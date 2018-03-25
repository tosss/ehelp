@isTest
private class ISVC_SyncRelatedCases_Test {
    @testSetup
    static void dataSetup() {
        Integer batchSize = 3;

        Id problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        Id requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        Id incidentRecordTypeId = ALL_RecordTypes_Utility.getIncidentRecordTypeId();
        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();

        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.country('United States').save();
        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAccountBuilder.getRecord().Id];

        List<Case> problems = new List<Case>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder problemCaseBuilder = new ISVC_Case_Builder();
            problemCaseBuilder.recordTypeId(problemRecordTypeId).subject('Problem Test Case 00'+i).build();
            problems.add(problemCaseBuilder.getRecord());
        }
        insert problems;

        List<Case> problemRelatedCases = new List<Case>();
        for(Case problem : problems){
            ISVC_Case_Builder requestCaseBuilder = new ISVC_Case_Builder();
            requestCaseBuilder.recordTypeId(requestRecordTypeId).parentId(problem.Id).subject('Request Test Case').build();
            problemRelatedCases.add(requestCaseBuilder.getRecord());
            ISVC_Case_Builder incidentCaseBuilder = new ISVC_Case_Builder();
            incidentCaseBuilder.recordTypeId(incidentRecordTypeId).parentId(problem.Id).subject('Incident Test Case').build();
            problemRelatedCases.add(incidentCaseBuilder.getRecord());
        }
        insert problemRelatedCases;

        List<Case> parentTerminationCases = new List<Case>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder parentCaseBuilder = new ISVC_Case_Builder();
            parentCaseBuilder.recordTypeId(terminationRecordTypeId).accountId(personAccount.Id).contactId(personAccount.PersonContactId)
                    .subject('Termination Test Case 00'+i).category('Personnel').subCategory('Termination/Leaver').build();
            parentTerminationCases.add(parentCaseBuilder.getRecord());
        }
        ISVC_Case_Handler.triggerDisabled = true;
        insert parentTerminationCases;

        List<Case> terminationSubCases = new List<Case>();
        for(Case parentCase : parentTerminationCases){
            ISVC_Case_Builder subCaseBuilder = new ISVC_Case_Builder();
            subCaseBuilder.recordTypeId(parentCase.RecordTypeId).accountId(parentCase.AccountId).contactId(parentCase.ContactId)
                    .subject(parentCase.Subject).category(parentCase.Category__c).subCategory(parentCase.Sub_Category__c)
                    .parentId(parentCase.Id).subCaseType('AD Termination').build();
            terminationSubCases.add(subCaseBuilder.getRecord());
        }
        insert terminationSubCases;
    }

    //Succesfull flow
    static testMethod void testCloseProblemRelatedCases() {
        Id problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        //Given: list of problem cases
        List<Case> problems = [SELECT Id, Status FROM Case WHERE RecordTypeId = :problemRecordTypeId];
        for(Case problem : problems){
            problem.Action_Taken__c = 'Configuration - Set up completed';
            problem.Root_Cause__c = 'Component failure';
            problem.Close_Related_Cases__c = true;
        }
        ISVC_Case_Handler.triggerDisabled = true;
        update problems;
        //When: ask to sync related cases
        Map<Id, Case> problemsMap = new Map<Id, Case>(problems);
        Test.startTest();
        ISVC_SyncRelatedCases.closeCasesReletedToProblems(problemsMap);
        Test.stopTest();
        //Then: all related cases are closed too
        for(Case relatedCase : [SELECT isClosed, Action_Taken__c, Root_Cause__c FROM Case WHERE ParentId IN :problemsMap.keySet()]){
            System.assertEquals(true, relatedCase.isClosed);
            System.assertEquals('Configuration - Set up completed', relatedCase.Action_Taken__c);
            System.assertEquals('Component failure', relatedCase.Root_Cause__c);
        }
    }

    //Succesfull flow
    static testMethod void testCloseRelatedCases() {
        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();
        //Given: list of termination sub cases
                Map<Id, Case> parentCases = new Map<Id, Case>([
                SELECT Id, RecordTypeId, RecordType.DeveloperName, Category__c, Sub_Category__c, Sub_Case_Type__c, Employee_Location__c,
                        AccountId, ContactId, OwnerId, ParentId
                FROM Case
                WHERE RecordTypeId = :terminationRecordTypeId AND ParentId = null
        ]);
        for(Case parentCase : parentCases.values()){
            parentCase.Status = 'Closed';
        }
        update parentCases.values();
        //When: ask to close parent cases
        Test.startTest();
        ISVC_SyncRelatedCases.closeRelatedCasesWhenParentCaseIsClosed(parentCases);
        Test.stopTest();
        //Then: all related cases are closed too
        for(Case relatedCase : [SELECT isClosed  FROM Case WHERE ParentId IN :parentCases.keySet()]){
            System.assertEquals(true, relatedCase.isClosed);
        }
    }

    //Succesfull flow
    static testMethod void testCloseParentCases() {
        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();
        //Given: list of termination sub cases
        Map<Id, Case> subCases = new Map<Id, Case>([
                SELECT Id, RecordTypeId, RecordType.DeveloperName, Category__c, Sub_Category__c, Sub_Case_Type__c, Employee_Location__c,
                        AccountId, ContactId, OwnerId, ParentId
                FROM Case
                WHERE RecordTypeId = :terminationRecordTypeId AND ParentId != null
        ]);
        Set<Id> parentCaseIds = new Set<Id>();
        for(Case subCase : subCases.values()){
            parentCaseIds.add(subCase.ParentId);
            subCase.Status = 'Closed';
        }
        update subCases.values();
        //When: ask to close parent cases
        Test.startTest();
        ISVC_SyncRelatedCases.closeParentCasesIfAllRelatedCasesAreClosed(parentCaseIds);
        Test.stopTest();
        //Then: all related cases are closed too
        for(Case parentCase : [SELECT isClosed  FROM Case WHERE Id IN :parentCaseIds]){
            System.assertEquals(true, parentCase.isClosed);
        }
    }
}