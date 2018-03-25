//2015-10-14 Hemanth - Fixed Too many rows fetched error , code optimization
public class DS_UpdateCampaignAccountMember_Handler 
{
    //Updates LeadID on Campaign Account Member
    public static void updateCampaignAccountMember(List<Lead> oldLeadList,List<Lead> newLeadList)
    {
        try
        {
            //Map of campaign ID and lead object
            Map<Id,Lead> leadMap = new  Map<Id,Lead>();
            Set<Id> accIdSet = new Set<Id>();
            List<Campaign_Account_Members__c> ListToUpdate = new List<Campaign_Account_Members__c>();
            for(Lead leadObj : newLeadList)
            {
                leadMap.put(leadObj.ADP_Campaign__c, leadObj);  
                accIdSet.add(leadObj.Current_Account__c);
            }
            Map<Id,Id> oldCampIdMap = new Map<Id,Id>();
            if(oldLeadList!=null)
            {
                for(Lead leadObj : oldLeadList)
                {
                    if(leadObj.ADP_Campaign__c!=null)
                    {
                        oldCampIdMap.put(leadObj.ADP_Campaign__c,leadObj.Current_Account__c); 
                    }
                }
            }
            
            Set<Id> tempCampaignList = new Set<Id>();
            tempCampaignList.addAll(leadMap.keySet());
            tempCampaignList.addAll(oldCampIdMap.keySet());
            List<Campaign_Account_Members__c> campaignAccountMemberList = [
                select id,LeadID__c,Account__c,
                OpportunityID__c,Campaign__c 
                from Campaign_Account_Members__c 
                where Campaign__c in :tempCampaignList
                and Account__c in :accIdSet
            ];
            
            if(campaignAccountMemberList!=null)
            {	
                for(Campaign_Account_Members__c campaignAccountMemberObj : campaignAccountMemberList)
                {
                    Lead leadObj = leadMap.get(campaignAccountMemberObj.Campaign__c);
                    if(leadObj!=null)
                    {
                        if(leadObj.Current_Account__c==campaignAccountMemberObj.Account__c)
                        {
                            campaignAccountMemberObj.Campaign_Member_Status__c = 'Converted to Lead'; // added by Lalitha Adduru to update the status of Campain Member Status
                            campaignAccountMemberObj.LeadID__c = leadObj.Id;
                            ListToUpdate.add(campaignAccountMemberObj);
                        }  
                    }
                    else
                    {
                        if(oldLeadList!=null)
                        {
                            if(!leadMap.containsKey(campaignAccountMemberObj.Campaign__c) && oldCampIdMap.containsKey(campaignAccountMemberObj.Campaign__c))
                            {
                                campaignAccountMemberObj.LeadID__c = null;
                                ListToUpdate.add(campaignAccountMemberObj);
                            }
                        } 
                    }
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
            Set<Id> accIdSet = new Set<Id>();
            
            for(Opportunity oppObj : newOppList)
            {
                if(oppObj.CampaignId!=null)
                {
                    oppMap.put(oppObj.CampaignId, oppObj);  
                    accIdSet.add(oppObj.AccountId);
                }
            }
            Map<Id,Id> oldCampIdMap = new Map<Id,Id>();
            if(oldOppList!=null)
            {
                for(Opportunity oppObj : oldOppList)
                {
                    if(oppObj.CampaignId!=null)
                    {
                        oldCampIdMap.put(oppObj.CampaignId,oppObj.AccountId); 
                    }
                }
            }
            
            Set<Id> tempCampaignList = new Set<Id>();
            tempCampaignList.addAll(oppMap.keySet());
            tempCampaignList.addAll(oldCampIdMap.keySet());
            List<Campaign_Account_Members__c> campaignAccountMemberList = [
                select id,OpportunityID__c,
                Campaign__c,Account__c 
                from Campaign_Account_Members__c 
                where Campaign__c in :tempCampaignList
                and Account__c in :accIdSet 
            ];
            
            if(campaignAccountMemberList!=null)
            {	
                for(Campaign_Account_Members__c campaignAccountMemberObj : campaignAccountMemberList)
                {
                    Opportunity oppObj = OppMap.get(campaignAccountMemberObj.Campaign__c);
                    if(oppObj!=null)
                    {
                        if(oppObj.AccountId==campaignAccountMemberObj.Account__c)
                        {
                            campaignAccountMemberObj.Campaign_Member_Status__c = 'Converted to Opportunity';// added by Lalitha Adduru to update the status of Campain Member Status 
                            campaignAccountMemberObj.OpportunityID__c = oppObj.Id;
                            ListToUpdate.add(campaignAccountMemberObj);
                        } 
                    }
                    else
                    {
                        if(oldOppList!=null)
                        {
                            if(!OppMap.containsKey(campaignAccountMemberObj.Campaign__c) && oldCampIdMap.containsKey(campaignAccountMemberObj.Campaign__c))
                            {
                                campaignAccountMemberObj.OpportunityID__c = null;
                                ListToUpdate.add(campaignAccountMemberObj);
                            }
                        } 
                    }
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