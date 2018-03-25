@IsTest
public class CB_WebIDAccountTeamMembers_Test
{
    public static testmethod List<Account_Team_Sync_Settings__c> SetupSettings()
    {
        // setup settings
        delete [Select Id From CustomSettings__c];
        CustomSettings__c cs = new CustomSettings__c(); cs.WebIDTriggers_On__c = false; insert cs;
        
        Map<String, String> WEBID_FIELDS = new Map<String, String>//();
        {
            'Account_Advocate__c' => 'Account Advocate',
            'Online_Marketing_Specialist__c' => 'Online Marketing Specialist',
            'OwnerMktg_Specialist_lookup__c' => 'Email Marketing Specialist',
            'Owner_Marketing_DAP__c' => 'Owner Marketing (DAP)',
            'Reputation_Management_Specialist__c' => 'Reputation Management Specialist',
            'SEO_Specialist__c' => 'Search Optimization Specialist',
            'Social_Media_Specialist__c' => 'Social Media Specialist'//,
            //'Account__r.Digital_Services_CAM__c' => 'Digital Services CAM',
            //'Account__r.Digital_Services_GAM__c' => 'Digital Services GAM'
        };
        
        List<Account_Team_Sync_Settings__c> OldSyncSettings
        	= [Select Id, Team_Role__c, User_ID_Field_API_Name__c From Account_Team_Sync_Settings__c];
        
        //for(Account_Team_Sync_Settings__c SyncSetting : OldSyncSettings.clone()) { 
        //	WEBID_FIELDS.put(SyncSetting.User_ID_Field_API_Name__c, SyncSetting.Team_Role__c); }
        
        delete OldSyncSettings;
        List<Account_Team_Sync_Settings__c> Settings = new List<Account_Team_Sync_Settings__c>();
        
        for(String s : WEBID_FIELDS.keySet()) {
            Account_Team_Sync_Settings__c ws = new Account_Team_Sync_Settings__c();
            ws.Name = WEBID_FIELDS.get(s); 
            ws.sObject__c = 'WebID__c';
            ws.Team_Role__c = WEBID_FIELDS.get(s); 
            ws.User_ID_Field_API_Name__c = s;
            Settings.add(ws);
        } insert Settings;
        
        return Settings;
    }
    
    public static testmethod List<Account> GetAllTestAccounts()
    {
        // 2014-10-01 MK pulled in to individual methods because of test errors
        List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
        
        List<Account> Accounts = new List<Account>();
        List<Account_Team__c> AccountTeamMembers = new List<Account_Team__c>();
        List<WebID__c> WebIds = new List<WebID__c>();
        
        // user generation variables
        Integer UserCounter = 1;
        Profile P = DS_TestObjects.getStandardProfile();
        Id StandardProfileId = P != null ? P.Id : null;
        
        // ~1~ an Account with Account Team Members for each role 
        //     that match a single WebID with each Team Member Role field filled in 
        Account a1 = DS_TestObjects.NewAccount_Inserted(); Accounts.add(a1); 
        WebID__c w1 = DS_TestObjects.NewWebID();
        w1.Account__c = a1.Id; // set the Account
        
        // add an Account Team Member for each role to the first account
        //   then add that Account Team Member User to the WebID
        for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
        {
            // set up account team members 
            //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
            
            // 10/1/2014 MK pulled in User creation
            User NewUser = new User(
                UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                Alias='Web'+UserCounter,
                EmailEncodingKey='UTF-8', 
                FirstName='Apex',
                LastName='Test User', 
                LanguageLocaleKey='en_US', 
                LocaleSIDKey='en_US', 
                profileid=StandardProfileId, 
                TimeZoneSIDKey='America/Chicago',
                //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                ADID__c='A'+UserCounter,
                FederationIdentifier = 'F'+UserCounter
            ); 
            
            insert NewUser; UserCounter++;
            
            Account_Team__c NewAccountTeamMember = new Account_Team__c();
            NewAccountTeamMember.Account_Access__c = 'Read/Write';
            NewAccountTeamMember.Case_Access__c = 'Read/Write';
            NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
            NewAccountTeamMember.Team_Member__c = NewUser.Id;
            NewAccountTeamMember.Account__c = a1.Id; 
            NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
            AccountTeamMembers.add(NewAccountTeamMember);
            
            // set up a WebId try to put a value in the field desigated by the Settings
            try { w1.put(WebIDSetting.User_ID_Field_API_Name__c, NewAccountTeamMember.Team_Member__c); } 
            catch(Exception exc) { system.debug(exc); }
        }
        
        WebIds.add(w1);
        
        // ~2~ an Account with Account Team Members for each role
        //     without a WebID that includes the Team Members
        //     this should result in the removal of all Account Team Members
        Account a2 = DS_TestObjects.NewAccount_Inserted(); Accounts.add(a2); 
        WebID__c w2 = DS_TestObjects.NewWebID();
        w2.Account__c = a2.Id; // set the Account
        WebIds.add(w2);
        
        // add an Account Team Member for each role to the second Account
        for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
        {
            // set up account team members 
            //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
            
            // 10/1/2014 MK pulled in User creation
            User NewUser = new User(
                UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                Alias='Web'+UserCounter,
                EmailEncodingKey='UTF-8', 
                FirstName='Apex',
                LastName='Test User', 
                LanguageLocaleKey='en_US', 
                LocaleSIDKey='en_US', 
                profileid=StandardProfileId, 
                TimeZoneSIDKey='America/Chicago',
                //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                ADID__c='A'+UserCounter,
                FederationIdentifier = 'F'+UserCounter
            ); 
            
            insert NewUser; UserCounter++;
            
            Account_Team__c NewAccountTeamMember = new Account_Team__c();
            NewAccountTeamMember.Account_Access__c = 'Read/Write';
            NewAccountTeamMember.Case_Access__c = 'Read/Write';
            NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
            NewAccountTeamMember.Team_Member__c = NewUser.Id;
            NewAccountTeamMember.Account__c = a2.Id; 
            NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
            AccountTeamMembers.add(NewAccountTeamMember);
        }
        
        // ~3~ an Account with WebID Team Members for each role
        //     without Account Team Members
        Account a3 = DS_TestObjects.NewAccount_Inserted(); Accounts.add(a3); 
        WebID__c w3 = DS_TestObjects.NewWebID();
        w3.Account__c = a3.Id; // set the Account
        WebIds.add(w3);
        
        // add an Account Team Member for each role to the second Account
        for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
        {
            User NewUser = new User(
                UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                Alias='Web'+UserCounter,
                EmailEncodingKey='UTF-8', 
                FirstName='Apex',
                LastName='Test User', 
                LanguageLocaleKey='en_US', 
                LocaleSIDKey='en_US', 
                profileid=StandardProfileId, 
                TimeZoneSIDKey='America/Chicago',
                //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                ADID__c='A'+UserCounter,
                FederationIdentifier = 'F'+UserCounter
            ); 
            
            insert NewUser; UserCounter++;
            
            // set up a WebId try to put a value in the field desigated by the Settings
            try { w3.put(WebIDSetting.User_ID_Field_API_Name__c, NewUser.Id); } 
            catch(Exception exc) { system.debug(exc); }
        }
        
        // perform inserts
        insert AccountTeamMembers;
        insert WebIds;
        
        return Accounts;
    }
    
    public static testmethod void GetFieldSettings()
    {
        List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
        CB_WebIDAccountTeamMembers SyncWebIdAccountTeam = new CB_WebIDAccountTeamMembers();
        
        Map<String, String> Fields = SyncWebIdAccountTeam.Settings.getFields();
    }
    
    public static testmethod void BuildQuery()
    {
        List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
        Account a = DS_TestObjects.NewAccount_Inserted();
        CB_WebIDAccountTeamMembers SyncWebIdAccountTeam = new CB_WebIDAccountTeamMembers();
        
        SyncWebIdAccountTeam.BuildQuery(new List<Id>{a.Id}, SyncWebIdAccountTeam.Settings.getFields().keySet());
    }
    
    public static testmethod void GatherAccountIdsFromWebIDs()
    {
        //List<Account> TestAccounts = CB_WebIDAccountTeamMembers_Test.GetAllTestAccounts();
        
        // --- 2014-10-01 MK begin pulled in code
            
            List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
            
            List<Account> TestAccounts = new List<Account>();
            List<Account_Team__c> TestAccountTeamMembers = new List<Account_Team__c>();
            List<WebID__c> TestWebIds = new List<WebID__c>();
            
            // user generation variables
            Integer UserCounter = 1;
            Profile P = DS_TestObjects.getStandardProfile();
            Id StandardProfileId = P != null ? P.Id : null;
            
            // ~1~ an Account with Account Team Members for each role 
            //     that match a single WebID with each Team Member Role field filled in 
            Account a1 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a1); 
            WebID__c w1 = DS_TestObjects.NewWebID();
            w1.Account__c = a1.Id; // set the Account
            
            // add an Account Team Member for each role to the first account
            //   then add that Account Team Member User to the WebID
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                // set up account team members 
                //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
                
                // 10/1/2014 MK pulled in User creation
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                Account_Team__c NewAccountTeamMember = new Account_Team__c();
                NewAccountTeamMember.Account_Access__c = 'Read/Write';
                NewAccountTeamMember.Case_Access__c = 'Read/Write';
                NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
                NewAccountTeamMember.Team_Member__c = NewUser.Id;
                NewAccountTeamMember.Account__c = a1.Id; 
                NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
                TestAccountTeamMembers.add(NewAccountTeamMember);
                
                // set up a WebId try to put a value in the field desigated by the Settings
                try { w1.put(WebIDSetting.User_ID_Field_API_Name__c, NewAccountTeamMember.Team_Member__c); } 
                catch(Exception exc) { system.debug(exc); }
            }
            
            TestWebIds.add(w1);
            
            // ~2~ an Account with Account Team Members for each role
            //     without a WebID that includes the Team Members
            //     this should result in the removal of all Account Team Members
            Account a2 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a2); 
            WebID__c w2 = DS_TestObjects.NewWebID();
            w2.Account__c = a2.Id; // set the Account
            TestWebIds.add(w2);
            
            // add an Account Team Member for each role to the second Account
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                // set up account team members 
                //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
                
                // 10/1/2014 MK pulled in User creation
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                Account_Team__c NewAccountTeamMember = new Account_Team__c();
                NewAccountTeamMember.Account_Access__c = 'Read/Write';
                NewAccountTeamMember.Case_Access__c = 'Read/Write';
                NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
                NewAccountTeamMember.Team_Member__c = NewUser.Id;
                NewAccountTeamMember.Account__c = a2.Id; 
                NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
                TestAccountTeamMembers.add(NewAccountTeamMember);
            }
            
            // ~3~ an Account with WebID Team Members for each role
            //     without Account Team Members
            Account a3 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a3); 
            WebID__c w3 = DS_TestObjects.NewWebID();
            w3.Account__c = a3.Id; // set the Account
            TestWebIds.add(w3);
            
            // add an Account Team Member for each role to the second Account
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                // set up a WebId try to put a value in the field desigated by the Settings
                try { w3.put(WebIDSetting.User_ID_Field_API_Name__c, NewUser.Id); } 
                catch(Exception exc) { system.debug(exc); }
            }
            
            // perform inserts
            insert TestAccountTeamMembers;
            insert TestWebIds;
            
        // --- 2014-10-01 MK end pulled in code
        
        List<Id> TestAccountIds = new List<Id>(); for(Account a : TestAccounts) { TestAccountIds.add(a.Id); }
        //List<Account_Team_Sync_Settings__c> WebIDSettings = Account_Team_Sync_Settings__c.getall().values();
        
        CB_WebIDAccountTeamMembers SyncWebIdAccountTeam = new CB_WebIDAccountTeamMembers();
        
        String q = SyncWebIdAccountTeam.BuildQuery(TestAccountIds, SyncWebIdAccountTeam.Settings.getFields().keySet());
        
        Account a = null;
        List<Account> Accounts = Database.query(q);
        
        if(Accounts != null && !Accounts.IsEmpty()) { a = Accounts[0]; }
        else { a = DS_TestObjects.NewAccount_Inserted(); } 
        
        List<WebID__c> WebIds = a.getSObjects('Sites__r');
        
        SyncWebIdAccountTeam.GatherAccountIdsFromWebIds(WebIds);
    }
    
    public static testmethod void GatherAccountTeamUserIdsByAccountId()
    {
        //List<Account> TestAccounts = CB_WebIDAccountTeamMembers_Test.GetAllTestAccounts();
        
        // --- 2014-10-01 MK begin pulled in code
            
            List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
            
            List<Account> TestAccounts = new List<Account>();
            List<Account_Team__c> TestAccountTeamMembers = new List<Account_Team__c>();
            List<WebID__c> TestWebIds = new List<WebID__c>();
            
            // user generation variables
            Integer UserCounter = 1;
            Profile P = DS_TestObjects.getStandardProfile();
            Id StandardProfileId = P != null ? P.Id : null;
            
            // ~1~ an Account with Account Team Members for each role 
            //     that match a single WebID with each Team Member Role field filled in 
            Account a1 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a1); 
            WebID__c w1 = DS_TestObjects.NewWebID();
            w1.Account__c = a1.Id; // set the Account
            
            // add an Account Team Member for each role to the first account
            //   then add that Account Team Member User to the WebID
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                // set up account team members 
                //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
                
                // 10/1/2014 MK pulled in User creation
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                Account_Team__c NewAccountTeamMember = new Account_Team__c();
                NewAccountTeamMember.Account_Access__c = 'Read/Write';
                NewAccountTeamMember.Case_Access__c = 'Read/Write';
                NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
                NewAccountTeamMember.Team_Member__c = NewUser.Id;
                NewAccountTeamMember.Account__c = a1.Id; 
                NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
                TestAccountTeamMembers.add(NewAccountTeamMember);
                
                // set up a WebId try to put a value in the field desigated by the Settings
                try { w1.put(WebIDSetting.User_ID_Field_API_Name__c, NewAccountTeamMember.Team_Member__c); } 
                catch(Exception exc) { system.debug(exc); }
            }
            
            TestWebIds.add(w1);
            
            // ~2~ an Account with Account Team Members for each role
            //     without a WebID that includes the Team Members
            //     this should result in the removal of all Account Team Members
            Account a2 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a2); 
            WebID__c w2 = DS_TestObjects.NewWebID();
            w2.Account__c = a2.Id; // set the Account
            TestWebIds.add(w2);
            
            // add an Account Team Member for each role to the second Account
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                // set up account team members 
                //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
                
                // 10/1/2014 MK pulled in User creation
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                Account_Team__c NewAccountTeamMember = new Account_Team__c();
                NewAccountTeamMember.Account_Access__c = 'Read/Write';
                NewAccountTeamMember.Case_Access__c = 'Read/Write';
                NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
                NewAccountTeamMember.Team_Member__c = NewUser.Id;
                NewAccountTeamMember.Account__c = a2.Id; 
                NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
                TestAccountTeamMembers.add(NewAccountTeamMember);
            }
            
            // ~3~ an Account with WebID Team Members for each role
            //     without Account Team Members
            Account a3 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a3); 
            WebID__c w3 = DS_TestObjects.NewWebID();
            w3.Account__c = a3.Id; // set the Account
            TestWebIds.add(w3);
            
            // add an Account Team Member for each role to the second Account
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                // set up a WebId try to put a value in the field desigated by the Settings
                try { w3.put(WebIDSetting.User_ID_Field_API_Name__c, NewUser.Id); } 
                catch(Exception exc) { system.debug(exc); }
            }
            
            // perform inserts
            insert TestAccountTeamMembers;
            insert TestWebIds;
            
        // --- 2014-10-01 MK end pulled in code
        
        List<Id> TestAccountIds = new List<Id>(); for(Account a : TestAccounts) { TestAccountIds.add(a.Id); }
        //List<Account_Team_Sync_Settings__c> WebIDSettings = Account_Team_Sync_Settings__c.getall().values();
        
        CB_WebIDAccountTeamMembers SyncWebIdAccountTeam = new CB_WebIDAccountTeamMembers();
        
        String q = SyncWebIdAccountTeam.BuildQuery(TestAccountIds, SyncWebIdAccountTeam.Settings.getFields().keySet());
        List<Account> Accounts = Database.query(q);
        
        Map<Id, Map<Id, Account_Team__c>> AccountTeamUsersByAccountId = new Map<Id, Map<Id, Account_Team__c>>();
        AccountTeamUsersByAccountId = SyncWebIdAccountTeam.GatherAccountTeamUserIdsByAccountId(Accounts);
    }
    
    public static testmethod void GatherUsersByAccountId()
    {
        //List<Account> TestAccounts = CB_WebIDAccountTeamMembers_Test.GetAllTestAccounts();
        
        // --- 2014-10-01 MK begin pulled in code
            
            List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
            
            List<Account> TestAccounts = new List<Account>();
            List<Account_Team__c> TestAccountTeamMembers = new List<Account_Team__c>();
            List<WebID__c> TestWebIds = new List<WebID__c>();
            
            // user generation variables
            Integer UserCounter = 1;
            Profile P = DS_TestObjects.getStandardProfile();
            Id StandardProfileId = P != null ? P.Id : null;
            
            // ~1~ an Account with Account Team Members for each role 
            //     that match a single WebID with each Team Member Role field filled in 
            Account a1 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a1); 
            WebID__c w1 = DS_TestObjects.NewWebID();
            w1.Account__c = a1.Id; // set the Account
            
            // add an Account Team Member for each role to the first account
            //   then add that Account Team Member User to the WebID
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                // set up account team members 
                //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
                
                // 10/1/2014 MK pulled in User creation
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                Account_Team__c NewAccountTeamMember = new Account_Team__c();
                NewAccountTeamMember.Account_Access__c = 'Read/Write';
                NewAccountTeamMember.Case_Access__c = 'Read/Write';
                NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
                NewAccountTeamMember.Team_Member__c = NewUser.Id;
                NewAccountTeamMember.Account__c = a1.Id; 
                NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
                TestAccountTeamMembers.add(NewAccountTeamMember);
                
                // set up a WebId try to put a value in the field desigated by the Settings
                try { w1.put(WebIDSetting.User_ID_Field_API_Name__c, NewAccountTeamMember.Team_Member__c); } 
                catch(Exception exc) { system.debug(exc); }
            }
            
            TestWebIds.add(w1);
            
            // ~2~ an Account with Account Team Members for each role
            //     without a WebID that includes the Team Members
            //     this should result in the removal of all Account Team Members
            Account a2 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a2); 
            WebID__c w2 = DS_TestObjects.NewWebID();
            w2.Account__c = a2.Id; // set the Account
            TestWebIds.add(w2);
            
            // add an Account Team Member for each role to the second Account
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                // set up account team members 
                //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
                
                // 10/1/2014 MK pulled in User creation
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                Account_Team__c NewAccountTeamMember = new Account_Team__c();
                NewAccountTeamMember.Account_Access__c = 'Read/Write';
                NewAccountTeamMember.Case_Access__c = 'Read/Write';
                NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
                NewAccountTeamMember.Team_Member__c = NewUser.Id;
                NewAccountTeamMember.Account__c = a2.Id; 
                NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
                TestAccountTeamMembers.add(NewAccountTeamMember);
            }
            
            // ~3~ an Account with WebID Team Members for each role
            //     without Account Team Members
            Account a3 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a3); 
            WebID__c w3 = DS_TestObjects.NewWebID();
            w3.Account__c = a3.Id; // set the Account
            TestWebIds.add(w3);
            
            // add an Account Team Member for each role to the second Account
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                // set up a WebId try to put a value in the field desigated by the Settings
                try { w3.put(WebIDSetting.User_ID_Field_API_Name__c, NewUser.Id); } 
                catch(Exception exc) { system.debug(exc); }
            }
            
            // perform inserts
            insert TestAccountTeamMembers;
            insert TestWebIds;
            
        // --- 2014-10-01 MK end pulled in code
        
        List<Id> TestAccountIds = new List<Id>(); for(Account a : TestAccounts) { TestAccountIds.add(a.Id); }
        //List<Account_Team_Sync_Settings__c> WebIDSettings = Account_Team_Sync_Settings__c.getall().values();
        
        CB_WebIDAccountTeamMembers SyncWebIdAccountTeam = new CB_WebIDAccountTeamMembers();
        Map<String, String> Fields = SyncWebIdAccountTeam.Settings.getFields();
        
        String q = SyncWebIdAccountTeam.BuildQuery(TestAccountIds, SyncWebIdAccountTeam.Settings.getFields().keySet());
        List<Account> Accounts = Database.query(q);
        
        Map<Id, Map<Id, Account_Team__c>> WebIdUsersByAccountId = new Map<Id, Map<Id, Account_Team__c>>();
        WebIdUsersByAccountId = SyncWebIdAccountTeam.GatherUsersByAccountId(Accounts, Fields);
    }
    
    public static testmethod void InstantiateComparedUsersClass()
    {
        List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
        CB_WebIDAccountTeamMembers SyncWebIdAccountTeam = new CB_WebIDAccountTeamMembers();
        CB_WebIDAccountTeamMembers.ComparedUsers ComparedUsers = new CB_WebIDAccountTeamMembers.ComparedUsers();
    }
    
    public static testmethod void SyncAccountTeamAndWebIdUsers()
    {
        //List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
        //List<Account> TestAccounts = CB_WebIDAccountTeamMembers_Test.GetAllTestAccounts();
        
        // --- 2014-10-01 MK begin pulled in code
            
            List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
            
            List<Account> TestAccounts = new List<Account>();
            List<Account_Team__c> TestAccountTeamMembers = new List<Account_Team__c>();
            List<WebID__c> TestWebIds = new List<WebID__c>();
            
            // user generation variables
            Integer UserCounter = 1;
            Profile P = DS_TestObjects.getStandardProfile();
            Id StandardProfileId = P != null ? P.Id : null;
            
            // ~1~ an Account with Account Team Members for each role 
            //     that match a single WebID with each Team Member Role field filled in 
            Account a1 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a1); 
            WebID__c w1 = DS_TestObjects.NewWebID();
            w1.Account__c = a1.Id; // set the Account
            
            // add an Account Team Member for each role to the first account
            //   then add that Account Team Member User to the WebID
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                // set up account team members 
                //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
                
                // 10/1/2014 MK pulled in User creation
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                Account_Team__c NewAccountTeamMember = new Account_Team__c();
                NewAccountTeamMember.Account_Access__c = 'Read/Write';
                NewAccountTeamMember.Case_Access__c = 'Read/Write';
                NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
                NewAccountTeamMember.Team_Member__c = NewUser.Id;
                NewAccountTeamMember.Account__c = a1.Id; 
                NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
                TestAccountTeamMembers.add(NewAccountTeamMember);
                
                // set up a WebId try to put a value in the field desigated by the Settings
                try { w1.put(WebIDSetting.User_ID_Field_API_Name__c, NewAccountTeamMember.Team_Member__c); } 
                catch(Exception exc) { system.debug(exc); }
            }
            
            TestWebIds.add(w1);
            
            // ~2~ an Account with Account Team Members for each role
            //     without a WebID that includes the Team Members
            //     this should result in the removal of all Account Team Members
            Account a2 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a2); 
            WebID__c w2 = DS_TestObjects.NewWebID();
            w2.Account__c = a2.Id; // set the Account
            TestWebIds.add(w2);
            
            // add an Account Team Member for each role to the second Account
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                // set up account team members 
                //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
                
                // 10/1/2014 MK pulled in User creation
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                Account_Team__c NewAccountTeamMember = new Account_Team__c();
                NewAccountTeamMember.Account_Access__c = 'Read/Write';
                NewAccountTeamMember.Case_Access__c = 'Read/Write';
                NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
                NewAccountTeamMember.Team_Member__c = NewUser.Id;
                NewAccountTeamMember.Account__c = a2.Id; 
                NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
                TestAccountTeamMembers.add(NewAccountTeamMember);
            }
            
            // ~3~ an Account with WebID Team Members for each role
            //     without Account Team Members
            Account a3 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a3); 
            WebID__c w3 = DS_TestObjects.NewWebID();
            w3.Account__c = a3.Id; // set the Account
            TestWebIds.add(w3);
            
            // add an Account Team Member for each role to the second Account
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                // set up a WebId try to put a value in the field desigated by the Settings
                try { w3.put(WebIDSetting.User_ID_Field_API_Name__c, NewUser.Id); } 
                catch(Exception exc) { system.debug(exc); }
            }
            
            // perform inserts
            insert TestAccountTeamMembers;
            insert TestWebIds;
            
        // --- 2014-10-01 MK end pulled in code
        
        CB_WebIDAccountTeamMembers SyncWebIdAccountTeam = new CB_WebIDAccountTeamMembers();
        
        for(Integer i=0; i<TestAccounts.size(); i++) 
        {
            Account a = TestAccounts[i];
            system.debug('Account ~' + (i+1) + '~ Id: ' + a.Id);
            SyncWebIdAccountTeam.SyncAccountTeamAndWebIdUsers(new List<Id>{a.Id}); 
        }
    }
    
    public static testmethod void RemoveAllFieldValuesFromInactiveWebIDs()
    {
        //List<Account> TestAccounts = CB_WebIDAccountTeamMembers_Test.GetAllTestAccounts();
        
        // --- 2014-10-01 MK begin pulled in code
            
            List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
            
            List<Account> TestAccounts = new List<Account>();
            List<Account_Team__c> TestAccountTeamMembers = new List<Account_Team__c>();
            List<WebID__c> TestWebIds = new List<WebID__c>();
            
            // user generation variables
            Integer UserCounter = 1;
            Profile P = DS_TestObjects.getStandardProfile();
            Id StandardProfileId = P != null ? P.Id : null;
            
            // ~1~ an Account with Account Team Members for each role 
            //     that match a single WebID with each Team Member Role field filled in 
            Account a1 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a1); 
            WebID__c w1 = DS_TestObjects.NewWebID();
            w1.Account__c = a1.Id; // set the Account
            
            // add an Account Team Member for each role to the first account
            //   then add that Account Team Member User to the WebID
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                // set up account team members 
                //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
                
                // 10/1/2014 MK pulled in User creation
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                Account_Team__c NewAccountTeamMember = new Account_Team__c();
                NewAccountTeamMember.Account_Access__c = 'Read/Write';
                NewAccountTeamMember.Case_Access__c = 'Read/Write';
                NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
                NewAccountTeamMember.Team_Member__c = NewUser.Id;
                NewAccountTeamMember.Account__c = a1.Id; 
                NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
                TestAccountTeamMembers.add(NewAccountTeamMember);
                
                // set up a WebId try to put a value in the field desigated by the Settings
                try { w1.put(WebIDSetting.User_ID_Field_API_Name__c, NewAccountTeamMember.Team_Member__c); } 
                catch(Exception exc) { system.debug(exc); }
            }
            
            TestWebIds.add(w1);
            
            // ~2~ an Account with Account Team Members for each role
            //     without a WebID that includes the Team Members
            //     this should result in the removal of all Account Team Members
            Account a2 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a2); 
            WebID__c w2 = DS_TestObjects.NewWebID();
            w2.Account__c = a2.Id; // set the Account
            TestWebIds.add(w2);
            
            // add an Account Team Member for each role to the second Account
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                // set up account team members 
                //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
                
                // 10/1/2014 MK pulled in User creation
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                Account_Team__c NewAccountTeamMember = new Account_Team__c();
                NewAccountTeamMember.Account_Access__c = 'Read/Write';
                NewAccountTeamMember.Case_Access__c = 'Read/Write';
                NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
                NewAccountTeamMember.Team_Member__c = NewUser.Id;
                NewAccountTeamMember.Account__c = a2.Id; 
                NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
                TestAccountTeamMembers.add(NewAccountTeamMember);
            }
            
            // ~3~ an Account with WebID Team Members for each role
            //     without Account Team Members
            Account a3 = DS_TestObjects.NewAccount_Inserted(); TestAccounts.add(a3); 
            WebID__c w3 = DS_TestObjects.NewWebID();
            w3.Account__c = a3.Id; // set the Account
            TestWebIds.add(w3);
            
            // add an Account Team Member for each role to the second Account
            for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
            {
                User NewUser = new User(
                    UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                    Alias='Web'+UserCounter,
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User', 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileid=StandardProfileId, 
                    TimeZoneSIDKey='America/Chicago',
                    //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                    ADID__c='A'+UserCounter,
                    FederationIdentifier = 'F'+UserCounter
                ); 
                
                insert NewUser; UserCounter++;
                
                // set up a WebId try to put a value in the field desigated by the Settings
                try { w3.put(WebIDSetting.User_ID_Field_API_Name__c, NewUser.Id); } 
                catch(Exception exc) { system.debug(exc); }
            }
            
            // perform inserts
            insert TestAccountTeamMembers;
            insert TestWebIds;
            
        // --- 2014-10-01 MK end pulled in code
        
        List<Id> TestAccountIds = new List<Id>(); for(Account a : TestAccounts) { TestAccountIds.add(a.Id); }
        List<WebID__c> WebIdsToUpdate = new List<WebID__c>();
        
        CB_WebIDAccountTeamMembers SyncWebIdAccountTeam = new CB_WebIDAccountTeamMembers();
        String q = SyncWebIdAccountTeam.BuildQuery(TestAccountIds, SyncWebIdAccountTeam.Settings.getFields().keySet());
        
        List<Account> Accounts = Database.query(q);
        
        for(Account a : Accounts) 
        {
            List<WebID__c> WebIds = a.getSObjects('Sites__r');
            system.debug(WebIds);
            
            if(WebIds != null && !WebIds.IsEmpty()) {
                for(WebID__c w : WebIds) { w.Status__c = 'Inactive'; WebIdsToUpdate.add(w); }
            }
        }
        
        update WebIdsToUpdate;
        
        Accounts = Database.query(q); // requery after update
        List<WebID__c> InactiveWebIds = SyncWebIdAccountTeam.RemoveAllFieldValuesFromInactiveWebIDs(Accounts);
    }
    
    public static testmethod void ProcessIfBatchSizeIsOne()
    {
        Account a1 = DS_TestObjects.NewAccount_Inserted();
        WebID__c w = DS_TestObjects.NewWebID(); w.Account__c = a1.Id;
        User u = DS_TestObjects.NewAdminUser();
        
        CB_WebIDAccountTeamMembers SyncWebIdAccountTeam = new CB_WebIDAccountTeamMembers();
        
        w = SyncWebIdAccountTeam.ProcessIfBatchSizeIsOne(10, w);
    }
    
    public static testmethod void WebIdTriggerSimulation()
    {
        List<Account_Team_Sync_Settings__c> WebIDSettings = CB_WebIDAccountTeamMembers_Test.SetupSettings();
        
        Account a1 = DS_TestObjects.NewAccount_Inserted();
        WebID__c o = DS_TestObjects.NewWebID(); o.Account__c = a1.Id;
        
        List<Account_Team__c> AccountTeamMembers = new List<Account_Team__c>();
        
        // user generation variables
        Integer UserCounter = 1;
        Profile P = DS_TestObjects.getStandardProfile();
        Id StandardProfileId = P != null ? P.Id : null;
        
        for(Account_Team_Sync_Settings__c WebIDSetting : WebIDSettings) 
        {
            // set up account team members 
            //Account_Team__c atm = DS_TestObjects.NewAccountTeamMember();
            
            // 10/1/2014 MK pulled in User creation
            User NewUser = new User(
                UserName='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                Email='test-WebIDAccountTeamMembers-'+UserCounter+'@cdk.com', 
                Alias='Web'+UserCounter,
                EmailEncodingKey='UTF-8', 
                FirstName='Apex',
                LastName='Test User', 
                LanguageLocaleKey='en_US', 
                LocaleSIDKey='en_US', 
                profileid=StandardProfileId, 
                TimeZoneSIDKey='America/Chicago',
                //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
                ADID__c='A'+UserCounter,
                FederationIdentifier = 'F'+UserCounter
            ); 
            
            insert NewUser; UserCounter++;
            
            Account_Team__c NewAccountTeamMember = new Account_Team__c();
            NewAccountTeamMember.Account_Access__c = 'Read/Write';
            NewAccountTeamMember.Case_Access__c = 'Read/Write';
            NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
            NewAccountTeamMember.Team_Member__c = NewUser.Id;
            NewAccountTeamMember.Account__c = a1.Id; 
            NewAccountTeamMember.Team_Role__c = WebIDSetting.Team_Role__c;
            AccountTeamMembers.add(NewAccountTeamMember);
            
            // set up a WebId try to put a value in the field desigated by the Settings
            try { o.put(WebIDSetting.User_ID_Field_API_Name__c, NewAccountTeamMember.Team_Member__c); } 
            catch(Exception exc) { system.debug(exc); }
        }
        
        insert AccountTeamMembers;
        insert o;
        
        Account a2 = DS_TestObjects.NewAccount_Inserted();
        
        WebID__c n = o.clone(false, true);
        n.Account__c = a2.Id;
        insert n;
        
        CB_WebIDAccountTeamMembers SyncWebIdAccountTeam = new CB_WebIDAccountTeamMembers();
        
        SyncWebIdAccountTeam.FilterWebIDsToProcessFromWebIdTrigger(new Map<Id, WebID__c> { o.Id => o }, new Map<Id, WebID__c> { n.Id => n });
    }
    
}