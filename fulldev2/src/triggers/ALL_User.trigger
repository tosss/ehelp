trigger ALL_User on User (after insert, after update, before insert, before update) 
{
    if (Trigger.isBefore)
    {
        if((Trigger.isInsert || Trigger.isUpdate) && ALL_CheckRecursive.runCodeBlockOnce('User_BeforeInsertUpdate'))
        {
            DS_UserToEmployeeUpdateTrigger_Handler.MakeFederationIDRequired(Trigger.New, Trigger.NewMap);  
        }
    }   
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert && ALL_CheckRecursive.runCodeBlockOnce('User_AfterInsert'))
        {
            ALL_User_Handler.createNewContactAndPolicy(Trigger.NewMap);
        }
        if(Trigger.isUpdate && ALL_CheckRecursive.runCodeBlockOnce('User_AfterUpdate'))
        {
            DS_UserToEmployeeUpdateTrigger_Handler.UserToEmployee(Trigger.new, Trigger.NewMap, Trigger.OldMap);
        }
        if ((Trigger.isInsert || Trigger.isUpdate) && Trigger.New != null && ALL_CheckRecursive.runCodeBlockOnce('User_AfterInsertUpdate'))
        {
            DS_AddPermissionSet_Handler.addPermissionSetsAndGroups(Trigger.New);
        }
        
    }   
}