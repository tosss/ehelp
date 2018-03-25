trigger DS_HardwareAssetNamePreventDuplicate on Hardware_Asset__c (before insert,before update) {
    
    if (Trigger.isInsert || Trigger.isupdate) {
        for (Hardware_Asset__c ha : Trigger.New) {
            ha.Hardware_Asset_Name_must_be_Unique__c = ha.Name;
        }
    }

}