//2016-08-22- anirudh.singh@cdk.com- Created this test class for ALL_QuestionAnswer_Controller.
@isTest
public class ALL_QuestionAnswer_Test
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
        questionsList.add(generateQuestions(true, 'Text', 'Dealership Overview', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Picklist', 'Dealership Overview', 'Pre-Sale', 'Yes, No', Null, Null));
        questionsList.add(generateQuestions(true, 'MultiSelect Picklist', 'Dealership Overview', 'Post-Sale', 
                                            'CDK ELA Internet; Client provided DSL/Other; Client provided cable; Client provided fiber', Null, Null));
        questionsList.add(generateQuestions(true, 'Long Text Area', 'Dealership Overview', 'Other', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Text', 'Network Configuration and Capacities', 'Pre-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(false, 'Currency', 'Network Configuration and Capacities', 'Post-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'Checkbox', 'Network Configuration and Capacities', 'Post-Sale', Null, Null, Null));
        questionsList.add(generateQuestions(true, 'MultiSelect Picklist', 'Dealership Overview', 'Pre-Sale', 'Yes, No, True', Null, Null));
        insert questionsList;
        
        List<Discovery_Question__c> childQuestionsList=new List<Discovery_Question__c>();
        childQuestionsList.add(generateQuestions(true, 'Text', 'Dealership Overview', 'Pre-Sale', Null, questionsList[0].Id, Null));
        childQuestionsList.add(generateQuestions(true, 'Text', 'Dealership Overview', 'Pre-Sale', Null, questionsList[0].Id, Null));
        childQuestionsList.add(generateQuestions(true, 'Picklist', 'Dealership Overview', 'Pre-Sale', 'Yes, No', questionsList[7].Id, 'Yes'));
        childQuestionsList.add(generateQuestions(true, 'Checkbox', 'Dealership Overview', 'Pre-Sale', Null, questionsList[7].Id, Null));
        insert childQuestionsList;
        
        List<Discovery_Question__c> grandChildQuestionsList=new List<Discovery_Question__c>();
        grandChildQuestionsList.add(generateQuestions(true, 'Text', 'Dealership Overview', 'Pre-Sale', Null, childQuestionsList[2].Id, 'No'));
        grandChildQuestionsList.add(generateQuestions(true, 'Checkbox', 'Dealership Overview', 'Pre-Sale', Null, childQuestionsList[2].Id, 'Yes'));
        grandChildQuestionsList.add(generateQuestions(true, 'Picklist', 'Dealership Overview', 'Pre-Sale', 'Sunday, Monday', childQuestionsList[2].Id, 'Yes'));
        insert grandChildQuestionsList;
        
        List<Discovery_Answer__c> answersList=new List<Discovery_Answer__c>();
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[0].Id, questionsList[0].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[3].Id, questionsList[3].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, questionsList[5].Id, questionsList[5].Answer_DataType__c));
        answersList.add(generateAnswer(siteWorkbookRecord.Id, childQuestionsList[0].Id, childQuestionsList[0].Answer_DataType__c));
        
        Discovery_Answer__c answerRecordWithNAChecked=new Discovery_Answer__c();
        answerRecordWithNAChecked.Discovery_Site_Workbook__c=siteWorkbookRecord.Id;
        answerRecordWithNAChecked.Discovery_Question__c=questionsList[1].Id;
        answersList.add(answerRecordWithNAChecked);
        insert answersList;
        
        generateQuestionsTabData(locRecord, questionsList);
    }
    
    private static Discovery_Question__c generateQuestions(Boolean active, String answerDataType, String generalCategory, 
                                                           String questionType, String picklistValues, Id parentQuestionId, String parentAnsForRendrng)
    {
        Discovery_Question__c questionRecord=new Discovery_Question__c();
        questionRecord.Active__c=active;
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
    
    private static testMethod void categoryWithNoSubCategoryTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='Dealership Overview';
        ref.subCategoryNameForRecs=Null;
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> quesAnsWraprList=ref.questionAnswerWrapperList;
        Test.stopTest();
        
        List<Discovery_Question__c> questsList=[
            SELECT Id, General_Category__c, Parent_Question__c 
            FROM Discovery_Question__c 
            WHERE General_Category__c INCLUDES ('Dealership Overview')
            AND Active__c=true
        ];
        
        system.assertEquals(questsList.size(), quesAnsWraprList.size(), 'No of Questions Equate.');
        
        Integer noOfParentQuests=0;
        Integer noOfChildQuests=0;
        for(Discovery_Question__c questRec: questsList)
        {
            if(questRec.Parent_Question__c==Null)
            {
                noOfParentQuests++;
            }
            else
            {
                noOfChildQuests++;
            }
        }
        
        Integer noOfParentQuestsFetched=0;
        Integer noOfChildQuestsFetched=0;
        for(ALL_QuestionAnswer_Controller.QuestionAnswerWrapper wrapperRef: quesAnsWraprList)
        {
            if(wrapperRef.questionRecord.Parent_Question__c==Null)
            {
                noOfParentQuestsFetched++;
            }
            else
            {
                noOfChildQuestsFetched++;
            }
        }
        
        system.assertEquals(noOfParentQuests, noOfParentQuestsFetched, 'No of Parent Questions Equate.');
        system.assertEquals(noOfChildQuests, noOfChildQuestsFetched, 'No of Child Questions Equate.');
    }
    
    private static testMethod void categoryWithSubCategoryTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='Network Technical';
        ref.subCategoryNameForRecs='Network Configuration and Capacities';
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        Test.stopTest();
        
        List<Discovery_Question__c> questionsList=[
            SELECT Id, General_Category__c, Parent_Question__c, 
            (
                SELECT Id, General_Category__c, Parent_Question__c 
                FROM Dependent_Questions__r
            )
            FROM Discovery_Question__c 
            WHERE General_Category__c='Network Configuration and Capacities' 
            AND Active__c=true 
            AND Parent_Question__c=Null
        ];
        
        system.assertEquals(questionsList.size(), questionAnswerWrapperList.size());
        
        Integer noOfChildQuestionsFromController=0;
        for(ALL_QuestionAnswer_Controller.QuestionAnswerWrapper wrapperRef: questionAnswerWrapperList)
        {
            if(wrapperRef.questionRecord.Parent_Question__c!=Null)
            {
                noOfChildQuestionsFromController++;
            }
        }
        
        system.assertEquals(0, noOfChildQuestionsFromController);
    }
    
    private static testMethod void newQuestionsTest()
    {
        List<Discovery_Question__c> newQuestionsList=new List<Discovery_Question__c>();
        newQuestionsList.add(generateQuestions(true, 'Date', 'General', 'Pre-Sale', Null, Null, Null));
        newQuestionsList.add(generateQuestions(true, 'DateTime', 'General', 'Pre-Sale', Null, Null, Null));
        newQuestionsList.add(generateQuestions(true, 'Email', 'General', 'Pre-Sale', Null, Null, Null));
        newQuestionsList.add(generateQuestions(true, 'Number', 'General', 'Post-Sale', Null, Null, Null));
        newQuestionsList.add(generateQuestions(true, 'Phone', 'General', 'Pre-Sale', Null, Null, Null));
        newQuestionsList.add(generateQuestions(true, 'URL', 'General', 'Pre-Sale', Null, Null, Null));
        newQuestionsList.add(generateQuestions(true, 'Checkbox', 'General', 'Post-Sale', Null, Null, Null));
        newQuestionsList.add(generateQuestions(true, 'Currency', 'General', 'Pre-Sale', Null, Null, Null));
        insert newQuestionsList;
        
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='General';
        ref.subCategoryNameForRecs=Null;
        ref.orderByFieldName='Order_General__c';
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        Test.stopTest();
        
        List<Discovery_Question__c> questionsList=[
            SELECT Id, General_Category__c, Parent_Question__c, 
            (
                SELECT Id, General_Category__c, Parent_Question__c 
                FROM Dependent_Questions__r
            )
            FROM Discovery_Question__c 
            WHERE General_Category__c='General' 
            AND Active__c=true 
            AND Parent_Question__c=Null
        ];
        
        system.assertEquals(questionsList.size(), questionAnswerWrapperList.size());
    }
    
    private static testMethod void questionsforProductsTest()
    {
        List<Discovery_Question__c> questionsList=[
            SELECT Id, General_Category__c, Parent_Question__c, 
            (
                SELECT Id, General_Category__c, Parent_Question__c 
                FROM Dependent_Questions__r
            )
            FROM Discovery_Question__c 
            WHERE General_Category__c='Dealership Overview' 
            AND Active__c=true 
            AND Parent_Question__c=Null
        ];
        
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.questionIdsForRecs='['+questionsList[0].Id+', '+questionsList[1].Id+', '+questionsList[0].Dependent_Questions__r[0].Id+']';
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        ref.productNameForRecs='Advent';
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        Test.stopTest();
        
        system.assert(questionAnswerWrapperList.size()>0, 'Questions are present for Questions Tab.');
    }
    
    private static testMethod void noQuestionRecordsPresentTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='Solution Specific';
        ref.subCategoryNameForRecs=Null;
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        Test.stopTest();
        
        system.assertEquals(0, questionAnswerWrapperList.size());
        
        ref.saveAnswerRecords();
        system.assertEquals(0, questionAnswerWrapperList.size());
    }
    
    private static testMethod void checkboxAnswerTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='Network Configuration and Capacities';
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        system.assertEquals(Null, ref.questionAnswerWrapperList[1].answerRecord.Id);
        
        ref.questionAnswerWrapperList[1].answerRecord.Checkbox_Answer__c=true;
        ref.questionAnswerWrapperList[1].answerRecord.N_A__c=false;
        ref.saveAnswerRecords();
        Test.stopTest();
        
        Discovery_Answer__c answerSaved=[
            SELECT Id 
            FROM Discovery_Answer__c 
            WHERE Discovery_Site_Workbook__c=:locRecord.Discovery_Site_Workbooks__r[0].Id 
            AND Discovery_Question__c=:questionAnswerWrapperList[1].questionRecord.Id 
        ];
        
        system.assertEquals(answerSaved.Id, ref.questionAnswerWrapperList[1].answerRecord.Id);
        
        ref.questionAnswerWrapperList[1].answerRecord.Checkbox_Answer__c=true;
        ref.questionAnswerWrapperList[1].answerRecord.N_A__c=true;
        ref.saveAnswerRecords();
        
        answerSaved=[
            SELECT Id 
            FROM Discovery_Answer__c 
            WHERE Discovery_Site_Workbook__c=:locRecord.Discovery_Site_Workbooks__r[0].Id 
            AND Discovery_Question__c=:questionAnswerWrapperList[1].questionRecord.Id 
        ];
        
        system.assertEquals(answerSaved.Id, ref.questionAnswerWrapperList[1].answerRecord.Id);
        
        ref.questionAnswerWrapperList[1].answerRecord.Checkbox_Answer__c=false;
        ref.questionAnswerWrapperList[1].answerRecord.N_A__c=false;
        ref.saveAnswerRecords();
    }
    
    private static testMethod void otherDataTypeAnswerTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='Dealership Overview';
        ref.subCategoryNameForRecs=Null;
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        ref.saveAnswerRecords();
        
        Discovery_Answer__c answerSaved=[
            SELECT Id 
            FROM Discovery_Answer__c 
            WHERE Discovery_Site_Workbook__c=:locRecord.Discovery_Site_Workbooks__r[0].Id 
            AND Discovery_Question__c=:questionAnswerWrapperList[0].questionRecord.Id 
        ];
        
        system.assertEquals(answerSaved.Id, ref.questionAnswerWrapperList[0].answerRecord.Id);
        
        ref.questionAnswerWrapperList[0].answerRecord.Text_Answer__c='Test Answer Modified';
        ref.questionAnswerWrapperList[0].answerRecord.N_A__c=false;
        ref.saveAnswerRecords();
        Test.stopTest();
        
        answerSaved=[
            SELECT Id 
            FROM Discovery_Answer__c 
            WHERE Discovery_Site_Workbook__c=:locRecord.Discovery_Site_Workbooks__r[0].Id 
            AND Discovery_Question__c=:questionAnswerWrapperList[0].questionRecord.Id 
        ];
        
        system.assertEquals(answerSaved.Id, ref.questionAnswerWrapperList[0].answerRecord.Id);
        
        ref.questionAnswerWrapperList[0].answerRecord.N_A__c=true;
        ref.saveAnswerRecords();
        
        answerSaved=[
            SELECT Id 
            FROM Discovery_Answer__c 
            WHERE Discovery_Site_Workbook__c=:locRecord.Discovery_Site_Workbooks__r[0].Id 
            AND Discovery_Question__c=:questionAnswerWrapperList[0].questionRecord.Id 
        ];
        
        system.assertEquals(answerSaved.Id, ref.questionAnswerWrapperList[0].answerRecord.Id);
    }
    
    private static testMethod void multiselectDataTypeAnswerTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='Dealership Overview';
        ref.subCategoryNameForRecs=Null;
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        
        ref.questionAnswerWrapperList[5].answerRecord.Multiselect_Picklist_Answer__c='[Post-Sale, CDK ELA Internet]';
        ref.saveAnswerRecords();
        Test.stopTest();
        
        Discovery_Answer__c answerSaved=[
            SELECT Id 
            FROM Discovery_Answer__c 
            WHERE Discovery_Site_Workbook__c=:locRecord.Discovery_Site_Workbooks__r[0].Id 
            AND Discovery_Question__c=:questionAnswerWrapperList[0].questionRecord.Id 
        ];
        
        system.assertEquals(answerSaved.Id, ref.questionAnswerWrapperList[0].answerRecord.Id);
    }
    
    private static testMethod void pdfVersionTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='Network Configuration and Capacities';
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        ref.questionsScenario='pdf';
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        system.assertEquals(Null, ref.questionAnswerWrapperList[1].answerRecord.Id);
        Test.stopTest();
    }
    
    private static testMethod void quickSaveAnswersNegTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='Dealership Overview';
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        Test.stopTest();
        
        String ansObject='{"answerId":"Null","dataType":"Picklist","fieldValue":"No","siteWorkBookId":"'+ref.questionAnswerWrapperList[0].answerRecord.Discovery_Site_Workbook__c
            +'","quesId":"'+ref.questionAnswerWrapperList[0].answerRecord.Discovery_Question__c+'"}';
        
        List<String> ansCleared=new List<String>();
        ansCleared.add(ref.questionAnswerWrapperList[1].answerRecord.Id);
        
        ALL_QuestionAnswer_Controller.quickSaveAnswers(ansObject, ansCleared);
    }
    
    private static testMethod void quickSaveAnswersTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='Dealership Overview';
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        Test.stopTest();
        
        String ansObject='{"answerId":"'+ref.questionAnswerWrapperList[0].answerRecord.Id
            +'","dataType":"Picklist","fieldValue":"No","siteWorkBookId":"'+ref.questionAnswerWrapperList[0].answerRecord.Discovery_Site_Workbook__c
            +'","quesId":"'+ref.questionAnswerWrapperList[0].answerRecord.Discovery_Question__c+'"}';
        
        List<String> ansCleared=new List<String>();
        ansCleared.add(ref.questionAnswerWrapperList[1].answerRecord.Id);
        
        ALL_QuestionAnswer_Controller.quickSaveAnswers(ansObject, ansCleared);
        
        String ansObject1='{"answerId":"","dataType":"Picklist","fieldValue":"No","siteWorkBookId":"'+ref.questionAnswerWrapperList[0].answerRecord.Discovery_Site_Workbook__c
            +'","quesId":"'+ref.questionAnswerWrapperList[0].answerRecord.Discovery_Question__c+'"}';
        
        ALL_QuestionAnswer_Controller.quickSaveAnswers(ansObject1, ansCleared);
    }
    
    private static testMethod void quickSaveNAAnswersTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Discovery_Site_Workbooks__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_QuestionAnswer_Controller ref=new ALL_QuestionAnswer_Controller();
        ref.categoryNameForRecs='Dealership Overview';
        ref.discoverySiteWorkbookIdForRecs=locRecord.Discovery_Site_Workbooks__r[0].Id;
        
        Test.startTest();
        List<ALL_QuestionAnswer_Controller.QuestionAnswerWrapper> questionAnswerWrapperList=ref.questionAnswerWrapperList;
        Test.stopTest();
        
        String ansObject1='{"answerId":"'+ref.questionAnswerWrapperList[0].answerRecord.Id
            +'","dataType":"Text","fieldValue":"true","siteWorkBookId":"'+ref.questionAnswerWrapperList[0].answerRecord.Discovery_Site_Workbook__c
            +'","quesId":"'+ref.questionAnswerWrapperList[0].answerRecord.Discovery_Question__c+'"}';
        
        String ansObject2='{"answerId":"'+ref.questionAnswerWrapperList[1].answerRecord.Id
            +'","dataType":"Text","fieldValue":"true","siteWorkBookId":"'+ref.questionAnswerWrapperList[1].answerRecord.Discovery_Site_Workbook__c
            +'","quesId":"'+ref.questionAnswerWrapperList[1].answerRecord.Discovery_Question__c+'"}';
        
        List<String> naAnsObjectList=new List<String>();
        naAnsObjectList.add(ansObject1);
        naAnsObjectList.add(ansObject2);
        
        ALL_QuestionAnswer_Controller.quickSaveNAAnswers(naAnsObjectList);
    }
    
    public static testMethod void networkTest()
    {
        Test.startTest();
        String retMsg=ALL_QuestionAnswer_Controller.networkTest();
        Test.stopTest();
        
        system.assertEquals('Network Connected', retMsg, 'Network is connected.');
    }
}