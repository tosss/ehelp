/*-----------------------------------------------------------------
2016-04-26 -venkata.shrivol@cdk.com -Created 
Description: Trigger Handler for ALL_Contact_Relationshp.apxt
---------------------MODIFICATIONS----------------------------------
2016-05-19 vishal.bandari@cdk.com  - updated methods as per the request RQ-07014
2016-06-07 venkata.shrivol@cdk.com - additional logic to the methods for RQ-07157
2016-06-21 matt.keefe@cdk.com - added null checking
2016-06-22 venkata.shrivol@cdk.com - added other conditions for account update on contact
2016-06-27 venkata.shrivol@cdk.com - added apex sharing code in after -insert/update, before delete contexts RQ-06969
2017-01-11 -venkata.shrivol@cdk.com -added boolean parameter to insertContactShare method
2017-01-10  ragashalini.koka@cdk.com - Moved Email to Other_Email__c if no active Contact Relationships are found for RQ-08427
2017-02-27  ragashalini.koka@cdk.com - Added the method to inactivate CRs if the Accounts are marked as duplicate for RQ-08685
2017-04-06  ragashalini.koka@cdk.com - Merged code with updateCasePhones changes
2017-04-07 -venkata.shrivol@cdk.com	-changed the contact share logic in after insert, update and before delete methods (RQ-08999)
2017-04-04 - Siva.Pragada@cdk.com - Made chagnges for RQ-08782 For CTI, Case "Contact Phone" Field Needs to be a "Phone" Type
2017-04-27 - lalitha.adduru@cdk.com - enable Data Librarians ro delete CR during account merge without validation exception - RQ-08869
-------------------------------------------------------------------*/

public class ALL_Contact_Relationship_Handler 
{
    public static void beforeUpdate(list<Contact_Relationship__c> newList, map<Id, Contact_Relationship__c> oldMap)
    {
        Map<ID, String> crIdToPhone = new Map<ID, String>();
        for(Contact_Relationship__c nc:newList)
        {
            Contact_Relationship__c oldCrt = oldMap.get(nc.Id) ;
            if(nc.Phone__c != oldCrt.Phone__c)
            {
                crIdToPhone.put(nc.ID, nc.Phone__c);
            }
            if(oldCrt != null) 
            {
                if(oldCrt.Status__c != nc.Status__c || oldCrt.No_Longer_There__c != nc.No_Longer_There__c)
                {
                    if(oldCrt.Status__c != nc.Status__c)
                    {
                        nc.No_Longer_There__c = nc.Status__c == 'Inactive' ? true : false;
                    }
                    else
                    {
                        nc.Status__c = nc.No_Longer_There__c ? 'Inactive' : 'Active';
                    }
                }
                //2016-05-24 -venkata.shrivol@cdk.com -If the account is updatable on CR, uncomment this.  
                /*if(nc.Account__c != oldCrt.Account__c)
				{
				nc.Account__c = (String)nc.Account__c + (String)nc.Contact__c;
				}*/
            }
        }
        
        //2017-04-24 - Siva.Pragada@cdk.com - added asynchronous check.
        boolean notAsynchronous = !system.isBatch() && !system.isFuture() && !system.isQueueable() && !system.isScheduled();
        
        if(notAsynchronous)
        {
            updateCasePhones(crIdToPhone);
        }
    }
    
    @future
    public static void updateCasePhones(Map<ID, String> crIdToPhone)
    {            
        List<Case> crCases = new List<Case>([
            Select ID, Contact_Name_Relationship__c // filter for recordtype and also status. add as much as filtering
            From Case
            Where Contact_Name_Relationship__c IN :crIdToPhone.keySet() AND (NOT (Status LIKE '%Closed%'))
            
        ]);
        
        List<Case> updateCases = new List<Case>();
        
        if(!crCases.isEmpty())
        {
            for(Case currentCase: crCases)
            {
                ID caseCrId = currentCase.Contact_Name_Relationship__c;
                currentCase.Contact_Relationship_Phone__c = crIdToPhone.get(caseCrId);
                updateCases.add(currentCase);
            }
        }
        
        update updateCases;
    }

    public static void afterInsert(list<Contact_Relationship__c> contactRelationshipList)
    {        
        
        //2016-05-19 vishal.bandari@cdk.com - updated method as per the request RQ-07014
        if(ALL_CheckRecursive.runCodeBlockOnce('ALL_Contact_Relationship_Handler_afterInsert') || Test.isRunningTest())
        {
            //2016-06-27 -venkata.shrivol@cdk.com -added this below set of Ids for apex sharing
            //set<Id> activeAccountIds = new set<Id>();
            //set<Id> activeContactIds = new set<Id>();
            //set<Id> ownerIds = new set<Id>();
            map<Id, set<Id>> accountIdToContactIds = new map<Id, set<Id>>();
            map<Id, set<string>> accountIdToContactOwnerIds = new map<Id, set<string>>();
            
            try
            {
                Set<Id> accountIds = new Set<Id>();
                map<Id, set<String>> contactToRoleMap = new map<Id, set<String>>();
                map<Id, Id> contactToAccountMap = new map<Id,Id>();
                for(Contact_Relationship__c contactRelationshipObj :  [select Id,Account__c,Contact__c, Status__c, Role__c, 
                                                                     contact__r.AccountId, contact__r.ownerId 
                                                                     from Contact_Relationship__c 
                                                                     where Id IN :contactRelationshipList])
                {
                    accountIds.add(contactRelationshipObj.Account__c);
                    contactToAccountMap.put(contactRelationshipObj.Contact__c, contactRelationshipObj.Account__c);
                    
                    if(contactRelationshipObj.Status__c == 'Active')
                    { 
                        if(contactRelationshipObj.Role__c!=null)
                        {
                            set<String> roleSet = contactToRoleMap.get(contactRelationshipObj.Contact__c) !=null ? 
                                contactToRoleMap.get(contactRelationshipObj.Contact__c) : new set<String>();
                            roleSet.addAll(contactRelationshipObj.Role__c.split(';[ ]*'));
                            contactToRoleMap.put(contactRelationshipObj.Contact__c, roleSet);	
                            system.debug('---roleSet----'+roleSet.size());
                        }
                        if(contactRelationshipObj.Account__c != contactRelationshipObj.contact__r.AccountId )
                        {
                            Id AccountId = contactRelationshipObj.Account__c;
                            set<Id> contactIds = accountIdToContactIds.containsKey(AccountId) ? 
                        					 accountIdToContactIds.get(AccountId) :
                        					 new set<Id>();
                            contactIds.add(contactRelationshipObj.Contact__c);
                            accountIdToContactIds.put(AccountId, contactIds);
                            
                            set<string> contact_OwnerIds = accountIdToContactOwnerIds.containsKey(AccountId) ? 
                            							   accountIdToContactOwnerIds.get(AccountId):
                            							   new set<string>();
                            contact_OwnerIds.add((string)contactRelationshipObj.Contact__c+(string)contactRelationshipObj.Contact__r.OwnerId);
							accountIdToContactOwnerIds.put(AccountId, contact_OwnerIds);                           
                        }
                    }
                    else if(!contactToRoleMap.containsKey(contactRelationshipObj.Contact__c))
                    {
                        contactToRoleMap.put(contactRelationshipObj.Contact__c, new set<String>()); 
                    }
                    
                }
                
                
                Map<Id,Id> topAcountIdsMap  = AccountHierarchyTools.TopParentAccountIdsByAccountId(new List<Id>(accountIds));
                System.debug('topAccountIdsMap : ' + topAcountIdsMap);
                Map<Id,Contact> contactMap = new Map<Id,Contact>();
                
                //2016-06-13 -venkata.shrivol@cdk.com -commented this code as this was being done in below for-loop
                /*for(Contact_Relationship__c contactRelationshipObj : contactRelationshipList)
					{
					Contact contactObj = new Contact();
					contactObj.Id = contactRelationshipObj.Contact__c;
					contactObj.Dealer_Group__c = topAcountIdsMap.get(contactRelationshipObj.Account__c);
					contactObj.accountId = contactRelationshipObj.Account__c;
					
					contactMap.put(contactObj.Id,contactObj);
					}*/
                 Map<Id,Integer> contactIdToActiveCRCountMap = getContactToActiveCRCount(contactToRoleMap.keySet());
                System.debug('contactIdToActiveCRCountMap : ' + contactIdToActiveCRCountMap);
                for(Contact con: [select Consolidated_Roles__c,Count_of_Contact_Relationships__c,OwnerId,
                                  Count_of_Active_Contact_Relationsips__c, AccountId, Email, Other_Email__c 
                                  from Contact  
                                  where Id IN:contactToRoleMap.keySet()
                                 ])
                {
                    
                    string roleValue = '';
                    set<string> existingValues = new set<String>();
                    if(con.Consolidated_Roles__c!=null && con.Consolidated_Roles__c!='')
                    {
                        existingValues.addAll(con.Consolidated_Roles__c.split(';[ ]*'));
                    }
                    existingValues.addAll(contactToRoleMap.get(con.Id));
                    list<String> listToSort = new list<String>(existingValues);
                    listToSort.sort();
                    roleValue = String.join(listToSort, '; ');
                    con.Consolidated_Roles__c = roleValue;
                    con.Title = roleValue.length() > 128 ? roleValue.substring(0,126)+'…' : roleValue;
                    con.Dealer_Group__c = topAcountIdsMap.get(contactToAccountMap.get(con.Id));
                    System.debug('dealer Group' +  con.Dealer_Group__c);
                    if(con.accountId == null || con.Count_of_Contact_Relationships__c == 0 || con.Count_of_Active_Contact_Relationsips__c == 0)
                    {
                        con.accountId = contactToAccountMap.get(con.Id);    
                        
                        
                    } 
                    if(!contactIdToActiveCRCountMap.containsKey(con.Id)) {
                        if(con.Email != null) {
                            con.Other_Email__c = con.Email;
                            con.Email = null;
                        }
                        con.Status__c = 'Inactive';
                        
                    }
                    else if(contactIdToActiveCRCountMap.containsKey(con.Id)) {
                        if(con.Other_Email__c != null) {
                            con.Email = con.Other_Email__c;
                            con.Other_Email__c = null;
                        }
                        con.Status__c = 'Active';
                    }
                    
                    
                    contactMap.put(con.Id,con);
                    /*set<Id> ownerIds = accountIdToContactOwnerIds.containsKey(con.AccountId) ?
                    					accountIdToContactOwnerIds.get(con.AccountId):
                    					new set<Id>();
                    ownerIds.add(con.OwnerId);
                    accountIdToContactOwnerIds.put(con.AccountId, ownerIds);*/
                }
                System.debug('contact values insert :' + contactMap.values());
                update contactMap.values();
            }
            catch(Exception e)
            {
                ALL_UtilitiesMiscellaneous.logException(e);
                System.debug('Exception : '+e.getMessage()+' at '+e.getLineNumber());
            }
            
            //2016-06-27 -venkata.shrivol@cdk.com -apex sharing code on contacts
            if(!accountIdToContactIds.isEmpty())
            {
                map<Id, set<Id>> accountIdToUserIdMap = ALL_InsertContactShare_Helper.retrieveUserIdsFromAccTeam(accountIdToContactIds.KeySet());
                //userIds.removeAll(ownerIds);
                //accountIdToUserIdMap = ALL_InsertContactShare_Helper.mapComparisonHelper(accountIdToContactOwnerIds, accountIdToUserIdMap);
                ALL_InsertContactShare_Helper.insertContactShare(accountIdToContactIds, accountIdToUserIdMap, accountIdToContactOwnerIds, false);
                //2017-01-11 -venkata.shrivol@cdk.com -added boolean parameter to insertContactShare method
                //ALL_InsertContactShare_Helper.insertContactShare(activeContactIds, userIds, false);
            }
            
        }
    } 
    
    //2016-05-19 vishal.bandari@cdk.com - added below method as per the request RQ-07014
    
    public static void afterUpdate(list<Contact_Relationship__c> newList, map<Id, Contact_Relationship__c> oldMap)
    { 
        system.debug('in after update start');
        if(ALL_CheckRecursive.runCodeBlockOnce('ALL_Contact_Relationship_Handler_afterUpdate') || Test.isRunningTest())
        {
            try
            {
                Set<Id> contactIds = new Set<Id>();
                
                Set<Id> accountIds = new Set<Id>();
                
                Map<Id,Contact> impactedContacts = new Map<Id,Contact>();
                
                map<Id, set<string>> relatedContactToRoleMap = new map<Id, set<String>>();
                
                //2016-06-27 -venkata.shrivol@cdk.com -added this below set of Ids for apex sharing
                set<Id> inactivatedAccountIds = new set<Id>();
                //set<Id> activatedAccountIds = new set<Id>();
                set<Id> inactivatedContactIds = new set<Id>();
                //set<Id> activatedContactIds = new set<Id>();
                //set<Id> inactivatedOwnerIds = new set<Id>();
                //set<Id> activatedOwnerIds = new set<Id>();
               
                map<Id, set<Id>> activatedAccIdToConIds = new map<Id, set<Id>>();
                map<Id, set<string>> activatedAccIdToOwnerIds = new map<Id, set<string>>();
                
                //fetching  for ConatctIds and AccountIds records
                for(Contact_Relationship__c contactRelationshipObj : newList)
                {
                    contactIds.add(contactRelationshipObj.Contact__c);
                    accountIds.add(contactRelationshipObj.Account__c);
                }
                
                //Fetching Contacts of Contact_RelationShip__c
                impactedContacts = new Map<Id,Contact>([SELECT Id, OwnerId, Dealer_Group__c,AccountId, Consolidated_Roles__c,
                                                        Count_of_Active_Contact_Relationsips__c, Email, Other_Email__c
                                                        from Contact where Id In: contactIds]);
                
                //Fetching Other related Contact_RelationShip__c under impactedContacts
                List<Contact_Relationship__c> relatedContactRelationShip = [
                    Select Id,Contact__c, Account__c, Role__c 
                    from Contact_Relationship__c 
                    where Contact__c In:contactIds 
                    and Status__c = 'Active' 
                    Order by LastModifiedDate desc
                ];
                
                List<Id> allImpactedAccountIds = new List<Id>();
                
                allImpactedAccountIds.addAll(accountIds);
                
                Map<Id, Contact_Relationship__c> contactId_To_ContactRelationShipMap = new Map<Id, Contact_Relationship__c>();
                
                for(Contact_Relationship__c contactRelationshipObj : relatedContactRelationShip)
                {
                    allImpactedAccountIds.add(contactRelationshipObj.Account__c);
                    
                    //Boolean check to change Contact based on recently Modified Contact_RelationShip__c record under that Contact
                    if(!contactId_To_ContactRelationShipMap.containsKey(contactRelationshipObj.Contact__c))
                    {
                        contactId_To_ContactRelationShipMap.put(contactRelationshipObj.Contact__c,contactRelationshipObj);
                    }
                    if(contactRelationshipObj.Role__c!=null)
                    {
                        set<String> roleSet = relatedContactToRoleMap.get(contactRelationshipObj.Contact__c) !=null ? 
                            relatedContactToRoleMap.get(contactRelationshipObj.Contact__c) : new set<String>();
                        roleSet.addAll(contactRelationshipObj.Role__c.split(';[ ]*'));
                        System.debug('role set : ' + contactRelationshipObj.Role__c.split(';[ ]*'));
                        relatedContactToRoleMap.put(contactRelationshipObj.Contact__c, roleSet);	
                    }
                }
                System.debug('contactId_To_ContactRelationShipMap : ' + contactId_To_ContactRelationShipMap);
                Map<Id,Id> topAccountIdsMap;
                
                //Fetching Top Most AccountIds in hierarchy of impactedAccounts
                if(allImpactedAccountIds.size() > 0)
                {
                    topAccountIdsMap =  AccountHierarchyTools.TopParentAccountIdsByAccountId(allImpactedAccountIds);
                }
                System.debug('topAccountIdsMap : ' + topAccountIdsMap);
                
                Map<Id,Contact> contactsToChange = new Map<Id,Contact>();
                
                for(Contact_Relationship__c contactRelationshipObj : newList)
                {
                    
                    //Boolean check to change Contact based on recently Modified Contact_RelationShip__c record under that Contact
                    if(!contactsToChange.containsKey(contactRelationshipObj.Contact__c))
                    {
                    	//2017-04-14 -venkata.shrivol@cdk.com -added this contact variable as a part of code clean-up
                    	Contact parentContact = impactedContacts.get(contactRelationshipObj.Contact__c) != null ?
                        						impactedContacts.get(contactRelationshipObj.Contact__c):
                        						new Contact();
                        							
                        
                        Contact contactObj = new Contact();
                        contactObj.Id = contactRelationshipObj.Contact__c;
                        contactObj.Status__c = 'Active';
                        
                        Boolean contactUpdated = false;
                        
                        //If Contact_Relationship record is inactivated
                        if( contactRelationshipObj.Status__c == 'Inactive' && ( contactRelationshipObj.Status__c != oldMap.get(contactRelationshipObj.Id).Status__c))
                        {
                            //if there are no other Active Contact_Relationship__c under that Contact Deal_Group__C is null.
                            if(contactId_To_ContactRelationShipMap.get(contactRelationshipObj.Contact__c)== null)
                            {     
                                System.debug('after update no active contact relationships');
                                contactObj.Status__c = 'Inactive';
                                contactObj.Dealer_Group__c = null;
                                contactObj.Role__c = null;
                                //2017-01-10  ragashalini.koka@cdk.com - Added this condition for RQ-08427
                                if(parentContact.Email != null ) {
                                    contactObj.Other_Email__c = parentContact.Email;
                                    contactObj.Email = null;
                                    
                                }
                                contactUpdated = true;
                                
                            }
                            
                            //Change Contact's AccountId if Contact_RelationShip AccountId match with its AccountId and there are other Active Contact_Relationship__c under that Contact.
                            else 
                            {
                                
                                if(parentContact.AccountId == contactRelationshipObj.Account__c )
                                {
                                    contactObj.AccountId = contactId_To_ContactRelationShipMap.get(contactRelationshipObj.Contact__c).Account__c;
                                    //contactUpdated = true;
                                }
                                
                                //If Inactivating Contact_RelationShip Object has impacted Dealer_Group__c on its Contact, 
                                //then change it as per last updated Contact_Relationship Object under that Contact
                                if(parentContact.Dealer_Group__c == topAccountIdsMap.get(contactRelationshipObj.Account__c))
                                {
                                    contactObj.Dealer_Group__c = topAccountIdsMap.get(contactId_To_ContactRelationShipMap.get(contactRelationshipObj.Contact__c).Account__c);
                                    //contactUpdated = true;
                                }
                                
                                
                                set<String> existingRoles = new set<String>();
                                
                                if(parentContact.Consolidated_Roles__c!=null)
                                {
                                    existingRoles.addAll(new list<String>((parentContact.Consolidated_Roles__c).split(';[ ]*')));	
                                }
                                if(contactRelationshipObj.Role__c !=null){
                                    existingRoles.removeAll((contactRelationshipObj.Role__c).split(';[ ]*'));	
                                }
                                if(relatedContactToRoleMap.get(contactRelationshipObj.Contact__c)!=null)
                                {
                                    existingRoles.addAll(relatedContactToRoleMap.get(contactRelationshipObj.Contact__c));
                                }
                                list<String> listToSort = new list<String>(existingRoles);
                                listToSort.sort();
                                string roleValue = String.join(listToSort, '; ');
                                contactObj.Title = roleValue.length() > 128 ? roleValue.substring(0,126)+'…' : roleValue;
                                system.debug('----roleValue---->'+roleValue);
                                contactObj.Consolidated_Roles__c = roleValue;
                                
                                contactUpdated = true;
                            }
                            
                            inactivatedAccountIds.add(contactRelationshipObj.Account__c);
                            inactivatedContactIds.add(contactRelationshipObj.Contact__c);
                            
                        }
                        //If  Contact_Relationship record is activated
                        else if(contactRelationshipObj.Status__c == 'Active' && ( contactRelationshipObj.Status__c != oldMap.get(contactRelationshipObj.Id).Status__c))
                        {
                        	
                            //2016-06-22 venkata.shrivol@cdk.com - added this if block to update contact's account only at certain times
                            if(parentContact.Count_of_Active_Contact_Relationsips__c == 0)
                            {
                                contactObj.AccountId = contactId_To_ContactRelationShipMap.get(contactRelationshipObj.Contact__c).Account__c;	
                                
                            }
                            contactObj.Dealer_Group__c = topAccountIdsMap.get(contactRelationshipObj.Account__c);
                            
                            
                            set<String> rolesToManipulate = new set<String>();
                            if(parentContact.Consolidated_Roles__c!=null)
                            {
                                rolesToManipulate.addAll(new list<String>((parentContact.Consolidated_Roles__c).split(';[ ]*')));
                            }
                            if(contactRelationshipObj.Role__c !=null)
                            {
                                rolesToManipulate.addAll(new list<String>((contactRelationshipObj.Role__c).split(';[ ]*')));	
                            }
                            list<String> listToSort = new list<String>(rolesToManipulate);
                            listToSort.sort();
                            string roleValue = String.join(listToSort, '; ');
                            contactObj.Title = roleValue.length() > 128 ? roleValue.substring(0,126)+'…' : roleValue;
                            contactObj.Consolidated_Roles__c = roleValue;	
                            //2017-01-12  ragashalini.koka@cdk.com - Added this condition for RQ-08427
                            if(parentContact.Email == null && parentContact.Other_Email__c != null) 
                            {
                            	contactObj.Email = parentContact.Other_Email__c;
                                contactObj.Other_Email__c = null;
                            }
                            contactObj.Status__c = 'Active';
                            contactUpdated = true;
                            
                            if(contactRelationshipObj.Account__c != parentContact.AccountId)
                            {
                            	Id AccountId = contactRelationshipObj.Account__c;
	                        	set<Id> contactIdSet = activatedAccIdToConIds.containsKey(AccountId) ?
	                        					activatedAccIdToConIds.get(AccountId) :
	                        					new set<Id>();	
		                        contactIdSet.add(contactRelationshipObj.Contact__c);	
		                        activatedAccIdToConIds.put(contactRelationshipObj.Account__c, contactIdSet);
		                        
		                        set<string> contactOwnerSet = activatedAccIdToOwnerIds.containsKey(AccountId) ?
		                        							  activatedAccIdToOwnerIds.get(AccountId):
		                        							  new set<string>();
		                        
		                        contactOwnerSet.add((string)parentContact.Id+(string)parentContact.OwnerID);
		                        activatedAccIdToOwnerIds.put(AccountId, contactOwnerSet);
                            }
                            
                            				
                            
                        }
                        
                        //Not used righ now so commented, please don't delete commented section, can be used in future
                        //If AccountId of Contact_Relationship record is updated - 
                        /* else if(contactRelationshipObj.Account__c != oldMap.get(contactRelationshipObj.Id).Account__c )
						{
						//update AccountId only if Contact AccountId and Contact_Relationship Account__c were equal before update and not equal after update
						if(impactedContacts.get(contactRelationshipObj.Contact__c).AccountId == oldMap.get(contactRelationshipObj.Id).Account__c)
						{
						contactObj.AccountId = contactRelationshipObj.Account__c;
						contactUpdated = true;
						}
						
						//update Dealer_Group__c only if Contact Dealer_Group__c and Contact_Relationship top Hierarcy of Account__c were equal before update and not equal after update
						if(impactedContacts.get(contactRelationshipObj.Contact__c).Dealer_Group__c != topAccountIdsMap.get(contactRelationshipObj.Account__c))
						{
						contactObj.Dealer_Group__c = topAccountIdsMap.get(crObj.Account__c);
						contactUpdated = true;
						}      
						}*/
                        
                        if(
                            (contactRelationshipObj.Role__c != oldMap.get(contactRelationshipObj.Id).Role__c) && 
                            (contactRelationshipObj.Status__c == oldMap.get(contactRelationshipObj.Id).Status__c)
                        )
                        {
                            
                            set<String> rolesToManipulate = new set<String>();
                            rolesToManipulate.addAll(relatedContactToRoleMap.get(contactRelationshipObj.Contact__c));
                            
                            if(contactRelationshipObj.Role__c !=null)
                            {
                                rolesToManipulate.addAll(new list<String>((contactRelationshipObj.Role__c).split(';[ ]*')));	
                            }
                            
                            list<String> listToSort = new list<String>(rolesToManipulate);
                            listToSort.sort();
                            
                            string roleValue = String.join(listToSort, '; ');
                            contactObj.Consolidated_Roles__c = roleValue;	
                            contactObj.Title = roleValue.length() > 128 ? roleValue.substring(0,126)+'…' : roleValue;
                            contactUpdated = true;                  		
                        }
                        
                        
                        //Add to map only if Contact got updated
                        if(contactUpdated)
                        {
                            contactsToChange.put(contactObj.Id,contactObj);
                            System.debug('contactsToChange :' + contactsToChange);
                        }
                    }
                }
                
                if(contactsToChange.size() > 0)
                {
                    System.debug('contactsToChange : ' + contactsToChange.values());
                    update contactsToChange.values();
                }
                
                if(!inactivatedAccountIds.isEmpty())
                {
                    system.debug('------Active Check 3');
                    map<Id, set<Id>> accountIdToUserIds = ALL_InsertContactShare_Helper.retrieveUserIdsFromAccTeam(inactivatedAccountIds);
                    //userIds.removeAll(inactivatedOwnerIds);
                    set<Id> userIds = new set<Id>();
                    for(Id AccountId:accountIdToUserIds.keySet()){
                    	userIds.addAll(accountIdToUserIds.get(AccountId));
                    }
                    ALL_InsertContactShare_Helper.deleteContactShare('UserOrGroupId',userIds,'ContactId',inactivatedContactIds);
                }
                if(!activatedAccIdToConIds.isEmpty())
                {
                    map<Id,set<Id>> accIdToUserIdMap = ALL_InsertContactShare_Helper.retrieveUserIdsFromAccTeam(activatedAccIdToConIds.keySet());
                    //accIdToUserIdMap = ALL_InsertContactShare_Helper.mapComparisonHelper(activatedAccIdToOwnerIds, accIdToUserIdMap);
                	
                    //2017-01-11 -venkata.shrivol@cdk.com -added boolean parameter to insertContactShare method
                    ALL_InsertContactShare_Helper.insertContactShare(activatedAccIdToConIds, accIdToUserIdMap, activatedAccIdToOwnerIds, false);
                }
                
            }
            catch(Exception e)
            {
                System.debug('Exception : '+e.getMessage()+' at '+e.getLineNumber());
                ALL_UtilitiesMiscellaneous.logException(e);
            }
        }
        system.debug('in after update end');
    }
    
    public static void beforeDelete(list<Contact_Relationship__c> oldList)
    {
        String profileName = [
            SELECT Id, Name
            FROM Profile WHERE Id=:UserInfo.getProfileId()
        ][0].Name;
        
        list<Contact_Relationship__c> relationshipRecords = new list<Contact_Relationship__c>();
        map<Id,set<String>> contactToRolesMap = new map<Id, set<String>>();
        set<Id> deletingRelationshipIds = new set<Id>();
        
        set<Id> activeAccountIds = new set<Id>();
        set<Id> activeContactIds = new set<Id>();
        set<Id> ownerIds = new set<Id>();
                
        for(Contact_Relationship__c contactRelationshipObj:
            [select Authorized_Contract_Signer__c, Status__c, Contact__r.OwnerId, Role__c, Contact__c, Account__c, Id 
             from Contact_Relationship__c
             where Id IN: Trigger.Old
            ])
        {
            if(contactRelationshipObj.Authorized_Contract_Signer__c == true && profileName != 'ADPDS - Admin - Data Librarian')
            {
                contactRelationshipObj.addError('ERROR: Contacts designated as Authorized Contract Signers can not be deleted!');    
            }
            if(contactRelationshipObj.Status__c == 'Active')
            {
                if(contactRelationshipObj.Role__c!=null)
                {
                    set<String> roleSet = contactToRolesMap.get(contactRelationshipObj.Contact__c) !=null ? 
                        contactToRolesMap.get(contactRelationshipObj.Contact__c) : new set<String>();
                    
                    roleSet.addAll(contactRelationshipObj.Role__c.split(';[ ]*'));
                    system.debug('------>'+roleSet.size());
                    contactToRolesMap.put(contactRelationshipObj.Contact__c, roleSet);
                }
                activeAccountIds.add(contactRelationshipObj.Account__c);
                activeContactIds.add(contactRelationshipObj.Contact__c);
                //ownerIds.add(contactRelationshipObj.Contact__r.OwnerId);
            }
            else
            {
                contactToRolesMap.put(contactRelationshipObj.Contact__c, new set<String>());          		
            }
            deletingRelationshipIds.add(contactRelationshipObj.Id);
        }
        
        if(!contactToRolesMap.isEmpty())
        {
            clearConsolidateRolesOnContact(contactToRolesMap, deletingRelationshipIds);	
        }
        
        if(!activeAccountIds.isEmpty())
        {
            map<Id, set<Id>> accountIdToUserIds = ALL_InsertContactShare_Helper.retrieveUserIdsFromAccTeam(activeAccountIds);
            //userIds.removeAll(ownerIds);
            set<Id> userIds = new set<Id>();
            for(Id AccountId:accountIdToUserIds.KeySet()){
            	userIds.addAll(accountIdToUserIds.get(AccountId));
            }
            ALL_InsertContactShare_Helper.deleteContactShare('UserOrGroupId',userIds,'ContactId',activeContactIds);
        }
        
    }
    
    public static void clearConsolidateRolesOnContact(map<Id, set<String>> contactToRoleMap, set<Id> deletingRelationshipIds)
    {
        list<Contact> contactsToUpdate = new list<Contact>();
        map<Id, set<String>> existingContactToRoleMap = new map<Id, set<String>>();
        set<Id> accountIds = new set<Id>();
        map<Id, Id> topAccountIdsMap = new map<Id,Id>();
        map<Id,Id> contactToAccountMap = new map<Id,Id>();
        map<Id,Id> inactiveChildMap = new map<Id,Id>(); // contact to accountMapping
        
        for(Contact_Relationship__c crt:[
            select Id, Role__c, Contact__c, Account__c, Status__c 
            from Contact_Relationship__c 
            where Contact__c IN:contactToRoleMap.keySet()
            and Id NOT IN: deletingRelationshipIds])
        {
            if(crt.Status__c == 'Active')
            {
                if(crt.Role__c != null)
                {
                    set<String> roleSet = existingContactToRoleMap.get(crt.Contact__c) !=null ? 
                        existingContactToRoleMap.get(crt.Contact__c) : new set<String>();
                    
                    roleSet.addAll(crt.Role__c.split(';[ ]*'));
                    existingContactToRoleMap.put(crt.Contact__c, roleSet);	
                }
                contactToAccountMap.put(crt.Contact__c, crt.Account__c);
                accountIds.add(crt.Account__c);
            }
            else
            {
                inactiveChildMap.put(crt.Contact__c, crt.Account__c);
            }
        }
        
        if(!accountIds.isEmpty())
        {
            topAccountIdsMap =  AccountHierarchyTools.TopParentAccountIdsByAccountId(new list<Id>(accountIds));
        }
        
        // 2016-06-21 matt.keefe@cdk.com - formatted code
        for(Contact con : [
            select Consolidated_Roles__c, Dealer_Group__c, Status__c, Email, Other_Email__c
            from Contact 
            where Id IN : contactToRoleMap.keySet()])
        {
            if(con.Id != null && con.Consolidated_Roles__c != null)
            {
                set<String> existingValues = new set<String>();
                existingValues.addAll(con.Consolidated_Roles__c.split('; '));
                
                // 2016-06-21 matt.keefe@cdk.com - added null check
                if(contactToRoleMap.get(con.Id) != null) { 
                    existingValues.removeAll(contactToRoleMap.get(con.Id)); }
                
                // 2016-06-21 matt.keefe@cdk.com - added null check
                if(existingContactToRoleMap.get(con.Id) != null) {
                    existingValues.addAll(existingContactToRoleMap.get(con.Id)); }
                
                list<String> sortedExistingValues = new list<String>(existingValues);
                sortedExistingValues.sort();
                
                string concatenatedRoles = String.join(sortedExistingValues, '; ');
                con.Consolidated_Roles__c = concatenatedRoles;	
                
                con.Title = concatenatedRoles.length() > 128 ? concatenatedRoles.substring(0,126)+'…' : concatenatedRoles;
            }
            //2016-06-22 venkata.shrivol@cdk.com - added this code to update contact's account 
            con.Dealer_Group__c = topAccountIdsMap.get(contactToAccountMap.get(con.Id));
            if(contactToAccountMap.get(con.Id) !=null)
            {
                con.AccountId = contactToAccountMap.get(con.Id);	
            }
            else if(inactiveChildMap.get(con.Id) !=null)
            {
                con.AccountId = inactiveChildMap.get(con.Id);	
            }
            
            if(!contactToAccountMap.containsKey(con.Id) && !inactiveChildMap.containsKey(con.Id)  ) {
                if(con.Email != null) {
                    con.Other_Email__c = con.Email;
                    con.Email = null;
                }
                con.Status__c = 'Inactive';
            }
            
            contactsToUpdate.add(con);
        }
        System.debug('contacts delete :' + contactsToUpdate);
        update contactsToUpdate;
    }
    
    public static void afterDelete(List<Contact_Relationship__c> crList) {
        Set<Id> allContactIdSet = new Set<Id>();
        for(Contact_Relationship__c cr : crList) {
            allContactIdSet.add(cr.Contact__c);
        }
        //System.debug('allContactIdSet : ' + allContactIdSet);
        List<AggregateResult> activeContactRelationList = [
            SELECT Contact__c,count(Id) CRCount 
            FROM Contact_Relationship__c 
            WHERE Contact__c IN :allContactIdSet AND Status__c = 'Active'
            GROUP BY Contact__c];
        Map<Id,Integer> contactIdToActiveCRCountMap = getContactToActiveCRCount(allContactIdSet);
        
         Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Email FROM Contact WHERE Id IN :allContactIdSet AND Email!=null]);
        List<Contact> contactList = new List<Contact>();
        for(Id conId : allContactIdSet) {
            if(!contactIdToActiveCRCountMap.containsKey(conId)) {
                Contact con = new Contact();
                con.Id = conId;
                con.Status__c = 'Inactive';
                if(contactMap.containsKey(conId)) {
                    con.Other_Email__c = contactMap.get(conId).Email;
                    con.Email = null;
                }
                contactList.add(con);
            }
        }
        System.debug('delete contact list :' + contactList);
        if(contactList.size() > 0) {
            update contactList;
        } 
    }
    
    private static  Map<Id,Integer> getContactToActiveCRCount(Set<Id> contactIdSet) {
        List<AggregateResult> activeContactRelationList = [
            SELECT Contact__c, count(Id) CRCount
            FROM Contact_Relationship__c 
            WHERE Contact__c IN :contactIdSet AND Status__c = 'Active'
            GROUP BY Contact__c];
       
        Map<Id,Integer> contactIdToActiveCRCountMap = new Map<Id,Integer>();
        if(activeContactRelationList.size() > 0) {
            for(AggregateResult aggRes : activeContactRelationList) {
                contactIdToActiveCRCountMap.put(String.valueOf(aggRes.get('Contact__c')), Integer.valueOf(String.valueOf(aggRes.get('CRCount'))));
            }
        }
        return contactIdToActiveCRCountMap;
    }
    
    //2017-02-27  ragashalini.koka@cdk.com - Added the method to inactivate CRs if the Accounts are marked as duplicate for RQ-08685
    public static void updateCRStatusOfDuplicateAccounts(Map<Id,Contact_Relationship__c> oldMap, List<Contact_Relationship__c> newList) {
        if(ALL_CheckRecursive.runCodeBlockOnce('ALL_Contact_Relationship_Handler_duplicateCheck') || Test.isRunningTest()) {
            Set<Id> accIdSet = new Set<Id>();
            for(Contact_Relationship__c cr : newList) {
                if(cr.Status__c == 'Active' && (oldMap == null || (oldMap.get(cr.Id).Status__c != cr.Status__c))) {
                    accIdSet.add(cr.Account__c);
                }
            }
            
            Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id FROM Account WHERE Duplicate__c = true AND Id IN :accIdSet]);
            for(Contact_Relationship__c cr : newList) {
                if(cr.Status__c == 'Active' && accMap.containsKey(cr.Account__c)) {
                    cr.Authorized_Contract_Signer__c = false;
                    cr.Status__c = 'Inactive'; 
                }
            }
            System.debug('crList after ---' + newList);
        }
    }
}