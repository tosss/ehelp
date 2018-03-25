//2016-04-13- lalitha.adduru@cdk.com - created this trigger to refactor triggers and handlers on User object - RQ-06757
//2016-05-02- anirudh.singh@cdk.com- Added system.isFuture() to avoid 'Future method cannot be called from a future method' error.
trigger ALL_User on User(before insert, before update, after insert, after update) 
{
    //2016-05-02- anirudh.singh@cdk.com- Added system.isFuture() to avoid 'Future method cannot be called from a future method' error.
    if(!system.isFuture())
    {
        if(Trigger.isBefore)
        {
            if(Trigger.isInsert && ALL_CheckRecursive.runCodeBlockOnce('User_BeforeInsert'))
            {
                All_User_Handler.beforeInsert(Trigger.New);
            }
            else if(Trigger.isUpdate && ALL_CheckRecursive.runCodeBlockOnce('User_BeforeUpdate'))
            {
                All_User_Handler.beforeUpdate(Trigger.NewMap,Trigger.oldMap);
            }
        }
        else if(Trigger.isAfter)
        {
            if(Trigger.isInsert && ALL_CheckRecursive.runCodeBlockOnce('User_AfterInsert'))
            {
                ALL_User_Handler.afterInsert(trigger.NewMap);
            }
            else if(Trigger.isUpdate && ALL_CheckRecursive.runCodeBlockOnce('User_AfterUpdate'))
            {
                ALL_User_Handler.afterUpdate(trigger.NewMap, trigger.OldMap);
            }
        }
    }
}