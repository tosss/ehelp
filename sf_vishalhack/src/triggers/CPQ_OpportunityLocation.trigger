//2016-09-22  -vishal.bandari@cdk.com - RQ-07834 : created Trigger

trigger CPQ_OpportunityLocation on Opportunity_Location__c (before insert,after insert,before delete,after delete) 
{
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            CPQ_OpportunityLocation_Handler.beforeInsert(Trigger.New);
        }
        else if(Trigger.IsDelete)
        {
            CPQ_OpportunityLocation_Handler.beforeDelete(Trigger.Old);
        }
    }
    else if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            CPQ_OpportunityLocation_Handler.afterInsert(Trigger.New);
        }
        else if(Trigger.IsDelete)
        {
            CPQ_OpportunityLocation_Handler.afterDelete(Trigger.Old);
        }
    }
}