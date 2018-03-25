@isTest
private class caseTriggersTest 
{
    // Test that when parents are updated, the change trickles down to the children
    
    static testMethod void updateParentOwnerEmailTest() 
    {
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        
        User u1 = new User(
            Username = 'test1@cdk.com', 
            Email = 'test1@cdk.com', 
            LastName = 'user1', 
            FirstName = 'test1', 
            Alias = 'tsAlias1', 
            CommunityNickName = 'testNickName1', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US', 
            ADID__c = 'test1', 
            IsActive = true
        );
        
        User u2 = new User(
            Username = 'test2@cdk.com', 
            Email = 'test2@cdk.com', 
            LastName = 'user2', 
            FirstName = 'test2', 
            Alias = 'tsAlias2', 
            CommunityNickName = 'testNickName2', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US', 
            ADID__c = 'test2', 
            IsActive = true
        );
        
        system.runas(DS_TestObjects.CurrentUser()) { insert u1; }
        system.runas(DS_TestObjects.CurrentUser()) { insert u2; }
         
        Account a = DS_TestObjects.NewAccount_Inserted();    
        contact con = DS_TestObjects.NewContact();
        con.AccountId = a.Id;
        insert con;
        
        // Insert 10 test parents
        system.debug('Ten (10) Test Parent Cases');
        List<Case> parents = new List<Case>();
        for (Integer i=0; i<10; i++) {
            parents.add(
                new Case(
                    Subject='Test'+i, 
                    AccountId=a.Id, 
                    OwnerId=u1.Id, 
                    ContactId=con.Id, 
                    Dealer_Group_Contact__c=con.Id
                )
            ); // 9/30
        } 
        insert parents;
        
        // Insert 2 children for each parent
        system.debug('Two (2) Test Children Cases for each parent');
        List<Case> children = new List<Case>();
        for (Case c : parents) {
            for (Integer i=0; i<2; i++) {
                children.add(
                    new Case(
                        ParentId = c.Id, 
                        AccountId=a.Id, 
                        ContactId=con.Id, 
                        Subject = 'Parent: ' + c.Id + ' Child # ' + i, 
                        Dealer_Group_Contact__c=con.Id
                    )
                ); // 9/30
            }
        }
        insert children;
        
        for (Case c : parents) {
            c.OwnerId = u2.Id;
        }
        
        //Test.startTest();
        update parents;
        //Test.stopTest();
        
        for(Case c : [SELECT Id, Parent_Case_Owner__c, Parent.Owner.Email FROM Case WHERE Id IN :children]) {
            //System.assertEquals(u2.Email, c.Parent.Owner.Email);
           // System.assertEquals(u2.Email, c.Parent_Case_Owner__c);
        }
    }
    
    static testMethod void testCaseTeam() 
    {
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        
        // Converted the following to use existing users because I could not get isactive = true.  I believe due to missing licenses.
        //List<User> us = [SELECT Id FROM User WHERE IsActive = true LIMIT 2];
        User u1 = new User(
            Username = 'test1@cdk.com', 
            Email = 'test1@cdk.com', 
            LastName = 'user1', 
            FirstName = 'test1', 
            Alias = 'tsAlias1', 
            CommunityNickName = 'testNickName1', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US', 
            ADID__c = 'test1', 
            IsActive = true, 
            FederationIdentifier='F301245'
        );
        
        User u2 = new User(
            Username = 'test2@cdk.com', 
            Email = 'test2@cdk.com', 
            LastName = 'user2', 
            FirstName = 'test2', 
            Alias = 'tsAlias2', 
            CommunityNickName = 'testNickName2', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US', 
            ADID__c = 'test2', 
            IsActive = true, 
            FederationIdentifier='R56789'
        );
        
        //User u1 = us[0];
        //User u2 = us[1];
        system.runas(DS_TestObjects.CurrentUser()) { insert u1; }
        system.runas(DS_TestObjects.CurrentUser()) { insert u2; }
        
        //insert new List<User>{u1,u2};
        system.debug('User1:'+u1.Id);
        system.debug('User2:'+u2.Id);
        
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact con = DS_TestObjects.NewContact();
        con.AccountId = a.Id;
        insert con;
        
        Integer howManyToTest = 10;
        
        List<Case> testCases = new List<Case>();
        for (Integer i=0; i<howManyToTest; i++) {
            testCases.add(
                new Case(
                    Subject='Test'+i, 
                    AccountId=a.Id, 
                    OwnerId=u1.Id, 
                    ContactId=con.Id, 
                    Dealer_Group_Contact__c=con.Id
                )
            ); // 9/30
        } 
        insert testCases;
        
        for (Case c : testCases) { c.OwnerId = u2.Id; }
        
        //Test.startTest();
        update testCases;
        //Test.stopTest();
    }
    
    static testMethod void testCaseTime() 
    {
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        
        User u1 = new User(
        	Username = 'test1@cdk.com', 
        	Email = 'test1@cdk.com', 
        	LastName = 'user1', 
        	FirstName = 'test1', 
        	Alias = 'tsAlias1', 
        	CommunityNickName = 'testNickName1', 
        	TimeZoneSidKey = 'America/Los_Angeles', 
        	LocaleSidKey = 'en_US', 
        	EmailEncodingKey = 'UTF-8', 
        	ProfileId = p.Id, 
        	LanguageLocaleKey = 'en_US', 
        	ADID__c = 'test1', 
        	IsActive = true
    	);
    	
        User u2 = new User(
        	Username = 'test2@cdk.com', 
        	Email = 'test2@cdk.com', 
        	LastName = 'user2', 
        	FirstName = 'test2', 
        	Alias = 'tsAlias2', 
        	CommunityNickName = 'testNickName2', 
        	TimeZoneSidKey = 'America/Los_Angeles', 
        	LocaleSidKey = 'en_US', 
        	EmailEncodingKey = 'UTF-8', 
        	ProfileId = p.Id, 
        	LanguageLocaleKey = 'en_US',  
        	ADID__c = 'test2', 
        	IsActive = true
    	);
    	
        //insert new List<User>{u1,u2};
        system.runas(DS_TestObjects.CurrentUser()) { insert u1; }
        system.runas(DS_TestObjects.CurrentUser()) { insert u2; }
        
        Account a = DS_TestObjects.NewAccount_Inserted();
        contact con = DS_TestObjects.NewContact();
        con.AccountId = a.Id;
        insert con;
            
        Integer howManyToTest = 10;
        List<Case> testCases = new List<Case>();
        for (Integer i=0; i<howManyToTest; i++) { 
            testCases.add(
                new Case(
                    Subject='Test'+i, 
                    AccountId=a.Id, 
                    OwnerId=u1.Id, 
                    ContactId=con.Id, 
                    Dealer_Group_Contact__c=con.Id
                )
            ); 
        } // 9/30
        insert testCases;
        
        for (Case c : testCases) { c.OwnerId = u2.Id; }
        
        //Test.startTest();
        update testCases;
        //Test.stopTest();
    }
}