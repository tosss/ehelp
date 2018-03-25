public class DS_Opportunity_Handler 
{
    // 2011-11-08: Added a condition to only process those with Forecase in the team role -MK 
    // 2011-11-08: Made changes to exclude any Opportunity with a BZ Migration record type -MK (matt_keefe@adp.com)
    public static list<Opportunity> FilterBZMigrationOpportunities(list<Opportunity> TriggerNew)
    {
        list<Opportunity> OpportunitiesToProcess = new list<Opportunity>();
        
        // 1 describe
        Id BZMigrationRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity', 'BZ Migration');
        
        for(Opportunity o : TriggerNew)
        {
            if(BZMigrationRecordTypeId != null) {
                if(o.RecordTypeId != BZMigrationRecordTypeId) {
                    OpportunitiesToProcess.add(o); //system.debug('Adding to Process List: '+o); 
                }
            } 
            else { 
                OpportunitiesToProcess.add(o); //system.debug('Adding to Process List: '+o); 
            }
        }
        
        return OpportunitiesToProcess;
    }
    
    // Inserts a Sales Team for an Opportunity when it is updated.
    public static void AddSalesTeam(list<Opportunity> OpportunitiesToProcess)
    {
        set<Id> accountSet = new set<Id>();
        set<Id> opportunitySet = new set<Id>();
        list<Opportunity> notForecast = new list<Opportunity>();
        list<Id> ownerIdWithOppShare = new List<Id>();
        list<Id> opportunityId = new List<Id>();
        
        for(Opportunity newOppty : OpportunitiesToProcess)
        {
            if(newOppty.AccountId != null)
            {
                notForecast.add(newOppty);
                accountSet.add(newOppty.AccountId);
                opportunitySet.add(newOppty.Id);
            }
        }
        
        if(notForecast.size() == 0) return;
        
        List<Sales_Team__c> addSalesTeam = new List<Sales_Team__c>();
        Sales_Team__c salesTeamMem;
        
        // 1 soql
        List<Account_Team__c> accountTeamMems = [
            Select Id, Team_Member__c, Team_Role__c, Opportunity_Access__c, Account__c 
            From Account_Team__c 
            Where Account__c in :accountSet
            And Team_Role__c like '%Forecast%' 
        ]; 
        
        for(Opportunity oneOpp : notForecast) 
        {
            Boolean ownerHasSharing = false;
            for(Account_Team__c accountTeamMem : accountTeamMems)
            {
                if(oneOpp.AccountId == accountTeamMem.Account__c)
                {
                    if(!ownerHasSharing) 
                    {
                        ownerHasSharing = (accountTeamMem.Team_Member__c == oneOpp.CreatedById);
                    }
                    
                    salesTeamMem = new Sales_Team__c();
                    salesTeamMem.User__c = accountTeamMem.Team_Member__c;
                    salesTeamMem.Opportunity__c = oneOpp.Id;
                    salesTeamMem.Opportunity_Access__c = accountTeamMem.Opportunity_Access__c;
                    salesTeamMem.Team_Role__c = accountTeamMem.Team_Role__c;
                    addSalesTeam.add(salesTeamMem);
                }
            }
            
            if(!ownerHasSharing)
            {
                salesTeamMem = new Sales_Team__c();
                salesTeamMem.User__c = oneOpp.CreatedById;
                salesTeamMem.Opportunity__c = oneOpp.Id;
                salesTeamMem.Opportunity_Access__c = 'Read/Write';
                salesTeamMem.Team_Role__c = 'Non-Forecasting Rep';
                addSalesTeam.add(salesTeamMem);
            }
            
        }
        // 1 dml
        if(addSalesTeam.size() > 0)
        {
            insert addSalesTeam;
        }
    }
    
    // Updates a Shareing Rule for an Opportunity when it is inserted.
    // Sets the Owner Manager for an Opportunity when inserted or updated.
    public static void CreateOpportunityShare(list<Opportunity> OpportunitiesToProcess, list<Opportunity> TriggerOld)
    {
        // the owner will be changed after the workflow 
        //   process and it will cause the trigger to fire one more time. 
        // this part will be called after the workflow 
        //   because the owner is changed and the trigger 
        //   will create a record in OpportunityShare
        
        string oppId = '';
        string ownerId = '';
        string OldOwnerId  = '';
        List<OpportunityShare> updatedOppShare = new List<OpportunityShare>();
        OpportunityShare oppShareRec;
        
        for(Integer i = 0; i < OpportunitiesToProcess.size(); i++)
        {
            Id OpportunityId = OpportunitiesToProcess[i].Id;
            OwnerId = OpportunitiesToProcess[i].OwnerId;
            OldOwnerId = TriggerOld[i].OwnerId;
            
            if (ownerId != OldOwnerId) 
            {
                OppShareRec = new OpportunityShare();
                OppShareRec.UserOrGroupId = OldOwnerId;
                //OppShareRec.RowCause = 'Team';
                OppShareRec.OpportunityId = OpportunityId;
                OppShareRec.OpportunityAccessLevel = 'Edit';    
                updatedOppShare.add(oppShareRec); 
            }
            
            // 1 dml
            if(updatedOppShare.size() > 0)
            {
                system.debug(updatedOppShare);
                insert updatedOppShare;
            }
        }
    }
}