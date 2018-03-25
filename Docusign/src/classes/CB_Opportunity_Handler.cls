public class CB_Opportunity_Handler 
{
    public static Set<Id> AlreadyProcessedLead = new Set<Id>();
    
    public static void UpdateLead(List<Opportunity> NewOppList, Map<Id,Opportunity> OldOppMap) 
    {
        List<String> LeadsToQuery = new List<String> ();
        List<Lead> LeadsToUpdate = new List<Lead> ();
        List<Opportunity> OpportunitiesToUpdate = new List<Opportunity>();
        
        Map<Id,Lead> LeadMap = new Map<Id,Lead> ();
        
        if (OldOppMap == null) { OldOppMap = new Map<Id,Opportunity> (); }
        
        if (NewOppList != null && !NewOppList.IsEmpty()) 
        {
            for (Opportunity NewOpp : NewOppList) 
            {
                Opportunity OldOpp = OldOppMap.get(NewOpp.Id);
                if(OldOpp == null) { OldOpp = new Opportunity(); }
                
                if (OldOpp.From_Lead__c != NewOpp.From_Lead__c 
                && NewOpp.From_Lead__c != null) 
                {
                    LeadsToQuery.add(NewOpp.From_Lead__c);
                }
            }
        }
        
        if (LeadsToQuery.size() > 0) {
            LeadMap = new Map<Id,Lead> ([
                Select Id, Status, IsConverted, ADP_Campaign__c 
                From Lead 
                Where Id IN :LeadsToQuery
            ]);
        }
        
        if (LeadMap != null && LeadMap.size() > 0) 
        {
            for (Opportunity opp : NewOppList) 
            {
                CB_UpdateLeadHandler.AlreadyProcessedOpp.add(opp.Id);
                
                if (LeadMap.keyset().contains(opp.From_Lead__c)) 
                {
                    Lead l = LeadMap.get(opp.From_Lead__c);
                    
                    if(!CB_Opportunity_Handler.AlreadyProcessedLead.contains(l.Id))
                    {
                        l.Status = 'Converted To Opportunity';
                        l.Opportunity__c = opp.Id;
                        
                        if(opp.CampaignId != null && l.ADP_Campaign__c == null) {
                            l.ADP_Campaign__c = opp.CampaignId;
                        }
                        
                        LeadsToUpdate.add(l);
                    }
                    
                    if(opp.CampaignId == null && l.ADP_Campaign__c != null) {
                        OpportunitiesToUpdate.add(new Opportunity(Id=opp.Id,CampaignId=l.ADP_Campaign__c));
                    }
                }
            }
            
            update LeadsToUpdate;
            update OpportunitiesToUpdate;
        }
    }
}