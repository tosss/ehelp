//2016-03-03- anirudh.singh@cdk.com- Created this class for Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
//                                   This is the test class for IMP_UpdateDealStateRollCallDate_Handler class.
@isTest
public class IMP_UpdateDealStateRollCallDate_Test
{
    @TestSetup
    private static void setupData()
    {
        Account accountRecord=IMP_TestFactory_Helper.buildAccount();   
        insert accountRecord;
        
        Opportunity opportunityRecord=IMP_TestFactory_Helper.buildOpportunity();
        opportunityRecord.AccountId=accountRecord.Id;
        insert opportunityRecord; 
        
        Opportunity_Quotes__c opportunityQuoteRecord=IMP_TestFactory_Helper.buildOpportunityQuotes(accountRecord.Id, opportunityRecord.Id);
        opportunityQuoteRecord.Deal_Id__c='12345';
        insert opportunityQuoteRecord;
        
        Deal_State__c dealStateRecord=new Deal_State__c();
        dealStateRecord.SQT_Deal_Id__c='12345';
        dealStateRecord.Opportunity__c=opportunityRecord.Id;
        dealStateRecord.CA_Approved_Date__c=datetime.now();
        insert dealStateRecord;
        
        Project__c projectRecord=IMP_TestFactory_Helper.buildProject(0);
        insert projectRecord;
        
        SubProject__c subProjectRecord=IMP_TestFactory_Helper.buildSubProject(projectRecord.Id);
        subProjectRecord.Deal_Id__c='12345';
        subProjectRecord.Project__c=projectRecord.Id;
        subProjectRecord.Contract_Roll_Called__c=date.newinstance(2016, 03, 14);
        insert subProjectRecord;
    }
    
    private static testMethod void updateRollCallDateTestOne()
    {
        SubProject__c subProjectRecord=[SELECT Id, Deal_Id__c, Project__c, Contract_Roll_Called__c FROM SubProject__c];
        Deal_State__c dealStateRecord=[SELECT Id, Roll_Call_Date__c FROM Deal_State__c];
        
        Map<String, Date> dealIdAndContractRollCalledMap=new Map<String, Date>();
        
        test.startTest();
        dealIdAndContractRollCalledMap.put(subProjectRecord.Deal_Id__c, date.newinstance(2016, 03, 16));
        IMP_UpdateDealStateRollCallDate_Handler.updateRollCallDate(dealIdAndContractRollCalledMap);
        
        Deal_State__c updatedDealStateRecord=[SELECT Id, Roll_Call_Date__c FROM Deal_State__c];
        system.assertNotEquals(dealStateRecord.Roll_Call_Date__c, updatedDealStateRecord.Roll_Call_Date__c, 'Roll Call Date Updated.');
        system.assertEquals(date.newinstance(2016, 03, 16), updatedDealStateRecord.Roll_Call_Date__c, 'Roll Call Date Updated.');
        test.stopTest();
    }
    
    private static testMethod void updateRollCallDateTestTwo()
    {
        Deal_State__c dealStateRecord=[SELECT Id FROM Deal_State__c];
        delete dealStateRecord;
        
        Opportunity_Quotes__c opportunityQuoteRecord=[SELECT Id FROM Opportunity_Quotes__c];
        delete opportunityQuoteRecord;
        
        test.startTest();
        IMP_UpdateDealStateRollCallDate_Handler.updateRollCallDate(Null);
        test.stopTest();
    }
}