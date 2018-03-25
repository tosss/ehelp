public class TestLeadConvert {    
       
    public void CreateOppUsingLead(Map<Id, Lead> triggerNew)
	{
        LeadStatus convertStatus = [
            SELECT MasterLabel 
            FROM LeadStatus
            WHERE IsConverted = true
            ORDER BY SORTORDER 
            LIMIT 1
        ];
		List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
		      
		List<Lead> newLeadLists = triggerNew.values();

		for (Lead lead: newLeadLists) 
        {
			  //if (!lead.isConverted && lead.Status == convertStatus.MasterLabel) 
              //{
              if (!lead.isConverted) {
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
				   
                   //leadConverts.add(lc);
                  
                   if(lead.Contact__c != null && lead.Current_Account__c != null)
                   {
                       leadConverts.add(lc);
                   }
			  }
		 }

		 if (!leadConverts.isEmpty()) 
         {
			  List<Database.LeadConvertResult> lcResults = Database.convertLead(leadConverts);
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
                      }
                      else
                      {
                          oppId = triggerNew.get(lcr.getLeadId()).Opportunity__c;
                      }
                      objOpportunity.add(UpdateLeadandCampaign(oppId, campId, lcr.getLeadId(), ownerId));
				  }
			  }	
			  
             if (objOpportunity.size() > 0)
             {
                update objOpportunity;
             }
		 }
	}
	
	public Opportunity UpdateLeadandCampaign(Id convertOppId, Id campId, Id leadId, Id ownerId)
    {
     	Opportunity convertedOpp = new Opportunity();
        convertedOpp.Id = convertOppId;
        convertedOpp.CampaignId = campId;
        convertedOpp.ADP_Opportunity_Owner__c = ownerId;
        //convertedOpp.From_Lead__c = leadId;
        
        return convertedOpp;
    }
    
    public void LeadDetails(ID leadId)
    {
        System.debug( '-------- Lead Methods ------------');
        Lead objL = [SELECT Id, Name, ConvertedAccountId, ConvertedContactId, ConvertedDate, ConvertedOpportunityId,
                     IsConverted, Status, Current_Account__c, Contact__c, Opportunity__c, ADP_Campaign__c
                     FROM Lead WHERE Id=:leadId LIMIT 1];
        System.debug( objL.id );
        System.debug( objL.Name );
        System.debug( objL.ConvertedAccountId );
        System.debug( objL.ConvertedContactId );
        System.debug( objL.ConvertedDate );
        System.debug( objL.ConvertedOpportunityId );
        System.debug( objL.IsConverted );
        System.debug( objL.Status );
        System.debug( objL.Current_Account__c );
        System.debug( objL.Contact__c );
        System.debug( objL.Opportunity__c );
        System.debug( objL.ADP_Campaign__c );
        /*
        System.debug( '-------- Lead Convert Methods ------------');
        System.debug( objLC.getLeadID() );
        System.debug( objLC.getConvertedStatus() );
        System.debug( objLC.getOpportunityName() );
        System.debug( objLC.getAccountId() );
        System.debug( objLC.getContactId() );
		*/
    }
}