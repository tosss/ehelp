/*------------------------------------------------------
 * 2016-06-28 -venkata.shrivol@cdk.com -Created
 * Description: Test Class for DS_AccountTeam_Handler
 * 2017-03-27 - Added Top 5 Records for RQ-08784
 * ---------------HISTORY----------------------------------
 * 2017-03-27 ragashalini.koka@cdk.com - Added this method to validate Top 5 Records Sharing
 * 2017-04-14 -venkata.shrivol@cdk.com - commented contactShareOnUpdate Method
-------------------------------------------------------*/
@isTest
public class DS_AccountTeam_Test 
{
	 @testSetup static void prepareTestData()
    {
    	Account acc = DS_TestObjects.NewAccount();
        acc.Name= 'Test One';
        insert acc;
                
        Contact c = DS_TestObjects.NewContact();
        c.lastName = 'contactSharing';
        c.AccountId = acc.Id;
        insert c;
        
        Top_5__c top5Rec = new Top_5__c();
        top5Rec.Account__c = acc.Id;
        top5Rec.Status__c = 'Green';
        top5Rec.Comments__c = 'Test Comments';
        insert top5Rec;
        
        Contact_Relationship__c crt = IMP_TestFactory_Helper.buildContactRelationship(acc.Id, c.Id);
        insert crt;
        
        Profile p = [select Id from Profile where Name='ADPDS - Sales - Inside Sales' limit 1];
        User u = DS_TestObjects.NewUser();
        u.FirstName= 'contactSharingFirstNam';
        u.ProfileId = p.Id;
        insert u;
       
        CustomSettings__c cst = CustomSettings__c.getOrgdefaults();
        cst.DS_SalesTeamTrigger_On__c = true;
        cst.Profile_Id__c = 'adminProfileId';
        insert cst;
        system.debug('----------------cst------'+cst);
            
        Account_Team__c act = new Account_Team__c();
        act.Account__c = acc.Id;
        act.Account_Access__c= 'Read/Write';
        act.Case_Access__c='Private';
        act.Opportunity_Access__c='Read/Write';
        act.Team_Role__c = 'Forecasting - Inside Sales Rep';
        act.Team_Member__c = u.ID;
        insert act;
    }
    
   static testMethod void contactShareOnInsert()
    {
    	Test.startTest();
        	Contact c = [select Id, AccountId from Contact where lastName = 'contactSharing' limit 1];
        	User u = [select Id from User where Profile.Name = 'ADPDS - Sales - Inside Sales' and firstName = 'contactSharingFirstNam' limit 1];
        	list<AccountShare> accountShareList = [select AccountAccessLevel from AccountShare where RowCause = 'Team' and AccountId = :c.AccountId and UserOrGroupId = :u.Id limit 1];
        	AccountShare thisAccShare = accountShareList.size() >0 ? accountShareList[0] : null;
            if(thisAccShare!=null)
            {
               system.assertEquals('Edit', thisAccShare.AccountAccessLevel); 
            }
            else
            {
                system.assert(false, 'Standard Account Team Shared record not updated for recent custom account team insertion.');   
            }
        	
        	//list<ContactShare> conShare = [select Id from ContactShare where UserOrGroupId = :u.Id and ContactId = :c.Id and RowCause = 'Manual'];
        	//system.assertEquals(1, conShare.size());
        Test.stopTest();
    }
    
    //2017-04-14 -venkata.shrivol@cdk.com -commented this method as the handler's update method commented.
    /*static testMethod void contactShareOnUpdate()
    {
    	Test.startTesT();
            Account_Team__c act = [select Id from Account_Team__c limit 1];
            
        	
        	Account newAccount = DS_TestObjects.NewAccount();
        	insert newAccount;
        
            User newUser = DS_TestObjects.NewUser();
        	insert newUser;
        	
        	act.Account__c = newAccount.Id;
        	act.Team_Member__c = newUser.Id;
        	update act;
        
        Test.stopTest();
    }*/
    
    static testMethod void contactShareOnUpdateTwo()
    {
    	Test.startTesT();
            Account_Team__c act = [select Id from Account_Team__c limit 1];
            Account acc = [select ID from Account limit 1];
        	
        	Account newAccount = DS_TestObjects.NewAccount();
        	insert newAccount;
        
        	act.Account__c = newAccount.Id;
        	
        	update act;
        
        Test.stopTest();
    }
    
    static testMethod void contactShareOnUpdateThree()
    {
    	Test.startTesT();
            Account_Team__c act = [select Id from Account_Team__c limit 1];
        	
            User newUser = DS_TestObjects.NewUser();
        	insert newUser;
        	
        	
        	act.Team_Member__c = newUser.Id;
        	update act;
        
        Test.stopTest();
    }
    
    static testMethod void contactShareOnDelete()
    {
        Account_Team__c slst = [select Id from Account_Team__c limit 1];
        Test.startTest();
        	delete slst;
        Test.stopTesT();
    }
    
    //2017-03-27 ragashalini.koka@cdk.com - Added this method to validate Top 5 Records Sharing
    static testMethod void validateTop5Share() 
    {
        Test.startTest();
        Account_Team__c accTeam = [SELECT Id, Account__c,Team_Member__c FROM Account_Team__c LIMIT 1];
        Id accId = accTeam.Account__c;
        Id userId = accTeam.Team_Member__c;
        Top_5__c top5Rec = [SELECT Id FROM Top_5__c WHERE Account__c = :accId LIMIT 1];
        List<Top_5__Share> top5ShareList = [SELECT Id FROM Top_5__Share WHERE UserOrGroupId = :userId AND ParentId = :top5Rec.Id];
        System.assert(top5ShareList.size() == 1);
        accTeam.Team_Role__c = 'Digital Advisor';
        update accTeam;
        top5ShareList = [SELECT Id FROM Top_5__Share WHERE UserOrGroupId = :userId AND ParentId = :top5Rec.Id];
        System.assert(top5ShareList.size() == 0);
        Test.stopTest(); 
        
    }
}