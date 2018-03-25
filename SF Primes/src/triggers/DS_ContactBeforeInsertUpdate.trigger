// rq-05034 combine contact triggers into one (this is old trigger commenting out)
// 2015-08-27 - brian.cook@cdk.com, bill.thurow@cdk.com
/* ADP Dealer Services - Sales Automation
 * Programmer: Matt Keefe (matt_keefe@adp.com)
 * Trigger: DS_ContactBeforeInsertUpdate
 * Description: Prevents duplicate Contacts (matched on FirstName and LastName or Email address) from being inserted or updated
 * Test Class: DS_ContactBeforeInsertUpdateTest
 */ 
trigger DS_ContactBeforeInsertUpdate on Contact (before insert, before update) 
{
    // get the custom settings to determine if this trigger should run on every inserted/updated Contact
    //CustomSettings__c settings = CustomSettings__c.getInstance();
    
    // if the custom settings indicate that the trigger should NOT be turned on, do NOT process
    //if(!settings.DS_ContactBeforeInsertUpdate_On__c) { return; }
    
    // a holding variable for the Trigger Contacts to process
    //List<Contact> TriggerContacts = new List<Contact>();
    
    // if the Trigger is executing because of an Insert
    //if(Trigger.IsInsert) 
    //{
        // loop through all Contacts to be processed by the trigger 
    //    for(Contact c : Trigger.new)
    //    {
    //        if(c.AccountId != settings.CDK_Global_Account_Id__c)
    //        {
    //            TriggerContacts.add(c); // process all contacts
    //        }
    //    }
    //}
    // otherwise (Trigger is executing because of an Update), first check to see if key fields have changed
    //else
    //{
        // loop through all Contacts to be processed by the trigger 
    //    for(Contact c : Trigger.new)
    //    {
            // get the new and old values for the Contact
    //        Contact OldContact = Trigger.oldMap.get(c.Id);
    //        Contact NewContact = Trigger.newMap.get(c.Id);
            
            // only add the Contact to the processing list if the Email, FirstName, or LastName has changed
    //       if((OldContact.Email != NewContact.Email
    //        || OldContact.FirstName != NewContact.FirstName
    //        || OldContact.LastName != NewContact.LastName)
    //        && NewContact.AccountId != settings.CDK_Global_Account_Id__c)
    //        {
    //            TriggerContacts.add(c);
    //        }
    //    }
    //}
    
    //List<Account> TriggerAccounts = null;
    //Map<Id,List<Contact>> TriggerContactsByAccountId = new Map<Id,List<Contact>>();
    
    // for all Contacts to be processed by the trigger
    //for(Contact c : TriggerContacts)
    //{
    //    system.debug(c);
        
        // if the Contact has an Account associated
    //    if(c.AccountId != null)
    //    {
            // if the Contact belongs to an Account that has NOT already been processed
    //        if(!TriggerContactsByAccountId.containsKey(c.AccountId)) 
    //        {
                // create a new list of Contacts for that Account
    //            List<Contact> AccountContactSet = new List<Contact>();
    //            AccountContactSet.add(c); // add the current contact to the list
                
                // put the list in the Account map for reference later
    //            TriggerContactsByAccountId.put(c.AccountId,AccountContactSet); 
    //        }
            // if the Contact belongs to an Account that has ALREADY been processed
    //        else 
    //        {
                // add the Contact to the Set of Contacts to check for duplicates later
    //            TriggerContactsByAccountId.get(c.AccountId).add(c);
    //        }
    //    }
    //}
    
    // get all previous Contacts for the Accounts found
    //TriggerAccounts = [
    //    Select Id, Name, (
    //        Select Id, Email, FirstName, LastName, No_Longer_There__c, Status__c, AccountId, Account.Name 
    //        From Contacts
    //    ) 
    //    From Account 
    //    Where Id IN :TriggerContactsByAccountId.keySet()
    //];
    
    // for each Account for the trigger Contacts to be inserted/updated
    //for(Account TriggerAccount : TriggerAccounts)
    //{
        // get the trigger Contacts for the current Account
    //    List<Contact> ListTriggerContacts = TriggerContactsByAccountId.get(TriggerAccount.Id);
        
        // process through all of the trigger Contacts for the Account
    //    for(Contact TriggerContact : ListTriggerContacts)
    //    {
            // get the previous Contacts on the Account
    //        List<Contact> AllAccountContacts = TriggerAccount.getSObjects('Contacts');
            
            // if there are previous Contacts on the Account
    //        if(AllAccountContacts != null)
    //        {
    //            String TriggerEmail = TriggerContact.Email;
    //            String TriggerFirstName = TriggerContact.FirstName;
    //            String TriggerLastName = TriggerContact.LastName;
                
                // un-necessary b/c visualforce already trims and compares lowercase
                //if(TriggerEmail != null) { TriggerEmail = TriggerEmail.toLowerCase().trim(); }
                //if(TriggerFirstName != null) { TriggerFirstName = TriggerFirstName.toLowerCase().trim(); }
                //if(TriggerLastName != null) { TriggerLastName = TriggerLastName.toLowerCase().trim(); }
                
                // process through all previous Contacts on the Account
    //            for(Contact AccountContact : AllAccountContacts)
    //            {
    //                String PreviousEmail = AccountContact.Email;
    //                String PreviousFirstName = AccountContact.FirstName;
    //                String PreviousLastName = AccountContact.LastName;
                    
                    // un-necessary b/c visualforce already trims and compares lowercase
                    //if(PreviousEmail != null) { PreviousEmail = PreviousEmail.toLowerCase().trim(); }
                    //if(PreviousFirstName != null) { PreviousFirstName = PreviousFirstName.toLowerCase().trim(); }
                    //if(PreviousLastName != null) { PreviousLastName = PreviousLastName.toLowerCase().trim(); }
                    
    //                String TriggerFirstInitial = '';
    //                String PreviousFirstInitial = '';
                    
                    // set the first initial
    //                if(TriggerFirstName != null) { TriggerFirstInitial = TriggerFirstName.substring(0,1); }
    //                if(PreviousFirstName != null) { PreviousFirstInitial = PreviousFirstName.substring(0,1); }
                    
                    // some contacts have a ' - LEFT' appended to their name, the compare should ignore this substring
    //                Pattern LeftPattern = Pattern.compile('(.*)[ ]*-+[ ]*(LEFT|left)$');
                    
                    // remove any ' - LEFT' from the previous contact to be compared against
    //                if(PreviousLastName != null)
    //                {
    //                    Matcher LeftMatcher = LeftPattern.matcher(PreviousLastName);
    //                    if(LeftMatcher.matches()) { PreviousLastName = LeftMatcher.group(1).trim(); }
    //                }
                    
                    // remove any ' - LEFT' from the trigger contact
    //                if(TriggerLastName != null)
    //                {
    //                    Matcher LeftMatcher = LeftPattern.matcher(TriggerLastName);
    //                    if(LeftMatcher.matches()) { TriggerLastName = LeftMatcher.group(1).trim(); }
    //                }
                    
                    // the current trigger Contact should not be compared against itself if the trigger is invoked by an update
                    // (if it is an update, the current trigger Contact will be in the Account Contacts list retrieved by SOQL)
    //                if(TriggerContact.Id != AccountContact.Id)
    //                {
                        // if both the Account Contact and the Trigger Contact are not "no longer there" (or if either are still there)
    //                    if((!AccountContact.No_Longer_There__c && !TriggerContact.No_Longer_There__c)
    //                    || (!AccountContact.No_Longer_There__c && !TriggerContact.No_Longer_There__c 
    //                        && AccountContact.Status__c != 'Active' && TriggerContact.Status__c != 'Active'))
    //                    {
                            //system.debug('Trigger Email: '+TriggerEmail);
                            //system.debug('Previous Email: '+PreviousEmail);
                            //system.debug('Trigger First Initial: '+TriggerFirstInitial);
                            //system.debug('Previous First Initial: '+PreviousFirstInitial);
                            //system.debug('Trigger First Name: '+TriggerFirstName);
                            //system.debug('Previous First Name: '+PreviousFirstName);
                            //system.debug('Trigger Last Name: '+TriggerLastName);
                            //system.debug('Previous Last Name: '+PreviousLastName);
                            
                            // if the current trigger Contact Email, First Initial, and Last Name matches 
                            //   any previous Contact Email, First Initial, and Last Name add an error
                            //if(TriggerEmail != null
                            //&& TriggerEmail == PreviousEmail
                            //&& TriggerFirstInitial == PreviousFirstInitial
                            //&& TriggerLastName == PreviousLastName) {
                            //    TriggerContact.Email.addError(
                            //        'Duplicate Contacts (on E-mail, First Initial, and Last Name) are not allowed on Accounts. '); }
                            
    //                        if(AccountContact.Account.Name != settings.CDK_Global_Account_Id__c)
    //                      {
                                // if the current trigger Contact FirstName and LastName matches any previous Contact FirstName and LastName, add an error
    //                          if(TriggerFirstName+TriggerLastName == PreviousFirstName+PreviousLastName) 
    //                          { 
    //                              TriggerContact.FirstName.addError('Duplicate Contacts (on First Name and Last Name) are not allowed on Accounts. ');
    //                              TriggerContact.LastName.addError('Duplicate Contacts (on First Name and Last Name) are not allowed on Accounts. '); 
    //                          }
    //                      }
    //                  }
    //              }
    //          } // end for AllAccountContacts (previous Contacts on the Account)
    //      }
    //  } // end for ListTriggerContacts (trigger Contacts being inserted/updated)
    //} // end for TriggerAccounts (all Accounts for the trigger Contacts)
}