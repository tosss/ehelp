@isTest
private class ISVC_CompleteCaseMilestones_Test {

    @testSetup
    static void dataSetup() {
        Integer batchSize = 3;

        Id locationAccountRecordTypeId = ALL_RecordTypes_Utility.getLocationAccountRecordTypeId();
        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.recordTypeId(locationAccountRecordTypeId).firstName('').lastName('Test Location').userId('').fedId('').inAD(false).save();
        Account locationAccount = personAccountBuilder.getRecord();

        ISVC_EntitlementSetting__mdt internalSupportEntitlementSetting = ALL_CustomSettings_Utility.getInternalSupportEntitlementSetting();
        SlaProcess internalSupportEntitlementProcess = [
                SELECT Id FROM SlaProcess
                WHERE SObjectType = 'Case' AND IsActive = true AND IsVersionDefault = true
                AND Name = :internalSupportEntitlementSetting.Entitlement_Process_Name__c];

        Entitlement internalSupportEntitlement = new Entitlement();
        internalSupportEntitlement.AccountId = locationAccount.Id;
        internalSupportEntitlement.SLAProcessId = internalSupportEntitlementProcess.Id;
        internalSupportEntitlement.Name = internalSupportEntitlementSetting.Entitlement_Name__c;
        internalSupportEntitlement.StartDate = Date.today();
        internalSupportEntitlement.EndDate = Date.today();
        insert internalSupportEntitlement;

        Id requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();

        List<Case> cases = new List<Case>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder requestCaseBuilder = new ISVC_Case_Builder();
            requestCaseBuilder.recordTypeId(requestRecordTypeId).subject('Request Test Case').build();
            cases.add(requestCaseBuilder.getRecord());
            ISVC_Case_Builder incidentCaseBuilder = new ISVC_Case_Builder();
            incidentCaseBuilder.recordTypeId(incidentRecordTypeId).subject('Incident Test Case').build();
            cases.add(incidentCaseBuilder.getRecord());
        }
        insert cases;
    }

    //Succesfull flow
    static testMethod void testCloseFirstResponseCaseMilestones() {
        Id requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        Set<Id> recordTypeIds = new Set<Id>{requestRecordTypeId, incidentRecordTypeId};
        //Given: list of incident and request cases assigned to user
        Map<Id, Case> cases = new Map<Id, Case>([SELECT Id, OwnerId, IsClosed FROM Case WHERE RecordTypeId IN :recordTypeIds]);
        for(Case cas : cases.values()){
            cas.OwnerId = UserInfo.getUserId();
        }
        ISVC_Case_Handler.triggerDisabled = true;
        update cases.values();
        //When: ask to close case milestones
        Test.startTest();
        ISVC_CompleteCaseMilestones.closeInternalSupportMilestones(cases);
        Test.stopTest();
        //Then: first response case milestones are completed
        for(CaseMilestone caseMilestone : [SELECT Id, MilestoneType.Name, IsCompleted FROM CaseMilestone WHERE CaseId IN :cases.keySet()]){
            if(caseMilestone.MilestoneType.Name == ISVC_CompleteCaseMilestones.FIRST_RESPONSE){
                System.assertEquals(true, caseMilestone.IsCompleted);
            } else if(caseMilestone.MilestoneType.Name == ISVC_CompleteCaseMilestones.RESOLUTION){
                System.assertEquals(false, caseMilestone.IsCompleted);
            }
        }
    }
}