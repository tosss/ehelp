//Author: Anirudh Singh
//Description: This class is created by merging the EMP_PolicyUtilityClass AND EMP_Policy_Utility classes.
//Dated: 12th August, 2015
public class EMP_PolicyUtility
{
    //This method will update the contact field in the user object.
    public static void updateUserswithContactIds(List<Id> userIds, Map<Id, Id> userIdToContact)
    {
        List<User> usersToUpdate=new List<User>();
        
        List<User> retrieveUser=[SELECT Id, EMP_Contact__c FROM User WHERE Id IN: userIds];
        
        for(User userRec: retrieveUser)
        {
            Id contactId=userIdToContact.get(userRec.Id);
            userRec.EMP_Contact__c=String.valueOf(contactId);
            usersToUpdate.add(userRec);
        }
        
        if(!usersToUpdate.isEmpty())
        {
            update usersToUpdate;
        }
    }
    
    // 2016-03-01 - lalitha.adduru@cdk.com - prevent contact creation on new sales user - RQ-06386
    public static Map<Id,User> preventContactOnNewSalesUser(List<User> newUserList)
    {
        Map<Id,User> userToCreateNewContact = new Map<Id,User>();
        Map<Id,Contact> contactsToUpdate = new Map<id, Contact>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<String> federationIdSet = new Set<String>();
        Map<String,User> federationIdToUserMap = new Map<String,User>();
        
        // serialize records in json as future methods cannot take sObjects as parameters
        List<String> serializedUserRecords = new List<String>();
        
        for(User newUser : newUserList)
        {
            if(newUser.federationIdentifier != null && newUser.federationIdentifier != '')
            {
                federationIdSet.add('%'+newUser.federationIdentifier+'%');
            }
        }
        
        List<User> ExistingActiveUserList = new List<User>();
        ExistingActiveUserList = [
            SELECT id, FederationIdentifier, EMP_Contact__c
            FROM User 
            WHERE federationIdentifier 
            LIKE :federationIdSet
            AND isActive = true
            AND Id NOT IN :newUserList
        ];
        
        system.debug('ExistingActiveUserList -->'+ExistingActiveUserList);
        
        if(!ExistingActiveUserList.isEmpty())
        {
            for(User existingUser : ExistingActiveUserList)
            {
                String fedIdWithNoUnderscores = existingUSer.FederationIdentifier ;
                while(fedIdWithNoUnderscores.startswith('_'))
                {
                    fedIdWithNoUnderscores = fedIdWithNoUnderscores.removeStart('_');
                }
                system.debug(fedIdWithNoUnderscores);
                federationIdToUserMap.put(fedIdWithNoUnderscores, existingUSer);
                if(existingUser.EMP_Contact__c != null)
                {
                    contactIdSet.add(existingUser.EMP_Contact__c);
                }
            }
        }
        
        // get corresponding contacts
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT id,User__c FROM Contact WHERE Id in :contactIdSet]);
        
        for(User newUser : newUserList)
        {
            User existingUser = federationIdToUserMap.get(newUser.FederationIdentifier);
            if(existingUser != null)
            {
                Contact existingContact = contactMap.get(existingUser.EMP_Contact__c);
                if(existingContact != null)
                {
                    existingContact.User__c =  newUser.id;
                    contactsToUpdate.put(existingContact.id, existingContact);
                }
                existingUser.EMP_Contact__c = null;
                serializedUserRecords.add(JSON.serialize(existingUser));
                newUser.Contact_Vendor_ID__c = existingUser.Contact_Vendor_ID__c;
                serializedUserRecords.add(JSON.serialize(newUser));
            }
            else
            {
                userToCreateNewContact.put(newUser.id, newUser);
            }
        }
        
        // call future method to precent mixed dml error ( as User is a setUp Object)
        UpdateUser( serializedUserRecords );              
        update contactsToUpdate.values();
        return userToCreateNewContact;
        
    }
    
    // 2016-03-09 - lalitha.adduru@cdk.com - to prevent having dmls of setUp and Non-SetUp objects in one context ( gets called in preventContactOnNewSalesUser method) - RQ-06386
    @Future
    private static void updateUser(List<String> serialisedUserRecords)
    {
        Map<Id, User> usersToBeUpdated = new Map<Id,User>();
        
        for(String serialisedUserRecord : serialisedUserRecords)
        {
            User userRecord = (User)JSON.deserialize(serialisedUserRecord, User.class);
            usersToBeUpdated.put(userRecord.id, userRecord);
        }
        
        if(!usersToBeUpdated.isEmpty())
        {
            update usersToBeUpdated.values();
        }        
    }
    
    
    //This method is used to create a New Contact and Poilcy when a user is created.
    public static void createNewContactAndPolicy(List<Id> userIdsForContact, List<Id> userIdsForPolicy)
    {
        //This below block is used to create a new contact when a user is created.
        if(!userIdsForContact.isEmpty())
        {
            List<User> users=[SELECT Id, Name, Title, Email, FirstName, LastName FROM User WHERE Id IN :userIdsForContact];
            
            List<Contact> newContactsToInsert=new List<Contact>();
            
            //Get the default account Id that will be used in creating contact.
            CustomSettings__c mc=CustomSettings__c.getOrgDefaults();
            
            Account acc=Null;
            List<Account> accts=[SELECT Id FROM Account WHERE Id=:mc.CDK_Global_Account_Id__c LIMIT 1];
            
            if(accts!=Null && !accts.isEmpty())
            {
                acc=accts.get(0);
            }
            
            if(acc!=Null)
            {
                for(User usr: users)
                {
                    Contact con=new Contact();
                    con.AccountId=acc.Id;
                    con.Status__c='Active';
                    con.Title=usr.Title;
                    con.Email=usr.Email;
                    con.User__c=usr.id;
                    con.FirstName=usr.FirstName;
                    con.LastName=usr.LastName;
                    newContactsToInsert.add(con);
                }
            }
            
            if(!newContactsToInsert.isEmpty())
            {
                insert newContactsToInsert;
            }
        }
        
        //This below block is used to create necessary policies when a user is created.
        if(!userIdsForPolicy.isEmpty())
        {
            List<User> validEmployee=new List<User>();
            validEmployee=[SELECT Id, Name, Title, Email, FirstName, LastName FROM User WHERE Id IN :userIdsForPolicy];
            
            List<EMP_Policy__c> policyList=new List<EMP_Policy__c>();
            policyList=[SELECT Id, Acknowledgement_Status__c, Name, User_Name__c FROM EMP_Policy__c WHERE User_Name__c IN: userIdsForPolicy];
            
            List<ContentVersion> lstContentVersion=getAllPolicyLatestDocument();
            
            List<EMP_Policy__c> insertPolicy=new List<EMP_Policy__c>();
            insertPolicy=generatePolicyAcknowledgement(validEmployee, lstContentVersion);
            insertPolicy=uniquePolicies(policyList, insertPolicy);
            
            if(!insertPolicy.isEmpty())
            {
                insert insertPolicy;
            }  
        }
    }
    
    //2016-04-01 lalitha.adduru@cdk.com create new contacts for a set of users
    public static void createNewContact(Set<ID> userIdsForContact)
    {
        //This below block is used to create a new contact when a user is created.
        if(!userIdsForContact.isEmpty())
        {
            List<User> users=[
                SELECT ID, Name, Title, Email, FirstName, LastName 
                FROM User 
                WHERE ID IN :userIdsForContact
            ];
            
            List<Contact> newContactsToInsert=new List<Contact>();
            
            //Get the default account Id that will be used in creating contact.
            CustomSettings__c mc=CustomSettings__c.getOrgDefaults();
            
            List<Account> defaultAccountResult=[
                SELECT ID 
                FROM Account 
                WHERE Id=:mc.CDK_Global_Account_Id__c 
                LIMIT 1
            ];
            
            Account defaultAccount=Null;
            if(defaultAccountResult!=Null && !defaultAccountResult.isEmpty())
            {
                defaultAccount=defaultAccountResult.get(0);
            }
            
            if(defaultAccount!=Null)
            {
                for(User usr: users)
                {
                    Contact con=new Contact();
                    con.AccountId=defaultAccount.Id;
                    con.Status__c='Active';
                    con.Title=usr.Title;
                    con.Email=usr.Email;
                    con.User__c=usr.id;
                    con.FirstName=usr.FirstName;
                    con.LastName=usr.LastName;
                    newContactsToInsert.add(con);
                }
            }
            
            if(!newContactsToInsert.isEmpty())
            {
                insert newContactsToInsert;
            }
        }
        
    }

	//2016-04-01 lalitha.adduru@cdk.com create new policy for a set of users
	public static void createNewPolicy(Set<ID> userIdsForPolicy)
    {
        //This below block is used to create necessary policies when a user is created.
        if(!userIdsForPolicy.isEmpty())
        {
            List<User> validEmployee=new List<User>();
            validEmployee=[
                SELECT Id, Name, Title, Email, FirstName, LastName 
                FROM User 
                WHERE Id IN :userIdsForPolicy
            ];
            
            List<EMP_Policy__c> policyList=new List<EMP_Policy__c>();
            policyList=[
                SELECT Id, Acknowledgement_Status__c, Name, User_Name__c 
                FROM EMP_Policy__c 
                WHERE User_Name__c IN: userIdsForPolicy
            ];
            
            List<ContentVersion> lstContentVersion=getAllPolicyLatestDocument();
            
            List<EMP_Policy__c> insertPolicy=new List<EMP_Policy__c>();
            insertPolicy=generatePolicyAcknowledgement(validEmployee, lstContentVersion);
            insertPolicy=uniquePolicies(policyList, insertPolicy);
            
            if(!insertPolicy.isEmpty())
            {
                insert insertPolicy;
            }  
        }
    }
    //This method is used in getting the content in the policy content library.
    public static List<ContentVersion> getAllPolicyLatestDocument() 
    {
        List<ContentDocument> contentDocuments=getPolicyContentDocument();
        
        //Get the valid content record for the policy acknowledgement.
        List<ContentVersion> contentVersionObj=[
            SELECT Title, Id, VersionNumber, Policy_Effective_Date__c 
            FROM ContentVersion 
            WHERE ContentDocumentId IN: contentDocuments 
            AND Acknowledgement_Required__c=true 
            AND Expiration_Date__c>TODAY 
            AND Geographic_Applicability__c='Global'
        ];
        
        //Change list to map for easy manipulation.
        Map<Id, ContentVersion> contentVersions=mapContentVersion(contentVersionObj);
        
        List<ContentVersion> lstContentVersion=new List<ContentVersion>();
        for(ContentDocument contentDoc: contentDocuments)
        {
            //Check if the content document is valid for the policy acknowledgement.
            if (contentVersions.containsKey(contentDoc.LatestPublishedVersionId))
            {
                ContentVersion latestContent=contentVersions.get(contentDoc.LatestPublishedVersionId);
                lstContentVersion.add(latestContent);
            }
        }
        return  lstContentVersion;                                            
    }
    
    
    //This method will get the record for the policy.
    public static List<ContentDocument> getPolicyContentDocument() 
    {
        String PolicyName=System.Label.EMP_Policy_Name;
        
        List<ContentDocument> contentDocuments=[
            SELECT Title, PublishStatus, ParentId, OwnerId, Id, LatestPublishedVersionId
            FROM ContentDocument
            WHERE ParentId IN: [
                SELECT Id 
                FROM ContentWorkspace 
                WHERE Name=:PolicyName
            ]
        ];
        return contentDocuments;                                             
    }
    
    private static Map<Id, ContentVersion> mapContentVersion(List<ContentVersion> contents)
    {
        Map<Id, ContentVersion> contentVersion=new Map<Id, ContentVersion>();
        for(ContentVersion content: contents)
        {
            contentVersion.put(content.Id, content);
        }
        return contentVersion;
    }
    
    //This method will insert policy acknowledgement for the list of users.
    public static List<EMP_Policy__c> generatePolicyAcknowledgement(List<User> users, List<ContentVersion> contentVersions)
    {
        List<EMP_Policy__c> empPolicy=new List<EMP_Policy__c>();
        
        Map<Id, Id> mapAccountContact=getUserIdToContactIdMap(users);
        
        if(users!=Null && !users.isEmpty())
        {
            for(User usr: users)
            {
                Id contactId;
                
                //this method will get the contact for the user
                if(mapAccountContact.containsKey(usr.Id))
                {   
                    contactId=mapAccountContact.get(usr.Id);
                }
                
                for(ContentVersion content: contentVersions)
                {
                    EMP_Policy__c policy=new EMP_Policy__c();
                    policy.User_Name__c=usr.Id;
                    policy.Name=content.Title;
                    policy.Content_Version_ID__c=content.Id;
                    policy.VersionNumber__c=Integer.valueOf(content.VersionNumber);
                    policy.Policy_Addition_Date__c=content.Policy_Effective_Date__c;              
                    policy.Employee_Contact__c =contactId;
                    empPolicy.add(policy);
                }
            }
        }
        return empPolicy;
    }
    
    public static Map<Id, Id> getUserIdToContactIdMap(List<User> usrs)
    {
        List<Contact> contacts=[SELECT Id, Name, User__c FROM Contact WHERE User__c IN: usrs];
        
        Map<Id, Id> mapContactANDAccount=new Map<Id, Id>();
        
        for(Contact con: contacts)
        {           
            mapContactANDAccount.put(con.User__c, con.Id);            
        }
        return mapContactANDAccount;
    }
    
    //2016-1-04 lalitha.adduru@cdk.com to get user id to contact map
    public static Map<Id, Contact> getUserIdToContactMap(List<User> usrs)
    {
        List<Contact> contacts=[SELECT Id, Name, User__c FROM Contact WHERE User__c IN: usrs];
        
        Map<Id, Contact> mapContactANDAccount=new Map<Id, Contact>();
        
        for(Contact con: contacts)
        {           
            mapContactANDAccount.put(con.User__c, con);            
        }
        return mapContactANDAccount;
    }
    
    //This method eliminates policies which are already assigned to a user
    public static List<EMP_Policy__c> uniquePolicies(List<EMP_Policy__c> existingPolicies, List<EMP_Policy__c> duplicatePolicies)
    {
        for(Integer i=0; i<existingPolicies.size(); i++)
        {
            EMP_Policy__c existingPolicy=existingPolicies.get(i);
            
            for(Integer j=0; j<duplicatePolicies.size(); j++)
            {                
                EMP_Policy__c duplicatePolicy=duplicatePolicies.get(j);
                if(existingPolicy.Name==duplicatePolicy.Name && existingPolicy.User_Name__c==duplicatePolicy.User_Name__c)
                {
                    duplicatePolicies.remove(j);                  
                }
            }
        }        
        return duplicatePolicies;
    }
    
    @future
    public static void deletePolicyAcknowledgement(List<String> validEmployeeIds)
    {
        List<EMP_Policy__c> deletePolicyList=new List<EMP_Policy__c>();
        
        List<EMP_Policy__c> policyList=[SELECT Id, Acknowledgement_Status__c FROM EMP_Policy__c WHERE User_Name__c IN: validEmployeeIds];
        
        if(!policyList.isEmpty())
        {
            for(EMP_Policy__c empPolicy: policyList)
            {
                if(empPolicy.Acknowledgement_Status__c==false)
                {
                    deletePolicyList.add(empPolicy);
                }
            }
            delete deletePolicyList;
        }        
    }
    
    public static Map<Id, ContentDocument> mapContentDocument(List<ContentDocument> contents)
    {
        Map<Id, ContentDocument> contentDocuments=new Map<Id, ContentDocument>();
        
        for(ContentDocument content: contents)
        {
            contentDocuments.put(content.Id, content);
        }
        
        return contentDocuments;
    }
    
    public static Map<Id, Id> getPolicyReference()
    {
        //Get all the version id in the policy object
        List<Policy_Reference_Log__c> empPolicy=[SELECT Id, Policy_Id__c FROM Policy_Reference_Log__c];
        
        List<Id> policyIds=new List<Id>();
        
        Map<Id, Id> mapParentId=new Map<Id, Id>();
        
        for(Policy_Reference_Log__c content: empPolicy)
        {
            if (!mapParentId.containsKey(content.Policy_Id__c))
            {
                mapParentId.put(content.Policy_Id__c, content.Policy_Id__c);
            }
        }
        return mapParentId;
    }
    
    //This method will get all the valid user for the policy acknowledgement.
    public static List<User> getUserForAcknowledgement()
    {
        List<User> users=[
            SELECT Id, Name 
            FROM User 
            WHERE Non_Employee__c=false 
            AND Contractor__c= false 
            AND isActive=true 
            AND Non_Interactive_User__c=false
        ];
        return users;
    }
    
    //This method will add the new created policy in the log, for reference.
    public static void updatePolicyReference(List<ContentVersion> newPolicyCreated)
    {
        List<Policy_Reference_Log__c> toInsert=new List<Policy_Reference_Log__c>();
        
        for(ContentVersion content: newPolicyCreated)
        {
            Policy_Reference_Log__c ref=new Policy_Reference_Log__c();
            ref.Policy_Id__c=content.ContentDocumentId;
            toInsert.add(ref);
        }
        
        if(!toInsert.isEmpty())
        {
            Insert toInsert;
        }
    }
    
    public static List<ContentVersion> getAllLatestDocument(String contentLibraryName) 
    {
        //get all the primary detail in the library
        List<ContentDocument> contentDocuments=getPolicyContentDocument(contentLibraryName);
        
        //get all the additional detail of the content
        List<ContentVersion> contentVersionObj=[
            SELECT Title, Id, VersionNumber, Policy_Effective_Date__c, Policy_Category__c, Geographic_Applicability__c, 
            Form_Geographic_Applicability__c, Form_Category__c, Version__c, Posting_Date__c, Immigration_Geographic_Applicability__c 
            FROM ContentVersion 
            WHERE ContentDocumentId IN: contentDocuments 
            AND Expiration_Date__c>TODAY
        ];        
        
        Map<Id, ContentVersion> contentVersions=mapContentVersion(contentVersionObj);
        List<ContentVersion> lstContentVersion=new List<ContentVersion>();
        
        //only get the latest uploaded file
        for(ContentDocument contentDoc: contentDocuments)
        {            
            if(contentVersions.containsKey(contentDoc.LatestPublishedVersionId))
            {
                ContentVersion latestContent=contentVersions.get(contentDoc.LatestPublishedVersionId);
                lstContentVersion.add(latestContent);
            }
        }
        return lstContentVersion;                                            
    }
    
    //This method will get the primary details of the content, the id AND the latestversionid.
    public static List<ContentDocument> getPolicyContentDocument(String libraryName) 
    {
        String contentName='';
        if('FormHub'.equals(libraryName)) 
        {           
            contentName=System.Label.EMP_Form_Name;  
        }
        else if('Immigration'.equals(libraryName))
        {
            contentName=System.Label.EMP_Immigration_Name;  
        }
        else
        {
            contentName=System.Label.EMP_Policy_Name;
        }
        
        List<ContentDocument> contentDocuments=[
            SELECT Title, PublishStatus, ParentId, OwnerId, Id, LatestPublishedVersionId
            FROM ContentDocument
            WHERE ParentId IN: [
                SELECT Id 
                FROM ContentWorkspace 
                WHERE Name=:contentName
            ] 
        ];
        
        return contentDocuments;                                             
    }
    
    public static void addPermissionSet(List<User> users, Id permissionSetId)
    {
        //every time a new user is created add the permission check so they can view the community
        List<PermissionSetAssignment> listPermission=new List<PermissionSetAssignment>();
        
        for(User usr: users)
        {
            PermissionSetAssignment perm=new PermissionSetAssignment();
            perm.AssigneeId=usr.Id;
            perm.PermissionSetId=permissionSetId;
            listPermission.add(perm);
        }
        
        if(!listPermission.isEmpty())
        {
            insert listPermission;
        }
    }
    
    public static void addPublicGroup(List<User> users, Id publicGroupId)
    {
        //every time a new user is created add the permission check so they can view the policy
        List<GroupMember> listGroup=new List<GroupMember>();
        
        for(User usr: users)
        {
            GroupMember groupM=new GroupMember();
            groupM.GroupId=publicGroupId;
            groupM.UserOrGroupId=usr.Id;         
            listGroup.add(groupM);
        }
        
        if(!listGroup.isEmpty())
        {
            insert listGroup;
        }
    }
}