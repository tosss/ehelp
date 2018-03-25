/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Test class for IMP_WorkBookAcrossProjects_Controller
Test Class:
History
11/20/14    Kimiko Roberto      Created
01/03/15    Karl Simon          Added CMF_Info and SubprojectSite record generation and insertion logic into the
cloneWkbook_Test, cloneFailureSiteWBAlreadyExists, cloneFailureNoSelectedSourceSite, cloneFailureNoSelectedTargetSite methods.
The addition accommodates the decommissioning of prior functionality that auto-generated a Subproject Site upon population or
change of the Subproject__c.Main_Site__c  field (which is planned for de-commission during Phase 1 R3).

------------------------------------------------------------*/
@isTest
private class IMP_WorkBookAcrossProjects_Cont_Test{
    
    /*private static final Project__c proj;
    private static final Account acc;
    private static final Account acc2;
    private static final Site_Workbook__c siteWorkbook;
    private static final Discovery_Workbook_Category__c wCategory;
    private static final Account actTarget;
    private static final Project__c proj2;

    static{
        createCustomSettings();
        proj = generate_Project();
        system.debug('**proj: '+proj);
        
        acc = IMP_TestFactory_Helper.buildAccount();
        insert acc;
        system.debug('**acc: '+acc);
        
        acc2 = IMP_TestFactory_Helper.buildAccount();
        insert acc2;
        
        siteWorkbook = generate_SiteWorkbook(proj.Id,acc.Id);
        
        wCategory = GenerateTestData_Project(siteWorkbook.Id);
        
        actTarget = IMP_TestFactory_Helper.buildAccount(); //Target Site
        Insert actTarget;
        
        proj2 = generate_Project();
    }

    static testMethod void cloneWkbook_Test(){
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(proj2.Id);
        testSubProject.Main_Site__c = acc2.Id;
        insert testSubProject;
        
        CMF_Info__c testCMFInfo2 = IMP_TestFactory_Helper.buildCMFInfo(acc2.Id);
        insert testCMFInfo2;
        
        SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(acc2.Id, testSubProject.Id, testCMFInfo2.Id);
        insert testSubProjectSite;
        
        List<SubProjectSite__c> testSiteList = IMP_Project_Utility.queryRelatedRecordsWithAndCriteria(SObjectType.SubProjectSite__c.FieldSets.SubProject_Site_Common.getFields(),'SubProjectSite__c','Account__c',acc2.Id, 'SubProject__c', IMP_Project_Utility.OPERATOR_RELATIONAL_EQUAL, testSubProject.Id, null);
        //SubProjectSite__c testSite = [SELECT Id, Account__c FROM SubProjectSite__c WHERE Account__c = :acc2.Id AND SubProject__c = :testSubProject.Id ];
        SubProjectSite__c testSite = testSiteList.get(0);
        
        PageReference page = new PageReference('/apex/IMP_WorkBookAcrossProjects?id='+proj.Id);  
        test.setCurrentPage(page);
        //right here is where we select the source site target project and target site for that project
        IMP_WorkBookAcrossProjects_Controller cont = new IMP_WorkBookAcrossProjects_Controller();
        cont.siteClone.Site_Workbook__c = wCategory.Site_Workbook__c;
        cont.selectedProject.Project__c = proj2.Id;
        cont.selectedProject.Site__c = testSite.Account__c;
        //we clone the selected site workbook to the target project
        cont.cloneWkbook();
        cont.getSites();
        cont.getSources();
        
        //check if a site workbook was created within the target project
        List<Site_Workbook__c> createdSiteWkBookList = IMP_Project_Utility.queryRelatedRecordsWithAndCriteria(SObjectType.Site_Workbook__c.FieldSets.Site_Workbook_Commons.getFields(),'Site_Workbook__c','Site__c',testSite.Account__c, 'Project__c', IMP_Project_Utility.OPERATOR_RELATIONAL_EQUAL, proj2.Id, null);
        Site_Workbook__c createdSiteWkBook = createdSiteWkBookList.get(0);
        //Site_Workbook__c createdSiteWkBook = [SELECT Id FROM Site_Workbook__c WHERE Site__c = : testSite.Account__c AND Project__c =: proj2.Id];
        system.assert(createdSiteWkBook != null);
        
    }
    
    static testMethod void cloneFailureSiteWBAlreadyExists(){
        //create data that enables Site Workbook creation
        //this time we duplicate the cloning process so we'll fire an error the the site workbook is already existing.
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(proj2.Id);
        testSubProject.Main_Site__c = acc2.Id;
        insert testSubProject;
        
        CMF_Info__c testCMFInfo2 = IMP_TestFactory_Helper.buildCMFInfo(acc2.Id);
        insert testCMFInfo2;
        
        SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(acc2.Id, testSubProject.Id, testCMFInfo2.Id);
        insert testSubProjectSite;
        
        SubProjectSite__c testSite = [SELECT Id, Account__c FROM SubProjectSite__c WHERE Account__c = :acc2.Id AND SubProject__c = :testSubProject.Id ];
        
        PageReference page = new PageReference('/apex/IMP_WorkBookAcrossProjects?id='+proj.Id);  
        test.setCurrentPage(page);
        //right here is where we select the source site target project and target site for that project
        IMP_WorkBookAcrossProjects_Controller cont = new IMP_WorkBookAcrossProjects_Controller();
        cont.siteClone.Site_Workbook__c = wCategory.Site_Workbook__c;
        cont.selectedProject.Project__c = proj2.Id;
        cont.selectedProject.Site__c = testSite.Account__c;
        //we clone the selected site workbook to the target project
        cont.cloneWkbook();
        cont.getSites();
        cont.getSources();
        
        //check if a site workbook was created within the target project
        Site_Workbook__c createdSiteWkBook = [SELECT Id FROM Site_Workbook__c WHERE Site__c = : testSite.Account__c AND Project__c =: proj2.Id];
        system.assert(createdSiteWkBook != null);
        
        //we'll do the clone process again so an error will be fired that the site workbook is already existing.
        cont.cloneWkbook();
        Apexpages.Message errorMessage;
        errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
        system.assertEquals(true, errorMessage.getDetail().contains('Workbook for Site ' + acc2.Name + ' already exists in Project ' + proj2.Name));
        
    }
    
    static testMethod void cloneFailureNoSelectedSourceSite(){
        //create data that enables Site Workbook creation
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(proj2.Id);
        testSubProject.Main_Site__c = acc2.Id;
        insert testSubProject;
        
        CMF_Info__c testCMFInfo2 = IMP_TestFactory_Helper.buildCMFInfo(acc2.Id);
        insert testCMFInfo2;
        
        SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(acc2.Id, testSubProject.Id, testCMFInfo2.Id);
        insert testSubProjectSite;
        
        SubProjectSite__c testSite = [SELECT Id, Account__c FROM SubProjectSite__c WHERE Account__c = :acc2.Id AND SubProject__c = :testSubProject.Id ];
        
        PageReference page = new PageReference('/apex/IMP_WorkBookAcrossProjects?id='+proj.Id);  
        test.setCurrentPage(page);
        //right here is where we select the source site target project and target site for that project
        IMP_WorkBookAcrossProjects_Controller cont = new IMP_WorkBookAcrossProjects_Controller();
        //we'll assign the source site as null so an error will be thrown
        cont.siteClone.Site_Workbook__c = null;
        cont.selectedProject.Project__c = proj2.Id;
        cont.selectedProject.Site__c = testSite.Account__c;
        //we clone the selected site workbook to the target project
        cont.cloneWkbook();
        cont.getSites();
        cont.getSources();
        
        //check that an error occured after cloning due to the source site being null
        Apexpages.Message errorMessage;
        errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
        System.assertEquals(true, errorMessage.getDetail().contains('No Source Site record found. Please select a Source Site'));
  
    }
    
    static testMethod void cloneFailureNoSelectedTargetSite(){
        //create data that enables Site Workbook creation
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(proj2.Id);
        testSubProject.Main_Site__c = acc2.Id;
        insert testSubProject;
        
        CMF_Info__c testCMFInfo2 = IMP_TestFactory_Helper.buildCMFInfo(acc2.Id);
        insert testCMFInfo2;
        
        SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(acc2.Id, testSubProject.Id, testCMFInfo2.Id);
        insert testSubProjectSite;
        
        SubProjectSite__c testSite = [SELECT Id, Account__c FROM SubProjectSite__c WHERE Account__c = :acc2.Id AND SubProject__c = :testSubProject.Id ];
        
        PageReference page = new PageReference('/apex/IMP_WorkBookAcrossProjects?id='+proj.Id);  
        test.setCurrentPage(page);
        //right here is where we select the source site target project and target site for that project
        IMP_WorkBookAcrossProjects_Controller cont = new IMP_WorkBookAcrossProjects_Controller();
        cont.siteClone.Site_Workbook__c = wCategory.Site_Workbook__c;
        cont.selectedProject.Project__c = proj2.Id;
        //we'll assign the target site as null so an error will be thrown
        cont.selectedProject.Site__c = null;
        //we clone the selected site workbook to the target project
        cont.cloneWkbook();
        cont.getSites();
        cont.getSources();
        
        //check that an error occured after cloning due to the target site being null
        Apexpages.Message errorMessage;
        errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
        System.assertEquals(true, errorMessage.getDetail().contains('No Target Site record found. Please select a Target Site'));
        
    }
    
    private static Project__c generate_Project()
    {
        Project__c project = IMP_TestFactory_Helper.buildProject(0); 
        Insert project;
        
        return project;
    } 
    
    private static Site_Workbook__c generate_SiteWorkbook(Id projectId, Id AccountId)
    {
        Site_Workbook__c siteWkbook = IMP_TestFactory_Helper.buildSiteWorkbook(projectId);
        siteWkbook.Site__c = AccountId;
        Insert siteWkbook;  
        
        return siteWkbook;
    }
    
    private static Discovery_Workbook_Category__c GenerateTestData_Project(Id siteWorkBookId)
    {   
        Question_Category__c qCategory = IMP_TestFactory_Helper.buildDealershipNeed();
        insert qCategory;
        
        Discovery_Workbook_Category__c wCtegory = IMP_TestFactory_Helper.buildDiscoveryWorkbookCategory(qCategory.Id);
        wCtegory.Site_Workbook__c = siteWorkBookId;
        Insert wCtegory;
        
        List<Question__c> insertQuestion = new List<Question__c>();
        for (Integer ctr = 0; ctr< 3; ctr++) {
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
            Answer__c ans = IMP_TestFactory_Helper.buildAnswer(wCtegory.Id, questions.Id);
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
        
        return wCtegory;
    }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }*/
}