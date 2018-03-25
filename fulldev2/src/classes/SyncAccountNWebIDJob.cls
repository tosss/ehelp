/* 
*  This is called in SyncAccountNWebIDScheduler to sync Account & WebID
*   - To copy Account Executive (Account Owner) name from Account Object into WebID Object.
*   - Concatenate all WebID Object Account Advocates into Account Object Account Advocate.
*   - Concatenate all WebID Object SEO Specialist into Account Object SEO Specialist.
*   - A batch process to run once in a day to synchronize Account & WebID Objects such as map 
*  Account.Account Execute into WebID.Account Execute, update & concatenate WebID Account Advocate, 
*  SEO Specialist into Account WebID Account Advocate, WebID SEO specialist.
*/
//2015-09-22- anirudh.singh@cdk.com- To upgrade the API Version FROM 24.0 to 34.0.
//2015-10-20- anirudh.singh@cdk.com- Modified the finish method to use the generic Finish method on ALL_UtilitiesBatch.
global class SyncAccountNWebIDJob implements Database.Batchable<Sobject>, Database.Stateful
{
    private static final GlobalSettings gs=GlobalSettings.getInstance(Null);
    public Batch_Jobs_Audit_Log__c jobLog;
    private String query;
    private String errorString;
    private List<String> accountList;
    
    //2015=11-02- anirudh.singh@cdk.com- Added the below parameter.
    public ALL_UtilitiesBatch.Logger log;
    
    //2015-10-20- anirudh.singh@cdk.com- Added the below variable.
    // used in error logging and finish e-mail
    global static final String currentClassName='SyncAccountNWebIDJob';
    
    private static final String QUERY_STRING=
        'Select Id, OwnerId, Designated_DSM__c ' +
        //', (select Id, Account_Executive__c FROM Sites__r) ' + // removed 2012-03-02 MK - this subquery was causing an error in the batch process
        'FROM Account ';
    
    public static Integer LIMITCOUNT=0;
    
    global SyncAccountNWebIDJob()
    {
        this.accountList=Null;
        this.query=Null;
        setjob();
    }
    
    global SyncAccountNWebIDJob(String q, List<String> aList)
    {
        this.query=q;
        this.accountList=aList;
        setjob();
    }
    
    private void setjob()
    {
        this.query=(this.query==Null) ? QUERY_STRING : this.query;
        
        if(this.accountList!=Null)
        {
            String aSet=GlobalSettings.convertListToString(accountList);
            String whereString=' WHERE Account_Number__c IN ' + aSet ;
            this.query=(this.accountList==Null) ? this.query : (this.query + whereString);
        }
        
        this.query=(LIMITCOUNT > 0 && this.accountList == Null) ? (this.query + ' LIMIT ' + LIMITCOUNT) : this.query;
        
        system.debug('setJob Query........++++++++++++++++++'+this.query);
        
        //set the Audit log data
        jobLog=new Batch_Jobs_Audit_Log__c();
        jobLog.Name='SyncAccountNWebIDJob';
        jobLog.Job_Start_Date__c=system.now();
        jobLog.Job_Executed_User__c=Userinfo.getName();
        jobLog.Job_Status__c='Started';
        jobLog.Total_Number_of_Failure_Records__c=0;
        jobLog.Total_Number_of_Success_Records__c=0;
        jobLog.Total_Number_Of_Records_processed__c=0;
        errorString='';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        try
        {
            jobLog.Job_ID__c=BC.getJobId();
            insert jobLog;
            return Database.getQueryLocator(this.query);
        }
        catch (Exception e)
        {
            //2015-10-23- anirudh.singh@cdk.com- Added the below code.
            invokeFinish(BC, 'Success');
            return Null;
        }
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> mms)
    {
        System.debug('SyncAccountNWebID -execute-start');
        
        try
        {
            if(mms!=Null)
            {
                jobLog.Total_Number_Of_Records_processed__c += mms.size();
            }
            
            List<WebID__c> updateList=new List<WebID__c>();
            // List<Account> updateAccList=new List<Account>();
            
            // 2012-03-02 MK - Added to compensate for the removal of subquery
            List<WebID__c> AllWebIds=[Select Id, Account_Executive__c, Account__c From WebId__c Where Account__c IN :mms];
            Map<Id, List<WebID__c>> WebIdsByAccount=new Map<Id, List<WebID__c>>(); 
            
            for(WebID__c w : AllWebIds)
            {
                if(WebIdsByAccount.get(w.Account__c)==Null) 
                {
                    List<WebID__c> NewWebIdList=new List<WebID__c>();
                    NewWebIdList.add(w);
                    WebIdsByAccount.put(w.Account__c, NewWebIdList); 
                }
                else
                {
                    WebIdsByAccount.get(w.Account__c).add(w);
                }
            }
            // end of added code
            
            for(Account acc: (List<Account>)mms)
            {
                // String accountAdvocate='  ';
                // String SEOSpecialist='  ';
                
                //Get all related WebIds and update Account Executive
                List<WebID__c> webList=WebIdsByAccount.get(acc.Id); // acc.Sites__r; // 2012-03-02 MK - changed
                
                if(webList!=Null)
                {
                    for(WebID__c c: webList)
                    {
                        if(c.Account_Executive__c!=acc.Designated_DSM__c)
                        {
                            c.Account_Executive__c=acc.Designated_DSM__c;
                            updateList.add(c);
                        }
                    } // end of internal for
                }
            } // end of extrenal for
            
            if(!(updateList.isEmpty()))
            {
                Database.SaveResult[] lsr=Database.update(updateList,false);
                Integer counter=0;
                
                for(Database.SaveResult sr: lsr)
                {
                    if(!sr.isSuccess())
                    {
                        jobLog.Total_Number_of_Failure_Records__c += 1;
                        Database.Error err=sr.getErrors()[0];
                        errorString += updateList.get(counter) + ': ' + 'Error ' + err + '\n;';
                    }
                    else
                    {
                        jobLog.Total_Number_of_Success_Records__c += 1;
                    }
                    
                    counter++;
                }
            }
            
            System.debug('SyncAccountNWebID -execute-stop');
        }
        catch (Exception e)
        {
            System.debug(logginglevel.ERROR,'SyncAccountNWebIDJob -execute-exception++++++++++++++++++++++');
            //2015-10-23- anirudh.singh@cdk.com- Added the below code.
            invokeFinish(BC, 'Success');
        }
    } // end of execute method
    
    global void finish(Database.BatchableContext BC)
    {
        //2015-10-23- anirudh.singh@cdk.com- Added the below code.
        invokeFinish(BC, 'Success');
    }
    
    //2015-11-10- anirudh.singh@cdk.com- Created the below method to invoke the finish method of ALL_UtilitiesBatch class.
    //This method is invoked from start, execute and finish methods of this batch class.
    private void invokeFinish(Database.BatchableContext BC, String msg)
    {
        if(BC!=Null)
        {
            log=new ALL_UtilitiesBatch.Logger();
            log.batchId=BC.getJobId();
            log.recordsProcessed=jobLog.Total_Number_Of_Records_processed__c;
            log.numberOfSuccessRecords=jobLog.Total_Number_of_Success_Records__c;
            log.numberOfFailureRecords=jobLog.Total_Number_of_Failure_Records__c;
            log.inputParameters=jobLog.Job_Input_Parameters__c;
            log.title='Account to WebID Synchronization Batch Job Summary';
            log.description='Replacing WebID Account Executive with Account Designated DSM (Account Executive)';
            log.message=msg;
            
            if(errorString.length()>1)
            {
                log.message=errorString;
                jobLog.Job_Failure_Reason__c=errorString;
            }
            
            ALL_UtilitiesBatch.ResultLogger resultLog=new ALL_UtilitiesBatch.ResultLogger();
            resultLog=ALL_UtilitiesBatch.finish(currentClassName, log);
            
            if(resultLog.emailAddresses!=Null)
            {
                //Audit Log
                jobLog.Job_Status__c=resultLog.Status;
                jobLog.Job_ID__c=BC.getJobId();
                jobLog.Job_End_Date__c=System.now();
                jobLog.Job_Summary__c=resultLog.emailSummary;
                String mailList='';
                
                for(Integer i=0; i<resultLog.emailAddresses.size(); i++)
                {
                    mailList=mailList + ';' + resultLog.emailAddresses[i];
                }
                
                jobLog.Job_Status_Email_Send_To__c=mailList;
                
                upsert jobLog Job_ID__c;
            }
        }
    }
} // end of class