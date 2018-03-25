//2015-04-22 - vishal.bandari@cdk.com - Created Trigger, Changes the Previous Process Coach and Previous EPC fields 
//2017-02-20 - lalitha.adduru@cdk.com - Added updateCoachingEPCEmailField to before update - RQ-08240.
//2017-04-17 - lalitha.adduru@cdk.com - refactored to have a single trigger - RQ-09019.
trigger ALL_TraverProject on Traver_Project__c (before insert, before update) 
{
    if(Trigger.IsBefore)
    {
        if(Trigger.isInsert)
        {
            ALL_TraverProject_Handler.onBeforeInsert(Trigger.New);
        }        
        if(Trigger.isUpdate)
        {
            ALL_TraverProject_Handler.onBeforeUpdate(Trigger.New, Trigger.oldMap);
        }
    }
}