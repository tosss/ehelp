//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user while running trigger code - RQ-06909
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
//2016-05-27 - sanjay.ghanathey@cdk.om - Commented the code and moved to ALL_Event to meet the coding standards
trigger DS_ValidateEvent on Event (before insert, before update) 
{ 
  /*  list<Event> newEventList = ALL_TriggerToggle_Handler.ProfileFilter(trigger.new, 'Event');
    system.debug(newEventList);
    DS_ValidateActivity.Validate(newEventList);
*/
}