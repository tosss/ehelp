//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user (even if trigger toggle is on ) while running trigger code - RQ-06909
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
trigger DS_ValidateTask on Task (before insert, before update) 
{
    //2016-04-26 - lalitha.adduru@cdk.com - fetch code reference to on/off map for Task (sObject)- RQ-06909
    Map<string, boolean> codeReferenceToSwitchMap = new Map<string, boolean>();
    codeReferenceToSwitchMap = ALL_TriggerToggle_Handler.getOrganizedTriggerToggles('Task').codeReferenceToSwitchMap;
    
    //2016-04-26 - lalitha.adduru@cdk.com -  fetch profileId to on/off map for DS_ValidateTask (code reference) on Task (sObject)
    Map<ID, boolean> profileToSwitchMap = new Map<ID, boolean>();
    profileToSwitchMap = ALL_TriggerToggleProfile_Handler.fetchProfileToSwitchMap('DS_ValidateTask','Task');
    
    if(!profileToSwitchMap.containsKey(UserInfo.getProfileId()) || profileToSwitchMap.get(UserInfo.getProfileId()) ) // skip if it is integration user - RQ-06909
    {
        if(!codeReferenceToSwitchMap.containsKey('DS_ValidateTask') || codeReferenceToSwitchMap.get('DS_ValidateTask')) // if 'on' is checked in trigger toggle for trigger , then run the enclosed code
        {
            DS_ValidateActivity.Validate(Trigger.New);
        }
    }
}