//rq-05034: 2016-01-07 combine contact triggers (all of them into one)  
//RQ-04894: Trigger on Contact to set User.ContactId when Contact.User__c is ins/upd
//2014-04-21 - siva.pragada@cdk.com - contactsetdonotfields
//2015-07-02 - vishal.bandari@cdk.com - updated updateUser method to meet RQ-04894 requirement
//2015-08-27 - brian.cook@cdk.com, bill.thurow@cdk.com
//2015-09-24- anirudh.singh@cdk.com- Added the IF Condition, as Trigger.New is not available for before delete, after delete.
//2016-02-03 - venkata.shrivol@cdk.com - Commented out the UpdateContactInfo method as it is a duplicate of DS_CDKGlobalAccountContacts_Handler.updateUser
//2016-02-04 - venkata.shrivol@cdk.com	- Commented out afterUpdateFromAccount method as same method is already in DSCB_SetDoNotFields apex class.
//                                       we can uncomment later if needed. 
//2016-02-25- anirudh.singh@cdk.com- Modified for changes as per Request RQ-06383 Modify Contact Trigger that sets Vendor ID on User...to Set Hire Date when chgs
//                                   and also corrected the variable naming, indentation standards.
global with sharing class ALL_Contact_Handler
{
    //This method is invoked from the All_Contact trigger for before Insert scenario.
    public static void beforeInsert(List<Contact> newContactList)
    {
        beforeInsert_DS(newContactList);
        beforeInsert_DSCB(newContactList); 
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
        
        preventDuplicateContacts(filteredContactsList, settings);
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
                
                contactsList=setContactDoNotFields(contactsList, contactRecord, accountRecord);
            }
        }
    }
    
    //This method is invoked from the beforeInsert_DSCB method.
    private static List<Contact> setContactDoNotFields(List<Contact> contactsList, Contact contactRecord, Account accountRecord)
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
    }
    
    //This method is invoked from the All_Contact trigger for before Update scenario.
    public static void beforeUpdate(List<Contact> newContactList, Map<Id, Contact> oldContactMap)
    {
        beforeUpdate_ALL(newContactList, oldContactMap);
        beforeUpdate_DS(newContactList);    
    }
    
    //This method is invoked from the beforeUpdate method.
    private static void beforeUpdate_ALL(List<Contact> newContactList, Map<Id, Contact> oldContactMap)
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
        
        preventDuplicateContacts(filteredContactsList, settings);
    }
    
    //This method is invoked from the All_Contact trigger for before Delete scenario.
    public static void beforeDelete_DS(List<Contact> oldContactList, Map<Id, Contact> oldContactMap) 
    {
        for(Contact contactRecord: oldContactList) 
        {
            if(contactRecord.Authorized_Contract_Signer__c==true)
            {
                contactRecord.addError('ERROR: Contacts designated as Authorized Contract Signers can not be deleted!');
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
        system.debug('newContactList---->'+newContactList);
        system.debug('oldContactMap---->'+oldContactMap);
        DS_CDKGlobalAccountContacts_Handler.updateUser(newContactList, oldContactMap);
    } 
    
    //This method is invoked from the beforeInsert_DS and beforeUpdate_DS methods.
    //We do not want duplicate contacts - this is also called from account trigger
    private static void preventDuplicateContacts(List<Contact> contactsList, CustomSettings__c settings)
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
    }
    
    public static void UpdateContactInfo(List<Contact> newContactList, Map<Id,Contact> om)
    {
       /* //if om is Null then load with contact object
        om=(om==Null ? new Map<Id,Contact>():om);
        Map<Id, Contact> newMap=new Map<Id, Contact>();
        
        for(Contact c: newContactList) 
        {
            if(c.AccountId==CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c) 
            {
                newMap.put(c.Id,c);
            }
        }
        Map<Id, Id> userToContactMap=new Map<Id, Id>();
        List<Id> requiredUserIds=new List<Id>();
        
        for(Contact cr: newMap.values()) 
        {
            if(cr.User__c!=Null) 
            {
                userToContactMap.put(cr.User__c, cr.Id);
                requiredUserIds.add(cr.User__c);
            }
            
            Contact oldContact=om.get(cr.Id);
            if(oldContact!=Null && oldContact.User__c!=Null) 
            { 
                requiredUserIds.add(oldContact.User__c);	
            }
        }
        //Initializing the userMap with required Users.
        Map<Id, User>   userMap=new Map<Id,User>([
            SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c 
            FROM User 
            WHERE Id IN: requiredUserIds
        ]);
        
        //Set EmpUser population 
        for(User EmpUser: userMap.values()) 
        {
            if(EmpUser.Emp_Contact__c==Null) 
            { 
                EmpUser.Emp_Contact__c=userToContactMap.get(EmpUser.Id); 
            }
        }
        
        //Updating user records of Previous Contacts User__c
        for(Contact newCon: newMap.values()) 
        {
            Contact oldCon=om.get(newCon.Id);
            if(oldCon !=Null && (newCon.User__c!=oldCon.User__c)) 
            {
                User userRec=userMap.get(oldCon.User__c);
                if(userRec!=Null) 
                { 
                    userRec.Contact_Vendor_Id__c=''; 	
                    userMap.put(userRec.id,userRec); 
                }
            }
            //Updating user records of Current Contacts User__c
                  
            if(newCon.User__c!=Null) 
            {
                User newUser=userMap.get(newCon.User__c);
                
                if(newUser!=Null && newCon.Vendor_ID__c!=newUser.Contact_Vendor_Id__c ) 
                {
                    newUser.Contact_Vendor_Id__c=newCon.Vendor_ID__c;
                    userMap.put(newUser.Id,newUser);
                }
            }
                         
        }*/
    }
    
    public static void afterUpdateFromAccount(Map<Id,Account> nm, Map<Id,Account> om) 
    {
        /*List<Contact> AccCon=new List<Contact>();
        List<Contact> ConToUpd=new List<Contact>();
        Map<Id, Account> AccToProcess=new Map<Id, Account>();
        
        for(Id AccId: nm.keySet())
        {
            Account NewAcc=nm.get(AccId);
            Account OldAcc=om.get(AccId);
            
            if(NewAcc!=Null && OldAcc!=Null
               && (NewAcc.Do_Not_Fax__c!=OldAcc.Do_Not_Fax__c || NewAcc.Do_Not_Solicit__c!=OldAcc.Do_Not_Solicit__c))
            {
                AccToProcess.put(AccId, NewAcc);
            }
        }
        
        AccCon=[
            select AccountId, Do_Not_Fax__c, Do_Not_Solicit__c 
            from Contact 
            where AccountId IN :AccToProcess.keySet()
        ];
        
        if(AccCon!=Null && !AccCon.IsEmpty()) 
        {
            for(Contact con: AccCon) 
            {
                Account acc=AccToProcess.get(con.AccountId);
                ConToUpd=setContactDoNotFields(ConToUpd, con, acc);
            }
        }
        
        if(!ConToUpd.IsEmpty()){       
            update ConToUpd;
        }*/
    }
}