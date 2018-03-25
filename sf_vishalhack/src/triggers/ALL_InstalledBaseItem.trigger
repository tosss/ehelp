trigger ALL_InstalledBaseItem on Installed_Base_Item__c (After Insert, After Update) 
{
    CB_Entitlements_Handler.createEntitlements(Trigger.new, Trigger.oldMap);
}