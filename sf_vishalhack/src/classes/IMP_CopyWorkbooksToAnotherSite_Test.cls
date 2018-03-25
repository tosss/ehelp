/*-----------------------------------------
7/1/15    Venkata Shrivol     -Created
Description - Test class for IMP_CopyWorkbooksToAnotherSite_Extension
-----History------------
2016-12-06 -venkata.shrivol@cdk.com -commented the code as this class is no longer required.
----------------------------------------- */
@isTest
private class IMP_CopyWorkbooksToAnotherSite_Test {

    /*@testSetup static void prepareTestData()
    {
        
        list<Account> accList = new list<Account>();
        for(Integer i=0;i<2;i++)
        {
            Account ac = new Account();
            ac.Name='Test Account'+i;
            accList.add(ac);
        } 
        insert accList;
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
       
        list<CMF_Info__c> cmfList = new list<CMF_Info__c>();
        for(Integer i=0;i<2;i++)
        {
            CMF_Info__c cmf = new CMf_Info__c();
            cmf.Account__c = accList.get(i).Id;
            cmf.Name = 'Test CMF'+i;
            cmf.Main_CMF__c = '321'+i;
            cmf.Ship_CMF__c = '321'+i;
            cmf.Status__c = 'A';
            cmfList.add(cmf);
        }           
        insert cmfList;

        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        list<SubProjectSite__c> subProjectSiteList = new list<SubProjectSite__c>();
        SubProjectSite__c sourceSite = IMP_TestFactory_Helper.buildSubProjectSite(accList.get(0).Id, testSubProject.Id, cmfList.get(0).Id);
        subProjectSiteList.add(sourceSite);
        SubProjectSite__c targetSite = IMP_TestFactory_Helper.buildSubProjectSite(accList.get(1).Id, testSubProject.Id, cmfList.get(1).Id);
        subProjectSiteList.add(targetSite);
        insert subProjectSiteList;
        
        list<Question_Category__c> testDNeedList = IMP_AddAnsOnSiteProdsInsert_Test.createQCList();
        //IMP_TestFactory_Helper.buildDealershipNeed();
        //insert testDNeed;
        
        list<Solution__c> testSolutionList  = IMP_AddAnsOnSiteProdsInsert_Test.createSolutionList(testDNeedList);
        //IMP_TestFactory_Helper.buildSolution(testDNeed.Id);
        //insert testSolution;
        
        list<Product__c> testProductList = IMP_AddAnsOnSiteProdsInsert_Test.createProductList(testSolutionList);
        //IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        //insert testProduct;

        list<Site_Product__c> siteProdList = new list<Site_Product__c>();
        for(Product__c prd:testProductList)
        {
            Site_Product__c sp = IMP_TestFactoryTemporary_Helper.buildSiteProduct(sourceSite.Id, prd.Id, testSubProject.Id);
            siteProdList.add(sp);
        }
        Site_Product__c targetSP = IMP_TestFactoryTemporary_Helper.buildSiteProduct(targetSite.Id, testProductList.get(0).Id, testSubProject.Id);
        siteProdList.add(targetSP);
        insert siteProdList;
        
        Site_Workbook__c testSiteWorkbook = IMP_TestFactoryTemporary_Helper.buildSiteWorkbook(testProject.Id, testSubProject.Id);
        testSiteWorkbook.Site__c = accList.get(0).Id;
        insert testSiteWorkbook;
        
        Discovery_Workbook_Category__c testSiteWorkbookCategory = IMP_TestFactoryTemporary_Helper.buildDiscoveryWorkbookCategory(testDNeedList.get(0).Id);
        testSiteWorkbookCategory.Site_Workbook__c = testSiteWorkbook.Id;
        testSiteWorkbookCategory.Count_of_Questions__c = 0;
        insert testSiteWorkbookCategory;
        //list<Discovery_Workbook_Category__c> testSiteWorkbookCatList = createWkbkCategoryList(testDNeedList, testSiteWorkbook.Id);
        
        list<Question__c> testQuestionsList = createQuestionList();
        
        generateQuestionProducts(testProductList, testQuestionsList);
        
        Discovery_Question_Category__c dqc = new Discovery_Question_Category__c();
        dqc.Question_Category__c = testDNeedList.get(2).Id;
        dqc.Discovery_Question__c = testQuestionsList.get(2).Id;
        insert dqc;
        
        createAnswersAndAnsWkbkCategories(testQuestionsList, testSiteWorkbook.Id, testSiteWorkbookCategory.Id);
        
        
    }
    static testMethod void getSiteProductsTest() 
    {
        Id sourceSiteId=null;
        Id targetSiteId=null;
        SubProject__c thisSubProj = [
            select Id, Market__c, Project_Type__c, Project__c, 
                (select Id, Account__r.Name,Account__c from SubProjectSites__r)
            from SubProject__c where SubProject_Name__c='Test SubProject Name' limit 1];
            
       Site_Workbook__c sourceSiteWkbk = [select Id, Site__c from Site_Workbook__c where SubProject__c=:thisSubProj.Id limit 1];
       for(SubProjectSite__c sps:thisSubProj.SubProjectSites__r)
       {
            if(sps.Account__c == sourceSiteWkbk.Site__c)
            {
                sourceSiteId = sps.Id;
            }
            else
            {
                targetSiteId = sps.Id;
            }
       }
       Site_Product__c thisSiteProd = [select Product__c, Product__r.Name, Id from Site_Product__c where SubProjectSite__c =:sourceSiteId limit 1];
       Test.startTest();
        ApexPages.CurrentPage().getParameters().put('Id', thisSubProj.Id);
        IMP_CopyWorkbooksToAnotherSite_Extension testObj = new IMP_CopyWorkbooksToAnotherSite_Extension();
        IMP_CopyWorkbooksToAnotherSite_Extension.sourceSiteProductWrapper sspw = new IMP_CopyWorkbooksToAnotherSite_Extension.sourceSiteProductWrapper();
        testObj.getSourceSites();
        testObj.getTargetSites();
        ApexPages.CurrentPage().getParameters().put('sourceSiteId', sourceSiteId);
        ApexPages.CurrentPage().getParameters().put('targetSiteId', targetSiteId);
        testObj.getSiteProducts();
        testObj.srcSiteProducts.clear();
        testObj.targetSiteId = targetSiteId;
        testObj.sourceSiteId=sourceSiteId;
        sspw.sourceProductName= thisSiteProd.Product__r.Name;
        sspw.sourceProdId= thisSiteProd.Product__c;
        sspw.toCopyThisProduct=true;
        testObj.srcSiteProducts.add(sspw);
        testObj.copyWorkbook();
       Test.stopTest();
       
       //Since we created a TargetWkbk, the total number of workbooks will be two
       list<Site_Workbook__c> totalSiteWorkbooks = [select Id from Site_Workbook__c where SubProject__c =:thisSubProj.Id];
       System.assertEquals(2, totalSiteWorkbooks.size());
       
    }
    
    public static void createAnswersAndAnsWkbkCategories(list<Question__c> questionList, Id SiteWkbkId, Id siteWkbkCatId)
    {
        Integer i=0;
        list<Answer__c> ansList = new list<Answer__c>();
        for(Question__c qs:questionList)
        {
            Answer__c ans = new Answer__c();
            ans.Discovery_Site_Workbook__c = SiteWkbkId;
            //ans.Discovery_Workbook_Category__c = siteWkbkCatId;
            if(i==0){
                ans.Text_Answer__c = 'testAnswer'+i;
            }
            ans.Question__c=qs.Id;
            ansList.add(ans);
            i++;
        }
        insert ansList;
        list<Discovery_Answer_Workbook_Category__c> ansWkbkCatList = new list<Discovery_Answer_Workbook_Category__c>();
        for(Answer__c ans:ansList)
        {
            Discovery_Answer_Workbook_Category__c dawc = new Discovery_Answer_Workbook_Category__c();
            dawc.Answer__c = ans.Id;
            dawc.Discovery_Workbook_Category__c = siteWkbkCatId;
            ansWkbkCatList.add(dawc);
        }
        insert ansWkbkCatList;
    }
    
    public static list<Question__c> createQuestionList()
    {
        list<Question__c> questionListToInsert = new list<Question__c>();
        
        for(Integer i=1; i<4; i++)
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
                if(j==2)
                {
                    break;
                }
                if(math.mod(j,2)==i)
                {
                    Discovery_Question_Product__c dqp = new Discovery_Question_Product__c();
                    dqp.Question__c=qs.Id;
                    dqp.Product__c = prd.Id;
                    dqpToInsert.add(dqp);
                }
                j++;
            }
            i++;
        }
        insert dqpToInsert;
    }
    */
}