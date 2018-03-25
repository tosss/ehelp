trigger DS_UpdateLead on Lead (before insert, before update, after insert) 
{
    GlobalSettings__c gs = GlobalSettings__c.getInstance();
    String MgrMgrExcludeRoles = gs.Lead_Owner_Mgrs_Mgr_Roles_to_Exclude__c;
    if(MgrMgrExcludeRoles != null) { MgrMgrExcludeRoles = MgrMgrExcludeRoles.toLowerCase(); }
    
    if (Trigger.isBefore)
    {
        // 2014-02-24 MK - added Contact phone sync
        if (Trigger.isInsert || Trigger.isUpdate)
        {
            List<Lead> LeadsToProcess = new List<Lead>();
            List<Id> ContactIdsToQuery = new List<Id>();
            
            if(Trigger.New != null && !Trigger.New.IsEmpty())
            {
                for(Lead NewLead : Trigger.new)
                {
                    Lead OldLead = new Lead();
                    if(Trigger.OldMap != null && !Trigger.OldMap.IsEmpty()) { 
                        OldLead = Trigger.oldMap.get(NewLead.Id); }
                    
                    if(NewLead.Contact__c != OldLead.Contact__c && NewLead.Contact__c != null) {
                        ContactIdsToQuery.add(NewLead.Contact__c); LeadsToProcess.add(NewLead); }
                }
            }
            
            Map<Id, Contact> LeadContacts = new Map<Id, Contact>([
                Select Id, Phone, MobilePhone
                From Contact
                Where Id IN :ContactIdsToQuery
            ]);
            
            if(LeadContacts != null && !LeadContacts.IsEmpty())
            {
                for(Lead NewLead : LeadsToProcess)
                {
                    Contact LeadContact = LeadContacts.get(NewLead.Contact__c);
                    
                    if(LeadContact != null)
                    {
                    	NewLead.Phone = LeadContact.Phone;
                        NewLead.MobilePhone = LeadContact.MobilePhone;
                    	
                        NewLead.Contact_Phone__c = LeadContact.Phone;
                        NewLead.Contact_Mobile__c = LeadContact.MobilePhone;
                    }
                }
            }
        }
        // END 2014-02-24 MK - added Contact phone sync
        
        if (Trigger.isUpdate)
        {
            List<Lead> updatedLeads = New List<Lead>();
            Set<string> changedowners = new Set<string>();
            
            for(integer i = 0; i<trigger.new.size(); i++)
            {      
                if (trigger.new[i].OwnerId <> trigger.old[i].OwnerId) 
                {
                    changedowners.add(trigger.new[i].OwnerId);
                    updatedLeads.add(trigger.new[i]);
                }
            }
            
            if (changedowners.size() > 0) 
            {
                Map<ID,User> userMap = new Map<ID,User>([
                    Select Id, ManagerId, Manager.ManagerId, UserRole.Name 
                    From User 
                    Where IsActive = true 
                    And id in : changedowners
                ]);
                
                for (lead l : updatedleads)
                {
                    if(userMap.containsKey(l.OwnerId))
                    {
                        User u = userMap.get(l.OwnerId);
                        l.Owner_Manager__c = u.ManagerId;
                        l.Owner_Lookup__c = u.Id;
                        
                        if(MgrMgrExcludeRoles != null && u.UserRole.Name != null) 
                        { 
                            List<String> MgrMgrExcludeRoleList = new List<String>();
                            Set<String> MgrMgrExcludeRoleSet = new Set<String>();
                            
                            MgrMgrExcludeRoleList = MgrMgrExcludeRoles.split(';');
                            MgrMgrExcludeRoleSet.addAll(MgrMgrExcludeRoleList);
                            
                            if(!MgrMgrExcludeRoleSet.contains(u.UserRole.Name.toLowerCase())) 
                            {
                                if(u.ManagerId != null) {
                                    if(u.Manager.ManagerId != null) {
                                        l.Owner_Managers_Manager__c = u.Manager.ManagerId; } 
                                }
                            }
                        }
                    } 
                    else 
                    {
                        l.Owner_Manager__c = null;  
                        l.Owner_Lookup__c = null;
                    }
                }
            }
        }
        
        if (Trigger.isInsert)
        {
            List<Lead> updatedLeads = New List<Lead>();
            Set<string> changedOwners = new Set<string>();
            Set<string> accts = new Set<string>();        
            
            for(integer i=0;i<Trigger.new.size();i++)
            {
                accts.add(trigger.new[i].Current_Account__c);
                
                if(trigger.new[i].LeadSource != 'NADA')
                {
                    changedOwners.add(trigger.new[i].OwnerId);
                    updatedLeads.add(trigger.new[i]);
                }
            }
            
            Map<id, Account> keyRepMap = new MAP<id,Account>([select Key_Rep__c from Account where Id in : accts]);
            
            // 2013-01-25 MK - Added Systems query to get DMS from System_At_Dealership__c
            Map<id, System_at_Dealership__c> systemsByAccountMap = new Map<id,System_at_Dealership__c>();
            
            List<System_at_Dealership__c> systemsList = new List<System_at_Dealership__c>([
                select Id, Account__c, Vendor__c, Vendor__r.Name, Install_Date__c 
                from System_at_Dealership__c where Account__c in : accts and System_Type__c = 'DMS']);
            
            for(integer i=0;i<systemsList.size();i++){
                systemsByAccountMap.put(systemsList[i].Account__c, systemsList[i]);
            }
            
            // End 2013-01-25 MK
            for(integer i=0;i<Trigger.new.size();i++)
            {
                if(Trigger.new[i].LeadSource == 'Trade Show - NADA' || Trigger.new[i].LeadSource == 'Trade Show - ATD')
                {
                    // 2013-01-25 MK - Updated to set DMS for NADA Leads
                    if(Trigger.new[i].LeadSource.contains('NADA')) 
                    {
                        System_at_Dealership__c Sys = systemsByAccountMap.get(trigger.new[i].Current_Account__c);
                        
                        if(Sys != null) 
                        {
                            Trigger.new[i].Vendor_System__c = Sys.Vendor__c;
                            Trigger.new[i].Install_Date__c = Sys.Install_Date__c;
                        }
                    }
                    
                    // End 2013-01-25 MK
                    system.debug(trigger.new[i]);
                    
                    trigger.new[i].Ownerid = keyRepMap.get(trigger.new[i].Current_Account__c).Key_Rep__c;
                    
                    changedOwners.add(keyRepMap.get(trigger.new[i].Current_Account__c).Key_Rep__c);
                    updatedLeads.add(trigger.new[i]);
                }
            }
            
            if(changedOwners.size() > 0)
            {
                Map<ID,User> userMap = new Map<ID,User>([
                    Select Id, ManagerId, Manager.ManagerId, UserRole.Name 
                    From User 
                    Where IsActive = true 
                    And id in : changedowners
                ]);
                
                for (Lead l : updatedLeads)
                {
                    if(userMap.containsKey(l.OwnerId))
                    {
                        User u = userMap.get(l.OwnerId); system.debug(u);
                        l.Owner_Manager__c = u.ManagerId;  
                        l.Owner_Lookup__c = u.Id;
                        
                        if(MgrMgrExcludeRoles != null && u.UserRole.Name != null) 
                        { 
                            List<String> MgrMgrExcludeRoleList = new List<String>();
                            Set<String> MgrMgrExcludeRoleSet = new Set<String>();
                            MgrMgrExcludeRoleList = MgrMgrExcludeRoles.split(';');
                            MgrMgrExcludeRoleSet.addAll(MgrMgrExcludeRoleList); system.debug(u.UserRole.Name);
                            
                            if(!MgrMgrExcludeRoleSet.contains(u.UserRole.Name.toLowerCase())) 
                            {
                                if(u.ManagerId != null) 
                                {
                                    if(u.Manager.ManagerId != null) {
                                        l.Owner_Managers_Manager__c = u.Manager.ManagerId; } 
                                }
                            }
                        }
                    } 
                    else 
                    {
                        l.Owner_Manager__c = null;  
                        l.Owner_Lookup__c = null;
                    }
                }
            }        
        } // end insert block
        
        
    }
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            set<string> accts = new set<string>();
            
            for(lead l : Trigger.new) { 
                if(l.LeadSource.contains('NADA')){
                    accts.add(l.Current_Account__c); system.debug('Added: '+l); 
                }
            }
            
            List<Account> AccountsWithAccountTeams = [
                Select Id, (Select Id, Account__c, Team_Member__c, Team_Member__r.IsActive, Team_Role__c From AccountTeamAccounts__r Where Team_Role__c like '%Forecasting%') 
                From Account 
                Where Id IN :accts
            ];
            
            List<LeadShare> LeadShares = new List<LeadShare>();
            
            for(Lead l : Trigger.new)
            {
                if(AccountsWithAccountTeams != null)
                {
                    for(Account a : AccountsWithAccountTeams)
                    {
                        if(a != null)
                        {
                            List<Account_Team__c> members = a.getSObjects('AccountTeamAccounts__r');
                            
                            if(members != null)
                            {
                                for(Account_Team__c member : members) 
                                {
                                    system.debug(member);
                                    // validate that the User of the LeadShare being added is active and is not the Owner
                                    
                                    if(member.Team_Member__r.IsActive && member.Team_Member__c != l.OwnerId) {
                                        LeadShares.add(new LeadShare(UserOrGroupId=member.Team_Member__c,LeadId=l.Id,LeadAccessLevel='Edit')); }
                                
                                } // end for Account_Team__c member in members
                            }
                        }
                    } // end for Account a in AccountsWithAccountTeams
                } 
            } // end for Lead l in Trigger.new
            
            insert LeadShares;
        }
    }

}