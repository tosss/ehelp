trigger CB_SyncAccountFieldsToAccountTeam on Account (after insert, after update, after delete, after undelete) 
{
    CB_WebIDAccountTeamMembers sync = new CB_WebIDAccountTeamMembers('Account');
    Map<Id, Account> newMap = Trigger.newMap;
    Map<Id, Account> oldMap = Trigger.oldMap;
    
    if(Trigger.isAfter)
    {
        // filter WebIDs based on whether or not any of the fields have (or the Account has) changed
        Set<Id> AccountIds = sync.FilterWebIDsToProcessFromAccountTrigger(oldMap, newMap);
        List<Id> AccountIdsToProcess = new List<Id>(); AccountIdsToProcess.addAll(AccountIds);
        
        // sync the WebID fields and the Account Team Members
        if(!AccountIdsToProcess.IsEmpty()) {
            sync.SyncAccountTeamAndWebIdUsers(AccountIdsToProcess); }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        DSCB_SetDoNotFields.AfterUpdateContactFromAccount(newMap, oldMap);
    }
}