//2016-09-01- anirudh.singh@cdk.com- Created this Trigger.
trigger ALL_Hours_Of_Operation on Hours_Of_Operation__c(before insert, before update, after insert, after update)
{
    
    if(Trigger.isBefore)
    {
       ALL_HoursOfOperation_Handler.checkDuplicates(Trigger.New, Trigger.oldMap);
       
       ALL_HoursOfOperation_Handler.beforeInsertAndBeforeUpdate(Trigger.New);
    }
    else
    {
        if( ( Trigger.isInsert || Trigger.isUpdate ) && ALL_CheckRecursive.runCodeBlockOnce('ALL_HoursOfOperation_Handler_afterInsert'))
        {
            ALL_HoursOfOperation_Handler.afterInsert(Trigger.NewMap);
        }    
    }
}