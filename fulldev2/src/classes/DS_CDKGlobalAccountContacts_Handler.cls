//RQ-04894 : Trigger on Contact to set User.ContactId when Contact.User__c is ins/upd
//2015-07-02 : vishal.bandari@cdk.com - updated updateUser method to meet RQ-04894 requirement
//2016-02-25- anirudh.singh@cdk.com- Modified for RQ-06383 Modify Contact Trigger that sets Vendor Id on User...to Set Hire Date when chgs
//                                   Corrected the indetation.
//2016-03-15- anirudh.singh@cdk.com- Added the logic for Hire Date and Rehire Date.
public class DS_CDKGlobalAccountContacts_Handler 
{
    public static void updateUser(List<Contact> newContactList, Map<Id, Contact> oldContactMap)
    {
        system.debug('Start updateUser---->');
        
        try
        {
            //Filtering the CDK_GLobal Account related Contacts.
            Map<Id, Contact> filteredContactsMap=new Map<Id, Contact>();
            
            for(Contact newContactRecord: newContactList)
            {
                if(newContactRecord.AccountId==CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c)
                {
                    filteredContactsMap.put(newContactRecord.Id, newContactRecord);
                }
            }
            
            //Contacts whose Account Name is CDK Global and User is set with Emp_contact__c not set.
            //Map<Id, Contact> filteredContactsMap=new Map<Id, Contact>([ 
            //    SELECT Id, Account_name_Text__c, Vendor_Id__c, User__r.Contact_Vendor_Id__c, User__r.Id, User__r.Emp_Contact__c 
            //    FROM Contact WHERE Id IN : newContactList 
            //    AND  AccountId =: CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c
            //]);
            
            //Mapping User Id to respective Contact Id.
            Map<Id, Id> userIdAndContactIdMap=new Map<Id, Id>();
            
            //2016-02-26- anirudh.singh@cdk.com- Changed the List to Set to have unique Ids.
            //Holds the value of user Id's related to inserted or updated CDK_Global Account related Contacts.
            Set<Id> requiredUserIds=new Set<Id>();
            
            //Constructing required users Set from new and old Contacts.
            for(Contact newContactRecord: filteredContactsMap.values())
            {
                if(newContactRecord.User__c!=Null)
                {
                    userIdAndContactIdMap.put(newContactRecord.User__c, newContactRecord.Id);
                    requiredUserIds.add(newContactRecord.User__c);
                }
            
                //For after update scenario, Trigger.oldMap is not Null.
                if(oldContactMap!=Null)
                {
                    Contact oldContactRecord=oldContactMap.get(newContactRecord.Id);
                    
                    //2016-03-15- anirudh.singh@cdk.com- Added the newContactRecord.User__c!=oldContactRecord.User__c condition.
                    if(oldContactRecord!=Null && oldContactRecord.User__c!=Null && newContactRecord.User__c!=oldContactRecord.User__c)
                    {
                        requiredUserIds.add(oldContactRecord.User__c);
                    }
                }
            }
            
            //2016-03-16- anirudh.singh@cdk.com- Added Hire_Date__c in the query.
            //Initializing the userMap with required Users.
            Map<Id, User> userMap=new Map<Id, User>([
                SELECT Id, Emp_Contact__c, Contact_Vendor_Id__c, Hire_Date__c
                FROM User 
                WHERE Id IN: requiredUserIds
            ]);
            
            //Updating the Emp_Contact__c of Users.
            for(User empUser: userMap.values())
            {
                if(empUser.Emp_Contact__c==Null)
                {
                    empUser.Emp_Contact__c=userIdAndContactIdMap.get(empUser.Id);
                }
            }
            
            for(Contact newContactRecord: filteredContactsMap.values())
            {
                if(newContactRecord.User__c!=Null)
                {
                    User newUser=userMap.get(newContactRecord.User__c);
                    
                    //2016-03-15- anirudh.singh@cdk.com- Added the logic for Hire Date and Rehire Date.
                    if(newUser!=Null)
                    {
                        Boolean valueChanged=false;
                        
                        if(newContactRecord.Vendor_Id__c!=newUser.Contact_Vendor_Id__c)
                        {
                            newUser.Contact_Vendor_Id__c=newContactRecord.Vendor_Id__c;
                            valueChanged=true;
                        }
                        
                        if(newContactRecord.HR_Rehire_Date__c!=Null && newUser.Hire_Date__c!=newContactRecord.HR_Rehire_Date__c)
                        {
                            newUser.Hire_Date__c=newContactRecord.HR_Rehire_Date__c;
                            valueChanged=true;
                        }
                        else if(newContactRecord.HR_Hire_Date__c!=Null && newUser.Hire_Date__c!=newContactRecord.HR_Hire_Date__c)
                        {
                            newUser.Hire_Date__c=newContactRecord.HR_Hire_Date__c;
                            valueChanged=true;
                        }
                        
                        if(valueChanged)
                        {
                            userMap.put(newUser.Id, newUser);
                        }
                    }
                }
                
                //For after update scenario, Trigger.oldMap is not Null.
                if(oldContactMap!=Null)
                {
                    Contact oldContactRecord=oldContactMap.get(newContactRecord.Id);
                    
                    if(oldContactRecord!=Null && newContactRecord.User__c!=oldContactRecord.User__c)
                    {
                        User userRecord=userMap.get(oldContactRecord.User__c);
                        
                        if(userRecord!=Null)
                        {
                            userRecord.Contact_Vendor_Id__c='';
                            userMap.put(userRecord.Id, userRecord);
                        }
                    }
                }
            }
            
            //Updating User List.
            update userMap.values();
        }
        catch(Exception ex)
        {
            System.debug('Exception---->'+ex.getMessage()+' At '+ex.getLineNumber());
        }
        system.debug('End updateUser---->');
    }   
}