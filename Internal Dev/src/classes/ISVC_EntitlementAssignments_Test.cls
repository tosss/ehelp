@isTest
private class ISVC_EntitlementAssignments_Test {

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
        ISVC_Case_Handler.triggerDisabled = true;
        insert cases;
    }

    //Succesfull flow
    static testMethod void testAssignEntitlements() {
        Id requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        Set<Id> recordTypeIds = new Set<Id>{requestRecordTypeId, incidentRecordTypeId};
        //Given: list of incident and request cases
        List<Case> cases = [SELECT Id, EntitlementId FROM Case WHERE RecordTypeId IN :recordTypeIds];
        //When: ask to assign entintements
        Test.startTest();
        ISVC_EntitlementAssignments.assignEntitlementsToCases(cases);
        Test.stopTest();
        //Then: entitlements are assigned
        for(Case cas : cases){
            System.assert(String.isNotBlank(cas.EntitlementId));
        }
    }
}