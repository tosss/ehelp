// GLOBIT-5239: Create termination case based on the employee termination record in SuccessFactor
//
// 2017-1-20 stephen.li@cdk.com Created
public with sharing class ISVC_Deactivation_Handler implements ALL_TriggerHandler_Interface {
	
	public static Boolean triggerDisabled = false;
	public static List<Deactivation__c> newDeactivations = new List<Deactivation__c>();
	public static List<Case> casesToBeInserted = new List<Case>();
	
	public Boolean isDisabled(){
        ALL_TriggerToggle__c triggerToggle = ALL_TriggerToggle__c.getInstance();
        Boolean isTriggerDisabled = triggerToggle.AllTriggersDisabled__c || triggerToggle.CaseTriggerDisabled__c || triggerDisabled;
        return isTriggerDisabled;
    }
    
    public void beforeInsert(List<SObject> newItems) {}
    
    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void beforeDelete(Map<Id, SObject> oldItems) {}
    
    public void afterInsert(Map<Id, SObject> newItems) {
    		newDeactivations = (List<Deactivation__c>) newItems.values();
    		casesToBeInserted = ISVC_CreateTermCase.createCases(newDeactivations);
    }
    
    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void afterDelete(Map<Id, SObject> oldItems) {}
    
    public void afterUndelete(Map<Id, SObject> oldItems) {}
    
    public void andFinally() {
    		if (casesToBeInserted.size() > 0) {
    			ALL_PersistenceHelper.insertObjs(casesToBeInserted, newDeactivations);
    		}
    }
    
}