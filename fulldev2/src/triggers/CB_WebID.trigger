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
//2016-01-21- anirudh.singh@cdk.com- Created this Trigger to replace trigger webIdTriggers, as per Request RQ-06027 Trigger on WebIDs update to follow standards.
//2016-02-10- anirudh.singh@cdk.com- Removed the before insert, before update, after undelete as these were not used and caused useless processing.
trigger CB_WebID on WebID__c(after insert, after update, after delete)
{
    //ALL_UtilitiesLogic.triggerOrderOfExecution('CB_WebID');
    //If the general CustomSettings__c WebIDTriggers_On__c checkbox is checked, process through the Trigger
    CustomSettings__c settings = CustomSettings__c.getInstance();
    
    if(settings!=Null && settings.WebIDTriggers_On__c)
    {
        if(Trigger.isAfter)
        {
            //2016-02-25- anirudh.singh@cdk.com- Added the condition (ALL_CheckRecursive.runCodeBlockOnce('WebID_AfterInsertUpdateDelete') || test.isRunningTest()) in the below IF Block.
            if((ALL_CheckRecursive.runCodeBlockOnce('WebID_AfterInsertUpdateDelete') || test.isRunningTest()) && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete))
            {
                CB_WebID_Handler.initializeAndProcessRecords('WebID__c', Trigger.oldMap, Trigger.newMap);
            }
        }
    }
    
    if(Trigger.isAfter)
    {
        //2016-02-25- anirudh.singh@cdk.com- Added the condition (ALL_CheckRecursive.runCodeBlockOnce('WebID_AfterInsert') || test.isRunningTest()) in the below IF Block.
        // To Update or Create Entitlements to WebId's
        if((ALL_CheckRecursive.runCodeBlockOnce('WebID_AfterInsert') || test.isRunningTest()) && Trigger.isInsert)
        {
            CB_WebID_Handler.processWebIdsAfterInsert(Trigger.newMap);
        }
        //2016-02-25- anirudh.singh@cdk.com- Added the condition (ALL_CheckRecursive.runCodeBlockOnce('WebID_AfterUpdate') || test.isRunningTest()) in the below ELSE IF Block.
        else if((ALL_CheckRecursive.runCodeBlockOnce('WebID_AfterUpdate') || test.isRunningTest()) && Trigger.isUpdate)
        {    
            CB_WebID_Handler.processWebIdsAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }  
    }
}