/*-----------------------------------------

****UPDATE HISTORY****
08/28/15 - Venkata Shrivol - Renamed the class to IMP_UpdateEntityNumsOnDealState_Handler
                             and modified the code accordingly to bring impact project number also 

-----------------------------------------*/

public with sharing class IMP_UpdateEntityNumsOnDealState_Handler 
{
	public static void updateEntityNumbers(map<String, map<String, set<String>>> dealIdToEntityMap)
	{
		try
		{
			
				Map<id, map<string, set<String>>> oppIdToEntityMap = new Map<id, map<string, set<String>>>();
                
				list<Opportunity_Quotes__c> oppQuotes = [
                    Select Id, Opportunity__r.id, Deal_id__c 
                    from Opportunity_Quotes__c 
                    where deal_id__c IN :dealIdToEntityMap.keySet()
                ];
                
				for(Opportunity_Quotes__c oppQuote : oppQuotes)
                {
                	
                	map<string, set<string>> entTypeToNumberMap= oppIdToEntityMap.containsKey(oppQuote.Opportunity__r.id) ? oppIdToEntityMap.get(oppQuote.Opportunity__r.id) : new map<string, set<string>>();
                	entTypeToNumberMap.putAll(dealIdToEntityMap.containsKey(oppQuote.Deal_Id__c) ? dealIdToEntityMap.get(oppQuote.Deal_Id__c) : new map<String, set<String>>());
                	
                	
                	/*list<String> contNumLst = oppContractNumMap.containsKey(oppQuote.Opportunity__r.id) ? oppContractNumMap.get(oppQuote.Opportunity__r.id) : new list<string>();
                	contNumLst.addAll(dealContractMap.containsKey(oppQuote.Deal_Id__c) ? dealContractMap.get(oppQuote.Deal_Id__c) : new list<string>());
                	
                	Set<String> cntNumSet = new Set<String>();                	
                	cntNumSet.addAll(contNumLst);
                	
                	contNumLst.clear();
                	contNumLst.addAll(cntNumSet);*/
                	
                	oppIdToEntityMap.put(oppQuote.Opportunity__r.id, entTypeToNumberMap );
					system.debug('---------oppContractNumMap inside loop--------'+oppIdToEntityMap);
				}
				system.debug('---------oppContractNumMap--------'+oppIdToEntityMap);
                
				list<Deal_State__c> dsList = [
                    Select Id, Contract_Number_s__c, Impact_Project_Number__c, Opportunity__r.id, CA_Approved_Date__c , Exception_Contract_Push__c
                    from Deal_State__c 
                    where Opportunity__c IN :oppIdToEntityMap.keySet()
                ];
				
				for(Deal_State__c ds : dsList)
				{
					if(oppIdToEntityMap.containsKey(ds.Opportunity__r.id))
					{
						set<String> contractNumberSet = oppIdToEntityMap.get(ds.Opportunity__r.id).get('Contract');
						String contractNumbers = string.join(new list<String>(contractNumberSet),', ');
						set<String> impactProjectNumberSet = oppIdToEntityMap.get(ds.Opportunity__r.id).get('Impact Project');
						String impactProjectNumbers = string.join(new list<String>(impactProjectNumberSet),', ');
						
						
						if(ds.Contract_Number_s__c ==null)
						{
							ds.Contract_Number_s__c = contractNumbers;
							/*ds.Contract_Number_s__c= '';
							for(String str: contractNumberSet)
							{
								ds.Contract_Number_s__c += str+ ', ';
							}
							ds.Contract_Number_s__c = ds.Contract_Number_s__c.removeEnd(', ');*/
						}
						else
						{
							ds.Contract_Number_s__c = ds.Contract_Number_s__c +', '+contractNumbers;
							/*for(String str: contractNumberSet)
							{
								ds.Contract_Number_s__c += ', '+str;
							}*/
						}
						if(ds.Impact_Project_Number__c ==null)
						{
							ds.Impact_Project_Number__c = impactProjectNumbers;
							/*ds.Impact_Project_Number__c= '';
							for(String str: impactProjectNumberSet)
							{
								ds.Impact_Project_Number__c += str+ ', ';
							}
							ds.Impact_Project_Number__c = ds.Impact_Project_Number__c.removeEnd(', ');*/
						}
						else
						{ds.Impact_Project_Number__c = ds.Impact_Project_Number__c+', '+impactProjectNumbers;
							/*for(String str: impactProjectNumberSet)
							{
								ds.Impact_Project_Number__c += ', '+str;
							}*/
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
	/*-------OLD CODE--------
	Map<id, map<string, set<String>> oppIdToEntityMap = new Map<id, map<string, set<String>>();
                
				list<Opportunity_Quotes__c> oppQuotes = [
                    Select Id, Opportunity__r.id, Deal_id__c 
                    from Opportunity_Quotes__c 
                    where deal_id__c IN :dealIdToEntityMap.keySet()
                ];
                
				for(Opportunity_Quotes__c oppQuote : oppQuotes)
                {
                	
                	map<string, set<string>> = 
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
	*/
}