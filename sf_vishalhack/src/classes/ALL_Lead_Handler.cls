//2017-01-30 - lalitha.adduru@cdk.com - creaed this handler class to contain the logic for trigger ALL_Lead - RQ-06389
public class ALL_Lead_Handler 
{
    GlobalSettings__c globalSettings = GlobalSettings__c.getInstance();
    String MgrMgrExcludeRoles = globalSettings.Lead_Owner_Mgrs_Mgr_Roles_to_Exclude__c;
    
    //2017-01-31 lalitha.adduru@cdk.com to fetch pardot and non pardot leads RQ-06389	
    //"Pardot"-->List<Lead> leadsFromPardot, "NotPardot"-->List<Lead> leadsNotFromPardot
   /* public Map<String,Set<Lead>> fetchPardotNonPardotLeadsMap(List<Lead> leadList)
    {
        Map<String,Set<Lead>> pardotNonPardotLeadsMap = new Map<String,Set<Lead>>();
        Set<Id> recordTypeIdSet = new Set<Id>();
        for(Lead newLead : leadList)
        {
            if(newLead.recordTypeId != null)
            {
                recordTypeIdSet.add(newLead.recordTypeId);
            }
        }
        
        Map<Id,recordType> recordTypeToNameMap = new Map<Id,recordType>([SELECT id, name FROM recordType WHERE id in :recordTypeIdSet]);
        
        for(Lead newLead : LeadList)
        {
            String CreatedByEmail = userinfo.getuseremail() == null ? '' : userinfo.getuseremail(); // changed from createdBy to userinfo as createdBy would be empty before insert
            system.debug('CreatedByEmail -->'+CreatedByEmail);
            String RecordTypeName = recordTypeToNameMap.get(NewLead.RecordTypeId) == null ? '' : recordTypeToNameMap.get(NewLead.RecordTypeId).name;
            
            // if the lead is not being created from pardot, add it to the list
            if(!(RecordTypeName == 'Marketing Lead'))
            {
                if(!pardotNonPardotLeadsMap.containsKey('NotPardot'))
                {
                    pardotNonPardotLeadsMap.put('NotPardot',new Set<Lead>{newLead});
                }
                else
                {
                    pardotNonPardotLeadsMap.get('NotPardot').add(newLead);
                }
            }
            else 
            {
				if(!pardotNonPardotLeadsMap.containsKey('Pardot'))
                {
                    pardotNonPardotLeadsMap.put('Pardot',new Set<Lead>{newLead});
                }
                else
                {
                    pardotNonPardotLeadsMap.get('Pardot').add(newLead);
                }               							
            }
        }
        return pardotNonPardotLeadsMap;
    }*/
    
    public map<String, Set<Lead>> fetchPardotNonPardotLeadsMap(List<Lead> leadList)
    {
        ID marketingLead = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Lead', 'Marketing Lead');
        Map<String,Set<Lead>> pardotNonPardotLeadsMap = new Map<String,Set<Lead>>();
        
        for(Lead newLead : LeadList)
        { 
            // if the lead is not being created from pardot, add it to the list
            if(newLead.RecordTypeID == marketingLead)
            {
                if(!pardotNonPardotLeadsMap.containsKey('Pardot'))
                {
                    pardotNonPardotLeadsMap.put('Pardot',new Set<Lead>{newLead});
                }
                else
                {
                    pardotNonPardotLeadsMap.get('Pardot').add(newLead);
                } 
            }
            else 
            { 
                if(!pardotNonPardotLeadsMap.containsKey('NotPardot'))
                {
                    pardotNonPardotLeadsMap.put('NotPardot',new Set<Lead>{newLead});
                }
                else
                {
                    pardotNonPardotLeadsMap.get('NotPardot').add(newLead);
                }
            }
        }
        return pardotNonPardotLeadsMap;
    }
    
    //2017-01-30 lalitha.adduru@cdk.com created another method with existing code with redundant code removed - RQ-06389
    public  void insertRequiredContactRelationships(List<Lead> leadList)
    {
        Id MarketingLeadId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Lead', 'Marketing Lead');
        Map<Id,Lead> contactToLeadMap = new Map<Id,Lead>();
        
        for(Lead leadObj : leadList)
        {
            if(leadObj.Status == 'Converted To Opportunity' && 
               leadObj.Contact__c == null && 
               leadObj.RecordTypeId == MarketingLeadId)
            {
                contactToLeadMap.put(leadObj.ConvertedContactId, leadObj);
            }
        }
        
        List<Contact> contactList = [SELECT Id, AccountId, LeadSource from contact where Id IN: contactToLeadMap.keySet()];
        
        List<Contact_Relationship__c> contactRelationshipList = new List<Contact_Relationship__c>();
        
        for(Contact contactObj : contactList)
        {
            if(contactObj.LeadSource != null)
            {
                Lead currentLead = contactToLeadMap.get(contactObj.Id);
                
                Contact_Relationship__c contactRelationshipObj = new Contact_Relationship__c();
                contactRelationshipObj.Contact__c = contactObj.Id;
                contactRelationshipObj.Account__c = contactObj.AccountId;
                contactRelationshipObj.Role__c = currentLead != null ? currentLead.Role__c : null;
                
                contactRelationshipList.add(contactRelationshipObj);
            }
        }
        
        ALL_SharedContact_Helper.insertDuplicateCheck(contactRelationshipList);
    }
    
    //2017-01-30 lalitha.adduru@cdk.com created another method with existing code with redundant code removed - RQ-06389
    public void checkCancelWorkflows(List<Lead> leadList)
    {
        for(Lead lead : leadList)
        {
            if(lead.Status == 'Converted to Opportunity')
            {
                lead.Cancel_Workflows__c = true;
            }
        }
    }
    
    // 2014-02-24 MK - added Contact phone sync
    // 2017-01-30 lalitha.adduru@cdk.com - RQ-06389
    public void ContactPhoneSync(Map<id,Lead> triggerOldMap, List<Lead> triggerNew)
    {
        List<Lead> LeadsToProcess = new List<Lead>();
        List<String> ContactandAccountToQuery = new List<String>();
        
        if(triggerNew != null && !triggerNew.IsEmpty())
        {
            for(Lead newLead : triggerNew)
            {
                Lead oldLead = new Lead();
                
                if(triggeroldMap!=null && !triggeroldMap.isEmpty())
                {
                    oldLead = triggeroldMap.get(newLead.Id);
                }  
                
                if(newLead.Contact__c != null && newLead.Contact__c != OldLead.Contact__c)
                {
                    ContactandAccountToQuery.add(newLead.Current_Account__c + '' + newLead.Contact__c); 
                    LeadsToProcess.add(newLead);
                }                
            }
            
            //2016-06-16- vishal.bandari@cdk.com - added logic to sync Phone fields on Lead with ContactRelationship and Contact		
            Map<Id, Contact_Relationship__c> LeadContacts = new Map<Id, Contact_Relationship__c>([
                SELECT Id, Phone__c, Contact__r.MobilePhone, Account_Contact_Id__c
                FROM Contact_Relationship__c
                WHERE Account_Contact_Id__c IN :ContactandAccountToQuery
            ]);
            
            Map<String,Contact_Relationship__c> ContactRelationship = new Map<String,Contact_Relationship__c>();
            
            for(Contact_Relationship__c cr : LeadContacts.values())
            {
                ContactRelationship.put(cr.Account_Contact_Id__c, cr);
            }
            
            if(LeadContacts != null && !LeadContacts.IsEmpty())
            {
                for(Lead newLead : LeadsToProcess)
                {
                    Contact_Relationship__c LeadContact = ContactRelationship.get(newLead.Current_Account__c+''+newLead.Contact__c);
                    
                    if(LeadContact != null)
                    {
                        newLead.Phone = LeadContact.Phone__c;
                        newLead.MobilePhone = LeadContact.Contact__r.MobilePhone;                    
                        newLead.Contact_Phone__c = LeadContact.Phone__c;
                        newLead.Contact_Mobile__c = LeadContact.Contact__r.MobilePhone;
                    }
                }
            }
        }
    }
    
    // Update lead owner details
    // 2017-01-30 - lalitha.adduru@cdk.com - RQ-06389
    public void UpdateOwnerDetails(Map<Id,Lead> triggerOldMap, list<Lead> triggerNew)
    {
        MgrMgrExcludeRoles = MgrMgrExcludeRoles != null ? MgrMgrExcludeRoles.toLowerCase() : null;
        List<Lead> updatedLeads = New List<Lead>();
        Set<string> changedOwners = new Set<string>();
        List<Lead> triggerOld = triggerOldMap != null ? triggerOldMap.values() : null;
        
        for(Lead lead : triggerNew)
        {
            Lead oldLead = triggerOldMap.get(lead.Id);
            
            if (oldLead != null && oldLead.OwnerId <> lead.OwnerId) 
            {
                changedOwners.add(lead.OwnerId);
                updatedLeads.add(lead);
            }
        }
        
        if (changedOwners.size() > 0) 
        {
            // 2016-04-11 matt.keefe@cdk.com - extracted method for duplicated code
            updatedLeads = updateOwners(updatedLeads, changedOwners);
        }
    }
    
    // 2016-04-11 matt.keefe@cdk.com - update the owners for the lead (key rep, owner, manager, etc.)
    public List<Lead> updateOwners(List<Lead> updatedleads, Set<string> changedOwners)
    {
        MgrMgrExcludeRoles = MgrMgrExcludeRoles != null ? MgrMgrExcludeRoles.toLowerCase() : null;
        
        Map<ID,User> userMap = new Map<ID,User>([
            SELECT Id, ManagerId, Manager.ManagerId, UserRole.Name 
            FROM User 
            WHERE IsActive = true 
            AND Id in : changedowners
        ]);
        
        for (Lead lead : updatedleads)
        {
            User currentUser = lead.OwnerId != null ? userMap.get(lead.OwnerId) : null;
            
            if(currentUser != null)
            {
                lead.Owner_Manager__c = currentUser.ManagerId;
                lead.Owner_Lookup__c = currentUser.Id;
                UserRole currentUserRole = currentUser.UserRole;
                
                if(MgrMgrExcludeRoles != null && currentUserRole != null) 
                { 
                    List<String> MgrMgrExcludeRoleList = new List<String>();
                    Set<String> MgrMgrExcludeRoleSet = new Set<String>();
                    
                    MgrMgrExcludeRoleList = MgrMgrExcludeRoles.split(';');
                    MgrMgrExcludeRoleSet.addAll(MgrMgrExcludeRoleList);
                    
                    if(!MgrMgrExcludeRoleSet.contains(currentUserRole.Name.toLowerCase())) 
                    {
                        if(currentUser.ManagerId != null)
                        {
                            if(currentUser.Manager.ManagerId != null)
                            {
                                lead.Owner_Managers_Manager__c = currentUser.Manager.ManagerId;
                            } 
                        }
                    }
                }
            } 
            else 
            {
                lead.Owner_Manager__c = null;  
                lead.Owner_Lookup__c = null;
            }
        }
        
        return updatedLeads;
    }
    
    // Updates VendorId and InstallDate, owner details
    // 2017-01-30 - lalitha.adduru@cdk.com - RQ-06389
    public void updateVendorInstallDate(List<Lead> triggerNew)
    {
        MgrMgrExcludeRoles = MgrMgrExcludeRoles != null ? MgrMgrExcludeRoles.toLowerCase() : null;
        List<Lead> updatedLeads = New List<Lead>();
        Set<string> changedOwners = new Set<string>();
        Set<string> accountIds = new Set<string>();        
        
        for(Lead lead : triggerNew)
        {
            if(lead.Current_Account__c != null) // added by lalitha
            {
                accountIds.add(lead.Current_Account__c);
            }
           
            if(lead.LeadSource != 'NADA')
            {
                changedOwners.add(lead.OwnerId);
                updatedLeads.add(lead);
            }
        }
        
        Map<Id, Account> keyRepMap = new Map<id, Account>([
            select Key_Rep__c 
            from Account 
            where Id in : accountIds
        ]);
        
        // 2013-01-25 MK - Added Systems query to get DMS from System_At_Dealership__c
        Map<id, System_at_Dealership__c> systemsByAccountMap = new Map<id, System_at_Dealership__c>();
        
        List<System_at_Dealership__c> systemsList = new List<System_at_Dealership__c>([
            select Id, Account__c, Vendor__c, Vendor__r.Name, Install_Date__c 
            from System_at_Dealership__c 
            where Account__c in : accountIds 
            and System_Type__c = 'DMS'
        ]);
        
        for(System_at_Dealership__c systemAtDS : systemsList)
        {
            systemsByAccountMap.put(systemAtDS.Account__c, systemAtDS);
        }
        
        // End 2013-01-25 MK
        
        for(Lead lead : triggerNew)
        {
            if(lead.LeadSource == 'Trade Show - NADA' || lead.LeadSource == 'Trade Show - ATD')
            {
                // 2013-01-25 MK - Updated to set DMS for NADA Leads
                if(lead.LeadSource.contains('NADA')) 
                {
                    System_at_Dealership__c systemAtDealerShip = systemsByAccountMap.get(lead.Current_Account__c);
                    
                    if(systemAtDealerShip != null) 
                    {
                        lead.Vendor_System__c = systemAtDealerShip.Vendor__c;
                       	lead.Install_Date__c = systemAtDealerShip.Install_Date__c;
                    }                    
                    // End 2013-01-25 MK
                    
                    // 2015-11-19 lalitha.adduru@cdk.com - added null check for keyRepMap
                    ID AccountId = lead.Current_Account__c;
                    Account currentAccount = (keyRepMap != null && AccountId != null) ? keyRepMap.get(AccountId) : null;
                    ID keyRep = currentAccount != null ? currentAccount.Key_Rep__c : null; 
                                        
                    if(keyRep != null)
                    {
                        lead.OwnerId = keyRep;                            
                        changedOwners.add(keyRep);
                        updatedLeads.add(lead);
                    }
                    else 
                    {
                        if(AccountId != null && keyRep == null)
                        {
                            lead.addError('Please ensure that Current Account '+ AccountId +' has a Key Rep' );
                        }
                        else if(AccountId == null)
                        {
                            lead.addError('Please ensure that Current Account field is not empty' );
                        }
                    }
                }
            }
            
            if(changedOwners.size() > 0)
            {
                // 2016-04-11 matt.keefe@cdk.com - extracted method for duplicated code
                updatedLeads = updateOwners(updatedLeads, changedOwners);
            }        
        } // end insert block            
    }
    
    // Creates LeadShares
    // 2017-01-30 - lalitha.adduru@cdk.com - RQ-06389
    public void createLeadShare(List<Lead> triggerNew)
    {        
        set<string> accountIds = new set<string>();
        
        for(Lead lead : triggerNew) 
        {             
            // 2015-11-18 lalitha.adduru@cdk.com - added null check for leadsource
            if(lead.LeadSource != null && lead.LeadSource.contains('NADA'))
            {
                accountIds.add(lead.Current_Account__c); 
            }
        }
        
        List<Account> AccountsWithAccountTeams = [
            SELECT Id, 
            
            (SELECT Id, Account__c, Team_Member__c, Team_Member__r.IsActive, Team_Role__c 
             FROM AccountTeamAccounts__r 
             WHERE Team_Role__c 
             like '%Forecasting%')
            
            FROM Account 
            WHERE Id IN :accountIds
        ];
        
        List<LeadShare> leadShares = new List<LeadShare>();
        
        for(Lead lead : triggerNew)
        { 
            for(Account account : AccountsWithAccountTeams)
            {
                List<Account_Team__c> members = account.getSObjects('AccountTeamAccounts__r');
                
                if(members != null)
                {
                    for(Account_Team__c member : members) 
                    {
                        // validate that the User of the LeadShare being added is active and is not the Owner 
                        User teamMember = member.Team_Member__r; 
                        
                        if(teamMember != null && teamMember.ID != lead.OwnerId && teamMember.IsActive)
                        {
                            leadShares.add(new LeadShare(UserOrGroupId=member.Team_Member__c,LeadId=lead.Id,LeadAccessLevel='Edit'));
                        } 
                    }
                }
            }
        }
        if(!leadShares.isEmpty()) // added by lalitha
        {
            insert leadShares;
        }
    }
    
    //2017-01-30 lalitha.adduru@cdk.com moved this from CB_UpdateLeadHandler and made changes to remove redundant code - RQ-06389
    public void UpdateOpportunity(Map<Id, Lead> newLeadMap, Map<Id, Lead> OldLeadMap) 
    {
        system.debug('UpdateOpportunity started -- >');
        //Set<Id> alreadyProcessedOpp = new Set<Id>();
    	Map<String, Lead> leadsByOpportunityId = new Map<String, Lead> ();
        
        if(newLeadMap != null && !newLeadMap.IsEmpty()) 
        {
            for (Lead lead : newLeadMap.values()) 
            {
            	Lead OldLead = new Lead();
                
                if(OldLeadMap!=null && !oldLeadMap.isEmpty())
                {
                    oldLead = oldLeadMap.get(lead.Id) == null ? new Lead() : oldLeadMap.get(lead.Id);
                }
                
                if (lead.Opportunity__c != OldLead.Opportunity__c && lead.Opportunity__c != null) 
                {
                    leadsByOpportunityId.put(lead.Opportunity__c, lead); 
                }
            }
        }
        
        List<Opportunity> OpportunitiesToUpdate = new List<Opportunity> ();
        
        Map<Id,Opportunity> LeadOpportunities = new Map<Id,Opportunity> ([
            Select Id, CampaignId, From_Lead__c, From_Lead__r.ADP_Campaign__c 
            From Opportunity 
            Where Id In : leadsByOpportunityId.keyset()
        ]);
        
        if(LeadOpportunities != null)
        {
	        for (Opportunity opp : LeadOpportunities.values()) 
	        {
	            // if the Opportunity has not already been processed
	            //if(!alreadyProcessedOpp.contains(opp.Id)) 
	            //{
	                Lead CurrentLead = leadsByOpportunityId.get(opp.Id);
                    
	                if (CurrentLead != null) 
	                {
                        CB_Opportunity_Handler.AlreadyProcessedLead.add(CurrentLead.Id);
	                    opp.From_Lead__c = CurrentLead.Id;
	                    CurrentLead.Status = 'Converted To Opportunity';
                        opp.CampaignId = 
                            (opp.CampaignId == null && CurrentLead.ADP_Campaign__c != null) ? CurrentLead.ADP_Campaign__c : null;
                        
                        CurrentLead.ADP_Campaign__c = 
                            (CurrentLead.ADP_Campaign__c == null && opp.CampaignId != null) ? opp.CampaignId:null;
                        								OpportunitiesToUpdate.add(opp); 
	                }
	            //}
	        }
        }
        
        if (!OpportunitiesToUpdate.IsEmpty()) 
        {
            update OpportunitiesToUpdate;
        }
        system.debug('UpdateOpportunity ended -- >');
    }
        
}