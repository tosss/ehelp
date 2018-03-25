//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user while running trigger code - RQ-06909
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
//2016-05-26 - vishal.bandari@cdk.com - added logic for isAfter Insert and Update - RQ-07013
//2016-07-13 - ragashalini.koka@cdk.com - modified the updatePrimaryAccountIds to run before insert and before update - RQ-07327
//2016-11-02 - ragashalini.koka@cdk.com - added the process builder functionality to trigger - RQ-08117
trigger ALL_Event on Event (before insert,after insert, before update, after update) 
{ 
    if(Trigger.IsBefore)
    {
        list<Event> newEventList = ALL_TriggerToggle_Handler.ProfileFilter(trigger.new, 'Event');
        DS_ValidateActivity.Validate(newEventList);
    }
    if(Trigger.IsInsert && Trigger.IsBefore && ALL_CheckRecursive.runCodeBlockOnce('ALL_Event_BeforeInsert'))
    {
        ALL_Event_Handler.updatePrimaryAccountIds(Trigger.New);
    }
    if(Trigger.IsUpdate && Trigger.IsBefore && ALL_CheckRecursive.runCodeBlockOnce('ALL_Event_BeforeUpdate'))
    {
        ALL_Event_Handler.updatePrimaryAccountIds(Trigger.New);
    }
    
    //2016-11-02 - ragashalini.koka@cdk.com - added the process builder functionality to trigger - RQ-08117
    if(Trigger.isAfter )
    {
        if(Trigger.isInsert || Trigger.isUpdate) 
        {
            ALL_Event_Handler.updateServiceConnectVisitTracking(Trigger.newMap, 'Event');
        }
        
    }
}