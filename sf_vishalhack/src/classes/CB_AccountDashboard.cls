/*
    // Account Dashboard Controller
    // Purpose: To display a summary of Account data for the Cobalt Service organization.
    // Programmer: Matt Keefe (matt.keefe@adp.com)
    // ----------------------------------------------------------------------------------
    
    // Test Code
    CB_AccountDashboard ad = new CB_AccountDashboard('0014000000Jvw9X');
    List<Account_Team__c> retired = ad.QueryRetiredWebIdUsers('0014000000Jvw9X', ad.ActivityTeamRoles);
    
    system.debug(retired);
    for(Account_Team__c atm : retired) { system.debug(atm); }
    
    // Tasks Query Test 
    List<Task> tsks = [
        Select Id, OwnerId, Owner.IsActive 
        From Task 
        Where (NOT What.Name LIKE 'MM%') 
        And (NOT What.Name LIKE '0%') 
        And (NOT What.Name LIKE 'gmps%') 
        And Owner.IsActive  = false 
        // And Owner.Name like '%retired' // do not use retired (only check for inactive)
        And WhatId != null 
        And (Owner.Title = 'SEO Specialist' or Owner.Title like 'Account%') 
        limit 10];
    for(Task t : tsks) { system.debug(t); }
*/

public class CB_AccountDashboard
{
    // -- Variables
    
    private Account_Dashboard_Settings__c Settings;
    Map<String, Account_Dashboard_Activity_Team_Roles__c> ActivityTeamRoles;
    
    private Id AccountId;
    private Account DashboardAccount;
    private List<Monthly_Maintenance__c> ProductMix;
    private List<CustomActivity> CustomActivities;
    
    // -- Properties
    
    public Account_Dashboard_Settings__c getSettings() { return Settings; }
    public Account getAccount() { return DashboardAccount; }
    //public Account getCorporationOrGroup() { return DashboardAccount; }
    public List<Monthly_Maintenance__c> getProductMix() { return ProductMix; }
    public List<CustomActivity> getCustomActivities() { return CustomActivities; }
    
    public Integer WIPOrders                { get { return WIPOrders == null                ? 0 : WIPOrders; }                set; }
    public Integer OpenOpportunities        { get { return OpenOpportunities == null        ? 0 : OpenOpportunities; }        set; }
    public Integer PendingCancellationCases { get { return PendingCancellationCases == null ? 0 : PendingCancellationCases; } set; }
    public Integer PendingDowngradeCases    { get { return PendingDowngradeCases == null    ? 0 : PendingDowngradeCases; }    set; }
    public Integer OpenBuySellCases         { get { return OpenBuySellCases == null         ? 0 : OpenBuySellCases; }         set; }
    public Integer OpenTechSupportCases     { get { return OpenTechSupportCases == null     ? 0 : OpenTechSupportCases; }     set; }
    public Integer OpenContentCases         { get { return OpenContentCases == null         ? 0 : OpenContentCases; }         set; }
    public Integer OpenOnboardingCases      { get { return OpenOnboardingCases == null      ? 0 : OpenOnboardingCases; }      set; }
    public Integer OpenIFSDataOpsCases      { get { return OpenIFSDataOpsCases == null      ? 0 : OpenIFSDataOpsCases; }      set; }
    public Integer OpenCases                { get { return OpenCases == null                ? 0 : OpenCases; }                set; }
    
    // -- Constructors
    
    public CB_AccountDashboard() { AccountId = null; Initialize(); }
    public CB_AccountDashboard(Id aid) { AccountId = aid; Initialize(); }
    
    // -- methods
    
    public void Initialize()
    {
        Settings = Account_Dashboard_Settings__c.getInstance();
        ActivityTeamRoles = Account_Dashboard_Activity_Team_Roles__c.getAll(); 
        
        system.debug(Settings);
        system.debug(ActivityTeamRoles);
        
        String AccountIdString = ApexPages.currentPage() != null ? ApexPages.currentPage().getParameters().get('id') : '';
        
        if(AccountIdString != null) { 
            try { AccountId = (Id)AccountIdString; } 
            catch (Exception exc) { system.debug(exc); } 
        }
        
        if(AccountId != null)
        {
            DashboardAccount = QueryDashboardAccount(AccountId);
            
            if(DashboardAccount != null && DashboardAccount.Id != null)
            {
                List<WIP_Order__c> WIPs = QueryWIPs(DashboardAccount.Id);
                List<Opportunity> Opportunities = QueryOpportunities(DashboardAccount.Id);
                List<Launch__c> Launches = QueryLaunches(DashboardAccount.Id);
                List<Case> Cases = QueryCases(DashboardAccount.Id); //system.debug(Cases);
                
                AddUpAlerts(WIPs, Opportunities, Launches, Cases);
                
                //ProductMix = QueryProductMix(DashboardAccount.Id);
                
                Map<String, List<sObject>> ActivityHistoriesByType = QueryTasksAndEvents(DashboardAccount.Id, false);
                //Map<String, List<sObject>> ActivityHistoriesByType = QueryActivities(DashboardAccount.Id, false);
                for(List<sObject> Activities : ActivityHistoriesByType.values()) { for(sObject ah : Activities) { system.debug(ah); } }
                
                Map<String, List<sObject>> OpenActivitiesByType = QueryTasksAndEvents(DashboardAccount.Id, true);
                //Map<String, List<sObject>> OpenActivitiesByType = QueryActivities(DashboardAccount.Id, true);
                for(List<sObject> Activities : OpenActivitiesByType.values()) { for(sObject oa : Activities) { system.debug(oa); } }
                
                List<Account_Team__c> AccountTeam = QueryAccountTeam(DashboardAccount.Id, ActivityTeamRoles.keyset());
                
                //Map<String, List<sObject>> TasksAndEvents = QueryTasksAndEvents(DashboardAccount.Id, false);
                //List<sObject> AllTasksAndEvents = new List<sObject>(); for(List<sObject> l : TasksAndEvents.values()) { AllTasksAndEvents.addAll(l); }
                //for(sObject te : AllTasksAndEvents) { system.debug(te); }
                
                CustomActivities = FilterActivities(ActivityHistoriesByType, AccountTeam, ActivityTeamRoles);
                CustomActivities = AddNextActivities(CustomActivities, OpenActivitiesByType);
            }
        }
    }
    
    public void AddUpAlerts(List<WIP_Order__c> WIPs, List<Opportunity> Opportunities, List<Launch__c> Launches, LIst<Case> Cases)
    {
        WIPOrders += WIPs.size();
        OpenOpportunities += Opportunities.size();
        PendingDowngradeCases += Launches.size();
        
        for(Case c : Cases)
        {
            String CaseRecordTypeName = c.RecordType.Name.ToUpperCase();
            
            //system.debug(c.IsClosed);
            //system.debug(CaseRecordTypeName);
            
            if(c.IsClosed == false && CaseRecordTypeName == 'CANCELLATION') { PendingCancellationCases += 1; }
            if(c.IsClosed == false && CaseRecordTypeName == 'SALES OPERATIONS') { PendingDowngradeCases += 1; }
            if(c.IsClosed == false && CaseRecordTypeName == 'IFS - CONTRACT ADMIN' && c.Type.contains('Buy/Sell')) { OpenBuySellCases += 1; }
            if(c.IsClosed == false && (CaseRecordTypeName == 'TIER 1' || CaseRecordTypeName == 'TIER 2 - ETS')) { OpenTechSupportCases += 1; }
            if(c.IsClosed == false && CaseRecordTypeName == 'TIER 2 - CONTENT') { OpenContentCases += 1; } 
            if(c.IsClosed == false && CaseRecordTypeName.contains('ONBOARDING')) { OpenOnboardingCases += 1; }
            if(c.IsClosed == false && CaseRecordTypeName == 'IFS - DATA OPS') { OpenIFSDataOpsCases += 1; }
            if(c.IsClosed == false) { OpenCases += 1; }
        }
    }
    
    // -- database methods
    
    public Account QueryDashboardAccount(Id AccountId) 
    {
        List<Account> Accounts = [
            Select Id, Name, 
                Account_Number__c, Corporation__c, Corporation__r.Name, Group__c, Group__r.Name, 
                Dealer_Group_Name2__c, LDP__c, VIP__c, ES_High_Profile__c, Do_Not_Sell__c, Critical_Note__c
            From Account 
            Where Id = :AccountId
            Limit 1
        ];
        
        if(Accounts != null && !Accounts.IsEmpty()) { return Accounts.get(0); } else { return null; }
    }
    
    /*
    public List<Monthly_Maintenance__c> QueryProductMix(Id AccountId)
    {
        if(AccountId == null) { return new List<Monthly_Maintenance__c>(); }
        
        return [
            Select Id, Name, WebID__c, Type__c // ("Product Mix" = Type__c) 
            From Monthly_Maintenance__c 
            Where Account__c = :AccountId
            Limit 1
        ];
    }
    */
    
    public List<WIP_Order__c> QueryWIPs(Id AccountId)
    {
        if(AccountId == null) { return new List<WIP_Order__c>(); }
        return [Select Id From WIP_Order__c Where Account__c = :AccountId];
    }
    
    public List<Opportunity> QueryOpportunities(Id AccountId) 
    {
        if(AccountId == null) { return new List<Opportunity>(); }
        
        return [
            Select Id From Opportunity 
            Where AccountId = :AccountId 
            And IsClosed = false 
            And RecordType.Name = 'PIPELINE' 
            And ADP_Opportunity_Owner__r.Title = 'DSM'
        ];
    }
    
    public List<Launch__c> QueryLaunches(Id AccountId)
    {
        if(AccountId == null) { return new List<Launch__c>(); }
        
        return [
            Select Id From Launch__c 
            Where Account__c = :AccountId 
            And Open_Status__c = 'OPEN' 
            And Order_Type__c = 'DOWNGRADE' 
        ];
    }
    
    public List<Case> QueryCases(Id AccountId) 
    {    
        if(AccountId == null) { return new List<Case>(); }
        
        return [
            Select Id, IsClosed, RecordType.Name, AccountId, Type From Case 
            Where AccountId = :AccountId
        ];
    }
    
    public List<Account_Team__c> QueryAccountTeam(Id AccountId, Set<String> TeamRoleSet)
    {
        List<String> TeamRoles = new List<String>(); 
        TeamRoles.addAll(TeamRoleSet);
        
        if(AccountId == null) { return new List<Account_Team__c>(); }
        
        List<Account_Team__c> AccountTeamMembers = new List<Account_Team__c>();
        
        if(!TeamRoles.IsEmpty())
        {
            String q = ''
                + 'Select Id, Account__c, Team_Member__c, Team_Member__r.Name, Team_Role__c '
                + 'From Account_Team__c '
                + 'Where Account__c = ' + '\'' + AccountId + '\' '
                + 'And Team_Role__c' + (TeamRoles.size() > 1 ? 
                    ' IN ' + ALL_UtilitiesString.ListToParenthesesCsv(TeamRoles) : 
                    ' = \'' + TeamRoles[0] + '\'');
        
            system.debug(q);
            try { AccountTeamMembers = database.query(q); } catch (Exception exc) { system.debug(exc); }
        }
        
        return AccountTeamMembers;
    }
    
    public Map<String, List<sObject>> QueryTasksAndEvents(Id AccountId, Boolean Open) 
    {
        // Invalid Activity Types to exclude from query results
        List<String> ActivityTypes = new List<String>{'Email','Left Message','Reminder','Internal'};
        
        // return object
        Map<String, List<sObject>> TasksAndEvents = new Map<String, List<sObject>>();
        
        // validation
        if(AccountId == null) { return TasksAndEvents; }
        
        String tq = ''
            + 'Select '
                + 'Id, '
                + 'IsClosed, '
                + 'Subject, ' /* Task/Event Name */
                + 'OwnerId, ' /* Assigned To Id */
                + 'Owner.Name, ' /* Assigned To */
                + 'Owner.Title, ' /* Assigned To Title */
                + 'Owner.IsActive, ' /* Assigned To IsActive */
                + 'Who.Name, ' /* Contact Name */
                + 'Description, ' /* Comments */
                + 'ActivityDate, ' /* Date */
                + 'RecordTypeId, '
                + 'RecordType.Name, '
                + 'Type '
            + 'From Task '
            + 'Where (AccountId = \''+AccountId+'\' Or WhatId = \''+AccountId+'\') '
            + 'And Who.Name != NULL '
            + 'And (Not Type IN ' + ALL_UtilitiesString.ListToParenthesesCsv(ActivityTypes) + ') '
            + (Open == true ? 'And IsClosed = false ' : 'And IsClosed = true ');
        
        system.debug(tq);
        List<sObject> Tasks = database.query(tq);
        if(!Tasks.IsEmpty()) { TasksAndEvents.put('Task', Tasks); }
        
        String eq = '' 
            + 'Select '
                + 'Id, '
                + 'Subject, ' /* Task/Event Name */
                + 'OwnerId, ' /* Assigned To Id */
                + 'Owner.Name, ' /* Assigned To */
                + 'Owner.Title, ' /* Assigned To Title */
                + 'Owner.IsActive, ' /* Assigned To IsActive */
                + 'Who.Name, ' /* Contact Name */
                + 'Description, ' /* Comments */
                + 'ActivityDate, ' /* Date */
                + 'EndDateTime, '
                + 'RecordTypeId, '
                + 'RecordType.Name, '
                + 'Type '
            + 'From Event '
            + 'Where (AccountId = \''+AccountId+'\' Or WhatId = \''+AccountId+'\') '
            + 'And Who.Name != NULL '
            + 'And (Not Type IN ' + ALL_UtilitiesString.ListToParenthesesCsv(ActivityTypes) + ') '
            + (Open == true ? 'And ActivityDate >= TODAY ' : 'And ActivityDate < TODAY ');
        
        system.debug(eq);
        List<sObject> Events = Database.query(eq);
        if(!Events.IsEmpty()) { TasksAndEvents.put('Event', Events); }
        
        // NOTE: Tasks and Events older than a year are archived (and not queryable) in Salesforce
        // To retrieve these records, the ActivityHistories relationship of the Account needs to be
        // queried and those Tasks & Events merged with the results. -MK 2013-08-13 
        return TasksAndEvents;
    }
    
    // -- other classes and methods
    
    public class CustomActivity
    {
        public String ActivityId { get; set; }
        public String Subject { get; set; }
        public String ContactName { get; set; }
        public String ContactId { get; set; }
        public String Description { get; set; }
        public Boolean IsClosed { get; set; }
        public String ActivityType { get; set; }
        public String ActivityObjectType { get; set; }
        public Date ActivityDate { get; set; }
        public DateTime ActivityEndDateTime { get; set; } 
        public String ActivityRecordTypeName { get; set; }
        
        public String OwnerName { get; set; }
        public Id OwnerId { get; set; }
        public String OwnerTeamRole { get; set; }
        public Boolean OwnerIsActive { get; set; }
        public Boolean OwnerIsOnAccountTeam { get; set; }
        public String OwnerTitle { get; set; }
        
        public String NextActivityId { get; set; }
        public String NextActivitySubject { get; set; }
        public Date NextActivityDate { get; set; }
    }
    
    public class FilterMaps
    {
        public Map<String, String> ActivityIdsByAccountTeamRole;
        public Map<String, String> ActivityIdsByRecordType;
        public Map<String, String> ActivityIdsByOwnerTitle;
        
        public Map<String, CustomActivity> FilteredActivitiesByKey;
        
        public FilterMaps() { 
            ActivityIdsByAccountTeamRole = new Map<String, String>();
            ActivityIdsByRecordType = new Map<String, String>();
            ActivityIdsByOwnerTitle = new Map<String, String>();
            
            FilteredActivitiesByKey = new Map<String, CustomActivity>();
        }
    }
    
    public FilterMaps AddFilteredActivity(FilterMaps fm, CustomActivity ca) { return AddFilteredActivity(fm,ca,null); }
    public FilterMaps AddFilteredActivity(FilterMaps fm, CustomActivity ca, String RemoveKey)
    {
        if(RemoveKey != null) {
            system.debug('REMOVING - ' + RemoveKey);
            fm.FilteredActivitiesByKey.remove(RemoveKey);
        }
        
        system.debug('ADDING - ' + ca.ActivityId);
        fm.FilteredActivitiesByKey.put(ca.ActivityId, ca);
        
        if(ca.OwnerTeamRole != null) { fm.ActivityIdsByAccountTeamRole.put(ca.OwnerTeamRole, ca.ActivityId); }
        if(ca.ActivityRecordTypeName != null) { fm.ActivityIdsByRecordType.put(ca.ActivityRecordTypeName, ca.ActivityId); }
        if(ca.OwnerTitle != null) { fm.ActivityIdsByOwnerTitle.put(ca.OwnerTitle, ca.ActivityId); }
        
        return fm;
    }
    
    public void LogCustomActivity(CustomActivity ca, Boolean header) 
    {
        if(header) {
            system.debug('ActivityId,Subject,OwnerName,IsClosed,ActivityEndDateTime,ActivityDate,OwnerTeamRole,ActivityRecordTypeName,OwnerTitle'); 
        }
        
        system.debug(
            ca.ActivityId + ',' + 
            ca.Subject + ',' + 
            ca.OwnerName + ',' + 
            ca.IsClosed + ',' + 
            ca.ActivityEndDateTime + ',' + 
            ca.ActivityDate + ',' +
            ca.OwnerTeamRole + ',' + 
            ca.ActivityRecordTypeName + ',' + 
            ca.OwnerTitle
        );
    }
    
    public CustomActivity BuildCustomActivity(sObject s, String TeamRole, String ActivityOwnerTitle, Boolean OwnerIsOnAccountTeam, String ActivityRecordTypeName, String TaskOrEvent)
    {
        CustomActivity ca = new CustomActivity();
        
        ca.ActivityId = s.Id;
        ca.Subject = (String) ALL_UtilitiesData.GetDataFromNestedFields('Subject', s);
        ca.ContactName = (String) ALL_UtilitiesData.GetDataFromNestedFields('Who.Name', s);
        ca.ContactId = (Id) ALL_UtilitiesData.GetDataFromNestedFields('WhoId', s);
        ca.Description = (String) ALL_UtilitiesData.GetDataFromNestedFields('Description', s);
        ca.IsClosed = TaskOrEvent == 'Task' ? (Boolean) ALL_UtilitiesData.GetDataFromNestedFields('IsClosed', s) : null;
        ca.ActivityType = (String) ALL_UtilitiesData.GetDataFromNestedFields('Type', s);
        ca.ActivityObjectType = TaskOrEvent;
        ca.ActivityDate = (Date) ALL_UtilitiesData.GetDataFromNestedFields('ActivityDate', s);
        ca.ActivityEndDateTime = TaskOrEvent == 'Event' ? (DateTime) ALL_UtilitiesData.GetDataFromNestedFields('EndDateTime', s) : null;
        ca.OwnerId = (Id) ALL_UtilitiesData.GetDataFromNestedFields('OwnerId', s);
        ca.OwnerName = (String) ALL_UtilitiesData.GetDataFromNestedFields('Owner.Name', s);
        ca.OwnerIsActive = (Boolean) ALL_UtilitiesData.GetDataFromNestedFields('Owner.IsActive', s);
        ca.OwnerIsOnAccountTeam = OwnerIsOnAccountTeam;
        ca.OwnerTeamRole = TeamRole;
        ca.OwnerTitle = ActivityOwnerTitle;
        ca.ActivityRecordTypeName = ActivityRecordTypeName;
        
        return ca;
    }
    
    public String AccountTeamRole(Id OwnerId, Map<Id, Account_Team__c> AccountTeamById)
    {
        if(OwnerId != null && AccountTeamById != null && AccountTeamById.get(OwnerId) != null) { 
            return AccountTeamById.get(OwnerId).Team_Role__c; }
        
        return null;
    }
    
    public List<CustomActivity> FilterActivities(Map<String, List<sObject>> Histories, List<Account_Team__c> AccountTeam, 
        Map<String, Account_Dashboard_Activity_Team_Roles__c> ActivityTeamRoles)
    {
        // by using a Map, the Activities are automatically filtered by the key (in this case, Account Team Member Id)
        Map<Id, Account_Team__c> AccountTeamById = new Map<Id, Account_Team__c>(); 
        for(Account_Team__c atm : AccountTeam) { AccountTeamById.put(atm.Team_Member__c, atm); system.debug(atm.Team_Member__r.Name); }
        
        FilterMaps fm = new FilterMaps();
        
        // put together valid keys
        Map<String, Account_Dashboard_Activity_Team_Roles__c> ActivityRecordTypeMap = new Map<String, Account_Dashboard_Activity_Team_Roles__c>();
        Map<String, Account_Dashboard_Activity_Team_Roles__c> UserTitleMap = new Map<String, Account_Dashboard_Activity_Team_Roles__c>();
        for(Account_Dashboard_Activity_Team_Roles__c atr : ActivityTeamRoles.values()) 
        {
            if(atr.Activity_Record_Type__c != null) { ActivityRecordTypeMap.put(atr.Activity_Record_Type__c, atr); }
            if(atr.User_Title__c != null) { UserTitleMap.put(atr.User_Title__c, atr); }
        }
        // end valid keys
        
        // return list
        List<CustomActivity> FilteredActivities = new List<CustomActivity>();
        
        if(Histories != null && !Histories.IsEmpty()) 
        {
            Integer CurrentIndex = 0;
            for(String TaskOrEvent : Histories.keyset())
            {
                for(sObject ah : Histories.get(TaskOrEvent))
                {
                    system.debug(ah);
                    
                    Id OwnerId = (Id) ah.get('OwnerId');
                    String TeamRole = AccountTeamRole(OwnerId, AccountTeamById);
                    String ActivityOwnerTitle = (String) ALL_UtilitiesData.GetDataFromNestedFields('Owner.Title', ah);
                    String ActivityRecordTypeName = (String) ALL_UtilitiesData.GetDataFromNestedFields('RecordType.Name', ah);
                    Boolean ActivityOwnerIsOnAccountTeam = AccountTeamById.keyset().contains(OwnerId);
                    
                    if(TeamRole == null && ActivityRecordTypeName != null) { 
                    	Account_Dashboard_Activity_Team_Roles__c atr = ActivityRecordTypeMap.get(ActivityRecordTypeName);
                    	if(atr != null) { TeamRole = atr.Name; } 
                	}
                    
                    if(ActivityOwnerIsOnAccountTeam
                    || ActivityRecordTypeMap.keySet().contains(ActivityRecordTypeName)
                    || UserTitleMap.keySet().contains(ActivityOwnerTitle))
                    {
                        CustomActivity ca = BuildCustomActivity(ah, TeamRole, ActivityOwnerTitle, ActivityOwnerIsOnAccountTeam, ActivityRecordTypeName, TaskOrEvent);
                        LogCustomActivity(ca, (CurrentIndex == 0));
                        
                        if( (ca.IsClosed == true || ca.ActivityEndDateTime >= DateTime.now())
                        &&  (ca.ActivityDate <= Date.Today() || ca.ActivityEndDateTime <= DateTime.now()) )
                        {
                            //system.debug('*** (Closed or Future) and (Due Date Past or Past) ***'); system.debug(ca);
                            
                            // get any previous records
                            String PreviousTeamRoleActivityId = fm.ActivityIdsByAccountTeamRole.get(ca.OwnerTeamRole); 
                            String PreviousRecordTypeActivityId = fm.ActivityIdsByRecordType.get(ca.ActivityRecordTypeName); 
                            String PreviousOwnerTitleActivityId = fm.ActivityIdsByOwnerTitle.get(ca.OwnerTitle); 
                            
                            // if no previous record was found, add this one
                            if(PreviousTeamRoleActivityId == null 
                            && PreviousRecordTypeActivityId == null 
                            && PreviousOwnerTitleActivityId == null) 
                            {
                                fm = AddFilteredActivity(fm, ca);
                            }
                            else if(ca.OwnerTeamRole != null) // if there is an owner team role, filter by this
                            {
                            	// filter by team role
                                if(PreviousTeamRoleActivityId != null && fm.FilteredActivitiesByKey.get(PreviousTeamRoleActivityId) != null) { 
                                    if(ca.ActivityDate > fm.FilteredActivitiesByKey.get(PreviousTeamRoleActivityId).ActivityDate) {
                                        fm = AddFilteredActivity(fm, ca, PreviousTeamRoleActivityId); }
                                }
                                // filter by record type
                                else if(PreviousRecordTypeActivityId != null && fm.FilteredActivitiesByKey.get(PreviousRecordTypeActivityId) != null) { 
                                    if(ca.ActivityDate > fm.FilteredActivitiesByKey.get(PreviousRecordTypeActivityId).ActivityDate) {
                                        fm = AddFilteredActivity(fm, ca, PreviousRecordTypeActivityId); }
                                }
                                else { // do not filter (add record without filtering)
                                    fm = AddFilteredActivity(fm, ca);
                                }
                            }
                            else // does not exist in results and owner team role is null
                            {
                            	// filter by record type
                                if(PreviousRecordTypeActivityId != null && fm.FilteredActivitiesByKey.get(PreviousRecordTypeActivityId) != null) { 
                                    if(ca.ActivityDate > fm.FilteredActivitiesByKey.get(PreviousRecordTypeActivityId).ActivityDate) {
                                        fm = AddFilteredActivity(fm, ca, PreviousRecordTypeActivityId); }
                                }
                                else { // do not filter (add record without filtering)
                                    fm = AddFilteredActivity(fm, ca);
                                }
                            }
                        }
                    } // end if criteria to add
                    
                    CurrentIndex++;
                    
                } // end for
            }
        } // end if histories
        
        FilteredActivities = fm.FilteredActivitiesByKey.values();
        return FilteredActivities;
    }
    
    public List<CustomActivity> AddNextActivities(List<CustomActivity> Activities, Map<String, List<sObject>> OpenActivities)
    {
        system.debug(Activities);
        system.debug(OpenActivities);
        
        Map<Id, CustomActivity> CustomActivityMap = new Map<Id, CustomActivity>();
        for(CustomActivity ca : Activities) { CustomActivityMap.put(ca.OwnerId, ca); }
        
        for(String ActivityType : OpenActivities.keyset()) 
        {
            List<sObject> OpenActivityList = OpenActivities.get(ActivityType);
            
            for(sObject oa : OpenActivityList)
            {
                CustomActivity ca = CustomActivityMap.get((Id)oa.get('OwnerId'));
                
                // if there is a custom Activity already existing (there needs to be to add a Next Activity) 
                //   and the Open Activity Date is after Today
                if(ca != null && (Date) oa.get('ActivityDate') > Date.Today())
                {
                    // if the Next Activity does not have a value, set the current Activity to the open Activity
                    //   or the current Activity Date occurs before the Open Activity Date
                    if(ca.NextActivityId == null || ca.NextActivityDate < (Date) oa.get('ActivityDate')) 
                    { 
                        ca.NextActivityId = (Id) oa.Id;
                        ca.NextActivitySubject = (String) oa.get('Subject');
                        ca.NextActivityDate = (Date) oa.get('ActivityDate');
                    } 
                }
            }
        }
        
        return CustomActivityMap.values();
    }
}