public class DS_UpdateCampaignAccountMember_Handler 
{
    //Updates LeadID on Campaign Account Member
    public static void updateCampaignAccountMember(List<Lead> oldLeadList,List<Lead> newLeadList)
    {
        try
        {
            //Map of campaign ID and lead object
            Map<Id,Lead> leadMap = new  Map<Id,Lead>();
            List<Campaign_Account_Members__c> ListToUpdate = new List<Campaign_Account_Members__c>();
            for(Lead leadObj : newLeadList)
            {
                leadMap.put(leadObj.ADP_Campaign__c, leadObj);  
            }
            
            List<Campaign_Account_Members__c> campaignAccountMemberList = [
                select id,LeadID__c,Account__c,
                OpportunityID__c,Campaign__c 
                from Campaign_Account_Members__c 
                where Campaign__c in :leadMap.keySet()];
            
            if(campaignAccountMemberList!=null)
            {	
                for(Campaign_Account_Members__c campaignAccountMemberObj : campaignAccountMemberList)
                {
                    Lead leadObj = leadMap.get(campaignAccountMemberObj.Campaign__c);
                    if(leadObj.Current_Account__c==campaignAccountMemberObj.Account__c)
                    {
                        campaignAccountMemberObj.LeadID__c = leadObj.Id;
                        ListToUpdate.add(campaignAccountMemberObj);
                    }
                } 
            }
            if(oldLeadList!=null)
            {
                Set<Id> oldCamIdSet = new Set<Id>();
                for(Lead leadObj : oldLeadList)
                {
                    if(leadObj.ADP_Campaign__c!=null)
                    {
                        oldCamIdSet.add(leadObj.ADP_Campaign__c); 
                    }
                }
                List<Campaign_Account_Members__c> oldCampAccMemberList = [
                    select id,LeadID__c,
                    Campaign__c,Account__c 
                    from Campaign_Account_Members__c 
                    where Campaign__c in :oldCamIdSet
                ];
                for(Campaign_Account_Members__c camObj : oldCampAccMemberList)
                {
                    camObj.LeadID__c = null;
                    ListToUpdate.add(camObj);
                }
            }
            if(ListToUpdate.size()!=0)
            {
                upsert ListToUpdate;
            }
        }
        catch(Exception e)
        {
            System.debug('Exception '+e.getMessage()+' at '+e.getLineNumber());
        }
    }
    
    //Updates OpportunityID on Campaign Account Member when Opportunity is inserted
    public static void updateCampaignAccountMember(List<Opportunity> oldOppList,List<Opportunity> newOppList)
    {
        try
        {
            List<Campaign_Account_Members__c> ListToUpdate = new List<Campaign_Account_Members__c>();
            //Map of campaign ID and Opportunity Object
            Map<Id,Opportunity> oppMap = new  Map<Id,Opportunity>();
            
            for(Opportunity oppObj : newOppList)
            {
                if(oppObj.CampaignId!=null)
                {
                    oppMap.put(oppObj.CampaignId, oppObj);  
                }
            }
            
            List<Campaign_Account_Members__c> campaignAccountMemberList = [
                select id,OpportunityID__c,
                Campaign__c,Account__c 
                from Campaign_Account_Members__c 
                where Campaign__c in :oppMap.keySet()];
            
            if(campaignAccountMemberList!=null)
            {	
                for(Campaign_Account_Members__c campaignAccountMemberObj : campaignAccountMemberList)
                {
                    Opportunity oppObj = OppMap.get(campaignAccountMemberObj.Campaign__c);
                    if(oppObj.AccountId==campaignAccountMemberObj.Account__c)
                    {
                        campaignAccountMemberObj.OpportunityID__c = oppObj.Id;
                        ListToUpdate.add(campaignAccountMemberObj);
                    }
                }
                
            }
            
            if(oldOppList!=null)
            {
                Set<Id> oldCamIdSet = new Set<Id>();
                for(Opportunity oppObj : oldOppList)
                {
                    if(oppObj.CampaignId!=null)
                    {
                        oldCamIdSet.add(oppObj.CampaignId); 
                    }
                }
                List<Campaign_Account_Members__c> oldCampAccMemberList = [
                    select id,OpportunityID__c,
                    Campaign__c,Account__c 
                    from Campaign_Account_Members__c 
                    where Campaign__c in :oldCamIdSet
                ];
                for(Campaign_Account_Members__c camObj : oldCampAccMemberList)
                {
                    camObj.OpportunityID__c = null;
                    ListToUpdate.add(camObj);
                }
            }
            if(ListToUpdate.size()!=0)
            {
                upsert ListToUpdate;
            }
        }
        catch(Exception e)
        {
            System.debug('Exception '+e.getMessage()+' at '+e.getLineNumber());
        }
        
    }
    
}