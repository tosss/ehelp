@isTest
private class ISVC_CreateSubCaseTasks_Test {

    @testSetup
    static void dataSetup() {
        Integer batchSize = 3;

        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();

        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.country('United States').save();
        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAccountBuilder.getRecord().Id];

        List<Case> parentCases = new List<Case>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder parentCaseBuilder = new ISVC_Case_Builder();
            parentCaseBuilder.recordTypeId(terminationRecordTypeId).accountId(personAccount.Id).contactId(personAccount.PersonContactId)
                    .subject('Termination Test Case 00'+i).category('Personnel').subCategory('Termination/Leaver').build();
            parentCases.add(parentCaseBuilder.getRecord());
        }
        ISVC_Case_Handler.triggerDisabled = true;
        insert parentCases;

        List<Case> subCases = new List<Case>();
        for(Case parentCase : parentCases){
            ISVC_Case_Builder subCaseBuilder = new ISVC_Case_Builder();
            subCaseBuilder.recordTypeId(parentCase.RecordTypeId).accountId(parentCase.AccountId).contactId(parentCase.ContactId)
                    .subject(parentCase.Subject).category(parentCase.Category__c).subCategory(parentCase.Sub_Category__c)
                    .parentId(parentCase.Id).subCaseType('AD Termination').build();
            subCases.add(subCaseBuilder.getRecord());
        }
        insert subCases;
    }

    //Succesfull flow
    static testMethod void testCreateSubCases() {
        //Given: list of termination sub cases
        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();
        Map<Id, Case> subCases = new Map<Id, Case>([
                SELECT Id, RecordTypeId, RecordType.DeveloperName, Category__c, Sub_Category__c, Sub_Case_Type__c, Employee_Location__c,
                        AccountId, ContactId, OwnerId, CreatedDate
                FROM Case
                WHERE RecordTypeId = :terminationRecordTypeId AND ParentId != null
        ]);

        String empLocation = subCases.values()[0].Employee_Location__c;
        String combinedKey = ISVC_SubCaseSettings.getTaskSubjectKey(ALL_RecordTypes_Utility.RT_TERMINATION, 'Personnel', 'Termination/Leaver', 'AD Termination');
        Set<String> taskSubjects = new Set<String>{
                'AD Account Termination', '	AD Admin Account Termination'
        };

        //When: create tasks for sub cases
        Test.startTest();
        ISVC_CreateSubCaseTasks.taskSubjectsTestMap = new Map<String, Map<String, Set<String>>>();
        ISVC_CreateSubCaseTasks.taskSubjectsTestMap.put(empLocation, new Map<String, Set<String>>{
                combinedKey => taskSubjects
        });
        ISVC_CreateSubCaseTasks.createTasksForParentSubCases(subCases.values());
        Test.stopTest();

        //Then: tasks are created
        for(Case subCase : [SELECT Id, (SELECT Id, Subject FROM Tasks) FROM Case WHERE Id IN :subCases.keySet()]) {
            System.assertEquals(2, subCase.Tasks.size());
        }
    }
}