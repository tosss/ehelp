// rq-05034 combine contact triggers into one (this is old trigger commenting out)
// 2015-08-27 - brian.cook@cdk.com, bill.thurow@cdk.com
//2016-02-19- anirudh.singh@cdk.com- Changed the reference from CB_WebIDAccountTeamMembers to CB_WebID_Handler.
//2016-02-22- anirudh.singh@cdk.com- Changed the version from 28.0 to 35.0.
trigger CB_SyncAccountFieldsToAccountTeam on Account (after insert, after update, after delete, after undelete) 
{
    //2016-02-19- anirudh.singh@cdk.com- Commented the below code.
    //CB_WebIDAccountTeamMembers sync = new CB_WebIDAccountTeamMembers('Account');
    //Map<Id, Account> newMap = Trigger.newMap;
    //Map<Id, Account> oldMap = Trigger.oldMap;
    //if(Trigger.isAfter)
    //{
    // filter WebIDs based on whether or not any of the fields have (or the Account has) changed
    //Set<Id> AccountIds = sync.FilterWebIDsToProcessFromAccountTrigger(oldMap, newMap);
    //List<Id> AccountIdsToProcess = new List<Id>(); AccountIdsToProcess.addAll(AccountIds);
    // sync the WebID fields and the Account Team Members
    //if(!AccountIdsToProcess.IsEmpty()) {
    //sync.SyncAccountTeamAndWebIdUsers(AccountIdsToProcess); }
    //}*/
    
    //2016-02-19- anirudh.singh@cdk.com- Added the below code for invoking the method processWebIdsAndSyncAccountTeam from CB_WebID_Handler.
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete || Trigger.isUndelete)
        {
            CB_WebID_Handler.initializeAndProcessRecords('Account', Trigger.oldMap, Trigger.newMap);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        DSCB_SetDoNotFields.AfterUpdateContactFromAccount(Trigger.newMap, Trigger.oldMap);
    }
}