//Dated	                      Modified By								Description
//22nd September, 2015	  anirudh.singh@cdk.com		To upgrade the API Version FROM 28.0 to 34.0.
//2015-11-27              vishal.bandari@cdk.com    RQ-05289:changed SetupDashboardData to add contact record type
//2016-06-08              siva.pragada@cdk.com      added whatId in newPastTasks() and newPastEvents()
@IsTest
public class CB_AccountDashboard_Test
{
    public static testmethod List<String> getTeamRoles() { return new List<String> {'Test'}; }
    public static testmethod String getActivityType() { return 'Test'; }
    
    // SetupDashboardData returns AccountId
    public static testmethod Id SetupDashboardData()
    {
        // Current User
        User CurrentUser = DS_TestObjects.CurrentUser();
        
        // Settings
        Account_Dashboard_Settings__c Settings = new Account_Dashboard_Settings__c();
        List<Account_Dashboard_Activity_Team_Roles__c> ActivityTeamRoles = ActivityTeamRoles().values();
        insert ActivityTeamRoles;
        
        // Account
        Account a = DS_TestObjects.NewAccount_Inserted();
        
        // Product Mix (Monthly Maintenance)
        WebID__c wid = DS_TestObjects.NewWebID();
        wid.Account__c = a.Id;
        insert wid;
        
        //Account_Plan__c ap = new Account_Plan__c();
        //ap.Account__c = a.Id;
        //ap.WebID__c = wid.Id;
        //insert ap;
        
        //Monthly_Maintenance__c mm = new Monthly_Maintenance__c();
        //mm.Account__c = a.Id;
        //mm.WebID__c = wid.Id;
        //mm.Account_Plan__c = ap.Id; 
        //insert mm; 
        
        // WIP
        WIP_Order__c wip = new WIP_Order__c();
        wip.Name = 'Test Work In Progress';
        wip.Account__c = a.Id;
        insert wip; system.debug(wip);
        
        // Opportunity
        Opportunity o = DS_TestObjects.NewOpportunity();
        o.AccountId = a.Id;
        o.RecordTypeId = [Select Id From RecordType Where sObjectType = 'Opportunity' And Name = 'PIPELINE'].Id;
        system.runas(DS_TestObjects.CurrentUser()) { insert o; } system.debug(o);
        
        // Launch
        Launch__c l = new Launch__c();
        l.Account__c = a.Id;
        l.Status__c = 'In Progress'; 
        l.Order_Type__c = 'Downgrade'; 
        insert l; system.debug(l);
        
        // Contact
        Contact c = DS_TestObjects.NewContact();
        c.AccountId = a.Id; // default account relationship
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        Id contactRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        c.RecordTypeId = contactRecordTypeId;
        //c.Role__c = 'Test Role'; // 9/29
        insert c;
        
        Contact_Relationship__c cr = new Contact_Relationship__c();
        cr.Account__c = a.Id;
        cr.Contact__c = c.Id;
        cr.Role__c = 'Test Role';
        insert cr;
        
        // Default Case Team Member
        CaseTeamRole ctr = new CaseTeamRole(Name='TEST Case Team Member', AccessLevel='Edit');
        system.runas(DS_TestObjects.CurrentUser()) { insert ctr; }
        
        GlobalSettings__c gs = new GlobalSettings__c();
        gs.DefaultCaseTeamMemberId__c = ctr.Id;
        insert gs;
        
        // Cases
        List<Case> cases = new List<Case>();
        
        Case c1 = new Case(); c1.AccountId = a.Id;
        RecordType c1rt = [Select Id From RecordType Where sObjectType = 'Case' And Name = 'CANCELLATION' Limit 1]; 
        c1.RecordTypeId = c1rt != null ? c1rt.Id : null; c1.ContactId = c.Id;
        cases.add(c1);
        
        Case c2 = new Case(); c2.AccountId = a.Id; 
        RecordType c2rt = [Select Id From RecordType Where sObjectType = 'Case' And Name = 'SALES OPERATIONS' Limit 1];
        c2.RecordTypeId = c2rt != null ? c2rt.Id : null; c2.ContactId = c.Id;
        cases.add(c2);
        
        Case c3 = new Case(); c3.AccountId = a.Id; 
        RecordType c3rt = [Select Id From RecordType Where sObjectType = 'Case' And Name = 'IFS - CONTRACT ADMIN' Limit 1];
        c3.RecordTypeId = c3rt != null ? c3rt.Id : null; c3.ContactId = c.Id;
        c3.Type = 'Buy/Sell';
        cases.add(c3);
        
        Case c4 = new Case(); c4.AccountId = a.Id; 
        RecordType c4rt = [Select Id From RecordType Where sObjectType = 'Case' And Name = 'TIER 1' Limit 1];
        c4.RecordTypeId = c4rt != null ? c4rt.Id : null; c4.ContactId = c.Id;
        cases.add(c4);
        
        Case c5 = new Case(); c5.AccountId = a.Id; 
        RecordType c5rt = [Select Id From RecordType Where sObjectType = 'Case' And Name = 'TIER 2 - ETS' Limit 1];
        c5.RecordTypeId = c5rt != null ? c5rt.Id : null; c5.ContactId = c.Id;
        cases.add(c5);
        
        Case c6 = new Case(); c6.AccountId = a.Id; 
        RecordType c6rt = [Select Id From RecordType Where sObjectType = 'Case' And Name = 'TIER 2 - CONTENT' Limit 1];
        c6.RecordTypeId = c6rt != null ? c6rt.Id : null; c6.ContactId = c.Id;
        cases.add(c6);
        
        Case c7 = new Case(); c7.AccountId = a.Id; 
        RecordType c7rt = [Select Id From RecordType Where sObjectType = 'Case' And Name like '%ONBOARDING%' Limit 1];
        c7.RecordTypeId = c7rt != null ? c7rt.Id : null; c7.ContactId = c.Id;
        cases.add(c7);
        
        Case c8 = new Case(); c7.AccountId = a.Id; 
        RecordType c8rt = [Select Id From RecordType Where sObjectType = 'Case' And Name = 'IFS - DATA OPS' Limit 1];
        c8.RecordTypeId = c8rt != null ? c8rt.Id : null; c8.ContactId = c.Id;
        cases.add(c8);
        
        system.runas(DS_TestObjects.CurrentUser()) { insert cases; }
        
        // Account Team Members
        Account_Team__c atm = new Account_Team__c();
        atm.Account__c = a.Id; 
        atm.Team_Role__c = ActivityTeamRoles.get(0).Name;
        atm.Team_Member__c = UserInfo.getUserId();
        insert atm;
        
        // Task
        List<Task> tasks = new List<Task>(); tasks.addAll(NewPastTasks()); tasks.addAll(NewFutureTasks());
        for(Task t : tasks) { t.WhatId = a.Id; t.WhoId = c.Id; }
        system.runas(DS_TestObjects.CurrentUser()) { insert tasks; }
        
        // Event
        List<Event> events = new List<Event>(); events.addAll(NewPastEvents()); events.addAll(NewFutureEvents());
        for(Event e : events) { e.WhatId = a.Id; e.WhoId = c.Id; }
        system.runas(DS_TestObjects.CurrentUser()) { insert events; }
        
        // return Account Id
        return a.Id;
    }
    
    public static testmethod Map<String, Account_Dashboard_Activity_Team_Roles__c> ActivityTeamRoles()
    {
        Map<String, Account_Dashboard_Activity_Team_Roles__c> ActivityTeamRoles 
            = new Map<String, Account_Dashboard_Activity_Team_Roles__c>();
        
        for(String TeamRoleName : getTeamRoles()) 
        {
            ActivityTeamRoles.put(TeamRoleName, 
                                  new Account_Dashboard_Activity_Team_Roles__c(
                                      Name = TeamRoleName, 
                                      Activity_Record_Type__c = 'Test', 
                                      User_Title__c = 'Test'
                                  )
                                 );
        }
        
        return ActivityTeamRoles;
    }
    
    public static testmethod List<Task> NewPastTasks()
    {
        List<Task> tasks = new List<Task>();
        
        TaskStatus ClosedStatus = [Select MasterLabel, IsClosed From TaskStatus Where IsClosed = true limit 1];
        Account acc = DS_TestObjects.NewAccount_Inserted();
        Task ClosedTask = new Task();
        ClosedTask.Type = getActivityType(); 
        ClosedTask.ActivityDate = Date.Today().addDays(-2); 
        ClosedTask.Status = ClosedStatus.MasterLabel;
        ClosedTask.WhatId = acc.ID;
        tasks.add(ClosedTask);
        
        return tasks;
    }
    
    public static testmethod List<Task> NewFutureTasks()
    {
        List<Task> tasks = new List<Task>();
        
        TaskStatus OpenStatus = [Select MasterLabel, IsClosed From TaskStatus Where IsClosed = false limit 1];
        
        Task OpenTask = new Task(); // this is a Next Activity
        OpenTask.Type = getActivityType(); OpenTask.ActivityDate = Date.Today().addDays(2); OpenTask.Status = OpenStatus.MasterLabel;
        tasks.add(OpenTask);
        
        return tasks;
    }
    
    public static testmethod List<Event> NewPastEvents()
    {
        List<Event> events = new List<Event>();
        Account acc = DS_TestObjects.NewAccount_Inserted();
        
        DateTime PastDateTime = DateTime.Now().addDays(-2);
        Event PastEvent = new Event();
        PastEvent.Type = getActivityType(); 
        PastEvent.ActivityDate = PastDateTime.date(); 
        PastEvent.ActivityDateTime = PastDateTime;
        PastEvent.StartDateTime = PastDateTime; 
        PastEvent.EndDateTime = PastDateTime.addMinutes(30); 
        PastEvent.DurationInMinutes = 30;
        PastEvent.WhatId = acc.ID;
        events.add(PastEvent);
        
        return events;
    }
    
    public static testmethod List<Event> NewFutureEvents()
    {
        List<Event> events = new List<Event>();
        
        DateTime FutureDateTime = DateTime.Now().addDays(2);
        Event FutureEvent = new Event();
        FutureEvent.Type = getActivityType(); 
        FutureEvent.ActivityDate = FutureDateTime.date(); 
        FutureEvent.ActivityDateTime = FutureDateTime;
        FutureEvent.StartDateTime = FutureDateTime; 
        FutureEvent.EndDateTime = FutureDateTime.addMinutes(30); 
        FutureEvent.DurationInMinutes = 30;
        events.add(FutureEvent);
        
        return events;
    }
    
    public static testmethod void Properties()
    {
        CB_AccountDashboard ad = new CB_AccountDashboard();
        
        Account_Dashboard_Settings__c settings = ad.getSettings();
        Account a = ad.getAccount();
        List<Monthly_Maintenance__c> mms = ad.getProductMix();
        List<CB_AccountDashboard.CustomActivity> activities = ad.getCustomActivities();
    }
    
    public static testmethod void Initialize()
    {
        // test without Account Id
        CB_AccountDashboard AccountDashboardWithoutAccount = new CB_AccountDashboard();
    }
    
    public static testmethod void InitializeWithInvalidAccountId()
    {
        // test with invalid Account Id
        PageReference pg = Page.CB_AccountDashboard;
        pg.getParameters().put('id', 'abc');
        Test.setCurrentPage(pg);
        Test.startTest();
        
        CB_AccountDashboard AccountDashboardWithInvalidAccount = new CB_AccountDashboard();
        
        Test.stopTest();
    }
    
    public static testmethod void InitializeWithData()
    {
        // setup data
        Id AccountId = SetupDashboardData();
        // setup test page
        PageReference pg = Page.CB_AccountDashboard;
        pg.getParameters().put('id', AccountId);
        Test.setCurrentPage(pg);
        list<Contact_Relationship__c> crList = [Select Id, Name From Contact_Relationship__c];
        system.debug(crList.size());
        Test.startTest();
        
        // test with Account Id
        CB_AccountDashboard AccountDashboard = new CB_AccountDashboard(AccountId);
        
        Test.stopTest();
    }
    
    public static testmethod CB_AccountDashboard.CustomActivity InstantiateCustomActivity()
    {
        CB_AccountDashboard.CustomActivity ca = new CB_AccountDashboard.CustomActivity();
        
        ca.ActivityId = '00T000000123456';
        ca.Subject = 'Test';
        ca.ContactName = 'Contact';
        ca.ContactId = '003000000123456';
        ca.Description = 'Description';
        ca.IsClosed = true;
        ca.ActivityType = 'Test';
        ca.ActivityDate = Date.today();
        ca.ActivityEndDateTime = DateTime.now(); 
        ca.ActivityRecordTypeName = 'Test';
        ca.OwnerName = 'Owner';
        ca.OwnerId = '005000000123456';
        ca.OwnerTeamRole = 'Test';
        ca.OwnerIsActive = true;
        ca.OwnerTitle = 'Test';
        ca.NextActivityId = '00T000000123457';
        ca.NextActivitySubject = 'Test';
        ca.NextActivityDate = Date.today().addDays(1);
        
        return ca;
    }
    
    public static testmethod CB_AccountDashboard.FilterMaps InstantiateFilterMaps()
    {
        CB_AccountDashboard.FilterMaps fm = new CB_AccountDashboard.FilterMaps();
        return fm;
    }
    
    public static testmethod void AddFilteredActivity()
    {
        CB_AccountDashboard ad = new CB_AccountDashboard();
        CB_AccountDashboard.FilterMaps fm = InstantiateFilterMaps();
        CB_AccountDashboard.CustomActivity ca = InstantiateCustomActivity();
        
        fm = ad.AddFilteredActivity(fm, ca);
        
        List<String> keyList = new List<String>();
        keyList.addAll(fm.FilteredActivitiesByKey.keyset());
        
        ad.AddFilteredActivity(fm, ca, keyList[0]);
    }
    
    public static testmethod void LogCustomActivity()
    {
        CB_AccountDashboard ad = new CB_AccountDashboard();
        CB_AccountDashboard.CustomActivity ca = InstantiateCustomActivity();
        
        ad.LogCustomActivity(ca, true);
    }
    
    public static testmethod void BuildCustomActivity()
    {
        CB_AccountDashboard ad = new CB_AccountDashboard();
        
        sObject t = new Task();
        ad.BuildCustomActivity(t, 'Test', 'Test', false, 'Test', 'Task');
    }
    
    public static testmethod void AccountTeamRole() 
    {
        CB_AccountDashboard ad = new CB_AccountDashboard();
        ad.AccountTeamRole(null, null); // test null case
        ad.AccountTeamRole('005000000123456', new Map<Id, Account_Team__c> { // test with (fake) data
            '005000000123456' => new Account_Team__c() }); 
    }
    
    public static testmethod void FilterActivities()
    {
        // build data to filter
        Id TestUserId    = '0050000000000T1AAA';
        Id TestAccountId = '0010000000000A1AAA';
        Id TestContactId = '0030000000000C1AAA';
        
        // team roles
        Map<String, Account_Dashboard_Activity_Team_Roles__c> ActivityTeamRoles = ActivityTeamRoles();
        
        // account team
        List<Account_Team__c> AccountTeam = new List<Account_Team__c>();
        Account_Team__c atm1 = new Account_Team__c();
        atm1.Team_Member__c = TestUserId;
        atm1.Team_Role__c = ActivityTeamRoles.values()[0].Name;
        atm1.putSObject('Team_Member__r', new User(FirstName = 'Test', LastName = 'User', Title = ActivityTeamRoles.values()[0].User_Title__c));
        AccountTeam.add(atm1);
        
        // histories
        Map<String, List<sObject>> Histories = new Map<String, List<sObject>>();
        List<Task> Tasks = NewPastTasks(); insert Tasks; for(Task t : Tasks) { t.OwnerId = TestUserId; } Histories.put('Task', Tasks);
        List<Event> Events = NewPastEvents(); insert Events; for(Event e : Events) { e.OwnerId = TestUserId; } Histories.put('Event', Events);
        
        // instantiate class
        CB_AccountDashboard ad = new CB_AccountDashboard();
        
        // filter
        ad.FilterActivities(Histories, AccountTeam, ActivityTeamRoles);
    }
    
    public static testmethod void AddNextActivity()
    {
        // set a common user id as the owner id
        Id TestUserId    = '0050000000000T1AAA';
        
        // get list of custom activities
        CB_AccountDashboard.CustomActivity ca = InstantiateCustomActivity();
        ca.OwnerId = TestUserId;
        List<CB_AccountDashboard.CustomActivity> CustomActivities = new List<CB_AccountDashboard.CustomActivity> { ca };
                
        // build map of open activities
        Map<String, List<sObject>> OpenActivities = new Map<String, List<sObject>>();
        List<Task> Tasks = NewFutureTasks(); for(Task t : Tasks) { t.OwnerId = TestUserId; } OpenActivities.put('Task', Tasks);
        List<Event> Events = NewFutureEvents(); for(Event e : Events) { e.OwnerId = TestUserId; } OpenActivities.put('Event', Events);
        
        // instantiate class
        CB_AccountDashboard ad = new CB_AccountDashboard();
        
        // add next activities
        ad.AddNextActivities(CustomActivities, OpenActivities);
    }
    
}