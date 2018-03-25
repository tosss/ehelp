/*-------------------------------------
05/12/2015 - Venkata Shrivol - Created
Description - Test-Class for IMP_AddProductsToSite_Extension

---History----

--------------------------------------*/

@isTest
private class IMP_AddProductsToSite_Test 
{
	
	//public static SubProject__c testSubProject;
	//public static SubProjectSite__c testSubProjectSite;
	//public static Product__c testProduct;
	
	@testSetup static void prepareTestData()
	{
		list<sObject> testObjectRecs;
		
		Account testAccount = IMP_TestFactory_Helper.buildAccount();
		insert testAccount;
		
		Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        
        CMF_Info__c testCmfInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
        insert testCmfInfo;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        system.debug('---testSubProject-----'+testSubProject.Id);
        
        SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount.Id, testSubProject.Id, testCmfInfo.Id);
        insert testSubProjectSite;
        
        Question_Category__c testDNeed = IMP_TestFactory_Helper.buildDealershipNeed();
        insert testDNeed;
        
        Solution__c testSolution = IMP_TestFactory_Helper.buildSolution(testDNeed.Id);
        insert testSolution;
        
       	Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        insert testProduct;
        
	}

    static testMethod void testMethodForEmptySiteRecs() 
    {
    	SubProject__c thisSubProject = [
    		select Id,Name, 
    			(Select Id, Account__r.Name 
             	from SubProjectSites__r) 
            from SubProject__c 
            where SubProject_Name__c='Test SubProject Name' limit 1];
        
        SubProjectSite__c thisSite = thisSubProject.SubProjectSites__r.size()>0 ? thisSubProject.SubProjectSites__r.get(0) : new SubProjectSite__c();
            
        Product__c thisProduct = [select Id from Product__c where Name='Test Product' limit 1];
    	//prepareTestData();
    	
        Test.StartTest();
            ApexPages.CurrentPage().getParameters().put('Id', thisSubProject.Id);
            ApexPages.CurrentPage().getParameters().put('prodId', thisProduct.Id);
            IMP_AddProductsToSite_Extension testObj = new IMP_AddProductsToSite_Extension();
            IMP_AddProductsToSite_Extension.ProductDetail pd = new IMP_AddProductsToSite_Extension.ProductDetail();
            IMP_AddProductsToSite_Extension.SiteProductDetail spd = new IMP_AddProductsToSite_Extension.SiteProductDetail();
            testObj.getSites();
            testObj.siteRecIds = new list<String>{thisSite.Id};
            
            IMP_AddProductsToSite_Extension.findProduct('Test');
            testObj.updateProductList();
            testObj.removeProduct();
            testObj.siteRecIds.clear();
            testObj.addSiteProducts();
            //system.assertEquals(1, testSubProject.SubProjectSites__r.size());
        Test.StopTest();   
    }
    static testMethod void testMethodForNewSiteRecs()
    {
    	SubProject__c thisSubProject = [
    		select Id,Name, 
    			(Select Id, Account__r.Name 
             	from SubProjectSites__r) 
            from SubProject__c 
            where SubProject_Name__c='Test SubProject Name' limit 1];
        
        SubProjectSite__c thisSite = thisSubProject.SubProjectSites__r.size()>0 ? thisSubProject.SubProjectSites__r.get(0) : new SubProjectSite__c();
            
        Product__c thisProduct = [select Id from Product__c where Name='Test Product' limit 1];
    	//prepareTestData();
    	
        Test.StartTest();
            ApexPages.CurrentPage().getParameters().put('Id', thisSubProject.Id);
            ApexPages.CurrentPage().getParameters().put('prodId', thisProduct.Id);
            IMP_AddProductsToSite_Extension testObj = new IMP_AddProductsToSite_Extension();
            IMP_AddProductsToSite_Extension.ProductDetail pd = new IMP_AddProductsToSite_Extension.ProductDetail();
            IMP_AddProductsToSite_Extension.SiteProductDetail spd = new IMP_AddProductsToSite_Extension.SiteProductDetail();
            testObj.getSites();
            testObj.siteRecIds = new list<String>{thisSite.Id};
            testObj.updateProductList();
        	testObj.addSiteProducts();
            testObj.deleteSiteProducts();
        Test.StopTest();
        
        list<Site_Product__c> siteProdList = [select Id from Site_Product__c where SubProjectSite__c =:thisSite.Id];
        
        system.assertEquals(1, siteProdList.size());  
    }
    
    static testMethod void testMethodForExisitingSiteRecs()
    {
    	SubProject__c thisSubProject = [
    		select Id,Name, 
    			(Select Id, Account__r.Name 
             	from SubProjectSites__r) 
            from SubProject__c 
            where SubProject_Name__c='Test SubProject Name' limit 1];
        
        SubProjectSite__c thisSite = thisSubProject.SubProjectSites__r.size()>0 ? thisSubProject.SubProjectSites__r.get(0) : new SubProjectSite__c();
            
        Product__c thisProduct = [select Id from Product__c where Name='Test Product'];
    	
    	Site_Product__c thisSiteProd = new Site_Product__c();
    	thisSiteProd.Product__c = thisProduct.Id;
    	thisSiteProd.SubProjectSite__c= thisSite.Id;
    	thisSiteProd.SubProject__c = thisSubProject.Id;
    	insert thisSiteProd;
    	
        Test.StartTest();
            ApexPages.CurrentPage().getParameters().put('Id', thisSubProject.Id);
            ApexPages.CurrentPage().getParameters().put('prodId', thisProduct.Id);
            IMP_AddProductsToSite_Extension testObj = new IMP_AddProductsToSite_Extension();
            IMP_AddProductsToSite_Extension.ProductDetail pd = new IMP_AddProductsToSite_Extension.ProductDetail();
            IMP_AddProductsToSite_Extension.SiteProductDetail spdObject = new IMP_AddProductsToSite_Extension.SiteProductDetail();
            spdObject.toDelete=true;
            spdObject.sprodId = thisSiteProd.Id;
            
            testObj.getSites();
            testObj.siteRecIds = new list<String>{thisSite.Id};
            testObj.updateProductList();
        	testObj.addSiteProducts();
            testObj.siteProductList.add(spdObject);
            testObj.deleteSiteProducts();
        Test.StopTest();   
        
    }
    
}