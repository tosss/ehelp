trigger ALL_User on User (after insert, after update, before insert, before update) 
{
    if (Trigger.isAfter && Trigger.isUpdate)
    {
        DS_UserToEmployeeUpdateTriggerHandler.UserToEmployee(Trigger.new, Trigger.NewMap, Trigger.OldMap);
    }
    
    if (Trigger.isBefore)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            DS_UserToEmployeeUpdateTriggerHandler.MakeFederationIDRequired(Trigger.New, Trigger.NewMap);  
        }
    }
    
    if (Trigger.New != null && Trigger.isAfter)
    {
        DS_AddPermissionSet_Handler.addPermissionSetsAndGroups(Trigger.New);
    }
}