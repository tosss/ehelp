// GLOBIT-4019: Create tasks after a user takes the ownership of a subcase
//
// 2017-10-19 marta.malinowska@cdk.com Created
public class ISVC_CreateSubCaseTasks {

    private static Map<Id, RecordType> caseRecordTypesMap;
    @testVisible
    private static Map<String, Map<String, Set<String>>> taskSubjectsTestMap;
    private static Map<String, Map<String, Set<String>>> taskSubjectsMap;
    private static List<Task> tasksToInsert;

    public static void createTasksForParentSubCases(List<Case> parentSubCases){
        caseRecordTypesMap = new Map<Id, RecordType>(ALL_RecordTypes_Utility.getCaseRecordTypes());
        taskSubjectsMap = ISVC_SubCaseSettings.getTaskSubjectsMap();
        if(Test.isRunningTest() && taskSubjectsTestMap != null){
            taskSubjectsMap = taskSubjectsTestMap;
        }
        tasksToInsert = getTasksToInsert(parentSubCases);
        insert tasksToInsert;
    }

    private static List<Task> getTasksToInsert(List<Case> parentSubCases){
        List<Task> newTasks = new List<Task>();

        String recordTypeName;
        String combinedKey;
        Map<String, Set<String>> tempMap;
        for(Case parentSubCase : parentSubCases){
            recordTypeName = caseRecordTypesMap.containsKey(parentSubCase.RecordTypeId) ? caseRecordTypesMap.get(parentSubCase.RecordTypeId).DeveloperName : '';
            combinedKey = ISVC_SubCaseSettings.getTaskSubjectKey(recordTypeName, parentSubCase.Category__c, parentSubCase.Sub_Category__c, parentSubCase.Sub_Case_Type__c);
            if(taskSubjectsMap.containsKey(parentSubCase.Employee_Location__c)){
                tempMap = taskSubjectsMap.get(parentSubCase.Employee_Location__c);
                if(tempMap.containsKey(combinedKey)){
                    for(String taskSubject : tempMap.get(combinedKey)){
                        newTasks.add(createTask(parentSubCase, taskSubject));
                    }
                }
            }
        }
        return newTasks;
    }

    private static Task createTask(Case parentSubCase, String taskSubject){
        Task newTask = new Task();
        newTask.WhatId = parentSubCase.Id;
        newTask.WhoId = parentSubCase.ContactId;
        newTask.Subject = taskSubject;
        newTask.OwnerId = parentSubCase.OwnerId;
        // GLOBIT-6312 Set the task due date to be 48 hours (2 calendar days) after the case creation
        if (newTask.Subject == 'AD Account Termination') {
        		newTask.ActivityDate = parentSubCase.CreatedDate.addDays(2).date();
        		System.debug('Setting task due date to ' + newTask.ActivityDate);
        }
        return newTask;
    }

}