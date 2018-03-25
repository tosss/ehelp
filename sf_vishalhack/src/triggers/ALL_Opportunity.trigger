//2015-10-13 Hemanth - added recursive check on DS_UpdateCampaignAccountMember_Handler 
//2015-10-27 Hemanth - Added Test.isRunning check to access blocked code from test class
//2016-09-26 ragashalini.koka@cdk.com - added code to update owner hierarchy fields before insert and before update for CPQ - RQ-07879
//2016-09-30 ragashalini.koka@cdk.com - added code to create Opportunity Location for Opportunities after insert - RQ-07919
//2016-10-12 vishal.bandari@cdk.com   - added method to update DataConsent Changes - RQ-07963
//2016-10-25 ragashalini.koka@cdk.com - added the after insert and update functionality for the RQ-08086

trigger ALL_Opportunity on Opportunity (after insert, after update, before insert, before update) 
{
    list<Opportunity> OpportunitiesToProcess 
        = DS_Opportunity_Handler.FilterBZMigrationOpportunities(Trigger.New);
    
    if(Trigger.isAfter && Trigger.isInsert && ALL_CheckRecursive.runCodeBlockOnce('ALL_DealState_Handler_AfterInsert'))
    {
        system.debug('here in opportunity insert trigger');
        DS_Opportunity_Handler.AddSalesTeam(OpportunitiesToProcess);
        //2016-09-30  ragashalini.koka@cdk.com - referenced the above method to create opportunity locations
        DS_Opportunity_Handler.addOpportunityLocations(Trigger.New);
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
        
        CPQ_DataConsent_Helper.updateProductDataConsent(Trigger.New);
        //2016-10-25 ragashalini.koka - added code to set ownership changes on Opportunity Locations for the RQ-08086
        if(Trigger.isAfter )
        {
            if((Trigger.isInsert || Trigger.isUpdate) && ALL_CheckRecursive.runCodeBlockOnce('DS_Opportunity_Handler_AfterInsertUpdate'))
            {
                DS_Opportunity_Handler.handleOwnershipChanges(Trigger.old, Trigger.new, Trigger.isInsert);
            }
        }
    }
    
    
    //2016-09-26 ragashalini.koka@cdk.com - updates owner hierarchy fields on opportunity - RQ-07879
    //2017-02-06 ragashalini.koka@cdk.com - Added the missing code for RQ-08532
    if(Trigger.isBefore) 
    {
        if((Trigger.isInsert || Trigger.isUpdate) && ALL_CheckRecursive.runCodeBlockOnce('DS_Opportunity_Handler_BeforeInsertUpdate'))
        {
            //2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
            Map<String, String> contactToCRMap = new Map<String, String> ();
            contactToCRMap.put('CB_Dealership_Primary_Contact__c', 'Contact_Relationship__c');
            ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'AccountId', null, contactToCRMap);
            DS_Opportunity_Handler.updateOwnerHierarchy(Trigger.old, Trigger.new, Trigger.isInsert);
            
        }
    }
}