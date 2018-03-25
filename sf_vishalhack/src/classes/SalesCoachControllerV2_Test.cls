//2015-11-13- anirudh.singh@cdk.com- Created this test class for SalesCoachControllerV2. Earlier no test class existed for SalesCoachControllerV2.
@isTest
public class SalesCoachControllerV2_Test
{
    @TestSetup
    private static void setupData()
    {
        Account acc = DS_TestObjects.NewAccount_Inserted();
        Opportunity opp=TestingUtil.makeTestableOp();
        opp.AccountId = acc.Id;
        insert opp;
    }
    
    private static testmethod void testConstructorFirst()
    {
        SalesCoachControllerV2 sccExceptions=new SalesCoachControllerV2();
    }
    
    private static testmethod void testConstructorSecond()
    {
        Opportunity opp=[SELECT Id FROM Opportunity];
        
        test.startTest();
        PageReference pRef=Page.SalesCoachV2;
        pRef.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pRef);
        
        SalesCoachControllerV2 sccExceptions=new SalesCoachControllerV2();
        test.stopTest();
    }
    
    private static testmethod void testStartProcess()
    {
        Opportunity opp=[SELECT Id FROM Opportunity];
        
        test.startTest();
        Sales_Coach_Stage__c scs=TestingUtil.makeSalesCoachStage();
        insert scs;
        
        PageReference pRef=Page.SalesCoachV2;
        pRef.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pRef);
        
        SalesCoachControllerV2 sccExceptions=new SalesCoachControllerV2();
        test.stopTest();
    }
    
    private static testmethod void testPopulateSuperSectionsFirst()
    {
        Opportunity opp=[SELECT Id FROM Opportunity];
        
        test.startTest();
        Sales_Coach_Stage__c scs=TestingUtil.makeSalesCoachStage();
        insert scs;
        
        Sales_Coach_Section__c scsec=TestingUtil.makeSalesCoachSections(scs.Id);
        insert scsec;
        
        PageReference pRef=Page.SalesCoachV2;
        pRef.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pRef);
        
        SalesCoachControllerV2 sccExceptions=new SalesCoachControllerV2();
        test.stopTest();
    }
    
    private static testmethod void testPopulateSuperSectionsSecond()
    {
        Opportunity opp=[SELECT Id FROM Opportunity];
        
        test.startTest();
        Sales_Coach_Stage__c scs=TestingUtil.makeSalesCoachStage();
        insert scs;
        
        Sales_Coach_Section__c scsec=TestingUtil.makeSalesCoachSections(scs.Id);
        insert scsec;
        
        Sales_Coach_Section_Item__c secItem=TestingUtil.makeSecItem(scsec.Id);
        insert secItem;
        
        PageReference pRef=Page.SalesCoachV2;
        pRef.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pRef);
        
        SalesCoachControllerV2 sccExceptions=new SalesCoachControllerV2();
        test.stopTest();
    }
    
    private static testmethod void testPopulateActivities()
    {
        Opportunity opp=[SELECT Id FROM Opportunity];
        
        test.startTest();
        Sales_Coach_Stage__c scs=TestingUtil.makeSalesCoachStage();
        insert scs;
        
        Sales_Coach_Section__c scsec=TestingUtil.makeSalesCoachSections(scs.Id);
        insert scsec;
        
        Sales_Coach_Section_Item__c secItem=TestingUtil.makeSecItem(scsec.Id);
        insert secItem;
        
        Sales_Coach_Activity__c sca=TestingUtil.makeActivities(scs.Id);
        insert sca;
        
        PageReference pRef=Page.SalesCoachV2;
        pRef.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pRef);
        
        SalesCoachControllerV2 sccExceptions=new SalesCoachControllerV2();
        test.stopTest();
    }
    
    private static testMethod void testUpdateStageData()
    {
        SalesCoachControllerV2 scc=new SalesCoachControllerV2();
        System.assert(scc.updateStageData()==Null);
    }
    
    private static testmethod void testGettersAndSetters()
    {
        Opportunity opp=[SELECT Id FROM Opportunity];
        
        test.startTest();
        Sales_Coach_Stage__c scs=TestingUtil.makeSalesCoachStage();
        insert scs;
        
        Sales_Coach_Section__c scsec=TestingUtil.makeSalesCoachSections(scs.Id);
        insert scsec;
        
        Sales_Coach_Section_Item__c secItem=TestingUtil.makeSecItem(scsec.Id);
        insert secItem;
        
        Sales_Coach_Activity__c sca=TestingUtil.makeActivities(scs.Id);
        insert sca;
        
        PageReference pRef=Page.SalesCoachV2;
        pRef.getParameters().put('id', opp.Id);
        Test.setCurrentPage(pRef);
        
        SalesCoachControllerV2 scc=new SalesCoachControllerV2();
        System.assert(scc.getOpportunityStage()=='testStage');
        System.assert(scc.getSalesCoachStage().Name=='testStage');
        System.assert(scc.getSuperSections().size()>=0);
        System.assert(scc.getSalesCoachActivities().size()>0);
        System.assert(scc.getSuperSections()[0].getSalesCoachSection()!=null);
        System.assert(scc.getSuperSections()[0].getSalesCoachSectionItems().size()>0);
        
        scc.setOpportunityStage('newOpStage');
        System.assert(scc.getOpportunityStage()=='newOpStage');
        
        System.assert(scc.getOpptyStages().size()>0);
        test.stopTest();
    }
}