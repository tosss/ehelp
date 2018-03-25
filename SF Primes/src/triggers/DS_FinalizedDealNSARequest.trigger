trigger DS_FinalizedDealNSARequest on Finalized_Deal_NSA_Request__c(after insert) 
{
    DS_FinalizedDealNSARequest_Handler.FinalizedDealNSARequest(Trigger.New);
}