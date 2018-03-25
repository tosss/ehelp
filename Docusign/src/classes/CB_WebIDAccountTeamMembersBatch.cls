/*
    CB_WebIDAccountTeamMembersBatch b = new CB_WebIDAccountTeamMembersBatch();
    b.Conditions = ' Limit 100 '; // optional
    ID BatchId = Database.executeBatch(b, 1);
*/
global class CB_WebIDAccountTeamMembersBatch implements Database.Batchable<sObject>, Database.Stateful
{
	// -- Variables
	
    List<Account> Accounts;
    CB_WebIDAccountTeamMembers Sync;
    
    global String Conditions;
    
    // -- Constructors
    
    global CB_WebIDAccountTeamMembersBatch() { Initialize(null); }
    global CB_WebIDAccountTeamMembersBatch(List<Account> accts) { Initialize(accts); }
    
    global void Initialize(List<Account> accts) 
    {
        Conditions = '';
        if(accts == null) { Accounts = new List<Account>(); }
        if(Sync == null) { Sync = new CB_WebIDAccountTeamMembers(); }
    }
    
    // -- Batch Methods
    
    global Database.QueryLocator start(Database.BatchableContext BC) { return Database.getQueryLocator(st()); }
    global void execute(Database.BatchableContext BC, List<Account> Accounts) { ex(Accounts); }
    global void finish(Database.BatchableContext BC) { fn(BC); }
    
    // -- Methods
    
    global String st() 
    {
        return 'Select Id From Account ' + Conditions; 
    }
    
    global void ex(List<Account> Accounts)
    {
        List<Id> AccountIdsToProcess = new List<Id>();
        for(Account a : Accounts) { AccountIdsToProcess.add(a.Id); }
        
        Sync.SyncAccountTeamAndWebIdUsers(AccountIdsToProcess); 
    }
    
    global void fn(Database.BatchableContext BC)
    {
    	Id JobId = null;
    	if(BC != null) { JobId = BC.getJobId(); }
    	
    	AsyncApexJob BatchJob = null;
    	List<AsyncApexJob> BatchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedDate 
            FROM AsyncApexJob WHERE Id = :JobId LIMIT 1];
    	
    	ALL_UtilitiesMiscellaneous.Job j = null;
    	if(!BatchJobs.IsEmpty()) { j = new ALL_UtilitiesMiscellaneous.Job(BatchJobs[0]); } 
		else { j = new ALL_UtilitiesMiscellaneous.Job(); }
    	
        ALL_UtilitiesMiscellaneous.SendBatchCompleteMessage(j,
        	'CB_WebIDAccountTeamMembersBatch', 
        	'Finished Syncing WebID Users, specified in WebID Settings (Custom Settings), to the (ADP) Account Team. ', 
        	'Batch Complete');
    }
}