/*------------------------------------------------------------
Author: Jerick Laurio
Company: Cloud Sherpas
Description: Test class for IMP_SiteWorkbookExtension
Test Class:
History
09/09/14    Jerick Laurio      Created
10/08/14    Kimiko Roberto     Added test methods(for createworkbook, cloneworkbook, pagination, deleteacount, getsources)
11/20/14    Samuel Oberes      Added assertions for all the test methods 
11/27/14    Samuel Oberes      Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/

@isTest
private class IMP_SiteWorkbookExtension_Test {
    
    /*static testMethod void cloneWkbook_Test(){
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        system.runAs(testUser){
            Account testAccount = IMP_TestFactory_Helper.buildAccount();
            testAccount.Name = 'Test Account';
            insert testAccount;

            Account testAccount2 = IMP_TestFactory_Helper.buildAccount();
            testAccount2.Name = 'Test Account2';
            insert testAccount2;
            
            Project__c testProject = generate_Project();
            Site_Workbook__c testSiteWorkbook = generate_SiteWorkbook(testProject.Id, testAccount.Id);
            
            Question_Category__c testQuestionCat = createQuestionCategory();
            
            Discovery_Workbook_Category__c testDiscoveryWkbk = IMP_TestFactory_Helper.buildDiscoveryWorkbookCategory(testQuestionCat.Id);
            testDiscoveryWkbk.Project__c = testProject.Id;
            testDiscoveryWkbk.Site_Workbook__c = testSiteWorkbook.Id;
            insert testDiscoveryWkbk;
            
            List<Question__c> testQuestions = createQuestion(testDiscoveryWkbk.Id, testQuestionCat.id);

            //checklist item
            Checklist_Category__c testchkCategory = IMP_TestFactory_Helper.buildChecklistCategory();
            insert testchkCategory;

            Project_Checklist__c testPrjCheckList = IMP_TestFactory_Helper.buildProjectChecklist(testProject.Id, testchkCategory.Id);
            insert testPrjCheckList;

            Checklist_Item__c testChkListItem = IMP_TestFactory_Helper.buildChecklistItem(testchkCategory.Id);
            testChkListItem.Active__c = true;
            insert testChkListItem;

            Checklist_Answer__c testChkAnswer = IMP_TestFactory_Helper.buildChecklistAnswer(testPrjCheckList.Id);
            testChkAnswer.Response__c = 'testing';
            testChkAnswer.URL_Location__c = 'www.gmail.com';
            insert testChkAnswer;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(testProject);
            IMP_SiteWorkbook_Extension controller = new IMP_SiteWorkbook_Extension(sc);
            
            
            controller.site.Site__c = null;
            controller.siteClone.Site_Workbook__c = null;
            
            Apexpages.Message errorMessage;
            
            // if a site workbook wasn't provided, then cloning the workbook will throw an error
            controller.cloneWkbook();
            errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
            System.assertEquals(true, errorMessage.getDetail().contains('No Source Site record found. Please select a Source Site'));


            // if a site wasn't provided, then cloning the workbook will throw an error
            controller.siteClone.Site_Workbook__c = testSiteWorkbook.Id;
            controller.cloneWkbook();
            errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
            System.assertEquals(true, errorMessage.getDetail().contains('No Target Site record found. Please select a Target Site'));


            // expect that the workbook will get created successfully
            controller.site.Site__c = testAccount2.Id;
            controller.cloneWkbook();
            errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
            System.assertEquals(true, errorMessage.getDetail().contains('Workbook for Site ' + testAccount2.Name + ' has been created'));


            // if the workbook to be cloned contains a SiteID-ProjectID pair that is already existing in the site, expect an error to get thrown
            controller.cloneWkbook();
            errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
            System.assertEquals(true, errorMessage.getDetail().contains('Workbook for Site ' + testAccount2.Name + ' already exists'));
        }
        
    }
    */
   /* static testMethod void createWorkbookTest() {
        // -----------------------------------------------------------------------------
        // INITIALIZATION 
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        system.runAs(testUser){
            Account testAccount3 = IMP_TestFactory_Helper.buildAccount();
            testAccount3.Name = 'Test Account3';
            insert testAccount3;
            
            Project__c testProject = generate_Project();
            
            SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject();
            insert testSubProject;
            
            CMF_Info__c testCmfInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount3.Id);
          insert testCmfInfo;
            
            SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount3.Id, testSubProject.Id, testCmfInfo.Id);
          insert testSubProjectSite; 
          
          
          
            
            Question_Category__c testQuestionCat = createQuestionCategory();

            Question__c q;
            List<Question__c> questionsToInsertList = new List<Question__c>();

            for (Integer ctr = 0; ctr < 2; ctr++) {
                
                q = IMP_TestFactoryTemporary_Helper.buildQuestion(
                                                         IMP_TestFactoryTemporary_Helper.Enum_MarketList.DRIVE_BASELINE, 
                                                         IMP_TestFactoryTemporary_Helper.Enum_ProjectTypeList.UPGRADE);

                q.Active__c            = true;
                q.Question_Text__c     = 'This is a test question for item ' + String.valueOf(ctr);
                q.Cloneable__c    = true;
                
                /*if (math.mod(ctr, 3) == 0) {               
                    q.Cloneable__c    = false;
                } else {                
                    q.Cloneable__c    = true;
                    q.Market__c       = IMP_TestFactoryTemporary_Helper.LITERAL_DMS_AGNOSTIC_APP_SHARED;
                }*/
                
              /*  questionsToInsertList.add(q);
            }
            insert questionsToInsertList;
            
            
            Solution__c testSolution = IMP_TestFactoryTemporary_Helper.buildSolution(testQuestionCat.Id);
          insert testSolution;
          
           Product__c testProduct = IMP_TestFactoryTemporary_Helper.buildProduct(testSolution.Id);
          insert testProduct;
          
          Site_Product__c testSiteProduct = IMP_TestFactoryTemporary_Helper.buildSiteProduct(testSubProjectSite.Id, testProduct.Id, testSubProject.Id);
          insert testSiteProduct;
          
          Question__c qs =questionsToInsertList.size()>0 ? questionsToInsertList.get(0) : new Question__c();
          
          Discovery_Question_Product__c dquestionProduct = IMP_TestFactoryTemporary_Helper.buildDiscoveryQuestionProduct(testProduct.Id, qs.Id);
          insert dquestionProduct;
          
          Question__c qs2 =questionsToInsertList.get(1)!=null ? questionsToInsertList.get(1) : new Question__c();
          
          system.debug('-----Question2----'+qs2);
          
          
        Discovery_Question_Category__c dquestionCategory = IMP_TestFactoryTemporary_Helper.buildDiscoveryQuestionCategory(qs2.Id, testQuestionCat.Id);
        insert dquestionCategory;
          
            
            ApexPages.StandardController sc = new ApexPages.StandardController(testSubProject);
            IMP_SiteWorkbook_Extension controller = new IMP_SiteWorkbook_Extension(sc);
            
            controller.tempsite.Site__c = null;
            controller.project = testProject;
            ApexPages.CurrentPage().getParameters().put('subProject', testSubProject.Id);
            

            Apexpages.Message errorMessage;

            // -----------------------------------------------------------------------------
            // TESTING PROPER
            

            // if a site workbook wasn't provided, then cloning the workbook will throw an error
            controller.createWkbook();
            errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
            System.assertEquals(true, errorMessage.getDetail().contains('No Site record found. Please select a Site.'));


            // start the creation of the workbook
            controller.tempsite.Site__c = testAccount3.Id;
            controller.getSites();
            
            
            
            
            controller.createWkbook();


            // expect question-category count to be 1 because we have inserted a dealership need above
            /*List<Question_Category__c> questionCategoryList = IMP_Project_Utility.retrieveDealershipsWithQuestions();
            System.assertEquals(1, questionCategoryList.size());*/


            // for every question-category record, there will be 1 record of discovery workbook category.
            // expect 1 record of discovery workbook category since we already have 1 question-category record.
          /*  List<Discovery_Workbook_Category__c> autoCreatedDiscoverWorkbookCategoryList = [SELECT Id, Count_of_Questions__c FROM Discovery_Workbook_Category__c];
            System.assertEquals(1, autoCreatedDiscoverWorkbookCategoryList.size());


            // check if the created discovery workbook has the same question count
            /*for (Discovery_Workbook_Category__c dwc : autoCreatedDiscoverWorkbookCategoryList) {
                System.assertEquals(2, dwc.Count_of_Questions__c);
            }
            */


            // since there are 2 questions, expect 2 answers to automatically get created
            /*List<Answer__c> autoCreatedAnswers = [SELECT Id, Question__c FROM Answer__c ORDER BY Question__c];
            System.assertEquals(2, autoCreatedAnswers.size());


            // check if the answers refer to an existing question (or 1 of the questions created above)
            List<Question__c> manuallyCreatedQuestions = [SELECT Id FROM Question__c ORDER BY Id];
            for (Integer ctr = 0; ctr < manuallyCreatedQuestions.size() - 1; ctr++) {
                System.assertEquals(manuallyCreatedQuestions.get(ctr).Id, autoCreatedAnswers.get(ctr).Question__c);
            }
            

            // expect that the workbook will get created successfully
            errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
            System.assertEquals(true, errorMessage.getDetail().contains('Workbook for Site ' + testAccount3.Name + ' has been created'));


            // if the workbook to be cloned contains a SiteID-ProjectID pair that is already existing in the site, expect an error to get thrown
            controller.createWkbook();
            errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
            System.assertEquals(true, errorMessage.getDetail().contains('Workbook for Site ' + testAccount3.Name + ' already exists'));
        }
        
    }
    
    static testMethod void deleteSiteWorkbook_Test(){
        // -----------------------------------------------------------------------------
        // INITIALIZATION 
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        system.runAs(testUser){
            Account testAccount3 = IMP_TestFactory_Helper.buildAccount();
            testAccount3.Name = 'Test Account3';
            insert testAccount3;

            Project__c testProject = generate_Project();
            
            SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
            insert testSubProject;
            
            CMF_Info__c testCmfInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount3.Id);
          insert testCmfInfo;
            
            SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount3.Id, testSubProject.Id, testCmfInfo.Id);
          insert testSubProjectSite; 
            
            Question_Category__c testQuestionCat = createQuestionCategory();

            Question__c q;
            List<Question__c> questionsToInsertList = new List<Question__c>();

            for (Integer ctr = 0; ctr < 2; ctr++) {
                
                q = IMP_TestFactoryTemporary_Helper.buildQuestion(
                                                         IMP_TestFactoryTemporary_Helper.Enum_MarketList.DRIVE_BASELINE, 
                                                         IMP_TestFactoryTemporary_Helper.Enum_ProjectTypeList.UPGRADE);

                q.Active__c            = true;
                q.Question_Text__c     = 'This is a test question for item ' + String.valueOf(ctr);
                q.Cloneable__c    = true;
                
                /*if (math.mod(ctr, 3) == 0) {               
                    q.Cloneable__c    = false;
                } else {                
                    q.Cloneable__c    = true;
                    q.Market__c       = IMP_TestFactoryTemporary_Helper.LITERAL_DMS_AGNOSTIC_APP_SHARED;
                }*/
                
              /*  questionsToInsertList.add(q);
            }
            insert questionsToInsertList;
            
            Solution__c testSolution = IMP_TestFactoryTemporary_Helper.buildSolution(testQuestionCat.Id);
          insert testSolution;
          
           Product__c testProduct = IMP_TestFactoryTemporary_Helper.buildProduct(testSolution.Id);
          insert testProduct;
          
          Site_Product__c testSiteProduct = IMP_TestFactoryTemporary_Helper.buildSiteProduct(testSubProjectSite.Id, testProduct.Id, testSubProject.Id);
          insert testSiteProduct;
          
          Question__c qs =questionsToInsertList.size()>0 ? questionsToInsertList.get(0) : new Question__c();
          
          system.debug('---Question1----'+qs);
          
          Discovery_Question_Product__c dquestionProduct = IMP_TestFactoryTemporary_Helper.buildDiscoveryQuestionProduct(testProduct.Id, qs.Id);
          insert dquestionProduct;
          
          Question__c qs2 =questionsToInsertList.get(1)!=null ? questionsToInsertList.get(1) : new Question__c();
          
          system.debug('---Question12----'+qs2);
          
        Discovery_Question_Category__c dquestionCategory = IMP_TestFactoryTemporary_Helper.buildDiscoveryQuestionCategory(qs2.Id, testQuestionCat.Id);
        insert dquestionCategory;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(testSubProject);
            IMP_SiteWorkbook_Extension controller = new IMP_SiteWorkbook_Extension(sc);
            
            controller.tempsite.Site__c = null;
            

            Apexpages.Message errorMessage;

            // -----------------------------------------------------------------------------
            // TESTING PROPER
            

            // start the creation of the workbook
            controller.tempsite.Site__c = testAccount3.Id;
            controller.createWkbook();


            // expect that the workbook will get created successfully
            errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
            System.assertEquals(true, errorMessage.getDetail().contains('Workbook for Site ' + testAccount3.Name + ' has been created'));


            // double check if the workbook got created
            List<Site_Workbook__c> createdWorkbook = [SELECT Id FROM Site_Workbook__c];
            System.assertEquals(1, createdWorkbook.size());


            // delete the workbook and expect it to get erased from the Site_Workbook__c table
            controller.SelectedId = createdWorkbook.get(0).Id;
            controller.deleteSiteWorkbook();
            System.assertEquals(0, [SELECT COUNT() FROM Site_Workbook__c]);
        }
    }
    
    /*static testMethod void getSources_Test(){
        // -----------------------------------------------------------------------------
        // INITIALIZATION 
        User testUser = IMP_TestFactoryTemporary_Helper.buildUserAdmin();
        insert testUser;
        system.runAs(testUser){
            Account testAccount3 = IMP_TestFactoryTemporary_Helper.buildAccount();
            testAccount3.Name = 'Test Account3';
            insert testAccount3;

            Project__c testProject = generate_Project();
            
            SubProject__c testSubProject = IMP_TestFactoryTemporary_Helper.buildSubProject(testProject.Id);
            insert testSubProject;
            
            CMF_Info__c testCmfInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount3.Id);
          insert testCmfInfo;
            
            SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount3.Id, testSubProject.Id, testCmfInfo.Id);
          insert testSubProjectSite; 
            
            Question_Category__c testQuestionCat = createQuestionCategory();

            Question__c q;
            List<Question__c> questionsToInsertList = new List<Question__c>();
            for (Integer ctr = 0; ctr < 2; ctr++) {
                
                q = IMP_TestFactory_Helper.buildQuestion(testQuestionCat.Id, 
                                                         IMP_TestFactory_Helper.Enum_MarketList.DASH_SMALL_AUTO, 
                                                         IMP_TestFactory_Helper.Enum_ProjectTypeList.UPGRADE);

                q.Active__c            = true;
                q.Question_Text__c     = 'This is a test question for item ' + String.valueOf(ctr);
                
                if (math.mod(ctr, 3) == 0) {               
                    q.Cloneable__c    = false;
                } else {                
                    q.Cloneable__c    = true;
                    q.Market__c       = IMP_TestFactory_Helper.LITERAL_DMS_AGNOSTIC_APP_SHARED;
                }
                
                questionsToInsertList.add(q);
            }
            insert questionsToInsertList;
            
            ApexPages.StandardController sc = new ApexPages.StandardController(testSubProject);
            IMP_SiteWorkbook_Extension controller = new IMP_SiteWorkbook_Extension(sc);
            
            controller.tempsite.Site__c = null;
            

            Apexpages.Message errorMessage;

            // -----------------------------------------------------------------------------
            // TESTING PROPER
            

            // check if initial count of the sources list is 0
            List<SelectOption> sourceSiteList = controller.getSources();
            System.assertEquals(1, sourceSiteList.size()); // contains -> "--None--"


            // start the creation of the workbook
            controller.tempsite.Site__c = testAccount3.Id;
            controller.createWkbook();


            // expect that the workbook will get created successfully
            errorMessage = ApexPages.getMessages().get(ApexPages.getMessages().size() - 1);
            System.assertEquals(true, errorMessage.getDetail().contains('Workbook for Site ' + testAccount3.Name + ' has been created'));


            // double check if the workbook got created
            List<Site_Workbook__c> createdWorkbook = [SELECT Id FROM Site_Workbook__c];
            System.assertEquals(1, createdWorkbook.size());


            // source site list should now be 1 after the creation of the workbook
            sourceSiteList = controller.getSources();
            System.assertEquals(2, sourceSiteList.size()); // contains -> "--None--" and "Test Account3"
        }
    }
    */
    /*static testMethod void pagination_Test(){
        // -----------------------------------------------------------------------------
        // INITIALIZATION 
        User testUser = IMP_TestFactory_Helper.buildUserAdmin();
        insert testUser;
        system.runAs(testUser) {
          
          
            
            Project__c testProject = generate_Project();
            
            SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
            insert testSubProject;
            
            
            
            Question_Category__c testQuestionCat = createQuestionCategory();

            Question__c q;
            List<Question__c> questionsToInsertList = new List<Question__c>();
            for (Integer ctr = 0; ctr < 2; ctr++) {
                
                q = IMP_TestFactoryTemporary_Helper.buildQuestion( 
                                                         IMP_TestFactoryTemporary_Helper.Enum_MarketList.DASH_SMALL_AUTO, 
                                                         IMP_TestFactoryTemporary_Helper.Enum_ProjectTypeList.UPGRADE);

                q.Active__c            = true;
                q.Question_Text__c     = 'This is a test question for item ' + String.valueOf(ctr);
                
                if (math.mod(ctr, 3) == 0) {               
                    q.Cloneable__c    = false;
                } else {                
                    q.Cloneable__c    = true;
                    q.Market__c       = IMP_TestFactoryTemporary_Helper.LITERAL_DMS_AGNOSTIC_APP_SHARED;
                }
                
                questionsToInsertList.add(q);
            }
            insert questionsToInsertList;
            


            // Create 16 accounts for pagination testing
            List<Account> accountsToInsertList = new List<Account>();
            for (Integer ctr = 1; ctr < 17; ctr++) {
                Account acc = IMP_TestFactory_Helper.buildAccount();
                acc.Name = 'Test Account ' + ctr;
                accountsToInsertList.add(acc);
            }
            insert accountsToInsertList;

            // Create 16 bare site Workbooks for pagination testing
            List<Site_Workbook__c> siteWorkbooksToInsertList = new List<Site_Workbook__c>();
            for (Account a : accountsToInsertList) {
                
                Site_Workbook__c swkbk = IMP_TestFactoryTemporary_Helper.buildSiteWorkbook(testProject.Id, testSubProject.Id);
                swkbk.Site__c = a.Id;
                //swkbk.SubProject__c = testSubProject.Id;
                siteWorkbooksToInsertList.add(swkbk);
            }
            insert siteWorkbooksToInsertList;



            ApexPages.StandardController sc = new ApexPages.StandardController(testSubProject);
            IMP_SiteWorkbook_Extension controller = new IMP_SiteWorkbook_Extension(sc);
            
            controller.tempsite.Site__c = null;
            

            Apexpages.Message errorMessage;


            List<Site_Workbook__c> siteworkbooklist;

            // -----------------------------------------------------------------------------
            // TESTING PROPER
            

            // Now get all the IDs that the standard set controller would return for page 1
            siteworkbooklist = (List<Site_Workbook__c>)controller.setCon.getRecords();
            
            // Assert that there are 5 records, representing the first 5 of 16 records.
            System.assertEquals(5, siteworkbooklist.size());

            // Store all page 1 IDs for further testing
            Set<Id> siteworkbookset1 = new Set<Id>();
            for(Site_Workbook__c sw : (List<Site_Workbook__c>)controller.setCon.getRecords()){
                siteworkbookset1.add(sw.Id);
            }

            // Go to page 2
            controller.next();
            
            // Now get all the IDs that the standard set controller would return for page 2
            siteworkbooklist = (List<Site_Workbook__c>)controller.setCon.getRecords();

            // Assert that there are 5 records, representing the second 5 of 16 records.
            System.assertEquals(5, siteworkbooklist.size());

            // Store all page 2 IDs for further testing
            Set<Id> siteworkbookset2 = new Set<Id>();
            for(Site_Workbook__c sw : (List<Site_Workbook__c>)controller.setCon.getRecords()){
                siteworkbookset2.add(sw.Id);
            }

            // Go to page 3
            controller.next();

            // Now get all the IDs that the standard set controller would return for page 3
            siteworkbooklist = (List<Site_Workbook__c>)controller.setCon.getRecords();

            // Assert that there are 5 records, representing the third 5 of 16 records.
            System.assertEquals(5, siteworkbooklist.size());

            // Store all page 3 IDs for further testing
            Set<Id> siteworkbookset3 = new Set<Id>();
            for(Site_Workbook__c sw : (List<Site_Workbook__c>)controller.setCon.getRecords()){
                siteworkbookset3.add(sw.Id);
            }

            // Go to page 4
            controller.next();

            // Now get all the IDs that the standard set controller would return for page 4
            siteworkbooklist = (List<Site_Workbook__c>)controller.setCon.getRecords();

            // Assert that there is 1 record, representing the last of 16 records.
            System.assertEquals(1, siteworkbooklist.size());

            // Store all page 4 IDs for further testing
            Set<Id> siteworkbookset4 = new Set<Id>();
            for(Site_Workbook__c sw : (List<Site_Workbook__c>)controller.setCon.getRecords()){
                siteworkbookset4.add(sw.Id);
            }

            // Go back to the first page and check if the current IDs are equal to those contained in siteworkbookset1 
            controller.first();
            for(Site_Workbook__c sw : (List<Site_Workbook__c>)controller.setCon.getRecords()){
                System.assertEquals(true, siteworkbookset1.contains(sw.Id));
            }

            // Go to the last page and check if the current ID is equal to that contained in siteworkbookset4
            controller.last();
            for(Site_Workbook__c sw : (List<Site_Workbook__c>)controller.setCon.getRecords()){
                System.assertEquals(true, siteworkbookset4.contains(sw.Id));
            }

            // Go to the previous page (third page) and check if the current IDs are equal to those contained in siteworkbookset3
            controller.previous();
            for(Site_Workbook__c sw : (List<Site_Workbook__c>)controller.setCon.getRecords()){
                System.assertEquals(true, siteworkbookset3.contains(sw.Id));
            }

            // Go to the previous page (second page) and check if the current IDs are equal to those contained in siteworkbookset2
            controller.previous();
            for(Site_Workbook__c sw : (List<Site_Workbook__c>)controller.setCon.getRecords()){
                System.assertEquals(true, siteworkbookset2.contains(sw.Id));
            }

        }

    }
    
    private static Project__c generate_Project()
    {
        Project__c proj = IMP_TestFactory_Helper.buildProject(0);
        Insert proj;
        
        return proj;
    }
    
    /*private static Site_Workbook__c generate_SiteWorkbook(Id projectId, Id AccountId)
    {
        Site_Workbook__c siteWorkbook = IMP_TestFactory_Helper.buildSiteWorkbook(projectId);
        siteWorkbook.Site__c = AccountId;
        Insert siteWorkbook;  
        
        return siteWorkbook;
    }*/
    
   /* private static Question_Category__c createQuestionCategory() 
    {
        Question_Category__c qCategory = IMP_TestFactoryTemporary_Helper.buildDealershipNeed();
        insert qCategory;
        
        return qCategory;
    }
    
    private static List<Question__c> createQuestion(Id wCategoryId, Id qCategoryId)
    {
        List<Question__c> insertQuestion = new List<Question__c>();
        for (Integer ctr = 0; ctr < 2; ctr++) {
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
        insertAnswer.remove(1);
        Insert insertAnswer;
        
        return insertQuestion;
    }*/
}