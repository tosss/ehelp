// GLOBIT-4019: Create tasks after an owner of sub case is changed from queue to individual user
//
// 2017-10-19 marta.malinowska@cdk.com Created
public class ISVC_Task_Handler implements ALL_TriggerHandler_Interface {

    public static Boolean triggerDisabled = false;
    private Set<Id> casesToCheckStatus = new Set<Id>();

    public Boolean isDisabled(){
        ALL_TriggerToggle__c triggerToggle = ALL_TriggerToggle__c.getInstance();
        Boolean isTriggerDisabled = triggerToggle.AllTriggersDisabled__c || triggerToggle.TaskTriggerDisabled__c || triggerDisabled;
        return isTriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {}

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems) {}

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Task> newTasks = (Map<Id, Task>) newItems;
        Map<Id, Task> oldTasks = (Map<Id, Task>) oldItems;

        Task newTask, oldTask;
        Boolean isRelatedToCase, isNewStatusClosed;
        for(Id taskId : newTasks.keySet()){
            newTask = newTasks.get(taskId);
            oldTask = oldTasks.get(taskId);
            isRelatedToCase = newTask.WhatId.getSobjectType() == Case.getSObjectType();
            isNewStatusClosed = newTask.Status != oldTask.Status && newTask.IsClosed;
            if(isRelatedToCase && isNewStatusClosed){
                casesToCheckStatus.add(newTask.WhatId);
            }
        }
    }

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> oldItems) {}

    public void andFinally(){
        if(!casesToCheckStatus.isEmpty()){
            ISVC_SyncRelatedTasks.closeSubCaseIfRelatedTasksAreClosed(casesToCheckStatus);
        }
    }
}