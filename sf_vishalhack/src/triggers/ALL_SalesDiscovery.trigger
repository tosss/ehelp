//2017-05-17 - lalitha.adduru@cdk.com - created this trigger - RQ-09223
trigger ALL_SalesDiscovery on Sales_Discovery__c (before insert) 
{
    if(Trigger.IsBefore)
    {
        if(Trigger.IsInsert)
        {
            ALL_SalesDiscovery_Handler.beforeInsert(Trigger.New);
        }
    }
}