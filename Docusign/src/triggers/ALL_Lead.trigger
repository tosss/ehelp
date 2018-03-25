trigger ALL_Lead on Lead (after insert,after update) 
{
    if(Trigger.isAfter)
    {
        if(ALL_CheckRecursive.runCodeBlockOnce('UpdateCampaignAccountMemberLead09302015'))
        {
            DS_UpdateCampaignAccountMember_Handler.updateCampaignAccountMember(Trigger.Old,Trigger.New);
        }
    }
}