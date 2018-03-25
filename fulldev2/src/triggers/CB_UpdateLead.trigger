//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user (even if trigger toggle is on )while running trigger code - RQ-06909 
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
trigger CB_UpdateLead on Lead(before insert, before update) 
{
    //2016-04-26 - lalitha.adduru@cdk.com - fetch code reference to on/off map for Lead (sObject)- RQ-06909
    Map<String, Boolean> codeReferenceToSwitchMap = new Map<String, Boolean>();
    codeReferenceToSwitchMap = ALL_TriggerToggle_Handler.getOrganizedTriggerToggles('Lead').codeReferenceToSwitchMap;
    
    //2016-04-26 - lalitha.adduru@cdk.com - fetch profileId to on/off map for ALL_Lead (code reference) on Lead (sObject)- RQ-06909
    Map<ID, Boolean> profileToSwitchMap = new Map<ID, Boolean>();
    profileToSwitchMap = ALL_TriggerToggleProfile_Handler.fetchProfileToSwitchMap('CB_UpdateLead','Lead');
    
    if(!profileToSwitchMap.containsKey(UserInfo.getProfileId()) || profileToSwitchMap.get(UserInfo.getProfileId()) ) // skip if it is integration user - RQ-06909
    {
        if(!codeReferenceToSwitchMap.containsKey('CB_UpdateLead') ||codeReferenceToSwitchMap.get('CB_UpdateLead')) // if 'on' is checked in trigger toggle for trigger , then run the enclosed code
        {
    		CB_UpdateLeadHandler.UpdateOpportunity(Trigger.NewMap, Trigger.OldMap);
        }
    }
}