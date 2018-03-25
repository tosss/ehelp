trigger DS_LaserCatalogNumberPreventDuplicate on Laser_Ordered_Forms_Catalog_Numbers__c (before insert,before update) {
    
    if (Trigger.isInsert || Trigger.isupdate) {
        for (Laser_Ordered_Forms_Catalog_Numbers__c catalogNumbers : Trigger.New) {
            catalogNumbers.Catalog_Number_Must_Be_Unique__c = catalogNumbers.Name;
        }
    }

}