public with sharing class DS_ValidateActivity
{
    public static String BAC_ErrorMessage = 'The BAC Number entered does not match '
        + 'any Business Site BAC on the associated Account. '
        + 'Please ensure that Account is not blank if you enter a BAC value. ';
    
    // add an error specifically to the BAC field if the Activity is a Task or Event
    public static void BAC_AddActivityError(sObject Activity, String ErrorMessage)
    {
        String sObjectType = String.valueOf(Activity.getSObjectType());
        if(sObjectType == 'Task') { Task t = (Task) Activity; t.BAC__c.addError(ErrorMessage); }
        else if(sObjectType == 'Event') { Event e = (Event) Activity; e.BAC__c.addError(ErrorMessage); }
        else { Activity.addError(ErrorMessage); } 
    }
    
    // main method (factory): validate 
    public static void Validate(List<sObject> TasksOrEvents)
    {
        //  +- Account Id
        //  v   v- Activity Record
        Map<Id, List<sObject>> Activities = BAC_FilterActivitiesByAccountId(TasksOrEvents);
        
        //  +- Account Id
        //  v   v- Set of BAC Numbers
        Map<Id, Set<String>> BACNumbers = BAC_QueryValidBACsByAccountId(Activities.keySet());
        
        // process validation
        BAC_ProcessActivities(Activities, BACNumbers);
    }
    
    public static List<sObject> AddContactDataToActivities(List<sObject> Activities)
    {
    	List<Id> ContactIds = new List<Id>();
    	
    	for(sObject Activity : Activities) {
            Id WhoId = (Id) Activity.get('WhoId');
            if(WhoId != null && String.valueOf(WhoId).startsWith('003')) { 
            	ContactIds.add(WhoId); }
    	}
    	
    	// query Contacts
    	Map<Id, Contact> Contacts = new Map<Id, Contact>(
    	    [Select Id, AccountId From Contact Where Id IN :ContactIds]);
		
		//system.debug(Contacts);
		
		for(sObject Activity : Activities) {
	        Id WhoId = (Id) Activity.get('WhoId');
            if(WhoId != null && String.valueOf(WhoId).startsWith('003')) { 
            	Activity.putSObject('Who', Contacts.get(WhoId)); }
		}
    	
    	return Activities;
    }
    
    // get the Activity Account Id by checking both The AccountId and WhatId fields
    public static Id GetActivityAccountId(sObject Activity)
    {
        Id ActivityAccountId = null;
        
        if(Activity != null)
        {
            Id AccountId = (Id) Activity.get('AccountId');
            Id WhatId = (Id) Activity.get('WhatId'); 
            Id WhoId = (Id) Activity.get('WhoId');
            
            if(WhatId != null && !String.valueOf(WhatId).startsWith('001')) { WhatId = null; } // Accounts ONLY
            if(WhoId != null && !String.valueOf(WhoId).startsWith('003')) { WhoId = null; } // Contacts ONLY
            
            if(AccountId != null) { 
            	ActivityAccountId = AccountId; }
            else if(WhatId != null) { 
            	ActivityAccountId = WhatId; }
            else if(WhoId != null) { 
            	ActivityAccountId = (Id) ALL_UtilitiesData.GetDataFromNestedFields('Who.AccountId', Activity); }
            //else { } // not needed ActivityAccountId is already null
        }
        
        return ActivityAccountId;
    }
    
    // get a Map of Activities (by Account Id) that match the processing criteria
    public static Map<Id, List<sObject>> BAC_FilterActivitiesByAccountId(List<sObject> Activities)
    {
        //  +- Account Id
        //  v   v- Activity Record
        Map<Id, List<sObject>> ActivitiesByAccountId = new Map<Id, List<sObject>>();
        
        if(Activities != null && !Activities.IsEmpty())
        {
        	Activities = AddContactDataToActivities(Activities);
        	
            for(sObject Activity : Activities) 
            { 
                //system.debug(Activity);
                
                Id ActivityAccountId = GetActivityAccountId(Activity);
                
                String ActivityBAC = (String) Activity.get('BAC__c');
                
                if(ActivityBAC != null)
                {
                    //system.debug(ActivityBAC);
                    
                    // if there is a BAC and there is an Account
                    if(ActivityAccountId != null) 
                    { 
                        // add the Activity to the Map of Activities by Accounts (for processing)
                        if(ActivitiesByAccountId.get(ActivityAccountId) == null) {
                            ActivitiesByAccountId.put(ActivityAccountId, new List<sObject>{Activity}); }
                        else {
                            ActivitiesByAccountId.get(ActivityAccountId).add(Activity); }
                    }
                    // if there is a BAC but no Account was found
                    else { 
                        BAC_AddActivityError(Activity, BAC_ErrorMessage);
                    }
                }
            }
        }
        
        return ActivitiesByAccountId;
    }
    
    // query all valid BACs and return a set of number by Account Id in a map
    public static Map<Id, Set<String>> BAC_QueryValidBACsByAccountId(Set<Id> AccountIds)
    {
        //  +- Account Id
        //  v   v- Set of BAC Numbers
        Map<Id, Set<String>> BACNumbersByAccountId = new Map<Id, Set<String>>();
        
        // get the Business Sites (for a list of valid BACs) from the Account Ids on the Activities
        List<Business_Site__c> BusinessSites = new List<Business_Site__c>();
        if(AccountIds != null && !AccountIds.IsEmpty()) {
            BusinessSites = [
                Select Id, Name, Account__c, BAC__c 
                From Business_Site__c 
                Where Account__c IN :AccountIds
            ]; 
        }
        
        // put together a Map of Business Sites by Account Id
        if(BusinessSites != null && !BusinessSites.IsEmpty())
        {
            for(Business_Site__c b : BusinessSites) 
            {
                if(BACNumbersByAccountId.get(b.Account__c) == null) { 
                    Set<String> SiteNames = new Set<String>(); SiteNames.add(b.BAC__c); 
                    BACNumbersByAccountId.put(b.Account__c, SiteNames); }
                else {
                    BACNumbersByAccountId.get(b.Account__c).add(b.BAC__c); }
            }
        }
        //system.debug(BACNumbersByAccountId);
        
        return BACNumbersByAccountId;
    }
    
    public static void BAC_ProcessActivities(
        Map<Id, List<sObject>> ActivitiesByAccountId, Map<Id, Set<String>> BACNumbersByAccountId)
    {
        // if there are Activities to process
        if(ActivitiesByAccountId != null && !ActivitiesByAccountId.IsEmpty())
        {
            // for all of the Activities (listed in a map by Account Id)
            for(Id AccountId : ActivitiesByAccountId.keySet()) 
            {
                // get all Activities for the Account
                List<sObject> Activities = ActivitiesByAccountId.get(AccountId);
                //system.debug(Activities);
                
                // for each Activity
                for(sObject Activity : Activities)
                {
                    // get all Business Site BAC Numbers
                    Set<String> CurrentBACs = BACNumbersByAccountId.get(AccountId);
                    String ActivityBAC = (String) Activity.get('BAC__c');
                    
                    if(ActivityBAC != null) 
                    {
                        // if there are no BACs for the Account
                        if(CurrentBACs == null 
                        // or if BAC is not in the Set
                        || (CurrentBACs != null && !CurrentBACs.contains(ActivityBAC))) { 
                            BAC_AddActivityError(Activity, BAC_ErrorMessage); // add an error message to the current Activity
                        }
                    }
                }
            } // end for
        } // end if
    } // end method
}