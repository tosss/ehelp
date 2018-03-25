/*------------------------------------------------------
 * 2016-06-28 -venkata.shrivol@cdk.com -Created
 * Description: Test Class for DS_SalesTeam_Handler
 * 
-------------------------------------------------------*/
@isTest
public class DS_SalesTeam_Test 
{
    @testSetup static void prepareTestData()
    {
    	Account acc = DS_TestObjects.NewAccount();
        acc.Name= 'Test One';
        insert acc;
        
        Opportunity opp = DS_TestObjects.NewOpportunity();
        opp.Name= 'Test Opportunity';
        opp.AccountId = acc.Id;
        insert opp;
        
        Contact c = DS_TestObjects.NewContact();
        c.lastName = 'contactSharing';
        c.AccountId = acc.Id;
        insert c;
        
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
            
        Sales_Team__c slsteam = new Sales_Team__c();
        slsteam.Opportunity__c = opp.Id;
        slsteam.User__c = u.Id;
        slsteam.Opportunity_Access__c = 'Read Only';
        insert slsTeam;
        
    }
    
    static testMethod void contactShareOnInsert()
    {
    	Test.startTest();
        	Opportunity opp = [select Id from Opportunity limit 1];
        	Contact c = [select Id from Contact where lastName = 'contactSharing' limit 1];
        	User u = [select Id from User where Profile.Name = 'ADPDS - Sales - Inside Sales' and firstName = 'contactSharingFirstNam' limit 1];
        	list<OpportunityShare> oppShareList = [select OpportunityAccessLevel from OpportunityShare where RowCause = 'Team' and OpportunityId = :opp.Id and UserOrGroupId = :u.Id limit 1];
        	OpportunityShare thisOppShare = oppShareList.size() >0 ? oppShareList[0] : null;
            if(thisOppShare!=null)
            {
               system.assertEquals('Read', thisOppShare.OpportunityAccessLevel); 
            }
            else
            {
                system.assert(false, 'Standard Sales Team Shared record not updated for recent custom sales team insertion.');   
            }
        	//list<ContactShare> conShare = [select Id from ContactShare where UserOrGroupId = :u.Id and ContactId = :c.Id and RowCause = 'Manual'];
        	//system.assertEquals(1, conShare.size());
        Test.stopTest();
    }
    
    static testMethod void contactShareOnUpdate()
    {
    	Test.startTesT();
            Sales_Team__c slst = [select Id from Sales_Team__c limit 1];
            Account acc = [select ID from Account limit 1];
        	
            User newUser = DS_TestObjects.NewUser();
        	insert newUser;
        	
        	slst.User__c = newUser.Id;
        	update slst;
        
        Test.stopTest();
    }
    
    static testMethod void contactShareOnDelete()
    {
        Sales_Team__c slst = [select Id from Sales_team__c limit 1];
        Test.startTest();
        	delete slst;
        Test.stopTesT();
    }
}