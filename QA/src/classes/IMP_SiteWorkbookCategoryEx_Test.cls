/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: IMP_SiteWorkbookCategory_Extension test class
History
09/03/14    Rey Austral         Created
11/26/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
12/08/14    Samuel Oberes       Added regex patterns for discovery question
------------------------------------------------------------*/
@isTest
public class IMP_SiteWorkbookCategoryEx_Test {

    private static final IMP_RegularExpressions__c regex { get; set; }

    static {
        regex = new IMP_RegularExpressions__c();
        regex.Name = 'DiscoveryQuestionPicklistDelimiter';
        regex.Pattern__c = '[\\\\s*;\\\\s*|\\\\s*,\\\\s*]';
        regex.ReplacementString__c = '_';
        insert regex;
    }

    static testMethod void loadQuestionAndAnswer()
    {
        
        Project__c proj = generate_Project();
        SubProject__c subProject = IMP_TestFactory_Helper.buildSubProject(proj.Id);
        insert subProject;
        Account acc = generate_Account();
        insert acc;
        CMF_Info__c cmfInfo = IMP_TestFactory_Helper.buildCMFInfo(acc.Id);
        insert cmfInfo;
        SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(acc.Id, subProject.Id, cmfInfo.Id);
        insert testSubProjectSite;
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id, acc.Id,subProject.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        list<Product__c> products = createProduct(sol_c.Id);
        generateDQuestionProduct(question,products);
        generateSiteProducts(testSubProjectSite.Id,products, subProject.Id);
        Discovery_Workbook_Interviewer__c interviewers = createInteviewer(wCategory.Id);
        Discovery_Workbook_Interviewee__c interviewees = createInterviewee(wCategory.Id);
        createCustomSettings();
        
        test.startTest();
        PageReference pageRef = Page.imp_siteworkbookcategory;
        pageRef.getParameters().put('id', wCategory.Id);
        pageRef.getParameters().put('subProject', subProject.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Discovery_Workbook_Category__c());
        IMP_SiteWorkbookCategory_Extension controller = new IMP_SiteWorkbookCategory_Extension(sc);
        test.stopTest();
        //check if all question has been retrieve        
     
        System.assertEquals(3,controller.qWrapper.size());
        
        //check if all answer has been retrieve
        System.assertEquals(3,controller.AnswersForEachQuestion.size());
        
    }
    
    static testMethod void testSaveAnswer()
    {
        Project__c proj = generate_Project();
        SubProject__c subProject = IMP_TestFactory_Helper.buildSubProject(proj.Id);
        insert subProject;
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id, acc.Id,subProject.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        createProduct(sol_c.Id);
        Discovery_Workbook_Interviewer__c interviewers = createInteviewer(wCategory.Id);
        Discovery_Workbook_Interviewee__c interviewees = createInterviewee(wCategory.Id);
        createCustomSettings();
        
        test.startTest();
        PageReference pageRef = Page.imp_siteworkbookcategory;
        pageRef.getParameters().put('id', wCategory.Id);
        pageRef.getParameters().put('subProject', subProject.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Discovery_Workbook_Category__c());
        IMP_SiteWorkbookCategory_Extension controller = new IMP_SiteWorkbookCategory_Extension(sc);
        
        //get previous answer
        Map<Id,Answer__c> ans = controller.AnswersForEachQuestion;   
        //update all null answer
        for(Answer__c answerTest : ans.values())
        {
            if (answerTest.Text_Answer__c == null || answerTest.Question__r.Dependent_Question__c!=null)
            {
                answerTest.Text_Answer__c = 'Updated answer';
                
            }
        }
        
        controller.AnswersForEachQuestion = ans;
        controller.SaveAnswers();
        controller.selectedQuestionId = question.get(0).Id;
        controller.tabSaveAnswer();
        test.stopTest();
        
        //check if all answer is updated
        //List<Answer__c> resultAnswer = [Select Id,Name from Answer__c where Text_Answer__c = null and Discovery_Workbook_Category__c =: wCategory.Id];
        //system.assertEquals(0, resultAnswer.size());
        
    }
    
    /*static testMethod void testRemoteSaveAnswer()
    {  
        Project__c proj = generate_Project();
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id,acc.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id,qCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        createProduct(sol_c.Id);
        Discovery_Workbook_Interviewer__c interviewers = createInteviewer(wCategory.Id);
        Discovery_Workbook_Interviewee__c interviewees = createInterviewee(wCategory.Id);
        createCustomSettings();
        
        test.startTest();
        PageReference pageRef = Page.imp_siteworkbookcategory;
        pageRef.getParameters().put('id', wCategory.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Discovery_Workbook_Category__c());
        IMP_SiteWorkbookCategory_Extension controller = new IMP_SiteWorkbookCategory_Extension(sc);
        
        //get previous answer
        Map<Id,Answer__c> ans = controller.AnswersForEachQuestion;   
        //update all null answer
        for(Answer__c answerTest : ans.values())
        {
            if (answerTest.Text_Answer__c == null)
            {
                answerTest.Text_Answer__c = 'Updated answer';
            }
        }
        controller.AnswersForEachQuestion = ans;
        //this the method that will be use in the autosave
        //controller.remoteSaveAnswer();
        test.stopTest();
        
        //check if all answer is updated
        List<Answer__c> resultAnswer = [Select Id,Name from Answer__c where Text_Answer__c = null and Discovery_Workbook_Category__c =: wCategory.Id];        
        system.assertEquals(0, resultAnswer.size());
    }*/
    
    static testMethod void testFilter()
    {
        Project__c proj = generate_Project();
        SubProject__c subProject = IMP_TestFactory_Helper.buildSubProject(proj.Id);
        insert subProject;
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id, acc.Id,subProject.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        List<Product__c> products = createProduct(sol_c.Id);
        Discovery_Workbook_Interviewer__c interviewers = createInteviewer(wCategory.Id);
        Discovery_Workbook_Interviewee__c interviewees = createInterviewee(wCategory.Id);
        
        createCustomSettings();
        generateDQuestionProduct(question,products);
        
        
        test.startTest();
        PageReference pageRef = Page.imp_siteworkbookcategory;
        pageRef.getParameters().put('id', wCategory.Id);
        pageRef.getParameters().put('subProject', subProject.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Discovery_Workbook_Category__c());
        IMP_SiteWorkbookCategory_Extension controller = new IMP_SiteWorkbookCategory_Extension(sc);
        //add value in the filter variable
        controller.marketSelectedValue = 'Dash - Small Auto';
        controller.projectTypeSelectedValue = 'Upgrade';
        
        List<String> solList = new List<String>();
        solList.add(sol_c.Id);
        controller.solutionSelectedValue = solList;
        
        List<String> prodList = new List<String>();
        String tempList = '';
        for (Product__c prods : products)
        {
            prodList.add(prods.Id);
            tempList += prods.Id + ',';
        }
        controller.tempSelectedProduct = tempList;
        controller.productSelectedValue = prodList;
        controller.getMarketItems();
        controller.getProjectTypeItems();
        //execute filter function
        //System.debug('About to call the performFilterQuestion function from within the Site Workbook Category controller.');
        controller.performFilterQuestion();
        //System.debug('Made it back to the test class, after controller completed the performFilterQuestion method.');
        test.stopTest();
        
        //check the number of records return
        System.assertEquals(3,controller.qWrapper.size());
    }
    
    static testMethod void testFilterSolutionOnly()
    {        
        Project__c proj = generate_Project();
        SubProject__c subProject = IMP_TestFactory_Helper.buildSubProject(proj.Id);
        insert subProject;
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id, acc.Id,subProject.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        List<Product__c> products = createProduct(sol_c.Id);
        Discovery_Workbook_Interviewer__c interviewers = createInteviewer(wCategory.Id);
        Discovery_Workbook_Interviewee__c interviewees = createInterviewee(wCategory.Id);
        
        createCustomSettings();
        generateDQuestionProduct(question,products);
        
        test.startTest();
        PageReference pageRef = Page.imp_siteworkbookcategory;
        pageRef.getParameters().put('id', wCategory.Id);
        pageRef.getParameters().put('subProject', subProject.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Discovery_Workbook_Category__c());
        IMP_SiteWorkbookCategory_Extension controller = new IMP_SiteWorkbookCategory_Extension(sc);
        controller.tempSelectedProduct ='';
        List<String> solList = new List<String>();
        solList.add(sol_c.Id);
        controller.solutionSelectedValue = solList;
        //System.debug('About to call the performFilterQuestion function from within the Site Workbook Category controller.');
        controller.performFilterQuestion();
        //System.debug('Made it back to the test class, after controller completed the performFilterQuestion method.');
        test.stopTest();
        
        
        //check the number of records return
        System.assertEquals(3,controller.qWrapper.size());
    }
    
    
    static testMethod void testClearFilter()
    {
        Project__c proj = generate_Project();
        SubProject__c subProject = IMP_TestFactory_Helper.buildSubProject(proj.Id);
        insert subProject;
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id, acc.Id,subProject.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id);
        Solution__c solutions = createSolution(qCategory.Id);
        List<Product__c> products = createProduct(solutions.Id);
        Discovery_Workbook_Interviewer__c interviewers = createInteviewer(wCategory.Id);
        Discovery_Workbook_Interviewee__c interviewees = createInterviewee(wCategory.Id);
        
        createCustomSettings();
        
        test.startTest();
        PageReference pageRef = Page.imp_siteworkbookcategory;
        pageRef.getParameters().put('id', wCategory.Id);
        pageRef.getParameters().put('subProject', subProject.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Discovery_Workbook_Category__c());
        IMP_SiteWorkbookCategory_Extension controller = new IMP_SiteWorkbookCategory_Extension(sc);
        //add value in the filter variable
        controller.marketSelectedValue = 'Dash - Small Auto';
        controller.projectTypeSelectedValue = 'Upgrade';
        
        List<String> solList = new List<String>();
        solList.add(solutions.Id);
        controller.solutionSelectedValue = solList;
        
        List<String> prodList = new List<String>();
        for (Product__c prods : products)
        {
            prodList.add(prods.Id);
        }
        controller.productSelectedValue = prodList;
        
        controller.clearFilter();
        test.stopTest();
        //check if filter variable has value
        system.assertEquals('',controller.marketSelectedValue);
        system.assertEquals('',controller.projectTypeSelectedValue);
        system.assertEquals(0,controller.solutionSelectedValue.size());
        system.assertEquals(0,controller.productSelectedValue.size());
    }
    
   /* static testMethod void testAddInterviewee()
    {
        Project__c proj = generate_Project();
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id,acc.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id,qCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        createProduct(sol_c.Id);
        Discovery_Workbook_Interviewer__c interviewers = createInteviewer(wCategory.Id);
        Discovery_Workbook_Interviewee__c interviewees = createInterviewee(wCategory.Id);
        
        createCustomSettings();
        
        test.startTest();
        PageReference pageRef = Page.imp_siteworkbookcategory;
        pageRef.getParameters().put('id', wCategory.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Discovery_Workbook_Category__c());
        IMP_SiteWorkbookCategory_Extension controller = new IMP_SiteWorkbookCategory_Extension(sc);
        //create a contact and assign in the interviewee variable
        Discovery_Workbook_Interviewee__c interviewee = new Discovery_Workbook_Interviewee__c();
        Id contactId = createNewContact().Id;
        interviewee.Interviewee__c = contactId;
        interviewee.Discovery_Workbook_Category__c = wCategory.Id;
        controller.captureInterviewee = interviewee;
        //execute adding of interviewee
        controller.addInterviewee();
        controller.SaveAnswers();
        test.stopTest();
        
        //check if the interviewee is added in the Discovery_Workbook_Interviewee__c object
        List<Discovery_Workbook_Interviewee__c> inters = [Select Id,Name from Discovery_Workbook_Interviewee__c where Discovery_Workbook_Category__c = :wCategory.Id and Interviewee__c= : contactId];
        
        system.assertEquals(1,inters.size());
    }
    static testMethod void removeInterviewee()
    {
        Project__c proj = generate_Project();
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id,acc.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id,qCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        createProduct(sol_c.Id);
        Discovery_Workbook_Interviewer__c interviewers = createInteviewer(wCategory.Id);
        Discovery_Workbook_Interviewee__c interviewees = createInterviewee(wCategory.Id);
        
        createCustomSettings();
        
        test.startTest();
        PageReference pageRef = Page.imp_siteworkbookcategory;
        pageRef.getParameters().put('id', wCategory.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Discovery_Workbook_Category__c());
        IMP_SiteWorkbookCategory_Extension controller = new IMP_SiteWorkbookCategory_Extension(sc);
        
        controller.setChosenInterviewee(interviewees.Id);
        controller.removeInterviewee();
        controller.SaveAnswers();
        test.stopTest();
        //check if the interviewee id is still exist in the database
        List<Discovery_Workbook_Interviewee__c> inters = [Select Id,Name from Discovery_Workbook_Interviewee__c where Discovery_Workbook_Category__c = :wCategory.Id and Interviewee__c= : interviewees.Id];
        
        system.assertEquals(0,inters.size());
        
    }
    */
    
    static testMethod void testCancelRedirection()
    {
        Project__c proj = generate_Project();
        SubProject__c subProject = IMP_TestFactory_Helper.buildSubProject(proj.Id);
        insert subProject;
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id, acc.Id,subProject.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        createProduct(sol_c.Id);
        Discovery_Workbook_Interviewer__c interviewers = createInteviewer(wCategory.Id);
        Discovery_Workbook_Interviewee__c interviewees = createInterviewee(wCategory.Id);
        createCustomSettings();
        
        test.startTest();
        PageReference pageRef = Page.imp_siteworkbookcategory;
        pageRef.getParameters().put('id', wCategory.Id);
        pageRef.getParameters().put('subProject', subProject.Id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Discovery_Workbook_Category__c());
        IMP_SiteWorkbookCategory_Extension controller = new IMP_SiteWorkbookCategory_Extension(sc);
        //String nextPage = controller.ViewClose();       
        test.stopTest();
        
        //check if the page is redirected correctly
        //System.assertEquals(nextPage, '/apex/imp_siteworkbook?id=' + proj.Id);
    }
    
    static testMethod void testEditRedirection()
    {
        Project__c proj = generate_Project();
        SubProject__c subProject = IMP_TestFactory_Helper.buildSubProject(proj.Id);
        insert subProject;
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id, acc.Id,subProject.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        createProduct(sol_c.Id);
        Discovery_Workbook_Interviewer__c interviewers = createInteviewer(wCategory.Id);
        Discovery_Workbook_Interviewee__c interviewees = createInterviewee(wCategory.Id);
        createCustomSettings();
        
        test.startTest();
        PageReference pageRef = Page.imp_siteworkbookcategory;
        pageRef.getParameters().put('id', wCategory.Id);
        pageRef.getParameters().put('subProject', subProject.Id);
        pageRef.getParameters().put('view','yes');
        Test.setCurrentPage(pageRef);
        
        //System.debug('About to instantiate the standard controller.');
        ApexPages.StandardController sc = new ApexPages.StandardController(new Discovery_Workbook_Category__c());
        //System.debug('Made it back to the test class, after standard controller instantiated with new Discovery Workbook Category.');
        IMP_SiteWorkbookCategory_Extension controller = new IMP_SiteWorkbookCategory_Extension(sc);
        controller.performFilterQuestion();
        controller.ViewEdit();       
        test.stopTest();
        
        //check if the page is redirected correctly
        System.assert(controller.isEditMode);
    }
    
    private static Project__c generate_Project()
    {
        Project__c proj = IMP_TestFactory_Helper.buildProject(0);
        Insert proj;
        
        return proj;
    }
    
    private static Account generate_Account()
    {
        List<Account> insertAccount = new List<Account>();
        Account actSource = IMP_TestFactory_Helper.buildAccount();
        insertAccount.add(actSource);            
        
        
        return actSource;
    }
    
    private static Site_Workbook__c generate_SiteWorkbook(Id projectId, Id AccountId, Id subProjectId)
    {
        Site_Workbook__c siteWorkbook = IMP_TestFactoryTemporary_Helper.buildSiteWorkbook(projectId, subProjectId);
        siteWorkbook.Site__c = AccountId;
        Insert siteWorkbook;  
        
        return siteWorkbook;
    }
    
    private static Question_Category__c createQuestionCategory() 
    {
        Question_Category__c qCategory = IMP_TestFactoryTemporary_Helper.buildDealershipNeed();
        insert qCategory;
        
        return qCategory;
    }
    
    private static Discovery_Workbook_Category__c GenerateTestData_Project(Id siteWorkBookId,Id qCategoryId)
    {       
        
        Discovery_Workbook_Category__c wCategory = IMP_TestFactoryTemporary_Helper.buildDiscoveryWorkbookCategory(qCategoryId);
        wCategory.Site_Workbook__c = siteWorkBookId;
        Insert wCategory;        
        
        
        return wCategory;
    }
    
    private static List<Question__c> createQuestion(Id wCategoryId)
    {
        Question__c quest2 = new Question__c();
        quest2.Active__c = true;
        quest2.Question_Text__c = 'This is a test question for CheckAnswerLockFunction';
        //quest2.Question_Category__c = qCategoryId;
        quest2.Answer_Type__c = 'Picklist';
        quest2.Cloneable__c = true;
        quest2.Project_Type__c = 'Upgrade';
        quest2.Market__c = 'Dash - Small Auto';
        quest2.Picklist_Values__c  = 'Yes; No; N/A';
        quest2.Toggle_Dependent__c = 'Yes';
        insert quest2;
        
        List<Question__c> insertQuestion = new List<Question__c>();
        for (Integer ctr = 0; ctr < 2; ctr++) 
        {
            Question__c quest = new Question__c();
            quest.Active__c = true;
            quest.Question_Text__c = 'This is a test question for item ' + String.valueOf(ctr);
            quest.Market__c = 'Dash - Small Auto';
            quest.Answer_Type__c = 'Text';
            //quest.Question_Category__c = qCategoryId;
            
            
            if (math.mod(ctr, 3) == 0)
            {               
                quest.Cloneable__c = false;
                quest.Project_Type__c = 'Upgrade';
                
                quest.Dependent_Question__c=quest2.Id;
            }else
            {                
                quest.Cloneable__c = true;
                quest.Question_Text__c = 'This is a test child question for CheckAnswerLockFunction';
                quest.Answer_Type__c='MultiSelect Picklist';
                quest.Picklist_Values__c  = 'Yes; No; N/A';
            }
            
            insertQuestion.add(quest);
        }
        insert insertQuestion;
        
        insertQuestion.add(quest2);
        
        List<Answer__c> insertAnswer =  new List<Answer__c>();
        Integer ctr2 = 0;
        for (Question__c questions : insertQuestion) 
        {
            Answer__c ans = new Answer__c();
            //ans.Discovery_Workbook_Category__c = wCategoryId;
            ans.Question__c = questions.Id;
            if (ans.Question__r.Answer_Type__c=='Picklist')//math.mod(ctr2, 2) == 0)
            {   
                //ans.Text_Answer__c = 'Source Answer' + questions.Id;
                ans.Picklist_Answer__c='Yes';
            }
            else if (ans.Question__r.Answer_Type__c=='MultiSelect Picklist')
            {   
                //ans.Text_Answer__c = 'Source Answer' + questions.Id;
                ans.MultiSelect_Picklist_Answer__c='Yes';
            }else 
            {
                ans.Text_Answer__c = 'Source Answer' + questions.Id;
                ans.YesNo_Answer__c = null;
                ans.Number_Answer__c = null;                
                ans.Currency_Answer__c = null;
            }
            ctr2++;
            insertAnswer.add(ans);
        }
        Insert insertAnswer;
        
        list<Discovery_Answer_Workbook_Category__c> insertAnswerWkbkCategoriesList = new list<Discovery_Answer_Workbook_Category__c>();
        for(Answer__c ans:insertAnswer)
        {
            Discovery_Answer_Workbook_Category__c dawc = new Discovery_Answer_Workbook_Category__c();
            dawc.Answer__c = ans.Id;
            dawc.Discovery_Workbook_Category__c = wCategoryId;
            insertAnswerWkbkCategoriesList.add(dawc);
        }
        insert insertAnswerWkbkCategoriesList;
        
        return insertQuestion;
    }
    
    
    private static Solution__c createSolution(Id qCategoryId)
    {
        Solution__c sol = IMP_TestFactoryTemporary_Helper.buildSolution(qCategoryId);
        Insert sol;
        
        return sol;
    }
    
    private static List<Product__c> createProduct(Id solutionId)
    {
        List<Product__c> prods = new List<Product__c>();
        Product__c prod = IMP_TestFactoryTemporary_Helper.buildProduct(solutionId);
        prod.Name = 'Baseline Payroll US/Canada';
        prods.add(prod);
        
        prod = IMP_TestFactoryTemporary_Helper.buildProduct(solutionId);
        prod.Name = 'Payroll Plus Premier';
        prods.add(prod);
        
        Insert prods;
        
        return prods;        
    }
    
    private static void generateDQuestionProduct(List<Question__c> questions, List<Product__c> products)
    {        
        List<Discovery_Question_Product__c> dest = new List<Discovery_Question_Product__c>();
        Integer ctr = 0;
        for(Product__c prod : products)
        {
            Integer ctr2 = 0;
            for (Question__c quest : questions)
            {
                if (math.mod(ctr2, 2) == ctr)
                {
                    Discovery_Question_Product__c qProd = IMP_TestFactoryTemporary_Helper.buildDiscoveryQuestionProduct(prod.Id, quest.Id);
                    dest.add(qProd);
                }
                ctr2++;
            }
            ctr++;
        }
        
        insert dest;
    }
    
   
    private static User createUser()
    {
        List<User> users = new List<User>();
        User user = IMP_TestFactory_Helper.buildUser();
        user.IsActive = true;
        
        users.add(user);
        insert user;
        
        return user;
    }
    
    private static Discovery_Workbook_Interviewer__c createInteviewer(Id wCategoryId)
    {   
        User mike = IMP_TestFactory_Helper.buildUser();
        
        Discovery_Workbook_Interviewer__c interviewer = new Discovery_Workbook_Interviewer__c();
        interviewer.Interviewer__c = mike.Id;
        interviewer.Discovery_Workbook_Category__c = wCategoryId;
        insert interviewer;
        
        
        return interviewer;
    }
    
    private static Discovery_Workbook_Interviewee__c createInterviewee(Id wCategoryId)
    {
        Contact contacts = IMP_TestFactory_Helper.buildContact(null);
        Insert contacts;
        
        Discovery_Workbook_Interviewee__c interviewee = new Discovery_Workbook_Interviewee__c();
        interviewee.Interviewee__c = contacts.Id;
        
        interviewee.Discovery_Workbook_Category__c = wCategoryId;
        insert interviewee;
        
        return interviewee;
    }
    
    private static Contact createNewContact()
    {
        Contact contacts = IMP_TestFactory_Helper.buildContact(null);
        Insert contacts;
        
        return contacts;
    }
    
    private static void generateSiteProducts(Id subProjectSiteId, list<Product__c> productList, Id subProjectId)
    {
        list<Site_Product__c> sprodList = new list<Site_Product__c>();
        for(Product__c prd:productList)
        {
            Site_Product__c sp = new Site_Product__c();
            sp.Product__c = prd.Id;
            sp.SubProjectSite__c = subProjectSiteId;
            sp.SubProject__c = subProjectId;
            sprodList.add(sp);
        }
        insert sprodList;
    }
    
    private static void createCustomSettings()
    {
        IMP_MarketList__c market = IMP_TestFactoryTemporary_Helper.buildMarketListItem(IMP_TestFactoryTemporary_Helper.Enum_MarketList.DASH_SMALL_AUTO);
        insert market;
        
        IMP_ProjectTypeList__c product = IMP_TestFactoryTemporary_Helper.buildProjectTypeItem(IMP_TestFactoryTemporary_Helper.Enum_ProjectTypeList.UPGRADE);
        insert product;
        
        IMP_AutoSaveTimers__c  timer = IMP_TestFactoryTemporary_Helper.buildAutoSaveTimerItem(IMP_TestFactoryTemporary_Helper.Enum_AutoSaveTimers.AUTO_SAVE);
        insert timer;
    }
    
}