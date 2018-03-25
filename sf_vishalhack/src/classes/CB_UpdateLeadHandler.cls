//2017-03-31 - lalitha.adduru@cdk.com - commented this class as it's moved to ALL_Lead_Handler - RQ-06389
public class CB_UpdateLeadHandler 
{
    /*public static Set<Id> AlreadyProcessedOpp = new Set<Id>();
    
    public static void UpdateOpportunity(map<Id,Lead> NewLeadMap, map<Id,Lead> OldLeadMap) 
    {
    	map<String,Lead> LeadsByOpportunityId = new map<String,Lead> ();
        
        if(OldLeadMap == null) { OldLeadMap = new Map<Id,Lead>(); }
        
        if(NewLeadMap != null && !NewLeadMap.IsEmpty()) {
            for (Lead l : NewLeadMap.values()) 
            {
            	Lead OldLead = null;
            	if(OldLeadMap == null || OldLeadMap.get(l.Id) == null) { OldLead = new Lead(); }
                else { OldLead = OldLeadMap.get(l.Id); }
                
                if (l.Opportunity__c != OldLead.Opportunity__c 
                && l.Opportunity__c != null) {
                    LeadsByOpportunityId.put(l.Opportunity__c, l); 
                }
            }
        }
        
        List<Opportunity> OpportunitiesToUpdate = new List<Opportunity> ();
        
        Map<Id,Opportunity> LeadOpportunities = new Map<Id,Opportunity> ([
            Select Id, CampaignId, From_Lead__c, From_Lead__r.ADP_Campaign__c 
            From Opportunity 
            Where Id In : LeadsByOpportunityId.keyset()
        ]);
        
        if(LeadOpportunities != null && !LeadOpportunities.IsEmpty())
        {
	        for (Opportunity opp : LeadOpportunities.values()) 
	        {
	            // if the Opportunity has not already been processed
	            if(!AlreadyProcessedOpp.contains(opp.Id)) 
	            {
	                Lead CurrentLead = LeadsByOpportunityId.get(opp.Id);
	                CB_Opportunity_Handler.AlreadyProcessedLead.add(CurrentLead.Id);
	                
	                if (CurrentLead != null) 
	                {
	                    opp.From_Lead__c = CurrentLead.Id;
	                    CurrentLead.Status = 'Converted To Opportunity';
	                    
	                    if (opp.CampaignId == null && CurrentLead.ADP_Campaign__c != null) {
	                        opp.CampaignId = CurrentLead.ADP_Campaign__c;
	                    }
	                    
	                    if (CurrentLead.ADP_Campaign__c == null && opp.CampaignId != null) {
	                        CurrentLead.ADP_Campaign__c = opp.CampaignId;
	                    }
	                    
	                    OpportunitiesToUpdate.add(opp); 
	                }
	            }
	        }
        }
        
        if (OpportunitiesToUpdate != null && !OpportunitiesToUpdate.IsEmpty()) {
            update OpportunitiesToUpdate; }
    }*/
}