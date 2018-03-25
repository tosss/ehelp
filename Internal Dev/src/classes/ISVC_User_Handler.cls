public class ISVC_User_Handler implements ALL_TriggerHandler_Interface{
    
    public static Boolean triggerDisabled = false;

    public Boolean isDisabled(){
        ALL_TriggerToggle__c triggerToggle = ALL_TriggerToggle__c.getInstance();
        Boolean isTriggerDisabled = triggerToggle.AllTriggersDisabled__c || triggerToggle.UserTriggerDisabled__c || triggerDisabled;
        return isTriggerDisabled;
    }
    
    public void beforeInsert(List<SObject> newItems) {
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    }
 
    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems) {
    	ALL_UserGroupPermissionSet_Helper.addPermissionSetsAndGroups(newItems.values());
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    	ALL_UserGroupPermissionSet_Helper.addPermissionSetsAndGroups(newItems.values());
    }

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> oldItems) {}   
    
    
    public void andFinally(){
    }
}