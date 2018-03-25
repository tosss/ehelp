//2015-12-04 hemanth.kesapragada@cdk.com rewriting EMP_UserAfterInsert trigger to meet stds
public class EMP_User_Handler 
{
    public static void afterInsert(List<User> newUsersList, Map<Id,User> newUserMap)
    {
        //Lists and Map Declaration
        List<User> users = newUsersList;
        List<Contact> contacts = new List<Contact>();
        List<String> userIds = new List<String>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Set<String> emailIdSet  = new Set<String>();
        Set<String> contactEmailIdSet  = new Set<String>();
       
        //Creating a User Contact Map to check if contact already exists
        for(User usr: users)
        {
            userIds.add(usr.Id); 
            emailIdSet.add(usr.Email);
        }

        contacts = [select id,User__c,Email from Contact where User__c IN :userIds or Email in :emailIdSet];
        for(Contact contact : contacts)
        {
            if(contact.User__c!=null)
            {
                contactMap.put(contact.User__c, contact); 
            }
            if(contact.Email!=null)
            {
                contactEmailIdSet.add(contact.Email);
            }
        }
        
        try
        {
            List<String> createPolicyForUsers = new List<String>();        
            List<String> createContactForUsers = new List<String>();
            
            for(User usr: users)
            {
                EMP_User_HireDate__c hd = EMP_User_HireDate__c.getOrgDefaults(); 
                //2015-10-13 RQ-05492 hemanth.kesapragada@cdk.com Added isActive check
                if (usr.Contractor__c == false && usr.Non_Employee__c == false && usr.Non_Interactive_User__c == false && usr.IsActive==true)
                { 
                    //RQ-05492 hemanth.kesapragada@cdk.com Added check on emailId of the user
                    //If the Map doesnt contain id - contact does not exists.
                    if(!contactMap.containsKey(usr.Id)&&!contactEmailIdSet.contains(usr.Email))
                    {
                        // if(usr.Hire_Date__c==null || usr.Hire_Date__c < hd.Hire_Date__c)
                        // {
                        createContactForUsers.add(usr.Id);
                        //  }
                    }
                    if(usr.Hire_Date__c != null && usr.Hire_Date__c >=  hd.Hire_Date__c)
                    {
                        createPolicyForUsers.add(usr.id);
                    }  
                }
            }
            
            //2015-01-06 lalitha.adduru@cdk.com- RQ-06040:modified 'if' condtion to check if createPolicyForUsers is not empty
            if(!createContactForUsers.isEmpty() || !createPolicyForUsers.isEmpty())
            {
                // creating contacts and policies for the users
                EMP_PolicyUtility.createNewContactAndPolicy(createContactForUsers, createPolicyForUsers);
            }
        }
        catch(Exception e)
        {
            System.debug('Exception - '+e.getMessage());
        }
    }
    
    public static void afterUpdate(List<User> oldUserList, List<User> newUsersList, Map<Id,User> oldUserMap, Map<Id,User> newUserMap)
    {
        System.debug('$$ In EMP_User_Handler after Update method');
        //Lists and Map Declaration

        List<User> users = newUsersList;
        List<Contact> contacts = new List<Contact>();
        List<String> userIds = new List<String>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Set<String> emailIdSet  = new Set<String>();
        Set<String> contactEmailIdSet  = new Set<String>();
        
        //Creating a User Contact Map to check if contact already exists
        for(User usr: users)
        {
            userIds.add(usr.Id);
            emailIdSet.add(usr.Email);
        }
        
        contacts = [
            select id,User__c,Email 
            from Contact 
            where User__c IN :userIds or Email in :emailIdSet
        ];
        
        for(Contact contact : contacts)
        {
            contactMap.put(contact.User__c, contact);
            for(User userObj : users)
            {
                if(contact.User__c!=null)
                {
                    contactMap.put(contact.User__c, contact); 
                }
                if(contact.Email!=null)
                {
                    contactEmailIdSet.add(contact.Email);
                }
            }
        }
        
        try
        {
            List<String> createPolicyForUsers = new List<String>();        
            List<String> createContactForUsers = new List<String>();
            List<String> deletePolicyForUsers = new List<String>();
            
            for(User usr: users)
            {
                EMP_User_HireDate__c hd = EMP_User_HireDate__c.getOrgDefaults(); 
                
                //RQ-05492 hemanth.kesapragada@cdk.com Added isActive check
                if (usr.Contractor__c == false && usr.Non_Employee__c == false && usr.Non_Interactive_User__c == false && usr.IsActive==true)
                { 
                    //RQ-05492 hemanth.kesapragada@cdk.com Added check on emailId of the user
                    //If the Map doesnt contain id - contact does not exists.
                    if(!contactMap.containsKey(usr.Id)&&!contactEmailIdSet.contains(usr.Email))
                    {
                        createContactForUsers.add(usr.Id);
                    }
                    if(usr.Hire_Date__c != null && usr.Hire_Date__c >=  hd.Hire_Date__c)
                    {
                        createPolicyForUsers.add(usr.id);
                    }
                    //else if(usr.Hire_Date__c == null ||usr.Hire_Date__c <  hd.Hire_Date__c)
                    //{
                    //     deletePolicyForUsers.add(usr.id);
                    //}
                }
                else
                {
                    if(usr.Contractor__c == true || usr.Non_Employee__c == true)
                    {
                        deletePolicyForUsers.add(usr.id);
                    }                  
                }
            }
            
            if(!createContactForUsers.isEmpty() || !createPolicyForUsers.isEmpty())
            {
                // Create Contacts if it does not exists and update the policies
                EMP_PolicyUtility.createNewContactAndPolicy(createContactForUsers,createPolicyForUsers);
            }
            
            //Delete policy - hire_date__c is either CLEARED or is set to a value before 10/1/14 
            if (!deletePolicyForUsers.isEmpty())
            {
                EMP_PolicyUtility.deletePolicyAcknowledgement(deletePolicyForUsers);
            }
        }
        catch(Exception e)
        {
            System.debug('Exception - '+e.getMessage());
        }
    }
}