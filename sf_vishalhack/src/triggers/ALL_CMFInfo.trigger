//2016-08-18 - vishal.bandari@cdk.com - added after insert and update logic - RQ-07433
trigger ALL_CMFInfo on CMF_Info__c (before insert, before update, after insert, after update) 
{
    if(Trigger.IsInsert)
    {
        if(Trigger.IsBefore)
        {
            
        }
        else if(Trigger.IsAfter)
        {
            ALL_CMFInfo_Handler.afterInsert(Trigger.New);
        }
    }
    else if(Trigger.IsUpdate)
    {
        if(Trigger.IsBefore)
        {
            
        }
        else if(Trigger.IsAfter)
        {
            ALL_CMFInfo_Handler.afterUpdate(Trigger.New, Trigger.OldMap);
        }
    }
}