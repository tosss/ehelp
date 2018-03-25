global with sharing class CB_CreativeCaseTallyOnWebIdReset_Batch implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string query = 'SELECT Id from WebID__c where Creative_Case_Tally__c > 0';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<WebID__c> scope){
        list<sObject> webIdCasesAccountPlanList = new list<sObject>();
        set<Id> webIdsToQuery = new set<Id>();
        for(WebID__c webId: scope)
        {
            webIdsToQuery.add(webId.Id);
        }
        list<WebID__c> webIdList = [
            SELECT ID, Creative_Case_Tally__c, 
            (Select Id, Creative_Case_Tally__c, Status from Cases__r 
             	where RecordType.Name='Inquiry - Creative' 
             	and Creative_Case_Tally__c > 0 
             	limit 50000
            ), 
            (Select Id, Creative_Case_Tally__c from Account_Plans__r 
             	where RecordType.Name='DAA Account Plan' 
             	and Creative_Case_Tally__c > 0 
            )  
            from WebID__c
        	where Id IN:webIdsToQuery];
        if(!webIdList.isEmpty())
        {
            for(WebID__c webId: webIdList)
            {
                webId.Creative_Case_Tally__c =0;
                webIdCasesAccountPlanList.add(webId);
                for(Case cs:webId.Cases__r)
                {
                    if(!cs.Status.containsIgnoreCase('Closed'))
                    {
                        cs.Creative_Case_Tally__c = 0;
                        webIdCasesAccountPlanList.add(cs); 
                    }
                }
                for(Account_Plan__c acPlan:webId.Account_Plans__r)
                {
                   acPlan.Creative_Case_Tally__c = 0;
                   webIdCasesAccountPlanList.add(acPlan);
                }  
          }
            webIdCasesAccountPlanList.sort(); 
            Database.update(webIdCasesAccountPlanList, false);
            
          //update webIdCasesAccountPlanList;  
        }
    }
    global void finish(Database.BatchableContext BC){
    	
    	Id JobId = null;
    	if(BC != null) { JobId = BC.getJobId(); }
    	
    	AsyncApexJob BatchJob = null;
    	List<AsyncApexJob> BatchJobs = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedDate 
            FROM AsyncApexJob WHERE Id = :JobId LIMIT 1];
    	
    	ALL_UtilitiesMiscellaneous.Job j = null;
    	if(!BatchJobs.IsEmpty()) { j = new ALL_UtilitiesMiscellaneous.Job(BatchJobs[0]); } 
		else { j = new ALL_UtilitiesMiscellaneous.Job(); }
    	
        ALL_UtilitiesMiscellaneous.SendBatchCompleteMessage(j,
        	'CB_CreativeCaseTallyOnWebIdReset_Batch', 
        	'Finished Resetting the Creative limit to 0 on AccountPlan<-WebID->Cases ', 
        	'Batch Complete');
    }
    
    

}