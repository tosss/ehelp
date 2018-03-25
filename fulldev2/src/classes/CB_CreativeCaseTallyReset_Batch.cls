//2015-11-03- anirudh.singh@cdk.com   - Modified the finish method to use the generic Finish method on ALL_UtilitiesBatch.
//2016-01-14- anirudh.singh@cdk.com   - Created this class to replace CB_CreativeCaseTallyOnWebIdReset_Batch class due to naming standards issue.
//2016-02-01- venkata.shrivol@cdk.com - added sort function for the sObject list and changed the dml updatet to Database method update.  
global with sharing class CB_CreativeCaseTallyReset_Batch implements Database.Batchable<sObject>
{
    //2015-10-20- anirudh.singh@cdk.com- Added the below variable.
    // used in error logging and finish e-mail
    global static final String currentClassName='CB_CreativeCaseTallyReset_Batch';
    
    //2015-11-02- anirudh.singh@cdk.com- Added the below parameter.
    public ALL_UtilitiesBatch.Logger log;
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string query='SELECT ID, Creative_Case_Tally__c from WebID__c';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<WebID__c> scope)
    {
        set<ID> webIDset = new set<ID>();
        
        if(!scope.isEmpty())
        {
            for(webID__c webID: scope)
            {
                webIDset.add(webID.ID);
            }
        }
        
        list<sObject> CasesAccountPlanList=new list<sObject>();
        list<WebID__c> webIDList = new list<WebID__c>();
        map<ID, list<Case>> casesMap = new map<ID, list<Case>>();
        map<ID, list<Account_Plan__c>> accountPlansMap = new map<ID, list<Account_Plan__c>>();
        
        if(!webIDset.isEmpty())
        {
            list<Case> CasesList = [
                Select Id, Creative_Case_Tally__c, RecordType.Name, WebId__c, Status 
                from Case
                Where WebID__c IN :webIDset
            ];
            
            if(!CasesList.isEmpty())
            {
                for(Case cs: CasesList)
                {
                    list<Case> tempCaseList = casesMap.get(cs.WebID__c);
                    if(tempCaseList == null){ tempCaseList = new list<Case>();}
                    tempCaseList.add(cs);
                    casesMap.put(cs.WebID__c, tempCaseList);
                }
            }
            
            list<Account_Plan__c> accountPlansList = [
                Select Id,Creative_Case_Tally__c, RecordType.Name, WebId__c 
                from Account_Plan__c
                Where WebID__c IN :webIDset
            ];
            
            if(!accountPlansList.isEmpty())
            {
                for(Account_Plan__c ap: accountPlansList)
                {
                    list<Account_Plan__c> tempAPsList = accountPlansMap.get(ap.WebID__c);
                    if(tempAPsList == null){ tempAPsList = new list<Account_Plan__c>();}
                    tempAPsList.add(ap);
                    accountPlansMap.put(ap.WebId__c, tempAPsList);
                }
            }
        }
        
        for(WebID__c webId: scope)
        {
            ID web18ID = webId.ID;
            if(webId.Creative_Case_Tally__c!=null)
            {
                webId.Creative_Case_Tally__c =0;
                webIDList.add(webId);
            }
            
            list<Case> tempcases = CasesMap.get(web18ID);
            if(tempcases != null && !tempcases.isEmpty())
            { 
                for(Case cs: tempcases)
                {
                    if(cs != null && cs.RecordType.Name=='Inquiry - Creative' && cs.Creative_Case_Tally__c!=null)
                    {
                        cs.Creative_Case_Tally__c=0;
                        CasesAccountPlanList.add(cs);
                    }
                }
            }
            
            list<Account_Plan__c> tempAPsList = accountPlansMap.get(web18ID);
            if(tempAPsList != null && !tempAPsList.isEmpty())
            {
                for(Account_Plan__c acPlan: tempAPsList)
                {
                    if(acPlan != null && acPlan.RecordType.Name == 'DAA Account Plan' && acPlan.Creative_Case_Tally__c!=null)
                    {
                        acPlan.Creative_Case_Tally__c=0;
                        CasesAccountPlanList.add(acPlan);
                    }
                }
            }            
            
        }
        
        //2016-02-01- venkata.shrivol@cdk.com -added the below sort and changed the dml call to database method 
        CasesAccountPlanList.sort();
        Database.update(webIDList, false);
        Database.update(CasesAccountPlanList, false);
        //update webIdCasesAccountPlanList;
    }
    
    global void finish(Database.BatchableContext BC)
    {
        //2015-10-23- anirudh.singh@cdk.com- Added the below code.
        if(BC!=Null)
        {
            log=new ALL_UtilitiesBatch.Logger();
            log.batchId=BC.getJobId();
            log.title='CB_CreativeCaseTallyReset_Batch';
            log.description='Finished Resetting the Creative limit to 0 on AccountPlan<-WebID->Cases ';
            log.message='Batch Complete';
            
            ALL_UtilitiesBatch.finish(currentClassName, log);
        }
    }
}