/*--------------------
06/23/2015    Venkata Shrivol - Created
Description - Test Class for IMP_AddAnsOnSiteProdsInsert_Handler
-----HISTORY--------
2016-12-05  -venkata.shrivol@cdk.com -commented the code as it is no longer required  
----------------------------------*/
@isTest
public class IMP_AddAnsOnSiteProdsInsert_Test {

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
        
        list<Question_Category__c> testDNeedList = createQCList();
        //IMP_TestFactory_Helper.buildDealershipNeed();
        //insert testDNeed;
        
        list<Solution__c> testSolutionList  = createSolutionList(testDNeedList);
        //IMP_TestFactory_Helper.buildSolution(testDNeed.Id);
        //insert testSolution;
        
       	list<Product__c> testProductList = createProductList(testSolutionList);
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
        
        list<Question__c> testQuestionsList = createQuestionList();
        
        generateQuestionProducts(testProductList, testQuestionsList);
			
	}
	
	static testMethod void addSiteProductFromExistingCategory() 
	{
		SubProject__c thisSubProject = [
    		select Id,Name, 
    			(Select Id
             	from SubProjectSites__r) 
            from SubProject__c 
            where SubProject_Name__c='Test SubProject Name' limit 1];
        
        SubProjectSite__c thisSite = thisSubProject.SubProjectSites__r.size()>0 ? thisSubProject.SubProjectSites__r.get(0) : new SubProjectSite__c();
            
        list<Product__c> thisProductList = [select Id from Product__c where Name='Test Product 1' or Name ='Test Product 3' or Name='Test Product 2'];
        
        Site_Workbook__c thisSiteWorkbook = [select Id from Site_Workbook__c where SubProject__c =:thisSubProject.Id limit 1];
        
        //Discovery_Workbook_Category__c thisSWkbkCategory = [select Id from Discovery_Workbook_Category__c where Site_Workbook__c =:thisSiteWorkbook.Id];
		
        //Site_Product__c siteProdsToInsert = IMP_TestFactoryTemporary_Helper.buildSiteProduct(thisSite.Id, thisProduct.Id, thisSubProject.Id);
        
        list<Site_Product__c> siteProdsToInsert = new list<Site_Product__c>();
		for(Product__c prd:thisProductList)
		{
			Site_Product__c testSiteProd = IMP_TestFactoryTemporary_Helper.buildSiteProduct(thisSite.Id, prd.Id, thisSubProject.Id);
			siteProdsToInsert.add(testSiteProd);
		}
        insert siteProdsToInsert.get(0);
        
        siteProdsToInsert.remove(0);
        
        Test.startTest();
        	insert siteProdsToInsert;
        Test.stopTest();
    }
    
    /*static testMethod void addSProductToCreateNewSWCategory() 
	{
		SubProject__c thisSubProject = [
    		select Id,Name, 
    			(Select Id
             	from SubProjectSites__r) 
            from SubProject__c 
            where SubProject_Name__c='Test SubProject Name' limit 1];
        
        SubProjectSite__c thisSite = thisSubProject.SubProjectSites__r.size()>0 ? thisSubProject.SubProjectSites__r.get(0) : new SubProjectSite__c();
            
        list<Product__c> thisProductList = [select Id, Solution__r.Question_Category__c from Product__c where Name='Test Product 2' or Name = 'Test Product 3'];
        
        Site_Workbook__c thisSiteWorkbook = [select Id from Site_Workbook__c where SubProject__c =:thisSubProject.Id limit 1];
        
        system.debug('RAM'+thisProductList);
        
        //Discovery_Workbook_Category__c thisSWkbkCategory = [select Id from Discovery_Workbook_Category__c where Site_Workbook__c =:thisSiteWorkbook.Id];
		
		list<Site_Product__c> siteProdsToInsert = new list<Site_Product__c>();
		for(Product__c prd:thisProductList)
		{
			Site_Product__c testSiteProd = IMP_TestFactoryTemporary_Helper.buildSiteProduct(thisSite.Id, prd.Id, thisSubProject.Id);
			siteProdsToInsert.add(testSiteProd);
		}
        
        Test.startTest();
        	insert siteProdsToInsert;
        Test.stopTest();
        
        list<Answer__c> ansList = [select Id from Answer__c where Discovery_Site_Workbook__c =:thisSiteWorkbook.Id];
		
		//Inserted 2 Products -> 1 Question -> 1 Answer -> 2 Answkbk Categories
		system.assertEquals(1,ansList.size());
    }
    
    
    
	public static list<Question_Category__c> createQCList()
	{
		list<Question_Category__c> listToInsert = new list<Question_Category__c>();
		
		for(Integer i=1;i<4;i++)
		{
			Question_Category__c qcat = new Question_Category__c();
			qcat.Name = 'Test Dealership Need '+i;
			qcat.Active__c = true;
			listToInsert.add(qcat);
		}
		insert listToInsert;
		return listToInsert;
	}
	public static list<Solution__c> createSolutionList(list<Question_Category__c> qcList)
	{
		list<Solution__c> listToInsert = new list<Solution__c>();
		Integer i=1;
		for(Question_Category__c qc:qcList)
		{
			Solution__c sol = new Solution__c();
			sol.Name = 'Test Solution '+i;
			sol.Question_Category__c = qc.Id;
			sol.Active__c = true;
			listToInsert.add(sol);
			i++;
		}
		insert listToInsert;
		
		return listToInsert;
	}
	public static list<Product__c> createProductList(list<Solution__c> solList)
	{
		integer i=1;
		list<Product__c> listToInsert = new list<Product__c>();
		for(Solution__c sol:solList)
		{
			
			Product__c prd = new Product__c();
			prd.Name = 'Test Product '+i;
			prd.Active__c = true;
			prd.Solution__c = sol.Id;
			listToInsert.add(prd);
			i++;
		}
		insert listToInsert;
		
		return listToInsert;
	}
	public static list<Discovery_Workbook_Category__c> createWkbkCategoryList(list<Question_Category__c> qcList, Id testSiteWorkbookId)
	{
		list<Discovery_Workbook_Category__c> listToInsert = new list<Discovery_Workbook_Category__c>();
		for(Question_Category__c qc:qcList)
		{
			Discovery_Workbook_Category__c dwc = new Discovery_Workbook_Category__c();
			dwc.Question_Category__c = qc.Id;
			dwc.Site_Workbook__c = testSiteWorkbookId;
			listToInsert.add(dwc);
		}
		insert listToInsert;
		
		return listToInsert;
		
	} 
	public static list<Question__c> createQuestionList()
	{
		list<Question__c> questionListToInsert = new list<Question__c>();
		
		for(Integer i=1; i<3; i++)
		{
			Question__c quest = new Question__c();
            quest.Active__c = true;
            quest.Question_Text__c = 'This is a test question for item ' + i;
            //quest.Question_Category__c = qCategoryId;
            quest.Project_Type__c = 'Upgrade';
            quest.Market__c = 'Drive - Baseline';
            quest.Answer_Type__c = 'Text';
            quest.Cloneable__c = true;
            questionListToInsert.add(quest);
		}
		insert questionListToInsert;
		
		/*list<Answer__c> insertAnswerList = new list<Answer__c>();
		for(Question__c qs:questionListToInsert)
		{
			Answer__c ans = new Answer__c();
			ans.Discovery_Workbook_Category__c = wkbkCatId;
			ans.Question__c = qs.Id;
			ans.Discovery_Site_Workbook__c = siteWkbkId;
			insertAnswerList.add();
		}
		insert insertAnswerList;
		
		list<Discovery_Answer_Workbook_Category__c> insertList = new list<Discovery_Answer_Workbook_Category__c>();
		for(Answer__c ans:insertAnswerList)
		{
			Discovery_Answer_Workbook_Category__c dawc = new Discovery_Answer_Workbook_Category__c();
        	dawc.Answer__c = ans.Id;
        	dawc.Discovery_Workbook_Category__c = wkbkCatId;
        	insertAnswerWkbkCategoriesList.add(dawc);
		}
		insert insertAnswerWkbkCategoriesList;
		
		return questionListToInsert;
	}
	
	public static void generateQuestionProducts(list<Product__c> testProductList, list<Question__c> testQuestionsList)
	{
		list<Discovery_Question_Product__c> dqpToInsert = new list<Discovery_Question_Product__c>();
		integer i=0;
		for(Product__c prd:testProductList)
		{
			integer j=0;
			for(Question__c qs:testQuestionsList)
			{
				if(math.mod(j,2)==i)
				{
					Discovery_Question_Product__c dqp = new Discovery_Question_Product__c();
					dqp.Question__c=qs.Id;
					dqp.Product__c = prd.Id;
					dqpToInsert.add(dqp);
				}
				else if(i==2)
				{
					Discovery_Question_Product__c dqp = new Discovery_Question_Product__c();
					dqp.Question__c=qs.Id;
					dqp.Product__c = prd.Id;
					dqpToInsert.add(dqp);
					break;
				}
				j++;
			}
			i++;
		}
		insert dqpToInsert;
	}
	
    */
}