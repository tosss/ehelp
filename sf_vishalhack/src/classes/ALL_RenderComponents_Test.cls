//2016-10-24- anirudh.singh@cdk.com- Created this test class for ALL_RenderComponents_Controller.
@isTest
public class ALL_RenderComponents_Test
{
    @TestSetup
    private static void setupData()
    {
        Account accountRecord=DS_TestObjects.NewAccount_Inserted();
        
        Opportunity oppRecord=DS_TestObjects.NewOpportunity();
        oppRecord.AccountId=accountRecord.Id;
        insert oppRecord;
        
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId= :siteRecordTypeId AND Opportunity__c= :oppRecord.Id AND Site__c= :accountRecord.Id]; 
    }
    
    private static testMethod void dealershipOverviewTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_RenderComponents_Controller ref=new ALL_RenderComponents_Controller();
        ref.tabNameSelected='Dealership Overview';
        ref.oppLocationRecord=locRecord;
        
        Test.startTest();
        ApexPages.Component outputTextPanel=ref.getOutputTextPanel();
        
        system.assertNotEquals(Null, outputTextPanel);
        Test.stopTest();
    }
    
    private static testMethod void buildingMapTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_RenderComponents_Controller ref=new ALL_RenderComponents_Controller();
        ref.tabNameSelected='Building Map';
        ref.oppLocationRecord=locRecord;
        
        Test.startTest();
        ApexPages.Component outputTextPanel=ref.getOutputTextPanel();
        
        system.assertNotEquals(Null, outputTextPanel);
        Test.stopTest();
    }
    
    private static testMethod void networkTechnicalTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_RenderComponents_Controller ref=new ALL_RenderComponents_Controller();
        ref.tabNameSelected='Network Technical';
        ref.oppLocationRecord=locRecord;
        
        Test.startTest();
        ApexPages.Component outputTextPanel=ref.getOutputTextPanel();
        
        system.assertNotEquals(Null, outputTextPanel);
        Test.stopTest();
    }
    
    private static testMethod void solutionsTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_RenderComponents_Controller ref=new ALL_RenderComponents_Controller();
        ref.tabNameSelected='Third Party Solutions';
        ref.oppLocationRecord=locRecord;
        
        Test.startTest();
        ApexPages.Component outputTextPanel=ref.getOutputTextPanel();
        
        system.assertNotEquals(Null, outputTextPanel);
        Test.stopTest();
    }
    
    private static testMethod void productsTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_RenderComponents_Controller ref=new ALL_RenderComponents_Controller();
        ref.tabNameSelected='Products';
        ref.oppLocationRecord=locRecord;
        
        Test.startTest();
        ApexPages.Component outputTextPanel=ref.getOutputTextPanel();
        
        system.assertNotEquals(Null, outputTextPanel);
        Test.stopTest();
    }
    
    private static testMethod void questionsTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_RenderComponents_Controller ref=new ALL_RenderComponents_Controller();
        ref.tabNameSelected='Questions';
        ref.oppLocationRecord=locRecord;
        
        Test.startTest();
        ApexPages.Component outputTextPanel=ref.getOutputTextPanel();
        
        system.assertNotEquals(Null, outputTextPanel);
        Test.stopTest();
    }
    
    private static testMethod void negativeTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_RenderComponents_Controller ref=new ALL_RenderComponents_Controller();
        
        Test.startTest();
        ApexPages.Component outputTextPanel=ref.getOutputTextPanel();
        
        system.assertNotEquals(Null, outputTextPanel);
        Test.stopTest();
    }
    
    private static testMethod void pdfVersionTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_RenderComponents_Controller ref=new ALL_RenderComponents_Controller();
        ref.tabNameSelected='Print Version';
        ref.oppLocationRecord=locRecord;
        
        Test.startTest();
        ApexPages.Component outputTextPanel=ref.getOutputTextPanel();
        
        system.assertNotEquals(Null, outputTextPanel);
        Test.stopTest();
    }
}