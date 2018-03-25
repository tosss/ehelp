public with sharing class DSCB_SetDoNotFields 
{
    public static list<Contact> SetContactDoNotFields(list<Contact> ContactsToUpdate, Contact c, Account a)
    {
        Boolean DoNotFax = a.Do_Not_Fax__c == true && c.Do_Not_Fax__c != true;
        Boolean DoNotSolicit = a.Do_Not_Solicit__c == true && c.Do_Not_Solicit__c != true;
        
        if(DoNotFax) { c.Do_Not_Fax__c = true; }
        if(DoNotSolicit) { c.Do_Not_Solicit__c = true; }
        
        if(DoNotFax || DoNotSolicit) { ContactsToUpdate.add(c); }
        
        return ContactsToUpdate;
    }
    
    public static void AfterUpdateContactFromAccount(Map<Id, Account> newMap, Map<Id, Account> oldMap)
    {
        list<Contact> AccountContacts = new List<Contact>();
        list<Contact> ContactsToUpdate = new List<Contact>();
        map<Id, Account> AccountsToProcess = new map<Id, Account>();
        
        for(Id AccountId : newMap.keySet())
        {
            Account NewAccount = newMap.get(AccountId);
            Account OldAccount = oldMap.get(AccountId);
            
            if(NewAccount != null && OldAccount != null
            && (NewAccount.Do_Not_Fax__c != OldAccount.Do_Not_Fax__c || NewAccount.Do_Not_Solicit__c != OldAccount.Do_Not_Solicit__c))
            {
                AccountsToProcess.put(AccountId, NewAccount);
            }
        }
        
        AccountContacts = [
            select AccountId, Do_Not_Fax__c, Do_Not_Solicit__c 
            from Contact 
            where AccountId IN :AccountsToProcess.keySet()
        ];
        
        if(AccountContacts != null && !AccountContacts.IsEmpty()) 
        {
            for(Contact c : AccountContacts) 
            {
                Account a = AccountsToProcess.get(c.AccountId);
                ContactsToUpdate = SetContactDoNotFields(ContactsToUpdate, c, a);
            }
        }
        
        if(!ContactsToUpdate.IsEmpty()){       
            update ContactsToUpdate;
        }
    }
    
    public static void BeforeInsertContactFromContact(list<Contact> ContactNew)
    {
        list<Contact> ContactsToUpdate = new list<Contact>();
        list<String> AccountIdsList = new list<String> ();
        
        if(ContactNew == null || ContactNew.IsEmpty()) { return; } 
        
        for (Contact c : ContactNew) {
            AccountIdsList.add(c.AccountId); }
        
        map<Id, Account> AccountMap = new map<Id, Account> ([
            Select Id, Name, Do_Not_Solicit__c, Do_Not_Fax__c 
            From Account 
            Where Id IN :AccountIdsList
        ]);
        
        for (Contact c : ContactNew)
        {
            if (AccountMap != null && !AccountMap.IsEmpty() 
            && AccountMap.containskey(c.AccountId))
            {
                Account a = AccountMap.get(c.AccountId);
                
                ContactsToUpdate = SetContactDoNotFields(ContactsToUpdate, c, a);
            }
        }
        
        // update call not necessary in a before trigger
    }
}