/* ADP Dealer Services - Sales Automation
* Programmer: Matt Keefe (matt_keefe@adp.com)
* Class: DS_Account_LastActivity_Test.cls
* Description: Unit Test for DS_Account_LastActivity.cls
*/
//2015-11-24- anirudh.singh@cdk.com- Added the below two field values (Class_Name__c and Finish_Email__c).
//2015-11-27    vishal.bandari@cdk.com    RQ-05289:changed methods to add contact record type
//2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
@isTest
public class DS_Account_LastActivity_Test
{
    // Test all of the single instance methods
    public static testmethod void TestSingleInstanceMethods() 
    {
        DateTime NowMinusFive = DateTime.now() - 5;
        User CurrentUser = [Select Id from User where Id = :UserInfo.getUserId()];
        
        // insert the ActivityHistorySettings custom settings // 10/3/2014 SivaP
        ActivityHistorySettings__c AHSSettings = new ActivityHistorySettings__c();
        AHSSettings.Date_Field__c = 'Key_Rep_Last_Activity_Date__c';
        AHSSettings.Group__c = 'Key Rep';
        AHSSettings.Type__c = 'ADE';
        AHSSettings.User_Field__c = 'Key_Rep_Last_Activity_By__c';
        AHSSettings.Name = 'test';     
        
        insert new List<ActivityHistorySettings__c> { AHSSettings };
            
            
            List<ActivityHistorySettings__c> settings = ActivityHistorySettings__c.getall().values();
        Map<String,ActivityHistorySettings__c> ActivityHistorySettings = new Map<String,ActivityHistorySettings__c>();
        
        for(ActivityHistorySettings__c setting : settings) {
            ActivityHistorySettings.put(setting.Type__c.trim().toLowerCase(),setting); }
        
        User u = DS_TestObjects.NewUser_Inserted();       // inserted
        Account a = DS_TestObjects.NewAccount_Inserted(); // inserted
        
        Task t = DS_TestObjects.NewTask();                // not inserted
        Event e = DS_TestObjects.NewEvent();              // not inserted
        
        Task lt = DS_TestObjects.NewTask();               // not inserted
        Event le = DS_TestObjects.NewEvent();             // not inserted
        
        Contact c = DS_TestObjects.NewContact();          // not inserted
        //c.Role__c = 'Test Role'; // 9/29
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordType = [select id from recordtype where name = 'Customer Contact' and SobjectType='Contact'][0];
        Lead l = DS_TestObjects.NewLead();                // not inserted
        Opportunity o = DS_TestObjects.NewOpportunity();  // not inserted
        
        c.AccountId = a.Id;
        l.Current_Account__c = a.Id;
        
        o.AccountId = a.Id;
        
        system.debug(c); system.debug(l); system.debug(o);
        system.runAs(CurrentUser) { insert c; insert l; insert o; }
        
        t.OwnerId = u.Id;
        t.WhatId = a.Id;
        t.WhoId = c.Id;
        
        e.OwnerId = u.Id;
        e.WhatId = a.Id;
        e.WhoId = c.Id;
        e.OwnerId = u.Id;
        e.WhatId = a.Id;        
        e.EndDateTime = DateTime.now() - 2;
        e.ActivityDateTime = NowMinusFive;
        e.StartDateTime = NowMinusFive;
        
        
        lt.OwnerId = u.Id;
        lt.WhoId = l.Id;
        lt.ActivityDate = Date.today() - 1; // 10/3/2014 SivaP
        lt.Status = 'Completed';
        
        
        le.OwnerId = u.Id;
        le.WhoId = l.Id;
        
        
        system.runas(CurrentUser) 
        { 
            insert t; system.debug(t);
            insert e; system.debug(e);
            insert lt; system.debug(lt);
            insert le; system.debug(le);
        }
        
        system.debug(t.Owner.Title);
        
        t = [Select ID, Subject, Status, ActivityDate, OwnerId, Owner.Title, WhatId, WhoId, AccountId From Task Where ID=:t.Id];
        
        system.debug(t.Owner.Title);
        
        Boolean SettingsContainsISR = false;
        String SettingsISRGroup = '';
        
        for(ActivityHistorySettings__c setting : settings) 
        {
            system.debug(setting);
            
            if(setting.Type__c.trim().toLowerCase().startsWith('isr')) 
            {
                SettingsContainsISR = true; 
                
                try
                {
                    SettingsISRGroup = setting.Type__c.trim().substring(setting.Type__c.indexof(' ')+1,setting.Type__c.length());
                } catch(Exception ex) { system.debug(ex); SettingsISRGroup = 'G1'; } 
            } 
        }
        
        if(SettingsContainsISR) { u.Title = 'ISR'; u.ISR_Group__c = SettingsISRGroup; }
        else { if(settings.size() > 0) { u.Title = settings[0].Type__c; } }
        
        update u;
        system.debug(u);
        
        List<Last_Activity__c> LastActivityList = new List<Last_Activity__c>();
        
        // Last Activity to test update case
        Last_Activity__c la1 = new Last_Activity__c(Related_To__c=a.Id,Account__c=a.Id, Channel_Name__c='TEST'); // 10/1/2014 SivaP
        LastActivityList.add(la1);
        
        // one extra to cover delete case
        Last_Activity__c la2 = new Last_Activity__c(Related_To__c=a.Id,Account__c=a.Id, Channel_Name__c='WEST'); // 10/1/2014 SivaP
        LastActivityList.add(la2);
        
        // Lead Last Activity to test WhoId case
        Last_Activity__c la3 = new Last_Activity__c(Related_To__c=a.Id,Lead__c=l.Id, Channel_Name__c='NEST'); // 10/1/2014 SivaP
        LastActivityList.add(la3);
        
        // Opportunity Last Activity to test non-Account WhatId case
        Last_Activity__c la4 = new Last_Activity__c(Related_To__c=a.Id,Opportunity__c=o.Id, Channel_Name__c='BEST'); // 10/1/2014 SivaP
        LastActivityList.add(la4);
        
        String ah_Owner_Title = '';
        
        if(u.Title == 'ISR') 
        {
            ah_Owner_Title = u.Title + ' ' + u.ISR_Group__c;
        }
        else
        {
            ah_Owner_Title = u.Title;
        }
        
        // for(Last_Activity__c la : LastActivityList) { la.Channel_Name__c = ah_Owner_Title; } // 10/2 SivaP
        
        if(ah_Owner_Title != null && !string.isEmpty(ah_Owner_Title)) // 10/1/2014 SivaP
        {
            ah_Owner_Title = ah_Owner_Title.trim().toLowerCase();
        }
        
        for(Last_Activity__c la : LastActivityList)
        {
            system.debug('TEST LAST ACTIVITY: '+la);
            system.debug('TEST ACTIVITY HISTORY OWNER: '+ah_Owner_Title);
            system.debug('TEST ACTIVITY HISTORY SETTINGS CONTAINSKEY: '+ActivityHistorySettings.containsKey(ah_Owner_Title));
            
            if(ActivityHistorySettings.containsKey(ah_Owner_Title))
            {
                //la.put(ActivityHistorySettings.get(ah_Owner_Title).User_Field__c,u.Id);
                //la.put(ActivityHistorySettings.get(ah_Owner_Title).Date_Field__c,Date.today().addYears(-10));
                
                la.put('Activity_By__c',u.Id);
                la.put('Activity_Date__c',Date.today().addYears(-10));
                
                system.debug(la);
            }
        }
        
        system.runas(CurrentUser) { insert LastActivityList; }
        
        DS_Account_LastActivity LastActivityBatchClass = new DS_Account_LastActivity();
        
        //create the job settings  // 10/1/2014 - SivaP
        Job_Settings__c jobSetting = new Job_Settings__c();
        //jobSetting.Finish_Email__c = 'siva.pragada@adp.com';
        jobSetting.Last_Run__c = datetime.newInstance(2014, 10, 03, 12, 30, 30);
        jobSetting.Name='Record 1';
        //2015-11-24- anirudh.singh@cdk.com- Added the below two field values (Class_Name__c and Finish_Email__c).
        jobSetting.Class_Name__c='DS_Account_LastActivity';
        //2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
        jobSetting.Finish_Emails__c='anirudh.singh@cdk.com';
        insert jobSetting;        
        
        // change the job settings to include test data
        //Job_Settings__c jobSetting = Job_Settings__c.getValues('DS_Account_LastActivity'); // 10/1/2014 SivaP
        
        system.debug(jobSetting);
        
        if(jobSetting != null)
        {        
            jobSetting.Last_Run__c = DateTime.now().addDays(-7);
            update jobSetting;
        }
        
        LastActivityBatchClass.useLastRunConditions = false;
        LastActivityBatchClass.queryWhere = ' And Id = \'' + t.AccountId + '\'';
        
        String query = LastActivityBatchClass.b_start();
        
        List<sObject> scope = Database.query(query);
        
        for(sObject s : scope) { system.debug('sObject: ' + s); } 
        system.debug(scope);
        LastActivityBatchClass.b_execute(scope);
        
        Batch_Failure__c fail = new Batch_Failure__c(Source__c='DS_Account_LastActivity',Error_Message__c='Test failure',Error_Type__c='Test',Line_Number__c=123);
        insert fail;
        
        LastActivityBatchClass.b_finish();
        
        Test.startTest();
        
        LastActivityBatchClass.queryLimit = ' Limit 1 ';
        LastActivityBatchClass.queryWhere = ' And Id = \'' + a.Id + '\' ';
        LastActivityBatchClass.useLastRunConditions = true;
        ID BatchId = Database.executeBatch(LastActivityBatchClass,1);
        
        Test.stopTest();       
    }
    
    // Test all of the batch methods: start, execute, finish
    public static testmethod void TestBatchMethods() 
    {
        User CurrentUser = [Select Id from User where Id = :UserInfo.getUserId()];
        
        // insert the ActivityHistorySettings custom settings // 10/3/2014 SivaP
        ActivityHistorySettings__c AHSSettings = new ActivityHistorySettings__c();
        AHSSettings.Date_Field__c = 'Key_Rep_Last_Activity_Date__c';
        AHSSettings.Group__c = 'Key Rep';
        AHSSettings.Type__c = 'isr';
        AHSSettings.User_Field__c = 'Key_Rep_Last_Activity_By__c';
        AHSSettings.Name = 'test';     
        
        insert new List<ActivityHistorySettings__c> { AHSSettings };
            
            List<ActivityHistorySettings__c> settings = ActivityHistorySettings__c.getall().values();
        Map<String,ActivityHistorySettings__c> ActivityHistorySettings = new Map<String,ActivityHistorySettings__c>();
        
        for(ActivityHistorySettings__c setting : settings) {
            ActivityHistorySettings.put(setting.Type__c.trim().toLowerCase(),setting); }
        
        //User u = DS_TestObjects.NewUser_Inserted();       // inserted
        Profile P = DS_TestObjects.getStandardProfile();
        Id StandardProfileId = P != null ? P.Id : null;
        
        User NewUser = new User(
            UserName='test-23'+'@cdk.com', 
            Email='test-56'+'@cdk.com', 
            Alias='h789i',
            EmailEncodingKey='UTF-8', 
            FirstName='Apex',
            LastName='Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid=StandardProfileId, 
            TimeZoneSIDKey='America/Chicago',
            //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
            ADID__c='hj',
            FederationIdentifier = '98iko4565'
        );
        insert NewUser;
        Account a = DS_TestObjects.NewAccount_Inserted(); // inserted
        
        Task t = DS_TestObjects.NewTask();                // not inserted
        Event e = DS_TestObjects.NewEvent();              // not inserted
        
        Task lt = DS_TestObjects.NewTask();               // not inserted
        Event le = DS_TestObjects.NewEvent();             // not inserted
        
        Contact c = DS_TestObjects.NewContact();          // not inserted
        //c.Role__c = 'Test Role'; // 9/29
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordType = [select id from recordtype where name = 'Customer Contact' and SobjectType='Contact'][0];
        Lead l = DS_TestObjects.NewLead();                // not inserted
        Opportunity o = DS_TestObjects.NewOpportunity();  // not inserted
        
        c.AccountId = a.Id;
        l.Current_Account__c = a.Id;
        
        o.AccountId = a.Id;
        
        system.debug(c); system.debug(l); system.debug(o);
        system.runAs(CurrentUser) { insert c; insert l; insert o; }
        
        t.OwnerId = NewUser.Id;
        t.WhatId = a.Id;
        t.WhoId = c.Id;
        
        e.OwnerId = NewUser.Id;
        e.WhatId = a.Id;
        e.WhoId = c.Id;
        
        lt.OwnerId = NewUser.Id;
        lt.WhoId = l.Id;
        
        // 10/3/2014 SivaP
        lt.ActivityDate = Date.today() - 1;
        lt.Status = 'Completed';
        
        le.OwnerId = NewUser.Id;
        le.WhoId = l.Id;
        
        system.runas(CurrentUser) 
        { 
            insert t; system.debug(t);
            insert e; system.debug(e);
            insert lt; system.debug(lt);
            insert le; system.debug(le);
        }
        
        system.debug(t.Owner.Title);
        
        t = [Select ID, Subject, Status, ActivityDate, OwnerId, Owner.Title, WhatId, WhoId, AccountId From Task Where ID=:t.Id];
        
        system.debug(t.Owner.Title);
        
        Boolean SettingsContainsISR = false;
        String SettingsISRGroup = '';
        
        for(ActivityHistorySettings__c setting : settings) 
        {
            system.debug(setting);
            
            if(setting.Type__c.trim().toLowerCase().startsWith('isr')) 
            {
                SettingsContainsISR = true; 
                
                try
                {
                    SettingsISRGroup = setting.Type__c.trim().substring(setting.Type__c.indexof(' ')+1,setting.Type__c.length());
                } catch(Exception ex) { system.debug(ex); SettingsISRGroup = 'G1'; } 
            } 
        }
        
        if(SettingsContainsISR) { NewUser.Title = 'ISR'; NewUser.ISR_Group__c = SettingsISRGroup; }
        else { if(settings.size() > 0) { NewUser.Title = settings[0].Type__c; } }
        
        update NewUser;
        
        List<Last_Activity__c> LastActivityList = new List<Last_Activity__c>();
        
        // Last Activity to test update case
        Last_Activity__c la1 = new Last_Activity__c(Related_To__c=a.Id,Account__c=a.Id, Channel_Name__c='TEST'); // 10/1/2014 SivaP
        LastActivityList.add(la1);
        
        // one extra to cover delete case
        Last_Activity__c la2 = new Last_Activity__c(Related_To__c=a.Id,Account__c=a.Id, Channel_Name__c='WEST'); // 10/1/2014 SivaP
        LastActivityList.add(la2);
        
        // Lead Last Activity to test WhoId case
        Last_Activity__c la3 = new Last_Activity__c(Related_To__c=a.Id,Lead__c=l.Id, Channel_Name__c='NEST'); // 10/1/2014 SivaP
        LastActivityList.add(la3);
        
        // Opportunity Last Activity to test non-Account WhatId case
        Last_Activity__c la4 = new Last_Activity__c(Related_To__c=a.Id,Opportunity__c=o.Id, Channel_Name__c='BEST'); // 10/1/2014 SivaP
        LastActivityList.add(la4);
        
        String ah_Owner_Title = '';
        
        if(NewUser.Title == 'ISR') 
        {
            ah_Owner_Title = NewUser.Title + ' ' + NewUser.ISR_Group__c;
        }
        else
        {
            ah_Owner_Title = NewUser.Title;
        }
        
        // for(Last_Activity__c la : LastActivityList) { la.Channel_Name__c = ah_Owner_Title; } // 10/2 SivaP
        
        if(ah_Owner_Title != null && !string.isEmpty(ah_Owner_Title)) // 10/1/2014 SivaP
        {
            ah_Owner_Title = ah_Owner_Title.trim().toLowerCase();
        }
        
        for(Last_Activity__c la : LastActivityList)
        {
            system.debug('TEST LAST ACTIVITY: '+la);
            system.debug('TEST ACTIVITY HISTORY OWNER: '+ah_Owner_Title);
            system.debug('TEST ACTIVITY HISTORY SETTINGS CONTAINSKEY: '+ActivityHistorySettings.containsKey(ah_Owner_Title));
            
            if(ActivityHistorySettings.containsKey(ah_Owner_Title))
            {
                //la.put(ActivityHistorySettings.get(ah_Owner_Title).User_Field__c,u.Id);
                //la.put(ActivityHistorySettings.get(ah_Owner_Title).Date_Field__c,Date.today().addYears(-10));
                
                la.put('Activity_By__c',NewUser.Id);
                la.put('Activity_Date__c',Date.today().addYears(-10));
                
                system.debug(la);
            }
        }
        
        system.runas(CurrentUser) { insert LastActivityList; }
        
        DS_Account_LastActivity LastActivityBatchClass = new DS_Account_LastActivity();
        
        //create the job settings  // 10/1/2014 - SivaP
        Job_Settings__c jobSetting = new Job_Settings__c();
        //jobSetting.Finish_Email__c = 'siva.pragada@adp.com';
        jobSetting.Last_Run__c = datetime.newInstance(2014, 10, 03, 12, 30, 30);
        jobSetting.Name='Record 1';
        //2015-11-24- anirudh.singh@cdk.com- Added the below two field values (Class_Name__c and Finish_Email__c).
        jobSetting.Class_Name__c='DS_Account_LastActivity';
        //2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
        jobSetting.Finish_Emails__c='anirudh.singh@cdk.com';
        insert jobSetting;        
        
        // change the job settings to include test data
        //Job_Settings__c jobSetting = Job_Settings__c.getValues('DS_Account_LastActivity'); // 10/1/2014 SivaP
        
        system.debug(jobSetting);
        
        if(jobSetting != null)
        {        
            jobSetting.Last_Run__c = DateTime.now().addDays(-7);
            update jobSetting;
        }
        
        LastActivityBatchClass.useLastRunConditions = false;
        LastActivityBatchClass.queryWhere = ' And Id = \'' + t.AccountId + '\'';
        
        String query = LastActivityBatchClass.b_start();
        
        List<sObject> scope = Database.query(query);
        
        for(sObject s : scope) { system.debug('sObject: ' + s); } 
        system.debug(scope);
        LastActivityBatchClass.b_execute(scope);
        
        Batch_Failure__c fail = new Batch_Failure__c(Source__c='DS_Account_LastActivity',Error_Message__c='Test failure',Error_Type__c='Test',Line_Number__c=123);
        insert fail;
        
        LastActivityBatchClass.b_finish();
        
        Test.startTest();
        
        LastActivityBatchClass.queryLimit = ' Limit 1 ';
        LastActivityBatchClass.queryWhere = ' And Id = \'' + a.Id + '\' ';
        LastActivityBatchClass.useLastRunConditions = true;
        ID BatchId = Database.executeBatch(LastActivityBatchClass,1);
        
        Test.stopTest();
    }
    
    @isTest(SeeAllData=True) // ActivityHistories requires seeAllData
    public static void TestActivityHistories()
    {
        Account a = DS_TestObjects.NewAccount_Inserted();
        User NewUser = DS_TestObjects.NewUser_Inserted();
        Task lt = new Task();
        
        
        lead leed = DS_TestObjects.NewLead_Inserted();
        leed.Status = 'Inactive';
        leed.Current_Account__c = a.Id;        
        update leed;
        
        lt.OwnerId = NewUser.Id;
        lt.WhoId = leed.Id;
        lt.ActivityDate = Date.today() - 1;
        lt.Status = 'Completed';
        insert lt;
        
        lead ld = [select Id, Name, (select Id From ActivityHistories) From Lead Where Id = :leed.Id];
        
        system.debug(ld.activityhistories); 
        system.debug(ld);
        
        DateTime NowMinusFive = DateTime.now() - 5;
        Event e = DS_TestObjects.NewEvent();
        e.OwnerId = NewUser.Id;
        e.WhatId = a.Id;        
        e.EndDateTime = DateTime.now() - 2;
        e.ActivityDateTime = NowMinusFive;
        e.StartDateTime = NowMinusFive;
        insert e;
        
        Test.startTest();
        
        DS_Account_LastActivity LastActivityBatchClass = new DS_Account_LastActivity();
        LastActivityBatchClass.queryLimit = ' Limit 1 ';
        LastActivityBatchClass.queryWhere = ' And Id = \'' + a.Id + '\' ';
        LastActivityBatchClass.useLastRunConditions = true;
        ID BatchId = Database.executeBatch(LastActivityBatchClass, 1);
        
        Test.stopTest();
    }
}