/*----------------------------------------------------------
RQ-06969
2016-06-23 -venkata.shrivol@cdk.com -Created RQ-06969
2016-12-23 -venkata.shrivol@cdk.com -Commented code in prepareShareIdsFromOpp method
									 to fix the contact share on salesTeam trigger.
2017-04-07 -venkata.shrivol@cdk.com	- changed the class as per request RQ-08999
------------------------------------------------------------*/
public class ALL_InsertContactShare_Helper 
{
	public static string DIGITAL_ADVISOR_ROLES = CustomSettings__c.getOrgDefaults().Digitial_Advisor_Roles__c;
    public static sharingResult prepareShareIds(set<Id> accountIds)
    {
        map<Id, set<Id>> accountIdToContactIdSet = new map<Id, set<Id>>();
    	map<Id, set<string>> contactOwnersToFilter = new map<Id, set<String>>();
    	map<Id, set<Id>> accountIdToPrimaryContactIdSet = new map<Id, set<Id>>();
    	
        set<Id> sharingObjectIds = new set<Id>();
        set<Id> ownerIds = new set<Id>();
        set<Id> contactOnPrimaryAccountIds = new set<Id>();
        set<Id> accountIdsToRemove = new set<Id>();
        
        for(Contact_Relationship__c crt:[
            select Account__c, Account__r.ownerId, 
            Contact__c, Contact__r.OwnerId, Contact__r.AccountId
            from Contact_Relationship__c 
            where Account__c IN :accountIds 
            and Status__c = 'Active'
            ])
        {
        	Id AccountId = crt.Account__c;
        	//Only considering indirect contact relationships on account.
        	//Direct contacts are already accessible to account team members
        	if(AccountId != crt.Contact__r.AccountId)
            {
	        	set<Id> contactIdSet = accountIdToContactIdSet.containsKey(AccountId) ? 
	    						accountIdToContactIdSet.get(AccountId) : 
	    						new set<Id>();
		    	contactIdSet.add(crt.Contact__c);
		    	accountIdToContactIdSet.put(AccountId, contactIdSet);
		    	
		    	set<string> contactOwnerSet = contactOwnersToFilter.containsKey(AccountId) ?
		    							contactOwnersToFilter.get(AccountId):
		    							new set<string>();
		    	//this combination of owner and contactId will be useful when adding contact share
		    	contactOwnerSet.add((string)crt.Contact__c+(string)crt.Contact__r.OwnerId);
		    	contactOwnersToFilter.put(AccountId, contactOwnerSet);
            }
        	
           
        }
        //sharingObjectIds.removeAll(contactOnPrimaryAccountIds);
        
        sharingResult sr = new sharingResult();
        sr.sharingIdMap = accountIdToContactIdSet;
        sr.ownerMapIdsToRemove = contactOwnersToFilter;
        //sr.sharingIds = sharingObjectIds;
        //sr.ownerIdsToRemove = ownerIds;
        //system.debug('---------accountIdToContactIdSet--------'+accountIdToContactIdSet);
        return sr;
    }
    
    public static sharingResult prepareShareIdsFromOpp(map<Id, set<Id>> oppToUserIdMap)
    {
    	system.debug('--opportunityIds--'+oppToUserIdMap.size());
    	
        //2016-12-23 -venkata.shrivol@cdk.com -commented. 
        //set<Id> contactIdsToRemove = new set<Id>();
        map<Id, set<Id>> accountIdToUserIdMap = new map<Id, set<Id>>();
        
        for(Opportunity opp: [select Id, AccountId from Opportunity where Id IN :oppToUserIdMap.keySet()])
        {
        	if(accountIdToUserIdMap.containsKey(opp.AccountId))
        	{
        		set<Id> userIds = accountIdToUserIdMap.get(opp.AccountId);
        		userIds.addAll(oppToUserIdMap.get(opp.Id));
        		accountIdToUserIdMap.put(opp.AccountId, userIds);
        	}
        	else{
        		accountIdToUserIdMap.put(opp.AccountId, oppToUserIdMap.get(opp.Id));
        	}
        }
        
        //1st comparison check on userIds
        // Other sibling opportunities under same account might have same sales team members
        // Filtering out those common sales team members 
        // At insertion, you do not care if those sales team members are already added under diff opportunity for same account.
        // At deletion, you have to restrict deleting contact share if there is same member for another opportunity.
        map<Id, set<Id>> siblingOppSalesTeamMem = new map<Id, set<Id>>();
        for(Sales_team__c sls:[select Id,Opportunity__r.AccountId, User__c from Sales_team__c where Opportunity__c NOT IN :oppToUserIdMap.keySet() 
        		and Opportunity__r.AccountId IN :accountIdToUserIdMap.keySet()])
        {
        	set<Id> userIds = siblingOppSalesTeamMem.containsKey(sls.Opportunity__r.AccountId) ? 
        					siblingOppSalesTeamMem.get(sls.Opportunity__r.AccountId) : 
        					new set<Id>();
        	userIds.add(sls.User__c);
        	siblingOppSalesTeamMem.put(sls.Opportunity__r.AccountId, userIds);				
        }
        if(!siblingOppSalesTeamMem.isEmpty()){
        	accountIdToUserIdMap = mapComparisonHelper(siblingOppSalesTeamMem, accountIdToUserIdMap);
        }
        
        
        //2nd comparison check on userIds
        // populating a map of accountTeamIds to its parent account
        // If the same acc.team members also added as sales team members on its child opportunities,
        // we should remove them using this map.
        map<ID, set<Id>> accIdToAccTeamIds = new map<Id, set<Id>>();
        for(Account_Team__c act: [select Team_Member__c, Account__c, Sales_Roles__c, Team_Role__c 
        		from Account_Team__c 
        		where Account__c IN:accountIdToUserIdMap.keySet()])
        {
        	if(act.Sales_Roles__c || (DIGITAL_ADVISOR_ROLES!=null ? DIGITAL_ADVISOR_ROLES.contains(act.Team_Role__c) : false)){
        		set<Id> accTeamIds = accIdToAccTeamIds.containsKey(act.Account__c) ?
        					accIdToAccTeamIds.get(act.Account__c) :
        					new set<Id>();
		        accTeamIds.add(act.Team_Member__c);
		    	accIdToAccTeamIds.put(act.Account__c, accTeamIds);
        	}
        	
        }
        //Removing some of the sales team members that are already part of account team members
        if(!accIdToAccTeamIds.isEmpty())
        {
        	accountIdToUserIdMap = mapComparisonHelper(accIdToAccTeamIds, accountIdToUserIdMap);
        	/*for(Id AccountId:accIdToAccTeamIds.keySet())
        	{
        		if(accountIdToUserIdMap.containsKey(AccountId))
        		{
        			set<ID> accTeamIdsToRemove = accIdToAccTeamIds.get(AccountId);
        			set<Id> userIds = accountIdToUserIdMap.get(AccountId);	
        			userIds.removeAll(accTeamIdsToRemove);
        			accountIdToUserIdMap.put(AccountId, userIds);
        		}
        	}*/	
        }
        //accountToContactIdMap generates the contact Ids that needs to be shared to that account. 
        map<Id, set<Id>> accountToContactIdMap = new map<Id, set<Id>>();
        
        //If a sales team member is already owner of its parent account's contact
        // no need to add contact share for that member
        // this map helps to filter out those contact owners.
        //Also populating contactIds to share in this loop 
        map<Id, set<String>> contactOwnersToFilter = new map<Id, set<String>>();
        for(Contact_Relationship__c crt:[
                select Contact__c, Account__c, Account__r.OwnerId, Contact__r.OwnerId from Contact_Relationship__c 
                where Status__c = 'Active'
                and Account__c IN :accountIdToUserIdMap.keySet()
            ])
        {
            Id AccountId = crt.Account__c;
        	set<Id> contactIdSet = accountToContactIdMap.containsKey(AccountId) ? 
        						accountToContactIdMap.get(AccountId) : 
        						new set<Id>();
        	contactIdSet.add(crt.Contact__c);
        	accountToContactIdMap.put(AccountId, contactIdSet);	
        	
        	set<string> contactOwnerSet = contactOwnersToFilter.containsKey(AccountId) ?
		    							contactOwnersToFilter.get(AccountId):
		    							new set<string>();
	    	//this combination of owner and contactId will be useful when adding contact share
	    	contactOwnerSet.add((string)crt.Contact__c+(string)crt.Contact__r.OwnerId);
	    	contactOwnersToFilter.put(AccountId, contactOwnerSet);
        	
            //sharingObjectIds.add(crt.Contact__c);
            /*if(crt.Account__r.ownerId == crt.Contact__r.OwnerId)
            {
	        	set<Id> contactOwnerIds = accountTocontactOwnerIDMap.containsKey(AccountId) ? 
	        							  accountTocontactOwnerIDMap.get(AccountId) : 
	    								  new set<Id>();
	            contactOwnerIds.add(crt.Contact__r.OwnerId);
	            accountTocontactOwnerIDMap.put(AccountId, contactOwnerIds);
        	}
        	*/
        }
        // Removing the contact owners
       /* if(!accountTocontactOwnerIDMap.isEmpty())
        {
        	for(Id AccountId:accountTocontactOwnerIDMap.keySet())
        	{
        		if(accountIdToUserIdMap.containsKey(AccountId))
        		{
        			set<ID> ownerIdsToRemove = 	accountTocontactOwnerIDMap.get(AccountId);
        			set<Id> userIds = accountIdToUserIdMap.get(AccountId);	
        			userIds.removeAll(ownerIdsToRemove);
        			accountIdToUserIdMap.put(AccountId, userIds);
        		}
        		
        	}	
        }*/
        
        
        sharingResult sr = new sharingResult();
        sr.accIdToUserIdMap = accountIdToUserIdMap;
        sr.sharingIdMap = accountToContactIdMap;
        sr.ownerMapIdsToRemove = contactOwnersToFilter;
        //ALL_InsertContactShare_Helper.insertContactShare(accountToContactIdMap, accountIdToUserIdMap, true);
        return sr;
    }
    
    public static map<Id, set<Id>> retrieveUserIdsFromAccTeam(set<Id> accountIds)
    {
        map<Id, set<Id>> accIdToUserIdsMap = new map<Id, set<Id>>();
        for(Account_Team__c accTeam:[select Team_Member__c, Account__c, Sales_Roles__c,Team_Role__c from Account_Team__c where Account__c IN :accountIds])
        {
        	if(accTeam.Sales_Roles__c || (DIGITAL_ADVISOR_ROLES!=null ? DIGITAL_ADVISOR_ROLES.contains(accTeam.Team_Role__c) : false))
        	{
	    		set<Id> userIds = accIdToUserIdsMap.containsKey(accTeam.Account__c) ?
	    					  accIdToUserIdsMap.get(accTeam.Account__c) :
	    					  new set<Id>();
		        userIds.add(accTeam.Team_Member__c);
		        accIdToUserIdsMap.put(accTeam.Account__c, userIds);
        	}
        }
        map<Id, set<Id>> accIdToUserIdsFromSalesTeam = retrieveUserIdsFromSalesTeam(accountIds);
        for(Id AccountId:accIdToUserIdsMap.KeySet())
        {
        	if(accIdToUserIdsFromSalesTeam.containsKey(AccountId)){
        		set<Id> userIdsFromSalesTeam = accIdToUserIdsFromSalesTeam.get(AccountId);
        		set<Id> userIdsFromAccTeam = accIdToUserIdsMap.get(AccountId);
        		userIdsFromAccTeam.addAll(userIdsFromSalesTeam);
        		accIdToUserIdsMap.put(AccountId, userIdsFromAccTeam);
        	}	
        }
        return accIdToUserIdsMap;
        
    }
    public static map<Id, set<Id>> retrieveUserIdsFromSalesTeam(set<Id> accountIds)
    {
    	map<Id, set<Id>> accIdToUserIdMap = new map<Id, set<Id>>();
    	for(Sales_Team__c sls:[select Opportunity__r.AccountId, User__c 
    			from Sales_Team__c 
    			where Opportunity__r.AccountId IN:accountIds])
    	{
    		Id AccountId = sls.Opportunity__r.AccountId;
    		set<Id> userIds = accIdToUserIdMap.containsKey(AccountId) ? 
    						accIdToUserIdMap.get(AccountId) :
    						new set<Id>();
    		accIdToUserIdMap.put(AccountId, userIds);
    	}
    	return accIdToUserIdMap; 
    }
    
    
    public static void insertContactShare(map<Id, set<Id>> sharingObjectIdMap, map<Id,set<Id>> userOrGroupIdMap, 
    									  map<Id, set<string>> contactOwnerIdsToRemove, boolean fromSalesTeam)
    {
    	system.debug('------sharingObjectIdMap-------'+sharingObjectIdMap);
    	system.debug('------userOrGroupIdMap-------'+userOrGroupIdMap);
        string contactAccess = fromSalesTeam ? 'Read' : 'Edit';
        list<ContactShare> contactSharesToInsert = new list<ContactShare>();
        for(Id AccountId:sharingObjectIdMap.keySet())
        {
        	set<Id> contactIds = sharingObjectIdMap.get(AccountId);
        	set<Id> userOrGroupIds = userOrGroupIdMap.containsKey(AccountId) ?
        							userOrGroupIdMap.get(AccountId) :
        							null;
        	set<string> contactOwnerIds = contactOwnerIdsToRemove.containsKey(AccountId) ?
        							contactOwnerIdsToRemove.get(AccountId):
        							new set<string>();
        	
        	if(userOrGroupIds!=null)
        	{
        		for(Id recordId:contactIds)
		        {
		             for(Id uIdOrGroupId:userOrGroupIds)
		             {
		             	string contactID_OwnerId = (string)recordId+(string)uIdOrGroupId; 
		             	if(!contactOwnerIds.contains(contactID_OwnerId))
		             	{
		             		ContactShare conShare = new ContactShare();
			             	conShare.ContactId = recordId;
			             	conShare.UserOrGroupId = uIdOrGroupId;
			                conShare.ContactAccessLevel = contactAccess;
			             	conShare.RowCause = 'Manual';
			             	contactSharesToInsert.add(conShare);
		             	}
		             	
		             }
		         }
        	}
        	
        }
        
         system.debug('---sharedList-----'+contactSharesToInsert.size());
         
         Database.insert(contactSharesToInsert, false);
         //list<Database.saveResult> dsrList = Database.insert(sharedList, false);    
    } 
    
    public static void deleteContactShare(string filterName, set<Id> filterIds, string secondFilter, set<Id> secondFilterSet)
    {
        String query = 'select Id from ContactShare where RowCause =\'Manual\'';
        if(filterName!=null && filterName!='')
        {
            query +=  ' and '+ filterName + ' IN :filterIds';
        }
        if(secondFilter!=null && secondFilter!='')
        {
            query +=  ' and '+ secondFilter + ' IN :secondFilterSet';
        }
        list<ContactShare> retrievedList = Database.Query(query);
        Database.delete(retrievedList, false);
    }   
    
    public static map<Id, set<Id>> mapComparisonHelper(map<Id, set<Id>> sourceMap, map<Id, set<Id>> destinationMap)
    {
    	for(Id accountId:sourceMap.KeySet())
    	{
    		if(destinationMap.containsKey(accountId))
    		{
    			set<Id> destinationIds = destinationMap.get(accountId);
    			set<Id> sourceIdsToRemove = sourceMap.get(accountId);
    			destinationIds.removeAll(sourceIdsToRemove);
    			destinationMap.put(accountId, destinationIds);	
    		}	
    	}
    	return destinationMap;	
    }
    
    public class sharingResult
    {
        //public set<Id> sharingIds;
        //public set<Id> ownerIdsToRemove;
        public map<Id, set<Id>> sharingIdMap;
        public map<Id, set<string>> ownerMapIdsToRemove;
        public map<ID, set<Id>> accIdToUserIdMap;    
    }
    
}