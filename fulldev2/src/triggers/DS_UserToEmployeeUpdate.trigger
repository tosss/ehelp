trigger DS_UserToEmployeeUpdate on User(after insert, after update, before insert, before update) 
{
    /* moved to ALL_User
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        DS_UserToEmployeeUpdateTriggerHandler.UserToEmployee(Trigger.new, Trigger.NewMap, Trigger.OldMap);
    }
    
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            DS_UserToEmployeeUpdateTriggerHandler.MakeFederationIDRequired(Trigger.New, Trigger.NewMap);  
        }
    }
    
    // 2015-01-13 matt.keefe@cdk.com - deprecated code
    //if(Trigger.isAfter   && ALL_CheckRecursive.runCodeBlockOnce('UserPermissionSetAndGroupTrigger6252015') )
    //{
    //    ALL_UserPermissionSetAndGroup_Handler.setPermissionSetAndGroup(Trigger.NewMap); 
    //}
    */
}