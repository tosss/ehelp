/*------------------------------------------------------------
Description:   Test Class to test DS_UpdateKeyRep Trigger
Created on:    17 August 2010.
------------------------------------------------------------
History
15 June 2015    Vishal Bandari      RQ-04417: Added setupTestData Method
15 June 2015    Vishal Bandari      RQ-04417: Added testUpdateRegion Method
------------------------------------------------------------*/

@IsTest
public class DS_UpdateKeyRep_And_Region_Test 
{
    //RQ-04417: Added by Vishal Bandari to Insert test data
    @testSetup
    private static void setUpData()
    {
        List<Trigger_Toggle__c> ToggleList = new List<Trigger_Toggle__c>();
        
        ToggleList.add(new Trigger_Toggle__c(
            Name='ALL_DSCB_CaseConcatenate_Handler', 
            sObject__c='Case', 
            Code_Reference__c='DSCB_CaseConcatenate_Handler', 
            On__c=false));
        
        ToggleList.add(new Trigger_Toggle__c(
            Name='RMS_DSCB_CaseConcatenate_Handler', 
            sObject__c='Case', 
            Code_Reference__c='DSCB_CaseConcatenate_Handler',
            RecordType_Name__c='Onboarding - RMS', 
            On__c=true));
        
        ToggleList.add(new Trigger_Toggle__c(
            Name='DS_UpdateKeyRep', 
            sObject__c='Account', 
            Code_Reference__c='DS_UpdateKeyRep',
            RecordType_Name__c='ADPDS Autotegrity', 
            On__c=true));
        insert ToggleList;
        
        Id accRecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('ADPDS Customer').getRecordTypeId();
        
        //Insert Sample Account to test region update
        Account accObj = DS_TestObjects.NewAccount();
        accObj.Name = 'RegionUpdateTestAccount';
        accObj.Region__c = 'Division';
        accObj.RecordTypeId=accRecordTypeId;
        insert accObj;
        
        List<User> AllUsers = new List<User>();
        List<User> managers = new List<User>();
        profile p = [Select Id, Name From Profile Limit 1];
        User CurrentUser = [Select Id from User where Id = :UserInfo.getUserId()];
        //User m1 = DS_TestObjects.NewUser(); //9/30
        User m1 = new User(
            Username = 'tt1@cobalt.com', 
            Email = 'te1@cobalt.com', 
            LastName = 'UpdateKeyRepTest1', 
            FirstName = 'tt123', 
            Alias = 'tsAnj1', 
            CommunityNickName = 'testjkName1', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US', 
            ADID__c = 'test1', 
            IsActive = true,
            FederationIdentifier = 'bhj783423'
        );
        m1.Sales_Automation_User__c = false;
        m1.Non_Interactive_User__c = false;
        managers.add(m1); 
        
        //User m2 = DS_TestObjects.NewUser(); //  9/30
        User m2 = new User(
            Username = 'tt2@cobalt.com', 
            Email = 'te2@cobalt.com', 
            LastName = 'UpdateKeyRepTest2', 
            FirstName = 'tt223', 
            Alias = 'tsAnj2', 
            CommunityNickName = 'testjkName2', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US', 
            ADID__c = 'test2', 
            IsActive = true,
            FederationIdentifier = 'bhj7834232'
        );
        m2.Sales_Automation_User__c = false;
        m2.Non_Interactive_User__c = false;
        managers.add(m2);
        
        AllUsers.addAll(managers);
        //system.runas(CurrentUser) { insert managers; }
        
        List<User> users = new List<User>();
        
        //User u1 = DS_TestObjects.NewUser(); // 9/30
        User u1 = new User(
            Username = 'tt671@cobalt.com', 
            Email = 'te178@cobalt.com', 
            LastName = 'UpdateKeyRepTestManager1', 
            FirstName = 'tvt123', 
            Alias = 'tsj1', 
            CommunityNickName = 'tekName1', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US', 
            ADID__c = 'post1', 
            IsActive = true,
            FederationIdentifier = 'bh89023'
        );
        u1.Sales_Automation_User__c = false;
        u1.Non_Interactive_User__c = false;
        u1.ManagerId = managers[0].Id;
        users.add(u1); 
        
        //User u2 = DS_TestObjects.NewUser(); // 9/30
        User u2 = new User(
            Username = 'tt1ui@cobalt.com', 
            Email = 'tejk@cobalt.com', 
            LastName = 'UpdateKeyRepTestManager2', 
            FirstName = 'tuhj123', 
            Alias = 'tfdj1', 
            CommunityNickName = 'tekloame1', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US', 
            ADID__c = 'tuyg', 
            IsActive = true,
            FederationIdentifier = 'bawqer23'
        );
        u2.Sales_Automation_User__c = false;
        u2.Non_Interactive_User__c = false;
        u2.ManagerId = managers[1].Id;
        users.add(u2);
        AllUsers.addAll(users);
        system.runas(CurrentUser) { insert AllUsers; }
        
        CustomSettings__c cs = CustomSettings__c.getInstance();
        if(cs == null) { 
            cs = new CustomSettings__c(); 
            cs.Nondealership_Key_Rep_ID__c = DS_TestObjects.NewUser_Inserted().Id;
            system.runas(DS_TestObjects.CurrentUser()) { insert cs; }
        }
        
        
        Site_Type__c NonDealershipSiteType = DS_TestObjects.NewSiteType(); 
        NonDealershipSiteType.Name = 'Non-dealership';
        NonDealershipSiteType.Non_Sales_Type__c = true; 
        NonDealershipSiteType.Active__c = true;
        system.runas(DS_TestObjects.CurrentUser()) { insert NonDealershipSiteType; }
    }
    
    //RQ-04417: Added by Vishal Bandari to test Region updates for OOB and Duplicate Accounts
    public static testmethod void testUpdateRegion()
    {
        //Scenario:1 Testing Region Update for OOB Account
        Account accObj = [
            SELECT Id, Region__c, Out_of_Business__c 
            FROM Account 
            WHERE Name = 'RegionUpdateTestAccount'
            LIMIT 1
        ];
        accObj.Out_of_Business__c = true;
        update accObj;
        
        accObj.Region__c = 'West';
        update accObj;
        
        accObj = [
            SELECT Id, Region__c
            FROM Account
            WHERE Id = :accObj.Id
            LIMIT 1
        ];
        
        System.assertEquals('Division', accObj.Region__c);
        
        //Scenario:2 Testing Region Update for Duplicate Account
        accObj = [
            SELECT Id, Region__c, Out_of_Business__c, Duplicate__c 
            FROM Account 
            WHERE Name = 'RegionUpdateTestAccount'
            LIMIT 1
        ];
        accObj.Out_of_Business__c = false;
        accObj.Duplicate__c = true;
        update accObj;
        
        accObj.Region__c = 'West';
        update accObj;
        
        accObj = [
            SELECT Id, Region__c
            FROM Account
            WHERE Id = :accObj.Id
            LIMIT 1
        ];
        System.assertEquals('Division', accObj.Region__c);
        
        //Scenario:3 Testing Region Update for Owner Changed Account
        accObj.OwnerId = [
            SELECT Id
            FROM User
            WHERE Name LIKE '% Martin'
            LIMIT 1
        ].id;
        
        update accObj;
        
        accObj = [
            SELECT Id, Region__c
            FROM Account
            WHERE Id = :accObj.Id
            LIMIT 1
        ];
        System.assertEquals('Division', accObj.Region__c);
    }
    
    testMethod static void testUpdateKeyRep()
    {
        // test non-dealership
        Site_Type__c NonDealershipSiteType = [SELECT ID FROM Site_Type__c WHERE Name='Non-dealership'];
        Account a1 = DS_TestObjects.NewAccount();
        a1.Site_Type__c = NonDealershipSiteType.Id;
        system.runas(DS_TestObjects.CurrentUser()) { insert a1; }
        
        // test new Owner
        List<User> users = [
            SELECT Id 
            FROM User 
            WHERE LastName 
            LIKE 'UpdateKeyRepTestManager%'
            ORDER BY LastName
        ];
        
        Account a3 = DS_TestObjects.NewAccount_Inserted();
        a3.OwnerId = users[0].Id;
        system.runas(DS_TestObjects.CurrentUser()) { update a3; }
        
        // test new Key_Rep__c
        
        Account a4 = DS_TestObjects.NewAccount_Inserted();
        a4.Key_Rep__c = users[1].Id;
        system.runas(DS_TestObjects.CurrentUser()) { update a4; }
    }
}