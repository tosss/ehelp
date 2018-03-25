@IsTest
public class DS_OpportunityDealChange_Test 
{
    public static testmethod void Test()
    {
        // test without existing deal state
        Opportunity opp1 = DS_TestObjects.NewOpportunity_Inserted();
        ApexPages.StandardController oppSC = new ApexPages.StandardController(opp1); // instantiate new standard controller
        DS_OpportunityDealChange_Extension OpportunityDealChangeExtension = new DS_OpportunityDealChange_Extension(oppSC);
        OpportunityDealChangeExtension.SaveDealChange();
        
        // test with existing deal state
        Opportunity opp2 = DS_TestObjects.NewOpportunity_Inserted();
        
        Deal_State__c DealState = new Deal_State__c();
        DealState.Opportunity__c = opp2.Id;
        DealState.Deal_Status__c = 'New Deal Arrived';
        DealState.Description_of_Need__c = 'Requested Changes from Opportunity Page';
        insert DealState;
        
        OpportunityDealChangeExtension.CurrentOpportunity = opp2;
        OpportunityDealChangeExtension.initialize();
        OpportunityDealChangeExtension.SaveDealChange();
        
        // test error case
        OpportunityDealChangeExtension.DealState = null;
        OpportunityDealChangeExtension.DealStateExists = false;
        OpportunityDealChangeExtension.SaveDealChange();
    }
}