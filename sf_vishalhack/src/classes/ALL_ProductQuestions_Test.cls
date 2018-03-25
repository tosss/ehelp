//2016-10-24- anirudh.singh@cdk.com- Created this test class for ALL_ProductQuestions_Controller.
@isTest
public class ALL_ProductQuestions_Test
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
        
        Discovery_Site_Workbook__c siteWorkbookRecord=[SELECT Id FROM Discovery_Site_Workbook__c WHERE Opportunity_Location__c=:locRecord.Id];
        
        List<Discovery_Question__c> questionsList=new List<Discovery_Question__c>();
        questionsList.add(generateQuestions(true, 'Text', 'Dealership Overview; General', 'Pre-Sale', Null, 1));
        questionsList.add(generateQuestions(true, 'Picklist', 'Dealership Overview', 'Pre-Sale', 'Yes, No', 4));
        questionsList.add(generateQuestions(true, 'MultiSelect Picklist', 'Dealership Overview', 'Post-Sale', 
                                            'CDK ELA Internet; Client provided DSL/Other; Client provided cable; Client provided fiber', 2));
        questionsList.add(generateQuestions(true, 'Date', 'Dealership Overview', 'Pre-Sale', Null, 3));
        insert questionsList;
        
        Opportunity_Location__c buildingRecord=[SELECT Id FROM Opportunity_Location__c WHERE Building_Site__c=:locRecord.Id LIMIT 1];
        Head_Count_Detail__c headCountRecord=new Head_Count_Detail__c();
        headCountRecord.Opportunity_Location__c=buildingRecord.Id;
        headCountRecord.Quantity__c=2;
        insert headCountRecord;
        
        CDK_Solution_Definition__c cdkSolutionRecord=new CDK_Solution_Definition__c();
        cdkSolutionRecord.Active__c=true;
        cdkSolutionRecord.Application_Area__c='Marketing';
        cdkSolutionRecord.Vendor__c='Test Vendor';
        cdkSolutionRecord.Dealership_Area__c='Front End';
        insert cdkSolutionRecord;
        
        Third_Party_Solution_Definition__c thirdPartySolutionRecord=new Third_Party_Solution_Definition__c();
        thirdPartySolutionRecord.Access_Type__c='Access';
        thirdPartySolutionRecord.Application_Area__c='Application Area';
        thirdPartySolutionRecord.Application_Name__c='App Name';
        thirdPartySolutionRecord.Business_Area__c='Business Area';        
        thirdPartySolutionRecord.Status__c='Sold';
        thirdPartySolutionRecord.Vendor__c='Vendor';
        insert thirdPartySolutionRecord;
        
        Solution_at_Site__c solutionAtSiteRecord=new Solution_at_Site__c();
        solutionAtSiteRecord.Current__c=true;
        solutionAtSiteRecord.CDK_Solution_Definition__c=cdkSolutionRecord.Id;
        solutionAtSiteRecord.Notes_Comments__c='notes';
        solutionAtSiteRecord.Opportunity_Location__c=locRecord.Id;
        solutionAtSiteRecord.Solution_Status__c='Sold';
        insert solutionAtSiteRecord;
        
        List<Discovery_Product_Definition__c> prodDefList=new List<Discovery_Product_Definition__c>();
        prodDefList.add(generateProductDefinitionRecord(true, 'BODYSHOP', 'Front End', 'F&I', cdkSolutionRecord.Id));
        prodDefList.add(generateProductDefinitionRecord(false, 'MENU', 'Dealer Ops', 'Accounting', cdkSolutionRecord.Id));
        prodDefList.add(generateProductDefinitionRecord(true, 'BOX UPGRADE', 'Fixed Ops', 'Parts', cdkSolutionRecord.Id));
        prodDefList.add(generateProductDefinitionRecord(true, 'DIGITAL CONTRACTING', 'Front End', 'F&I', cdkSolutionRecord.Id));
        prodDefList.add(generateProductDefinitionRecord(false, 'ADVENT', 'Fixed Ops', 'Body Shop', cdkSolutionRecord.Id));
        insert prodDefList;
        
        List<Discovery_Product_Question__c> prodQuesList=new List<Discovery_Product_Question__c>();
        Discovery_Product_Question__c prodQuesRecordOne=new Discovery_Product_Question__c();
        prodQuesRecordOne.Discovery_Product_Definition__c=prodDefList[0].Id;
        prodQuesRecordOne.Discovery_Question__c=questionsList[0].Id;
        prodQuesRecordOne.Order__c=10;
        prodQuesList.add(prodQuesRecordOne);
        
        Discovery_Product_Question__c prodQuesRecordTwo=new Discovery_Product_Question__c();
        prodQuesRecordTwo.Discovery_Product_Definition__c=prodDefList[2].Id;
        prodQuesRecordTwo.Discovery_Question__c=questionsList[2].Id;
        prodQuesRecordTwo.Order__c=20;
        prodQuesList.add(prodQuesRecordTwo);
        
        Discovery_Product_Question__c prodQuesRecordThree=new Discovery_Product_Question__c();
        prodQuesRecordThree.Discovery_Product_Definition__c=prodDefList[3].Id;
        prodQuesRecordThree.Discovery_Question__c=questionsList[3].Id;
        prodQuesRecordThree.Order__c=40;
        prodQuesList.add(prodQuesRecordThree);
        
        Discovery_Product_Question__c prodQuesRecordFour=new Discovery_Product_Question__c();
        prodQuesRecordFour.Discovery_Product_Definition__c=prodDefList[0].Id;
        prodQuesRecordFour.Discovery_Question__c=questionsList[3].Id;
        prodQuesRecordFour.Order__c=30;
        prodQuesList.add(prodQuesRecordFour);
        insert prodQuesList;
        
        List<Product_at_Site__c> prodAtSiteList=new List<Product_at_Site__c>();
        Product_at_Site__c prodRecordOne=new Product_at_Site__c();
        prodRecordOne.Discovery_Product_Definition__c=prodDefList[0].Id;
        prodRecordOne.Opportunity_Location__c=locRecord.Id;
        prodRecordOne.Current__c=true;
        prodRecordOne.Include_Questions__c=true;
        prodAtSiteList.add(prodRecordOne);
        
        Product_at_Site__c prodRecordTwo=new Product_at_Site__c();
        prodRecordTwo.Discovery_Product_Definition__c=prodDefList[2].Id;
        prodRecordTwo.Opportunity_Location__c=locRecord.Id;
        prodRecordTwo.Proposed__c=true;
        prodRecordTwo.Include_Questions__c=true;
        prodAtSiteList.add(prodRecordTwo);
        
        Product_at_Site__c prodRecordThree=new Product_at_Site__c();
        prodRecordThree.Discovery_Product_Definition__c=prodDefList[3].Id;
        prodRecordThree.Opportunity_Location__c=locRecord.Id;
        prodRecordThree.Proposed__c=true;
        prodAtSiteList.add(prodRecordThree);
        insert prodAtSiteList;
    }
    
    private static Discovery_Question__c generateQuestions(Boolean isActive, String answerDataType, String generalCategory, 
                                                           String questionType, String picklistValues, Integer orderNumber)
    {
        Discovery_Question__c questionRecord=new Discovery_Question__c();
        questionRecord.Active__c=isActive;
        questionRecord.Answer_DataType__c=answerDataType;
        questionRecord.General_Category__c=generalCategory;
        questionRecord.Discovery_Question_Text__c='Test Question ';
        questionRecord.Order__c=orderNumber;
        questionRecord.Question_Type__c=questionType;
        
        if(answerDataType=='Picklist' || answerDataType=='MultiSelect Picklist')
        {
            questionRecord.Picklist_Values__c=picklistValues;
        }
        
        return questionRecord;
    }
    
    private static Discovery_Product_Definition__c generateProductDefinitionRecord(Boolean active, String name, String department, String workflow, Id solutionId)
    {
        Discovery_Product_Definition__c productDefinitionRecord=new Discovery_Product_Definition__c();
        productDefinitionRecord.Active__c=active;
        productDefinitionRecord.Name=name;
        productDefinitionRecord.Department__c=department;
        productDefinitionRecord.Workflow__c=workflow;
        productDefinitionRecord.Discovery_Solution__c=solutionId;
        
        return productDefinitionRecord;
    }
    
    private static testMethod void displaySideBarTabsListTestOne()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        
        Test.startTest();
        ALL_ProductQuestions_Controller ref=new ALL_ProductQuestions_Controller();
        ref.siteWorkbookIdForQuestionsTab=locRecord.Discovery_Site_Workbooks__r[0].Id;
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        
        List<String> displaySideBarTabsList=ref.displaySideBarTabsList;
        system.assertEquals(2, displaySideBarTabsList.size());
        Test.stopTest();
    }
    
    private static testMethod void displaySideBarTabsListTestTwo()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        System.currentPageReference().getParameters().put('deptWorkflowName', EncodingUtil.urlEncode('Front End- F&I', 'UTF-8'));
        
        Test.startTest();
        ALL_ProductQuestions_Controller ref=new ALL_ProductQuestions_Controller();
        ref.siteWorkbookIdForQuestionsTab=locRecord.Discovery_Site_Workbooks__r[0].Id;
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        
        List<String> displaySideBarTabsList=ref.displaySideBarTabsList;
        system.assertEquals(2, displaySideBarTabsList.size());
        Test.stopTest();
    }
    
    private static testMethod void displaySideBarTabsListNegativeTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        
        Test.startTest();
        ALL_ProductQuestions_Controller ref=new ALL_ProductQuestions_Controller();
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        
        List<String> displaySideBarTabsList=ref.displaySideBarTabsList;
        system.assertEquals(Null, displaySideBarTabsList);
        Test.stopTest();
    }
    
    private static testMethod void questionAnswerComponentTestOne()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        
        Test.startTest();
        ALL_ProductQuestions_Controller ref=new ALL_ProductQuestions_Controller();
        ref.siteWorkbookIdForQuestionsTab=locRecord.Discovery_Site_Workbooks__r[0].Id;
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        
        List<String> displaySideBarTabsList=ref.displaySideBarTabsList;
        ApexPages.Component questionAnswerComponent=ref.getQuestionAnswerComponent();
        system.assertNotEquals(Null, questionAnswerComponent);
        system.assertEquals(1, questionAnswerComponent.childComponents.size());
        Test.stopTest();
    }
    
    private static testMethod void questionAnswerComponentNegativeTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        
        Test.startTest();
        ALL_ProductQuestions_Controller ref=new ALL_ProductQuestions_Controller();
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        
        ApexPages.Component questionAnswerComponent=ref.getQuestionAnswerComponent();
        system.assertNotEquals(Null, questionAnswerComponent);
        system.assertEquals(0, questionAnswerComponent.childComponents.size());
        Test.stopTest();
    }
    
    private static testMethod void pdfScenarioTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        System.currentPageReference().getParameters().put('deptWorkflowName', EncodingUtil.urlEncode('Front End- F&I', 'UTF-8'));
        
        Test.startTest();
        ALL_ProductQuestions_Controller ref=new ALL_ProductQuestions_Controller();
        ref.siteWorkbookIdForQuestionsTab=locRecord.Discovery_Site_Workbooks__r[0].Id;
        ref.questionsScenario='pdf';
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        List<String> displaySideBarTabsList=ref.displaySideBarTabsList;
        
        ApexPages.Component questionAnswerComponent=ref.getQuestionAnswerComponent();
        system.assertNotEquals(Null, questionAnswerComponent);
        system.assertEquals(2, questionAnswerComponent.childComponents.size());
        Test.stopTest();
    }
}