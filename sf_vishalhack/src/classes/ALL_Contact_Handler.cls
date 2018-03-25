// rq-05034 : 2016-01-07 combine contact triggers (all of them into one)  
// RQ-04894 : Trigger on Contact to set User.ContactId when Contact.User__c is ins/upd
// 2014-04-21 - siva.pragada@cdk.com - contactsetdonotfields
// 2015-07-02 - vishal.bandari@cdk.com - updated updateUser method to meet RQ-04894 requirement
// 2015-08-27 - brian.cook@cdk.com, bill.thurow@cdk.com
// 2015-09-24 - anirudh.singh@cdk.com- Added the IF Condition, as Trigger.New is not available for before delete, after delete.
// 2016-02-03 - venkata.shrivol@cdk.com - Commented out the UpdateContactInfo method as it is a duplicate of DS_CDKGlobalAccountContacts_Handler.updateUser
// 2016-02-04 - venkata.shrivol@cdk.com	- Commented out afterUpdateFromAccount method as same method is already in DSCB_SetDoNotFields apex class.
//              we can uncomment later if needed.
//2016-02-25- anirudh.singh@cdk.com- Modified for changes as per Request RQ-06383 Modify Contact Trigger that sets Vendor ID on User...to Set Hire Date when chgs
//                                   and also corrected the variable naming, indentation standards.
// 2016-05-24 - matt.keefe@cdk.com - Commented out call to ALL_ContactRelationship_Helper in beforeUpdate method as it is no longer needed and was causing
//              an error due to a field no longer existing (HR_Manager_Relationship__c).           
// 2016-05-25 - lalitha.adduru@cdk.com - removed out call to  ALL_ContactRelationship_Helper as it's not longer needed on contact object  
global with sharing class ALL_Contact_Handler 
{ 
    //This method is invoked from the All_Contact trigger for before Insert scenario.
    public static void beforeInsert(List<Contact> newContactList)
    {
        beforeInsert_DS(newContactList);
        beforeInsert_DSCB(newContactList);
    }
    
    private static void updateUserLocation(List<Contact> newContactList, Map<Id, contact> oldContactMap)
    {
        List<User> usersToUpdate = new List<User>();
        List<Id> contactIdList = new List<Id>();
        for(Contact newContact : newContactList)
        {
            if(newContact.HR_Location__c != oldContactMap.get(newContact.Id).HR_Location__c)
            {
                contactIdList.add(newContact.Id);
            }
        }
        List<user> userList =  new List<user>();
        userList = [
          SELECT id, Location__c, EMP_Contact__c
          FROM User
          WHERE EMP_Contact__c in :contactIdList
        ];
        Map<Id, user> contactToUserMap = new Map<Id, user>();
        for(User correspondingUser : userList)
        {
        	contactToUserMap.put(correspondingUser.EMP_Contact__c, correspondingUser);    
        }
        
        for(Contact newContact : newContactList)
        {
            if(contactToUserMap.get(newContact.Id) != null)
            {
                contactToUserMap.get(newContact.Id).Location__c = newContact.HR_Location__c;
                usersToUpdate.add(contactToUserMap.get(newContact.Id));
            }
        }
        
        if(!usersToUpdate.isEmpty())
        {
            update usersToUpdate;
        }
    }
    //This method is invoked from the beforeInsert method.
    private static void beforeInsert_DS(List<Contact> newContactList) 
    {
        //get the custom settings to determine if this trigger should run on every inserted/updated Contact
        CustomSettings__c settings=CustomSettings__c.getInstance();
        
        //List<RecordType> recordTypeObjectList=[SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Internal HR Contact'];
        //note that dml operation on recordType cannot be performed, so the else check in below ternary operator is negligible  
        //RecordType recordTypeObject=recordTypeObjectList.size() > 0 ? recordTypeObjectList.get(0): new RecordType(); 
        
        Id recordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        
        //loop through all Contacts to be processed by the trigger.
        List<Contact> filteredContactsList=new List<Contact>();
        
        for(Contact contactRecord: newContactList) 
        {
            if(contactRecord.AccountId!=settings.CDK_Global_Account_Id__c) 
            {
                //process all contacts.
                filteredContactsList.add(contactRecord);
            }
            else
            {
                if(recordTypeId!=Null)
                {
                    contactRecord.RecordTypeId=recordTypeId;
                }
            }
        }
        
        //2016-02-09 -venkata.shrivol@cdk.com -placed this if condition from original DS_ContactBeforeInsertUpdate trigger. 
        //								 		preventDuplicateContacts method is taken out from that trigger.
        if(!settings.DS_ContactBeforeInsertUpdate_On__c)
        {
            return;
        }
        
        // 2016-04-28 -venkata.shrivol@cdk.com - commented this method call; RQ-06910
        //preventDuplicateContacts(filteredContactsList, settings);
    }
    
    //This method is invoked from the beforeInsert method.
    private static void beforeInsert_DSCB(List<Contact> newContactList)
    {
        List<Contact> contactsList=new List<Contact>();
        List<String> accountIdsList=new List<String>();
        
        if(newContactList==Null || newContactList.IsEmpty()) 
        { 
            return; 
        } 
        
        for(Contact contactRecord: newContactList) 
        {
            accountIdsList.add(contactRecord.AccountId); 
        }
        
        Map<Id, Account> accountMap=new Map<Id, Account>([
            Select Id, Name, Do_Not_Solicit__c, Do_Not_Fax__c 
            From Account 
            Where Id IN :accountIdsList
        ]);
        
        for(Contact contactRecord: newContactList)
        {
            if(accountMap!=Null && !accountMap.IsEmpty() && accountMap.containskey(contactRecord.AccountId))
            {
                Account accountRecord=accountMap.get(contactRecord.AccountId);
                
                //contactsList=setContactDoNotFields(contactsList, contactRecord, accountRecord);
                
                if(accountRecord.Do_Not_Solicit__c == true && contactRecord.Do_Not_Solicit__c != true)
                {
                	contactRecord.Do_Not_Solicit__c = true;    
                }
                if(accountRecord.Do_Not_Fax__c == true && contactRecord.Do_Not_Fax__c!=true)
                {
                    contactRecord.Do_Not_Fax__c = true;
                }
            }
        }
    }
    
    //This method is invoked from the All_Contact trigger for before Update scenario.
    public static void beforeUpdate(List<Contact> newContactList, Map<Id, Contact> oldContactMap)
    {
        //2016-04-28 -venkata.shrivol@cdk.com -commented this method call; RQ-06910 
        //beforeUpdate_ALL(newContactList, oldContactMap);
        beforeUpdate_DS(newContactList);
    }
    
    //This method is invoked from the beforeUpdate method.
    private static void beforeUpdate_DS(List<Contact> newContactList)
    {
        //get the custom settings to determine if this trigger should run on every inserted/updated Contact
        CustomSettings__c settings=CustomSettings__c.getInstance();
        //List<RecordType> recordTypeObjectList=[SELECT Id FROM RecordType WHERE SobjectType='Contact' AND Name='Internal HR Contact'];
        //RecordType recordTypeObject=recordTypeObjectList.size() > 0 ? recordTypeObjectList.get(0): new RecordType();
        
        Id recordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact', 'Internal HR Contact');
        
        //loop through all Contacts to be processed by the trigger 
        List<Contact> filteredContactsList=new List<Contact>();
        
        for(Contact contactRecord: newContactList)
        {
            if(contactRecord.AccountId!=settings.CDK_Global_Account_Id__c) 
            {
                //process all contacts.
                filteredContactsList.add(contactRecord);
            }
            else
            {
                if(recordTypeId!=Null)
                {
                    contactRecord.RecordTypeId=recordTypeId;
                }
            }
        }
        //2016-02-09 -venkata.shrivol@cdk.com -placed this if condition from original DS_ContactBeforeInsertUpdate trigger. 
        //								 		preventDuplicateContacts method is taken out from that trigger.
        if(!settings.DS_ContactBeforeInsertUpdate_On__c)
        {
            return;
        }
        
        //2016-04-28 -venkata.shrivol@cdk.com -commented this method call; RQ-06910
        //preventDuplicateContacts(filteredContactsList, settings);
    }
    
    //This method is invoked from the All_Contact trigger for before Delete scenario.
    public static void beforeDelete_DS(Map<Id, Contact> oldContactMap) 
    {
        //for(Contact contactRecord: oldContactList) 
        //{
        //    if(contactRecord.Authorized_Contract_Signer__c==true)
        //    {
        //        contactRecord.addError('ERROR: Contacts designated as Authorized Contract Signers can not be deleted!');
        //    }
        //}
        
        for(Contact contactRecord: [
            select Id, 
            (
                select Id 
                from Contact_Relationships__r 
                where Authorized_Contract_Signer__c = true
            ) 
            from Contact 
            where Id IN :oldContactMap.keySet()
        ])
        {
            if(contactRecord.Contact_Relationships__r.size() > 0)
            {
                Contact triggerRecord = oldContactMap.get(contactRecord.Id); 
                triggerRecord.addError(
                    'ERROR: CONTACT CANNOT BE DELETED! '+
                    'Either one or all child Contact relationship records has designated Authorized Contract Signer.'
                );
            }
        }
    }
    
    //This method is invoked from the All_Contact trigger for after Insert scenario.
    public static void afterInsert(List<Contact> newContactList, Map<Id, Contact> oldContactMap)
    {
        //UpdateContactInfo(newContactList, newContactMap);
        DS_CDKGlobalAccountContacts_Handler.updateUser(newContactList, oldContactMap);
    }
    
    //This method is invoked from the All_Contact trigger for after Update scenario.
    public static void afterUpdate(List<Contact> newContactList, Map<Id, Contact> oldContactMap)
    {
        //UpdateContactInfo(newContactList, oldContactMap);
       
        system.debug('I am called inside afterUpdate--->');
        if(ALL_CheckRecursive.runCodeBlockOnce('afterUpdate_ALL'))
        {
            //ragashalini.koka@cdk.com - Added this to if block
            DS_CDKGlobalAccountContacts_Handler.updateUser(newContactList, oldContactMap);
            afterUpdate_ALL(newContactList, oldContactMap);
            updateUserLocation(newContactList, oldContactMap);
        }
       // updateUserLocation(newContactList, oldContactMap);
    }
    
    //This method is invoked from the afterUpdate method.
    public static void afterUpdate_ALL(List<Contact> newContactList, Map<Id, Contact> oldContactMap)
    {
        Map<Id, Contact> changedContactMap=new Map<Id, Contact>();
        Set<Id> existingChildRecordAccountIds=new Set<Id>(); 
        Set<Id> accountIdsToCheck=new Set<Id>();
        Set<Id> existingContactIds=new Set<Id>();
        List<Contact_Relationship__c> recsToBeInserted=new List<Contact_Relationship__c>();
        List<Contact_Relationship__c> recsToBeUpdated=new List<Contact_Relationship__c>();
        
        for(Contact contactRecord: newContactList)
        {
            Contact oldContact=oldContactMap.get(contactRecord.Id);
            if(contactRecord.AccountId!=oldContact.AccountId && contactRecord.AccountId!=null)
            {
                changedContactMap.put(contactRecord.Id, contactRecord);
                accountIdsToCheck.add(contactRecord.AccountId);
            }
        }
        
        if(!changedContactMap.keySet().isEmpty())
        {
            for(Contact_Relationship__c crt: [
                select Id, Account__c, Contact__c 
                from Contact_Relationship__c 
                where Account__c IN :accountIdsToCheck
                and Contact__c IN :changedContactMap.keySet()
            ])
            {
                existingChildRecordAccountIds.add(crt.Account__c); 
                existingContactIds.add(crt.Contact__c);
            } 
        }
        
        for(Id contactId: changedContactMap.keySet())
        {
            Id accountId=changedContactMap.get(contactId).AccountId;
            if(!existingChildRecordAccountIds.contains(accountId) && !existingContactIds.contains(contactId))
            {
                Contact_Relationship__c crt=new Contact_Relationship__c();
                crt.Account__c=changedContactMap.get(contactId).AccountId;
                crt.Contact__c=contactId;
                recsToBeInserted.add(crt);
            }
        }
        
        try
        {
            insert recsToBeInserted;
        }
        catch(Exception ex)
        {
        	system.debug('Exception Thrown---->'+ex.getMessage());    
        }
    }
    
    //2016-04-28 -venkata.shrivol@cdk.com -commented this method call; RQ-06910
    //This method is invoked from the beforeInsert_DSCB method.
    /*private static List<Contact> setContactDoNotFields(List<Contact> contactsList, Contact contactRecord, Account accountRecord)
    {
        Boolean doNotFaxCondition=accountRecord.Do_Not_Fax__c==true && contactRecord.Do_Not_Fax__c!=true;
        Boolean doNotSolicitCondition=accountRecord.Do_Not_Solicit__c==true && contactRecord.Do_Not_Solicit__c!=true;
        
        if(doNotFaxCondition)
        {
            contactRecord.Do_Not_Fax__c=true;
        }
        
        if(doNotSolicitCondition)
        {
            contactRecord.Do_Not_Solicit__c=true;
        }
        
        if(doNotFaxCondition || doNotSolicitCondition)
        {
            contactsList.add(contactRecord);
        }
        
        return contactsList;
    }*/
    
    //2016-04-28 -venkata.shrivol@cdk.com -RQ-06910;commented this method and moved to contact relationship handler
    //This method is invoked from the beforeUpdate method.
    /*private static void beforeUpdate_ALL(List<Contact> newContactList, Map<Id, Contact> oldContactMap)
    {
        for(Contact contactRecord: newContactList) 
        {
            Contact oldContactRecord=oldContactMap.get(contactRecord.Id) ;
            
            if(oldContactRecord!=Null) 
            {
                if(contactRecord.Status__c=='Inactive' && oldContactRecord.Status__c!='Inactive') 
                {
                    contactRecord.No_Longer_There__c=true;
                }
                
                if(contactRecord.Status__c=='Active' && oldContactRecord.Status__c!='Active') 
                {
                    contactRecord.No_Longer_There__c=false;
                }
                
                //contactRecord.No_Longer_There__c==true && oldContactRecord.No_Longer_There__c!=true
                if(contactRecord.No_Longer_There__c && !oldContactRecord.No_Longer_There__c) 
                {
                    contactRecord.Status__c='Inactive';
                }
                
                //contactRecord.No_Longer_There__c==false && oldContactRecord.No_Longer_There__c!=false
                if(!contactRecord.No_Longer_There__c && oldContactRecord.No_Longer_There__c) 
                {
                    contactRecord.Status__c='Active';
                }
            }
        }
    }*/
    
    //2016-04-28 -venkata.shrivol@cdk.com -commented this method call; RQ-06910
    //This method is invoked from the beforeInsert_DS and beforeUpdate_DS methods.
    //We do not want duplicate contacts - this is also called from account trigger
    /*private static void preventDuplicateContacts(List<Contact> contactsList, CustomSettings__c settings)
    {
        //CustomSettings__c settings=CustomSettings__c.getInstance();
        if(settings!=Null)
        {
            
        }
        
        //2015-12-02 vishal.bandari@cdk.com initiated to avoid Null pointer exception
        List<Account> accountsList=new List<Account>();
        
        Map<Id, List<Contact>> accountIdAndContactsMap=new Map<Id, List<Contact>>();
        
        for(Contact contactRecord: contactsList)
        {
            if(contactRecord.AccountId!=Null)
            {
                if(!accountIdAndContactsMap.containsKey(contactRecord.AccountId)) 
                {
                    //create a new List of Contacts for that Account
                    List<Contact> newContactList=new List<Contact>();
                    
                    //add the current contact to the List.
                    newContactList.add(contactRecord);
                    
                    //put the List in the Account map for reference later
                    accountIdAndContactsMap.put(contactRecord.AccountId, newContactList); 
                }
                //if the Contact belongs to an Account that has ALREADY been processed
                else 
                {
                    //add the Contact to the Set of Contacts to check for duplicates later
                    accountIdAndContactsMap.get(contactRecord.AccountId).add(contactRecord);
                } 
            }   
        }
        
        if(!accountIdAndContactsMap.isEmpty())
        {
            accountsList=[
                Select Id, Name, (
                    Select Id, Email, FirstName, LastName, No_Longer_There__c, Status__c, AccountId, Account.Name 
                    From Contacts
                ) 
                From Account 
                Where Id IN :accountIdAndContactsMap.keySet()
            ]; 
        }
        
        //for each Account for the trigger Contacts to be inserted/updated
        for(Account accountRecord: accountsList) 
        {
            //get the trigger Contacts for the current Account
            List<Contact> contactsForAccountList=accountIdAndContactsMap.get(accountRecord.Id);
            
            //process through all of the trigger Contacts for the Account
            for(Contact contactRecord: contactsForAccountList) 
            {
                //get the previous Contacts on the Account
                List<Contact> allContactsForAccountList=accountRecord.getSObjects('Contacts');
                
                //if there are previous Contacts on the Account
                if(allContactsForAccountList!=Null) 
                {
                    //2016-02-25- anirudh.singh@cdk.com- Commented the TriggerEmail variable as it is not used anywhere.
                    //String TriggerEmail=contactRecord.Email;
                    String contactFirstName=contactRecord.FirstName;
                    String contactLastName=contactRecord.LastName;
                    
                    //process through all previous Contacts on the Account
                    for(Contact contactRef: allContactsForAccountList) 
                    {
                        //2016-02-25- anirudh.singh@cdk.com- Commented the PreviousEmail variable as it is not used anywhere.
                        //String PreviousEmail=contactRef.Email;
                        String previousFirstName=contactRef.FirstName;
                        String previousLastName=contactRef.LastName;
                        
                        //2016-02-25- anirudh.singh@cdk.com- Commented the TriggerFirstInitial and PreviousFirstInitial as they are not used anywhere.
                        //String TriggerFirstInitial='';
                        //String PreviousFirstInitial='';
                        
                        //2016-02-25- anirudh.singh@cdk.com- Commented the below code as TriggerFirstInitial is not used anywhere.
                        //set the first initial
                        //if(contactFirstName!=Null) 
                        //{
                        //    TriggerFirstInitial=contactFirstName.substring(0,1); 
                        //}
                        
                        //2016-02-25- anirudh.singh@cdk.com- Commented the below code as TriggerFirstInitial is not used anywhere.
                        //if(previousFirstName!=Null) 
                        //{ 
                        //    PreviousFirstInitial=previousFirstName.substring(0,1); 
                        //}
                        
                        //some contacts have a ' - LEFT' appended to their name, the compare should ignore this substring
                        Pattern leftPattern=Pattern.compile('(.*)[ ]*-+[ ]*(LEFT|left)$');
                        
                        //remove any ' - LEFT' from the previous contact to be compared against
                        if(previousLastName!=Null) 
                        {
                            Matcher leftMatcher=leftPattern.matcher(previousLastName);
                            if(leftMatcher.matches()) 
                            { 
                                previousLastName=leftMatcher.group(1).trim(); 
                            }
                        }
                        
                        //remove any ' - LEFT' from the trigger contact
                        if(contactLastName!=Null) 
                        {
                            Matcher leftMatcher=leftPattern.matcher(contactLastName);
                            if(leftMatcher.matches()) 
                            {
                                contactLastName=leftMatcher.group(1).trim();
                            }
                        }
                        
                        //the current trigger Contact should not be compared against itself if the trigger is invoked by an update
                        //(if it is an update, the current trigger Contact will be in the Account Contacts List retrieved by SOQL)
                        if(contactRecord.Id!=contactRef.Id)
                        {
                            //if both the Account Contact and the Trigger Contact are not "no longer there"(or if either are still there)
                            if((!contactRef.No_Longer_There__c && !contactRecord.No_Longer_There__c)
                               || (!contactRef.No_Longer_There__c && !contactRecord.No_Longer_There__c 
                                   && contactRef.Status__c!='Active' && contactRecord.Status__c!='Active'))
                            {
                                if(contactRef.Account.Name!=settings.CDK_Global_Account_Id__c)
                                {
                                    //if the current trigger Contact FirstName and LastName matches any previous Contact FirstName and LastName, add an error
                                    if(contactFirstName+contactLastName==previousFirstName+previousLastName)
                                    { 
                                        contactRecord.FirstName.addError('Duplicate Contacts (on First Name and Last Name) are not allowed on Accounts. ');
                                        contactRecord.LastName.addError('Duplicate Contacts (on First Name and Last Name) are not allowed on Accounts. '); 
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }*/
    
    //2016-05-31- anirudh.singh@cdk.com- Commented the method signature. Earlier the whole method body was commented but the signature line was not commented.
    /*public static void UpdateContactInfo(List<Contact> newList, Map<Id,Contact> om)
    {
        // if om is null then load with contact object
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
                         
        }
    }*/
    
    //2016-05-31- anirudh.singh@cdk.com- Commented the method signature. Earlier the whole method body was commented but the signature line was not commented.
    /*public static void afterUpdateFromAccount(Map<Id,Account> nm, Map<Id,Account> om) 
    {
        list<Contact> AccCon = new List<Contact>();
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
        }
    }*/
}