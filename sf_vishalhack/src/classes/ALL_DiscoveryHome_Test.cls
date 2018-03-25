//2016-08-25- anirudh.singh@cdk.com- Created this class for Discovery Home Page Visualforce Component.
@isTest
public class ALL_DiscoveryHome_Test
{
    @TestSetup
    private static void setupData()
    {
        Account accountRecord=DS_TestObjects.NewAccount_Inserted();
        
        Opportunity oppRecord=DS_TestObjects.NewOpportunity();
        oppRecord.AccountId=accountRecord.Id;
        insert oppRecord;
        
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        
        Opportunity_Location__c locRecord=[
            SELECT Id 
            FROM Opportunity_Location__c 
            WHERE RecordTypeId=:siteRecordTypeId 
            AND Opportunity__c=:oppRecord.Id 
            AND Site__c=:accountRecord.Id
        ];
        
        Discovery_Site_Workbook__c siteWorkbookRecord=[SELECT Id FROM Discovery_Site_Workbook__c WHERE Opportunity_Location__c=:locRecord.Id];
        
        List<Discovery_Question__c> questionsList=new List<Discovery_Question__c>();
        questionsList.add(generateQuestions(true, 'Text', 'Dealership Overview; General', 'Pre-Sale', Null, Null, Null));
        
        questionsList.add(generateQuestions(true, 'Picklist', 'Dealership Overview', 'Pre-Sale', 'Yes, No', Null, Null));
        questionsList.add(generateQuestions(true, 'MultiSelect Picklist', 'Dealership Overview', 'Post-Sale', 
                                            'CDK ELA Internet; Client provided DSL/Other; Client provided cable; Client provided fiber', Null, Null));
        questionsList.add(generateQuestions(true, 'Date', 'Dealership Overview', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'DateTime', 'Dealership Overview', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Email', 'Dealership Overview', 'Post-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Long Text Area', 'Dealership Overview', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Phone', 'Dealership Overview', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'URL', 'Dealership Overview', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Number', 'Dealership Overview', 'Post-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Checkbox', 'Dealership Overview', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Currency', 'Dealership Overview', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Text', 'Dealership Overview', 'Pre-Sale', Null, Null, Null));
        
        questionsList.add(generateQuestions(true, 'MultiSelect Picklist', 'General', 'Post-Sale', 
                                            'CDK ELA Internet; Client provided DSL/Other; Client provided cable; Client provided fiber', Null, Null));
        questionsList.add(generateQuestions(true, 'Text', 'General', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Number', 'General', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Picklist', 'General', 'Pre-Sale', 'Yes, No', Null, Null));
        questionsList.add(generateQuestions(true, 'MultiSelect Picklist', 'General', 'Post-Sale', 
                                            'CDK ELA Internet; Client provided DSL/Other; Client provided cable; Client provided fiber', Null, Null));
        questionsList.add(generateQuestions(true, 'MultiSelect Picklist', 'General', 'Post-Sale', 
                                            'CDK ELA Internet, Client provided DSL/Other, Client provided cable, Client provided fiber', Null, Null));
        questionsList.add(generateQuestions(true, 'MultiSelect Picklist', 'General', 'Post-Sale', 
                                            'CDK ELA Internet, Client provided DSL/Other, Client provided cable, Client provided fiber', Null, Null));
        insert questionsList;
        
        List<Discovery_Question__c> childQuestionsList=new List<Discovery_Question__c>();
        childQuestionsList.add(generateQuestions(true, 'Text', 'Dealership Overview', 'Pre-Sale', Null, questionsList[0].Id, Null));
        childQuestionsList.add(generateQuestions(true, 'Picklist', 'Dealership Overview', 'Pre-Sale', 'Yes, No', questionsList[0].Id, Null));
        childQuestionsList.add(generateQuestions(true, 'Checkbox', 'Dealership Overview', 'Pre-Sale', Null, questionsList[0].Id, Null));
        childQuestionsList.add(generateQuestions(true, 'Currency', 'Dealership Overview', 'Pre-Sale', Null, questionsList[0].Id, Null));
        
        childQuestionsList.add(generateQuestions(true, 'Text', 'Dealership Overview', 'Pre-Sale', Null, questionsList[1].Id, 'Yes'));
        childQuestionsList.add(generateQuestions(true, 'Picklist', 'Dealership Overview', 'Pre-Sale', 'Yes, No', questionsList[1].Id, Null));
        childQuestionsList.add(generateQuestions(true, 'Checkbox', 'Dealership Overview', 'Pre-Sale', Null, questionsList[1].Id, Null));
        
        childQuestionsList.add(generateQuestions(true, 'Picklist', 'Dealership Overview', 'Pre-Sale', 'Yes, No', questionsList[2].Id, Null));
        
        childQuestionsList.add(generateQuestions(true, 'Picklist', 'General', 'Pre-Sale', 'Yes, No', questionsList[13].Id, 
                                                 'CDK ELA Internet; Client provided DSL/Other; Client provided cable'));
        childQuestionsList.add(generateQuestions(true, 'Text', 'General', 'Pre-Sale', Null, questionsList[13].Id, 'CDK ELA Internet; Client provided DSL/Other'));
        
        childQuestionsList.add(generateQuestions(true, 'Checkbox', 'General', 'Pre-Sale', Null, questionsList[14].Id, Null));
        childQuestionsList.add(generateQuestions(true, 'Number', 'General', 'Pre-Sale', Null, questionsList[15].Id, Null));
        childQuestionsList.add(generateQuestions(true, 'Picklist', 'General', 'Pre-Sale', 'Yes, No', questionsList[16].Id, Null));
        childQuestionsList.add(generateQuestions(true, 'Url', 'General', 'Pre-Sale', Null, questionsList[17].Id, Null));
        childQuestionsList.add(generateQuestions(true, 'Url', 'General', 'Pre-Sale', Null, questionsList[18].Id, 'CDK ELA Internet, Client provided DSL/Other'));
        childQuestionsList.add(generateQuestions(true, 'Text', 'General', 'Pre-Sale', Null, questionsList[19].Id, 'CDK ELA Internet'));
        insert childQuestionsList;
        
        /*List<Discovery_Question__c> grandChildQuestionsList=new List<Discovery_Question__c>();
        grandChildQuestionsList.add(generateQuestions(true, 'Text', 'Dealership Overview', 'Pre-Sale', Null, childQuestionsList[2].Id, 'No'));
        grandChildQuestionsList.add(generateQuestions(true, 'Checkbox', 'Dealership Overview', 'Pre-Sale', Null, childQuestionsList[2].Id, 'Yes'));
        grandChildQuestionsList.add(generateQuestions(true, 'Picklist', 'Dealership Overview', 'Pre-Sale', 'Sunday, Monday', childQuestionsList[2].Id, 'Yes'));
        insert grandChildQuestionsList;*/
        
        List<Discovery_Answer__c> answersList=new List<Discovery_Answer__c>();
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[0].Id, questionsList[0].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[1].Id, questionsList[1].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[2].Id, questionsList[2].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[3].Id, questionsList[3].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[4].Id, questionsList[4].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[5].Id, questionsList[5].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[6].Id, questionsList[6].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[7].Id, questionsList[7].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[8].Id, questionsList[8].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[9].Id, questionsList[9].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[10].Id, questionsList[10].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[11].Id, questionsList[11].Answer_DataType__c));
        answersList.add(generateNAAnswer(siteWorkbookRecord.Id, questionsList[12].Id));
        
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[13].Id, questionsList[13].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[14].Id, questionsList[14].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[15].Id, questionsList[15].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[16].Id, questionsList[16].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[17].Id, questionsList[17].Answer_DataType__c));
        Discovery_Answer__c answerRecordP18=generateAnswer(siteWorkbookRecord.Id, questionsList[18].Id, questionsList[18].Answer_DataType__c);
        answerRecordP18.Multiselect_Picklist_Answer__c='CDK ELA Internet';
        answersList.add(answerRecordP18);
        Discovery_Answer__c answerRecordP19=generateAnswer(siteWorkbookRecord.Id, questionsList[19].Id, questionsList[19].Answer_DataType__c);
        answerRecordP19.Multiselect_Picklist_Answer__c='CDK ELA Internet; Client provided DSL/Other';
        answersList.add(answerRecordP19);
        
        answersList.add(generateAnswer(siteWorkbookRecord.Id, childQuestionsList[8].Id, childQuestionsList[8].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, childQuestionsList[9].Id, 'Date'));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, childQuestionsList[10].Id, childQuestionsList[10].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, childQuestionsList[11].Id, 'Picklist'));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, childQuestionsList[12].Id, childQuestionsList[12].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, childQuestionsList[13].Id, 'Checkbox'));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, childQuestionsList[14].Id, childQuestionsList[14].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, childQuestionsList[15].Id, childQuestionsList[15].Answer_DataType__c));
        insert answersList;
        
        Opportunity_Location__c buildingRecord=[SELECT Id FROM Opportunity_Location__c WHERE Building_Site__c=:locRecord.Id LIMIT 1];
        Head_Count_Detail__c headCountRecord=new Head_Count_Detail__c();
        headCountRecord.Opportunity_Location__c=buildingRecord.Id;
        headCountRecord.Quantity__c=2;
        insert headCountRecord;
        
        generateQuestionsTabData(locRecord, questionsList);
    }
    
    private static Discovery_Question__c generateQuestions(Boolean isActive, String answerDataType, String generalCategory, 
                                                           String questionType, String picklistValues, Id parentQuestionId, String parentAnsForRendrng)
    {
        Discovery_Question__c questionRecord=new Discovery_Question__c();
        questionRecord.Active__c=isActive;
        questionRecord.Answer_DataType__c=answerDataType;
        questionRecord.General_Category__c=generalCategory;
        questionRecord.Discovery_Question_Text__c='Test Question ';
        questionRecord.Question_Type__c=questionType;
        questionRecord.Parent_Question__c=parentQuestionId;
        questionRecord.Parent_Answer_For_Child_Rendering__c=parentAnsForRendrng;
        
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
    
    private static Discovery_Answer__c generateNAAnswer(Id siteWorkbookRecordId, Id questionId)
    {
        Discovery_Answer__c answerRecord=new Discovery_Answer__c();
        answerRecord.Discovery_Site_Workbook__c=siteWorkbookRecordId;
        answerRecord.Discovery_Question__c=questionId;
        answerRecord.N_A__c=true;
        return answerRecord;
    }
    
    private static Discovery_Answer__c generateAnswer(Id siteWorkbookRecordId, Id questionId, String answerDataType)
    {
        Discovery_Answer__c answerRecord=new Discovery_Answer__c();
        answerRecord.Discovery_Site_Workbook__c=siteWorkbookRecordId;
        answerRecord.Discovery_Question__c=questionId;
        if(answerDataType=='Text')
        {
            answerRecord.Text_Answer__c='Test';
        }
        else if(answerDataType=='Picklist')
        {
            answerRecord.Picklist_Answer__c='Yes';
        }
        else if(answerDataType=='MultiSelect Picklist')
        {
            answerRecord.Multiselect_Picklist_Answer__c='Client provided cable, Client provided fiber';
        }
        else if(answerDataType=='Date')
        {
            answerRecord.Date_Answer__c=system.today();
        }
        else if(answerDataType=='DateTime')
        {
            answerRecord.Date_Time_Answer__c=system.now();
        }
        else if(answerDataType=='Email')
        {
            answerRecord.Email_Answer__c='abc@email.com';
        }
        else if(answerDataType=='Long Text Area')
        {
            answerRecord.Long_Text_Area_Answer__c='Test demo 13114';
        }
        else if(answerDataType=='Phone')
        {
            answerRecord.Phone_Answer__c='92849124899';
        }
        else if(answerDataType=='URL')
        {
            answerRecord.URL_Answer__c='www.google.com';
        }
        else if(answerDataType=='Number')
        {
            answerRecord.Number_Answer__c=938597;
        }
        else if(answerDataType=='Checkbox')
        {
            answerRecord.Checkbox_Answer__c=true;
        }
        else if(answerDataType=='Currency')
        {
            answerRecord.Currency_Answer__c=9891274;
        }
        return answerRecord;
    }
    
    private static void generateQuestionsTabData(Opportunity_Location__c locRecord, List<Discovery_Question__c> questionsList)
    {
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
        insert prodQuesList;
        
        List<Product_at_Site__c> prodAtSiteList=new List<Product_at_Site__c>();
        Product_at_Site__c prodRecordOne=new Product_at_Site__c();
        prodRecordOne.Discovery_Product_Definition__c=prodDefList[0].Id;
        prodRecordOne.Opportunity_Location__c=locRecord.Id;
        prodRecordOne.Current__c=true;
        prodRecordOne.Include_Questions__c=true;
        prodAtSiteList.add(prodRecordOne);
        
        Product_at_Site__c prodRecordTwo=new Product_at_Site__c();
        prodRecordTwo.Discovery_Product_Definition__c=prodDefList[0].Id;
        prodRecordTwo.Opportunity_Location__c=locRecord.Id;
        prodRecordTwo.Proposed__c=true;
        prodRecordOne.Include_Questions__c=true;
        prodAtSiteList.add(prodRecordTwo);
        insert prodAtSiteList;
    }
    
    private static testMethod void homeTabTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        
        Test.startTest();
        ALL_DiscoveryHome_Controller constructorRef=new ALL_DiscoveryHome_Controller();
        Test.stopTest();
        
        system.assertEquals('Home', constructorRef.selectedTab);
    }
    
    private static testMethod void nonHomeTabTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        System.currentPageReference().getParameters().put('tabName', 'Dealership Overview');
        
        Test.startTest();
        ALL_DiscoveryHome_Controller constructorRef=new ALL_DiscoveryHome_Controller();
        Test.stopTest();
        
        system.assertEquals('Dealership Overview', constructorRef.selectedTab);
    }
    
    private static testMethod void dealershipOverviewTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        
        Test.startTest();
        ALL_DiscoveryHome_Controller constructorRef=new ALL_DiscoveryHome_Controller();
        Test.stopTest();
        
        ALL_DiscoveryHome_Controller.HomePageWrapper wrapperRecord;
        for(Integer i=0; i<constructorRef.homePageWrapperList.size(); i++)
        {
            if(constructorRef.homePageWrapperList[i].tabName=='Dealership Overview')
            {
                wrapperRecord=constructorRef.homePageWrapperList[i];
                break;
            }
        }
        
        List<Discovery_Question__c> questionsList=new List<Discovery_Question__c>([
            SELECT Id, General_Category__c, 
            (
                SELECT Id, LastModifiedBy.Name, LastModifiedDate, Discovery_Site_Workbook__c
                FROM Discovery_Answers__r
                WHERE Discovery_Site_Workbook__c=:locRecord.Discovery_Site_Workbooks__r[0].Id 
                ORDER BY LastModifiedDate DESC
            )
            FROM Discovery_Question__c
            WHERE Active__c=true 
            AND General_Category__c INCLUDES ('Dealership Overview')
        ]);
        
        Integer numberOfAnsweredQuestions=0;
        Integer numberOfQuestionsForCategory=0;
        String lastModifiedBy;
        DateTime lastModifiedDate;
        
        for(Discovery_Question__c questionRecord: questionsList)
        {
            numberOfQuestionsForCategory++;
            if(questionRecord.Discovery_Answers__r.size()>0)
            {
                numberOfAnsweredQuestions+=questionRecord.Discovery_Answers__r.size();
                
                if(lastModifiedDate==Null)
                {
                    lastModifiedBy=questionRecord.Discovery_Answers__r[0].LastModifiedBy.Name;
                    lastModifiedDate=questionRecord.Discovery_Answers__r[0].LastModifiedDate;
                }
            }
        }
        
        String percentComplete=''+String.valueOf(((Decimal)numberOfAnsweredQuestions/(Decimal)numberOfQuestionsForCategory)*100)+'';
        
        system.assertEquals('Dealership Overview', wrapperRecord.tabName);
        system.assertEquals(lastModifiedBy, wrapperRecord.lastModifiedBy);
        system.assertEquals(lastModifiedDate, wrapperRecord.lastModifiedDate);
    }
    
    private static testMethod void generalTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        
        Test.startTest();
        ALL_DiscoveryHome_Controller constructorRef=new ALL_DiscoveryHome_Controller();
        Test.stopTest();
        
        ALL_DiscoveryHome_Controller.HomePageWrapper wrapperRecord;
        for(Integer i=0; i<constructorRef.homePageWrapperList.size(); i++)
        {
            if(constructorRef.homePageWrapperList[i].tabName=='General')
            {
                wrapperRecord=constructorRef.homePageWrapperList[i];
                break;
            }
        }
        
        List<Discovery_Question__c> questionsList=new List<Discovery_Question__c>([
            SELECT Id, General_Category__c, 
            (
                SELECT Id, LastModifiedBy.Name, LastModifiedDate, Discovery_Site_Workbook__c
                FROM Discovery_Answers__r
                WHERE Discovery_Site_Workbook__c=:locRecord.Discovery_Site_Workbooks__r[0].Id 
                ORDER BY LastModifiedDate DESC
            )
            FROM Discovery_Question__c
            WHERE Active__c=true 
            AND General_Category__c INCLUDES ('General')
        ]);
        
        Integer numberOfAnsweredQuestions=0;
        Integer numberOfQuestionsForCategory=0;
        String lastModifiedBy;
        DateTime lastModifiedDate;
        
        for(Discovery_Question__c questionRecord: questionsList)
        {
            numberOfQuestionsForCategory++;
            if(questionRecord.Discovery_Answers__r.size()>0)
            {
                numberOfAnsweredQuestions+=questionRecord.Discovery_Answers__r.size();
                
                if(lastModifiedDate==Null)
                {
                    lastModifiedBy=questionRecord.Discovery_Answers__r[0].LastModifiedBy.Name;
                    lastModifiedDate=questionRecord.Discovery_Answers__r[0].LastModifiedDate;
                }
            }
        }
        
        String percentComplete=''+String.valueOf(((Decimal)numberOfAnsweredQuestions/(Decimal)numberOfQuestionsForCategory)*100)+'';
        
        system.assertEquals('General', wrapperRecord.tabName);
        system.assertEquals(lastModifiedBy, wrapperRecord.lastModifiedBy);
        system.assertEquals(lastModifiedDate, wrapperRecord.lastModifiedDate);
    }
    
    private static testMethod void pdfVersionTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        Test.setCurrentPageReference(new PageReference('Page.ALL_DiscoveryHome')); 
        System.currentPageReference().getParameters().put('oppLocId', locRecord.Id);
        System.currentPageReference().getParameters().put('tabName', 'Print Version');
        
        Test.startTest();
        ALL_DiscoveryHome_Controller constructorRef=new ALL_DiscoveryHome_Controller();
        Test.stopTest();
        
        system.assertEquals(new List<ALL_DiscoveryHome_Controller.HomePageWrapper>(), constructorRef.homePageWrapperList);
    }
}