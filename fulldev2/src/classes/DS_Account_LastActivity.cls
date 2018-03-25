/* ADP Dealer Services - Sales Automation
* Programmer: Matt Keefe (matt_keefe@adp.com, 847.485.4849)
*
* Description:  To list the Last Activity by channel (User Title) for Accounts, Opportunities, Campaigns and Leads.
*               Updates (user and date) fields on a Last Activity record (inserting new records where appropriate)
*               designated by the ActivityHistorySettings__c custom settings to provide a list of Last Activities per object.
* 
* Requirements: Last_Activity__c object - records the Last Activities
*               Batch_Failure__c object - records any failures that may occur while running this batch
*               ActivityHistorySettings__c custom setting - holds all of the Owner titles to match and the fields to record them to
*               Job_Settings__c custom setting - holds general settings for this batch
*               DS_Account_LastActivity.cls class - batch logic
* 
* Testing Code Below
* ------------------
// Delete all Last Activity History and Batch Failures (only 10,000 DML records are allowed at a time):
delete [Select Id From Batch_Failure__c Limit 10000];
delete [Select Id From Last_Activity__c Limit 10000]; 

// Execute Batch Code (limited to a batch of 100 Accounts at a time, because there are two SOQL statements; one would limit to 200, two limits to 100):
DS_Account_LastActivity BatchClass=new DS_Account_LastActivity(); 
BatchClass.useLastRunConditions=false;
BatchClass.queryWhere=' And Id=\'0014000000JvtV5AAJ\''; // optional
ID BatchId=Database.executeBatch(BatchClass,20);

// Run outside of batch:
DS_Account_LastActivity LastActivityProcess=new DS_Account_LastActivity();
LastActivityProcess.useLastRunConditions=false; // optional
//LastActivityProcess.queryWhere=' And Id=\'0014000000Jvwk6\''; // optional
List<sObject> scope=Database.query(LastActivityProcess.b_start());
LastActivityProcess.b_execute(scope);
LastActivityProcess.b_finish();

// Batch status check:
AsyncApexJob job=[SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: BatchId]; system.debug(job);
*/

//2015-09-22- anirudh.singh@cdk.com- To upgrade the API Version FROM 21.0 to 34.0.
//2015-10-20- anirudh.singh@cdk.com- Modified the finish method to use the generic Finish method on ALL_UtilitiesBatch.
global class DS_Account_LastActivity implements Database.Batchable<sObject>, Database.Stateful
{
    // variables
    global string query;
    global string queryWhere;
    global string queryLimit;
    global boolean useLastRunConditions;
    
    global static final List<ActivityHistorySettings__c> settings=ActivityHistorySettings__c.getall().values();
    global static final String currentClassName='DS_Account_LastActivity'; // used in error logging and finish e-mail
    
    // a class structure for all ActivityHistories
    global class MasterActivityHistory
    {
        global string ah_Id;               // The ID of the Task or Event 
        global string ah_Name;             // The Name or Subject of the Task or Event 
        global string ah_Source;           // The Source of the Activity (sObject/Type)
        global string ah_Owner_Id;         // An ID of a Salesforce user that owns the Task or Event
        global string ah_Owner_Title;      // Owner Title; usually abbreviated, used for comparison to settings
        global string ah_Owner_ISR_Group;  // Owner ISR Group; added to Title if the Title is ISR
        global string ah_KeyId;            // The ID of the object referenced, whether WhatId or WhoId
        global string ah_WhatId;           // Account, Opportunity, or Campaign
        global string ah_WhoId;            // Lead, or Contact
        global string ah_AccountId;        // Account; this is usually recorded on Account and Opportunity
        global datetime ah_ActivityDate;   // Due Date for Tasks; Event Date for Events
    }
    
    // log variable
    public ALL_UtilitiesBatch.Logger log;
    
    // constructor
    global DS_Account_LastActivity()
    {
        log=new ALL_UtilitiesBatch.Logger();
    }
    
    /* BATCH METHODS - These methods are required for Batch Apex; they call the respective processes: initialize and processbatch. */
    /*                 Finish is not yet implemented, but it could be configured to send an e-mail when the batch is complete.     */
    // START - batch initialization
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        system.debug(' ***** START ***** '); // debug messsage for start; start, execute, and finish are logged to separate files
        return Database.getQueryLocator(b_start());
    }
    
    // EXECUTE - batch processing (going through the data provided by the start method)
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        system.debug(' ***** EXECUTE ***** '); // debug message for execute
        b_execute(scope);
    }
    
    // initialize (non-batch method, but used in start/initialization; called by START)
    global string b_start()
    {
        system.debug(' ***** SINGLE INSTANCE START ***** ');
        
        // if useLastRunConditions is blank, do not use Last Run Conditions
        if(useLastRunConditions == null)
        {
            useLastRunConditions=false;
        }
        
        // query variable to build the query on
        string BuildQuery='';
        
        // build the query if one is not supplied by the calling code
        if(query == null || query == '')
        {
            // put together a query of the Account, Last Activities related to the Account
            // and ActivityHistories related to the Account
            BuildQuery='Select Id, Name From Account ';
            
            // limit the Accounts returned to those that are needed
            // Khan : RQ-04052 change criteria to look at new checkboxes for duplicate & OOB
            BuildQuery += ' Where Out_of_Business__c != true And Duplicate__c != true And Owner.Non_Interactive_User__c != true ';
            
            // test query options (comment out for production)
            //queryWhere=' And Id=\'0014000000JvtV5AAJ\''; // test Account, options: 0014000000JvxkKAAR, 0014000000JvwuGAAR, 0014000000JvxSPAAZ
            //queryLimit=' Limit 1000'; // limit to save time testing
            
            // add the where clause and limit if applicable
            if(queryWhere != null && queryWhere != '')
            {
                BuildQuery += ' ' + queryWhere + ' ';
            }
            
            if(queryLimit != null && queryLimit != '')
            {
                BuildQuery += ' ' + queryLimit + ' ';
            }
        }
        
        // log the query for checking if necessary
        system.debug(BuildQuery);
        
        //insert JobLog;
        
        return BuildQuery;
    }
    
    // process (non-batch method, but called by EXECUTE)
    global void b_execute(List<sObject> scope)
    {
        // debug message for execute
        system.debug(' ***** SINGLE INSTANCE EXECUTE ***** ');
        
        // a map of Activity History Settings
        Map<String,ActivityHistorySettings__c> ActivityHistorySettings=new Map<String,ActivityHistorySettings__c>();
        
        // populate the map for comparison later
        for(ActivityHistorySettings__c setting : settings)
        {
            ActivityHistorySettings.put(setting.Type__c.trim().toLowerCase(), setting);
        }
        
        // a map of Last Activities to update by KeyId (Account, Lead, or Opportunity) and Channel Name
        // Last Activities are added to this map so that they can all be updated with a single DML update statement
        Map<String,Last_Activity__c> LastActivitiesToUpsert=new Map<String,Last_Activity__c>();
        
        // a map of Last Activities to delete by Last_Activity__c Id
        // there should only be one Last Activity record per account; all others should be deleted
        Map<ID,Last_Activity__c> LastActivitiesToDelete=new Map<ID,Last_Activity__c>();
        
        // a list of Errors to insert, or log
        List<Batch_Failure__c> Errors=new List<Batch_Failure__c>();
        
        List<Id> AccountIdQueryList=new List<Id>();
        for(sObject sid : scope) { AccountIdQueryList.add(sid.Id); }
        
        // ----- WORK-AROUND -----
        // ----- It looks like a Salesforce bug is affecting the query results returned by the Start method query locator.
        // ----- The records will need to be queried separately 
        
        //2015-11-23- anirudh.singh@cdk.com- updated the below line.
        // get the job settings for the current batch class name
        Job_Settings__c z=Null;
        Map<String, Job_Settings__c> AllJobSettings=Job_Settings__c.getAll();
        
        if(AllJobSettings!= Null && !AllJobSettings.isEmpty()) 
        {
            for(Job_Settings__c jobSettings: AllJobSettings.values())
            { 
                if(jobSettings.Class_Name__c==currentClassName)
                {
                    z=jobSettings;
                } 
            }
        }
        
        // generate last run conditions
        DateTime LastRun = z != null ? z.Last_Run__c : DateTime.now(); 
        string LastRunConditions = '';
        
        if(LastRun != null) 
        {
            if(useLastRunConditions) 
            { 
                LastRun=LastRun.addDays(-2); 
                LastRunConditions=' And LastModifiedDate > ' 
                    + String.valueOf(LastRun).replace(' ', 'T') + 'Z ';
                Log.lastRunDateTime=LastRun;
            } 
        }
        
        // convert set to string for query
        String AccountIdQueryString='(';
        for(Id i : AccountIdQueryList)
        {
            AccountIdQueryString += '\'' + String.valueOf(i) + '\',';
        }
        if(AccountIdQueryString.endsWith(','))
        {
            AccountIdQueryString=AccountIdQueryString.substring(0, AccountIdQueryString.lastIndexOf(','));
        }
        AccountIdQueryString += ')';
        
        // put together a query of the Account, Last Activities related to the Account
        // and ActivityHistories related to the Account
        String BuildQuery='Select Id, Name ';
        
        BuildQuery += ', (Select Id, Activity_Id__c, Activity_Date__c, Activity_Subject__c, Channel_Name__c, Account__c, Campaign__c, Opportunity__c, Lead__c '
            + ' From Account_Related_To__r Order By CreatedDate desc) ';
        
        BuildQuery += ', (Select Id, Subject, OwnerId, Owner.Title, WhatId, WhoId, AccountId, ActivityDate, LastModifiedDate From Tasks '
            + ' Where IsClosed=true ' + LastRunConditions 
            + ' And (NOT Owner.Name like \'%Reporting%\') '
            + ' And (NOT Owner.Name like \'%Integration%\') '
            + ' And (NOT Owner.Name like \'%Admin%\') '
            + ') ';
        
        BuildQuery += ', (Select Id, Subject, OwnerId, Owner.Title, WhatId, WhoId, AccountId, ActivityDate, LastModifiedDate From Events ' 
            + ' Where Id != null ' + LastRunConditions
            + ' And (NOT Owner.Name like \'%Reporting%\') '
            + ' And (NOT Owner.Name like \'%Integration%\') '
            + ' And (NOT Owner.Name like \'%Admin%\') '
            + ') ';
        
        BuildQuery += ', (Select Id From Leads__r) '; // Current_Account__c
        
        BuildQuery += ', (Select Subject, Status, OwnerId, Owner.Name, Owner.Title, ActivityType, ActivityDate, LastModifiedDate, '
            + ' AccountId, Account.Name, WhatId, What.Name, WhoId, Who.Name '
            //+ ' From ActivityHistories Where ((IsTask=true and IsClosed=true) or (IsTask=false)) ' + LastRunConditions + '' //previous
            //+ ' From ActivityHistories Where ((IsTask=true and IsClosed=true) or (IsTask=false and ActivityDate < ' + String.valueOf(Date.Today()) + ')) ' //previous 2
            + ' From ActivityHistories Where ((IsTask=true and IsClosed=true) or (IsTask=false ' + LastRunConditions + ')) ' 
            + ' ' + LastRunConditions + ' '
            + ' And (NOT Owner.Name like \'%Reporting%\') '
            + ' And (NOT Owner.Name like \'%Integration%\') '
            + ' And (NOT Owner.Name like \'%Admin%\') '
            + ' Order By LastModifiedDate desc) ';
        
        BuildQuery += ' From Account ';
        
        // limit the Accounts returned to those that are needed
        BuildQuery += ' Where Id IN ' + AccountIdQueryString;
        
        //Typical generated query looks like:
        //--------------------------
        //List<Account> scope=[Select Id, Name, 
        //(Select Id, Activity_Id__c, Activity_Date__c, Activity_Subject__c, Channel_Name__c, Account__c, Campaign__c, Opportunity__c, Lead__c 
        //Frzom Account_Related_To__r Order By CreatedDate desc), 
        //(Select Id, Subject, OwnerId, Owner.Title, WhatId, WhoId, AccountId, ActivityDate, LastModifiedDate 
        //From Tasks  
        //Where IsClosed=true  
        //And (NOT Owner.Name like '%Reporting%')  
        //And (NOT Owner.Name like '%Integration%')  
        //And (NOT Owner.Name like '%Admin%') ), 
        //(Select Id, Subject, OwnerId, Owner.Title, WhatId, WhoId, AccountId, ActivityDate, LastModifiedDate 
        //From Events  
        //Where Id != null  
        //And (NOT Owner.Name like '%Reporting%')  
        //And (NOT Owner.Name like '%Integration%')  
        //And (NOT Owner.Name like '%Admin%') ), 
        //(Select Id From Leads__r), 
        //(Select Subject, Status, OwnerId, Owner.Name, Owner.Title, ActivityType, ActivityDate, LastModifiedDate, AccountId, Account.Name, WhatId, What.Name, WhoId, Who.Name  
        //From ActivityHistories 
        //Where ((IsTask=true and IsClosed=true) or (IsTask=false))  
        //And (NOT Owner.Name like '%Reporting%')  
        //And (NOT Owner.Name like '%Integration%')  
        //And (NOT Owner.Name like '%Admin%')  
        //Order By LastModifiedDate desc)  
        //From Account  
        //Where Out_of_Business__c != true 
        //And Duplicate__c != true
        // And Site_Type__r.Name != 'Out-of-Business'
        //And Id='0014000000JvtV5AAJ'];
        // Khan : RQ-04052 change criteria to look at new checkboxes for duplicate & OOB
        //];
        
        Map<Id, Account> QueryAccounts=new Map<Id, Account>((List<Account>)Database.query(BuildQuery));
        
        // ----- End WORK-AROUND -----
        
        // work with a single sObject from the scope (list of objects, limited by batch size, returned by the query)
        for(sObject s : scope)
        {
            Log.recordsProcessed++;
            
            try
            {
                system.debug('Scope Loop - sObject: ' + s);
                
                // all of the related Last Activity records for the sObject
                List<Last_Activity__c> sObjectLastActivities=QueryAccounts.get(s.Id).getSObjects('Account_Related_To__r'); //s.getSObjects('Account_Related_To__r');
                
                // the individual object groups that will make up the Master Activity History Map
                List<Task> sObjectTasks=QueryAccounts.get(s.Id).getSObjects('Tasks'); //s.getSObjects('Tasks');
                List<Event> sObjectEvents=QueryAccounts.get(s.Id).getSObjects('Events'); //s.getSObjects('Events');
                List<Lead> sObjectLeads=QueryAccounts.get(s.Id).getSObjects('Leads__r'); //s.getSObjects('Leads__r'); // Current_Account__c
                List<ActivityHistory> sObjectActivityHistories=QueryAccounts.get(s.Id).getSObjects('ActivityHistories'); //s.getSObjects('ActivityHistories');
                
                Log.collectedExistingLastActivities += ((sObjectLastActivities!=null)?sObjectLastActivities.size():0);
                Log.collectedExistingTasks += ((sObjectTasks!=null)?sObjectTasks.size():0);
                Log.collectedExistingEvents += ((sObjectEvents!=null)?sObjectEvents.size():0);
                Log.collectedExistingLeads += ((sObjectLeads!=null)?sObjectLeads.size():0);
                Log.collectedExistingActivityHistories += ((sObjectActivityHistories!=null)?sObjectActivityHistories.size():0);
                
                // an empty Master Activity History Map to be filled with the disparate related Activities
                Map<ID,MasterActivityHistory> MasterActivityHistoryMap=new Map<ID,MasterActivityHistory>();
                
                // a map of the Last Activities to work with
                // This is needed to dynamically select the Last Activity to work with based on the Activity KeyId reference
                Map<String,Last_Activity__c> MasterLastActivitiesMap=new Map<String,Last_Activity__c>();
                
                if(sObjectLastActivities != null)
                {
                    // put together the map of activities for comparison later by WhatId (or Account, Campaign, or Opportunity Id)
                    for(Last_Activity__c la : sObjectLastActivities)
                    {
                        system.debug('Last Activity (la): ' + la);
                        
                        // because there are three different Id fields (of which only one is populated), use a variable to collect the Id
                        Id WhichIdField=null;
                        
                        if(la.Account__c != null)
                        {
                            WhichIdField=la.Account__c;
                        }
                        
                        if(la.Campaign__c != null)
                        {
                            WhichIdField=la.Campaign__c;
                        }
                        
                        if(la.Opportunity__c != null)
                        {
                            WhichIdField=la.Opportunity__c;
                        }
                        
                        if(la.Lead__c != null)
                        {
                            WhichIdField=la.Lead__c;
                        }
                        
                        // do not add it if it exists; in fact, delete it.
                        if(MasterLastActivitiesMap.containsKey(s.Id+'-'+la.Channel_Name__c.trim().toLowerCase()))
                        { 
                            system.debug('To Delete: ' + la);
                            LastActivitiesToDelete.put(la.Id, la);
                        }
                        // else, put the Last Activity in the map
                        // UPDATE - need to add CHANNEL NAME here to retrieve all activities by channel, because there can be multiple per Object ID
                        else
                        {
                            system.debug('To Update: ' + la);
                            MasterLastActivitiesMap.put(s.Id+'-'+la.Channel_Name__c.trim().toLowerCase(), la);
                        }
                        // old method below
                        //else { system.debug('To Update: ' + la); MasterLastActivitiesMap.put(WhichIdField,la); }
                    }
                    
                    for(string key : MasterLastActivitiesMap.keySet())
                    {
                        system.debug('+++ MasterLastActivitiesMap (' + key + '):' + MasterLastActivitiesMap.get(key));
                    }
                    
                    for(string key : LastActivitiesToDelete.keySet())
                    {
                        system.debug('--- LastActivitiesToDelete (' + key + '):' + LastActivitiesToDelete.get(key));
                    }
                }
                
                // add tasks (t)
                system.debug('Tasks: '+sObjectTasks);
                if(sObjectTasks != null)
                {
                    for(Task t : sObjectTasks)
                    {
                        MasterActivityHistory MasterRecord=new MasterActivityHistory();
                        MasterRecord.ah_Source='Task';
                        MasterRecord.ah_Id=t.Id;
                        MasterRecord.ah_Name=t.Subject;
                        MasterRecord.ah_Owner_Id=t.OwnerId;
                        MasterRecord.ah_Owner_Title=t.Owner.Title;
                        MasterRecord.ah_AccountId=t.AccountId;
                        MasterRecord.ah_ActivityDate=t.LastModifiedDate;
                        MasterRecord.ah_WhatId=t.WhatId;
                        MasterRecord.ah_KeyId=t.WhatId;
                        
                        //system.debug('T Master: '+MasterRecord);
                        
                        MasterActivityHistoryMap.put(MasterRecord.ah_Id, MasterRecord);
                    }
                }
                
                // add events (e)
                system.debug('Events: '+sObjectEvents);
                if(sObjectEvents != null)
                {
                    for(Event e : sObjectEvents)
                    {
                        MasterActivityHistory MasterRecord=new MasterActivityHistory();
                        MasterRecord.ah_Source='Event';
                        MasterRecord.ah_Id=e.Id;
                        MasterRecord.ah_Name=e.Subject;
                        MasterRecord.ah_Owner_Id=e.OwnerId;
                        MasterRecord.ah_Owner_Title=e.Owner.Title;
                        MasterRecord.ah_AccountId=e.AccountId;
                        MasterRecord.ah_ActivityDate=e.LastModifiedDate;
                        MasterRecord.ah_WhatId=e.WhatId;
                        MasterRecord.ah_KeyId=e.WhatId;
                        
                        //system.debug('E Master: '+MasterRecord);
                        
                        MasterActivityHistoryMap.put(MasterRecord.ah_Id, MasterRecord);
                    }
                }
                
                // loop through each leads__r (l) to collect their ActivityHistory
                system.debug('Leads: '+sObjectLeads);
                List<ID> AllLeadIds=new List<ID>();
                
                if(sObjectLeads != null)
                {
                    for(Lead l : sObjectLeads)
                    {
                        AllLeadIds.add(l.Id);
                    }
                }
                
                sObjectLeads=[
                    Select Id, 
                    (Select Id,  Subject, Status, Description, OwnerId, Owner.Name, Owner.Title, ActivityType, ActivityDate, LastModifiedDate, 
                     AccountId, Account.Name, WhatId, What.Name, WhoId, Who.Name 
                     From ActivityHistories 
                     Where (NOT LastModifiedBy.Name like '%Reporting%')
                     And (NOT LastModifiedBy.Name like '%Integration%')
                     And (NOT LastModifiedBy.Name like '%Admin%')
                     Order By LastModifiedDate desc)
                    From Lead
                    Where Id In :AllLeadIds
                ]; 
                
                // add Lead ActivityHistory to ActivityHistory
                if(sObjectLeads != null)
                {
                    for(Lead l : sObjectLeads)
                    {
                        for(ActivityHistory lah : l.ActivityHistories)
                        {
                            //system.debug(LeadActivityHistory);
                            if(lah != null) 
                            {
                                MasterActivityHistory MasterRecord=new MasterActivityHistory();
                                MasterRecord.ah_Source='Lead';
                                MasterRecord.ah_Id=lah.Id;
                                MasterRecord.ah_Name=lah.Subject;
                                MasterRecord.ah_Owner_Id=lah.OwnerId;
                                MasterRecord.ah_Owner_Title=lah.Owner.Title;
                                MasterRecord.ah_AccountId=lah.AccountId;
                                MasterRecord.ah_ActivityDate=lah.LastModifiedDate;
                                MasterRecord.ah_WhoId=lah.WhoId;
                                MasterRecord.ah_KeyId=lah.WhoId;
                                
                                //system.debug('LAH Master: '+MasterRecord);
                                
                                MasterActivityHistoryMap.put(MasterRecord.ah_Id, MasterRecord);
                            }
                        }
                    }
                }
                
                // add Account ActivityHistory (Tasks and Events)
                // this serves as a catch-all, making sure all Activities have been added
                //system.debug('ActivityHistories: '+sObjectActivityHistories);
                if(sObjectActivityHistories != null)
                {
                    for(ActivityHistory ah : sObjectActivityHistories)
                    {
                        String KeyId=String.valueOf(ah.WhatId);
                        String WhoId=String.valueOf(ah.WhoId);
                        
                        // if this is a Lead, set the KeyId to the WhoId
                        if(WhoId != null)
                        {
                            if(WhoId.startsWith('00Q'))
                            {
                                KeyId=WhoId;
                                /* system.debug('WHO ID: '+KeyId); */
                            }
                        }
                        
                        MasterActivityHistory MasterRecord=new MasterActivityHistory();
                        MasterRecord.ah_Source='ActivityHistory';
                        MasterRecord.ah_Id=ah.Id;
                        MasterRecord.ah_Name=ah.Subject;
                        MasterRecord.ah_Owner_Id=ah.OwnerId;
                        MasterRecord.ah_Owner_Title=ah.Owner.Title;
                        MasterRecord.ah_AccountId=ah.AccountId;
                        MasterRecord.ah_ActivityDate=ah.LastModifiedDate;
                        MasterRecord.ah_WhatId=ah.WhatId;
                        MasterRecord.ah_WhoId=WhoId;
                        MasterRecord.ah_KeyId=KeyId;
                        
                        //system.debug('AH Master: '+MasterRecord);
                        
                        MasterActivityHistoryMap.put(MasterRecord.ah_Id, MasterRecord);
                    }
                }
                
                // sort the ActivityHistory Objects by their Owner Title
                List<MasterActivityHistory> records=MasterActivityHistoryMap.values();
                Boolean swapped=true; Integer j=0;
                
                while(swapped)
                {
                    swapped=false; j++;
                    
                    for(Integer i=0; i < records.size() - j; i++)
                    {
                        if (records[i].ah_Owner_Title > records[i+1].ah_Owner_Title)
                        {
                            MasterActivityHistory temp=records[i];
                            records[i]=records[i+1];
                            records[i+1]=temp;
                            swapped=true;
                        }
                    } 
                }
                // end sort
                
                system.debug('All Collected Activity Histories: ');
                for(MasterActivityHistory m : records)
                {
                    system.debug('  '+m.ah_Owner_Title+' - '+m);
                }
                
                // process collected ActivityHistory records
                if(MasterActivityHistoryMap.size() > 0)
                {
                    // Get Owners
                    Map<Id,User> ActivityHistoryAndOwners=MapOwnersAndActivityHistories(MasterActivityHistoryMap.values());
                    //for(User u : ActivityHistoryAndOwners.values()) { system.debug('Owners: '+u); } 
                    
                    system.debug(' ***** CONTINUE PROCESS ***** ');
                    
                    for(MasterActivityHistory m : MasterActivityHistoryMap.values())
                    {
                        //system.debug(m);
                        
                        // startsWith is not valid for ID field types, so convert to String
                        String KeyId=String.valueOf(m.ah_WhatId);
                        String WhoId=String.valueOf(m.ah_WhoId);
                        
                        // if the Activity History is from a Lead, make sure to store the WhoId in the KeyId
                        // KeyId contains either a WhatId or a WhoId
                        if(WhoId != null)
                        {
                            if(WhoId.startsWith('00Q'))
                            {
                                KeyId=WhoId; 
                                /* system.debug('WHO ID: '+KeyId); */
                            }
                        }
                        
                        // get the Owner title for comparison
                        string ah_Owner_Title='';
                        if(m.ah_Owner_Title != null)
                        {
                            ah_Owner_Title=m.ah_Owner_Title.toLowerCase().trim();
                        }
                        
                        // ISRs need to be paried with groups
                        if(ah_Owner_Title == 'isr')
                        {
                            //system.debug('Owner Title Matches Type');
                            User ah_Owner=ActivityHistoryAndOwners.get(m.ah_Id);
                            
                            if(ah_Owner.ISR_Group__c != null)
                            {
                                ah_Owner_Title=ah_Owner_Title + ' ' + ah_Owner.ISR_Group__c.toLowerCase().trim();
                                m.ah_Owner_ISR_Group=ah_Owner.ISR_Group__c;
                            }
                        }
                        // End ISR group modifications
                        
                        //Boolean containsKey=ActivityHistorySettings.containsKey(ah_Owner_Title);
                        //system.debug('ah_Owner_Title: '+ah_Owner_Title+'('+containsKey+')'+', m:'+m);
                        //system.debug('Current Activity History Id: ' + m.ah_Id + ', KeyId: ' + KeyId 
                        //   + ', WhoId: ' + m.ah_WhoId + ', WhatId: ' + m.ah_WhatId + ', AccountId: ' + s.Id);
                        
                        // if the Owner Title matches an ActivityHistorySetting (or if the Owner Title exists in the Activity History settings)
                        if(ActivityHistorySettings.containsKey(ah_Owner_Title))
                        {
                            // ** INVENTORY **
                            // ActivityHistorySettings - Map of settings containing field information by Owner Title
                            // MasterActivityHistory - Custom Apex object (child-class) structure for all Activity Histories
                            // MasterActivityHistoryMap - Map of Activity Histories by Activity (Event or Task) Id
                            // ActivityHistoryAndOwners - Map of Activity Owners by Activity (Event or Task) Id
                            // m - Current Master Activity History record
                            // ** END INVENTORY **
                            
                            // get the setting in which the Owner Title exists
                            ActivityHistorySettings__c setting=ActivityHistorySettings.get(ah_Owner_Title);
                            
                            system.debug('  >>> Owner Title Contains Type. Owner Title: ' + ah_Owner_Title + ', Type: ' + setting.Type__c);
                            
                            // put together a key for referencing a Last Activity in the update list
                            String UpsertListKey=s.Id+'-'+setting.Group__c.trim().toLowerCase(); 
                            
                            // do not update a Last Activity unless it meets certain conditions
                            boolean UpdateLastActivity=false;
                            
                            //Last_Activity__c ExistingKeyIdLastActivity=null;
                            Last_Activity__c ExistingSIdLastActivity=null;
                            
                            // get the Last Activity/Activities to work with
                            // s.Id is the Id of the Account (Related To)
                            if(MasterLastActivitiesMap.get(UpsertListKey) != null)
                            {
                                ExistingSIdLastActivity=MasterLastActivitiesMap.get(UpsertListKey);
                            }
                            
                            // if there is already a sId Last Activity record
                            if(ExistingSIdLastActivity != null)
                            {
                                system.debug('    Last Activity exists: ' + ExistingSIdLastActivity);
                                // if the Date Field is not null
                                if(ExistingSIdLastActivity.get('Activity_Date__c') != null)
                                {
                                    // check to see if the date of the current Activity History is greater than the recorded date
                                    if(m.ah_ActivityDate > (DateTime)ExistingSIdLastActivity.get('Activity_Date__c'))
                                    {
                                        UpdateLastActivity=true;
                                    }
                                }
                                // if the Date Field is null
                                else
                                {
                                    UpdateLastActivity=true;
                                }
                            }
                            else
                            {
                                UpdateLastActivity=true;
                            }
                            
                            // Update the Last Activity(ies)
                            if(UpdateLastActivity)
                            {
                                //Last_Activity__c KeyIdLastActivityToUpsert;
                                Last_Activity__c sIdLastActivityToUpsert;
                                
                                String LastActivityType='';
                                
                                if(KeyId != null)
                                {
                                    if(KeyId.startsWith('00Q')) { LastActivityType='Lead'; }
                                    if(KeyId.startsWith('001')) { LastActivityType='Account'; }
                                    if(KeyId.startsWith('701')) { LastActivityType='Campaign'; }
                                    if(KeyId.startsWith('006')) { LastActivityType='Opportunity'; }
                                }
                                
                                // if there is a record of this sId in the Last Activities for this sObject, use that record
                                if(MasterLastActivitiesMap.get(UpsertListKey) != null)
                                { 
                                    sIdLastActivityToUpsert=MasterLastActivitiesMap.get(UpsertListKey);
                                }
                                // otherwise, create a new record to work with
                                else
                                {
                                    sIdLastActivityToUpsert=new Last_Activity__c(Related_To__c=s.Id);
                                }
                                
                                // check to see if the Activity Id is in the list to update
                                // if it is not in the list, add it
                                if(!LastActivitiesToUpsert.containsKey(UpsertListKey))
                                {
                                    system.debug('      Does not contain Activity Id, putting');
                                    // PUT the Last Activity to Upsert in the list of Last Activities to Upsert
                                    LastActivitiesToUpsert.put(UpsertListKey,sIdLastActivityToUpsert); 
                                    // name it
                                    LastActivitiesToUpsert.get(UpsertListKey).Related_IDs__c='LA-' + m.ah_Id;
                                }
                                
                                // log all Activity Histories to the sObject (Account)
                                if(LastActivitiesToUpsert.containsKey(UpsertListKey))
                                {
                                    system.debug('      Contains m.ah_Id');
                                    
                                    if(LastActivitiesToUpsert.get(UpsertListKey) != null)
                                    {
                                        // relate it
                                        if(LastActivityType == 'Account') { LastActivitiesToUpsert.get(UpsertListKey).Account__c=KeyId; system.debug('        Type: Account'); }
                                        if(LastActivityType == 'Campaign') { LastActivitiesToUpsert.get(UpsertListKey).Campaign__c=KeyId; system.debug('        Type: Campaign'); }
                                        if(LastActivityType == 'Opportunity') { LastActivitiesToUpsert.get(UpsertListKey).Opportunity__c=KeyId; system.debug('        Type: Opportunity'); }
                                        if(LastActivityType == 'Lead') { LastActivitiesToUpsert.get(UpsertListKey).Lead__c=KeyId; system.debug('        Type: Lead'); }
                                        
                                        // update it (if Current LastModifiedDate > Last Activity Date)
                                        if(m.ah_ActivityDate >= (DateTime)LastActivitiesToUpsert.get(UpsertListKey).get('Activity_Date__c') ||
                                           LastActivitiesToUpsert.get(UpsertListKey).get('Activity_Date__c') == null)
                                        {
                                            system.debug('        (m.ah_Id='+m.ah_Id+') Updating LastActivitiesToUpsert record: ' + LastActivitiesToUpsert.get(UpsertListKey));
                                            LastActivitiesToUpsert.get(UpsertListKey).put('Channel_Name__c',setting.Group__c);
                                            LastActivitiesToUpsert.get(UpsertListKey).put('Activity_Id__c',m.ah_Id);
                                            LastActivitiesToUpsert.get(UpsertListKey).put('Activity_Subject__c',m.ah_Name);
                                            LastActivitiesToUpsert.get(UpsertListKey).put('Activity_By__c',m.ah_Owner_Id);
                                            LastActivitiesToUpsert.get(UpsertListKey).put('Activity_Date__c',m.ah_ActivityDate);
                                            system.debug('        (m.ah_Id='+m.ah_Id+') Updated LastActivitiesToUpsert record: ' + LastActivitiesToUpsert.get(UpsertListKey));
                                        }
                                    }
                                }
                                
                                //for(string key : LastActivitiesToUpsert.keySet()) { 
                                //system.debug('LastActivitiesToUpsert: ' + key + ':' + LastActivitiesToUpsert.get(key+'-'+setting.Type__c.trim().toLowerCase())); }
                            }
                        }
                    } // END FOR (ActivityHistories)
                }
                
                //system.debug('LastActivitiesByType: '+LastActivitiesByType);
                //for(string key : MasterLastActivitiesMap.keySet()) { system.debug('MasterLastActivitiesMap: ' + key + ':' + MasterLastActivitiesMap.get(key)); }
                
            } // END TRY
            catch(Exception ex)
            {
                Errors.add(
                    new Batch_Failure__c(
                        Source__c=currentClassName,
                        Error_Message__c=ex.getMessage(),
                        sObject_Id__c=s.Id,
                        Line_Number__c=ex.getLineNumber(),
                        Error_Type__c=ex.getTypeName()
                    )
                );
            }
        } // END FOR (scope, Accounts)
        
        // try to delete the last activities (when there is more than last activity record on the account)
        try 
        {
            if(!LastActivitiesToDelete.IsEmpty()) 
            { 
                system.debug('Deleting: ' + LastActivitiesToDelete.values()); 
                Log.oldLastActivitiesDeleted += LastActivitiesToDelete.size();
                delete LastActivitiesToDelete.values(); 
            } 
        } 
        catch (Exception ex) { 
            Errors.add(
                new Batch_Failure__c(
                    Source__c=currentClassName,
                    Error_Message__c=ex.getMessage(),
                    Line_Number__c=ex.getLineNumber(),
                    Error_Type__c=ex.getTypeName()
                )
            ); 
        }
        
        // try to insert/update the new last activities
        try 
        {
            if(!LastActivitiesToUpsert.IsEmpty()) 
            { 
                for(string key : LastActivitiesToUpsert.keySet())
                {
                    system.debug('Upserting: KeyId(' + key + '):' + LastActivitiesToUpsert.get(key));
                }
                Log.lastActivitiesUpserted += LastActivitiesToUpsert.size();
                upsert LastActivitiesToUpsert.values(); 
            } 
        }
        catch (Exception ex)
        { 
            Errors.add(
                new Batch_Failure__c(
                    Source__c=currentClassName,
                    Error_Message__c=ex.getMessage(),
                    Line_Number__c=ex.getLineNumber(),
                    Error_Type__c=ex.getTypeName()
                )
            ); 
        }
        
        // if errors occurred, log them as records in the error object
        if(!Errors.IsEmpty())
        {
            system.debug(Errors);
            insert Errors;
        }
    }
    
    // FINISH - code to be executed after the batch completes
    // it is possible to have the system email the status after each batch is run...
    global void finish(Database.BatchableContext BC)
    { 
        system.debug('Start finish---->');
        log.batchId=BC.getJobId();
        b_finish();
    }
    
    //2015-10-29- anirudh.singh@cdk.com- Commented the below method.
    global void b_finish()
    {
        //2015-10-20- anirudh.singh@cdk.com- Added the below code.
        if(log.batchId!=Null)
        {
            log.useLastRunConditions=useLastRunConditions;
            log.title='Last Activity Batch Job Summary';
            log.description='Logged Last Activities (Events and Tasks)';
            log.message='';
            
            ALL_UtilitiesBatch.finish(currentClassName, log);
        }
    }
    
    // get Owners
    global Map<Id,User> MapOwnersAndActivityHistories(List<MasterActivityHistory> AllActivityHistories)
    {
        system.debug(' ***** MAP OWNERS AND ACTIVITY HISTORIES ***** ');
        
        // Owner variables
        List<ID> OwnerIDs=new List<ID>();
        Map<Id,User> ActivityHistoryAndOwners=new Map<Id,User>();
        
        // get all activity history owners
        //   These cannot be added to the Activity History query because the Owner on Activity History records
        //   specifically Events is polymorphic; the Owner can either be a Calendar (not currently used at ADP or a User).
        //   Owners must be queried separately. Because the Owner for Events is polymorphic, no custom fields 
        //   (such as ISR_Group__c) can be accessed through the relationship.
        for(MasterActivityHistory m : AllActivityHistories)
        {
            if(m.ah_Owner_Id != null)
            {
                OwnerIDs.add(m.ah_Owner_Id);
            }
        }
        
        // get Owner data
        Map<Id,User> Owners=new Map<Id,User>([Select Id, Name, Title, ISR_Group__c from User Where Id IN :OwnerIDs]);
        
        // put the Owner data together, mapping Activity History Id to the Owner data
        // (this seems unnecessarily complicated - having two for loops... but it seems to be the only way to limit to one Owner query)
        // (the less queries there are, the more Accounts can be processed at the same time)
        for(MasterActivityHistory m : AllActivityHistories)
        {
            ActivityHistoryAndOwners.put(m.ah_Id,Owners.get(m.ah_Owner_Id));
        }
        // end Owner logic
        
        return ActivityHistoryAndOwners;
    }
}