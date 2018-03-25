//Author: anirudh.singh@cdk.com
//Created Date: 2015-10-16
//Description: This class will contain generic methods to be used in Batch Classes.
//2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
//2016-01-14- anirudh.singh@cdk.com- Changed the reference CB_CreativeCaseTallyOnWebIdReset_Batch to CB_CreativeCaseTallyReset_Batch.
//2016-01-27- anirudh.singh@cdk.com- Changed the reference DSCB_AccountReLinkBatch to DSCB_AccountReLink_Batch.
//2016-02-19- anirudh.singh@cdk.com- Added a parameter in the Logger class and added an IF Block in finish method.
//2016-02-22- anirudh.singh@cdk.com- Changed the reference CB_WebIDAccountTeamMembersBatch to CB_WebIDAccountTeamMembers_Batch.
public class ALL_UtilitiesBatch
{
    public static ResultLogger finish(String className, Logger log)
    {
        system.debug('Start finish---->'); 
        
        Job_Settings__c jobSettingRef=Null;
        Map<String, Job_Settings__c> allJobSettingsMap=Job_Settings__c.getAll();
        
        if(allJobSettingsMap!=Null && !allJobSettingsMap.isEmpty()) 
        {
            for(Job_Settings__c jobSettings: allJobSettingsMap.values())
            { 
                if(jobSettings.Class_Name__c==className)
                {
                    jobSettingRef=jobSettings;
                } 
            }
        }
        
        String finalMessage=log.message;
        
        ResultLogger resultLog=new ResultLogger();
        if(jobSettingRef!=Null)
        {
            List<AsyncApexJob> jobs=new List<AsyncApexJob>();
            
            List<AsyncApexJob> batchJobs=[
                SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, CreatedDate,
                       ExtendedStatus
                FROM AsyncApexJob 
                WHERE Id=:log.batchId  
                LIMIT 1
            ];
            
            Job job=Null;
            
            if(!batchJobs.IsEmpty())
            {
                job=new Job(batchJobs[0]);
            }
            else
            {
                job=new Job();
            }
            
            //2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
            if(jobSettingRef.Finish_Emails__c!=Null && job!=Null) 
            {
                // Send an email to the Apex job's submitter notifying of job completion.  
                Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
                
                List<String> toAddresses=new List<String>();
                
                //2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
                for(String str: jobSettingRef.Finish_Emails__c.split(','))
                {
                    toAddresses.add(str.normalizeSpace());
                }
                resultLog.status=job.Status;
                resultLog.emailAddresses=toAddresses;
                
                mail.setToAddresses(toAddresses);
                
                List<Batch_Failure__c> batchFailuresList;
                
                if(job.Status!='Failed') 
                {
                    jobSettingRef.Last_Run__c=DateTime.now();
                    update jobSettingRef;
                }
                
                if(className=='DS_Account_LastActivity')
                {
                    batchFailuresList = [
                        Select Source__c, Error_Message__c, Line_Number__c, Error_Type__c 
                        From Batch_Failure__c 
                        Where Source__c = :className 
                        And CreatedDate > :job.CreatedDate.addHours(-6) 
                        order by CreatedDate DESC 
                        limit 10
                    ];
                    
                    for(Batch_Failure__c batchFailure : batchFailuresList)
                    {
                        finalMessage += 'Batch Failure: {'
                            + 'Line_Number__c:' + batchFailure.Line_Number__c + ', '
                            + 'Error_Type__c:' + batchFailure.Error_Type__c + ', ' 
                            + 'Error_Message__c:' + batchFailure.Error_Message__c + '' 
                            + '}<br/>';
                        system.debug(batchFailure);
                    }
                    
                    if(finalMessage=='')
                    {
                        finalMessage='Success!';
                    }
                    
                    mail.setSenderDisplayName('Salesforce Batch Apex');
                    mail.setUseSignature(false);
                }
                
                mail.setSubject(log.title+' executed on: '+job.CreatedDate.format('MM/dd/yyyy K:mm:ss:SS a, z')+' Status:'+job.Status);
                
                if(className=='DS_Account_LastActivity')
                {
                    String plainMailBody = '' 
                        + 'Job Start Date and Time: ' + job.CreatedDate.format('MM/dd/yyyy K:mm:ss:SS a, z') + ' \r\n'
                        + 'Job Status: ' + job.Status + ' at ' + system.now().format('MM/dd/yyyy K:mm:ss:SS a, z') + ' \r\n'
                        + 'Job Executed User: ' + Userinfo.getName() + ' (' + UserInfo.getUserName() + ') \r\n'
                        + 'Job Last Run Conditions: ' + 'Use Last Run Conditions? ' + ((log.useLastRunConditions)?'Yes':'No') 
                        + ((log.useLastRunConditions)?(((log.lastRunDateTime!=null)?('\r\nLast Run: '+log.lastRunDateTime.format('MM/dd/yyyy K:mm:ss:SS a, z')):'')):'') + '\r\n'
                        + 'Total Batch Failures: ' + (batchFailuresList!=null?String.valueOf(batchFailuresList.size()):'0') + ' \r\n'
                        + 'Job Failures: ' + String.valueOf(job.NumberOfErrors) + ' \r\n'
                        + 'Accounts Processed: ' + String.valueOf(log.recordsProcessed) + ' \r\n'
                        + 'Last Activities Updated / Inserted: ' + String.valueOf(log.lastActivitiesUpserted) + ' \r\n'
                        + 'Old Last Activities Deleted: ' + String.valueOf(log.oldLastActivitiesDeleted) + ' \r\n'
                        + 'Collected Existing Last Activities: ' + String.valueOf(log.collectedExistingLastActivities) + ' \r\n'
                        + 'Collected Existing Tasks: ' + String.valueOf(log.collectedExistingTasks) + ' \r\n'
                        + 'Collected Existing Events: ' + String.valueOf(log.collectedExistingEvents) + ' \r\n'
                        + 'Collected Existing Leads: ' + String.valueOf(log.collectedExistingLeads) + ' \r\n'
                        + 'Collected Existing Activity Histories: ' + String.valueOf(log.collectedExistingActivityHistories) + ' \r\n'
                        + 'Detail: ' + finalMessage + '\r\n'
                        + '';
                    plainMailBody += finalMessage.replaceAll('\\<br/\\>','\\\r\\\n');
                    mail.setPlainTextBody(plainMailBody);
                }
                
                string summary=''
                    + '<style media="all" type="text/css">'
                    + 'body, h1, h2, h3, h4 { font-family: \'Lucida Console\', Monaco, monospace; }'
                    + 'td { font-size: 10pt; }'
                    + '</style>'
                    + '<p>' 
                    + '<h3>' + log.title + ' Batch Job Summary</h3>'
                    + '<h4>' + log.description + '</h4>' 
                    + '<p>'
                    + '<table>'
                    + '<tr><td>Job Start Date and Time:</td><td> '+job.CreatedDate.format('MM/dd/yyyy K:mm:ss:SS a, z')+'</td></tr>'
                    + '<tr><td>Job End Date and Time:</td><td> '+system.now().format('MM/dd/yyyy K:mm:ss:SS a, z')+'</td></tr>'
                    + '<tr><td>Job Status:</td><td> '+job.Status+'</td></tr>'
                    + '<tr><td>Job Executed User:</td><td> '+Userinfo.getName()+' ( '+UserInfo.getUserName()+' )</td></tr>'
                    + '<tr><td>Additional Information:</td><td> ' + finalMessage + '</td></tr>';
                
                //2016-01-27- anirudh.singh@cdk.com- Changed the reference DSCB_AccountReLinkBatch to DSCB_AccountReLink_Batch.
                //2016-02-22- anirudh.singh@cdk.com- Changed the reference CB_WebIDAccountTeamMembersBatch to CB_WebIDAccountTeamMembers_Batch.
                if(className=='CB_UpdateExistingWebIdsToEntilmnts_Batch' || className=='CB_WebIDAccountTeamMembers_Batch'
                   || className=='DSCB_AccountReLink_Batch')
                {
                    summary+='<tr><td>Total Number of Accounts Processed:</td><td> ' + job.JobItemsProcessed + '</td></tr>'
                        + '<tr><td>Total Number of Failure Records:</td><td> ' + job.NumberOfErrors + '</td></tr>';
                    
                    //2016-02-19- anirudh.singh@cdk.com- Added the below If Block.
                    if(className=='DSCB_AccountReLink_Batch')
                    {
                        summary+='<tr><td>Processing Log:</td><td> ' + log.processingLog + '</td></tr>';
                    }
                }
                else if(className=='DS_Account_LastActivity')
                {
                    summary+='<tr><td>Job Last Run Conditions:</td><td> ' + 'Use Last Run Conditions? ' + ((log.useLastRunConditions)?'Yes':'No') 
                        + ((log.useLastRunConditions)?(((log.lastRunDateTime!=null)?('<br/>Last Run: '+log.lastRunDateTime.format('MM/dd/yyyy K:mm:ss:SS a, z')):'')):'') + '</td></tr>'
                        + '<tr><td>Total Batch Failures:</td><td> ' + batchFailuresList.size() + '</td></tr>'
                        + '<tr><td>Job Failures:</td><td> ' + job.NumberOfErrors + '</td></tr>'
                        + '<tr><td>Accounts Processed:</td><td> ' + String.valueOf(log.recordsProcessed) + '</td></tr>'
                        + '<tr><td>Last Activities Updated / Inserted:</td><td> ' + String.valueOf(log.lastActivitiesUpserted) + '</td></tr>'
                        + '<tr><td>Old Last Activities Deleted:</td><td> ' + String.valueOf(log.oldLastActivitiesDeleted) + '</td></tr>'
                        + '<tr><td>Collected Existing Last Activities:</td><td> ' + String.valueOf(log.collectedExistingLastActivities) + '</td></tr>'
                        + '<tr><td>Collected Existing Tasks:</td><td> ' + String.valueOf(log.collectedExistingTasks) + '</td></tr>'
                        + '<tr><td>Collected Existing Events:</td><td> ' + String.valueOf(log.collectedExistingEvents) + '</td></tr>'
                        + '<tr><td>Collected Existing Leads:</td><td> ' + String.valueOf(log.collectedExistingLeads) + '</td></tr>'
                        + '<tr><td>Collected Existing Activity Histories:</td><td> ' + String.valueOf(log.collectedExistingActivityHistories) + '</td></tr>';
                }
                else if(className=='SyncAccountNWebIDJob')
                {
                    summary+= '<tr><td>Total Number of Accounts Processed:</td><td> ' + log.recordsProcessed + '</td></tr>'
                        + '<tr><td>Total Number of WebIDs updated:</td><td> ' + log.numberOfSuccessRecords + '</td></tr>'
                        + '<tr><td>Total Number of Failure Records:</td><td> ' + log.numberOfFailureRecords + '</td></tr>'
                        + '<tr><td>No of Job Failures:</td><td> ' + job.NumberOfErrors + '</td></tr>'
                        + '<tr><td>Job Input Parameters:</td><td> ' + log.inputParameters + '</td></tr>';
                }
                else if(className=='CB_CreativeCaseTallyReset_Batch')
                {
                    summary+='<tr><td>The batch process is: </td><td> ' + job.Status + '</td></tr>'
                        + '<tr><td>Total Number of jobs Processed: </td><td> ' + job.JobItemsProcessed + '</td></tr>'
                        + '<tr><td>Total Number of Failure Records: </td><td> ' + job.NumberOfErrors + '</td></tr>';
                       
                }
                summary+= '</table>'
                    + '</p>'
                    + '</p>'
                    ; 
                resultLog.emailSummary=summary;
                
                mail.setHtmlBody(summary);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        }
        
        system.debug('End finish---->');
        return resultLog;
    }
    
    //createdby Matt.Keefe@cdk.com
    public class Job
    {
        public string Status;
        public Integer NumberOfErrors;
        public Integer JobItemsProcessed;
        public Integer TotalJobItems;
        public string CreatedByEmail;
        public DateTime CreatedDate;
        
        public Job(AsyncApexJob apexJob)
        {
            if(apexJob!=Null)
            {
                Status=apexJob.Status;
                NumberOfErrors=apexJob.NumberOfErrors;
                JobItemsProcessed=apexJob.JobItemsProcessed;
                TotalJobItems=apexJob.TotalJobItems;
                if(apexJob.CreatedBy!=Null)
                {
                    CreatedByEmail=apexJob.CreatedBy.Email;
                }
                else
                {
                    CreatedByEmail=Null;
                }
                CreatedDate=apexJob.CreatedDate;
            }
        }
        
        public Job() 
        {
            Status='Job ID not found';
            NumberOfErrors=0;
            JobItemsProcessed=0;
            TotalJobItems=0;
            CreatedByEmail='';
            CreatedDate=DateTime.Now();
        }
    }
    
    //2015-11-04- anirudh.singh@cdk.com- Created the below sub-class.
    public class ResultLogger
    {
        public String status;
        public List<String> emailAddresses;
        public String emailSummary;
    }
    
    //2015-11-10- anirudh.singh@cdk.com- This class was earlier present as a child class of DS_Account_LastActivity. Now, it is being used by the other batch classes too.
    public class Logger
    {
        public Id batchId;
        //2015-11-02- anirudh.singh@cdk.com- Commented the below parameter.
        //public Integer accountsProcessed;
        
        //2015-11-04- anirudh.singh@cdk.com- Added the below parameter in place of accountsProcessed.
        public Decimal recordsProcessed;
        public DateTime lastRunDateTime;
        public Integer lastActivitiesUpserted;
        public Integer oldLastActivitiesDeleted;
        public Integer collectedExistingLastActivities;
        public Integer collectedExistingTasks;
        public Integer collectedExistingEvents;
        public Integer collectedExistingLeads;
        public Integer collectedExistingActivityHistories;
        
        //2015-11-02- anirudh.singh@cdk.com- Added the below parameter.
        public String inputParameters;
        public Decimal numberOfSuccessRecords;
        public Decimal numberOfFailureRecords;
        public Boolean useLastRunConditions;
        public String title;
        public String description;
        public String message;
        
        //2016-02-19- anirudh.singh@cdk.com- Added the below parameter.
        public String processingLog;
        
        public Logger()
        {
            batchId=Null;
            recordsProcessed=0;
            lastRunDateTime=Null;
            collectedExistingLastActivities=0;
            collectedExistingTasks=0;
            collectedExistingEvents=0;
            collectedExistingLeads=0;
            collectedExistingActivityHistories=0;
            oldLastActivitiesDeleted=0;
            lastActivitiesUpserted=0;
            
            //2015-11-02- anirudh.singh@cdk.com- Added the below parameter.
            inputParameters=Null;
            numberOfSuccessRecords=0;
            numberOfFailureRecords=0;
            useLastRunConditions=false;
            title= Null;
            description=Null;
            message=Null;
            
            //2016-02-19- anirudh.singh@cdk.com- Added the below parameter.
            processingLog='';
        }
    }
}