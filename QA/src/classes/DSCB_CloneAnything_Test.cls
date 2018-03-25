//2015-11-27 : vishal.bandari@cdk.com - RQ-05289:changed methods to add contact record type
@IsTest
public class DSCB_CloneAnything_Test
{
    public static testmethod Clone_Records_Settings__c GetCloneRecordsSettings()
    {
        // clear previous settings
        delete [Select Id From Clone_Records_Settings__c];
        
        Clone_Records_Settings__c Settings = new Clone_Records_Settings__c();
        Settings.Name = 'Contact';
        Settings.sObject_API_Name__c = 'Contact';
        
        Settings.Source_Autocomplete_Account_Field__c = 'AccountId';
        Settings.Source_Autocomplete_Fields__c = 'Name,Account.Name,Email';
        Settings.Source_Autocomplete_Search_Fields__c = 'Name,Account.Name,Email';
        Settings.Source_Key_Field__c = 'AccountId';
        Settings.Source_Name_Field__c = 'Name';
        Settings.Source_Display_Fields__c = 'FirstName,LastName,Email,Phone,AccountId,Account.OwnerId,Account.Owner.Name';
        
        Settings.Destination_sObject_API_Name__c = 'Account';
        Settings.Destination_Display_Fields__c = 'Id,Name';
        Settings.Destination_sObject_Account_Field__c = 'Id';
        Settings.Destination_Conditions__c = 'Dynamically';
        Settings.Query_Conditional_Expression__c = '( 1 )';
        Settings.Clone_Profile_Access_Permission_Field__c = 'Case_Account_Plan__c';
        
        
        insert Settings;
        return Settings;
    }
    
    public static testmethod Clone_Destination_Query_Condition__c getContactCloneDestinationQueryConditions()
    {
        delete [Select Id From Clone_Destination_Query_Condition__c]; 
        
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = new  Clone_Destination_Query_Condition__c();
        Contact_CloneDestinationQuery.Name = '001';
        Contact_CloneDestinationQuery.Class_Name__c = 'DynamicSOQL_Helper';
        Contact_CloneDestinationQuery.Cloning_Type_Identifier__c = 'Contact';
        Contact_CloneDestinationQuery.Key__c = 'OwnerId';
        Contact_CloneDestinationQuery.Method_Name__c = 'CurrentUserId()';
        Contact_CloneDestinationQuery.Operator__c = '!=';
        Contact_CloneDestinationQuery.Order__c = 1;
        Contact_CloneDestinationQuery.Value__c = 'Dynamic';
        
        insert Contact_CloneDestinationQuery;
        return Contact_CloneDestinationQuery;           
     } 
    
    public static testmethod List<Clone_Records_Override_Settings__c> GetCloneRecordsOverrideSettings()
    {
        // clear previous settings
        delete [Select Id From Clone_Records_Override_Settings__c];
        
        List<Clone_Records_Override_Settings__c> ContactOverrides = new List<Clone_Records_Override_Settings__c>();
        
        Clone_Records_Override_Settings__c OverrideAccountId = new Clone_Records_Override_Settings__c();
        OverrideAccountId.Name = 'Contact Field 1';
        OverrideAccountId.sObject_API_Name__c = 'Contact';
        OverrideAccountId.Query_sObject__c = 'Account';
        OverrideAccountId.Query_Field_API_Name__c = 'Id';
        OverrideAccountId.Replacement_Field_API_Name__c = 'AccountId';
        
        Clone_Records_Override_Settings__c OverrideAccountOwner = new Clone_Records_Override_Settings__c();
        OverrideAccountOwner.Name = 'Contact Field 2';
        OverrideAccountOwner.sObject_API_Name__c = 'Contact';
        OverrideAccountOwner.Query_sObject__c = 'Account';
        OverrideAccountOwner.Query_Field_API_Name__c = 'OwnerId';
        
        Clone_Records_Override_Settings__c OverrideAccountOwnerName = new Clone_Records_Override_Settings__c();
        OverrideAccountOwnerName.Name = 'Contact Field 3';
        OverrideAccountOwnerName.sObject_API_Name__c = 'Contact';
        OverrideAccountOwnerName.Query_sObject__c = 'Account';
        OverrideAccountOwnerName.Query_Field_API_Name__c = 'Owner.Name';
        
        
        ContactOverrides.add(OverrideAccountId);
        ContactOverrides.add(OverrideAccountOwner);
        ContactOverrides.add(OverrideAccountOwnerName);
        
        insert ContactOverrides;
        return ContactOverrides;
    }
    
        
    public static testmethod List<Clone_Display_Field_Settings__c> GetCloneDisplayFieldSettings()
    {
        // required fields: Name, Field_API_Name__c, Field_Display_Type__c, sObject_API_Name__c
        
        // clear previous settings
        delete [Select Id From Clone_Display_Field_Settings__c];
        
        List<Clone_Display_Field_Settings__c> CloneDisplayFieldSettings = new List<Clone_Display_Field_Settings__c>();
        
        Clone_Display_Field_Settings__c ContactName = new Clone_Display_Field_Settings__c();
        ContactName.Name = '1 Contact: Name';
        ContactName.sObject_API_Name__c = 'Contact';
        ContactName.Field_API_Name__c = 'Name';
        ContactName.Field_Display_Type__c = 'Link';
        ContactName.Field_Editable__c = false;
        contactName.Relationship__c = 'Account';
        CloneDisplayFieldSettings.add(ContactName);     
        
        Clone_Display_Field_Settings__c ContactRelation = new Clone_Display_Field_Settings__c();
        ContactRelation.Name = '1R Contact: Name';
        ContactRelation.sObject_API_Name__c = 'Contact';
        ContactRelation.Destination_Picklist_Option_Fields__c = 'owner';
        ContactRelation.Field_Options_Query__c = 'Select Id, Name From Contact';
        ContactRelation.Relationship__c = 'Account';
        ContactRelation.Field_API_Name__c = 'Name';
        ContactRelation.Field_Display_Type__c = 'picklist';
        ContactRelation.Field_Editable__c = false;
        ContactRelation.Relationship__c = 'Account';
        CloneDisplayFieldSettings.add(ContactRelation);
        
        Clone_Display_Field_Settings__c ContactAccountName = new Clone_Display_Field_Settings__c();
        ContactAccountName.Name = '2 Contact: Account Name';
        ContactAccountName.sObject_API_Name__c = 'Contact';
        ContactAccountName.Field_API_Name__c = 'Account.Name';
        ContactAccountName.Field_Display_Type__c = 'Text';
        ContactAccountName.Field_Editable__c = false;
        CloneDisplayFieldSettings.add(ContactAccountName);
        
        Clone_Display_Field_Settings__c ContactOwner = new Clone_Display_Field_Settings__c();
        ContactOwner.Name = '3 Contact: Owner';
        ContactOwner.sObject_API_Name__c = 'Contact';
        ContactOwner.Field_API_Name__c = 'OwnerId';
        ContactOwner.Field_Display_Type__c = 'Picklist';
        ContactOwner.Field_Editable__c = true;
        ContactOwner.Field_Options_Query__c = 'Select Id,Name From User Where IsActive = true Limit 100';
        ContactOwner.Field_Options_Query_Text__c = 'Name';
        ContactOwner.Field_Options_Query_Value__c = 'Id';
        CloneDisplayFieldSettings.add(ContactOwner);
        
        insert CloneDisplayFieldSettings;
        return CloneDisplayFieldSettings;
    }
    
     
    public static testmethod void InitializePageWithoutSettings()
    {
        // test with invalid parameters
       
        delete [Select Id From Clone_Records_Settings__c];
        Clone_Records_Settings__c CloneRecordsSettings = GetCloneRecordsSettings();
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = getcontactCloneDestinationQueryConditions();
        PageReference CloneAnythingPage1 = Page.DSCB_CloneAnything;
        Test.setCurrentPage(CloneAnythingPage1);
        DSCB_CloneAnything CloneAnything1 = new DSCB_CloneAnything();
    }
    
    public static testmethod void InitializePageWithInvalidSettings()
    {
        // prepare records for testing
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact();
        c.Role__c = 'Test Role'; // 9/29
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        c.AccountId = a.Id; 
        insert c;
        
        delete [Select Id From Clone_Records_Settings__c];
        Clone_Records_Settings__c CloneRecordsSettings = GetCloneRecordsSettings();
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = getContactCloneDestinationQueryConditions();
        
        // test with invalid settings
        PageReference CloneAnythingPage = Page.DSCB_CloneAnything;
        CloneAnythingPage.getParameters().put('sourcetype', 'asdfjkl');
        CloneAnythingPage.getParameters().put('sourceid', c.Id);
        CloneAnythingPage.getParameters().put('Subtype', ' ');
        CloneAnythingPage.getParameters().put('aid', ' ');
        Test.setCurrentPage(CloneAnythingPage);
        DSCB_CloneAnything CloneAnything = new DSCB_CloneAnything();
    }
    
    public static testmethod void InitializePageWithValidSettingsAndObjects()
    {
        // prepare records for testing
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id; insert c;
        Site_Type__c st = DS_TestObjects.NewSiteType(); st.Group_Flag__c = true; insert st;
        Account p = DS_TestObjects.NewAccount(); p.Name = 'Parent'; p.Site_Type__c = st.Id; a.ParentId = p.Id; update a;
        
        // test with invalid parameters
        delete [Select Id From Clone_Records_Settings__c];
        Clone_Records_Settings__c CloneRecordsSettings = GetCloneRecordsSettings();
        CloneRecordsSettings.Unsearchable__c = false;
        CloneRecordsSettings.Clone_Profile_Access_Permission_Field__c = 'Case_Account_Plan__c'; Update CloneRecordsSettings;
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = getContactCloneDestinationQueryConditions();
        list<Clone_Profile_Access__c> CloneProfileAccessSettings = getCloneProfileAccessSettings();
        
        PageReference CloneAnythingPage = Page.DSCB_CloneAnything;
        CloneAnythingPage.getParameters().put('sourcetype', 'Contact');
        CloneAnythingPage.getParameters().put('sourceid', c.Id);
        CloneAnythingPage.getParameters().put('aid', a.Id);
        Test.setCurrentPage(CloneAnythingPage);
        DSCB_CloneAnything CloneAnything = new DSCB_CloneAnything();
    }
    
    public static testmethod void SearchSObjects()
    {
        // prepare records for testing
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id; insert c;
        
        delete [Select Id From Clone_Records_Settings__c];
        DSCB_Cloneanything.SearchSObjectsParameters parameters = new DSCB_Cloneanything.SearchSObjectsParameters();
        parameters.sObjectType = 'Contact';
        Parameters.SearchTerm = 'test';
        
        // test without settings
        DSCB_CloneAnything.SearchSObjectsWithSubType(parameters);
        
        Clone_Records_Settings__c CloneRecordsSettings = GetCloneRecordsSettings();
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = getContactCloneDestinationQueryConditions();
        
        // test with settings
        DSCB_CloneAnything.SearchSObjectsWithSubType(Parameters);
        
        DSCB_Cloneanything.SearchSObjectsParameters parameters1 = new DSCB_Cloneanything.SearchSObjectsParameters();
        parameters1.sObjectType = 'Contact';
        Parameters1.SearchTerm = ' ';
        DSCB_CloneAnything.SearchSObjectsWithSubType(Parameters1);
        
        // test result object
        DSCB_CloneAnything.SearchSObjectsResult sr1 = new DSCB_CloneAnything.SearchSObjectsResult();
        DSCB_CloneAnything.SearchSObjectsResult sr2 = new DSCB_CloneAnything.SearchSObjectsResult(new List<String>(), '');
        DSCB_CloneAnything.SearchSObjectsResult sr3 = new DSCB_CloneAnything.SearchSObjectsResult(new List<String>(), '', new List<sObject>());
    }
    
    public static testmethod void GetCloneDisplaySettings()
    {
        Clone_Records_Settings__c crs = GetCloneRecordsSettings();
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = getContactCloneDestinationQueryConditions();
        List<Clone_Display_Field_Settings__c> cdfs = GetCloneDisplayFieldSettings();
        DSCB_CloneAnything.CloneDisplaySettings cds = new DSCB_CloneAnything.CloneDisplaySettings(crs.sObject_API_Name__c, null); 
    }
    
    public static testmethod void CloneToSelected()
    {
        // prepare records for testing
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id; c.Role__c = 'Test Role'; 
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c; // 9/29
        
        delete [Select Id From Clone_Records_Settings__c];
        Clone_Records_Settings__c CloneRecordsSettings = GetCloneRecordsSettings();
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = getContactCloneDestinationQueryConditions();
        
        delete [Select Id From Clone_Records_Override_Settings__c];
        List<Clone_Records_Override_Settings__c> CloneRecordsOverrideSettings = GetCloneRecordsOverrideSettings();
        
        delete [Select Id From Clone_Display_Field_Settings__c];
        List<Clone_Display_Field_Settings__c> CloneDisplayFieldSettings = GetCloneDisplayFieldSettings();
        
        // test invalid destination object API name
        String OriginalDestinationSObjectAPIName = CloneRecordsSettings.Destination_sObject_API_Name__c;
        CloneRecordsSettings.Destination_sObject_API_Name__c = 'asdfjkl'; update CloneRecordsSettings;
        DSCB_CloneAnything.CloneToSelected(CloneRecordsSettings.sObject_API_Name__c, c.Id, new List<String>{a.Id});
        
        // test valid destination object API name
        CloneRecordsSettings.Destination_sObject_API_Name__c = OriginalDestinationSObjectAPIName; update CloneRecordsSettings;
        DSCB_CloneAnything.CloneToSelected(CloneRecordsSettings.sObject_API_Name__c, c.Id, new List<String>{a.Id});
    }
    
    public static testmethod void ValidateCloneParameters()
    {
        // prepare records for testing
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id;
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        
        Clone_Records_Settings__c CloneRecordsSettings = GetCloneRecordsSettings();
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = getContactCloneDestinationQueryConditions();
        
        // test with invalid destination
        DSCB_CloneAnything.ValidateCloneParameters(
            CloneRecordsSettings, CloneRecordsSettings.sObject_API_Name__c, String.valueOf(c.Id), new List<String>{'a'});
        
        // test with differing destination object types (prefix)
        DSCB_CloneAnything.ValidateCloneParameters(
            CloneRecordsSettings, CloneRecordsSettings.sObject_API_Name__c, String.valueOf(c.Id), new List<String>{'001000000ABCDEF','005000000ABCDEF'});
        
        // test conversion of an invalid destination id
        DSCB_CloneAnything.ValidateCloneParameters(
            CloneRecordsSettings, CloneRecordsSettings.sObject_API_Name__c, String.valueOf(c.Id), new List<String>{'ZZZ000000ABCDEF'});
        
        String[] DestinationList = new String[0];     
        DSCB_CloneAnything.ValidateCloneParameters(CloneRecordsSettings, null, String.valueOf(c.Id), new List<String>{'ZZZ000000ABCDEF'});
        DSCB_CloneAnything.ValidateCloneParameters(CloneRecordsSettings, CloneRecordsSettings.sObject_API_Name__c, String.valueOf(c.Id), null);
        DSCB_CloneAnything.ValidateCloneParameters(CloneRecordsSettings, CloneRecordsSettings.sObject_API_Name__c, String.valueOf(c.Id), DestinationList);
    }
    
    public static testmethod void ValidateSourceIdString()
    {
        // prepare records for testing
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id; 
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        
        DSCB_CloneAnything.ValidateSourceIdString(null); // invalid, null source id
        DSCB_CloneAnything.ValidateSourceIdString('abc'); // invalid, too short source id
        DSCB_CloneAnything.ValidateSourceIdString('ZZZ000000ABCDEF'); // invalid conversion of source id
        DSCB_CloneAnything.ValidateSourceIdString(String.valueOf(c.id)); // valid source id
    }
    
    public static testmethod void ConfigureCloneDisplayFields()
    {
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id; c.Role__c = 'Test Role'; 
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c; // 9/29
        
        // a new User must be inserted because the Clone Display Settings
        //   because the Settings include a User Query
        User u = DS_TestObjects.NewUser_Inserted(); 
        
        List<Clone_Display_Field_Settings__c> CloneDisplayFieldSettings = GetCloneDisplayFieldSettings();
        Clone_Records_Settings__c CloneRecordsSettings = GetCloneRecordsSettings();
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = getContactCloneDestinationQueryConditions();
        
        DSCB_CloneAnything.ConfigureCloneDisplayFields(
            a, CloneRecordsSettings, CloneDisplayFieldSettings, null, new Map<String, DSCB_CloneAnything.ClonedDisplayRecord>());
    }
    
    public static testmethod void SaveClones()
    {
        // prepare records for testing
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id;
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        
        delete [Select Id From Clone_Records_Settings__c];
        Clone_Records_Settings__c CloneRecordsSettings = GetCloneRecordsSettings();
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = getContactCloneDestinationQueryConditions();
        
        delete [Select Id From Clone_Records_Override_Settings__c];
        List<Clone_Records_Override_Settings__c> CloneRecordsOverrideSettings = GetCloneRecordsOverrideSettings();
        
        delete [Select Id From Clone_Display_Field_Settings__c];
        List<Clone_Display_Field_Settings__c> CloneDisplayFieldSettings = GetCloneDisplayFieldSettings();
        
        // perform the clone
        DSCB_CloneAnything.CloneResult cr 
            = DSCB_CloneAnything.CloneToSelected(CloneRecordsSettings.sObject_API_Name__c, c.Id, new List<String>{a.Id});
        
        system.debug(cr);
        system.debug(cr.Results);
        
        Map<String, sObject> Clones = new Map<String, sObject>();
        for(DSCB_CloneAnything.ClonedDisplayRecord cdr : cr.Results) {
            Clones.put(cdr.Destination, cdr.Record);
        }
        map<string, string> nulllookUpFiledsMap = new map<string, string>();
        //DSCB_CloneAnything.SaveClones(CloneRecordsSettings.sObject_API_Name__c, String.valueOf(c.Id), Clones, a, nulllookUpFiledsMap);
        
        DSCB_CloneAnything.SearchSObjectsParameters Parameters = new DSCB_CloneAnything.SearchSObjectsParameters();
        Parameters.SObjectType = CloneRecordsSettings.sObject_API_Name__c;
        Parameters.SourceIdString = String.valueOf(c.Id);
        Parameters.Clones = Clones;
        Parameters.SourceRecordUpdate = a;
        Parameters.LookUpFieldMap = nulllookUpFiledsMap;
        Parameters.DisplayAsOutputFields2 = true;
        
        DSCB_CloneAnything.SaveClonesWithParameters(Parameters);
        
        Parameters.DisplayAsOutputFields2 = false;
        
        DSCB_CloneAnything.SaveClonesWithParameters(Parameters);
            
    } 
    
    public static testmethod Clone_Records_Settings__c GetCloneRecapSettings()
    {
        // clear previous settings
        delete [Select Id From Clone_Records_Settings__c];
        
        Clone_Records_Settings__c RecapSettings = new Clone_Records_Settings__c();
        RecapSettings.Name = 'Recap__c';
        RecapSettings.sObject_API_Name__c = 'Recap__c';
        
        RecapSettings.Source_Autocomplete_Account_Field__c = 'Account__C';
        RecapSettings.Source_Autocomplete_Fields__c = 'Name';
        RecapSettings.Source_Autocomplete_Search_Fields__c = 'Name';
        RecapSettings.Source_Key_Field__c = 'Account__c';
        RecapSettings.Source_Name_Field__c = 'Name';
        RecapSettings.Source_Display_Fields__c = 'Name,Account__r.Name,Recap_Project__c,Product__c,OwnerId,owner.Name,Primary_Contact__c,Status__c';
        RecapSettings.destination_sObject_Relationship_Field__c = 'Account__r';        
        RecapSettings.Destination_sObject_API_Name__c = 'Account';
        RecapSettings.Destination_Display_Fields__c = 'Dealer_Group_Name2__c,Name';
        RecapSettings.Destination_sObject_Account_Field__c = 'Id';
        RecapSettings.Destination_Conditions__c = 'Dynamically';
        RecapSettings.Query_Conditional_Expression__c = '( 1 )'; 
             
                      
        insert RecapSettings;
        return RecapSettings;
    }   
    public static testmethod List<Clone_Records_Override_Settings__c> GetCloneRecapOverrideSettings()
    {
        // clear previous settings
        delete [Select Id From Clone_Records_Override_Settings__c];
        
        List<Clone_Records_Override_Settings__c> RecapOverrides = new List<Clone_Records_Override_Settings__c>();
        
        Clone_Records_Override_Settings__c Override1 = new Clone_Records_Override_Settings__c();
        Override1.Name = 'Recap Field 1';
        Override1.sObject_API_Name__c = 'Recap__C';
        Override1.Query_sObject__c = 'Account';
        Override1.Query_Field_API_Name__c = 'Id';
        Override1.Replacement_Field_API_Name__c = 'Account__c';
        RecapOverrides.add(Override1);
        
        Clone_Records_Override_Settings__c Override2 = new Clone_Records_Override_Settings__c();
        Override2.Name = 'Recap Field 2';
        Override2.sObject_API_Name__c = 'Recap__C';
        Override2.Query_sObject__c = 'Account__c';
        Override2.Query_Field_API_Name__c = 'Name';
        Override2.Replacement_Field_API_Name__c = 'Account__r.Name';
        RecapOverrides.add(Override2);
        
        Clone_Records_Override_Settings__c Override3 = new Clone_Records_Override_Settings__c();
        Override3.Name = 'Recap Field 3';
        Override3.sObject_API_Name__c = 'Recap__C';
        Override3.Query_sObject__c = ' ';
        Override3.Query_Field_API_Name__c = ' ';
        Override3.Replacement_Field_API_Name__c = 'Primary_Contact__c';
        RecapOverrides.add(Override3);
        
        Clone_Records_Override_Settings__c Override4 = new Clone_Records_Override_Settings__c();
        Override4.Name = 'Recap Field 4';
        Override4.sObject_API_Name__c = 'Recap__C';
        Override4.Query_sObject__c = ' ';
        Override4.Query_Field_API_Name__c = ' ';
        Override4.Replacement_Field_API_Name__c = 'Alternate_Contact__c';
        
        Clone_Records_Override_Settings__c Override5 = new Clone_Records_Override_Settings__c();
        Override5.Name = 'Recap Field 5';
        Override5.sObject_API_Name__c = 'Recap__C';
        Override5.Query_sObject__c = 'Account__c';
        Override5.Query_Field_API_Name__c = 'OwnerId';
        Override5.Replacement_Field_API_Name__c = 'OwnerId';
        RecapOverrides.add(Override5);
        
        Clone_Records_Override_Settings__c Override6 = new Clone_Records_Override_Settings__c();
        Override6.Name = 'Recap Field 6';
        Override6.sObject_API_Name__c = 'Recap__C';
        Override6.Query_sObject__c = 'Account__c';
        Override6.Query_Field_API_Name__c = 'Owner.Name';
        //Override6.Replacement_Field_API_Name__c = 'OwnerId';
        RecapOverrides.add(Override6);
        
        insert RecapOverrides;
        return RecapOverrides;
    }
    
    public static testmethod List<Clone_Display_Field_Settings__c> GetCloneRecapDisplayFieldSettings()
    {
        // required fields: Name, Field_API_Name__c, Field_Display_Type__c, sObject_API_Name__c
        
        // clear previous settings
        delete [Select Id From Clone_Display_Field_Settings__c];
        
        List<Clone_Display_Field_Settings__c> CloneRecapDisplayFieldSettings = new List<Clone_Display_Field_Settings__c>();
        
        Clone_Display_Field_Settings__c RecapName = new Clone_Display_Field_Settings__c();
        RecapName.Name = 'Recap 1: Name';
        RecapName.sObject_API_Name__c = 'Recap__c';
        RecapName.Field_API_Name__c = 'Name';
        RecapName.Field_Display_Type__c = 'Link';
        RecapName.Field_Header_text__c = 'Recap Name';
        CloneRecapDisplayFieldSettings.add(RecapName);
        
        Clone_Display_Field_Settings__c RecapAccount = new Clone_Display_Field_Settings__c();
        RecapAccount.Name = 'Recap 2: Account';
        RecapAccount.sObject_API_Name__c = 'Recap__c';
        RecapAccount.Field_API_Name__c = 'Account__r.Name';
        RecapAccount.Field_Display_Type__c = 'Default';
        RecapAccount.Field_Header_text__c = 'Account';
        CloneRecapDisplayFieldSettings.add(RecapAccount);
        
        Clone_Display_Field_Settings__c RecapProject = new Clone_Display_Field_Settings__c();
        RecapProject.Name = 'Recap 3: Recap Project';
        RecapProject.sObject_API_Name__c = 'Recap__c';
        RecapProject.Field_API_Name__c = 'Recap_Project__c';
        RecapProject.Field_Display_Type__c = 'Text';
        RecapProject.Field_Header_text__c = 'Recap Project';
        RecapProject.Field_Display_Type__c = 'invisible';
        CloneRecapDisplayFieldSettings.add(RecapProject);
        
        Clone_Display_Field_Settings__c RecapPrimaryContact = new Clone_Display_Field_Settings__c();
        RecapPrimaryContact.Name = 'Recap 4: Recap Primary Contact';
        RecapPrimaryContact.sObject_API_Name__c = 'Recap__c';
        RecapPrimaryContact.Field_API_Name__c = 'Primary_Contact__c';
        RecapPrimaryContact.Field_Display_Type__c = 'picklist';
        RecapPrimaryContact.Destination_Picklist_Option_Fields__c = 'owner';
        RecapPrimaryContact.Field_Header_text__c = 'Primary Contact';
        RecapPrimaryContact.Relationship__c = 'Account__r';
        RecapPrimaryContact.Destination_Picklist_Option_Fields__c = 'owner';
        RecapPrimaryContact.Field_Options_Query__c = 'Select Id, Name, Account__c, Primary_Contact__r.Name, Account__r.Name, Account__r.OwnerId, Owner.Name From Recap__c';
        RecapPrimaryContact.Field_Options_Query_Text__c = 'Name';
        RecapPrimaryContact.Field_Options_Query_Value__c = 'Id';
        RecapPrimaryContact.Field_Options_Query_Clone_Field__c = 'Account__c';        
        CloneRecapDisplayFieldSettings.add(RecapPrimaryContact);
        
        Clone_Display_Field_Settings__c RecapOwner = new Clone_Display_Field_Settings__c();
        RecapOwner.Name = 'Recap 5: Recap Owner';
        RecapOwner.sObject_API_Name__c = 'Recap__c';
        RecapOwner.Field_API_Name__c = 'Owner.Name';
        RecapOwner.Field_Display_Type__c = 'Text';
        RecapOwner.Field_Header_text__c = 'Owner';
        CloneRecapDisplayFieldSettings.add(RecapOwner);
        
        Clone_Display_Field_Settings__c RecapProduct = new Clone_Display_Field_Settings__c();
        RecapProduct.Name = 'Recap 6: Recap Product__c';
        RecapProduct.sObject_API_Name__c = 'Recap__c';
        RecapProduct.Field_API_Name__c = 'Product__c';
        RecapProduct.Field_Display_Type__c = 'Text';
        RecapProduct.Field_Header_text__c = 'Product';
        CloneRecapDisplayFieldSettings.add(RecapProduct);
        
        Clone_Display_Field_Settings__c RecapStatus = new Clone_Display_Field_Settings__c();
        RecapStatus.Name = 'Recap 7: RecapStatus';
        RecapStatus.sObject_API_Name__c = 'Recap__c';
        RecapStatus.Field_API_Name__c = 'Status__c';
        RecapStatus.Field_Display_Type__c = 'Text';
        RecapStatus.Field_Header_text__c = 'Recap Status ';
        CloneRecapDisplayFieldSettings.add(RecapStatus);
        
        Clone_Display_Field_Settings__c RecapAccountOwnerId = new Clone_Display_Field_Settings__c();
        RecapAccountOwnerId.Name = 'Recap 8: AccountOwnerId';
        RecapAccountOwnerId.sObject_API_Name__c = 'Recap__c';
        RecapAccountOwnerId.Field_API_Name__c = 'Account__r.OwnerId';
        RecapAccountOwnerId.Field_Display_Type__c = 'Default';
        RecapAccountOwnerId.Field_Header_text__c = 'AccountOwner';
        CloneRecapDisplayFieldSettings.add(RecapAccountOwnerId);
        
        Clone_Display_Field_Settings__c RecapAccountOwnerName = new Clone_Display_Field_Settings__c();
        RecapAccountOwnerName.Name = 'Recap 8: AccountOwnerName';
        RecapAccountOwnerName.sObject_API_Name__c = 'Recap__c';
        RecapAccountOwnerName.Field_API_Name__c = 'Account__r.Owner.Name';
        RecapAccountOwnerName.Field_Display_Type__c = 'Default';
        RecapAccountOwnerName.Field_Header_text__c = 'AccountOwnerName';
        CloneRecapDisplayFieldSettings.add(RecapAccountOwnerName);
        
        insert CloneRecapDisplayFieldSettings;
        return CloneRecapDisplayFieldSettings;
    }
    
    public static testmethod void CloneRecapWithProducts()
    {
        List<Recap_Field__c> RecapFields = CB_Recap_Test.GenerateRecapFields();
        
        Account a = DS_TestObjects.NewAccount();
        a.OwnerId = userInfo.getUserId(); insert a;
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id;
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        Recap__c r = new Recap__c(); r.Account__c = a.Id; r.ownerId = userInfo.getUserId(); /*r.Primary_Contact__c = c.Id;*/ insert r;
        
        List<Recap_Product__c> RecapProductsList = new List<Recap_Product__c>();
        
        for(integer i=0;i<1;i++)
        {
            Recap_Product__c rp  = new Recap_Product__c();
            
            //Id websiteId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Recap__c', 'website');           
            rp.recap__c  = r.Id;
            //rp.RecordTypeId = WebsiteId;
            
            RecapProductsList.add(rp);
        }
        
        insert RecapProductsList;
                   
        delete [Select Id From Clone_Records_Settings__c];
        Clone_Records_Settings__c CloneRecapSettings = DSCB_CloneAnything_Test.GetCloneRecapSettings();
        Clone_Records_Settings__c CloneRecapProductSettings = DSCB_CloneAnything_Test.GetCloneRecapProductSettings();
        
        delete [Select Id From Clone_Records_Override_Settings__c];
        List<Clone_Records_Override_Settings__c> CloneRecapOverrideSettings = DSCB_CloneAnything_Test.GetCloneRecapOverrideSettings();
        List<Clone_Records_Override_Settings__c> CloneRecapProductOverrideSettings = DSCB_CloneAnything_Test.GetCloneRecapProductOverrideSettings();
        
        delete [Select Id From Clone_Display_Field_Settings__c];
        List<Clone_Display_Field_Settings__c> CloneRecapDisplayFieldSettings = DSCB_CloneAnything_Test.GetCloneRecapDisplayFieldSettings();
        List<Clone_Display_Field_Settings__c> CloneRecapProductDisplayFieldSettings = DSCB_CloneAnything_Test.GetCloneRecapProductDisplayFieldSettings();
        
        delete [Select Id From Clone_Destination_Query_Condition__c];
               
        // perform the clone
        DSCB_CloneAnything.CloneResult cr 
            = DSCB_CloneAnything.CloneToSelected('Recap__c', r.Id, new List<String>{a.Id});
        system.debug(cr);
        system.debug(cr.results);
        
        Map<String, sObject> Clones = new Map<String, sObject>();
        for(DSCB_CloneAnything.ClonedDisplayRecord cdr : cr.Results) {
            Clones.put(cdr.Destination, cdr.Record);
        }
        
        map<string, string> nullLookUpFieldMap = new map<string, string>();
        
        DSCB_CloneAnything.SaveClones('Recap__c', String.valueOf(r.Id), Clones, r, nullLookUpFieldMap); 
    }
    
    public static testmethod Clone_Records_Settings__c GetCloneRecapProductSettings()
    {
        Clone_Records_Settings__c RecapProductSettings = new Clone_Records_Settings__c();
        RecapProductSettings.Name = 'Recap_product__c';
        RecapProductSettings.sObject_API_Name__c = 'Recap_product__c';
        
        RecapProductSettings.Source_Autocomplete_Account_Field__c = 'Recap_Account__c';
        RecapProductSettings.Source_Autocomplete_Fields__c = 'Name,Recap__r.Account__r.Name';
        RecapProductSettings.Source_Autocomplete_Search_Fields__c = 'Name,Recap__r.Account__r.Name';
        RecapProductSettings.Source_Key_Field__c = 'Recap__c';
        RecapProductSettings.Source_Name_Field__c = 'Name';
        RecapProductSettings.Source_Display_Fields__c = 'Name,Recap__c,Recap__r.Account__c';
        
        RecapProductSettings.Destination_sObject_API_Name__c = 'Recap__c';
        RecapProductSettings.Destination_Display_Fields__c = 'Name, Account__c';
        RecapProductSettings.Destination_sObject_Account_Field__c = 'Account__c';
        RecapProductSettings.Unsearchable__c = true;
               
        insert RecapProductSettings;
        return RecapProductSettings;
    }
    
     public static testmethod List<Clone_Records_Override_Settings__c> GetCloneRecapProductOverrideSettings()
    {
        List<Clone_Records_Override_Settings__c> RecapProductOverrides = new List<Clone_Records_Override_Settings__c>();
        
        Clone_Records_Override_Settings__c Override1 = new Clone_Records_Override_Settings__c();
        Override1.Name = 'Recap Product 1';
        Override1.sObject_API_Name__c = 'Recap_Product__c';
        Override1.Query_sObject__c = 'Recap__c';
        Override1.Query_Field_API_Name__c = 'Account__c';
        Override1.Replacement_Field_API_Name__c = 'Recap_Account__c';
        RecapProductOverrides.add(Override1);
        
        Clone_Records_Override_Settings__c Override2 = new Clone_Records_Override_Settings__c();
        Override2.Name = 'Recap Product 2';
        Override2.sObject_API_Name__c = 'Recap_Product__c';
        Override2.Query_sObject__c = 'Recap__c';
        Override2.Query_Field_API_Name__c = 'Id';
        Override2.Replacement_Field_API_Name__c = 'Recap__c';
        RecapProductOverrides.add(Override2);
        
        Clone_Records_Override_Settings__c Override3 = new Clone_Records_Override_Settings__c();
        Override3.Name = 'Recap Product 3';
        Override3.sObject_API_Name__c = 'Recap_Product__c';
        Override3.Query_sObject__c = '';
        Override3.Query_Field_API_Name__c = '';
        Override3.Replacement_Field_API_Name__c = 'Product_Primary_Contact__c';
        RecapProductOverrides.add(Override3);        
        
        insert RecapProductOverrides;
        return RecapProductOverrides;
    }
    
    public static testmethod List<Clone_Display_Field_Settings__c> GetCloneRecapProductDisplayFieldSettings()
    {

        List<Clone_Display_Field_Settings__c> CloneRecapProductDisplayFieldSettings = new List<Clone_Display_Field_Settings__c>();
        
        Clone_Display_Field_Settings__c RecapProductName = new Clone_Display_Field_Settings__c();
        RecapProductName.Name = 'Recap Product 1: Name';
        RecapProductName.sObject_API_Name__c = 'Recap_product__c';
        RecapProductName.Field_API_Name__c = 'Name';
        RecapProductName.Field_Display_Type__c = 'Link';
        RecapProductName.Field_Header_text__c = 'Recap Product Name';
        CloneRecapProductDisplayFieldSettings.add(RecapProductName);
        
        Clone_Display_Field_Settings__c Recap = new Clone_Display_Field_Settings__c();
        Recap.Name = 'Recap Product 2: Recap';
        Recap.sObject_API_Name__c = 'Recap_product__c';
        Recap.Field_API_Name__c = 'Recap__r.Name';
        Recap.Field_Display_Type__c = 'text';
        Recap.Field_Header_text__c = 'Recap';
        CloneRecapProductDisplayFieldSettings.add(Recap);
        
        
        insert CloneRecapProductDisplayFieldSettings;
        return CloneRecapProductDisplayFieldSettings;
    }
      
    // -- Test Utility Methods
    
    public static testmethod void DisplayPageWarning() 
    {
        delete [Select Id From Clone_Records_Settings__c];
        Clone_Records_Settings__c CloneRecordsSettings = GetCloneRecordsSettings();
        Clone_Destination_Query_Condition__c Contact_CloneDestinationQuery = getContactCloneDestinationQueryConditions();
        DSCB_CloneAnything CloneAnything = new DSCB_CloneAnything();
        CloneAnything.DisplayPageWarning('Test warning...');
    }
    
    public static testmethod void GetDataFromNestedFields() 
    {
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id; c.Role__c = 'Test Role'; 
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c; // 9/29
        
        c = [Select Id, Name, Account.RecordType.Name From Contact Where Id = :c.Id];
        
        // test two levels deep
        Object Data = ALL_UtilitiesData.GetDataFromNestedFields('Account.RecordType.Name', c); system.debug(Data);
    }
    
    public static testmethod void PutDataInNestedFields() 
    {
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id;
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        
        c = [Select Id, Name, Account.RecordType.Name From Contact Where Id = :c.Id];
        Object Data = ALL_UtilitiesData.GetDataFromNestedFields('Account.RecordType.Name', c);
        
        // test two levels deep
        sObject obj = ALL_UtilitiesData.PutDataInNestedFields('Account.RecordType.Name', c, Data); system.debug(obj);
    }
    
    public static testmethod void ListToCSV()
    {
        List<String> ListOfStrings = new List<String>{'a','b','c','d','e'};
        String CsvStrings = ALL_UtilitiesString.ListToCSV(ListOfStrings);
    }
    
    public static testmethod Clone_Records_Settings__c GetCloneTaskRecordsSettings()
    {
        // clear previous settings
        delete [Select Id From Clone_Records_Settings__c];
        
        Clone_Records_Settings__c Settings = new Clone_Records_Settings__c();
        Settings.Name = 'Task:Sales';
        Settings.sObject_API_Name__c = 'Task';
        
        Settings.Source_Autocomplete_Account_Field__c = 'AccountId';
        Settings.Source_Autocomplete_Fields__c = 'Subject,Account.Name';
        Settings.Source_Autocomplete_Search_Fields__c = 'Subject,Account.Name,Type';
        Settings.Source_Key_Field__c = 'AccountId';
        Settings.Source_Name_Field__c = 'Subject';
        Settings.Source_Display_Fields__c = 'Subject,Type,WhatId,Status,ActivityDate,WhoId,Description';
        
        Settings.Destination_sObject_API_Name__c = 'Account';
        Settings.Destination_Display_Fields__c = 'Name';
        Settings.Destination_sObject_Account_Field__c = 'Id';
        Settings.Destination_Conditions__c = ' ';
        Settings.SubType__c = 'Digital Sales';
        
        insert Settings;
        return Settings;
    }
    
    public static testmethod List<Clone_Records_Override_Settings__c> GetCloneTaskRecordsOverrideSettings()
    {
        // clear previous settings
        delete [Select Id From Clone_Records_Override_Settings__c];
        
        List<Clone_Records_Override_Settings__c> TaskOverrides = new List<Clone_Records_Override_Settings__c>();
        
        Clone_Records_Override_Settings__c OverrideAccountId = new Clone_Records_Override_Settings__c();
        OverrideAccountId.Name = 'Task Field 1';
        OverrideAccountId.sObject_API_Name__c = 'Task';
        OverrideAccountId.Query_sObject__c = 'Account';
        OverrideAccountId.Query_Field_API_Name__c = 'Id';
        OverrideAccountId.Replacement_Field_API_Name__c = 'WhatId';
        OverrideAccountId.SubType__c = 'Digital Sales';
        TaskOverrides.add(OverrideAccountId);
        
        Clone_Records_Override_Settings__c Overridewhat = new Clone_Records_Override_Settings__c();
        Overridewhat.Name = 'Task Field 2';
        Overridewhat.sObject_API_Name__c = 'Task';
        Overridewhat.Query_sObject__c = 'Account';
        Overridewhat.Query_Field_API_Name__c = ' ';
        Overridewhat.Replacement_Field_API_Name__c = 'What';
        Overridewhat.SubType__c = 'Digital Sales';
        TaskOverrides.add(Overridewhat);
        
        Clone_Records_Override_Settings__c OverrideName = new Clone_Records_Override_Settings__c();
        OverrideName.Name = 'Task Field 3';
        OverrideName.sObject_API_Name__c = 'Task';
        OverrideName.Query_sObject__c = 'Account';
        OverrideName.Query_Field_API_Name__c = 'Name';
        OverrideName.Replacement_Field_API_Name__c = 'What.Name';
        OverrideName.SubType__c = 'Digital Sales';
        TaskOverrides.add(OverrideName);
        
        insert TaskOverrides;
        return TaskOverrides;
    }
    public static testmethod List<Clone_Display_Field_Settings__c> GetCloneTaskDisplayFieldSettings()
    {
        // required fields: Name, Field_API_Name__c, Field_Display_Type__c, sObject_API_Name__c
        
        // clear previous settings
        delete [Select Id From Clone_Display_Field_Settings__c];
        
        List<Clone_Display_Field_Settings__c> CloneDisplayFieldSettings = new List<Clone_Display_Field_Settings__c>();
        
        Clone_Display_Field_Settings__c TaskName = new Clone_Display_Field_Settings__c();
        TaskName.Name = 'Task: Name';
        TaskName.sObject_API_Name__c = 'task';
        TaskName.Field_API_Name__c = 'Subject';
        TaskName.Field_Display_Type__c = 'Link';
        TaskName.Field_Editable__c = false;
        CloneDisplayFieldSettings.add(TaskName);
        
        insert CloneDisplayFieldSettings;
        return CloneDisplayFieldSettings;
    }
    
    public static testmethod void PerformTaskOverrides() 
    {
        // prepare records for testing
        User TestOwner = DS_TestObjects.NewUser_Inserted();
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id;
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        //Task t = new task(); task.whatId = a.Id; insert t;
        Task t = DS_TestObjects.NewTask();
        t.OwnerId = TestOwner.Id;
        t.WhatId = a.Id;
        t.WhoId = c.Id;
        insert t;
        
        delete [Select Id From Clone_Records_Settings__c];
        Clone_Records_Settings__c ClonetaskRecordsSettings = GetCloneTaskRecordsSettings();
        
        delete [Select Id From Clone_Records_Override_Settings__c];
        List<Clone_Records_Override_Settings__c> CloneTaskRecordsOverrideSettings = GetCloneTaskRecordsOverrideSettings();
        
        delete [Select Id From Clone_Display_Field_Settings__c];
        List<Clone_Display_Field_Settings__c> CloneTaskDisplayFieldSettings = GetCloneTaskDisplayFieldSettings();
        
        DSCB_Cloneanything.SearchSObjectsParameters parameters = new DSCB_Cloneanything.SearchSObjectsParameters();
        parameters.sObjectType = CloneTaskRecordsSettings.sObject_API_Name__c;
        Parameters.sSubType = CloneTaskRecordsSettings.SubType__c;
        Parameters.SourceIdString = t.Id;
        Parameters.DestinationIdsList = new List<String>{a.Id};
        Parameters.SourceRecordUpdate = new task(subject = 'Changed');
        Parameters.DisplayAsOutputFields2 = true;
    
        // test invalid destination object API name
        String OriginalDestinationSObjectAPIName = CloneTaskRecordsSettings.Destination_sObject_API_Name__c;
        CloneTaskRecordsSettings.Destination_sObject_API_Name__c = 'asdfjkl';
        update CloneTaskRecordsSettings;
        DSCB_CloneAnything.CloneToSelectedWithParameters(Parameters);

        // test valid destination object API name
        ClonetaskRecordsSettings.Destination_sObject_API_Name__c = OriginalDestinationSObjectAPIName;
        update CloneTaskRecordsSettings;
        DSCB_CloneAnything.CloneToSelectedWithParameters(Parameters);
        Parameters.DisplayAsOutputFields2 = false;
        DSCB_CloneAnything.CloneToSelectedWithParameters(Parameters);
    }
    
    public static testmethod Clone_Records_Settings__c GetCloneCaseRecordsSettings()
    {
        // clear previous settings
        delete [Select Id From Clone_Records_Settings__c];
        
        Clone_Records_Settings__c Settings = new Clone_Records_Settings__c();
        Settings.Name = 'Case';
        Settings.sObject_API_Name__c = 'Case';
        
        Settings.Source_Autocomplete_Account_Field__c = 'AccountId';
        Settings.Source_Autocomplete_Fields__c = 'CaseNumber,Account.Name,Status';
        Settings.Source_Autocomplete_Search_Fields__c = 'CaseNumber,Account.Name,Status';
        Settings.Source_Key_Field__c = 'AccountId';
        Settings.Source_Name_Field__c = 'CaseNumber';
        Settings.Source_Display_Fields__c = 'CaseNumber,Subject,Status,Reopened_Reason__c,AccountId,ContactId,Dealer_Group_Contact__c,WebID__c';
        
        Settings.Destination_sObject_API_Name__c = 'WebID__c';        
        Settings.Destination_Display_Fields__c = 'Name,Account__c,Locale__c';
        Settings.Destination_sObject_Account_Field__c = 'Account__c';
        Settings.Destination_Conditions__c = ' ';
        Settings.Evaluate_Account_Hierarchy__c = true;
        
        insert Settings;
        return Settings;
    } 
    
    public static testmethod list<Clone_Profile_Access__c> getCloneProfileAccessSettings()
    {
        delete [Select Id From Clone_Profile_Access__c];
        list<Clone_Profile_Access__c> CloneProfileAccessSettings = new list<Clone_Profile_Access__c>();
        
        Clone_Profile_Access__c capSettings1 = new Clone_Profile_Access__c();
        capSettings1.Name = string.valueOf(userInfo.getProfileId());//'00e40000000rAoYAAU';
        capSettings1.Case_Account_Plan__c = true;
        capSettings1.Profile_Id__c = string.valueOf(userInfo.getProfileId());//'00e40000000rAoYAAU';
        
        CloneProfileAccessSettings.add(capSettings1);
        
        insert CloneProfileAccessSettings;
        return CloneProfileAccessSettings;
    }
    
    public static testmethod List<Clone_Display_Field_Settings__c> GetCloneCaseDisplayFieldSettings()
    {
        // required fields: Name, Field_API_Name__c, Field_Display_Type__c, sObject_API_Name__c
        
        // clear previous settings
        delete [Select Id From Clone_Display_Field_Settings__c];
        
        List<Clone_Display_Field_Settings__c> CloneCaseDisplayFieldSettings = new List<Clone_Display_Field_Settings__c>();
        
        Clone_Display_Field_Settings__c CaseName = new Clone_Display_Field_Settings__c();
        CaseName.Name = 'Case: Name';
        CaseName.sObject_API_Name__c = 'Case';
        CaseName.Field_API_Name__c = 'CaseNumber';
        CaseName.Field_Display_Type__c = 'Link';
        CaseName.Field_Editable__c = false;
        CloneCaseDisplayFieldSettings.add(CaseName);
        
        Clone_Display_Field_Settings__c CaseSubject = new Clone_Display_Field_Settings__c();
        CaseSubject.Name = 'Case:Subject';
        CaseSubject.sObject_API_Name__c = 'Case';
        CaseSubject.Field_API_Name__c = 'Subject';
        CaseSubject.Field_Display_Type__c = 'Text';
        CaseSubject.Field_Editable__c = false;
        CloneCaseDisplayFieldSettings.add(CaseSubject);
        
        Clone_Display_Field_Settings__c CaseStat = new Clone_Display_Field_Settings__c();
        CaseStat.Name = 'CaseStatus';
        CaseStat.sObject_API_Name__c = 'Case';
        CaseStat.Field_API_Name__c = 'Status';
        CaseStat.Field_Display_Type__c = 'Text';
        CaseStat.Field_Editable__c = false;
        CloneCaseDisplayFieldSettings.add(CaseStat);
        
        Clone_Display_Field_Settings__c CaseAccount = new Clone_Display_Field_Settings__c();
        CaseAccount.Name = 'CaseStat';
        CaseAccount.sObject_API_Name__c = 'Case';
        CaseAccount.Field_API_Name__c = 'Account.Name';
        CaseAccount.Field_Display_Type__c = 'Link';
        CaseAccount.Field_Editable__c = false;
        CloneCaseDisplayFieldSettings.add(CaseAccount);
        
        Clone_Display_Field_Settings__c CaseWebId = new Clone_Display_Field_Settings__c();
        CaseWebId.Name = 'CaseWeb';
        CaseWebId.sObject_API_Name__c = 'Case';
        CaseWebId.Field_API_Name__c = 'WebId__r.Name';
        CaseWebId.Field_Display_Type__c = 'Link';
        CaseWebId.Field_Editable__c = false;
        CloneCaseDisplayFieldSettings.add(CaseWebId);
        
        Clone_Display_Field_Settings__c CaseDealer = new Clone_Display_Field_Settings__c();
        CaseDealer.Name = 'CaseWebId';
        CaseDealer.sObject_API_Name__c = 'Case';
        CaseDealer.Field_API_Name__c = 'Dealer_Group_Contact__r.Name';
        CaseDealer.Field_Display_Type__c = 'Link';
        CaseDealer.Field_Editable__c = false;
        CloneCaseDisplayFieldSettings.add(CaseDealer);
        
        Clone_Display_Field_Settings__c CaseContactId = new Clone_Display_Field_Settings__c();
        CaseContactId.Name = 'CaseContactId';
        CaseContactId.sObject_API_Name__c = 'Case';
        CaseContactId.Field_API_Name__c = 'ContactId';
        CaseContactId.Field_Display_Type__c = 'Picklist';
        CaseContactId.Field_Editable__c = true;
        CaseContactId.Field_Options_Query__c = 'Select Id, Name, AccountId From Contact Where No_Longer_There__c = false';
        CaseContactId.Field_Options_Query_Text__c = 'Name';
        CaseContactId.Field_Options_Query_Value__c = 'Id';
        CaseContactId.Field_Options_Query_Match__c = 'AccountId';
        CaseContactId.Field_Options_Query_Clone_Field__c = 'AccountId';
        CloneCaseDisplayFieldSettings.add(CaseContactId);
        
        insert CloneCaseDisplayFieldSettings;
        return CloneCaseDisplayFieldSettings;
    }

    public static testmethod void ConfigureCloneCaseDisplayFields()
    {
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact(); c.AccountId = a.Id; 
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        WebId__c w = DS_TestObjects.NewWebID();
        w.Account__c = a.Id;
        insert w;
        Case ca = new Case(); ca.AccountId = a.Id; ca.ContactId = c.Id; ca.webId__c = w.Id; insert ca;
        
        // a new User must be inserted because the Clone Display Settings
        //   because the Settings include a User Query
        User u = DS_TestObjects.NewUser_Inserted(); 
        
        List<Clone_Display_Field_Settings__c> CloneCaseDisplayFieldSettings = GetCloneCaseDisplayFieldSettings();
        Clone_Records_Settings__c CloneCaseRecordsSettings = GetCloneCaseRecordsSettings();
        
        PageReference CloneAnythingPage = Page.DSCB_CloneAnything;
        CloneAnythingPage.getParameters().put('sourcetype', 'Case');
        CloneAnythingPage.getParameters().put('sourceid', ca.Id);
        CloneAnythingPage.getParameters().put('aid', a.Id);
        Test.setCurrentPage(CloneAnythingPage);
        DSCB_CloneAnything CloneAnything = new DSCB_CloneAnything();
        
        DSCB_CloneAnything.ConfigureCloneDisplayFields(
            W, CloneCaseRecordsSettings, CloneCaseDisplayFieldSettings, null, new Map<String, DSCB_CloneAnything.ClonedDisplayRecord>());
    } 
   
}