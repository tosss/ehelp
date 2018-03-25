//Author: Anirudh Singh
//Description: This class is created by merging the EMP_PolicyUtilityClass AND EMP_Policy_Utility classes.
//Dated: 12th August, 2015
//2015-12-17 vishal.bandari@cdk.com RQ-05289: added record type to contact object
//2016-04-18 - lalitha.adduru@cdk.com  - made some changes to fit coding standards - RQ-06757
//2016-04-29- anirudh.singh@cdk.com- Changed the use of User_Name__c to use Employee_Contact__c for RQ-06380 Policy Acknowledgement Record adds to a Contact in error.
//2016-07-07 - venkata.shrivol@cdk.com - Added code to insert the contact relationship after contact insertion. (RQ-07319)
//2016-08-30 - lalitha.adduru@cdk.com - commented out fnctionality for creating new policies - RQ-07651
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
    
    //2016-04-18 - lalitha.adduru@cdk.com  - made some changes to fit coding standards - RQ-06757
    //This method is used to create a New Contact and Poilcy when a user is created.
    @future
    public static void createNewContacts(List<Id> userIdsForContact)
    {
        system.debug('Start createNewContact---->');
        //This below block is used to create a new contact when a user is created.
        if(userIdsForContact!=Null && !userIdsForContact.isEmpty())
        {
            List<User> users=[
                SELECT Id, Name, Title, Email, FirstName, LastName 
                FROM User 
                WHERE Id IN :userIdsForContact
            ];
            
            List<Contact> newContactsToInsert=new List<Contact>();
            
            //Get the default account Id that will be used in creating contact.
            CustomSettings__c mc=CustomSettings__c.getOrgDefaults();
            
            List<Account> accountList=[
                SELECT Id 
                FROM Account 
                WHERE Id=:mc.CDK_Global_Account_ID__c 
                LIMIT 1
            ];
            
            Account globalAccount =(accountList!=Null && !accountList.isEmpty()) ? accountList.get(0) : Null;            
            
            //2015-12-17 vishal.bandari@cdk.com added Contact Record type 
            //RecordType recordTypeObject=[
            //SELECT Id 
            //FROM RecordType 
            //WHERE Name='Internal HR Contact' 
            //AND SobjectType='Contact'
            //LIMIT 1
            //][0];
            
            //2015-12-18 venkata.shrivol@cdk.com added Contact Record type 
            Id contactRecordTypeId=Null;
            try
            {
                contactRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Internal HR Contact');    
            }
            catch(Exception ex)
            {
                list<RecordType> contactRecordTypes=[
                    Select Id 
                    From RecordType 
                    Where sObjectType='Contact' 
                    and DeveloperName like '%HR%' 
                    limit 1
                ];
                
                contactRecordTypeId=(contactRecordTypes!=Null && !contactRecordTypes.isEmpty()) ?  contactRecordTypes.get(0).Id : Null;             
            }
            
            if(globalAccount!=Null)
            {
                for(User userForContact: users)
                {
                    Contact newContact=new Contact();
                    newContact.AccountId=globalAccount.Id;
                    newContact.Status__c='Active';
                    
                    //2015-12-17 vishal.bandari@cdk.com added Contact Record type 
                    if(contactRecordTypeId!=Null)
                    {
                        newContact.RecordTypeId=contactRecordTypeId;
                    }
                    newContact.Title=userForContact.Title;
                    newContact.Email=userForContact.Email;
                    newContact.User__c=userForContact.Id;
                    newContact.FirstName=userForContact.FirstName;
                    newContact.LastName=userForContact.LastName;
                    newContactsToInsert.add(newContact);
                }
            }
            
            //2016-07-07 - venkata.shrivol@cdk.com - Added code to insert the contact relationship after contact insertion. 
            SavePoint sp = Database.setSavePoint();
            
            if(!newContactsToInsert.isEmpty())
            {
            	insert newContactsToInsert;	
            }
            
            list<Contact_Relationship__c> relationshipRecsTobeInserted = new list<Contact_Relationship__c>();
            
            List<Contact> insertedContactList=[
                SELECT Id, recordType.Name, Account.Name, AccountId  
                FROM Contact 
                WHERE User__c IN: userIdsForContact
            ];
            
            if(globalAccount!=null)
            {
                for(Contact insertedContact : insertedContactList)
                {
                    Contact_Relationship__c crt = new Contact_Relationship__c();
                    crt.Account__c  = insertedContact.AccountId;
                    crt.Contact__c = insertedContact.Id;
                    relationshipRecsTobeInserted.add(crt);
                    system.debug('insertedContact Record Type Name---->'+insertedContact.recordType.Name);
                    system.debug('insertedContact Account Name---->'+insertedContact.Account.Name);
                }
            }
            
            try
            {
            	insert 	relationshipRecsTobeInserted;
            }
            catch(Exception e)
            {
            	system.debug(e);
            	Database.rollback(sp);	
            }
            
            system.debug('End createNewContact---->');
        }
        
        //This below block is used to create necessary policies when a user is created.
        /*if(userIdsForPolicy!=Null && !userIdsForPolicy.isEmpty())
        {
            List<User> validEmployeeList=new List<User>();
            validEmployeeList=[
                SELECT Id, Name, Title, Email, FirstName, LastName 
                FROM User 
                WHERE Id IN :userIdsForPolicy
            ];
            
            //2016-04-29- anirudh.singh@cdk.com- RQ-06380 Used the query below.
            //To be updated after request RQ-06383.
            Map<Id, Contact> contactsMap=new Map<Id, Contact>([
                SELECT Id, User__c
                FROM Contact
                WHERE User__c IN : userIdsForPolicy
            ]);
            
            //2016-04-29- anirudh.singh@cdk.com- RQ-06380 Changed the User_Name__c field reference to Employee_Contact__c.
            List<EMP_Policy__c> policyList=new List<EMP_Policy__c>();
            policyList=[
                SELECT Id, Acknowledgement_Status__c, Name, Employee_Contact__c 
                FROM EMP_Policy__c 
                WHERE Employee_Contact__c IN: contactsMap.keySet()
            ];
            
            List<ContentVersion> lstContentVersion=getAllPolicyLatestDocument();
            
            List<EMP_Policy__c> policiesToBeInserted=new List<EMP_Policy__c>();
            policiesToBeInserted=generatePolicyAcknowledgement(validEmployeeList, lstContentVersion);
            policiesToBeInserted=uniquePolicies(policyList, policiesToBeInserted);
            
            if(!policiesToBeInserted.isEmpty())
            {
                insert policiesToBeInserted;
            }  
        }*/
    }
    
    //This method is used in getting the content in the policy content library.
    public static List<ContentVersion> getAllPolicyLatestDocument() 
    {
        List<ContentDocument> contentDocuments=getPolicyContentDocument();
        
        //Get the valId content record for the policy acknowledgement.
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
            //Check if the content document is valId for the policy acknowledgement.
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
                    //2016-04-29- anirudh.singh@cdk.com- RQ-06380 Commented the User_Name__c field.
                    //policy.User_Name__c=usr.Id;
                    policy.Name=content.Title;
                    policy.Content_Version_ID__c=content.Id;
                    policy.VersionNumber__c=Integer.valueOf(content.VersionNumber);
                    policy.Policy_Addition_Date__c=content.Policy_Effective_Date__c;              
                    policy.Employee_Contact__c=contactId;
                    empPolicy.add(policy);
                }
            }
        }
        return empPolicy;
    }
    
    private static Map<Id, Id> getUserIdToContactIdMap(List<User> usrs)
    {
        List<Contact> contacts=[SELECT Id, Name, User__c FROM Contact WHERE User__c IN: usrs];
        
        Map<Id, Id> mapContactANDAccount=new Map<Id, Id>();
        
        for(Contact con: contacts)
        {           
            mapContactANDAccount.put(con.User__c, con.Id);            
        }
        return mapContactANDAccount;
    }
    
    //This method eliminates policies which are already assigned to a user
    /*public static List<EMP_Policy__c> uniquePolicies(List<EMP_Policy__c> existingPolicies, List<EMP_Policy__c> duplicatePolicies)
    {
        for(Integer i=0; i<existingPolicies.size(); i++)
        {
            EMP_Policy__c existingPolicy=existingPolicies.get(i);
            
            for(Integer j=0; j<duplicatePolicies.size(); j++)
            {                
                EMP_Policy__c duplicatePolicy=duplicatePolicies.get(j);
                //2016-04-29- anirudh.singh@cdk.com- RQ-06380 Changed the User_Name__c field reference to Employee_Contact__c.
                if(existingPolicy.Name==duplicatePolicy.Name && existingPolicy.Employee_Contact__c==duplicatePolicy.Employee_Contact__c)
                {
                    duplicatePolicies.remove(j);                  
                }
            }
        }        
        return duplicatePolicies;
    }*/
    
    /*@Future
    public static void deletePolicyAcknowledgement(List<String> valIdEmployeeIds)
    {
        //2016-04-29- anirudh.singh@cdk.com- RQ-06380 Used the query below.
        //To be updated after request RQ-06383.
        Map<Id, Contact> contactsMap=new Map<Id, Contact>([
            SELECT Id, User__c
            FROM Contact
            WHERE User__c IN :valIdEmployeeIds
        ]);
        
        List<EMP_Policy__c> deletePolicyList=new List<EMP_Policy__c>();
        
        //2016-04-29- anirudh.singh@cdk.com- RQ-06380 Using Employee_Contact__c instead of User_Name__c.
        List<EMP_Policy__c> policyList=[SELECT Id, Acknowledgement_Status__c FROM EMP_Policy__c WHERE Employee_Contact__c IN :contactsMap.keySet()];
        
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
    }*/
    
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
        //Get all the version Id in the policy object
        List<Policy_Reference_Log__c> empPolicy=[SELECT Id, Policy_ID__c FROM Policy_Reference_Log__c];
        
        List<Id> policyIds=new List<Id>();
        
        Map<Id, Id> mapParentId=new Map<Id, Id>();
        
        for(Policy_Reference_Log__c content: empPolicy)
        {
            if (!mapParentId.containsKey(content.Policy_Id__c))
            {
                mapParentId.put(content.Policy_ID__c, content.Policy_ID__c);
            }
        }
        return mapParentId;
    }
    
    //This method will get all the valId user for the policy acknowledgement.
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
        
        for(ContentVersion content : newPolicyCreated)
        {
            Policy_Reference_Log__c ref=new Policy_Reference_Log__c();
            ref.Policy_ID__c=content.ContentDocumentId;
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
    
    //This method will get the primary details of the content, the Id AND the latestversionId.
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