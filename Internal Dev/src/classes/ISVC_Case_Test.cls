@isTest
private class ISVC_Case_Test {
    @testSetup
    static void dataSetup() {
        Id cdkAdminSystemAdministratorProfileId = ALL_Profiles_Utility.getCdkAdminSystemAdministratorProfileId();
        ALL_User_Builder cdkAdminSystemAdministratorBuilder = new ALL_User_Builder(cdkAdminSystemAdministratorProfileId);
        cdkAdminSystemAdministratorBuilder.userName('cdkadminsystemadministrator@cdk.com').save();
        User cdkAdminSystemAdministrator = cdkAdminSystemAdministratorBuilder.getRecord();

        System.runAs(cdkAdminSystemAdministrator){
            Group terminationsGroup = new Group(Name='TEST Terminations', Type='Queue');
            insert terminationsGroup;
            QueuesObject terminationsQueue = new QueueSObject(QueueId=terminationsGroup.Id, sObjectType='Case');
            insert terminationsQueue;
        }

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
    }

    //Succesfull flow
    static testMethod void testCloseRelatedCases() {
        Integer batchSize = 3;

        Id problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        Id requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();

        //Given: list of problem cases
        List<Case> problems = new List<Case>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder problemCaseBuilder = new ISVC_Case_Builder();
            problemCaseBuilder.recordTypeId(problemRecordTypeId).subject('Problem Test Case 00'+i).build();
            problems.add(problemCaseBuilder.getRecord());
        }
        insert problems;

        List<Case> relatedCases = new List<Case>();
        for(Case problem : problems){
            ISVC_Case_Builder requestCaseBuilder = new ISVC_Case_Builder();
            requestCaseBuilder.recordTypeId(requestRecordTypeId).parentId(problem.Id).subject('Request Test Case').build();
            relatedCases.add(requestCaseBuilder.getRecord());
            ISVC_Case_Builder incidentCaseBuilder = new ISVC_Case_Builder();
            incidentCaseBuilder.recordTypeId(incidentRecordTypeId).parentId(problem.Id).subject('Incident Test Case').build();
            relatedCases.add(incidentCaseBuilder.getRecord());
        }
        insert relatedCases;
        //When: case statuses are updated
        for(Case problem : problems){
            problem.Action_Taken__c = 'Configuration - Set up completed';
            problem.Root_Cause__c = 'Component failure';
            problem.Close_Related_Cases__c = true;
        }
        Test.startTest();
        update problems;
        Test.stopTest();
        //Then: all related cases are closed too
        for(Case relatedCase : [SELECT isClosed, Action_Taken__c, Root_Cause__c FROM Case WHERE RecordTypeId != :problemRecordTypeId]){
            System.assertEquals(true, relatedCase.isClosed);
            System.assertEquals('Configuration - Set up completed', relatedCase.Action_Taken__c);
            System.assertEquals('Component failure', relatedCase.Root_Cause__c);
        }
    }

    //Succesfull flow
    static testMethod void testCreateSubCases() {
        Integer batchSize = 3;

        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.country('United States').save();
        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAccountBuilder.getRecord().Id];

        //Given: list of parent cases
        List<Case> parentCases = new List<Case>();
        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder parentCaseBuilder = new ISVC_Case_Builder();
            parentCaseBuilder.recordTypeId(terminationRecordTypeId).accountId(personAccount.Id).contactId(personAccount.PersonContactId)
                    .subject('Termination Test Case 00'+i).category('Personnel').subCategory('Termination/Leaver').build();
            parentCases.add(parentCaseBuilder.getRecord());
        }
        //When: create subcases for parent cases
        Test.startTest();
        insert parentCases;
        Test.stopTest();

        //Then: sub cases are created
        Map<Id, Case> parentCasesMap = new Map<Id, Case>(parentCases);
        for(Case parentCase : [SELECT Id, (SELECT Id, Sub_Case_Type__c FROM Cases) FROM Case WHERE Id IN :parentCasesMap.keySet()]){
            for(Case subCase : parentCase.Cases){
                System.assert(String.isNotBlank(subCase.Sub_Case_Type__c));
            }
        }
    }

    //Succesfull flow
    static testMethod void testCreateSubCaseTasks() {
        Integer batchSize = 3;

        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();
        Group terminationsQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name ='TEST Terminations'];

        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.country('United States').save();
        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAccountBuilder.getRecord().Id];

        ISVC_Case_Builder parentCaseBuilder = new ISVC_Case_Builder();
        parentCaseBuilder.recordTypeId(terminationRecordTypeId).accountId(personAccount.Id).contactId(personAccount.PersonContactId)
                .subject('Termination Parent Test Case').category('Personnel').subCategory('Termination/Leaver').build();
        Case parentCase = parentCaseBuilder.getRecord();
        ISVC_Case_Handler.triggerDisabled = true;
        insert parentCase;
        ISVC_Case_Handler.triggerDisabled = false;

        //Given: list of sub cases
        List<Case> subCases = new List<Case>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder subCaseBuilder = new ISVC_Case_Builder();
            subCaseBuilder.recordTypeId(terminationRecordTypeId).accountId(personAccount.Id).contactId(personAccount.PersonContactId)
                    .parentId(parentCase.Id).subject('Termination Test Case 00'+i).category('Personnel').subCategory('Termination/Leaver')
                    .subCaseType('AD Termination').ownerId(terminationsQueue.Id).build();
            subCases.add(subCaseBuilder.getRecord());
        }
        insert subCases;
        //When: create subcases for parent cases
        Test.startTest();
        for(Case subCase : subCases){
            subCase.OwnerId = UserInfo.getUserId();
        }
        update subCases;
        Test.stopTest();

        //Then: sub cases are created
        Map<Id, Case> subCasesMap = new Map<Id, Case>(subCases);
        for(Case subCase : [SELECT Id, OwnerId, (SELECT Id, OwnerId FROM Tasks) FROM Case WHERE Id IN :subCasesMap.keySet()]) {
            for(Task task : subCase.Tasks){
                System.assertEquals(subCase.OwnerId, task.OwnerId);
            }
        }
    }

    //Succesfull flow
    static testMethod void testAssignEntitlements() {
        Integer batchSize = 3;

        Id requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();

        //Given: list of incident and request cases
        List<Case> cases = new List<Case>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder requestCaseBuilder = new ISVC_Case_Builder();
            requestCaseBuilder.recordTypeId(requestRecordTypeId).subject('Request Test Case').build();
            cases.add(requestCaseBuilder.getRecord());
            ISVC_Case_Builder incidentCaseBuilder = new ISVC_Case_Builder();
            incidentCaseBuilder.recordTypeId(incidentRecordTypeId).subject('Incident Test Case').build();
            cases.add(incidentCaseBuilder.getRecord());
        }
        //When: ask to assign entintements
        Test.startTest();
        insert cases;
        Test.stopTest();
        //Then: entitlements are assigned
        for(Case cas : [SELECT Id, EntitlementId FROM Case WHERE Id IN :cases]){
            System.assert(String.isNotBlank(cas.EntitlementId));
        }
    }

    //Succesfull flow
    static testMethod void testCloseCaseMilestones() {
        Integer batchSize = 3;

        Id requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();

        //Given: list of incident and request cases assigned to user
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
        //When: close cases
        Test.startTest();
        for(Case cas : cases){
            cas.Status = 'Closed';
            cas.Action_Taken__c = 'Configuration - Set up completed';
            cas.Root_Cause__c = 'Component failure';
        }
        update cases;
        Test.stopTest();
        //Then: all related case milestones are completed
        for(CaseMilestone caseMilestone : [SELECT Id, MilestoneType.Name, IsCompleted FROM CaseMilestone WHERE CaseId IN :cases]){
            System.assertEquals(true, caseMilestone.IsCompleted);
        }
    }
}