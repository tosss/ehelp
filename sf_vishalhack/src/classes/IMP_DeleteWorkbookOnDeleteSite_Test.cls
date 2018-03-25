/*-----------------------------------------
 07/14/15   -Venkata Shrivol	-Created
 Description : Test Class for IMP_DeleteWorkbookOnDeleteSite_Handler
 -----HISTORY-------------
12/05/16  - Venkata Shrivol -commented this code as it no longer required
------------------------------------------- */
@isTest
private class IMP_DeleteWorkbookOnDeleteSite_Test {

   /* @testSetup static void prepareTestData()
    {
    	Account testAccount = IMP_TestFactory_Helper.buildAccount();
		insert testAccount;
		
		Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        
        CMF_Info__c testCmfInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
        insert testCmfInfo;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        list<sObject> testObjects = new list<sObject>();
        SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount.Id, testSubProject.Id, testCmfInfo.Id);
        testObjects.add(testSubProjectSite);
        //insert testSubProjectSite;
        
        Question_Category__c testDealershipNeed = IMP_TestFactoryTemporary_Helper.buildDealershipNeed();
        testObjects.add(testDealershipNeed);
        //insert testDealershipNeed;
        
        Question__c testQuestion = new Question__c();
        testQuestion.Active__c = true;
        testQuestion.Question_Text__c = 'This is a test question for item ' ;
        //testQuestion.Question_Category__c = qCategoryId;
        testQuestion.Project_Type__c = 'Upgrade';
        testQuestion.Market__c = 'Drive - Baseline';
        testQuestion.Answer_Type__c = 'Text';
        testQuestion.Cloneable__c = true;
        testObjects.add(testQuestion);
        
        Site_Workbook__c testSiteWorkbook = IMP_TestFactoryTemporary_Helper.buildSiteWorkbook(testProject.Id, testSubProject.Id);
        testSiteWorkbook.Site__c = testAccount.Id;
        testObjects.add(testSiteWorkbook);
        //insert testSiteWorkbook;
        
        insert testObjects;
        
        Discovery_Workbook_Category__c testSiteWorkbookCategory = IMP_TestFactoryTemporary_Helper.buildDiscoveryWorkbookCategory(testDealershipNeed.Id);
        testSiteWorkbookCategory.Site_Workbook__c = testSiteWorkbook.Id;
        insert testSiteWorkbookCategory;
        
        Answer__c testAnswer = new Answer__c();
        testAnswer.Question__c = testQuestion.Id;
        testAnswer.Discovery_Site_Workbook__c = testSiteWorkbook.Id;
        insert testAnswer;
        
        Discovery_Answer_Workbook_Category__c  testRec = new Discovery_Answer_Workbook_Category__c();
        testRec.Discovery_Workbook_Category__c = testSiteWorkbookCategory.Id;
        testRec.Answer__c = testAnswer.Id;
        insert testRec;
    }
    static testMethod void deleteSiteTest() 
    {
        SubProjectSite__c thisSite = [
        	select Id 
        	from SubProjectSite__c 
        	where SubProject__c IN 
        	(select Id from SubProject__c where SubProject_Name__c='Test SubProject Name') limit 1];
        Test.startTest();
        	delete thisSite;
        Test.stopTest();
        
        //below list size will be empty since the above trigger deleted the workbook
		list<Site_Workbook__c> emptySiteWkbkList = [
			select Id from Site_Workbook__c 
			where SubProject__c IN
			(select Id from SubProject__c where SubProject_Name__c='Test SubProject Name')];
		system.assertEquals(0, emptySiteWkbkList.size());
    }*/
}