@isTest
private class ISVC_SyncRelatedTasks_Test {

    @testSetup
    static void dataSetup() {
        Integer batchSize = 3;

        Id terminationRecordTypeId = ALL_RecordTypes_Utility.getTerminationRecordTypeId();

        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.country('United States').save();
        Account personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAccountBuilder.getRecord().Id];

        List<Case> subCases = new List<Case>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder parentCaseBuilder = new ISVC_Case_Builder();
            parentCaseBuilder.recordTypeId(terminationRecordTypeId).accountId(personAccount.Id).contactId(personAccount.PersonContactId)
                    .subject('Termination Test Case 00'+i).category('Personnel').subCategory('Termination/Leaver')
                    .subCaseType('AD Termination').build();
            subCases.add(parentCaseBuilder.getRecord());
        }
        ISVC_Case_Handler.triggerDisabled = true;
        insert subCases;

        List<Task> tasks = new List<Task>();
        for(Case subCase : subCases){
            ISVC_Task_Builder taskBuilder = new ISVC_Task_Builder();
            taskBuilder.whatId(subCase.Id).whoId(subCase.ContactId).subject('AD Account Termination').build();
            tasks.add(taskBuilder.getRecord());
        }
        insert tasks;
    }

    //Succesfull flow
    static testMethod void testCloseSubCases() {
        //Given: list of tasks related to sub cases
        List<Task> tasks = [SELECT Id, WhatId, Subject, Status FROM Task];
        for(Task task : tasks){
            task.Status = 'Completed';
        }
        ISVC_Task_Handler.triggerDisabled = true;
        update tasks;

        //When: close sub cases
        Test.startTest();
        Set<Id> caseIds = new Set<Id>();
        for(Task task : tasks){
            caseIds.add(task.WhatId);
        }
        ISVC_SyncRelatedTasks.closeSubCaseIfRelatedTasksAreClosed(caseIds);
        Test.stopTest();

        //Then: parent sub cases are closed
        for(Case subCase : [SELECT Id, IsClosed FROM Case WHERE Id IN :caseIds]) {
            System.assertEquals(true, subCase.IsClosed);
        }
    }
}