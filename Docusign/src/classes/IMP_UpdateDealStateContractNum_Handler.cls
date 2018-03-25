public with sharing class IMP_UpdateDealStateContractNum_Handler 
{
	
	public static void updateContractNumbers(Map<String,list<String>> dealContractMap)
	{
		try
		{
			
				Map<id,list<String>> oppContractNumMap = new Map<id,list<String>>();
                
				list<Opportunity_Quotes__c> oppQuotes = [
                    Select Id, Opportunity__r.id, Deal_id__c 
                    from Opportunity_Quotes__c 
                    where deal_id__c IN :dealContractMap.keySet()
                ];
                
				for(Opportunity_Quotes__c oppQuote : oppQuotes)
                {
                	list<String> contNumLst = oppContractNumMap.containsKey(oppQuote.Opportunity__r.id) ? oppContractNumMap.get(oppQuote.Opportunity__r.id) : new list<string>();
                	contNumLst.addAll(dealContractMap.containsKey(oppQuote.Deal_Id__c) ? dealContractMap.get(oppQuote.Deal_Id__c) : new list<string>());
                	
                	Set<String> cntNumSet = new Set<String>();                	
                	cntNumSet.addAll(contNumLst);
                	
                	contNumLst.clear();
                	contNumLst.addAll(cntNumSet);
                	
                	oppContractNumMap.put(oppQuote.Opportunity__r.id, contNumLst );
					system.debug('---------oppContractNumMap inside loop--------'+oppContractNumMap);
				}
				system.debug('---------oppContractNumMap--------'+oppContractNumMap);
                
				list<Deal_State__c> dsList = [
                    Select Id, Contract_Number_s__c,Opportunity__r.id, CA_Approved_Date__c , Exception_Contract_Push__c
                    from Deal_State__c 
                    where Opportunity__c IN :oppContractNumMap.keySet()
                ];
				
				for(Deal_State__c ds : dsList)
				{
					if(oppContractNumMap.containsKey(ds.Opportunity__r.id))
					{
						if(ds.Contract_Number_s__c ==null)
						{
							ds.Contract_Number_s__c= '';
							for(String str: oppContractNumMap.get(ds.Opportunity__r.id))
							{
								ds.Contract_Number_s__c += str+ ', ';
							}
							ds.Contract_Number_s__c = ds.Contract_Number_s__c.removeEnd(', ');
						}
						else
						{
							for(String str: oppContractNumMap.get(ds.Opportunity__r.id))
							{
								ds.Contract_Number_s__c += ', '+str;
							}
						}
					}
					
					
					if(ds.CA_Approved_Date__c != null)
						{
							ds.Exception_Contract_Push__c = 'CA';
						}
				}
				
                
				update dsList;
		}
        catch(Exception e){
			system.debug('----e---'+e);
		}
	}
}