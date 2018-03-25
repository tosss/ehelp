//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user (even if trigger toggle is on ) while running trigger code - RQ-06909
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
//2016-05-26 - vishal.bandari@cdk.com - added logic for isAfter Insert and Update - RQ-07013
//2016-07-13 - ragashalini.koka@cdk.com - modified the updatePrimaryAccountIds to run before insert and before update - RQ-07327
//2016-08-29 - ragashalini.koka@cdk.com - added logic for before insert and before update  - RQ-04812
//2016-11-02 - ragashalini.koka@cdk.com - added the process builder functionality to trigger - RQ-08117
trigger ALL_Task on Task (before insert, before update, after insert, after update) 
{
    list<Task> newTaskList;
    
    if(Trigger.isBefore)
    {  
        newTaskList = ALL_TriggerToggle_Handler.ProfileFilter(trigger.new, 'Task');
        
        if(All_CheckRecursive.runCodeBlockOnce('DS_ValidateTask_isBefore'))
        {    
            DS_ValidateActivity.Validate(newTaskList);
        } 
        if(trigger.isUpdate || trigger.isInsert)
        {           
            DS_TraverProjectUpdate.validate(newTaskList);
        }
    }    
    
    // For reference: Added 12/04/2014 SivaP- added below code to prevent non Lao related tasks from going to the task 
    // trigger handler during the task mass cloning process, 
    // that was causing null pointer exception
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {       
        list<Task> LaoRelatedTasks = new list<Task>();
        
        for(task t: newTaskList)
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
    
    //2016-08-29 - ragashalini.koka@cdk.com RQ-04812 - added logic to update Completed_Date__c based on Status
    //This is done through trigger because workflow rule will not be fired when 'Send An Email' is clicked on Activity History 
    if(Trigger.isBefore) 
    {
        if(ALL_CheckRecursive.runCodeBlockOnce('ALL_Task_BeforeInsert_BeforeUpdate') && (Trigger.isInsert || Trigger.isUpdate))
        {
            ALL_Task_Handler.updatePrimaryAccountIds(Trigger.New);
            //2016-10-06 ragashalini.koka@cdk.com - commented the code as it is no longer needed
            //ALL_Task_Handler.updateCompletedDate(Trigger.New);
        }
    }
    
     //2016-11-02 - ragashalini.koka@cdk.com - added the process builder functionality to trigger - RQ-08117
     if(Trigger.isAfter )
    {
        if(Trigger.isInsert || Trigger.isUpdate) 
        {
            ALL_Task_Handler.updateServiceConnectVisitTracking(Trigger.newMap, 'Task');
        }
        
    }
}