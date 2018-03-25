// 2015-12-04 hemanth.kesapragada@cdk.com - Creates policies and contacts when user is inserted or updated
// EMP_UserAfterInsert is renamed as EMP_User
trigger EMP_User on User (after insert,after update) 
{
    if(Trigger.isbefore) 
    {
        
    } 
    else if(Trigger.isAfter) 
    {
        if(Test.isRunningTest() || (
            Trigger.isInsert && ALL_CheckRecursive.runCodeBlockOnce('User_AfterInsertOrUpdate'))) 
        {
            EMP_User_Handler.afterInsert(Trigger.new,Trigger.newMap);
        } 
        else if(Test.isRunningTest() || (
            Trigger.isUpdate && ALL_CheckRecursive.runCodeBlockOnce('User_AfterInsertOrUpdate'))) 
        {
            EMP_User_Handler.afterUpdate(Trigger.old,Trigger.new,Trigger.oldMap,Trigger.newMap);
        } 
    }
}