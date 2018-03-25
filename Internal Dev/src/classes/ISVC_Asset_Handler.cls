// GLOBIT-5446 Bringing Asset Data into Salesforce

// 2017-11-14 stephen.li@cdk.com Created
public class ISVC_Asset_Handler implements ALL_TriggerHandler_Interface {

    public static Boolean triggerDisabled = false;
    private Id hardwareRecordTypeId;

    public Boolean isDisabled(){
        ALL_TriggerToggle__c triggerToggle = ALL_TriggerToggle__c.getInstance();
        Boolean isTriggerDisabled = triggerToggle.AllTriggersDisabled__c || triggerDisabled;
        return isTriggerDisabled;
    }
    
    public void beforeInsert(List<SObject> newItems) {
        List<Asset> assets = (List<Asset>) newItems;
        for(Asset a : assets) {
        		a.Software_Refresh_Required__c = true;
            updateOtherOwnerFields(a);
            defaultStatus(a);
        }
    }

    public void beforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        Map<Id, Asset> newAssets = (Map<Id, Asset>) newItems;
        Map<Id, Asset> oldAssets = (Map<Id, Asset>) oldItems;
        for (Id i : newAssets.keySet()) {
            Asset newAsset = newAssets.get(i);
            Asset oldAsset = oldAssets.get(i);
            if (newAsset.Last_Sms_Scan_Date_Time__c != oldAsset.Last_Sms_Scan_Date_Time__c) {
                newAsset.Software_Refresh_Required__c = true;
            }
            updateOtherOwnerFields(newAsset);
            defaultStatus(newAsset);
        }
    }
    
    private void updateOtherOwnerFields(Asset a) {
        System.debug('Inside updateOtherOwnerFields');
        hardwareRecordTypeId = ALL_RecordTypes_Utility.getHardwareRecordTypeId();
        if (a.Status == 'Inactive') {
            a.Hardware_owner__c = null;
            a.Active_Asset_Owner__c = null;
        } else {
            a.Active_Asset_Owner__c = a.AccountId;
            if (a.RecordTypeId == hardwareRecordTypeId) {
                a.Hardware_owner__c = a.AccountId;
            }
        }
    }
    
    private void defaultStatus(Asset a) {
        if (a.Status == null) {
            a.Status = 'Active';
        }
    }



    public void beforeDelete(Map<Id, SObject> oldItems) {}

    public void afterInsert(Map<Id, SObject> newItems) {}

    public void afterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) { }

    public void afterDelete(Map<Id, SObject> oldItems) {}

    public void afterUndelete(Map<Id, SObject> oldItems) {}

    public void andFinally(){ }
}