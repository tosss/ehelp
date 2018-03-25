//2016-01-22- anirudh.singh@cdk.com- Created this Test class for the Handler DS_DealStateSecured_Handler for Request RQ-06022.
@isTest
public class DS_DealStateSecured_Test
{
    @TestSetup
    private static void setupData()
    {
        Opportunity opp=DS_TestObjects.NewOpportunity_Inserted();
    }
    
    private static testMethod void preventMultipleRecsTestOne()
    {
        Opportunity opp=[SELECT Id FROM Opportunity];
        
        test.startTest();
        Deal_State__c dealStateRec=new Deal_State__c();
        dealStateRec.Quantity_of_Sites__c=2;
        dealStateRec.Opportunity__c=opp.Id;
        try
        {
            insert dealStateRec;
        }
        catch(Exception e)
        {
            system.debug(e);
        }
        
        List<Deal_State_Secured__c> dealStateSecList=new List<Deal_State_Secured__c>();
        
        Deal_State_Secured__c dealStateSecRec=new Deal_State_Secured__c();
        dealStateSecRec.Deal_State__c=dealStateRec.Id;
        dealStateSecList.add(dealStateSecRec);
        
        DS_DealStateSecured_Handler.preventMultipleRecsOnParent(dealStateSecList);
        try
        {
            insert dealStateSecList;
        }
        catch(Exception e)
        {
            system.debug(e);
        }
        
        test.stopTest();
    }
    
    private static testMethod void preventMultipleRecsTestTwo()
    {
        Opportunity opp=[SELECT Id FROM Opportunity];
        
        test.startTest();
        Deal_State__c dealStateRec=new Deal_State__c();
        dealStateRec.Quantity_of_Sites__c=2;
        dealStateRec.Opportunity__c=opp.Id;
        try
        {
            insert dealStateRec;
        }
        catch(Exception e)
        {
            system.debug(e);
        }
        
        List<Deal_State_Secured__c> dealStateSecList=new List<Deal_State_Secured__c>();
        
        Deal_State_Secured__c dealStateSecRecOne=new Deal_State_Secured__c();
        dealStateSecRecOne.Deal_State__c=dealStateRec.Id;
        dealStateSecList.add(dealStateSecRecOne);
        
        DS_DealStateSecured_Handler.preventMultipleRecsOnParent(dealStateSecList);
        try
        {
            insert dealStateSecList;
        }
        catch(Exception e)
        {
            system.debug(e);
        }
        
        //Insert a second Deal State Secured - should cause an error
        Deal_State_Secured__c dealStateSecRecTwo=new Deal_State_Secured__c();
        dealStateSecRecTwo.Deal_State__c=dealStateRec.Id;
        try
        {
            insert dealStateSecRecTwo;
        }
        catch(Exception e)
        {
            system.debug(e);
        }
        
        test.stopTest();
    }
    
    private static testMethod void updateDealStateRecordsTest()
    {
        Opportunity opp=[SELECT Id FROM Opportunity];
        
        test.startTest();
        Deal_State__c dealStateRec=new Deal_State__c();
        dealStateRec.Quantity_of_Sites__c=2;
        dealStateRec.Opportunity__c=opp.Id;
        
        try
        {
            insert dealStateRec;
        }
        catch(Exception e)
        {
            system.debug(e);
        }
        
        List<Deal_State_Secured__c> dealStateSecList=new List<Deal_State_Secured__c>();
        
        Deal_State_Secured__c dealStateSecRec=new Deal_State_Secured__c();
        dealStateSecRec.Deal_State__c=dealStateRec.Id;
        
        try
        {
            insert dealStateRec;
        }
        catch(Exception e)
        {
            system.debug(e);
        }
        
        List<Deal_State_Secured__c> newdealStateSecuredList=new List<Deal_State_Secured__c>();
        newdealStateSecuredList.add(dealStateSecRec);
        
        DS_DealStateSecured_Handler.updateDealStateRecords(newdealStateSecuredList);
        
        test.stopTest();
    }
}