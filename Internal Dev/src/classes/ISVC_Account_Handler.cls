// GLOBIT 4675 - Create and/or Sync User record with the account record

// 2017-10-01 Marta.Malinowska@cdk.com
public class ISVC_Account_Handler implements ALL_TriggerHandler_Interface {

    public static Boolean triggerDisabled = false;
    private Id personAccountRecordTypeId;
    private Map<Id, Account> accountsToSyncWithUsers = new Map<Id, Account>();

    public Boolean isDisabled(){
        ALL_TriggerToggle__c triggerToggle = ALL_TriggerToggle__c.getInstance();
        Boolean isTriggerDisabled = triggerToggle.AllTriggersDisabled__c || triggerToggle.AccountTriggerDisabled__c || triggerDisabled;
        return isTriggerDisabled;
    }

    public void beforeInsert(List<SObject> newItems) {
    		List<Account> newAccounts = (List<Account>) newItems;
    		for (Account a : newAccounts) {
    			if (a.AD_Account_Expires__pc != null) {
    				a.AD_Account_Expires_Changed__pc = true;
    			}
    		}
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    		Map<Id, Account> newAccounts = (Map<Id, Account>) newItems;
        Map<Id, Account> oldAccounts = (Map<Id, Account>) oldItems;
    		for (Account a : newAccounts.values()) {
    			System.debug('New date = ' + a.AD_Account_Expires__pc);
    			System.debug('Old date = ' + oldAccounts.get(a.Id).AD_Account_Expires__pc);
    			if (a.AD_Account_Expires__pc != oldAccounts.get(a.Id).AD_Account_Expires__pc) {
    				a.AD_Account_Expires_Changed__pc = true;
    			}
    		}
    }

    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems) {
        Map<Id, Account> newAccounts = (Map<Id, Account>) newItems;
        personAccountRecordTypeId = ALL_RecordTypes_Utility.getPersonAccountRecordTypeId();

        for(Account newAccount : newAccounts.values()){
            if(newAccount.IsPersonAccount == true && newAccount.RecordTypeId != null && newAccount.RecordTypeId == personAccountRecordTypeId){
                accountsToSyncWithUsers.put(newAccount.Id, newAccount);
            }
        }
    }

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Account> newAccounts = (Map<Id, Account>) newItems;
        Map<Id, Account> oldAccounts = (Map<Id, Account>) oldItems;
        personAccountRecordTypeId = ALL_RecordTypes_Utility.getPersonAccountRecordTypeId();

        for(Account newAccount : newAccounts.values()){
        		Boolean updateCausedByTermCaseCreationBatch = newAccount.AD_Account_Expires_Changed__pc != oldAccounts.get(newAccount.Id).AD_Account_Expires_Changed__pc;
            if(newAccount.RecordTypeId != null && newAccount.RecordTypeId == personAccountRecordTypeId && !updateCausedByTermCaseCreationBatch){
                accountsToSyncWithUsers.put(newAccount.Id, newAccount);
            }
        }
    }

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> oldItems) {}

    public void andFinally(){
        if(!accountsToSyncWithUsers.isEmpty() && !System.isQueueable()) {
            System.enqueueJob(new ISVC_SyncPersonAccounts_Queueable(accountsToSyncWithUsers));
        }
    }
}