//2016-03-03- anirudh.singh@cdk.com- Modified this class for Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
public with sharing class IMP_UpdateDealStateRollCallDate_Handler
{
    public static void updateRollCallDate(Map<String, Date> dealIdAndContractRollCalledMap)
    {
        system.debug('Start updateRollCallDate---->');
        try
        {
            Map<Id, Date> oppIdAndContractRollCalledMap=new Map<Id, Date>();
            
            List<Opportunity_Quotes__c> oppQuoteList=[
                SELECT Id, Opportunity__r.Id, Deal_Id__c 
                FROM Opportunity_Quotes__c 
                WHERE Deal_Id__c IN :dealIdAndContractRollCalledMap.keySet()
            ];
            
            for(Opportunity_Quotes__c oppQuoteRecord: oppQuoteList)
            {
                oppIdAndContractRollCalledMap.put(oppQuoteRecord.Opportunity__r.Id, 
                                                  dealIdAndContractRollCalledMap.containsKey(oppQuoteRecord.Deal_Id__c) ? dealIdAndContractRollCalledMap.get(oppQuoteRecord.Deal_Id__c) : null);
            }
            
            List<Deal_State__c> dealStateList=[
                SELECT Id, Opportunity__r.Id, Roll_Call_Date__c
                FROM Deal_State__c 
                WHERE Opportunity__c IN :oppIdAndContractRollCalledMap.keySet()
            ];
            
            for(Deal_State__c dealStateRecord: dealStateList)
            {
                dealStateRecord.Roll_Call_Date__c=oppIdAndContractRollCalledMap.containsKey(dealStateRecord.Opportunity__r.Id) ? oppIdAndContractRollCalledMap.get(dealStateRecord.Opportunity__r.Id) : null;
            }
            
            update dealStateList;
        }
        catch(Exception ex)
        {
            system.debug('Exception---->'+ex);
        }
        system.debug('End updateRollCallDate---->');
    }
}