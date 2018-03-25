public with sharing class IMP_UpdateDealStateRollCallDate_Handler {
    
    public static void updateRollCallDate (Map<string, Date> rollCalledDateMap) {
        
        try
        {
            Map<id,Date> oppQuoteMap = new Map<id,Date>();
            
            list<Opportunity_Quotes__c> oppQuoteList = [
                Select Id, Opportunity__r.id, Deal_id__c 
                from Opportunity_Quotes__c 
                where deal_id__c IN :rollCalledDateMap.keySet()
            ];
            
            for(Opportunity_Quotes__c oppQuote : oppQuoteList)
            {
                oppQuoteMap.put(oppQuote.Opportunity__r.id, 
                    rollCalledDateMap.containsKey(oppQuote.Deal_Id__c) ? rollCalledDateMap.get(oppQuote.Deal_Id__c) : null);
            }
            
            list<Deal_State__c> dealStateList = [
                Select Id, Opportunity__r.id, Roll_Call_Date__c
                from Deal_State__c 
                where Opportunity__c IN :oppQuoteMap.keySet()
            ];
            
            for(Deal_State__c ds : dealStateList)
            {
                ds.Roll_Call_Date__c = oppQuoteMap.containsKey(ds.Opportunity__r.id) ? oppQuoteMap.get(ds.Opportunity__r.id) : null;
            }
            
            update dealStateList;
        }
        catch(Exception e){
            system.debug('----e---'+e);
        }
        
    }

}