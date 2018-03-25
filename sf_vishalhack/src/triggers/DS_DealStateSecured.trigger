//2016-01-22- anirudh.singh@cdk.com- Modified this Trigger to bring it up to Standards for Request RQ-06022.
trigger DS_DealStateSecured on Deal_State_Secured__c(before insert, after insert) 
{
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            DS_DealStateSecured_Handler.preventMultipleRecsOnParent(Trigger.New);
        }
    }
    //2015-01 modified by Lalitha Adduru to after insert, as a Id can be created ( thereby queried ) for a record only after insert.
    else if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            DS_DealStateSecured_Handler.updateDealStateRecords(Trigger.New);
        }
    }
}