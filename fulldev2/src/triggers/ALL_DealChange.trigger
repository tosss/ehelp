trigger ALL_DealChange on Deal_Change__c (after insert,after update) 
{
    //sanjay.ghanathey@cdk.com 13-Mar-2015 Update Dealstate
    ALL_DealChange_Helper.updateDealState(Trigger.New);
}