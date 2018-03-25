trigger CB_LaunchUpdateEmails on Launch__c (before insert, before update) 
{
    List<Launch__c> LaunchesToUpdate = new List<Launch__c>();
    
    Set<Id> AccountsToQuery = new Set<Id>();
    Set<Id> WebIDsToQuery = new Set<Id>();
    
    // loop through updated records
    for(Launch__c l : Trigger.new) 
    {
        if(l.CreatedDate <= DateTime.now())
        {
            LaunchesToUpdate.add(l);
            if(l.Account__c != null) { AccountsToQuery.add(l.Account__c); }
            if(l.WebID__c != null) { WebIDsToQuery.add(l.WebID__c); }
        }
    }
    
    system.debug(AccountsToQuery);
    
    // query the Account fields for the collected Launch Accounts
    Map<Id, Account> Accounts = new Map<Id, Account>();
    if(!AccountsToQuery.IsEmpty()) {
        Accounts = new Map<Id, Account>([
            Select Id, Designated_DSM__r.Email, Digital_Services_CAM__r.Email 
            From Account Where Id IN :AccountsToQuery]); }
    
    // query the WebID fields for the collected Launch WebIDs
    Map<Id, WebID__c> WebIDs = new Map<Id, WebID__c>();
    if(!WebIDsToQuery.IsEmpty()) {
        WebIDs = new Map<Id, WebID__c>([
            Select Id, Account_Advocate__r.Email, OwnerMktg_Specialist_lookup__r.Email, Online_Marketing_Specialist__r.Email, 
                Reputation_Management_Specialist__r.Email, SEO_Specialist__r.Email, Social_Media_Specialist__r.Email 
            From WebID__c Where Id IN :WebIDsToQuery]); }
    
    if(!LaunchesToUpdate.IsEmpty()) 
    {
        for(Launch__c l : LaunchesToUpdate)
        {
            Account a = Accounts.get(l.Account__c);
            WebID__c w = WebIDs.get(l.WebID__c);
            
            if(a != null)
            {
                l.DSM_Email__c = a.Designated_DSM__r.Email; 
                l.CAM_Email__c = a.Digital_Services_CAM__r.Email; 
                //l.GAM_Email__c = a.Digital_Services_GAM__r.Email; 
            }
            
            if(w != null)
            {
                l.Advocate_Email__c = w.Account_Advocate__r.Email; 
                l.EMS_Email__c = w.OwnerMktg_Specialist_lookup__r.Email; 
                l.OMS_Email__c = w.Online_Marketing_Specialist__r.Email; 
                l.RMS_Email__c = w.Reputation_Management_Specialist__r.Email; 
                l.SEO_Email__c = w.SEO_Specialist__r.Email; 
                l.SMS_Email__c = w.Social_Media_Specialist__r.Email; 
            }
        }
    }
}