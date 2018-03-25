//2015-09-22- anirudh.singh@cdk.com- To upgrade the API Version FROM 28.0 to 34.0.
//2015-10-20- anirudh.singh@cdk.com- Modified the finish method to use the generic Finish method on ALL_UtilitiesBatch.
//2016-02-22- anirudh.singh@cdk.com- Commented this class as it was not following naming standards.
/*
CB_WebIDAccountTeamMembersBatch b=new CB_WebIDAccountTeamMembersBatch();
b.Conditions=' Limit 100 '; // optional
ID BatchId=Database.executeBatch(b, 1);
*/
global class CB_WebIDAccountTeamMembersBatch
//global class CB_WebIDAccountTeamMembersBatch implements Database.Batchable<sObject>, Database.Stateful
{
    /*
    // -- Variables
    List<Account> Accounts;
    CB_WebIDAccountTeamMembers Sync;
    
    global String Conditions;
    
    //2015-10-20- anirudh.singh@cdk.com- Added the below variable.
    // used in error logging and finish e-mail
    global static final String currentClassName='CB_WebIDAccountTeamMembersBatch';
    
    //2015-11-02- anirudh.singh@cdk.com- Added the below parameter.
    public ALL_UtilitiesBatch.Logger log;
    
    // -- Constructors
    
    global CB_WebIDAccountTeamMembersBatch()
    {
        Initialize(null);
    }
    global CB_WebIDAccountTeamMembersBatch(List<Account> accts)
    {
        Initialize(accts);
    }
    
    global void Initialize(List<Account> accts) 
    {
        Conditions='';
        if(accts == null)
        {
            Accounts=new List<Account>();
        }
        if(Sync == null)
        {
            Sync=new CB_WebIDAccountTeamMembers();
        }
    }
    
    // -- Batch Methods
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(st());
    }
    
    global void execute(Database.BatchableContext BC, List<Account> Accounts)
    {
        ex(Accounts);
    }
    
    // -- Methods
    
    global String st() 
    {
        return 'Select Id From Account ' + Conditions; 
    }
    
    global void ex(List<Account> Accounts)
    {
        List<Id> AccountIdsToProcess=new List<Id>();
        for(Account a : Accounts)
        {
            AccountIdsToProcess.add(a.Id);
        }
        
        Sync.SyncAccountTeamAndWebIdUsers(AccountIdsToProcess); 
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //2015-10-23- anirudh.singh@cdk.com- Added the below code.
        if(BC!=Null)
        {
            log=new ALL_UtilitiesBatch.Logger();
            log.batchId=BC.getJobId();
            log.title='CB_WebIDAccountTeamMembersBatch';
            log.description='Finished Syncing WebID Users, specified in WebID Settings (Custom Settings), to the (CDK) Account Team. ';
            log.message='Batch Complete';
            
            ALL_UtilitiesBatch.finish(currentClassName, log);
        }
    }*/
}