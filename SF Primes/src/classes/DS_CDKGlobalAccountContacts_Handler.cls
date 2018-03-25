//RQ-04894 : Trigger on Contact to set User.ContactId when Contact.User__c is ins/upd

//2015-07-02 : vishal.bandari@cdk.com - updated updateUser method to meet RQ-04894 requirement

public class DS_CDKGlobalAccountContacts_Handler 
{
    
    public static void updateUser(List<Contact> newContactTriggerList, Map<Id, Contact> oldContactsMap)
    {
        try
        {
            //Initialize oldMap if Trigger is insert.
            oldContactsMap = (oldContactsMap==null? new Map<Id,Contact>():oldContactsMap);
            
            
            //Filtering the CDK_  GLobal Account related Contacts
            map<Id, Contact> newContactsMap = new map<Id, Contact>();
            for(Contact c : newContactTriggerList) 
            {
                if(c.AccountId == CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c) {
                    newContactsMap.put(c.Id,c);
                }
            }
            
            //Contacts whose Account Name is CDK Global and User is set with Emp_contact__c not set.
            //Map<Id, Contact> newContactsMap=new Map<Id, Contact>([ 
            //    SELECT Id, Account_name_Text__c, Vendor_Id__c, User__r.Contact_Vendor_Id__c, User__r.Id, User__r.Emp_Contact__c 
            //    FROM Contact WHERE Id IN : newContactTriggerList 
            //    AND  AccountId =: CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c
            //]);
            
            //Mapping User Id to respective Contact Id.
            Map<Id, Id> userToContactMap=new Map<Id, Id>();
            
            //Holds the value of user id's related to inserted or updated CDK_Global Account related Contacts
            List<Id> requiredUserIds = new List<Id>();
            
            //Constructing required users List from new and old Contacts
            for(Contact contactRecord: newContactsMap.values())
            {
                if(contactRecord.User__c != null)
                {
                    userToContactMap.put(contactRecord.User__c, contactRecord.Id);
                    requiredUserIds.add(contactRecord.User__c);
                }
                
                Contact oldContact = oldContactsMap.get(contactRecord.Id);
                
                if(oldContact != null && oldContact.User__c != null)
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
            
            //Updating the Emp_Contact__c of Users.
            for(User EmpUser : userMap.values())
            {
                if(EmpUser.Emp_Contact__c == null)
                {
                    EmpUser.Emp_Contact__c = userToContactMap.get(EmpUser.Id);
                }
            }
            
            //Updating user records of Previous Contacts User__c
            for(Contact newContact : newContactsMap.values())
            {
                Contact oldContact = oldContactsMap.get(newContact.Id);
                
                if(oldContact !=null && (newContact.User__c != oldContact.User__c))
                {
                    User userRecord = userMap.get(oldContact.User__c);
                    if(userRecord != null)
                    {
                        userRecord.Contact_Vendor_Id__c = '';
                        
                        userMap.put(userRecord.id,userRecord);  
                    }
                    
                }
            }
            
            //Updating user records of Current Contacts User__c
            for(Contact newContact : newContactsMap.values())
            {      
                if(newContact.User__c != null)
                {
                    User newUser = userMap.get(newContact.User__c);
                    
                    if(newUser!=null && newContact.Vendor_Id__c != newUser.Contact_Vendor_Id__c )
                    {
                        newUser.Contact_Vendor_Id__c = newContact.Vendor_Id__c;
                        
                        userMap.put(newUser.Id,newUser);
                    }
                }
            }     
            
            //Updating User List
            update userMap.values();
        }
        catch(Exception e)
        {
            System.debug('Exception: '+e.getMessage()+' At '+e.getLineNumber());   
        }
    }   
}