// Created by Hemanth Kesapragada for RQ-03180
public class DS_SyncAccountAddress_Handler 
{ 
    public static void ProcessBeforeFuture(map<ID, Account> newAccountMap, map<ID, Account> oldAccountMap)
    {
        Boolean AllowAddressUpdate = false;
        
        for(Account a: newAccountMap.values())
        {
            Account OldAccount = oldAccountMap.get(a.Id);
            
            if(a.BillingCity != OldAccount.BillingCity || a.BillingCountry != OldAccount.BillingCountry ||
               a.BillingPostalCode != OldAccount.BillingPostalCode || a.BillingState != OldAccount.BillingState ||
               a.BillingStreet != OldAccount.BillingStreet || a.Location_County__c != OldAccount.Location_County__c)
            {
                AllowAddressUpdate = true; break;
            }
        }
        
        //DS_SyncAccountAddress_Handler.syncAddress(Trigger.new);
        Boolean NoAsynchronousProcess = !system.isBatch() && !system.isFuture() && !system.isScheduled();
        
        if(NoAsynchronousProcess && AllowAddressUpdate && (All_CheckRecursive.runCodeBlockOnce('syncAddressFuture_After') || Test.isRunningTest()))
        {
            DS_SyncAccountAddress_Handler.syncAddressFuture(newAccountMap.keySet());
        }        
    }
    
    @future
    public static void syncAddressFuture(Set<ID> AccountIdSet)
    {
        Map<Id,Account> accountMap; 
        string cdkGlobalAccId = CustomSettings__c.getInstance(userInfo.getOrganizationId()).CDK_Global_Account_Id__c; //[select CDK_Global_Account_Id__c from CustomSettings__c];
        List<Contact> ContactsToUpdate = new List<Contact>();
        list<Contact> DividedList = new list<contact>();
        //Skip CDK Global Account          
        
        for(ID id: AccountIdSet)
        {
            if(id == (ID)cdkGlobalAccId)
            {
                AccountIdSet.remove(id);
            }
        }
        
        accountMap = new Map<Id,Account>([
            Select Id, BillingCity, BillingStreet, BillingState, BillingPostalCode, BillingCountry, Location_County__c,
            
            (Select Id, MailingCity, Mailingstreet, Mailingstate, Mailingpostalcode, Mailingcountry, Status__c,
             No_Longer_There__c, County__c, AccountId
             From Contacts),
            //06-15-2016 sanjay.ghanathey@cdk.com No Longer There field must be fetched from Contact Relationship
            (Select Id,No_Longer_There__c from Contact_Relationships__r)
            
            From Account 
            Where Id IN :AccountIdSet
        ]);
        
        if(accountMap != null && !accountMap.isEmpty())
        {
            for(string AccId: accountMap.keySet())
            {
                Account CurrentAccount = accountMap.get(AccId);
                
                if(CurrentAccount != null)
                {
                    list<Contact> ContactList = CurrentAccount.Contacts;
                    
                    if(ContactList != null && !ContactList.isEmpty())
                    {
                        for(contact c: ContactList)
                        {                               
                            //06-15-2016 sanjay.ghanathey@cdk.com No Longer There was replaced with Status
                            if(c.Status__c != 'Inactive' )
                            {                          
                                c.MailingCity = CurrentAccount.BillingCity;
                                c.MailingStreet = CurrentAccount.BillingStreet;
                                c.MailingState = CurrentAccount.BillingState;
                                c.MailingPostalCode = CurrentAccount.BillingPostalCode;
                                c.MailingCountry = CurrentAccount.BillingCountry;
                                c.County__c = CurrentAccount.Location_County__c;
                                
                                ContactsToUpdate.add(c);
                            }                            
                        }
                    }
                }
            }
        }
        
        if(ContactsToUpdate != null && !ContactsToUpdate.isEmpty())
        {
            // this should be good for 10,000 records at a time, if this exceeds 10,000 practically, we could divide and
            // use dml statements upto 150 in this future call alone, maximum could be like 10,000 * 150 = 1,500,000           
            
            DataBase.SaveResult[] Results = Database.Update(ContactsToUpdate, false); 
            
            if(Results != null && !Results.isEmpty())
            {
                for(DataBase.SaveResult sr: Results)
                {
                    if(sr.isSuccess())
                    {
                        system.debug(sr.getId() + ' Is Successfully Updated');
                    }
                    else
                    {
                        for(DataBase.Error de: sr.getErrors())
                        {
                            if(de.getMessage() != null)
                            {                                  
                                system.debug(de.getMessage());                                    
                            }
                        }
                    }
                }
            }            
        }         
    }
}