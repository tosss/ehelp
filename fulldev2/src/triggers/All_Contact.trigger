//rq-05034 combine all previous contact triggers into one. put all handlers into one as well!
//2015-08-27 - brian.cook@cdk.com, bill.thurow@cdk.com
//2016-02-25- anirudh.singh@cdk.com- Modified for bringing it up to the standards. 
//2016-02-25- anirudh.singh@cdk.com- Added the ALL_CheckRecursive and test.isRunningTest() conditions to the IF Blocks.
trigger All_Contact on Contact(before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    if(Trigger.isbefore)
    {
        if((ALL_CheckRecursive.runCodeBlockOnce('Contact_BeforeInsert') || test.isRunningTest()) && Trigger.isInsert)
        {
            All_Contact_Handler.beforeInsert(Trigger.new);
        }
        else if((ALL_CheckRecursive.runCodeBlockOnce('Contact_BeforeUpdate') || test.isRunningTest()) && Trigger.isUpdate)
        {
            All_Contact_Handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        else if((ALL_CheckRecursive.runCodeBlockOnce('Contact_BeforeDelete') || test.isRunningTest()) && Trigger.isDelete)
        {
            All_Contact_Handler.beforeDelete_DS(Trigger.old, Trigger.oldMap);
        }
    } 
    else if(Trigger.isafter)
    {
        if((ALL_CheckRecursive.runCodeBlockOnce('Contact_AfterInsert') || test.isRunningTest()) && Trigger.isInsert)
        {
            //2016-03-15- anirudh.singh@cdk.com- For After Insert, Trigger.oldMap is Null.
            All_Contact_Handler.afterInsert(Trigger.new, Trigger.oldMap);
        }
        else if((ALL_CheckRecursive.runCodeBlockOnce('Contact_AfterUpdate') || test.isRunningTest()) && Trigger.isUpdate)
        {
            All_Contact_Handler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
        else if(Trigger.isDelete)
        {
            //not used
        }
        else if(Trigger.isUndelete)
        {
            //not used
        }
    }   
}