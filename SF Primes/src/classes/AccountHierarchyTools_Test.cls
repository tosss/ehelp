@IsTest
public class AccountHierarchyTools_Test
{
	//2015-07-24 anirudh.singh@cdk.com- Added this method.
	//Earlier the data was created in the method named Test.
    @TestSetup static void setupTestData()
    {
        //2015-07-24 anirudh.singh@cdk.com- Added the Active__c field value for the record, as the class was failing.
        Site_Type__c siteType=new Site_Type__c(Name='Test Site Type', Corporation_Flag__c=true, Active__c=true);
        insert sitetype;
        
        Account topmostParent=DS_TestObjects.newAccount(); 
        topmostParent.Site_Type__c=siteType.Id;
        insert topmostParent;
        
        Account level1Child=DS_TestObjects.newAccount(); 
        level1Child.ParentId=topmostParent.Id;
        level1Child.Site_Type__c=siteType.Id;
        insert level1Child;
        
        Account level2Child=DS_TestObjects.newAccount(); 
        level2Child.ParentId=level1Child.Id;
        level2Child.Site_Type__c=siteType.Id;
        insert level2Child;
        
        Account level3Child=DS_TestObjects.newAccount(); 
        level3Child.ParentId=level2Child.Id;
        level3Child.Site_Type__c=siteType.Id;
        insert level3Child;
        
        Account level4Child=DS_TestObjects.newAccount(); 
        level4Child.ParentId=level3Child.Id;
        level4Child.Site_Type__c=siteType.Id;
        insert level4Child;
        
        Account level5Child=DS_TestObjects.newAccount(); 
        level5Child.ParentId=level4Child.Id;
        level5Child.Site_Type__c=siteType.Id;
        insert level5Child;
        
        Account level6Child=DS_TestObjects.newAccount(); 
        level6Child.ParentId=level5Child.Id;
        level6Child.Site_Type__c=siteType.Id;
        insert level6Child;
        
        Account level7Child=DS_TestObjects.newAccount(); 
        level7Child.ParentId=level6Child.Id;
        insert level7Child;
    }
    
    // test 1
    public static testmethod void Test()
    {
        List<Account> accList=[SELECT Name FROM Account];
        
        Test.startTest();
        AccountHierarchyTools.TopParentAccountId(accList[7].Id);
        
        //2015-07-24 anirudh.singh@cdk.com - Commented the below line, RecursiveTopParentAccountId method was removed as it was not working.
        //AccountHierarchyTools.RecursiveTopParentAccountId(childaccount.Id);
        
        //2015-07-24 anirudh.singh@cdk.com - Added the below line in place of RecursiveTopParentAccountId now the new method is invoked.
        AccountHierarchyTools.recursivelyFetchTopParentAccountId(accList[7].Id);
        
        AccountHierarchyTools.ChildrenAccountIds(new Set<Id>{accList[4].Id});
        AccountHierarchyTools.TopParentAccountIdsByAccountId(new List<Id>{accList[7].Id});
        AccountHierarchyTools.HierarchySiteTypesForFiveLevels(new List<Id>{accList[7].Id});
        Test.stopTest();
    }
}