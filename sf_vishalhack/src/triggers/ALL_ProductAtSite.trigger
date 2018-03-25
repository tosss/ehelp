//2016-12-07 -venkata.shrivol@cdk.com -Created
trigger ALL_ProductAtSite on Product_at_Site__c (after insert) 
{
	if(Trigger.isInsert)
	{
		if(Trigger.isAfter)
		{
            if(ALL_CheckRecursive.runCodeBlockOnce('ALL_ProductAtSite_Handler'))
            {
                ALL_ProductAtSite_Handler.afterInsert(Trigger.New);
            }
		}
	}    
}