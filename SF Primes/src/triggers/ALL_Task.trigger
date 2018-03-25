trigger ALL_Task on Task (before insert, before update, after insert, after update) 
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