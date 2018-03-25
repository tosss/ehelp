//2017-03-31 - lalitha.adduru@cdk.com - commented this class as it's moved to ALL_Lead - RQ-06389
trigger CB_UpdateLead on Lead(before insert, before update) 
{
    //CB_UpdateLeadHandler.UpdateOpportunity(Trigger.NewMap, Trigger.OldMap);
}