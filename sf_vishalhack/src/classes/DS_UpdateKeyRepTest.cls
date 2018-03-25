@IsTest
public class DS_UpdateKeyRepTest 
{
    testMethod static void testUpdateKeyRep()
    {
        // setup data
        
        List<User> managers = new List<User>();
        profile p = [Select Id, Name From Profile Limit 1];
        User CurrentUser = [Select Id from User where Id = :UserInfo.getUserId()];
        //User m1 = DS_TestObjects.NewUser(); //9/30
        User m1 = new User(
            Username = 'tt1@cdk.com', 
            Email = 'te1@cdk.com', 
            LastName = 'us1', 
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
            Username = 'tt2@cdk.com', 
            Email = 'te2@cdk.com', 
            LastName = 'us2', 
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
        
        system.runas(CurrentUser) { insert managers; }
        
        List<User> users = new List<User>();
        
        //User u1 = DS_TestObjects.NewUser(); // 9/30
        User u1 = new User(
            Username = 'tt671@cdk.com', 
            Email = 'te178@cdk.com', 
            LastName = 'usg1', 
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
            Username = 'tt1ui@cdk.com', 
            Email = 'tejk@cdk.com', 
            LastName = 'uops1', 
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
        
        system.runas(CurrentUser) { insert users; }
        
        CustomSettings__c cs = CustomSettings__c.getInstance();
        if(cs == null) { 
            cs = new CustomSettings__c(); 
            cs.Nondealership_Key_Rep_ID__c = DS_TestObjects.NewUser_Inserted().Id;
            system.runas(DS_TestObjects.CurrentUser()) { insert cs; }
        }
        
        Site_Type__c NonDealershipSiteType = DS_TestObjects.NewSiteType(); 
        NonDealershipSiteType.Name = 'Non-dealership';
        NonDealershipSiteType.Non_Sales_Type__c = true; 
        system.runas(DS_TestObjects.CurrentUser()) { insert NonDealershipSiteType; }
        
        // test non-dealership
        
        Account a1 = DS_TestObjects.NewAccount();
        a1.Site_Type__c = NonDealershipSiteType.Id;
        system.runas(DS_TestObjects.CurrentUser()) { insert a1; }
        
        // test new Owner
        
        Account a3 = DS_TestObjects.NewAccount_Inserted();
        a3.OwnerId = users[0].Id;
        system.runas(DS_TestObjects.CurrentUser()) { update a3; }
        
        // test new Key_Rep__c
        
        Account a4 = DS_TestObjects.NewAccount_Inserted();
        a4.Key_Rep__c = users[1].Id;
        system.runas(DS_TestObjects.CurrentUser()) { update a4; }
    }

}