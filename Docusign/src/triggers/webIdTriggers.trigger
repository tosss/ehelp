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
*/

trigger webIdTriggers on WebID__c (after insert, after update, after delete, after undelete) 
{
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
        if(CB_EntitlementsToWebIdAssignment_Handler.isFirstRun)
        {
            CB_EntitlementsToWebIdAssignment_Handler.isFirstRun = false;
            if(Trigger.isAfter && Trigger.isInsert)
            {
                CB_EntitlementsToWebIdAssignment_Handler.createEntitlementOnInsert(Trigger.newMap);
            }
            else if(Trigger.isAfter && Trigger.isUpdate)
            {
                CB_EntitlementsToWebIdAssignment_Handler.createEntitlementOnUpdate(Trigger.oldMap, Trigger.newMap);
            }
    	}
    }
    //---------05/11/15 Commented out by Venkata - RQ-04229----------------
    //27th Nov, 2014: Added by Anirudh.
    //This is added for populating Account Advocate field on Account record from WebId Record associated with the Account Record.
     /* //A set is taken to hold the uinque account records.
        //This is done as one or many WebID records may be associated to a Account record and thus, there can be a redundancy if we create a list.
        Set<String> accountRecords=new Set<String>();
        
        //The WebId records getting inserted or updated are iterated.
        for(WebID__c webIDRecords: Trigger.New)
        {
            //If the Account Advocate field value in the WebID Record is not Null.
            //The Account associated to it is added the accountRecords set.
            if(webIDRecords.Account_Advocate__c!=Null)
            {
                accountRecords.add(webIDRecords.Account__c);
            }
        }
        
        //Account records are fecthed whose Id is present in the set accountRecords and in which Account Advocate field value is Null.
        List<Account> accountsList=[SELECT Account_Advocate__c FROM Account WHERE Id IN :accountRecords AND Account_Advocate__c=Null];
        
        //A list of Accounts is initialized that needs to be updated after population of Account Advocate field value.
        List<Account> accountsToBeUpdatedList=new List<Account>();
        
        //The accountsList is iterated.
        for(Account accRecord: accountsList)
        {
            //The WebId records getting inserted or updated are iterated.
            for(WebID__c webIDRecords: Trigger.New)
            {
                //If the Account Advocate field value on the Account record is Null, then only the the value of Account Advocate field is populated on the Account record.
                if(accRecord.Account_Advocate__c==Null)
                {
                    accRecord.Account_Advocate__c=webIDRecords.Account_Advocate__c;
                    accountsToBeUpdatedList.add(accRecord);
                    break;
                }
            }
        }
        
        //The list of Accounts is updated.
        update accountsToBeUpdatedList;*/
      
}