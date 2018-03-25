/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Consolidated SubProject External Reference triggers
Test Class:
History
10/20/14    Michael Lasala      Created
09/07/15    Vishal Bandari      invoked IMP_SperToFormsOrderUpdate_Handler.updateFormsOrder 
2015-11-02 - siva.pragada@cdk.com - added null checks and formatted code according to standards.
------------------------------------------------------------*/
trigger IMP_SubProjectExternalReference on SubProject_External_Reference__c (
    before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{ 
    if(Trigger.isbefore) 
    {
        if(Trigger.isInsert && ALL_CheckRecursive.runCodeBlockOnce('[SubProject_External_Reference__c]_BeforeInsert'))
        {
            IMP_SubProjectExternalReference_Handler.beforeInsert(Trigger.new);
        } 
        else if(Trigger.isUpdate && ALL_CheckRecursive.runCodeBlockOnce('[SubProject_External_Reference__c]_BeforeUpdate')) 
        {
            IMP_SubProjectExternalReference_Handler.beforeUpdate(Trigger.new,Trigger.oldMap);
        } 
        /*else if(Trigger.isDelete && ALL_CheckRecursive.runCodeBlockOnce('[SubProject_External_Reference__c]_BeforeDelete')) 
        {
            IMP_SubProjectExternalReference_Handler.beforeDelete(Trigger.old,Trigger.oldMap);
        }*/
    } 
    else if(Trigger.isAfter)
    {
        if(Trigger.isInsert && ALL_CheckRecursive.runCodeBlockOnce('[SubProject_External_Reference__c]_AfterInsert')) 
        {
            IMP_SubProjectExternalReference_Handler.afterInsert(Trigger.new);
        } 
        else if(Trigger.isUpdate && ALL_CheckRecursive.runCodeBlockOnce('[SubProject_External_Reference__c]_AfterUpdate')) 
        {
            IMP_SubProjectExternalReference_Handler.afterUpdate(Trigger.new,Trigger.oldMap);
        } 
        /*else if(Trigger.isDelete && ALL_CheckRecursive.runCodeBlockOnce('[SubProject_External_Reference__c]_AfterDelete')) 
        {
            IMP_SubProjectExternalReference_Handler.afterDelete(Trigger.old,Trigger.oldMap);
        }*/ 
        /*else if(Trigger.isUndelete && ALL_CheckRecursive.runCodeBlockOnce('[SubProject_External_Reference__c]_AfterUndelete')) 
        {
            IMP_SubProjectExternalReference_Handler.afterUndelete(Trigger.new,Trigger.newMap);
        }*/
    }
    
}