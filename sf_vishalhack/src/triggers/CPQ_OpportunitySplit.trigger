trigger CPQ_OpportunitySplit on Opportunity_Split__c (before insert,before update,before delete)
{
    if(Trigger.IsBefore)
    {
        if(Trigger.IsInsert)
        {
            CPQ_OpportunitySplit_Handler.beforeInsert(Trigger.New);
        }
        else if(Trigger.IsUpdate)
        {
            CPQ_OpportunitySplit_Handler.beforeUpdate(Trigger.New,Trigger.oldMap);
        }
        else if(Trigger.IsDelete)
        {
            CPQ_OpportunitySplit_Handler.beforeDelete(Trigger.oldMap);
        }
    }
}