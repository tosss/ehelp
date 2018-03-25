/* ADP Dealer Services - Sales Automation
 * Programmer: Matt Keefe (matt_keefe@adp.com)
 * Class: DS_TestObjects
 * Description: Generates test objects for use in unit test classes to prevent redundancy.
 * 
 * Test Code for developing tests:
  // First, search and replace [testmethod] with []
    System.Savepoint sp = Database.setSavePoint();
    List<Account> accounts = DS_TestObjects.OneHundredNewAccounts_Inserted();
    for(Account a : accounts) { system.debug(a); }
    Database.rollback(sp);
  // Last, search and replace [static] with [static testmethod]
 * --------History------------
 * 2015-06-17 - hemanth.kesapragada@cdk.com - RQ-04227 Changed custom object to custom setting
 * 07/07/15 - Venkata Shrivol  - Added Discovery Object references
 * 2015-11-06 - vishal.bandari@cdk.com  - changed NewLaserArtworkOrders method 
 */ 
//2016-02-24- anirudh.singh@cdk.com-   Commented Account__r.Digital_Services_CAM__c record in getAcountTeamSyncSettings method.
//2016-05-05- venkata.shrivol@cdk.com -added newContactRelationship method for Contact Relationship Object
//2016-05-30 - vishal.bandari@cdk.com - added New_DealState and New_DealState_Inserted method for DealState Object
//2016-06-06- venkata.shrivol@cdk.com -added user insertion dml statement in NewLaserArtworkOrder method  
//2016-06-16 -venkata.shrivol@cdk.com -changed email address from cdk to cdkglobal in randomUSerNAme method
//2016-10-10 -venkata.shrivol@cdk.com  - Changed the like selector of query from LFD to FFC - Forms in NewLaserArtworkOrder method 
//2017-04-03 - Siva.Pragada@cdk.com - added newContactRelationship_Inserted() method and additional values in newContactRelationship()
//2017-04-21 - ragashalini.koka@cdk.com - Added PartyId__c for Account due to validation rule on the Opportunity Location
@IsTest
public class DS_TestObjects
{
    public static Profile getStandardProfile()
    {
       profile P = [Select Id, Name From Profile Where Name = 'Standard User' Limit 1];
       return P;
    }
    
    public static Profile getAdminProfile()
    {
       profile P = [Select Id, Name From Profile Where Name = 'ADPDS - Admin - System Administrator' Limit 1];
       return P;
    }
    
    // 0 dml, 1 soql
    public static testmethod User CurrentUser()
    {
        User CurrentUser = [Select Id from User where Id = :UserInfo.getUserId()];
        return CurrentUser;
    }
    
    public static testmethod String NextTestUserRandom()
    {
        String Random = DS_TestObjects.TrueRandomUpToAMillion(); system.debug(Random);
        
        // get any existing users and increment
        list<User> ExistingTestUsers = new list<User>();
        list<AggregateResult> MaxUsers = [Select MAX(UserName)m From User Where UserName like 'test-%'];
        
        String MaxUserName = null; 
        if(MaxUsers != null && !MaxUsers.isEmpty()) { MaxUserName = String.valueOf(MaxUsers[0].get('m')); }
        
        if(MaxUserName != null)
        {
            if(MaxUserName.contains('@') && MaxUserName.length() > 5)
            {
                try
                {
                    // increment
                    Integer IncrementedTestNumber = 
                        Integer.valueOf(MaxUserName.substring(5, MaxUserName.indexOf('@'))) + 1; 
                    
                    Random = String.valueOf(IncrementedTestNumber);
                }
                // if there is an error use the TrueRandomUpToAMillion value, so do not reset it
                catch(Exception e) { }
            }
        }
        
        return Random;
    }
    
    public static testmethod String TrueRandomUpToAMillion()
    {
        String Random = String.valueOf( Math.round( Math.random() * 1000 ) * DateTime.now().millisecond() );
        return Random;
    }
    
    public static testmethod Campaign_Member_Status__c NewCampaignMemberStatus()
    {
        Campaign_Member_Status__c NewCampaignMemberStatus = new Campaign_Member_Status__c();
        NewCampaignMemberStatus.Campaign__c = DS_TestObjects.NewCampaign_Inserted().Id;
        NewCampaignMemberStatus.Name = 'Not Contacted Yet';
        return NewCampaignMemberStatus;
    }
    
    public static testmethod Campaign_Member_Status__c NewCampaignMemberStatus_Inserted()
    {
        Campaign_Member_Status__c NewCampaignMemberStatus = DS_TestObjects.NewCampaignMemberStatus();
        NewCampaignMemberStatus.Name = 'Test';
        insert NewCampaignMemberStatus;
        return NewCampaignMemberStatus;
    }
    //2016-06-16 -venkata.shrivol@cdk.com -changed email address from cdk to cdkglobal
    public static testmethod String RandomUserName()
    {
        String Random = DS_TestObjects.TrueRandomUpToAMillion();
        
        string UserExtensionDefault = 'apex-test-objects';
        string UserExtension = UserExtensionDefault;
        
        try
        {
            UserExtension = UserExtension.substring(UserExtension.lastIndexOf('.')+1, UserExtension.length());
            if(UserExtension == 'com') { UserExtension = UserExtensionDefault; }
        } catch (Exception ex) { UserExtension = 'apex-test-objects'; }
        
        return 'test-'+Random+'-'+UserExtension+'@cdkglobal.com';
    }
    
    // 1 dml, 3 soql
    public static testmethod User NewUser_Inserted() 
    { 
        User u = DS_TestObjects.NewUser(); //system.debug(u); 
        
        system.runas(DS_TestObjects.CurrentUser()) { insert u; } 
        return u; 
    }
    
    // added this because an additional user was needed for the same testmethod
    public static testmethod User NewSecondUser_Inserted() 
    { 
        User u = DS_TestObjects.NewUser(); //system.debug(u); 
        
        system.runas(DS_TestObjects.CurrentUser()) { insert u; } 
        return u; 
    }
    
    // 0 dml, 3 soql
    public static testmethod User NewUser()
    {
        // default to true random
        String Random = DS_TestObjects.NextTestUserRandom(); system.debug(Random);
        Profile P = DS_TestObjects.getStandardProfile();
        Id StandardProfileId = P != null ? P.Id :null;
        
        User NewUser = new User(
            UserName='test-'+Random+'@cdk.com', 
            Email='test-'+Random+'@cdk.com', 
            Alias=Random.length()>8?Random.substring(4, Random.length()):Random,
            EmailEncodingKey='UTF-8', 
            FirstName='Apex',
            LastName='Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid=StandardProfileId, 
            TimeZoneSIDKey='America/Chicago',
            //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
            ADID__c='A'+Random,
            FederationIdentifier = 'F'+Random
        );
        
        return NewUser;
    }
    
    // 1 dml, 4 soql
    public static testmethod User NewAdminUser_Inserted() 
    { 
        User u = NewAdminUser(); //system.debug(u); 
        
        system.runas(DS_TestObjects.CurrentUser()) { insert u; } 
        return u; 
    }
    
    // 0 dml, 3 soql
    public static testmethod User NewAdminUser()
    {
        String Random = DS_TestObjects.NextTestUserRandom(); system.debug(Random);
        Id AdminProfileId 
            = [Select Id, Name From Profile Where PermissionsModifyAllData = true And PermissionsApiEnabled = true Limit 1].Id;
        
        User NewUser = new User(
            UserName='test-'+Random+'@cdk.com', 
            Email='test-'+Random+'@cdk.com', 
            Alias='a'+Random,
            EmailEncodingKey='UTF-8', 
            FirstName='Apex',
            LastName='Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid=AdminProfileId, 
            //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
            TimeZoneSIDKey='America/Chicago',
            ADID__c='A'+Random,
            FederationIdentifier = 'F'+Random
        );
        
        return NewUser;
    }
    
    // 1 dml, 1 soql
    public static testmethod Account NewAccount_Inserted()
    {
        Account NewAccount = DS_TestObjects.NewAccount();
        
        system.runas(DS_TestObjects.CurrentUser()) { insert NewAccount; }
        return NewAccount;
    }
    
    // 0 dml, 0 soql
    public static testmethod Account NewAccount()
    {
        Account NewAccount = new Account(
            Name = 'Test Account',
            PartyID__c = EncodingUtil.convertToHex(Crypto.generateAesKey(128)).substring(0,7)
        );
        
        return NewAccount;
    }
    
    // 0 dml, 0 soql
    public static testmethod Site_Type__c NewSiteType()
    {
        Site_Type__c NewSiteType = new Site_Type__c(Name='Test Site Type', Active__c=true);
        return NewSiteType;
    }
    
    // 1 dml, 0 soql
    public static testmethod Site_Type__c NewSiteType_Inserted()
    {
        Site_Type__c NewSiteType = new Site_Type__c(Name='Test Site Type', Active__c=true);
        
        insert NewSiteType;
        return NewSiteType;
    }
    
    // 1 dml, 1 soql
    public static testmethod Contact NewContact_Inserted()
    {
        Contact NewContact = DS_TestObjects.NewContact();
        //NewContact.Role__c = 'Test Role'; // 9/29
        
        system.runas(DS_TestObjects.CurrentUser()) { insert NewContact; }
        return NewContact;
    }
    
    // 0 dml, 0 soql
    public static testmethod Contact NewContact()
    {
        Contact NewContact = new Contact(
            LastName = 'TEST Last Name',
            FirstName = 'TEST First Name',
            Title__c = 'Manager',
            Department__c = 'Service',
            Email = DS_TestObjects.RandomUserName()
            //,Role__c='Test Role'                             
        );
        
        return NewContact;
    }
    
    public static testMethod Contact_Relationship__c newContactRelationship()
    {
        Account newAccount = DS_TestObjects.NewAccount_Inserted();
        Contact newContact = DS_TestObjects.NewContact_Inserted();
        
        Contact_Relationship__c crs = new Contact_Relationship__c();
        crs.Role__c = 'Test Role';
        crs.Account__c = newAccount.ID;
        crs.Contact__c = newContact.ID;
        crs.Phone__c = '206-206-2062';
        
        return crs;
    }
    
    public static testMethod Contact_Relationship__c newContactRelationship_Inserted()
    {
        Contact_Relationship__c crs = DS_TestObjects.newContactRelationship();
        insert crs;
        
        return crs;
    }
    
    // 2 dml, 2 soql
    public static testmethod Lead NewLead_Inserted()
    {
        Lead NewLead = DS_TestObjects.NewLead();
        NewLead.Current_Account__c = DS_TestObjects.NewAccount_Inserted().Id;
        
        system.runas(DS_TestObjects.CurrentUser()) { insert NewLead; } // 1 soql, 1 dml
        return NewLead;
    }
    
    // 0 dml, 0 soql
    public static testmethod Lead NewLead()
    {
        Lead NewLead = new Lead(
            LastName='TEST Lead Last Name',
            FirstName='TEST Lead First Name',
            Company='TEST Company',
            LeadSource='API',
            Status='Rep Attempted Contact'
        );
        
        return NewLead;
    }
    
    public static testmethod Case NewCase()
    {
        Case NewCase = new Case();
        return NewCase;
    }
    
    // 2 dml, 2 soql
    public static testmethod Opportunity NewOpportunity_Inserted()
    {
        Opportunity NewOpportunity = DS_TestObjects.NewOpportunity();
        NewOpportunity.AccountId = DS_TestObjects.NewAccount_Inserted().Id;
        
        system.runas(DS_TestObjects.CurrentUser()) { insert NewOpportunity; } // 1 soql, 1 dml
        return NewOpportunity;
    }
    
    // 0 dml, 0 soql
    public static testmethod Opportunity NewOpportunity()
    {
        String CurrentUserInitials = '';
        
        if(UserInfo.getFirstName() != null && UserInfo.getLastName() != null) {
            CurrentUserInitials = UserInfo.getFirstName().substring(0,1)+UserInfo.getLastName().substring(0,1);
        }
        else {
            CurrentUserInitials = 'IU'; // integration user
        }
        
        Opportunity NewOpportunity = new Opportunity(
            Name=CurrentUserInitials+' - '+'TEST Opportunity',
            ADP_Opportunity_Owner__c=UserInfo.getUserId(),
            CloseDate=Date.today(),
            StageName='Plan',
            Type='Add-on'
        );
        
        return NewOpportunity;
    }
    
     // 2016/05/30 - vishal.bandari@ck.com - added method to insert Deal_State__c 
    public static testmethod Deal_State__c New_DealState()
    {
        Deal_State__c newDealState = new Deal_State__c();
        return newDealState;
    }
    
    // 2016/05/30 - vishal.bandari@ck.com - added method to insert Deal_State__c
    public static testmethod Deal_State__c New_DealState_Inserted()
    {
        Deal_State__c newDealState = new Deal_State__c();
        Opportunity newOpportunity = DS_TestObjects.NewOpportunity_Inserted();
        newDealState.Opportunity__c = newOpportunity.Id;
        return newDealState;
    }
    
    // 1 dml, 1 soql
    public static testmethod Campaign NewCampaign_Inserted()
    {
        Campaign NewCampaign = DS_TestObjects.NewCampaign();
        
        User u = new User();
            u.Firstname = 'Test';
            u.Lastname = 'User';
            u.Title = 'TestUser';
            u.Street = '1950 Hassel Rd.';
            u.City = 'Hoffman Estates';
            u.State = 'IL';
            u.Username = 'tuser@adp.com';
            u.email = 'test@adp.com';
            u.alias = 'testuser';
            u.MobilePhone = '2342342343';
            u.Fax = '3453453454';
            u.Extension = '3344';
            u.Country = 'USA';
            u.TimeZoneSidKey = 'America/Chicago';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'ISO-8859-1';
            u.ProfileId = [select id from profile where name = 'ADPDS - Admin - System Administrator'].id;
            u.LanguageLocaleKey = 'en_US';
            u.ADID__c = 'testuse';
        insert u;
        
        //system.runas(DS_TestObjects.CurrentUser()) { insert NewCampaign; } // 1 soql, 1 dml
        
        system.runas(u) {insert NewCampaign;} // 1 soql, 1 dml
        return NewCampaign;
    }
    
    // 0 dml, 0 soql
    public static testmethod Campaign NewCampaign()
    {
        Campaign NewCampaign = new Campaign(Name='TEST Campaign'
            ,Campaign_Source__c='Retail Solutions'
            ,StartDate=Date.today()
            ,EndDate=Date.today()
            ,IsActive=true
        );
        
        return NewCampaign;
    }
    
    // 9 dml, 6 soql
    public static testmethod Campaign_Account_Members__c NewCampaignAccountMember_WithTaskAndEvent_Inserted()
    {
        Campaign_Account_Members__c CampaignAccountMember = NewCampaignAccountMember_WithSystemAtDealership_Inserted(); // 5 dml, 2 soql
        
        User TestOwner = DS_TestObjects.NewUser_Inserted(); // 1 dml, 3 soql
        Contact TestContact = DS_TestObjects.NewContact(); // 0 dml, 0 soql
        TestContact.Role__c = 'Test Role'; // 9/29
        
        TestContact.AccountId = CampaignAccountMember.Account__c;
        system.RunAs(DS_TestObjects.CurrentUser()) { insert TestContact; } // 1 dml, 1 soql
        
        Task t = DS_TestObjects.NewTask();
        t.OwnerId = TestOwner.Id;
        t.WhatId = CampaignAccountMember.Account__c;
        t.WhoId = TestContact.Id;
        
        Event e = DS_TestObjects.NewEvent();
        e.OwnerId = TestOwner.Id;
        e.WhatId = CampaignAccountMember.Account__c;
        e.WhoId = TestContact.Id;
        
        system.RunAs(DS_TestObjects.CurrentUser()) { insert t; insert e; } // 2 dml, 0 soql
        system.debug('New Task: ' + t); system.debug('New Event: ' + e);
        
        return CampaignAccountMember;
    }
    
    // 5 dml, 2 soql
    public static testmethod Campaign_Account_Members__c NewCampaignAccountMember_WithSystemAtDealership_Inserted()
    {
        Campaign_Account_Members__c NewCampaignAccountMember = NewCampaignAccountMember_WithSystemAtDealership();
        insert NewCampaignAccountMember;
        return NewCampaignAccountMember;
    }
    
    // 4 dml, 2 soql
    public static testmethod Campaign_Account_Members__c NewCampaignAccountMember_WithSystemAtDealership()
    {
        System_at_Dealership__c NewSystemAtDealership = DS_TestObjects.NewSystemAtDealership_Inserted();
        Campaign NewCampaign = NewCampaign_Inserted();
        
        Campaign_Account_Members__c NewCampaignAccountMember = new Campaign_Account_Members__c();
        NewCampaignAccountMember.Account__c = NewSystemAtDealership.Account__c;
        NewCampaignAccountMember.Campaign__c = NewCampaign.Id;
        NewCampaignAccountMember.Campaign_Member_Status__c = 'Not Contacted Yet';
        
        return NewCampaignAccountMember;
    }
    
    // 3 dml, 1 soql
    public static testmethod System_at_Dealership__c NewDMSSystemAtDealership_Inserted()
    {
        System_at_Dealership__c NewDMSSystemAtDealership = DS_TestObjects.NewDMSSystemAtDealership();
        insert NewDMSSystemAtDealership;
        return NewDMSSystemAtDealership;
    }
    
    // 2 dml, 2 soql
    public static testmethod System_at_Dealership__c NewDMSSystemAtDealership()
    {
        System_at_Dealership__c NewSystemAtDealership = DS_TestObjects.NewSystemAtDealership();
        
        List<RecordType> DMSRecordType = [
            Select Id 
            From RecordType 
            Where sObjectType='System_at_Dealership__c' 
            And Name like '%DMS%' Limit 1
        ];
        
        if(DMSRecordType != null && !DMSRecordType.IsEmpty()) {
            NewSystemAtDealership.RecordTypeId = DMSRecordType[0].Id; }
        
        return NewSystemAtDealership;
    }
    
    // 3 dml, 1 soql
    public static testmethod System_at_Dealership__c NewSystemAtDealership_Inserted()
    {
        System_at_Dealership__c NewSystemAtDealership = DS_TestObjects.NewSystemAtDealership();
        insert NewSystemAtDealership;
        return NewSystemAtDealership;
    }
    
    // 2 dml, 1 soql
    public static testmethod System_at_Dealership__c NewSystemAtDealership()
    {
        Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        Systems__c NewSystem = DS_TestObjects.NewDMSSystem_Inserted();
        
        System_at_Dealership__c NewSystemAtDealership = new System_at_Dealership__c();
        
        NewSystemAtDealership.Account__c = NewAccount.Id;
        NewSystemAtDealership.Vendor__c = NewSystem.Id;
        NewSystemAtDealership.Box_Onsite__c = false;
        NewSystemAtDealership.Install_Date__c = Date.Today();
        NewSystemAtDealership.Sold_Date__c = Date.Today();
        NewSystemAtDealership.System_Type__c = 'DMS';
        
        return NewSystemAtDealership;
    }
    
    // 1 dml, 0 soql
    public static testmethod Systems__c NewDMSSystem_Inserted()
    {
        Systems__c NewSystem = DS_TestObjects.NewDMSSystem();
        insert NewSystem;
        return NewSystem;
    }
    
    // 0 dml, 0 soql
    public static testmethod Systems__c NewDMSSystem()
    {
        Systems__c NewSystem = new Systems__c();
        NewSystem.Active__c = true;
        NewSystem.Name = 'Test DMS System';
        NewSystem.Type__c = 'DMS';
        NewSystem.SLXSystem_ID__c = 'TEST01234567';

        //randomize the SLX Vendor ID         
        Schema.DescribeFieldResult dfr = Systems__c.SLXVendor_ID__c.getDescribe();
        integer len = dfr.getLength();
        string num = DS_TestObjects.TrueRandomUpToAMillion();
        string newNum = 'TEST' + num.leftPad(len - 4).replace(' ','0');
        NewSystem.SLXVendor_ID__c = newNum;
        
        return NewSystem;
    }
    
    public static testMethod Systems__c NewCRMSystem()
    {
        Systems__c NewSystem = new Systems__c();
        NewSystem.Active__c = true;
        NewSystem.Name = 'Test CRM System';
        NewSystem.Type__c = 'CRM';
        NewSystem.SLXSystem_ID__c = 'TEST01234567';

        //randomize the SLX Vendor ID         
        Schema.DescribeFieldResult dfr = Systems__c.SLXVendor_ID__c.getDescribe();
        integer len = dfr.getLength();
        string num = DS_TestObjects.TrueRandomUpToAMillion();
        string newNum = 'TEST' + num.leftPad(len - 4).replace(' ','0');
        NewSystem.SLXVendor_ID__c = newNum;
        
        return NewSystem;       
    }    
    
    // 4 dml, 6 soql
    public static testmethod Task NewTask_Inserted()
    {
        Task t = DS_TestObjects.NewTask();
        
        User TestOwner = DS_TestObjects.NewUser_Inserted(); // 1 dml, 3 soql
        Account TestAccount = DS_TestObjects.NewAccount_Inserted(); // 1 dml, 1 soql
        Contact TestContact = DS_TestObjects.NewContact(); // 0 dml, 0 soql
        
        TestContact.AccountId = TestAccount.Id;
        TestContact.Role__c = 'Test Role'; // 9/29
        system.runas(DS_TestObjects.CurrentUser()) { insert TestContact; } // 1 dml, 1 soql
        
        t.OwnerId = TestOwner.Id;
        t.WhatId = TestAccount.Id;
        t.WhoId = TestContact.Id;
        //t.AccountId = TestAccount.Id;
        
        system.runas(DS_TestObjects.CurrentUser()) { insert t; }
        system.debug('New Task: ' + t);
        return t;
    }
    
    // 0 dml, 0 soql
    public static testmethod Task NewTask()
    {
        Task NewTask = new Task(
            Subject='Test Task',
            Status='Completed',
            ActivityDate=Date.today().addDays(-7),
            Completed_Date__c=Date.today()
        );
        
        return NewTask;
    }
    
    // 4 dml, 6 soql
    public static testmethod Event NewEvent_Inserted()
    {
        Event e = DS_TestObjects.NewEvent();
        
        User TestOwner = DS_TestObjects.NewUser_Inserted(); // 1 dml, 3 soql
        Account TestAccount = DS_TestObjects.NewAccount_Inserted(); // 1 dml, 1 soql
        Contact TestContact = DS_TestObjects.NewContact(); // 0 dml, 0 soql
        
        TestContact.AccountId = TestAccount.Id;
        TestContact.Role__c = 'Test Role'; // 9/29
        system.runas(DS_TestObjects.CurrentUser()) { insert TestContact; } // 1 dml, 1 soql
        
        e.OwnerId = TestOwner.Id;
        e.WhatId = TestAccount.Id;
        e.WhoId = TestContact.Id;
        
        system.runas(DS_TestObjects.CurrentUser()) { insert e; } // 1 dml, 1 soql
        system.debug('New Event: ' + e);
        return e;
    }
    
    // 0 dml, 0 soql
    public static testmethod Event NewEvent()
    {
        Date aWeekAgoDate = Date.today().addDays(-7);
        DateTime aWeekAgoDateTime = DateTime.now().addDays(-7);
        
        Event NewEvent = new Event(
            Subject = 'Meeting',
            ActivityDate=aWeekAgoDate,
            Start_Date__c=aWeekAgoDate,
            End_Date__c=aWeekAgoDate.addDays(1),
            StartDateTime=aWeekAgoDateTime,
            EndDateTime=aWeekAgoDateTime.addDays(1)
        );
        
        return NewEvent;
    }
    
    public static testmethod List<ActivityHistory> NewActivityHistories_Inserted()
    {
        User TestOwner = DS_TestObjects.NewUser_Inserted(); // 1 dml, 3 soql
        Account TestAccount = DS_TestObjects.NewAccount_Inserted(); // 1 dml, 1 soql
        
        Contact TestContact = DS_TestObjects.NewContact(); // 0 dml, 0 soql
        Lead NewLead = DS_TestObjects.NewLead();
        Opportunity NewOpportunity = DS_TestObjects.NewOpportunity();
        
        /* Insert Tasks and Events here */
        
        return new List<ActivityHistory>();
    }
    
    public static testmethod EmailTemplate NewEmailTemplate_Inserted()
    {
        EmailTemplate NewEmailTemplate = DS_TestObjects.NewEmailTemplate();
        if(NewEmailTemplate.FolderId != null) { system.runas(DS_TestObjects.CurrentUser()) { insert NewEmailTemplate; } }
        return NewEmailTemplate;
    }
    
    public static testmethod EmailTemplate NewEmailTemplate()
    {
        List<Folder> Folders = [Select Id From Folder Where Type = 'Email'];
        
        EmailTemplate NewEmailTemplate = new EmailTemplate();
        NewEmailTemplate.Name = 'Test EmailTemplate';
        NewEmailTemplate.DeveloperName = 'TestEmailTemplate_'+String.valueOf(DateTime.now().millisecond());
        NewEmailTemplate.FolderId = (Folders.IsEmpty()?null:Folders[0].Id);
        NewEmailTemplate.IsActive = true;
        NewEmailTemplate.TemplateType = 'Text';
        NewEmailTemplate.Subject = 'Test EmailTemplate';
        NewEmailTemplate.Body = 'Test EmailTemplate';
        return NewEmailTemplate;
    }
    
    public static testmethod Folder NewFolder()
    {
        Folder NewFolder = new Folder();
        NewFolder.Name = 'Test Folder';
        NewFolder.DeveloperName = 'TestFolder_'+String.valueOf(DateTime.now().millisecond());
        NewFolder.Type = 'Email Template';
        return NewFolder;
    }
    
    public static testmethod List<Laser_Artwork_Order__c> NewLaserArtworkOrders_Inserted()
    {
        List<Laser_Artwork_Order__c> Orders = DS_TestObjects.NewLaserArtworkOrders();
        insert Orders; return Orders;
    }
    
    //2015-11-06 vishal.bandari@cdk.com changed the method to avoid SOQL in for loop
    public static testmethod List<Laser_Artwork_Order__c> NewLaserArtworkOrders()
    {
        List<Account> Accounts = new List<Account>();
        List<Laser_Artwork_Order__c> Orders = new List<Laser_Artwork_Order__c>();
        
        for(Integer i=0; i<3; i++)
        {
            Account a = DS_TestObjects.NewAccount();
            a.Name += ' ' + String.valueOf(i);
            Accounts.add(a);
        }
        
        insert Accounts;
        
        List<CMF_Info__c> cmfInfos = new List<CMF_Info__c>();
        
        for(Account a : Accounts)
        {
            CMF_Info__c CMF_Info = DS_TestObjects.NewCMFInfo();
            CMF_Info.Account__c = a.Id;
            cmfInfos.add(CMF_Info);
        }
        
        insert cmfInfos;
        
        for(CMF_Info__c cmf : cmfInfos)
        {
            Laser_Artwork_Order__c Order = DS_TestObjects.NewLaserArtworkOrder();
            Order.Ship_CMF_Info__c = cmf.Id;
            Orders.add(Order);
        }
        
        return Orders;
    }
    
    public static testmethod Laser_Artwork_Order__c NewLaserArtworkOrder_Inserted()
    {
        Account a = DS_TestObjects.NewAccount_Inserted();
        Laser_Artwork_Order__c LaserArtworkOrder = DS_TestObjects.NewLaserArtworkOrder();
        CMF_Info__c CMF_Info = DS_TestObjects.NewCMFInfo();
        
        CMF_Info.Account__c = a.Id;
        insert CMF_Info;
        
        LaserArtworkOrder.Ship_CMF_Info__c = CMF_Info.Id;
        
        insert LaserArtworkOrder;
        return LaserArtworkOrder;
    }
    
    public static testmethod Laser_Artwork_Order__c NewLaserArtworkOrder()
    {
        Laser_Artwork_Order__c LaserArtworkOrder;
        
        list<User> listOfUsers = new list<User>();
        User LAS_User = DS_TestObjects.NewUser();
        LAS_User.ProfileId = [Select Id, Name From Profile Where Name like '%FFC - Laser%' Limit 1].Id;
        
        User LFD_User = DS_TestObjects.NewUser();
        LFD_User.ProfileId = [Select Id, Name From Profile Where Name like '%FFC - Forms%' Limit 1].Id;
        
        insert listOfUsers;
        
        Contact c = DS_TestObjects.NewContact_Inserted();
        
        // 2015-12-22 matt.keefe@cdk.com - added Contact__c to satisfy validation rule
        LaserArtworkOrder = new Laser_Artwork_Order__c(
            Artwork_Vision_Case__c = '123456789-1',
            Change_Notes__c = 'Test Change Notes',
            Contract_PO__c = '12345678',
            Estimated_Install_Date__c = Date.today(),
            FE_Date__c = Date.today(),
            LAS_Name__c = LAS_User.Id, // user
            LFD_Name__c = LFD_User.Id, // user
            Order_Priority__c = 'Standard',
            Order_Status__c = 'Sold',
            Order_Type__c = 'Buy/Sell - Other',
            Owner_Email__c = 'noreply@cdk.com',
            Prev_SO__c = 'SO# 123',
            Project__c = '00001',
            Stock_Order__c = 'Stock #123',
            Total_Number_of_Forms__c = 5,
            Contact__c = c.Id
        );
        
        return LaserArtworkOrder;
    }
    
    public static testmethod CMF_Info__c NewCMFInfo()
    {
        return new CMF_Info__c(Name='Test CMF Info');
    }
   

  //2015-06-17 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting (Return Type)
    //public static testmethod Campaign_Mgmt_VF_Page_Assignment__c NewCampaignMgmtVFPageAssignment_InsideSales_Inserted()
    public static testmethod Campaign_Mgmt_VF_Page_Assign__c NewCampaignMgmtVFPageAssignment_InsideSales_Inserted()
    {
        //Campaign_Mgmt_VF_Page_Assignment__c VF_Assignment = NewCampaignMgmtVFPageAssignment_InsideSales();
        Campaign_Mgmt_VF_Page_Assign__c VF_Assignment = NewCampaignMgmtVFPageAssignment_InsideSales();
        upsert VF_Assignment;
        return VF_Assignment;
    }
    
    //2015-06-17 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting (Return Type)
    //public static testmethod Campaign_Mgmt_VF_Page_Assignment__c NewCampaignMgmtVFPageAssignment_InsideSales()
    public static testmethod Campaign_Mgmt_VF_Page_Assign__c NewCampaignMgmtVFPageAssignment_InsideSales()
    {
        //Campaign_Mgmt_VF_Page_Assignment__c VF_Assignment = NewCampaignMgmtVFPageAssignment();
        Campaign_Mgmt_VF_Page_Assign__c VF_Assignment = NewCampaignMgmtVFPageAssignment();
        VF_Assignment.Name = 'Test Mapping ID 000002';
        VF_Assignment.Campaign_VF_Layout__c = 'Inside Sales';
        VF_Assignment.Filter_by_Account_Team__c = true;
        return VF_Assignment;
    }
    
    //2015-06-17 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting (Return Type)
    //public static testmethod Campaign_Mgmt_VF_Page_Assignment__c NewCampaignMgmtVFPageAssignment_Inserted()
    public static testmethod Campaign_Mgmt_VF_Page_Assign__c NewCampaignMgmtVFPageAssignment_Inserted()
    {
        //Campaign_Mgmt_VF_Page_Assignment__c VF_Assignment = NewCampaignMgmtVFPageAssignment();
        Campaign_Mgmt_VF_Page_Assign__c VF_Assignment = NewCampaignMgmtVFPageAssignment();
        VF_Assignment.Name = 'Test Mapping ID 000002';
        upsert VF_Assignment;
        return VF_Assignment;
    }
    
    //2015-06-17 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting (Return Type)
    //public static testmethod Campaign_Mgmt_VF_Page_Assignment__c NewCampaignMgmtVFPageAssignment()
    public static testmethod Campaign_Mgmt_VF_Page_Assign__c NewCampaignMgmtVFPageAssignment()
    {
        //Campaign_Mgmt_VF_Page_Assignment__c VF_Assignment = null;
        Campaign_Mgmt_VF_Page_Assign__c VF_Assignment = null;
        String ProfileName = [Select Id, Name From Profile Where Id = :UserInfo.getProfileId() Limit 1].Name;
        
        //List<Campaign_Mgmt_VF_Page_Assignment__c> Matching_VF_Assignment 
        List<Campaign_Mgmt_VF_Page_Assign__c> Matching_VF_Assignment 
            = [Select Id, Name From Campaign_Mgmt_VF_Page_Assign__c Where Profile_Name__c = :ProfileName Limit 1];
          //= [Select Id, Name From Campaign_Mgmt_VF_Page_Assignment__c Where Profile_Name__c = :ProfileName Limit 1];
        
        if(Matching_VF_Assignment.IsEmpty()) 
        { 
            //VF_Assignment = new Campaign_Mgmt_VF_Page_Assignment__c(); 
            VF_Assignment = new Campaign_Mgmt_VF_Page_Assign__c(); 
            VF_Assignment.Profile_Name__c = ProfileName; 
        }
        else { VF_Assignment = Matching_VF_Assignment[0]; }
        
        VF_Assignment.Campaign_VF_Layout__c = 'Non-Inside Sales';
        VF_Assignment.Filter_by_Account_Team__c = false;
        
        return VF_Assignment;
    }
    
  
    
    public static testmethod WebID__c NewWebID_Inserted()
    {
        WebID__c NewWebID = DS_TestObjects.NewWebID();
        insert NewWebID;
        return NewWebID;
    }
    
    public static testmethod WebID__c NewWebID()
    {
        WebID__c NewWebID = new WebID__c();
        Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        
        NewWebId.Name = 'test-webid-001';
        NewWebId.Account__c = NewAccount.Id;
        NewWebId.Account__r = NewAccount;
        
        return NewWebID;
    }
    
    public static testmethod Account_Team__c NewAccountTeamMember()
    {
        // 10/1 pulled in User creation
        String Random = DS_TestObjects.TrueRandomUpToAMillion(); system.debug(Random);
        String RandomUserName = DS_TestObjects.RandomUserName(); system.debug(RandomUserName);
        Profile P = DS_TestObjects.getStandardProfile();
        Id StandardProfileId = P != null ? P.Id : null;
        
        User NewUser = new User(
            UserName=RandomUserName,
            Email='test-'+Random+'@cdk.com', 
            Alias= Random.length()>8?Random.substring(4, Random.length()):Random,
            EmailEncodingKey='UTF-8', 
            FirstName='Apex',
            LastName='Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid=StandardProfileId, 
            TimeZoneSIDKey='America/Chicago',
            //userroleid = [Select Id, RollupDescription From UserRole Where RollupDescription = 'Data Librarian'].Id,
            ADID__c='testus',
            FederationIdentifier = 'F'+Random
        );
        
        insert NewUser;
        
        Account_Team__c NewAccountTeamMember = new Account_Team__c();
        NewAccountTeamMember.Account_Access__c = 'Read/Write';
        NewAccountTeamMember.Case_Access__c = 'Read/Write';
        NewAccountTeamMember.Opportunity_Access__c = 'Read Only';
        NewAccountTeamMember.Team_Member__c = NewUser.Id;
        
        return NewAccountTeamMember;
    }
    
    public static testmethod Account_Team__c NewAccountTeamMember_Inserted()
    {
        Account_Team__c NewAccountTeamMember = DS_TestObjects.NewAccountTeamMember();
        NewAccountTeamMember.Account__c = DS_TestObjects.NewAccount_Inserted().Id;
        NewAccountTeamMember.Team_Role__c = 'Test';
        insert NewAccountTeamMember;
        return NewAccountTeamMember;
    }
    
    public static testmethod Account_Plan__c NewAccountPlan_Inserted()
    {
        Account_Plan__c NewAccountPlan = DS_TestObjects.NewAccountPlan();
        
        insert NewAccountPlan;
        return NewAccountPlan;
    }
    
    public static testmethod Account_Plan__c NewAccountPlan()
    {
        Account_Plan__c NewAccountPlan = new Account_Plan__c();
        
        WebID__c NewWebID = DS_TestObjects.NewWebID_Inserted();
        NewAccountPlan.Account__c = NewWebID.Account__c;
        NewAccountPlan.Account__r = NewWebID.Account__r;
        NewAccountPlan.WebID__c = NewWebID.Id;
        NewAccountPlan.WebID__r = NewWebID;
        
        RecordType AccountPlanRecordType = [
            Select Id, Name From RecordType Where SobjectType = 'Account_Plan__c' Limit 1];
        
        if(AccountPlanRecordType != null) {
            NewAccountPlan.RecordTypeId = AccountPlanRecordType.Id; 
            NewAccountPlan.RecordType = AccountPlanRecordType;
        }
        
        return NewAccountPlan;
    }
    
    public static testmethod Account_Plan_Contacts_Filter__c NewAccountPlanContactFilter_Inserted()
    {
        Account_Plan_Contacts_Filter__c NewContactsFilter = DS_TestObjects.NewAccountPlanContactFilter();
        insert NewContactsFilter;
        return NewContactsFilter;
    }
    
    public static testmethod Account_Plan_Contacts_Filter__c NewAccountPlanContactFilter()
    {
        Account_Plan__c ap = NewAccountPlan_Inserted();
        
        Account_Plan_Contacts_Filter__c NewContactsFilter = new Account_Plan_Contacts_Filter__c();
        NewContactsFilter.Name = 'Test Contacts Filter';
        NewContactsFilter.Record_Type_Name__c = ap.RecordType.Name;
        NewContactsFilter.Contact_Role__c = 'Test Contact Role';
        
        return NewContactsFilter;
    }
    
    public static testmethod Monthly_Maintenance__c NewMonthlyMaintenance_Inserted()
    {
        Monthly_Maintenance__c NewMonthlyMaintenance = DS_TestObjects.NewMonthlyMaintenance();
        insert NewMonthlyMaintenance;
        return NewMonthlyMaintenance;
    }
    
    public static testmethod Monthly_Maintenance__c NewMonthlyMaintenance()
    {
        Account_Plan__c ap = NewAccountPlan_Inserted();
        
        Monthly_Maintenance__c NewMonthlyMaintenance = new Monthly_Maintenance__c();
        
        NewMonthlyMaintenance.Account_Plan__c = ap.Id;
        NewMonthlyMaintenance.Account_Plan__r = ap;
        NewMonthlyMaintenance.Account__c = ap.Account__c;
        NewMonthlyMaintenance.Account__r = ap.Account__r;
        NewMonthlyMaintenance.WebID__c = ap.WebID__c;
        NewMonthlyMaintenance.WebID__r = ap.WebID__r;
        
        Date DateToday = Date.Today();
        Integer DaysToAdd = (DateToday.day()*-1); // get the negative value of the current day
        DaysToAdd = DaysToAdd + 1; // add one (we do not want to get the 0th day, but the 1st)
        Date FirstDayOfMonth = DateToday.addDays(DaysToAdd); // add the negative days
        
        NewMonthlyMaintenance.Month__c = FirstDayOfMonth;
        NewMonthlyMaintenance.Review_Frequency__c = 'Monthly';
        NewMonthlyMaintenance.Type__c = 'ProCare';
        NewMonthlyMaintenance.Status__c = 'Not Started';
        
        return NewMonthlyMaintenance;
    }
    
    public static testmethod AsyncApexJob NewAsyncApexJob()
    {
        AsyncApexJob NewAsyncApexJob = new AsyncApexJob();
        return NewAsyncApexJob;
    }
    
    public static testmethod Launch__c NewLaunch_Inserted()
    {
        Launch__c NewLaunch = DS_TestObjects.NewLaunch();
        
        insert NewLaunch;
        return NewLaunch;
    }
    
    public static testmethod Launch__c NewLaunch()
    {
        Launch__c NewLaunch = new Launch__c();
        Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        
        NewLaunch.Account__c = NewAccount.Id;
        NewLaunch.Account__r = NewAccount;
        NewLaunch.Order_Type__c = 'New';
        NewLaunch.Order_Priority__c = 'Services Only';
        
        RecordType LaunchRecordType = [
            Select Id, Name From RecordType Where SobjectType = 'Launch__c' Limit 1];
        
        if(LaunchRecordType != null) {
            NewLaunch.RecordTypeId = LaunchRecordType.Id; 
            NewLaunch.RecordType = LaunchRecordType;
        }
        
        return NewLaunch;
    }
    
   /* public static testmethod NADA_Swipe__c NewSwipe()
    {
        NADA_Swipe__c Swipe = new NADA_Swipe__c(
            RawData_Manufacturers__c = 'Chevrolet+Buick',
            Manufacturers_Picklist__c = 'Chevrolet;Buick',
            Lead_Type__c = 'Add-On',
            Notes__c = 'Test Notes...',
            Street_Address__c = '1 Market St',
            Address2__c = '#300',
            City__c = 'San Francisco',
            State__c = 'CA',
            Postal_Code__c = '94105',
            Country__c = 'USA',
            Show_Code__c = 'NADA123',
            Swiped_Card_Number__c = '15473',
            Apparatus_Id__c = '45A7F935',
            Swiped_Date_Time__c = DateTime.now(),
            Server_Date_Time__c = DateTime.now()
        );
        
        return Swipe;
    }
    
    public static testmethod NADA_Device__c NewNADADevice_Inserted()
    {
        NADA_Device__c Device = DS_TestObjects.NewNADADevice();
        
        insert Device;
        return Device;
    }
    
    public static testmethod NADA_Device__c NewNADADevice()
    {
        NADA_Device__c Device = new NADA_Device__c();
        Device.Name = '45A7F935';
        return Device;
    }*/
    
    public static testMethod Id getCaseTier1RecordTypeId()
    {
        List<Schema.RecordTypeInfo> RecordList = new List<Schema.RecordTypeInfo>();
        Schema.DescribeSObjectResult d = Schema.SObjectType.Case;
        
        Id Tier1RecordTypeId = null;
        for(Schema.RecordTypeInfo sr : RecordList) { 
            if(sr.getName().toLowerCase().contains('tier 1')) { 
                Tier1RecordTypeId = sr.getRecordTypeId(); 
                break;
            } 
        }
        
        return Tier1RecordTypeId;
    }
    
    public static testMethod List<Account_Team_Sync_Settings__c> getAcountTeamSyncSettings()
    {
        List<Account_Team_Sync_Settings__c> AccountTeamSettings = new List<Account_Team_Sync_Settings__c>();
        
        AccountTeamSettings.add(new Account_Team_Sync_Settings__c(Name='1',sObject__c='WebID__c',Team_Role__c='Account Advocate',User_ID_Field_API_Name__c='Account_Advocate__c'));
        AccountTeamSettings.add(new Account_Team_Sync_Settings__c(Name='2',sObject__c='Account', Team_Role__c='Digital Services CAM', User_ID_Field_API_Name__c='Digital_Services_CAM__c'));
        AccountTeamSettings.add(new Account_Team_Sync_Settings__c(Name='3',sObject__c='WebID__c', Team_Role__c='Email Marketing Specialist', User_ID_Field_API_Name__c='OwnerMktg_Specialist_lookup__c'));
        AccountTeamSettings.add(new Account_Team_Sync_Settings__c(Name='4',sObject__c='WebID__c', Team_Role__c='Online Marketing Specialist', User_ID_Field_API_Name__c='Online_Marketing_Specialist__c'));
        AccountTeamSettings.add(new Account_Team_Sync_Settings__c(Name='5',sObject__c='WebID__c', Team_Role__c='Owner Marketing (DAP)', User_ID_Field_API_Name__c='Owner_Marketing_DAP__c'));
        AccountTeamSettings.add(new Account_Team_Sync_Settings__c(Name='6',sObject__c='WebID__c', Team_Role__c='Reputation Management Specialist', User_ID_Field_API_Name__c='Reputation_Management_Specialist__c'));
        AccountTeamSettings.add(new Account_Team_Sync_Settings__c(Name='7',sObject__c='WebID__c', Team_Role__c='Search Optimization Specialist', User_ID_Field_API_Name__c='SEO_Specialist__c'));
        AccountTeamSettings.add(new Account_Team_Sync_Settings__c(Name='8',sObject__c='WebID__c', Team_Role__c='Social Media Specialist', User_ID_Field_API_Name__c='Social_Media_Specialist__c'));
        //2016-02-24- anirudh.singh@cdk.com- Commented the below line as using WebID__c record we cannot put value in Account field Account__r.Digital_Services_CAM__c.
        //AccountTeamSettings.add(new Account_Team_Sync_Settings__c(Name='9',sObject__c='WebID__c', Team_Role__c='Digital Services CAM', User_ID_Field_API_Name__c='Account__r.Digital_Services_CAM__c'));
        
        insert AccountTeamSettings;        
        return AccountTeamSettings;        
    }
}