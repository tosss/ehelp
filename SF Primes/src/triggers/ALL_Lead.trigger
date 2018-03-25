//2015-10-13 Hemanth - added recursive check on DS_UpdateCampaignAccountMember_Handler 
//2015-10-27 Hemanth - Added Test.isRunning check to access blocked code from test class
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