public with sharing class CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler {
	
	public static void creativeCaseTallyUpdate(set<Id> caseIds)
	{
		try
		{
			list<sObject> updLst = new list<sObject>();
			Map<Id,WebID__c> updMap = new Map<Id,WebID__c>();
            
			for(Case cs: [
                Select Id, WebID__c, WebID__r.Creative_Case_Tally__c, WebID__r.Creative_Case_Limit__c, Problem_Code__c,Creative_Case_Limit__c  
                from Case 
                where Id IN: caseIds])
			{
				// This map is used for the related account plan creative case tally fields.
				WebID__c webId = updMap.containsKey(cs.WebID__c) ? 
                    updMap.get(cs.WebID__c) : 
                    new WebID__c(
                        id=cs.WebID__c, 
                        Creative_Case_Tally__c = cs.WebID__r.Creative_Case_Tally__c, 
                        Creative_Case_Limit__c=cs.WebID__r.Creative_Case_Limit__c
                    );
                
                system.debug('WebId Creative Caselimit'+webId.Creative_Case_Limit__c );
                if(webId.Creative_Case_Limit__c != null){
                    cs.Creative_Case_Limit__c = webId.Creative_Case_Limit__c;
                }
                
                if(cs.Problem_Code__c != null && cs.Problem_Code__c.startsWithIgnoreCase('Power'))
                {
                    if(webId.Creative_Case_Tally__c == null ){
                        webId.Creative_Case_Tally__c = 1;
                        cs.Creative_Case_Tally__c = webId.Creative_Case_Tally__c; 
                    }
                    else{
                        webId.Creative_Case_Tally__c +=1;
                        cs.Creative_Case_Tally__c = webId.Creative_Case_Tally__c;
                    }
                    updMap.put(webId.id, webId);
                    updLst.add(webId);    
                }
                else if(cs.Problem_Code__c != null && !cs.Problem_Code__c.startsWithIgnoreCase('Power'))
                {
                    if(webId.Creative_Case_Tally__c != null)
                    {
                        cs.Creative_Case_Tally__c = webId.Creative_Case_Tally__c;
                    }  
                }
                updLst.add(cs);
			}
			//update updMap.values();
			//system.debug(updMap);
			//update caseList;
			//system.debug('------CASE LIST--------'+caseList);
			
			for(Account_Plan__c acPlan : [
                Select Id, Creative_Case_Tally__c, WebId__c, RecordType.Name 
                from Account_Plan__c 
                where WebId__c in :updMap.keySet() 
                and RecordType.Name = 'DAA Account Plan'])
			{
                acPlan.Creative_Case_Tally__c = updMap.get(acPlan.WebId__c).Creative_Case_Tally__c;
                system.debug('---Creative Case Tally----'+acPlan.Creative_Case_Tally__c);
                updLst.add(acPlan);
			}
            
			//update updateList;
			update updLst;
		}
		catch(Exception ex)
		{
			system.debug('----------Exception--------------------'+ex);
		}
		
		
	}

}