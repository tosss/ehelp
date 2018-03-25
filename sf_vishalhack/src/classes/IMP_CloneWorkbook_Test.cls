/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test class for IMP_CloneWorkbook_Helper
Test Class:
History
10/09/14    Rey Austral         Created
11/18/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/
@isTest
public class IMP_CloneWorkbook_Test {
    /*static testMethod void cloneWorkbookPositiveTest()
    {
        Project__c proj = generate_Project();
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id,acc.Id);        
        Discovery_Workbook_Category__c wCategory = GenerateTestData_Project(siteWorkbook.Id);
        Account actTarget = IMP_TestFactory_Helper.buildAccount(); //Target Site
        Insert actTarget;
        
        IMP_CloneWorkbook_Helper clone = new IMP_CloneWorkbook_Helper();
        test.startTest();
        clone.cloneWorkBook(proj.Id, actTarget.Id, siteWorkbook.Id);
        test.stopTest();
        
        List<Question__c> nonCloneable = [Select Id,Name From Question__c where Cloneable__c = false];
        List<Question__c> Cloneable = [Select Id,Name From Question__c where Cloneable__c = true];
        List<Answer__c> ansNonCloneable = [Select Id,Name,Text_Answer__c From Answer__c where Discovery_Workbook_Category__c != :wCategory.id and Question__c In: nonCloneable and Text_Answer__c != null  ];
        List<Answer__c> ansCloneable = [Select Id,Name,Text_Answer__c From Answer__c where Discovery_Workbook_Category__c != :wCategory.id and Question__c In: Cloneable and Text_Answer__c != null  ];
        List<Answer__c> allTargetAns = [Select Id,Name,Text_Answer__c From Answer__c where Discovery_Workbook_Category__c != :wCategory.id ];
        List<Site_Workbook__c> targetSiteCreated = [Select Id,Name From Site_Workbook__c where Site__c != : actTarget.Id];
        //check if non-cloneable question has answer
        system.assertEquals(0, ansNonCloneable.size());
        //check if target question w/ cloneable has answer 
        system.assertEquals(3, ansCloneable.size());
        //check if all answer has been inserted
        system.assertEquals(10, allTargetAns.size());
        //check if target site is created
        system.assertEquals(1, targetSiteCreated.size());
    }
    
    static testMethod void cloneWorkbookSiteAlreadyExist()
    {
        Project__c proj = generate_Project();
        Account acc = generate_Account();
        Site_Workbook__c siteWorkbook = generate_SiteWorkbook(proj.Id,acc.Id);        
        GenerateTestData_Project(siteWorkbook.Id);
        
        IMP_CloneWorkbook_Helper clone = new IMP_CloneWorkbook_Helper();
        test.startTest();
        String result = clone.cloneWorkBook(proj.Id, acc.Id, siteWorkbook.Id);
        test.stopTest();
        system.assertEquals('The Site you have chosen already has a workbook for this project.  Please utilize it to continue your discovery, or if you intended to select a different site, please try selecting again.', result);
    }
    
    private static Project__c generate_Project()
    {
        Project__c proj = IMP_TestFactory_Helper.buildProject(0); //Project Test For Clone
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
    
    private static Site_Workbook__c generate_SiteWorkbook(Id projectId, Id AccountId)
    {
        Site_Workbook__c siteWorkbook = IMP_TestFactory_Helper.buildSiteWorkbook(projectId);
        siteWorkbook.Site__c = AccountId;
        Insert siteWorkbook;  
        
        return siteWorkbook;
    }
    
    private static Discovery_Workbook_Category__c GenerateTestData_Project(Id siteWorkBookId)
    {   
        Question_Category__c qCategory = IMP_TestFactory_Helper.buildDealershipNeed();
        insert qCategory;
        
        Discovery_Workbook_Category__c wCategory = IMP_TestFactory_Helper.buildDiscoveryWorkbookCategory(qCategory.Id);
        wCategory.Site_Workbook__c = siteWorkBookId;
        Insert wCategory;
        
        List<Question__c> insertQuestion = new List<Question__c>();
        for (Integer ctr = 0; ctr< 10; ctr++) {
            Question__c quest = IMP_TestFactory_Helper.buildQuestion(qCategory.Id, 
                                                                     IMP_TestFactory_Helper.Enum_MarketList.MANUAL_INPUT_OF_DEFAULT_VALS, 
                                                                     IMP_TestFactory_Helper.Enum_ProjectTypeList.MANUAL_INPUT_OF_DEFAULT_VALS);
            quest.Active__c = true;
            quest.Question_Text__c = 'This is a test question for item ' + String.valueOf(ctr);
            
            if (math.mod(ctr, 3) == 0) {
                quest.Cloneable__c = false;
            } else {
                system.debug(ctr + ' - Clone Question');
                quest.Cloneable__c = true;
            }
            insertQuestion.add(quest);
        }
        
        insert insertQuestion;
        
        List<Answer__c> insertAnswer =  new List<Answer__c>();
        Integer ctr2 = 0;
        for (Question__c questions : insertQuestion)  {
            Answer__c ans = IMP_TestFactory_Helper.buildAnswer(wCategory.Id, questions.Id);
            if (math.mod(ctr2, 2) == 0) {
                system.debug(ctr2 + ' - w/Answer ' + questions.Id);
                ans.Text_Answer__c = 'Source Answer' + questions.Id;
            } else {
                ans.YesNo_Answer__c = null;
                ans.Number_Answer__c = null;                
                ans.Currency_Answer__c = null;
                ans.Text_Answer__c = null;
            }
            ctr2++;
            insertAnswer.add(ans);
        }
        Insert insertAnswer;
        
        return wCategory;
    }*/
}