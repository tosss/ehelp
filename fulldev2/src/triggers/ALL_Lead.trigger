//2015-10-13 Hemanth - added recursive check on DS_UpdateCampaignAccountMember_Handler 
//2015-10-27 Hemanth - Added Test.isRunning check to access blocked code from test class
//2016-04-25 - lalitha.adduru@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com - modified to skip integration user while running trigger code - RQ-06909 
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
trigger ALL_Lead on Lead (after insert,after update) 
{
    //2016-04-26 - lalitha.adduru@cdk.com - fetch code reference to on/off map for Lead (sObject)- RQ-06909
    Map<string, boolean> codeReferenceToSwitchMap = new Map<string, boolean>();
    codeReferenceToSwitchMap = ALL_TriggerToggle_Handler.getOrganizedTriggerToggles('Lead').codeReferenceToSwitchMap;
    
    //2016-04-26 - lalitha.adduru@cdk.com -  fetch profileId to on/off map for ALL_Lead (code reference) on Lead (sObject)
    Map<ID, boolean> profileToSwitchMap = new Map<ID, boolean>();
    profileToSwitchMap = ALL_TriggerToggleProfile_Handler.fetchProfileToSwitchMap('ALL_Lead','Lead');
    
    if(!profileToSwitchMap.containsKey(UserInfo.getProfileId()) || profileToSwitchMap.get(UserInfo.getProfileId()) ) // skip if it is integration user - RQ-06909
    {
        if(!codeReferenceToSwitchMap.containsKey('ALL_Lead') || codeReferenceToSwitchMap.get('ALL_Lead')) // if 'on' is checked in trigger toggle for trigger , then run the enclosed code
        {
            if(Trigger.isAfter)
            {
                if(ALL_CheckRecursive.runCodeBlockOnce('UpdateCampaignAccountMemberLead09302015'))
                {
                    DS_UpdateCampaignAccountMember_Handler.updateCampaignAccountMember(Trigger.Old,Trigger.New);
                }
            }
        }
    }
}