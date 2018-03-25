//2015-11-13- anirudh.singh@cdk.com- Created this test class for SalesCoachSetup. Earlier no test class existed for SalesCoachSetup.
@isTest
public class SalesCoachSetup_Test
{
    @TestSetup
    private static void setupData()
    {
        Sales_Coach_Stage__c scs=TestingUtil.makeSalesCoachStage();
        insert scs;
        
        Sales_Coach_Section__c scsec=TestingUtil.makeSalesCoachSections(scs.Id);
        insert scsec;
        
        Sales_Coach_Section_Item__c secItem=TestingUtil.makeSecItem(scsec.Id);
        insert secItem;
    }
    
    static testMethod void testOne()
    {
        Sales_Coach_Stage__c salesCoachStage=[SELECT Id, Name, Buyer_Stage__c, Active__c FROM Sales_Coach_Stage__c];
        Sales_Coach_Section__c salesCoachSection=[SELECT Id FROM Sales_Coach_Section__c];
        Sales_Coach_Section_Item__c salesCoachSectionItem=[SELECT Id FROM Sales_Coach_Section_Item__c];
        
        test.startTest();
        SalesCoachSetup salesCoachSetupRef=new SalesCoachSetup();
        
        system.assert(salesCoachSetupRef.getShowSections()!=Null);
        system.assert(salesCoachSetupRef.getScStage()==Null);
        System.assert(salesCoachSetupRef.getScActivities()==Null);
        System.assert(salesCoachSetupRef.getSwi()==Null);
        
        salesCoachSetupRef.getSections();
        
        salesCoachSetupRef.stage='-- Select --';
        salesCoachSetupRef.getSections();
        
        salesCoachSetupRef.stage='testStage';
        salesCoachSetupRef.getSections();
        
        system.assert(salesCoachSetupRef.getShowSections()!=Null);
        system.assert(salesCoachStage==salesCoachSetupRef.getScStage());
        system.assert(salesCoachSetupRef.getScActivities()!=Null && salesCoachSetupRef.getScActivities().size()==3);
        system.assert(salesCoachSetupRef.getSwi()!=Null);
        
        salesCoachSetupRef.saveSections();
        
        salesCoachSetupRef.stage='Closed Won';
        salesCoachSetupRef.getSections();
        
        salesCoachSetupRef.stage='Prospecting';      
        system.assert(salesCoachSetupRef.getSections()==Null);
        
        salesCoachSetupRef.deleteActivity();
        
        List<Sales_Coach_Activity__c> salesCoachActivityList=salesCoachSetupRef.getScActivities();
        salesCoachActivityList[0].Activity_Details__c='test0';
        salesCoachActivityList[1].Activity_Details__c='test1';
        salesCoachActivityList[2].Activity_Details__c='test2';
        salesCoachSetupRef.saveActivities();
        
        salesCoachSetupRef.saveSections();
        
        salesCoachSetupRef.toDelete=salesCoachSectionItem.Id;
        salesCoachSetupRef.deleteSectionItem();
        
        salesCoachSetupRef.toDelete=salesCoachSection.Id;
        salesCoachSetupRef.deleteSection();
        
        salesCoachSetupRef.toDelete=salesCoachActivityList[1].Id;
        salesCoachSetupRef.deleteActivity();
        
        SalesCoachSetup.getOpptyStages();
        test.stopTest();
    }
    
    static testMethod void testTwo()
    {
        Sales_Coach_Stage__c salesCoachStage=[SELECT Id, Name, Buyer_Stage__c, Active__c FROM Sales_Coach_Stage__c];
        Sales_Coach_Section__c salesCoachSection=[SELECT Id FROM Sales_Coach_Section__c];
        Sales_Coach_Section_Item__c salesCoachSectionItem=[SELECT Id FROM Sales_Coach_Section_Item__c];
        
        test.startTest();
        SalesCoachSetup salesCoachSetupRef=new SalesCoachSetup();
        salesCoachSetupRef.saveSections();
        salesCoachSetupRef.deleteSection();
        salesCoachSetupRef.deleteActivity();
        salesCoachSetupRef.deleteSectionItem();
        test.stopTest();
    }
}