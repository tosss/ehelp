//Author: Anirudh Singh
//Description: This class is created by merging the EMP_PolicyUtilityClass_Test AND EMP_Policy_Utility_Test classes.
//Dated: 13th August, 2015
//2015-12-17 vishal.bandari@cdk.com RQ-05289: added record type to contact object
//2016-04-29- anirudh.singh@cdk.com- Changed the use of User_Name__c to use Employee_Contact__c for RQ-06380 Policy Acknowledgement Record adds to a Contact in error.
//2016-07-08 -venkata.shrivol@cdk.com - added new assertion to check the insertion of contactRelationships in createNewContactsAndPolicyTest method.(RQ-07319)
//2016-07-30 - lalitha.adduru@cdk.com - added testmethod to test generatePolicyAcknowledgement - RQ-07651
@isTest
public class EMP_PolicyUtility_Test
{
    @TestSetup
    private static void setupTestData()
    {
        List<String> randomUserNamesList=new List<String>();
        for(Integer i=0; i<4; i++)
        {
            String randomUserName=ALL_UtilitiesRandom.RandomUserName('PolicyUtilityTest'+i);
            randomUserNamesList.add(randomUserName);
        }
        
        List<String> randomNumbersList=new List<String>();
        for(Integer i=0; i<4; i++)
        {
            String randomNum=ALL_UtilitiesRandom.TrueRandomUpToAMillion();
            randomNumbersList.add(randomNum);
        }
        
        List<Profile> adminProfiles=[
            SELECT Id, Name 
            FROM Profile 
            WHERE PermissionsModifyAllData=true AND PermissionsApiEnabled=true AND Name LIKE '%System Administrator%' 
            LIMIT 1
        ];
        
        List<User> userList=new List<User>();
        if(adminProfiles!=Null && !adminProfiles.isEmpty())
        {
            Profile adminProfile=adminProfiles.get(0);
            
            for(Integer i=0; i<4; i++)
            {
                User testUser=new User(
                    UserName=randomUserNamesList[i], 
                    Email=randomUserNamesList[i], 
                    Alias=randomNumbersList[i].length()>8?randomNumbersList[i].substring(4, randomNumbersList[i].length()):randomNumbersList[i],
                    EmailEncodingKey='UTF-8', 
                    FirstName='Apex',
                    LastName='Test User'+i, 
                    LanguageLocaleKey='en_US', 
                    LocaleSIDKey='en_US', 
                    profileId=AdminProfile.Id, 
                    TimeZoneSIDKey='America/Chicago',
                    ADID__c='A'+randomNumbersList[i],
                    FederationIdentifier='F'+randomNumbersList[i]
                );
                testUser.putSObject('Profile', adminProfile);
                userList.add(testUser);
            }
        }
        insert userList;
        
        Account acc=DS_TestObjects.NewAccount();
        insert acc;
        
        List<Contact> contactList=new List<Contact>();
        //2015-12-17 vishal.bandari@cdk.com added Contact Record type 
        Id rt = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Internal HR Contact');   
        for(Integer i=0; i<userList.size(); i++)
        {
            Contact cont=new Contact();
            cont.FirstName='Con ';
            cont.LastName='Test ';
            cont.AccountId=acc.Id;
            cont.User__c=userList[i].Id;
            cont.RecordTypeId = rt;
            contactList.add(cont);
        }
        insert contactList;
    }
    
    private static testMethod void updateUserswithContactIdsTest()
    {
        List<Contact> contactList=[SELECT Id, FirstName, LastName, User__c FROM Contact];
        List<Id> userIdtoRetrieveList=new List<Id>();
        Map<Id, Id> userIdtoContactId=new Map<Id, Id>();
        
        for(Contact rec: contactList)
        {
            if(rec.User__c!=Null)
            {
                userIdtoRetrieveList.add(rec.User__c);
                userIdtoContactId.put(rec.User__c, rec.Id);
            }
        }
        
        test.startTest();
        EMP_PolicyUtility.updateUserswithContactIds(userIdtoRetrieveList, userIdtoContactId);
        test.stopTest();
    }
    
    private static testMethod void createNewContactsAndPolicyTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        
        List<Id> userIdsList=new List<Id>();
        for(User rec: userList)
        {
            userIdsList.add(rec.Id);
        }
        
        test.startTest();
        createContent(userList[0].Id);
        EMP_PolicyUtility.createNewContacts(userIdsList);
        test.stopTest();
        //2015-12-17 vishal.bandari@cdk.com added Contact Record type 
        Id rt = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Internal HR Contact'); 
        
        List<Contact> contactsCreated = [
            SELECT id,RecordTypeId 
            FROM Contact 
            WHERE Account.Name = 'CDK Global' 
            AND  RecordTypeId =: rt
        ];
    
        system.assertEquals(userIdsList.size(), contactsCreated.size(), 'All contacts are not created or Record Type not Updated');
        
        //2016-07-08 -venkata.shrivol@cdk.com - added new assertion to check the insertion of contactRelationships in createNewContactsAndPolicyTest method.(RQ-07319)
        set<Id> contactIds = new set<Id>();
        for(Contact con:contactsCreated)
        {
            contactIds.add(con.ID);
        }
        
        List<Contact_Relationship__c> contactRelationshipsCreated = [
            SELECT id
            FROM Contact_Relationship__c 
            WHERE Account__r.Name = 'CDK Global' 
            and Contact__c IN :contactIds
        ];
        
        system.assertEquals(contactsCreated.size(), contactRelationshipsCreated.size(), 'All contact relationships are not created for newly created Contacts');
        
        
    }
    
    /*private static testMethod void deletePolicyAcknowledgementTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        
        List<Id> userIdsList=new List<Id>();
        for(User rec: userList)
        {
            userIdsList.add(rec.Id);
        }
        
        test.startTest();
        createContent(userList[0].Id);
        EMP_PolicyUtility.createNewContacts(userIdsList);
        EMP_PolicyUtility.deletePolicyAcknowledgement(userIdsList);
        test.stopTest();
    }*/
    
    private static testMethod void getAllLatestDocumentTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        
        List<Id> userIdsList=new List<Id>();
        for(User rec: userList)
        {
            userIdsList.add(rec.Id);
        }
        
        test.startTest();
        createContent(userList[0].Id);
        EMP_PolicyUtility.createNewContacts(userIdsList);
        EMP_PolicyUtility.getAllLatestDocument('Policy');
        test.stopTest();
    }
    
    private static testMethod void getAllLatestDocumentFormHubTest()
    {
        test.startTest();
        EMP_PolicyUtility.getAllLatestDocument('FormHub');
        test.stopTest();
    }
    
    private static testMethod void getAllLatestDocumentImmigrationTest()
    {
        test.startTest();
        EMP_PolicyUtility.getAllLatestDocument('Immigration');
        test.stopTest();
    }
    
    private static testMethod void addPermissionSetTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        
        test.startTest();
        Id permissionSetId=[Select Id from PermissionSet where Name='Associate_Community_Access'].Id;
        EMP_PolicyUtility.addPermissionSet(userList, permissionSetId);
        test.stopTest();
    }
    
    private static testMethod void addPublicGroupTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        
        test.startTest();
        Id groupId=[Select Id from Group where Name='All Emps - Assoc Comm Content Access'].Id;
        EMP_PolicyUtility.addPublicGroup(userList, groupId);
        test.stopTest();
    }
    
    private static void createContent(Id userId)
    {
        //2016-04-29- anirudh.singh@cdk.com- Added the below SOQL.
        List<Contact> contactList=[SELECT Id, FirstName, LastName, User__c FROM Contact];
        
        EMP_Policy__c policyRec=new EMP_Policy__c();
        policyRec.Name='Admin';
        //2016-04-29- anirudh.singh@cdk.com- Changed the use of User_Name__c to use Employee_Contact__c.
        policyRec.Employee_Contact__c=contactList[0].Id;
        insert policyRec;
        
        Account account=new Account();
        account.name='CDK Global';
        insert account;
        
        CustomSettings__c cs=CustomSettings__c.getOrgDefaults();
        if(cs==Null)
        {
            cs=new CustomSettings__c();
        }
        cs.CDK_Global_Account_Id__c=account.Id;
        insert cs;
        
        String before='Testing base 64 encode'; 
        Blob beforeBlob=Blob.valueOf(before);
        Id recordTypeId=[SELECT Id FROM RecordType WHERE Name='Policy' LIMIT 1].Id;
        
        List<ContentVersion> cvList=new List<ContentVersion>();
        
        ContentVersion doc=new ContentVersion();
        doc.Title='Title 1';
        doc.PathOnClient='xyz';
        doc.VersionData=beforeBlob;
        doc.RecordTypeId=recordTypeId;
        doc.Acknowledgement_Required__c=true;
        doc.Geographic_Applicability__c='Global';
        doc.Expiration_Date__c=date.today()+30;
        insert doc;
        
        ContentVersion testContent=[SELECT ContentDocumentId FROM ContentVersion where Title='Title 1'];
        cvList.add(doc);
        
        ContentWorkspace shareWorkspace=[SELECT Id FROM ContentWorkspace WHERE Name='Policy'];
        
        ContentWorkspaceDoc newWorkspaceDoc=new ContentWorkspaceDoc();        
        newWorkspaceDoc.ContentWorkspaceId=shareWorkspace.Id;
        newWorkspaceDoc.ContentDocumentId=testContent.ContentDocumentId;
        insert newWorkspaceDoc;
        
        EMP_PolicyUtility.updatePolicyReference(cvList);
        EMP_PolicyUtility.getUserForAcknowledgement();
        EMP_PolicyUtility.getPolicyReference();
        
        ContentDocument cd=[SELECT Id FROM ContentDocument LIMIT 1];
        
        List<ContentDocument> contents=new List<ContentDocument>();
        contents.add(cd);
        EMP_PolicyUtility.mapContentDocument(contents);
    }
    
    private static testMethod void generatePolicyAcknowledgementTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        EMP_PolicyUtility.generatePolicyAcknowledgement(userList, EMP_PolicyUtility.getAllPolicyLatestDocument());
    }
}