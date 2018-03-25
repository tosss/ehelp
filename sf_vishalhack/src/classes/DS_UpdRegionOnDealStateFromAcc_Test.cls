/*----------------------------------------------------------
 * RQ-06546
 * 03-28-2016 -venkata.shrivol@cdk.com -created this class.
 * Test Class for: DS_UpdRegionOnDealStateFromAcc_Handler 
-----------------------------------------------------------*/
@isTest
public class DS_UpdRegionOnDealStateFromAcc_Test 
{
    @testSetup static void prepareTestData()
    {
        Account testAccount = DS_TestObjects.NewAccount();
        testAccount.Name='myTestAccount';
        insert testAccount;
        
        Opportunity testOpp = DS_TestObjects.NewOpportunity();
        testOpp.AccountId = testAccount.Id;
        insert testOpp;
        
        Deal_State__c testDeal = new Deal_State__c();
        testDeal.Opportunity__c = testOpp.Id;
        insert testDeal;
    }
    testMethod static void testRegionUpdate()
    {
                
    	list<Account> retrieveAccList = [select Region__c from Account where Name ='myTestAccount'];
        Account thisAccount = retrieveAccList.size() > 0 ? retrieveAccList.get(0) : new Account();
        
        Test.startTest();
        	thisAccount.Region__c = thisAccount.Region__c == 'North' ? 'South' : 'North';	
        	upsert thisAccount; 
        Test.stopTest();
        
        //system.debug('----'+thisAccount.Region__c);
        
        list<Deal_State__c> retrieveDealStateList = [
            select  Region_Of_Account__c
            from Deal_State__c 
            where Opportunity__r.AccountId =:thisAccount.Id
        ];
        Deal_State__c thisDealState = retrieveDealStateList.size()> 0? retrieveDealStateList.get(0) : new Deal_State__c();
		
        system.assertEquals(thisAccount.Region__c, thisDealState.Region_Of_Account__c, 'Deal State region is not updated when its parent account region is updated');
	        
    }
}