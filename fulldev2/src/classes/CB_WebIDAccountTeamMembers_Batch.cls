//2016-02-22- anirudh.singh@cdk.com- Created this Batch Class as earlier class CB_WebIDAccountTeamMembersBatch was not following naming standards.
global class CB_WebIDAccountTeamMembers_Batch implements Database.Batchable<sObject>, Database.Stateful
{
    private List<Account> accountsList=new List<Account>();
    
    global String conditions;
    
    //2015-10-20- anirudh.singh@cdk.com- Added the below variable.
    // used in error logging and finish e-mail
    global static final String currentClassName='CB_WebIDAccountTeamMembers_Batch';
    
    //2015-11-02- anirudh.singh@cdk.com- Added the below parameter.
    public ALL_UtilitiesBatch.Logger log;
    
    // -- Constructors
    global CB_WebIDAccountTeamMembers_Batch()
    {
        initialize(Null);
    }
    
    global CB_WebIDAccountTeamMembers_Batch(List<Account> accts)
    {
        initialize(accts);
    }
    
    global void initialize(List<Account> accts) 
    {
        conditions='';
        if(accts == Null)
        {
            accountsList=new List<Account>();
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(processStart());
    }
    
    private String processStart() 
    {
        return 'Select Id From Account '+conditions; 
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accountsList)
    {
        processExecute(accountsList);
    }
    
    private void processExecute(List<Account> accountsList)
    {
        List<Id> accountIdsToProcessList=new List<Id>();
        
        for(Account acc: accountsList)
        {
            accountIdsToProcessList.add(acc.Id);
        }
        
        //2016-02-22- anirudh.singh@cdk.com- Commented the below line.
        //handler.SyncAccountTeamAndWebIdUsers(accountIdsToProcessList);
        //2016-02-22- anirudh.singh@cdk.com- Added the below lines as the method is now static.
        CB_WebID_Handler.initializeAndProcessRecords('WebID__c', Null, Null);
        CB_WebID_Handler.syncAccountTeamAndWebIdUsers(accountIdsToProcessList);
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //2015-10-23- anirudh.singh@cdk.com- Added the below code.
        if(BC!=Null)
        {
            log=new ALL_UtilitiesBatch.Logger();
            log.batchId=BC.getJobId();
            log.title='CB_WebIDAccountTeamMembers_Batch';
            log.description='Finished Syncing WebID Users, specified in WebID Settings (Custom Settings), to the (CDK) Account Team. ';
            log.message='Batch Complete';
            
            ALL_UtilitiesBatch.finish(currentClassName, log);
        }
    }
}