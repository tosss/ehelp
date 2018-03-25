trigger ALL_BusinessSites on Business_Site__c (before insert, before update, after insert, after update, before delete, after delete)
{
    ALL_BusinessSites_Handler.fieldSettingMethod(Trigger.oldMap, Trigger.new);
}