trigger DS_OpportunityQuotes on Opportunity_Quotes__c (after insert, after update) 
{
    if(trigger.isInsert || trigger.isUpdate) {
        DS_OpportunityQuotes_Handler.UpdateDealState(Trigger.new); 
    }
}