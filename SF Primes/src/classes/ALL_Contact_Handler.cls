// rq-05034 : 2016-01-07 combine contact triggers (all of them into one)  
// RQ-04894 : Trigger on Contact to set User.ContactId when Contact.User__c is ins/upd
// 2014-04-21 - siva.pragada@cdk.com - contactsetdonotfields
// 2015-07-02 - vishal.bandari@cdk.com - updated updateUser method to meet RQ-04894 requirement
// 2015-08-27 - brian.cook@cdk.com, bill.thurow@cdk.com
// 2015-09-24- anirudh.singh@cdk.com- Added the IF Condition, as Trigger.New is not available for before delete, after delete.
// 2016-02-03 - venkata.shrivol@cdk.com - Commented out the UpdateContactInfo method as it is a duplicate of DS_CDKGlobalAccountContacts_Handler.updateUser
// 2016-02-04 - venkata.shrivol@cdk.com	- Commented out afterUpdateFromAccount method as same method is already in DSCB_SetDoNotFields apex class.
//                                        we can uncomment later if needed. 


global with sharing class ALL_Contact_Handler 
{ 
    public static void beforeInsert(list<Contact> newList)
    {
        beforeInsert_DS(newList);
        beforeInsert_DSCB(newList); 
    }
    public static void beforeInsert_DS(list<Contact> newList) 
    {
        // get the custom settings to determine if this trigger should run on every inserted/updated Contact
        CustomSettings__c settings = CustomSettings__c.getInstance();
        
        //list<RecordType> recordTypeObjectList = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name = 'Internal HR Contact'];
        //note that dml operation on recordType cannot be performed, so the else check in below ternary operator is negligible  
        //RecordType recordTypeObject = recordTypeObjectList.size() > 0 ? recordTypeObjectList.get(0) : new RecordType(); 
        
        Id recordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        
        
        // loop through all Contacts to be processed by the trigger 
        List<Contact> triggerContacts = new List<Contact>();
        for(Contact c : newList) 
        {
            if(c.AccountId != settings.CDK_Global_Account_Id__c) 
            {
                triggerContacts.add(c); // process all contacts
            }
            else
            {
                if(recordTypeId!=null)
                {
                    c.RecordTypeId = recordTypeId;
                }
            }
        }
        
        //2016-02-09 -venkata.shrivol@cdk.com -placed this if condition from original DS_ContactBeforeInsertUpdate trigger. 
        //								 		preventDuplicateContacts method is taken out from that trigger.
        if(!settings.DS_ContactBeforeInsertUpdate_On__c) { return; }
        
        
        preventDuplicateContacts(triggerContacts, settings);
    }
    public static void beforeInsert_DSCB(list<Contact> newList)
    {
        list<Contact> ConToUpd = new list<Contact>();
        list<String> AccIdList = new list<String> ();
        
        if(newlist == null || newlist.IsEmpty()) 
        { 
            return; 
        } 
        
        for (Contact con : newlist) 
        {
            AccIdList.add(con.AccountId); 
        }
        
        map<Id, Account> AccMap = new map<Id, Account> ([
            Select Id, Name, Do_Not_Solicit__c, Do_Not_Fax__c 
            From Account 
            Where Id IN :AccIdList
        ]);
        
        for (Contact con : newlist)
        {
            if (AccMap != null && !AccMap.IsEmpty() 
                && AccMap.containskey(con.AccountId))
            {
                Account acc = AccMap.get(con.AccountId);
                
                ConToUpd = SetContactDoNotFields(ConToUpd, con, acc);
            }
        }
    }
    public static void beforeUpdate(List<Contact> newList, Map<Id,Contact> om)
    {
        beforeUpdate_ALL(newList, om);
        beforeUpdate_DS(newList);    
    }
    
    public static void beforeDelete_DS(list<Contact> newList, map<Id, Contact> om) 
    {
        for(Contact con : newList) 
        {
            if(con.Authorized_Contract_Signer__c == true)
            {
                con.addError('ERROR: Contacts designated as Authorized Contract Signers can not be deleted!');
            }
        }
    }
    
    public static void afterInsert(List<Contact> newList, Map<Id,Contact> om)
    {
        //UpdateContactInfo(newList, om);
        DS_CDKGlobalAccountContacts_Handler.updateUser(newList, om);
    }
    
    public static void afterUpdate(List<Contact> newList, Map<Id,Contact> om)
    {
       // UpdateContactInfo(newList, om);
        DS_CDKGlobalAccountContacts_Handler.updateUser(newList, om);
    }
    // end main 
    
    public static void UpdateContactInfo(List<Contact> newList, Map<Id,Contact> om)
    {
       /* // if om is null then load with contact object
        om = (om == null ? new Map<Id,Contact>():om);
        map<Id, Contact> newMap = new map<Id, Contact>();
        
        for(Contact c : newList) 
        {
            if(c.AccountId == CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c) 
            {
                newMap.put(c.Id,c);
            }
        }
        Map<Id, Id> userToContactMap=new Map<Id, Id>();
        List<Id> requiredUserIds = new List<Id>();
        
        for(Contact cr: newMap.values()) 
        {
            if(cr.User__c != null) 
            {
                userToContactMap.put(cr.User__c, cr.Id);
                requiredUserIds.add(cr.User__c);
            }
            
            Contact oldContact = om.get(cr.Id);
            if(oldContact != null && oldContact.User__c != null) 
            { 
                requiredUserIds.add(oldContact.User__c);	
            }
        }
        // Initializing the userMap with required Users.
        Map<Id, User>   userMap=new Map<Id,User>([
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c 
            FROM User 
            WHERE Id IN: requiredUserIds
        ]);
        
        // Set EmpUser population 
        for(User EmpUser : userMap.values()) 
        {
            if(EmpUser.Emp_Contact__c == null) 
            { 
                EmpUser.Emp_Contact__c = userToContactMap.get(EmpUser.Id); 
            }
        }
        
        //Updating user records of Previous Contacts User__c
        for(Contact newCon : newMap.values()) 
        {
            Contact oldCon = om.get(newCon.Id);
            if(oldCon !=null && (newCon.User__c != oldCon.User__c)) 
            {
                User userRec = userMap.get(oldCon.User__c);
                if(userRec != null) 
                { 
                    userRec.Contact_Vendor_Id__c = ''; 	
                    userMap.put(userRec.id,userRec); 
                }
            }
            //Updating user records of Current Contacts User__c
                  
            if(newCon.User__c != null) 
            {
                User newUser = userMap.get(newCon.User__c);
                
                if(newUser!=null && newCon.Vendor_ID__c != newUser.Contact_Vendor_Id__c ) 
                {
                    newUser.Contact_Vendor_Id__c = newCon.Vendor_ID__c;
                    userMap.put(newUser.Id,newUser);
                }
            }
                         
        }*/
    }
    
    private static void beforeUpdate_ALL (List<Contact> newList, Map<Id, Contact> om)
    {
        for(Contact nc : newList) 
        {
            Contact oc = om.get(nc.Id) ;
            
            if(oc != null) 
            {
                if( nc.Status__c == 'Inactive' && oc.Status__c != 'Inactive' ) 
                {
                    nc.No_Longer_There__c = true;
                }
                if( nc.Status__c == 'Active' && oc.Status__c != 'Active' ) 
                {
                    nc.No_Longer_There__c = false;
                }
                if (nc.No_Longer_There__c && !oc.No_Longer_There__c) 
                {	//nc.No_Longer_There__c == true && oc.No_Longer_There__c != true
                    nc.Status__c = 'Inactive';
                }
                if (!nc.No_Longer_There__c && oc.No_Longer_There__c) 
                {	// nc.No_Longer_There__c == false && oc.No_Longer_There__c != false 
                    nc.Status__c = 'Active';
                }
            }
        }
    }
    
    private static void beforeUpdate_DS(list<Contact> newList)
    {
        // get the custom settings to determine if this trigger should run on every inserted/updated Contact
        CustomSettings__c settings = CustomSettings__c.getInstance();
        //list<RecordType> recordTypeObjectList = [SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name = 'Internal HR Contact'];
        //RecordType recordTypeObject = recordTypeObjectList.size() > 0 ? recordTypeObjectList.get(0) : new RecordType();
        //
        //
        Id recordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        // loop through all Contacts to be processed by the trigger 
        List<Contact> triggerContacts = new List<Contact>();
        for(Contact c : newList) {
            if(c.AccountId != settings.CDK_Global_Account_Id__c ) 
            {
                triggerContacts.add(c); // process all contacts
            }
            else
            {
                if(recordTypeId!=null)
                {
                    c.RecordTypeId = recordTypeId;
                }
            }
        }
        //2016-02-09 -venkata.shrivol@cdk.com -placed this if condition from original DS_ContactBeforeInsertUpdate trigger. 
        //								 		preventDuplicateContacts method is taken out from that trigger.
        if(!settings.DS_ContactBeforeInsertUpdate_On__c) { return; }
        
        preventDuplicateContacts(triggerContacts, settings);
        
    }
    
    
    public static void afterUpdateFromAccount(Map<Id,Account> nm, Map<Id,Account> om) 
    {
        /*list<Contact> AccCon = new List<Contact>();
        list<Contact> ConToUpd = new List<Contact>();
        map<Id, Account> AccToProcess = new map<Id, Account>();
        
        for(Id AccId : nm.keySet())
        {
            Account NewAcc = nm.get(AccId);
            Account OldAcc = om.get(AccId);
            
            if(NewAcc != null && OldAcc != null
               && (NewAcc.Do_Not_Fax__c != OldAcc.Do_Not_Fax__c || NewAcc.Do_Not_Solicit__c != OldAcc.Do_Not_Solicit__c))
            {
                AccToProcess.put(AccId, NewAcc);
            }
        }
        
        AccCon = [
            select AccountId, Do_Not_Fax__c, Do_Not_Solicit__c 
            from Contact 
            where AccountId IN :AccToProcess.keySet()
        ];
        
        if(AccCon != null && !AccCon.IsEmpty()) 
        {
            for(Contact con : AccCon) 
            {
                Account acc = AccToProcess.get(con.AccountId);
                ConToUpd = SetContactDoNotFields(ConToUpd, con, acc);
            }
        }
        
        if(!ConToUpd.IsEmpty()){       
            update ConToUpd;
        }*/
    }
    public static list<Contact> SetContactDoNotFields(list<Contact> ConToUpd, Contact con, Account acc)
    {
        Boolean DoNotFax = acc.Do_Not_Fax__c == true && con.Do_Not_Fax__c != true;
        Boolean DoNotSolicit = acc.Do_Not_Solicit__c == true && con.Do_Not_Solicit__c != true;
        
        if(DoNotFax) { con.Do_Not_Fax__c = true; }
        
        if(DoNotSolicit) { con.Do_Not_Solicit__c = true; }
        
        if(DoNotFax || DoNotSolicit) { ConToUpd.add(con); }
        
        return ConToUpd;
    }   
    
    // We do not want duplicate contacts - this is also called from account trigger
    public static void preventDuplicateContacts(list<Contact> cList,  CustomSettings__c settings){
        //CustomSettings__c settings = CustomSettings__c.getInstance();
        if(settings!=null)
        {
            
        }
         
        
        //2015-12-02 vishal.bandari@cdk.com initiated to avoid null pointer exception
        list<Account> triggerAccounts = new List<Account>();
        
        Map<Id, list<Contact>> TriggerContactsByAccountId = new Map<Id,List<Contact>>();
        
        for(Contact c: cList){
            if(c.AccountId != null) {
                if(!TriggerContactsByAccountId.containsKey(c.AccountId)) 
                {
                    // create a new list of Contacts for that Account
                    List<Contact> AccountContactSet = new List<Contact>();
                    AccountContactSet.add(c); // add the current contact to the list
                    
                    // put the list in the Account map for reference later
                    TriggerContactsByAccountId.put(c.AccountId,AccountContactSet); 
                }
                // if the Contact belongs to an Account that has ALREADY been processed
                else 
                {
                    // add the Contact to the Set of Contacts to check for duplicates later
                    TriggerContactsByAccountId.get(c.AccountId).add(c);
                } 
            }   
        }
        
        if(!TriggerContactsByAccountId.isEmpty())
        {
            TriggerAccounts = [
                Select Id, Name, (
                    Select Id, Email, FirstName, LastName, No_Longer_There__c, Status__c, AccountId, Account.Name 
                    From Contacts
                ) 
                From Account 
                Where Id IN :TriggerContactsByAccountId.keySet()
            ]; 
        }
        
        // for each Account for the trigger Contacts to be inserted/updated
        for(Account TriggerAccount : TriggerAccounts) 
        {
            // get the trigger Contacts for the current Account
            List<Contact> ListTriggerContacts = TriggerContactsByAccountId.get(TriggerAccount.Id);
            
            // process through all of the trigger Contacts for the Account
            for(Contact TriggerContact : ListTriggerContacts) 
            {
                // get the previous Contacts on the Account
                List<Contact> AllAccountContacts = TriggerAccount.getSObjects('Contacts');
                
                // if there are previous Contacts on the Account
                if(AllAccountContacts != null) 
                {
                    String TriggerEmail = TriggerContact.Email;
                    String TriggerFirstName = TriggerContact.FirstName;
                    String TriggerLastName = TriggerContact.LastName;
                    
                    // process through all previous Contacts on the Account
                    for(Contact AccountContact : AllAccountContacts) 
                    {
                        String PreviousEmail = AccountContact.Email;
                        String PreviousFirstName = AccountContact.FirstName;
                        String PreviousLastName = AccountContact.LastName;
                        String TriggerFirstInitial = '';
                        String PreviousFirstInitial = '';
                        
                        // set the first initial
                        if(TriggerFirstName != null) 
                        {
                            TriggerFirstInitial = TriggerFirstName.substring(0,1); 
                        }
                        if(PreviousFirstName != null) 
                        { 
                            PreviousFirstInitial = PreviousFirstName.substring(0,1); 
                        }
                        
                        // some contacts have a ' - LEFT' appended to their name, the compare should ignore this substring
                        Pattern LeftPattern = Pattern.compile('(.*)[ ]*-+[ ]*(LEFT|left)$');
                        
                        // remove any ' - LEFT' from the previous contact to be compared against
                        if(PreviousLastName != null) 
                        {
                            Matcher LeftMatcher = LeftPattern.matcher(PreviousLastName);
                            if(LeftMatcher.matches()) 
                            { 
                                PreviousLastName = LeftMatcher.group(1).trim(); 
                            }
                        }
                        
                        // remove any ' - LEFT' from the trigger contact
                        if(TriggerLastName != null) 
                        {
                            Matcher LeftMatcher = LeftPattern.matcher(TriggerLastName);
                            if(LeftMatcher.matches()) 
                            {
                                TriggerLastName = LeftMatcher.group(1).trim(); }
                        }
                        
                        // the current trigger Contact should not be compared against itself if the trigger is invoked by an update
                        // (if it is an update, the current trigger Contact will be in the Account Contacts list retrieved by SOQL)
                        if(TriggerContact.Id != AccountContact.Id) {
                            // if both the Account Contact and the Trigger Contact are not "no longer there" (or if either are still there)
                            if((!AccountContact.No_Longer_There__c && !TriggerContact.No_Longer_There__c)
                               || (!AccountContact.No_Longer_There__c && !TriggerContact.No_Longer_There__c 
                                   && AccountContact.Status__c != 'Active' && TriggerContact.Status__c != 'Active'))
                            {
                                if(AccountContact.Account.Name != settings.CDK_Global_Account_Id__c) {
                                    // if the current trigger Contact FirstName and LastName matches any previous Contact FirstName and LastName, add an error
                                    if(TriggerFirstName+TriggerLastName == PreviousFirstName+PreviousLastName) { 
                                        TriggerContact.FirstName.addError('Duplicate Contacts (on First Name and Last Name) are not allowed on Accounts. ');
                                        TriggerContact.LastName.addError('Duplicate Contacts (on First Name and Last Name) are not allowed on Accounts. '); 
                                    }
                                }
                            }
                        }
                    } 
                    // end for AllAccountContacts (previous Contacts on the Account)
                }
            } 
            // end for ListTriggerContacts (trigger Contacts being inserted/updated)
        }
    }   
}