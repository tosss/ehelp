//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user while running trigger code - RQ-06909
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
trigger DS_ValidateEvent on Event (before insert, before update) 
{
    //2016-04-26 - lalitha.adduru@cdk.com - fetch code reference to on/off map for Lead (sObject)- RQ-06909
    Map<string, boolean> codeReferenceToSwitchMap = new Map<string, boolean>();
    codeReferenceToSwitchMap = ALL_TriggerToggle_Handler.getOrganizedTriggerToggles('Event').codeReferenceToSwitchMap;
	
    //2016-04-26 - lalitha.adduru@cdk.com - fetch profileId to on/off map for DS_ValidateEvent (code reference) on Event (sObject)
    Map<ID, boolean> profileToSwitchMap = new Map<ID, boolean>();
    profileToSwitchMap = ALL_TriggerToggleProfile_Handler.fetchProfileToSwitchMap('DS_ValidateEvent','Event');
    
    if(!profileToSwitchMap.containsKey(UserInfo.getProfileId()) || profileToSwitchMap.get(UserInfo.getProfileId()) ) // skip if it is integration user - RQ-06909
    {
        if(!codeReferenceToSwitchMap.containsKey('DS_ValidateEvent') || codeReferenceToSwitchMap.get('DS_ValidateEvent')) // if 'on' is checked in trigger toggle for trigger , then run the enclosed code
        {
            DS_ValidateActivity.Validate(Trigger.New);
        }
    }
    else
    {
        system.debug('DS_ValidateEvent integration user needs to skip this trigger');
    }
}