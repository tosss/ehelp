trigger ALL_BusinessSites on Business_Site__c (before insert, before update, after insert, after update, before delete, after delete)
{
    // 2016-04-20 ALL_BusinessSites_Handler class is invoked for BusinessSite handling
    ALL_BusinessSites_Handler.fieldSettingMethod(Trigger.OldMap, Trigger.New);
    
    GlobalSettings__c gs = GlobalSettings__c.getInstance();

    // 2016-04-20 ALL_OEMAndBrand_Handler class is invoked for OEM and BrandRelationship handling
	if ((Trigger.isAfter) && (Trigger.isInsert || Trigger.isUpdate) && gs.BrandRelationship_Synch__c) 
    {
        //Query to get additional data, such as from the Account fields
        List<Business_Site__c> newBusinessSites=ALL_OEMAndBrand_Handler.getFullDataForRecords(Trigger.New);

        //Pass that additional data to the methods that do the actual processing
        if ((newBusinessSites != null) && (newBusinessSites.size() > 0)) {
			ALL_OEMAndBrand_Handler.createOrUpdateBrandRelationshipRecords(newBusinessSites);
		}
    }
}