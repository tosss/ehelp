/*
    Updated: 2012-07-30 - Matt Keefe
      Change Description: 
        - Added WebID Account change functionality
          + When the WebID Account field is changed, all Account Team Members (for the desgnated WebID fields)
            are removed, and the Account Team Members are placed on the new WebID Account.
    
    Updated: 2012-03-12 - Matt Keefe
      Change Description: 
        - Completely re-wrote Trigger, moved code from external Apex Class to Trigger directly
        - Implemented Custom Settings to activate/deactive the Trigger and control the fields that are processed
        - Standardized field processing (some fields were processed differently)
        - Increased Trigger efficiency
          + only processes when key fields are changed
          + only attempts to insert new Account Team Members when necessary (if one does not already exist)
    
    Updated: 2013-06-27 - Matt Keefe
      Change Description:
        - Refactored Trigger into more reusable methods - for Trigger and Batch processing
        - Created a new class to house all functionality (CB_WebIDAccountTeamMembers)
        - Added more extensive testing
    
    Updated: 2014-11-27- Anirudh Singh - CODE Commented
        Change Description:
        -If a WebID record is added to an Account record and its Account Advocate field value is not Null,
        and the Account record does not have value in Account Advocate field. 
        Account Advocate field value should be populated on Account record from WebId Record.

    Updated 2015-02-25 Venkata Shrivol
          Change Description
            - Added Logic to create entitlements on Insert & Update depending on its Status
    
    Updated 2015-10-08 Venkata Shrivol
          Change Description
            - Modified boolean check on entitlements handler
    2015-11-16 siva.pragada@cdk.com STARTED WORKING....IN PROGRESS 
    
*/
//2016-02-10- anirudh.singh@cdk.com- Commented this Trigger as per Request RQ-06027 Trigger on WebIDs update to follow standards.
//2016-02-10- anirudh.singh@cdk.com- A new Trigger CB_WebID has been created. This Trigger will be deleted later.

trigger webIdTriggers on WebID__c (before insert, before update, after insert, after update, after delete, after undelete) 
{
    /*
    // if the general CustomSettings__c WebIDTriggers_On__c checkbox is checked, process through the Trigger
    CustomSettings__c Settings = CustomSettings__c.getInstance();
    
    if(Settings != null && Settings.WebIDTriggers_On__c)
    {
        CB_WebIDAccountTeamMembers sync = new CB_WebIDAccountTeamMembers();
        Map<Id, WebID__c> newMap = Trigger.newMap;
        Map<Id, WebID__c> oldMap = Trigger.oldMap;
        
        if(Trigger.isAfter)
        {
            // filter WebIDs based on whether or not any of the fields have (or the Account has) changed
            Set<Id> AccountIds = sync.FilterWebIDsToProcessFromWebIdTrigger(oldMap, newMap);
            List<Id> AccountIdsToProcess = new List<Id>(); AccountIdsToProcess.addAll(AccountIds);
            
            system.debug(AccountIds);
            // sync the WebID fields and the Account Team Members
            if(!AccountIdsToProcess.IsEmpty()) {
                sync.SyncAccountTeamAndWebIdUsers(AccountIdsToProcess); } 
        }
    }
    
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    {
        
       // To Update or Create Entitlements to WebId's
        if(ALL_CheckRecursive.runCodeBlockOnce('CB_EntitlementsToWebIdAssignment_Handler_ConditionAfterInsert') || test.isRunningTest())
        {
            if(Trigger.isAfter && Trigger.isInsert)
            {
                CB_EntitlementsToWebIdAssignment_Handler.createEntitlementOnInsert(Trigger.newMap);
            }
        }    
        if(ALL_CheckRecursive.runCodeBlockOnce('CB_EntitlementsToWebIdAssignment_Handler_ConditionAfterUpdate') || test.isRunningTest())
        {    
            if(Trigger.isAfter && Trigger.isUpdate)
            {
                CB_EntitlementsToWebIdAssignment_Handler.createEntitlementOnUpdate(Trigger.oldMap, Trigger.newMap);
            }
    	}
        
        if(ALL_CheckRecursive.runCodeBlockOnce('setAccountPlanFields20151119') || test.isRunningTest())
        {
            CB_WebID_Handler.setAccountPlanFields();
        }   
    }*/
}