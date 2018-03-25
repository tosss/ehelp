@IsTest
public class CB_AccountPlan_Test
{
    public static testmethod void Subclasses()
    {
        CB_AccountPlan.Column c = new CB_AccountPlan.Column('Name','Name','html');
        
        CB_AccountPlan.Strategies s = new CB_AccountPlan.Strategies();
        s.Open = new Map<Id, Monthly_Maintenance__c>();
        s.History = new Map<Id, Monthly_Maintenance__c>();
    }
    
    // 1 soql
    public static testmethod void DefaultContactColumns()
    {
        delete [select id from Account_Plan_Contact_Display_Fields__c];
        List<CB_AccountPlan.Column> ContactColumns = CB_AccountPlan.getAllContactColumns();
        
        system.assert(ContactColumns != null);
    }

    // 1 dml
    public static testmethod void CustomContactColumns()
    {
        // insert field column
        Account_Plan_Contact_Display_Fields__c col = new Account_Plan_Contact_Display_Fields__c();
        col.Name = 'Name';
        col.API_Name__c = 'Name';
        col.Header__c = 'Name';
        col.Input_Type__c = 'string';
        insert col;
        
        List<CB_AccountPlan.Column> ContactColumns = CB_AccountPlan.getAllContactColumns();
        
        system.assert(ContactColumns != null);
    }
    
    public static testmethod void Properties()
    {
        Account_Plan__c AccountPlan = DS_TestObjects.NewAccountPlan_Inserted();
        
        Account_Plan_Strategy_Field__c StrategyField = new Account_Plan_Strategy_Field__c();
        StrategyField.Name = 'Test Strategy Filter';
        StrategyField.Field_API_Name__c = 'Name';
        StrategyField.Field_Label__c = 'Label';
        StrategyField.Field_DataTable_Type__c = 'html';
        StrategyField.Record_Type_Name__c = AccountPlan.RecordType.Name;
        insert StrategyField;
        
        CB_AccountPlan AccountPlanController = new CB_AccountPlan(new ApexPages.StandardController(AccountPlan));
        
        AccountPlanController.ErrorMessage = 'Test Error';
        String ErrorMessage = AccountPlanController.ErrorMessage;
        
        AccountPlanController.Contacts = new List<Contact>();
        List<Contact> Contacts = AccountPlanController.Contacts;
    	
        AccountPlanController.SaveStrategyId = '001000000123456';
        Id SaveStrategyId = AccountPlanController.SaveStrategyId;
        
        AccountPlanController.OpenStrategies = new Map<Id, Monthly_Maintenance__c>();
        Map<Id, Monthly_Maintenance__c> OpenStrategies = AccountPlanController.OpenStrategies;
        
        AccountPlanController.StrategyHistories = new Map<Id, Monthly_Maintenance__c>();
        Map<Id, Monthly_Maintenance__c> StrategyHistories = AccountPlanController.StrategyHistories;
        
        AccountPlanController.NewStrategy = new Monthly_Maintenance__c();
        Monthly_Maintenance__c NewStrategy = AccountPlanController.NewStrategy;
        
        List<CB_AccountPlan.Column> ContactColumns = CB_AccountPlan.getAllContactColumns();
        List<CB_AccountPlan.Column> StrategyColumns = AccountPlanController.getStrategyColumns();
        
        List<CB_AccountPlan.Column> StrategyColumnsByRecordType 
            = CB_AccountPlan.getStrategyColumnsByRecordTypeName(AccountPlan.RecordType.Name);
    }
    
    public static testmethod void Methods()
    {
        Account_Plan__c AccountPlan = DS_TestObjects.NewAccountPlan_Inserted();
        
        Account_Plan_Strategy_Field__c StrategyField = new Account_Plan_Strategy_Field__c();
        StrategyField.Name = 'Test Strategy Filter';
        StrategyField.Field_API_Name__c = 'Name';
        StrategyField.Field_Label__c = 'Label';
        StrategyField.Field_DataTable_Type__c = 'html';
        StrategyField.Record_Type_Name__c = AccountPlan.RecordType.Name;
        insert StrategyField;
        
        CB_AccountPlan AccountPlanBlank = new CB_AccountPlan(null);
        CB_AccountPlan AccountPlanController = new CB_AccountPlan(new ApexPages.StandardController(AccountPlan));
        
        AccountPlanController.QueryAccountPlan(AccountPlan.Id);
        AccountPlanController.InitializeContacts();
        AccountPlanController.InitializeStrategies();
        AccountPlanController.InitializeNewStrategy();
        
        AccountPlanController.SaveStrategyRecords();
        AccountPlanController.NewStrategy = DS_TestObjects.NewMonthlyMaintenance();
        AccountPlanController.AddNewStrategy();
    }
    
    public static testmethod void RemoteActions()
    {
        Monthly_Maintenance__c Strategy = DS_TestObjects.NewMonthlyMaintenance();
        Account_Plan__c AccountPlan = Strategy.Account_Plan__r;
        
        Account_Plan_Strategy_Field__c StrategyField = new Account_Plan_Strategy_Field__c();
        StrategyField.Name = 'Test Strategy Filter';
        StrategyField.Field_API_Name__c = 'Name';
        StrategyField.Field_Label__c = 'Label';
        StrategyField.Field_DataTable_Type__c = 'html';
        StrategyField.Record_Type_Name__c = AccountPlan.RecordType.Name;
        insert StrategyField;
        
        // test null strategy
        CB_AccountPlan.SaveStrategy(null, null); 
        
        // test unsuccessful update (Strategy has no ID, cannot be updated)
        CB_AccountPlan.SaveStrategy(Strategy, null); 
        
        // insert Strategy for updating
        insert Strategy;
        
        // test successful update
        CB_AccountPlan.SaveStrategy(Strategy, null); 
        
        // test error case (cannot null ActionDueDate)
        CB_AccountPlan.SaveStrategy(Strategy, new List<String>{'Action_Due_Date__c'}); 
        
        // refresh Strategy Name field
        CB_AccountPlan.RefreshStrategy(Strategy.Id, 'Name');
    }
    
	public static testmethod void QueryAndFilterContacts()
    {
        // custom settings
        Account_Plan_Contacts_Filter__c ContactsFilter 
            = DS_TestObjects.NewAccountPlanContactFilter_Inserted();
        
        // objects
        Account_Plan__c ap = DS_TestObjects.NewAccountPlan_Inserted();
        Contact c = DS_TestObjects.NewContact();
        c.AccountId = ap.Account__c;
        c.Role__c = ContactsFilter.Contact_Role__c;
        insert c;
        
        List<CB_AccountPlan.Column> Columns = new List<CB_AccountPlan.Column>();
        Columns = CB_AccountPlan.getAllContactColumns();
        
        // methods
        List<Contact> BlankContacts = CB_AccountPlan.QueryAccountPlanContacts(null, Columns);
        
        List<Contact> AllContacts = CB_AccountPlan.QueryAccountPlanContacts(ap, Columns);
        List<Contact> FilteredContacts = CB_AccountPlan.FilterContacts(ap, AllContacts);
    }
    
    public static testmethod void QueryAndFilterStrategies()
    {
        // objects
        Account_Plan__c ap = DS_TestObjects.NewAccountPlan_Inserted();
        List<Monthly_Maintenance__c> mms = new List<Monthly_Maintenance__c>();
        Monthly_Maintenance__c mm1 = DS_TestObjects.NewMonthlyMaintenance();
        Monthly_Maintenance__c mm2 = DS_TestObjects.NewMonthlyMaintenance();
        
        mm1.Account_Plan__c = ap.Id; 
        mm1.Account_Plan__r = ap;
        mm1.Account__c = ap.Account__c; 
        mm1.Account__r = ap.Account__r;
        mm1.WebID__c = ap.WebID__c;
        mm1.WebID__r = ap.WebID__r;
        mm1.Month__c = Date.today().addDays((-1*Date.today().day())+1);
        mm1.Action_Due_Date__c = Date.today();
        
        mm2.Account_Plan__c = ap.Id;
        mm2.Account_Plan__r = ap;
        mm2.Account__c = ap.Account__c; 
        mm2.Account__r = ap.Account__r;
        mm2.WebID__c = ap.WebID__c;
        mm2.WebID__r = ap.WebID__r;
        mm2.Month__c = Date.today().addDays((-1*Date.today().day())+1);
        mm2.Action_Due_Date__c = Date.today();
        mm2.Status__c = 'Completed';
        
        mms.add(mm1); mms.add(mm2);
        insert mms;
        
        // custom settings
        Account_Plan_Strategy_Field__c StrategyField = new Account_Plan_Strategy_Field__c();
        StrategyField.Name = 'Test Strategy Filter';
        StrategyField.Field_API_Name__c = 'Name';
        StrategyField.Field_Label__c = 'Label';
        StrategyField.Field_DataTable_Type__c = 'html';
        StrategyField.Record_Type_Name__c = ap.RecordType.Name;
        insert StrategyField;
        
        List<CB_AccountPlan.Column> StrategyColumns 
            = CB_AccountPlan.getStrategyColumnsByRecordTypeName(ap.RecordType.Name); 
        
        // test with blank account plan
        List<Monthly_Maintenance__c> AllStrategies_Invalid
            = CB_AccountPlan.QueryAccountPlanStrategies(null, StrategyColumns);
        
        // test with valid account plan
        List<Monthly_Maintenance__c> AllStrategies_Valid
            = CB_AccountPlan.QueryAccountPlanStrategies(ap, StrategyColumns);
        
        CB_AccountPlan.Strategies FilteredStrategies = CB_AccountPlan.FilterStrategies(AllStrategies_Valid);
    }
}