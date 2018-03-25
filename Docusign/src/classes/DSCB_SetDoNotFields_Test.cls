@IsTest
public class DSCB_SetDoNotFields_Test
{
    static testMethod void SetDoNotFields()
    {
        Account a = DS_TestObjects.NewAccount_Inserted(); 
        Contact c = DS_TestObjects.NewContact_Inserted(); 
        c.FirstName = 'Test';
        c.AccountId = a.Id;
        update c;
        
        // test Contact set method
        list<Contact> ContactsToUpdate = new list<Contact>();
        DSCB_SetDoNotFields.SetContactDoNotFields(ContactsToUpdate, c, a);
        
        Account NewAccount = a.clone(true, true); // create a cloned account with the same Id to set the newmap values
        NewAccount.Do_Not_Fax__c = true;
        NewAccount.Do_Not_Solicit__c = true;
        
        // test Account Trigger method
        map<Id, Account> AccountNewMap = new map<Id, Account>(); AccountNewMap.put(a.Id, NewAccount);
        map<Id, Account> AccountOldMap = new map<Id, Account>(); AccountOldMap.put(a.Id, a);
        DSCB_SetDoNotFields.AfterUpdateContactFromAccount(AccountNewMap, AccountOldMap);
        
        // test Contact Trigger method
        list<Contact> ContactNewMap = new list<Contact>(); ContactNewMap.add(c);
        DSCB_SetDoNotFields.BeforeInsertContactFromContact(ContactNewMap);
    }
}