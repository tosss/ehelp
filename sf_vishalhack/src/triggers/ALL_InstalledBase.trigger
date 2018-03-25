trigger ALL_InstalledBase on Installed_Base__c (After insert, After update) 
{
    CB_Entitlements_Handler.createEntitlements(Trigger.new, Trigger.oldMap);
}