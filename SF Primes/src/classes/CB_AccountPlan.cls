global with sharing class CB_AccountPlan
{
    // -- class variables
    
    private Account_Plan__c AccountPlan;
    private List<Column> ContactColumns;
    private List<Column> StrategyColumns;
    private List<Monthly_Maintenance__c> AllStrategies;
    
    // -- constructors
    
    public CB_AccountPlan() { Initialize(null); }
    public CB_AccountPlan(ApexPages.StandardController sc) { Initialize(sc); }
    
    // -- subclasses
    
    public class Column
    {
        public String Header {get;set;}
        public String ApiName {get;set;}
        public String InputType {get;set;}
        public Column(String a, String h, String t) { ApiName = a; Header = h; InputType = t; }
    }
    
    public class Strategies
    {
        public Map<Id, Monthly_Maintenance__c> Open;
        public Map<Id, Monthly_Maintenance__c> History;
        public Map<Id, Monthly_Maintenance__c> HistoryFor255Plus;
    }
    
    // -- properties
    
    public String ErrorMessage {get;set;}
    
    public List<Contact> Contacts {get;set;}
    
    public Id SaveStrategyId {get;set;}
    public Map<Id, Monthly_Maintenance__c> OpenStrategies {get;set;}
    public Map<Id, Monthly_Maintenance__c> StrategyHistories {get;set;}
    public Map<Id, Monthly_Maintenance__c> StrategyHistoriesFor255Plus {get;set;} //added 1/2/2015 SivaP for production isssue 
    
    public Monthly_Maintenance__c NewStrategy {get;set;}
    
    public static List<Column> getAllContactColumns()
    {
        List<Column> Columns = new List<Column>();
        Map<String, Account_Plan_Contact_Display_Fields__c> FieldMap = Account_Plan_Contact_Display_Fields__c.getAll();
        
        if(FieldMap != null && !FieldMap.isEmpty())
        {
            List<Account_Plan_Contact_Display_Fields__c> Fields = FieldMap.values(); Fields.sort();
            
            for(Account_Plan_Contact_Display_Fields__c f : Fields) {
                Columns.add(new Column(f.API_Name__c, f.Header__c, f.Input_Type__c)); }
            
            return Columns;
        }
        else
        {
            // add defaults;
            Columns.add(new Column('Name', 'Name', 'string'));
            Columns.add(new Column('Phone', 'Phone & Ext', 'string'));
            Columns.add(new Column('MobilePhone', 'Mobile', 'string'));
            Columns.add(new Column('Email', 'Email', 'string'));
            Columns.add(new Column('Role__c', 'Role(s)', 'string'));
            
            return Columns;
        }
    }
    
    public List<Column> getStrategyColumns() { return StrategyColumns; }
    
    public static List<Column> getStrategyColumnsByRecordTypeName(String RecordTypeName)
    {
        List<Column> Columns = new List<Column>();
        Map<String, Account_Plan_Strategy_Field__c> StrategyFields = Account_Plan_Strategy_Field__c.getAll();
        
        system.debug(RecordTypeName);
        String LowerCaseRecordTypeName = null;
        if(RecordTypeName != null) { LowerCaseRecordTypeName = RecordTypeName.toLowerCase(); }
        
        List<String> keys = new List<String>(); keys.addAll(StrategyFields.keySet());
        keys.sort();
        
        for(String key : keys)
        {
            Account_Plan_Strategy_Field__c f = StrategyFields.get(key);
            
            if(f.Record_Type_Name__c.toLowerCase() == LowerCaseRecordTypeName)
            {
                Columns.add(new Column(f.Field_API_Name__c, f.Field_Label__c, f.Field_DataTable_Type__c));
            }
        }
        
        return Columns;
    }
    
    // -- class methods
    
    public void Initialize(ApexPages.StandardController sc)
    {
        // account plan
        if(sc != null) { this.AccountPlan = (Account_Plan__c) sc.getRecord(); }
        if(this.AccountPlan != null) { QueryAccountPlan(this.AccountPlan.Id); }
        
        // contacts
        InitializeContacts();
        
        // new strategy
        InitializeNewStrategy();
        
        // strategies
        InitializeStrategies();
    }
    
    public void QueryAccountPlan(Id AccountPlanId)
    {
        if(AccountPlanId != null)
        {
            this.AccountPlan = [
                Select Id, Name, RecordTypeId, RecordType.Name,  
                    Account__c, Account__r.Name, WebID__c, WebID__r.Name
                From Account_Plan__c
                Where Id = :AccountPlanId
                Limit 1
            ];
        }
    }
    
    public void InitializeContacts()
    {
		this.Contacts = new List<Contact>();
        this.ContactColumns = CB_AccountPlan.getAllContactColumns();
        
        if(this.AccountPlan != null) {
            List<Contact> AllContacts = QueryAccountPlanContacts(this.AccountPlan, ContactColumns); 
            this.Contacts = FilterContacts(this.AccountPlan, AllContacts);
        }
    }
    
    public void InitializeStrategies()
    {
        this.AllStrategies = new List<Monthly_Maintenance__c>();
        this.OpenStrategies = new Map<Id, Monthly_Maintenance__c>();
        this.StrategyHistories = new Map<Id, Monthly_Maintenance__c>();
        this.StrategyHistoriesFor255Plus = new Map<Id, Monthly_Maintenance__c>(); //added 1/2/2015 SivaP for production isssue 
        
        if(this.AccountPlan != null)
        {
            this.StrategyColumns = CB_AccountPlan.getStrategyColumnsByRecordTypeName(this.AccountPlan.RecordType.Name); 
            this.AllStrategies = QueryAccountPlanStrategies(this.AccountPlan, StrategyColumns); 
            
            Strategies FilteredStrategies = FilterStrategies(this.AllStrategies);
            
            this.OpenStrategies = FilteredStrategies.Open;
            this.StrategyHistories = FilteredStrategies.History;
            this.StrategyHistoriesFor255Plus = FilteredStrategies.HistoryFor255Plus; //added 1/2/2015 SivaP for production isssue 
            
           //added 1/2/2015 SivaP for production isssue 
            for(Id key: FilteredStrategies.Open.keySet())
            {
                FilteredStrategies.HistoryFor255Plus.put(key, FilteredStrategies.Open.get(key));
            }
        }
    }
    
    public void InitializeNewStrategy()
    {
        this.NewStrategy = new Monthly_Maintenance__c();
        
        Map<Id, Id> StrategyRecordTypeMap = new Map<Id, Id>();
        
        List<Account_Plan_Strategy_RecordType__c> StrategyRecordTypeList 
            = Account_Plan_Strategy_RecordType__c.getAll().values();
        
        for(Account_Plan_Strategy_RecordType__c rt : StrategyRecordTypeList) {
            StrategyRecordTypeMap.put(rt.Account_Plan_RecordType__c, rt.Strategy_RecordType__c); }
        
        if(this.AccountPlan != null)
        {
            Id StrategyRecordTypeId = StrategyRecordTypeMap.get(this.AccountPlan.RecordTypeId);
            if(StrategyRecordTypeId != null) { this.NewStrategy.RecordTypeId = StrategyRecordTypeId; }
            
            this.NewStrategy.Account_Plan__c = this.AccountPlan.Id;
            this.NewStrategy.putSObject('Account_Plan__r', this.AccountPlan);
            this.NewStrategy.Account__c = this.AccountPlan.Account__c;
            this.NewStrategy.putSObject('Account__r', this.AccountPlan.Account__r);
            this.NewStrategy.WebID__c = this.AccountPlan.WebID__c;
            this.NewStrategy.putSObject('WebID__r', this.AccountPlan.WebID__r);
        }
        
        this.NewStrategy.Month__c = Date.today();
        this.NewStrategy.Review_Frequency__c = 'Monthly';
        this.NewStrategy.Type__c = 'ProCare';
        this.NewStrategy.Status__c = 'Not Started';
    }
    
    public void SaveStrategyRecords()
    {
        if(OpenStrategies != null) {
            update OpenStrategies.values(); }
    }
    
    @RemoteAction
    global static String SaveStrategy(sObject CurrentStrategy, List<String> FieldsToNull)
    {
        system.debug(CurrentStrategy);
        system.debug(FieldsToNull);
        
        if(CurrentStrategy != null) 
        {
            if(FieldsToNull != null && !FieldsToNull.isEmpty()) {
                for(String FieldApiName : FieldsToNull) { system.debug(FieldApiName);
                    CurrentStrategy.put(FieldApiName, null); } }
            
            try { update CurrentStrategy; }
            catch(Exception exc) 
            {
                String ExceptionMessage = exc != null ? exc.getMessage() : null;
                String ErrorMessage = 'An unexpected error occurred while saving.';
                
                if(ExceptionMessage != null && ExceptionMessage.contains(';'))
                {
                    List<String> ErrorSplit = ExceptionMessage.split(';');
                    if(ErrorSplit.size() > 1) { ErrorMessage = ErrorSplit[1]; }
                }
                
                return ErrorMessage;
            }
            
            return 'Success!';
        }
        
        return 'An unexpected error occurred while saving.';
    }
    
    @RemoteAction
    global static Monthly_Maintenance__c RefreshStrategy(String StrategyId, String FieldApiName)
    {
        Monthly_Maintenance__c RefreshedStrategy = null;
        List<Monthly_Maintenance__c> RefreshedStrategies = new List<Monthly_Maintenance__c>();
        
        try 
        {
            RefreshedStrategies = Database.query(
                'Select ' + FieldApiName + ' From Monthly_Maintenance__c ' + 
                'Where Id = \'' + StrategyId + '\''
            );
            
            if(!RefreshedStrategies.isEmpty()) {
                RefreshedStrategy = RefreshedStrategies[0]; 
            }
        }
        catch(Exception exc) { system.debug(exc); }
        
        return RefreshedStrategy;
    }
    
    public void AddNewStrategy()
    {
        ErrorMessage = '';
        
        system.debug(NewStrategy);
        
        try { insert NewStrategy; }
        catch(Exception exc) { ErrorMessage = exc.getMessage(); system.debug(exc); }
        
        QueryAccountPlan(this.AccountPlan.Id);
        
        // new strategy
        InitializeNewStrategy();
        
        // strategies
        InitializeStrategies();
    }
    
    // -- static methods
    
    public static List<Contact> FilterContacts(Account_Plan__c ap, List<Contact> AllContacts)
    {
        List<Contact> FilteredContacts = new List<Contact>();
        
        List<Account_Plan_Contacts_Filter__c> apContactsFilters = Account_Plan_Contacts_Filter__c.getAll().values();
        Set<String> ContactRoles = new Set<String>();
        
        for(Account_Plan_Contacts_Filter__c ContactsFilter : apContactsFilters)
        {
            if(ap.RecordType.Name.toLowerCase().contains(ContactsFilter.Record_Type_Name__c.toLowerCase()))
            {
                ContactRoles.add(ContactsFilter.Contact_Role__c.toLowerCase());
            }
        }
        
        for(Contact c : AllContacts)
        {
            system.debug(ContactRoles); system.debug(c);
            Boolean add = false;
            
            List<String> CurrentRoles = 
                (c.Role__c != null) ? 
                	c.Role__c.toLowerCase().split(';') : 
            		new List<String>(); 
            
            for(String CurrentRole : CurrentRoles) 
            { 
                if(ContactRoles.contains(CurrentRole)) { add = true; }
            }
            
            if(add) { FilteredContacts.add(c); }
        }
        
        return FilteredContacts;
    }
    
    public static List<Contact> QueryAccountPlanContacts(Account_Plan__c ap, List<Column> Columns)
    {
        List<String> Fields = new List<String>();
        for(Column c : Columns) { Fields.add(c.ApiName); }
        
        if(ap != null)
        {
            String FieldsToQuery = ALL_UtilitiesString.ListToCSV(Fields).remove('\'');
            String IdCondition = ALL_UtilitiesString.ListToInclusiveCondition('Where', 'Id', new List<String>{ap.Account__c});
            
            if(!FieldsToQuery.toLowerCase().contains('role__c')) { FieldsToQuery += ',Role__c'; }
            
            if(!FieldsToQuery.toLowerCase().contains('accountid')) { FieldsToQuery += ',AccountId'; }
            if(!FieldsToQuery.toLowerCase().contains('account.name')) { FieldsToQuery += ',Account.Name'; }
            
            if(!FieldsToQuery.toLowerCase().contains('webid__c')) { FieldsToQuery += ',WebID__c'; }
            if(!FieldsToQuery.toLowerCase().contains('webid__r.name')) { FieldsToQuery += ',WebID__r.Name'; }
            
            String q = '' 
                + 'Select Id, Name, ' 
                    + '(Select ' 
                        + FieldsToQuery + ' ' 
                        + 'From Contacts ' 
                        + 'Where Status__c != \'Inactive\' ' 
                        + 'And No_Longer_There__c = false ' 
                    + ') '
                + 'From Account ' 
                + IdCondition + ' ' 
                + 'Limit 1 '; 
            
            system.debug(q);
            
            Account a = Database.query(q);
            
            if(a != null) 
            {
                system.debug('here?');
                List<Contact> AccountContacts = a.getSObjects('Contacts');
                if(AccountContacts != null) { system.debug(AccountContacts.size()); return AccountContacts; }
            }
        }       
        return new List<Contact>();
    }
    
    public static Strategies FilterStrategies(List<Monthly_Maintenance__c> AllStrategies)
    {
        Strategies FilteredStrategies = new Strategies();
        FilteredStrategies.Open = new Map<Id, Monthly_Maintenance__c>();
        FilteredStrategies.History = new Map<Id, Monthly_Maintenance__c>();
        FilteredStrategies.HistoryFor255Plus = new Map<Id, Monthly_Maintenance__c>();
        
        for(Monthly_Maintenance__c s : AllStrategies)
        {
            system.debug(s);
            
            String OpenStatus = s.Open_Status__c.toLowerCase();
            
            if(OpenStatus == 'open') 
            { 
                FilteredStrategies.Open.put(s.Id, s);
                FilteredStrategies.HistoryFor255Plus.put(s.Id, s); //added 1/2/2015 SivaP for production isssue 
            }
            
            if(OpenStatus == 'completed' || OpenStatus == 'cancelled' || OpenStatus == 'canceled' || OpenStatus == 'n/a') 
            { 
                if(FilteredStrategies.History.size() < 200) 
                {
                    FilteredStrategies.History.put(s.Id, s);
                    FilteredStrategies.HistoryFor255Plus.put(s.Id, s); //added 1/2/2015 SivaP for production isssue 
                } 
            }
        }
        
        return FilteredStrategies;
    }
    
    public static List<Monthly_Maintenance__c> QueryAccountPlanStrategies(Account_Plan__c ap, List<Column> Columns)
    {
        List<String> Fields = new List<String>();
        for(Column c : Columns) { Fields.add(c.ApiName); }
        
        if(ap != null)
        {
            String IdCondition = ALL_UtilitiesString.ListToInclusiveCondition('Where', 'Id', new List<String>{ap.Id});
            
            String FieldsToQuery = ALL_UtilitiesString.ListToCSV(Fields).remove('\''); system.debug(FieldsToQuery);
            String FieldsComma = '';
            
            FieldsComma = (FieldsToQuery == '' || FieldsToQuery == null) ? '' : ',';
            if(!FieldsToQuery.toLowerCase().contains('account__c')) { FieldsToQuery += FieldsComma + 'Account__c'; }
            
            FieldsComma = (FieldsToQuery == '' || FieldsToQuery == null) ? '' : ',';
            if(!FieldsToQuery.toLowerCase().contains('account__r.name')) { FieldsToQuery += FieldsComma + 'Account__r.Name'; }
            
            FieldsComma = (FieldsToQuery == '' || FieldsToQuery == null) ? '' : ',';
            if(!FieldsToQuery.toLowerCase().contains('open_status__c')) { FieldsToQuery += FieldsComma + 'Open_Status__c'; }
            
            String q = '' 
                + 'Select Id, Name, ' 
                    + '(Select ' 
                        + FieldsToQuery + ' ' 
                        + 'From Monthly_Maintenance__r ' 
                    + ') ' 
                + 'From Account_Plan__c ' 
                + IdCondition + ' ' 
                + 'Limit 1 '; 
            
            system.debug(q);
            Account_Plan__c StrategiesAccountPlan = Database.query(q);
            
            if(StrategiesAccountPlan != null) 
            {
                List<Monthly_Maintenance__c> AccountStrategies = StrategiesAccountPlan.getSObjects('Monthly_Maintenance__r');
                if(AccountStrategies != null) { return AccountStrategies; }
            }
        }
        
        return new List<Monthly_Maintenance__c>();
    }
    /* Execute Anonymous Code
	// This section of code is used to setup the Account Plan Strategy Custom Settings - DO NOT DELETE
    public static void SetRecordTypeSettings()
    {
        List<Account_Plan_Strategy_RecordType__c> StrategyRecordTypeSettings = new List<Account_Plan_Strategy_RecordType__c>();
        
        List<Account_Plan_Strategy_RecordType__c> oldStrategyRecordTypeSettings = Account_Plan_Strategy_RecordType__c.getAll().values();
        delete oldStrategyRecordTypeSettings;
        
        List<RecordType> RecordTypes = [
            Select Id, Name, sObjectType From RecordType 
            Where sObjectType = 'Account_Plan__c' OR sObjectType = 'Monthly_Maintenance__c'
        ];
        
        if(!RecordTypes.isEmpty()) 
        {
            List<RecordType> AccountPlanRecordTypes = new List<RecordType>();
            List<RecordType> StrategyRecordTypes = new List<RecordType>();
            
            for(RecordType rt : RecordTypes) 
            {
                if(rt.sObjectType == 'Account_Plan__c') { AccountPlanRecordTypes.add(rt); }
                if(rt.sObjectType == 'Monthly_Maintenance__c' && rt.Name.contains('Strategy')) { StrategyRecordTypes.add(rt); }
            }
            
            for(RecordType apRecordType : AccountPlanRecordTypes) 
            {
                Account_Plan_Strategy_RecordType__c StrategyRecordTypeSetting = new Account_Plan_Strategy_RecordType__c();
                String apType = apRecordType.Name.replaceAll('Account Plan','').trim();
                
                StrategyRecordTypeSetting.Name = apType;
                StrategyRecordTypeSetting.Account_Plan_RecordType__c = apRecordType.Id;
                
                for(RecordType stratRecordType : StrategyRecordTypes)
                {
                    if(stratRecordType.Name.contains(apType)) { 
                    	StrategyRecordTypeSetting.Strategy_RecordType__c = stratRecordType.Id;
                    }
                }
                
                StrategyRecordTypeSettings.add(StrategyRecordTypeSetting);
            }
            
            insert StrategyRecordTypeSettings;
        }
    }
	*/
}