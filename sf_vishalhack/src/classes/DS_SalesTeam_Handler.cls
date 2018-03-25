/*----------------------------------------------------------
RQ-07305
2016-07-13 -venkata.shrivol@cdk.com -Created
------------------HISTORY------------------------------------
2017-04-07 -venkata.shrivol@cdk.com	-changed the contact share logic in after insert, update and before delete methods (RQ-08999)
------------------------------------------------------------*/
public class DS_SalesTeam_Handler 
{
	public static string ERROR_MESSAGE ='A user can only appear once in the sales team for each opportunity.';
	
	public static void beforeInsert(list<Sales_Team__c> salesTeam)
	{
		for(Sales_Team__c slsTeam: salesTeam)
		{
			slsTeam.Opportunity_User_Id__c = (string)slsTeam.Opportunity__c + (String)slsTeam.User__c;
		}
		
		List<OpportunityTeamMember> opportunityMembers = DS_CreateSForceSalesTeam.insertSForceSalesTeam(salesTeam);
		Integer x=0;
        Map <ID,ID> existingStdSTMS=new Map <ID,ID>();
        
        if(opportunityMembers.size() > 0 )
        {
        	for(x=0; x<salesTeam.size(); x++)
	        {
	        	if(opportunityMembers.size() > x )
	        	{
	        		if(opportunityMembers.get(x)!=Null)
		            {
		                //cn commented 03 / 20
		                //salesTeam.get(x).SForce_Sales_Team_Id__c=opportunityMembers.get(x).Id;  
		                //x++;
		                
		                if(existingStdSTMS.get(opportunityMembers.get(x).Id)==Null)
		                {
		                    salesTeam.get(x).SForce_Sales_Team_Id__c=opportunityMembers.get(x).Id;
		                    existingStdSTMS.put(opportunityMembers.get(x).Id, opportunityMembers.get(x).Id);
		                }
		                else
		                {
		                    salesTeam.get(x).SForce_Sales_Team_Id__c=Null;
		                }
		            }
		            else
		            {
		                salesTeam.get(x).addError('Error in Creating Sales Team - Check for active Opp Owner');
		            }
	        	}
	            
	        }
        }
        
         //duplicateCheckOnSalesTeamMember(salesTeam, null);
	}   
	
	public static void beforeUpdate(list<Sales_Team__c> newSalesTeam, list<Sales_Team__c> oldSalesTeam)
	{
		for(Sales_Team__c slsTeam: newSalesTeam)
		{
			slsTeam.Opportunity_User_Id__c = (string)slsTeam.Opportunity__c + (String)slsTeam.User__c;
		}
		
		DS_CreateSForceSalesTeam.deleteSForceSalesTeam(newSalesTeam);
        List<OpportunityTeamMember> opportunityMembers=DS_CreateSForceSalesTeam.insertSForceSalesTeam(newSalesTeam);    
        
        for(Integer x=0; x<newSalesTeam.size(); x++)
        {
        	if(opportunityMembers.size() > x)
        	{
        		newSalesTeam.get(x).SForce_Sales_Team_Id__c=opportunityMembers.get(x).Id; 
        	}
               
        }
        //duplicateCheckOnSalesTeamMember(newSalesTeam, oldSalesTeam);
	} 
	
	public static void beforeDelete(list<Sales_Team__c> oldSalesTeam)
	{
		DS_CreateSForceSalesTeam.deleteSForceSalesTeam(oldSalesTeam);
		 
		 // 6/26/09 - removed since not use forecast opportunities now
        //utils.deleteSalesTeam(oldSalesTeam);
      //  if(UserInfo.getProfileId() !=CustomSettings__c.getInstance().Profile_Id__c)
      //  {
        	map<Id, set<Id>> oppIdToUserIdMap = new map<ID, set<Id>>();
            for(Sales_Team__c slsTeam:oldSalesTeam)
            {
            	set<Id> userIds = oppIdToUserIdMap.containsKey(slsTeam.Opportunity__c) ?
            					  oppIdToUserIdMap.get(slsTeam.Opportunity__c) :
            					  new set<Id>();
            	userIds.add(slsTeam.User__c);
            	oppIdToUserIdMap.put(slsTeam.Opportunity__c, userIds);				  
            }
            ALL_InsertContactShare_Helper.sharingResult sr = ALL_InsertContactShare_Helper.prepareShareIdsFromOpp(oppIdToUserIdMap);
            set<Id> userIds = new set<Id>();
            set<Id> contactIds = new set<Id>();
            for(Id accountId:sr.sharingIdMap.keySet()){
            	userIds.addAll(sr.accIdToUserIdMap.get(accountId));
            	contactIds.addAll(sr.sharingIdMap.get(accountId));
            }
            
            ALL_InsertContactShare_Helper.deleteContactShare('UserOrGroupId',userIds,'ContactId',contactIds);
        //}
	}
	
	public static void afterInsert(list<Sales_Team__c> newSalesTeam)
	{
		map<Id, set<Id>> oppIdToUserIDMap = new map<Id, set<Id>>();
		for(Sales_Team__c slsteam:newSalesTeam)
		{
			set<Id> userIds = oppIdToUserIDMap.containsKey(slsteam.Opportunity__c) ?
							  oppIdToUserIDMap.get(slsteam.Opportunity__c) :
							  new set<Id>();
			userIds.add(slsteam.User__c);
			oppIdToUserIDMap.put(slsteam.Opportunity__c, userIds);				  	
		}
		ALL_InsertContactShare_Helper.sharingResult sr =  ALL_InsertContactShare_Helper.prepareShareIdsFromOpp(oppIdToUserIDMap);
		ALL_InsertContactShare_Helper.insertContactShare(sr.sharingIdMap, sr.accIdToUserIdMap, sr.ownerMapIdsToRemove,  true);
	}
	
	public static void afterUpdate(list<Sales_Team__c> newSalesTeam, map<Id, Sales_Team__c> oldSalesTeamMap)
	{
		set<Id> userIDsToDelete = new set<Id>();
		set<Id> oppIds = new set<Id>();
		map<Id, set<Id>> oppIdToUserIdsMap = new map<Id, set<Id>>();
		for(Sales_Team__c slsTeam:newSalesTeam)
		{
			Sales_Team__c oldSlsTeam = oldSalesTeamMap.get(slsTeam.Id);
			
			if(slsTeam.User__c != oldSlsTeam.User__c)
			{
				set<Id> userIds = oppIdToUserIdsMap.containsKey(slsTeam.Opportunity__c) ?
								  oppIdToUserIdsMap.get(slsTeam.Opportunity__c):
								  new set<Id>();
				userIds.add(slsTeam.User__c);
				oppIdToUserIdsMap.put(slsTeam.Opportunity__c, userIds);			  
				userIDsToDelete.add(oldSlsTeam.User__c);
			}    			
		}
		if(!userIDsToDelete.isEmpty() && !oppIdToUserIdsMap.isEmpty())
		{
			
			ALL_InsertContactShare_Helper.sharingResult sr = ALL_InsertContactShare_Helper.prepareShareIdsFromOpp(oppIdToUserIdsMap);
			set<Id> contactIds = new set<Id>();
			for(Id AccountId:sr.sharingIdMap.keySet()){
				contactIds.addAll(sr.sharingIdMap.get(AccountId));
			}
			ALL_InsertContactShare_Helper.deleteContactShare('UserOrGroupId',userIDsToDelete, 'ContactId', contactIds);
			//userIdsToInsert.removeAll(sr.ownerIdsToRemove);
			ALL_InsertContactShare_Helper.insertContactShare(sr.sharingIdMap, sr.accIdToUserIdMap, sr.ownerMapIdsToRemove, true);
		}
        
	}
	
	// This method checks if the user on salesTeam member(STM) is already a part of that opportunity as another STM record. 
	/*public static void duplicateCheckOnSalesTeamMember(list<Sales_Team__c> salesTeam, list<Sales_Team__c> oldSalesTeam)
	{
		Set<String> parentOpportunities=new Set<String>();
        
        for(Sales_Team__c sTeamMember:salesTeam)
        {
            parentOpportunities.add(sTeamMember.Opportunity__c);
        }   
        
        Map<String, String> opportunityTeam=new Map<String, String>();
        
        List<Sales_Team__c> salesTeamAll=[
            SELECT User__c, Opportunity__c 
            FROM Sales_Team__c 
            WHERE Opportunity__c IN :parentOpportunities
        ];
                
        for(Sales_Team__c teamMember:salesTeamAll)
        {
            String temp=opportunityTeam.get(teamMember.Opportunity__c);
            
            if(temp == Null)
            {
                opportunityTeam.put(teamMember.Opportunity__c, teamMember.User__c);
            }
            else
            {
                opportunityTeam.remove(teamMember.Opportunity__c);
                opportunityTeam.put(teamMember.Opportunity__c, temp + teamMember.User__c);
            }
        }
                
        for(Integer x=0; x<salesTeam.size(); x++)
        {
            String opptId=opportunityTeam.get(salesTeam[x].Opportunity__c);
            
            if(Trigger.isInsert)
            {
                if(opptId != Null)
                {   
                    if(salesTeam.get(x).SForce_Sales_Team_Id__c !=Null)
                    {
                        if(opptId.indexOf(salesTeam[x].User__c)!=-1)
                        {
                            salesTeam[x].User__c.addError(ERROR_MESSAGE);                    
                        }
                    }
                    else
                    {
                        salesTeam[x].User__c.addError(ERROR_MESSAGE);
                    }
                }
                else
                {
                    if(salesTeam.get(x).SForce_Sales_Team_Id__c == Null) 
                    {
                        salesTeam[x].User__c.addError(ERROR_MESSAGE);
                        system.debug('Adding error as the user exists');
                    }
                }
            }
            if(Trigger.isUpdate)
            {
            	
                if(opptId != Null)
                {   
                    if(opptId.indexOf(salesTeam[x].User__c) != -1 
                       && salesTeam[x].User__c != oldSalesTeam[x].User__c)
                    {
                        salesTeam[x].User__c.addError('A user can only appear once in the sales team for each opportunity.');                   
                    }
                }
            }
        }   
	}*/
}