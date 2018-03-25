/*--------------------
06/26/2015    Venkata Shrivol - Created
Description - Test Class for IMP_DeleteAnsOnSiteProdsDelete_Handler
-----HISTORY--------
 2016-12-05 -venkata.shrivol@cdk.com -commented the project object reference RQ-08305
----------------------------------*/

@isTest
public class IMP_DeleteAnsOnSiteProdsDelete_Test 
{
	/*@testSetup static void prepareTestData()
	{
		Account testAccount = IMP_TestFactory_Helper.buildAccount();
		insert testAccount;
		
		Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        
        CMF_Info__c testCmfInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
        insert testCmfInfo;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount.Id, testSubProject.Id, testCmfInfo.Id);
        insert testSubProjectSite;
        
        list<Question_Category__c> testDNeedList = IMP_AddAnsOnSiteProdsInsert_Test.createQCList();
        //IMP_TestFactory_Helper.buildDealershipNeed();
        //insert testDNeed;
        
        list<Solution__c> testSolutionList  = IMP_AddAnsOnSiteProdsInsert_Test.createSolutionList(testDNeedList);
        //IMP_TestFactory_Helper.buildSolution(testDNeed.Id);
        //insert testSolution;
        
       	list<Product__c> testProductList = IMP_AddAnsOnSiteProdsInsert_Test.createProductList(testSolutionList);
       	//IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        //insert testProduct;
        
        Site_Workbook__c testSiteWorkbook = IMP_TestFactoryTemporary_Helper.buildSiteWorkbook(testProject.Id, testSubProject.Id);
        testSiteWorkbook.Site__c = testAccount.Id;
        insert testSiteWorkbook;
        
        Discovery_Workbook_Category__c testSiteWorkbookCategory = IMP_TestFactoryTemporary_Helper.buildDiscoveryWorkbookCategory(testDNeedList.get(0).Id);
        testSiteWorkbookCategory.Site_Workbook__c = testSiteWorkbook.Id;
        testSiteWorkbookCategory.Count_of_Questions__c = 0;
        insert testSiteWorkbookCategory;
        //list<Discovery_Workbook_Category__c> testSiteWorkbookCatList = createWkbkCategoryList(testDNeedList, testSiteWorkbook.Id);
        
        list<Question__c> testQuestionsList = IMP_AddAnsOnSiteProdsInsert_Test.createQuestionList();
        
        IMP_AddAnsOnSiteProdsInsert_Test.generateQuestionProducts(testProductList, testQuestionsList);
        
        Site_Product__c testSiteProd = IMP_TestFactoryTemporary_Helper.buildSiteProduct(testSubProjectSite.Id, testProductList.get(0).Id, testSubProject.Id);
        insert testSiteProd;
	}
	
	static testMethod void deleteSiteProdsTest()
	{
		Site_Product__c thisSiteProduct = [
			select Id from Site_Product__c 
			where SubProject__c IN 
			(select Id from SubProject__c where SubProject_Name__c='Test SubProject Name') limit 1];
		
		Test.startTest();
			delete thisSiteProduct;
		Test.stopTest();
		
	} */
}