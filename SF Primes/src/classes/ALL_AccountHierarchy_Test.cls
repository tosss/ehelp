//Author: Anirudh Singh
//Created Date: 2015-07-24
//Description: This is the test class for ALL_AccountHierarchy_Controller.
@isTest
public class ALL_AccountHierarchy_Test
{
    @TestSetup 
    static void setupTestData()
    {
        Site_Type__c siteType=new Site_Type__c(Name='Test Site Type', Corporation_Flag__c=true, Active__c=true);
        insert sitetype;
        
        //Creating account records.
        Account topmostParent=DS_TestObjects.newAccount(); 
        topmostParent.Site_Type__c=siteType.Id;
        insert topmostParent;
        
        Account level1Child1=DS_TestObjects.newAccount(); 
        level1Child1.ParentId=topmostParent.Id;
        level1Child1.Site_Type__c=siteType.Id;
        insert level1Child1;
        
        Account level1Child2=DS_TestObjects.newAccount(); 
        level1Child2.ParentId=topmostParent.Id;
        level1Child2.Site_Type__c=siteType.Id;
        insert level1Child2;
        
        Account level2Child=DS_TestObjects.newAccount(); 
        level2Child.ParentId=level1Child1.Id;
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
        level7Child.Site_Type__c=siteType.Id;
        insert level7Child;
        
        Account child1Parent7=DS_TestObjects.newAccount(); 
        child1Parent7.ParentId=level7Child.Id;
        insert child1Parent7;
        
        Account child2Parent7=DS_TestObjects.newAccount(); 
        child2Parent7.ParentId=level7Child.Id;
        insert child2Parent7;
        
        Account child3Parent7=DS_TestObjects.newAccount(); 
        child3Parent7.ParentId=level7Child.Id;
        child3Parent7.Site_Type__c=siteType.Id;
        insert child3Parent7;
        
        Account level8Child=DS_TestObjects.newAccount(); 
        level8Child.ParentId=child3Parent7.Id;
        insert level8Child;
        
        //Creating ALL_AccountHierarchy__c records.
        List<ALL_AccountHierarchy__c> accHierarchyList=new List<ALL_AccountHierarchy__c>();
        ALL_AccountHierarchy__c ref1=new ALL_AccountHierarchy__c();
        ref1.Name='Record 1';
        ref1.Fields_To_Be_Displayed__c='Name';
        ref1.Position__c=1;
        accHierarchyList.add(ref1);
        
        ALL_AccountHierarchy__c ref2=new ALL_AccountHierarchy__c();
        ref2.Name='Record 2';
        ref2.Fields_To_Be_Displayed__c='Industry';
        ref2.Position__c=1;
        accHierarchyList.add(ref2);
        
        ALL_AccountHierarchy__c ref3=new ALL_AccountHierarchy__c();
        ref3.Name='Record 3';
        ref3.Fields_To_Be_Displayed__c='Site';
        ref3.Position__c=1;
        accHierarchyList.add(ref3);
        
        ALL_AccountHierarchy__c ref4=new ALL_AccountHierarchy__c();
        ref4.Name='Record 4';
        ref4.Fields_To_Be_Displayed__c='Parent.ParentId';
        ref4.Position__c=1;
        accHierarchyList.add(ref4);
        
        insert accHierarchyList;
    }
    
    //If Account Hierarchy Records are present.
    public static testmethod void testAccountHierarchy()
    {
        List<Account> accList=[SELECT Name FROM Account];
        
        Test.startTest();
        PageReference pRef=Page.ALL_AccountHierarchyView;
        pRef.getParameters().put('id', accList[11].Id);
        pRef.getParameters().put('name', accList[11].Name);
        Test.setCurrentPage(pRef);
        ALL_AccountHierarchy_Controller.processAccountHierarchy();
        
        ALL_AccountHierarchy_Controller controllerRef=new ALL_AccountHierarchy_Controller();
        List<ALL_AccountHierarchy_Controller.ColumnNameLabelWrapper> displayColNamesLabelList=controllerRef.displayColumnNamesLabelList;
        List<String> displayRemColumns=controllerRef.displayRemainingColumns;
        List<ALL_AccountHierarchy_Controller.HierarchyWrapper> displayAccsList=controllerRef.displayAccountsList;
        Test.stopTest();
    }
    
    //If Account Hierarchy Records are not present.
    static testmethod void testAccountHierarchy2()
    {
        List<Account> accList=[SELECT Name FROM Account];
        
        List<ALL_AccountHierarchy__c> accHierarchyList=[SELECT Id, Fields_To_Be_Displayed__c, Position__c FROM ALL_AccountHierarchy__c];
        delete accHierarchyList;
        
        Test.startTest();
        PageReference pRef=Page.ALL_AccountHierarchyView;
        pRef.getParameters().put('id', accList[11].Id);
        pRef.getParameters().put('name', accList[11].Name);
        Test.setCurrentPage(pRef);
        ALL_AccountHierarchy_Controller.processAccountHierarchy();
        Test.stopTest();
    }
    
    //If wrong field api name value is present in Account Hierarchy Records.
    static testmethod void testAccountHierarchy3()
    {
        List<Account> accList=[SELECT Name FROM Account];
        
        List<ALL_AccountHierarchy__c> accHierarchyList=[SELECT Id, Fields_To_Be_Displayed__c, Position__c FROM ALL_AccountHierarchy__c];
        delete accHierarchyList;
        
        ALL_AccountHierarchy__c ref=new ALL_AccountHierarchy__c();
        ref.Name='Record 1';
        ref.Fields_To_Be_Displayed__c='abc';
        ref.Position__c=1;
        insert ref;
        
        Test.startTest();
        PageReference pRef=Page.ALL_AccountHierarchyView;
        pRef.getParameters().put('id', accList[11].Id);
        pRef.getParameters().put('name', accList[11].Name);
        Test.setCurrentPage(pRef);
        ALL_AccountHierarchy_Controller.processAccountHierarchy();
        Test.stopTest();
    }
}