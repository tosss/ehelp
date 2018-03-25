//2015-09-23- anirudh.singh@cdk.com- To upgrade the API Version FROM 29.0 to 34.0.
//2015-11-19- lalitha.adduru@cdk.com- Added null check to KeyRepMap 
//2015-11-19- lalitha.adduru@cdk.com- Added null check to LeadSource 
//2015-11-19- lalitha.adduru@cdk.com- Modified variable names and indentation at some parts as per coding standards
//2015-11-25- lalitha.adduru@cdk.com- Created Handler class for DS_UpdateLead Trigger
//2016-03-18- harisantosh.kadiyaal@cdk.com- Added Lead conversion methods
//2016-03-30- venkata.shrivol@cdk.com -modified CreateOppUsingLead method
//2016-04-11- venkata.shrivol@cdk.com -modified CreateOppUsingLead method
//2016-04-15- venkata.shrivol@cdk.com -commented out the CreateOppUsingLead method
//2016-06-16- vishal.bandari@cdk.com - added logic to sync Phone fields on Lead with ContactRelationship and Contact
//2017-03-31 - lalitha.adduru@cdk.com - commented this class as it's moved to ALL_Lead_Handler - RQ-06389
public class DS_UpdateLead_Handler {
    
    // 2014-02-24 MK - added Contact phone sync
    /*public void ContactPhoneSync(Map<id,Lead> triggerOldMap, List<Lead> triggerNew)
    {
        List<Lead> LeadsToProcess = new List<Lead>();
        List<String> ContactandAccountToQuery = new List<String>();
        
        List<Lead> triggerOld =  new List<Lead>();
        if(triggerOldMap != null)
        {
            triggerOld =  triggerOldMap.values();
        }
        
        if(triggerNew != null && !triggerNew.IsEmpty())
        {
            for(Lead NewLead : triggerNew)
            {
                Lead OldLead = new Lead();
                
                if(triggerOldMap != null && !triggerOldMap.IsEmpty())
                { 
                    OldLead = triggeroldMap.get(NewLead.Id);
                }
                
                if(NewLead.Contact__c != OldLead.Contact__c && NewLead.Contact__c != null)
                {
                    ContactandAccountToQuery.add(NewLead.Current_Account__c+''+NewLead.Contact__c); LeadsToProcess.add(NewLead);
                }
                
            }
        }
        
		//2016-06-16- vishal.bandari@cdk.com - added logic to sync Phone fields on Lead with ContactRelationship and Contact
        Map<Id, Contact_Relationship__c> LeadContacts = new Map<Id, Contact_Relationship__c>([
            Select Id, Phone__c, Contact__r.MobilePhone,Account_Contact_Id__c
            From Contact_Relationship__c
            Where Account_Contact_Id__c IN :ContactandAccountToQuery
        ]);
        Map<String,Contact_Relationship__c> ContactRelationship = new Map<String,Contact_Relationship__c>();
        for(Contact_Relationship__c cr : LeadContacts.values())
        {
            ContactRelationship.put(cr.Account_Contact_Id__c, cr);
        }
        if(LeadContacts != null && !LeadContacts.IsEmpty())
        {
            for(Lead NewLead : LeadsToProcess)
            {
                Contact_Relationship__c LeadContact = ContactRelationship.get(NewLead.Current_Account__c+''+NewLead.Contact__c);
                System.debug(LeadContact);
                if(LeadContact != null)
                {
                    NewLead.Phone = LeadContact.Phone__c;
                    NewLead.MobilePhone = LeadContact.Contact__r.MobilePhone;
                    
                    NewLead.Contact_Phone__c = LeadContact.Phone__c;
                    NewLead.Contact_Mobile__c = LeadContact.Contact__r.MobilePhone;
                }
            }
        }
    }
    // END 2014-02-24 MK - added Contact phone sync
    
    // Update lead owner details
    public void UpdateOwnerDetails(Map<id,Lead> triggerOldMap, list<Lead> triggerNew, String MgrMgrExcludeRoles)
    {
        List<Lead> updatedLeads = New List<Lead>();
        Set<string> changedOwners = new Set<string>();
        
        List<Lead> triggerOld = triggerOldMap.values();
        
        for(integer i = 0; i<triggerNew.size(); i++)
        {
            system.debug(triggerNew.size());
            system.debug(triggerOld.size());
            if (triggerNew[i].OwnerId <> triggerOld[i].OwnerId) 
            {
                changedowners.add(triggerNew[i].OwnerId);
                updatedLeads.add(triggerNew[i]);
            }
        }
        
        if (changedowners.size() > 0) 
        {
            // 2016-04-11 matt.keefe@cdk.com - extracted method for duplicated code
            updatedLeads = updateOwners(updatedLeads, changedOwners, MgrMgrExcludeRoles);
        }
    }
    
    // 2016-04-11 matt.keefe@cdk.com - update the owners for the lead (key rep, owner, manager, etc.)
    public List<Lead> updateOwners(List<Lead> updatedleads, Set<string> changedOwners, String MgrMgrExcludeRoles)
    {
        Map<ID,User> userMap = new Map<ID,User>([
            Select Id, ManagerId, Manager.ManagerId, UserRole.Name 
            From User 
            Where IsActive = true 
            And id in : changedowners
        ]);
        
        for (Lead lead : updatedleads)
        {
            if(userMap.containsKey(lead.OwnerId))
            {
                User user = userMap.get(lead.OwnerId);
                lead.Owner_Manager__c = user.ManagerId;
                lead.Owner_Lookup__c = user.Id;
                
                if(MgrMgrExcludeRoles != null && user.UserRole.Name != null) 
                { 
                    List<String> MgrMgrExcludeRoleList = new List<String>();
                    Set<String> MgrMgrExcludeRoleSet = new Set<String>();
                    
                    MgrMgrExcludeRoleList = MgrMgrExcludeRoles.split(';');
                    MgrMgrExcludeRoleSet.addAll(MgrMgrExcludeRoleList);
                    
                    if(!MgrMgrExcludeRoleSet.contains(user.UserRole.Name.toLowerCase())) 
                    {
                        if(user.ManagerId != null)
                        {
                            if(user.Manager.ManagerId != null)
                            {
                                lead.Owner_Managers_Manager__c = user.Manager.ManagerId;
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
    public void updateVendorInstallDate(List<Lead> triggerNew,String MgrMgrExcludeRoles)
    {
        List<Lead> updatedLeads = New List<Lead>();
        Set<string> changedOwners = new Set<string>();
        Set<string> accountIds = new Set<string>();        
        
        for(integer i=0;i<triggerNew.size();i++)
        {
            accountIds.add(triggerNew[i].Current_Account__c);
           
            if(triggerNew[i].LeadSource != 'NADA')
            {
                changedOwners.add(triggerNew[i].OwnerId);
                updatedLeads.add(triggerNew[i]);
            }
        }
        
        Map<id, Account> keyRepMap = new MAP<id,Account>( [select Key_Rep__c from Account where Id in : accountIds] );
        
        // 2013-01-25 MK - Added Systems query to get DMS from System_At_Dealership__c
        Map<id, System_at_Dealership__c> systemsByAccountMap = new Map<id,System_at_Dealership__c>();
        
        List<System_at_Dealership__c> systemsList = new List<System_at_Dealership__c>([
            select Id, Account__c, Vendor__c, Vendor__r.Name, Install_Date__c 
            from System_at_Dealership__c 
            where Account__c in : accountIds and System_Type__c = 'DMS'
        ]);
        
        for(integer i=0;i<systemsList.size();i++)
        {
            systemsByAccountMap.put(systemsList[i].Account__c, systemsList[i]);
        }
        
        // End 2013-01-25 MK
        for(integer i=0;i<triggerNew.size();i++)
        {
            if(triggerNew[i].LeadSource == 'Trade Show - NADA' || triggerNew[i].LeadSource == 'Trade Show - ATD')
            {
                // 2013-01-25 MK - Updated to set DMS for NADA Leads
                if(triggerNew[i].LeadSource.contains('NADA')) 
                {
                    System_at_Dealership__c systemAtDealerShip = systemsByAccountMap.get(triggerNew[i].Current_Account__c);
                    
                    if(systemAtDealerShip != null) 
                    {
                        triggerNew[i].Vendor_System__c = systemAtDealerShip.Vendor__c;
                        triggerNew[i].Install_Date__c = systemAtDealerShip.Install_Date__c;
                    }                    
                    // End 2013-01-25 MK
                    
                    // 2015-11-19 lalitha.adduru@cdk.com - added null check for keyRepMap
                    if(!keyRepMap.isEmpty() && keyRepMap.size() > 0 &&  keyRepMap.get(triggerNew[i].Current_Account__c) != null && keyRepMap.get(triggerNew[i].Current_Account__c).Key_Rep__c != null)
                    {
                        triggerNew[i].OwnerId = keyRepMap.get(triggerNew[i].Current_Account__c).Key_Rep__c;                            
                        changedOwners.add(keyRepMap.get(triggerNew[i].Current_Account__c).Key_Rep__c);
                        updatedLeads.add(triggerNew[i]);
                    }
                    else 
                    {
                        if(triggerNew[i].Current_Account__c != null && keyRepMap.get(triggerNew[i].Current_Account__c).Key_Rep__c == null)
                        {
                            triggerNew[i].addError('Please ensure that Current Account '+triggerNew[i].Current_Account__c+' has a Key Rep' );
                        }
                        else if(triggerNew[i].Current_Account__c == null)
                        {
                            triggerNew[i].addError('Please ensure that Current Account field is not empty' );
                        }
                    }
                    // end 2015-11-19 Lalitha Adduru
                }
            }
            
            if(changedOwners.size() > 0)
            {
                // 2016-04-11 matt.keefe@cdk.com - extracted method for duplicated code
                updatedLeads = updateOwners(updatedLeads, changedOwners, MgrMgrExcludeRoles);
            }        
        } // end insert block            
    }
        
    // Creates LeadShares
    public void createLeadShare(List<Lead> triggerNew)
    {        
        set<string> accountIds = new set<string>();
        
        for(Lead lead : triggerNew) 
        {             
            // 2015-11-18 lalitha.adduru@cdk.com - added null check for leadsource
            if(lead.LeadSource != null && lead.LeadSource.contains('NADA'))
            {
                accountIds.add(lead.Current_Account__c); 
                system.debug('Added: '+lead); 
            }
            // End 2015-11-19 Lalitha Adduru
        }
        
        List<Account> AccountsWithAccountTeams = [
            Select Id, (Select Id, Account__c, Team_Member__c, Team_Member__r.IsActive, Team_Role__c From AccountTeamAccounts__r Where Team_Role__c like '%Forecasting%') 
            From Account 
            Where Id IN :accountIds
        ];
        
        List<LeadShare> LeadShares = new List<LeadShare>();
        
        for(Lead lead : triggerNew)
        {
            if(AccountsWithAccountTeams != null)
            {
                for(Account account : AccountsWithAccountTeams)
                {
                    if(account != null)
                    {
                        List<Account_Team__c> members = account.getSObjects('AccountTeamAccounts__r');
                        
                        if(members != null)
                        {
                            for(Account_Team__c member : members) 
                            {
                                // validate that the User of the LeadShare being added is active and is not the Owner                                        
                                if(member.Team_Member__r.IsActive && member.Team_Member__c != lead.OwnerId)
                                {
                                    LeadShares.add(new LeadShare(UserOrGroupId=member.Team_Member__c,LeadId=lead.Id,LeadAccessLevel='Edit'));
                                }
                                
                            } // end for Account_Team__c member in members
                        }
                    }
                } // end for Account account in AccountsWithAccountTeams
            } 
        } // end for Lead lead in Trigger.new
        
        insert LeadShares;        
    }
    
    // 2016-03-18- harisantosh.kadiyaal@cdk.com (Pradeep) - Convert Leads.
    // if opportunity is available for a lead, lead will get converted.
    // if opportunity is not available for a lead, lead will get converted by creating an opportunity.
    // Current Account, Contact, campaign id and Owner Id will be updated in the newly converted opportunity.
    // 2016-04-11 -venkata.shrivol@cdk.com -updated this method to future call for a prod fix; no request assigned;
    // 2016-04-15- venkata.shrivol@cdk.com -commented out the CreateOppUsingLead method
   /* @future
    public static void CreateOppUsingLead(set<Id> leadIds) //Map<Id, Lead> triggerNew)//
    {
        map<Id, Lead> triggerNew = new map<Id,Lead>([select Id,isConverted,Status,Name,Current_Account__c,Contact__c,OwnerId,Opportunity__c,Cancel_Workflows__c,
                                                     ADP_Campaign__c
                                                     from Lead 
                                                    where Id IN:leadIds]);
        //2016-03-30 -venkata.shrivol@cdk.com -added another and condition in soql query below.
        list<LeadStatus> convertStatusList = [
            SELECT MasterLabel 
            FROM LeadStatus
            WHERE IsConverted = true
            and MasterLabel='Converted to Opportunity'
            ORDER BY SORTORDER 
            LIMIT 1
        ];
        LeadStatus convertStatus = convertStatusList.size() > 0 ? convertStatusList.get(0) : new LeadStatus();
        
        List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
        List<Lead> newLeadLists = triggerNew.values();
        
        for (Lead lead: newLeadLists) 
        {
            if (!lead.isConverted && lead.Status == convertStatus.MasterLabel) 
            {
                Database.LeadConvert lc = new Database.LeadConvert();
                String oppName = lead.Name;
                
                lc.setLeadId(lead.Id);
                lc.setConvertedStatus(convertStatus.MasterLabel);
                lc.setAccountId(lead.Current_Account__c);
                lc.setContactId(lead.Contact__c);
                lc.setOwnerId(lead.OwnerId);
                
                if(lead.Opportunity__c != null)
                {
                    lc.setDoNotCreateOpportunity(true);   
                }
                else
                {
                    lc.setDoNotCreateOpportunity(false); 
                    lc.setOpportunityName(oppName);
                }
                
                if(lead.Contact__c != null && lead.Current_Account__c != null)
                {
                    leadConverts.add(lc);
                }
                system.debug('----testing---'+lead.Cancel_Workflows__c);
            }
        }
        system.debug('-----leadConverts------'+leadConverts);
        if (!leadConverts.isEmpty()) 
        {
            //2016-04-11  -venkata.shrivol@cdk.com -added try-catch to get the exceptions in logs 
            List<Database.LeadConvertResult> lcResults;
            try
            {
              lcResults = Database.convertLead(leadConverts);  
            }
            catch(Exception e)
            {
            	system.debug('----Exception Caught---'+e);    
            }
            
            List<Opportunity> objOpportunity = new List<Opportunity>();
            
            if(!lcResults.isEmpty())
            {
                for (Database.LeadConvertResult lcr: lcResults)
                {
                    Id campId = triggerNew.get(lcr.getLeadId()).ADP_Campaign__c;
                    Id ownerId = triggerNew.get(lcr.getLeadId()).OwnerId;
                    Id oppId;
                    if(lcr.getOpportunityId() != null)
                    {
                        oppId = lcr.getOpportunityId();
                        system.debug('---------oppId----'+oppId);
                    }
                    else
                    {
                        oppId = triggerNew.get(lcr.getLeadId()).Opportunity__c;
                    }
                    objOpportunity.add(UpdateLeadandCampaign(oppId, campId, lcr.getLeadId(), ownerId));
                }
            }	
            system.debug('-----objOpportunity--------'+objOpportunity);
            if (objOpportunity.size() > 0)
            {
                update objOpportunity;
            }
            
        }
    }
    
    public static Opportunity UpdateLeadandCampaign(Id convertOppId, Id campId, Id leadId, Id ownerId)
    {
        Opportunity convertedOpp = new Opportunity();
        convertedOpp.Id = convertOppId;
        convertedOpp.CampaignId = campId;
        convertedOpp.ADP_Opportunity_Owner__c = ownerId;
        //convertedOpp.From_Lead__c = leadId;
        
        return convertedOpp;
    }*/
}