trigger DSCB_AccountReLink on Account_ReLink__c (before insert, after insert) 
{
    if(Trigger.isBefore)
    {
        Map<String,Account_ReLink__c> PartyIds = new Map<String,Account_ReLink__c>();
        Map<String,Account_ReLink__c> CobaltIds = new Map<String,Account_ReLink__c>();
        
        for(Account_ReLink__c rl : Trigger.new)
        {
            if(rl.Relink_Date__c == null) // if Relink Date is NOT blank, do NOT process
            {
                if(rl.Party_ID__c == null) { 
                    rl.Party_ID__c.addError('Party ID must not be null.'); 
                }
                else {
                    PartyIds.put(rl.Party_ID__c,rl); 
                }
                
                if(rl.Cobalt_Account_Number__c == null) { 
                    rl.Cobalt_Account_Number__c.addError('Cobalt Account Number must not be null.'); 
                }
                else {
                    CobaltIds.put(rl.Cobalt_Account_Number__c,rl); 
                }
            }
        }
        
        system.debug(PartyIds);
        system.debug(CobaltIds);
        
        Map<String,Account> AccountsByPartyIds = new Map<String,Account>();
        List<String> PartyIdsToQuery = new List<String>(); PartyIdsToQuery.addAll(PartyIds.keyset());
        
        List<Account> PartyAccounts = [
            Select Id, Name, PartyID__c, Account_Number__c, 
                BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone 
            From Account Where PartyID__c IN :PartyIdsToQuery
        ];
        
        for(Account a : PartyAccounts) { AccountsByPartyIds.put(a.PartyID__c,a); }
        
        for(Account_ReLink__c rl : PartyIds.values())
        {
            Account a = AccountsByPartyIds.get(rl.Party_ID__c);
            
            if(a == null) { 
                rl.Party_ID__c.addError('Party ID is invalid.'); 
            }
            //else if(a.Id == rl.Cobalt_Account__c) {
            //  rl.Party_ID__c.addError('Party Account ('+a.Name+') and Cobalt Account must not match.'); 
            //}
            else {
                rl.Party_Account__c = a.Id;
                rl.Party_Account_Phone__c = a.Phone;
                rl.Party_Account_Street__c = a.BillingStreet;
                rl.Party_Account_City__c = a.BillingCity;
                rl.Party_Account_State__c = a.BillingState;
                rl.Party_Account_Zip_Code__c = a.BillingPostalCode;
                rl.Party_Account_Country__c = a.BillingCountry;
            }
        }
        
        Map<String,Account> AccountsByCobaltAccountNumbers = new Map<String,Account>(); 
        List<String> CobaltIdsToQuery = new List<String>(); CobaltIdsToQuery.addAll(CobaltIds.keyset());
        
        List<Account> CobaltAccounts = [
            Select Id, Name, PartyID__c, Account_Number__c, 
                BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone 
            From Account Where Account_Number__c IN :CobaltIdsToQuery];
        
        for(Account a : CobaltAccounts) { AccountsByCobaltAccountNumbers.put(a.Account_Number__c,a); }
        
        for(Account_ReLink__c rl : CobaltIds.values())
        {
            Account a = AccountsByCobaltAccountNumbers.get(rl.Cobalt_Account_Number__c);
            
            if(a == null) { 
                rl.Cobalt_Account_Number__c.addError('Cobalt Account Number is invalid.'); 
            }
            //else if(a.Id == rl.Party_Account__c) {
            //  rl.Cobalt_Account_Number__c.addError('Cobalt Account ('+a.Name+') and Party Account must not match.'); 
            //}
            else {
                rl.Cobalt_Account__c = a.Id;
                rl.Cobalt_Account_Phone__c = a.Phone;
                rl.Cobalt_Account_Street__c = a.BillingStreet;
                rl.Cobalt_Account_City__c = a.BillingCity;
                rl.Cobalt_Account_State__c = a.BillingState;
                rl.Cobalt_Account_Zip_Code__c = a.BillingPostalCode;
                rl.Cobalt_Account_Country__c = a.BillingCountry;
            }
        }
    }
    
    if(Trigger.isAfter)
    {
        // delete all previous ReLink details (case: when Accounts change on the ReLink)
        Set<Id> ReLinkIdsToDeleteDetails = new Set<Id>();
        List<Account_ReLink__c> ReLinksToProcess = new List<Account_ReLink__c>();
        
        for(Account_ReLink__c rl : Trigger.new)
        {
            Account_ReLink__c old_rl;
            if(Trigger.oldMap != null) { 
            	if(Trigger.oldMap.get(rl.Id) != null) { old_rl = Trigger.oldMap.get(rl.Id); } }
            else { old_rl = new Account_ReLink__c(); }
            
            if(rl.Account_Updated__c == 'False' || rl.Account_Updated__c == null)
            {
                if(rl.Cobalt_Account__c != old_rl.Cobalt_Account__c || rl.Party_Account__c != old_rl.Party_Account__c)
                {
                	// the below code is never true if this Trigger only executes on Insert
                    //if(Trigger.oldMap != null) {
                    //    if(rl.Cobalt_Account__c != old_rl.Cobalt_Account__c) { ReLinkIdsToDeleteDetails.add(rl.Id); } }
                    
                    if(rl.Cobalt_Account__c != null && rl.Party_Account__c != null) {
                        ReLinksToProcess.add(rl); }
                }
            }
        }
        
        // the below code is never true if this Trigger only executes on Insert
        //if(!ReLinkIdsToDeleteDetails.IsEmpty()) {
        //    delete [Select Id, Name From Account_ReLink_Detail__c Where Account_ReLink__c IN :ReLinkIdsToDeleteDetails]; }
        
        // process relinks into ReLink Detail records
        if(!ReLinksToProcess.IsEmpty()) {
            DSCB_AccountReLink.ProcessRelinks(ReLinksToProcess); }
    }
}