//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user (even if trigger toggle is on ) while running trigger code - RQ-06909
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
trigger ALL_Task on Task (before insert, before update, after insert, after update) 
{
   //2016-04-26 - lalitha.adduru@cdk.com - fetch code reference to on/off map for Task (sObject)- RQ-06909
    Map<string, boolean> codeReferenceToSwitchMap = new Map<string, boolean>();
    codeReferenceToSwitchMap = ALL_TriggerToggle_Handler.getOrganizedTriggerToggles('Task').codeReferenceToSwitchMap;
    
    //2016-04-26 - lalitha.adduru@cdk.com -  fetch profileId to on/off map for ALL_Task (code reference) on Task (sObject)
    Map<ID, boolean> profileToSwitchMap = new Map<ID, boolean>();
    profileToSwitchMap = ALL_TriggerToggleProfile_Handler.fetchProfileToSwitchMap('ALL_Task','Task');
    
    if(!profileToSwitchMap.containsKey(UserInfo.getProfileId()) || profileToSwitchMap.get(UserInfo.getProfileId()) ) // skip if it is integration user - RQ-06909
    {
        if(!codeReferenceToSwitchMap.containsKey('ALL_Task') || codeReferenceToSwitchMap.get('ALL_Task')) // if 'on' is checked in trigger toggle for trigger , then run the enclosed code
        {
            if(Trigger.isBefore)
            {         
                if(All_CheckRecursive.runCodeBlockOnce('DS_ValidateTask_isBefore'))
                {    
                    DS_ValidateActivity.Validate(Trigger.New);
                } 
                if(trigger.isUpdate || trigger.isInsert)
                {           
                    DS_TraverProjectUpdate.validate(Trigger.new);
                }
            }    
            
            // For reference: Added 12/04/2014 SivaP- added below code to prevent non Lao related tasks from going to the task 
            // trigger handler during the task mass cloning process, 
            // that was causing null pointer exception
            if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            {       
                list<Task> LaoRelatedTasks = new list<Task>();
                
                for(task t: Trigger.new)
                {   
                    if(t.WhatId != null)
                    {
                        if(t.WhatId.getSobjectType() == schema.Laser_Artwork_Order__c.sObjectType)
                        {
                            LaoRelatedTasks.add(t);
                        }
                    }
                }
                
                if(LaoRelatedTasks != null && !LaoRelatedTasks.isEmpty()) // this will prevent the non-lao related tasks from entering task trigger
                {
                    if(All_CheckRecursive.runCodeBlockOnce('DS_ValidateTask_isAfter'))
                    {          
                        DS_TaskRollUpHandler.TaskRollUp(LaoRelatedTasks);                                
                    }
                }     
            } 
        }
    }
}