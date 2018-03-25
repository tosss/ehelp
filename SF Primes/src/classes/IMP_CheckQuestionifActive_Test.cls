/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Test class for IMP_CheckQuestionifActive_Handler
Test Class:
History
10/22/14    Kimiko Roberto      Created
11/14/14    Samuel Oberes       Updated createQuestion method, changed number of questions from <10 to <3
11/18/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/
@isTest
public class IMP_CheckQuestionifActive_Test {
    static testMethod void checkActiveField_Test(){
        Project__c proj = generate_Project();
        Account acc = generate_Account();
        SubProject__c subProj  = IMP_TestFactory_Helper.buildSubProject(proj.Id);
        insert subProj;
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id,acc.Id,subProj.Id);    
        Question_Category__c qCategory = createQuestionCategory();
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id,qCategory.Id);
        List<Question__c> question = createQuestion(wCategory.Id,qCategory.Id);
        Solution__c sol_c = createSolution(qCategory.Id);
        List<Product__c> products = createProduct(sol_c.Id);
        createCustomSettings();
        generateDQuestionProduct(question,products);
        
        List<Question__c> questionsTobeUpdated = [SELECT Id, Active__c FROM Question__c WHERE Id IN: question];
        if(!questionsTobeUpdated.isEmpty()){
            for(Question__c q :questionsTobeUpdated){
                q.Active__c = false;
            }
            update questionsTobeUpdated;
            
            for(Question__c q :questionsTobeUpdated){
                q.Active__c = true;
            }
            update questionsTobeUpdated;
        }
        
    }
    
    private static Project__c generate_Project()
    {
        Project__c proj = IMP_TestFactory_Helper.buildProject(1); //Project Test For Clone
        Insert proj;

        return proj;
    }
    
    private static Account generate_Account()
    {
        List<Account> insertAccount = new List<Account>();
        Account actSource = IMP_TestFactory_Helper.buildAccount(); //Source Site
        insertAccount.add(actSource);
        
        return actSource;
    }
    
    private static Site_Workbook__c generate_SiteWorkbook(Id projectId, Id AccountId, Id subProjectId)
    {
        Site_Workbook__c siteWorkbook = IMP_TestFactoryTemporary_Helper.buildSiteWorkbook(projectId, subProjectId);
        siteWorkbook.Site__c = AccountId;
        //siteWorkbook.SubProject__c=subProjectId;
        
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
    
    private static List<Question__c> createQuestion(Id wCategoryId, Id qCategoryId)
    {
        List<Question__c> insertQuestion = new List<Question__c>();
        for (Integer ctr = 0; ctr < 3; ctr++) {
            Question__c quest = IMP_TestFactoryTemporary_Helper.buildQuestion( 
                                                                     IMP_TestFactoryTemporary_Helper.Enum_MarketList.DASH_SMALL_AUTO, 
                                                                     IMP_TestFactoryTemporary_Helper.Enum_ProjectTypeList.UPGRADE);
            quest.Active__c = true;
            quest.Question_Text__c = 'This is a test question for item ' + String.valueOf(ctr);
            if (math.mod(ctr, 3) == 0) {               
                quest.Cloneable__c = false;
                quest.Market__c = IMP_TestFactoryTemporary_Helper.LITERAL_DASH_SMALL_AUTO;
            } else {                
                quest.Cloneable__c = true;
                quest.Market__c = IMP_TestFactoryTemporary_Helper.LITERAL_DMS_AGNOSTIC_APP_SHARED;
            }
            
            insertQuestion.add(quest);
        }
        
        insert insertQuestion;
        
        List<Answer__c> insertAnswer =  new List<Answer__c>();
        Integer ctr2 = 0;
        for (Question__c questions : insertQuestion) {
            Answer__c ans = IMP_TestFactoryTemporary_Helper.buildAnswer(questions.Id);
            if (math.mod(ctr2, 2) == 0) {
                ans.url_answer__c = 'Source Answer' + questions.Id;
            } else {
                ans.YesNo_Answer__c = null;
                ans.Number_Answer__c = null;                
                ans.Currency_Answer__c = null;
                ans.url_answer__c = null;
            }
            ctr2++;
            insertAnswer.add(ans);
        }
        insertAnswer.remove(2);
        Insert insertAnswer;
        
        return insertQuestion;
    }
    
    
    private static Solution__c createSolution(Id qCategoryId)
    {
        Solution__c sol = IMP_TestFactoryTemporary_Helper.buildSolution(qCategoryId); //Payroll
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
    
    private static void createCustomSettings()
    {
        insert IMP_TestFactoryTemporary_Helper.buildMarketListItem(IMP_TestFactoryTemporary_Helper.Enum_MarketList.DASH_SMALL_AUTO);

        insert IMP_TestFactoryTemporary_Helper.buildProjectTypeItem(IMP_TestFactoryTemporary_Helper.Enum_ProjectTypeList.UPGRADE);
        
        insert IMP_TestFactoryTemporary_Helper.buildAutoSaveTimerItem(IMP_TestFactoryTemporary_Helper.Enum_AutoSaveTimers.AUTO_SAVE);
    }
}