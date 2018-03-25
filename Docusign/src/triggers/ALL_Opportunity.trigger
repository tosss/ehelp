trigger ALL_Opportunity on Opportunity (after insert, after update) 
{
    list<Opportunity> OpportunitiesToProcess 
        = DS_Opportunity_Handler.FilterBZMigrationOpportunities(Trigger.New);
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
        DS_Opportunity_Handler.AddSalesTeam(OpportunitiesToProcess);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate) 
    {
        // Added Sivap 3/17/2015 Updates deal state CDK_Opportunity_Owner_Email__c if CDK Opp owner on Opportunity is changed
        if(ALL_CheckRecursive.runCodeBlockOnce('ALL_DealState_Handler_isUpdate') || Test.isRunningTest())
        {
            DS_DealState_Handler.DealStateEmailUpdateFromOpportunity(Trigger.newMap, Trigger.OldMap);            
        }
    }
    
    // 2015-05-15 MK - attempted to remove this, but it caused a larger issue preventing 
    //   the User creating the Opp from accessing after creation
    if(Trigger.isAfter && Trigger.isUpdate) 
    {
        DS_Opportunity_Handler.CreateOpportunityShare(OpportunitiesToProcess, Trigger.Old);
    }
    
    if(Trigger.isAfter)
    {
        // update leads - Trigger.New must be sent because NewMap will not contain inserted records
        CB_Opportunity_Handler.UpdateLead(Trigger.New, Trigger.OldMap);
        
        // RQ-04271 - when the Opportunity Status is Inactive/Cancelled set Deal State Deal_Status__c to Cancelled
        DS_DealState_Handler.UpdateDealState(Trigger.New); 
        
        //2015-08-12 Hemanth RQ-03101 Store Lead ID and Opportunity ID on related Campaign Account Member
        if(ALL_CheckRecursive.runCodeBlockOnce('UpdateCampaignAccountMemberOpp09302015'))
        {
            DS_UpdateCampaignAccountMember_Handler.updateCampaignAccountMember(Trigger.Old,Trigger.New);
        }
    }
        
}