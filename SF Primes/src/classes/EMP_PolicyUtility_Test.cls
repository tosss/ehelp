//Author: Anirudh Singh
//Description: This class is created by merging the EMP_PolicyUtilityClass_Test AND EMP_Policy_Utility_Test classes.
//Dated: 13th August, 2015
//2015-12-17 vishal.bandari@cdk.com RQ-05289: added record type to contact object
@isTest
public class EMP_PolicyUtility_Test
{
    @TestSetup
    private static void setupTestData()
    {
        List<User> userList=new List<User>();
        
        List<String> randomNumbersList=new List<String>();
        for(Integer i=0; i<4; i++)
        {
            String randomNum=ALL_UtilitiesRandom.TrueRandomUpToAMillion();
            randomNumbersList.add(randomNum);
        }
        
        List<String> randomUserNamesList=new List<String>();
        for(Integer i=0; i<4; i++)
        {
            String randomUserName=ALL_UtilitiesRandom.RandomUserName('RequestTeamMember'+i);
            randomUserNamesList.add(randomUserName);
        }
        
        //List of System Admin Profiles
        List<Profile> adminProfiles=[
            SELECT Id, Name 
            FROM Profile 
            WHERE PermissionsModifyAllData=true AND PermissionsApiEnabled=true AND Name LIKE '%System Administrator%' 
            LIMIT 1
        ];
        
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
    
    static testMethod void updateUserswithContactIdsTest()
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
    
    static testMethod void createNewContactAndPolicyTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        
        List<Id> userIdsList=new List<Id>();
        for(User rec: userList)
        {
            userIdsList.add(rec.Id);
        }
        
        test.startTest();
        createContent(userList[0].Id);
        EMP_PolicyUtility.createNewContactAndPolicy(userIdsList, userIdsList);
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
    }
    
    static testMethod void deletePolicyAcknowledgementTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        
        List<Id> userIdsList=new List<Id>();
        for(User rec: userList)
        {
            userIdsList.add(rec.Id);
        }
        
        test.startTest();
        createContent(userList[0].Id);
        EMP_PolicyUtility.createNewContactAndPolicy(userIdsList, userIdsList);
        EMP_PolicyUtility.deletePolicyAcknowledgement(userIdsList);
        test.stopTest();
    }
    
    static testMethod void getAllLatestDocumentTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        
        List<Id> userIdsList=new List<Id>();
        for(User rec: userList)
        {
            userIdsList.add(rec.Id);
        }
        
        test.startTest();
        createContent(userList[0].Id);
        EMP_PolicyUtility.createNewContactAndPolicy(userIdsList, userIdsList);
        EMP_PolicyUtility.getAllLatestDocument('Policy');
        test.stopTest();
    }
    
    static testMethod void getAllLatestDocumentFormHubTest()
    {
        test.startTest();
        EMP_PolicyUtility.getAllLatestDocument('FormHub');
        test.stopTest();
    }
    
    static testMethod void getAllLatestDocumentImmigrationTest()
    {
        test.startTest();
        EMP_PolicyUtility.getAllLatestDocument('Immigration');
        test.stopTest();
    }
    
    static testMethod void addPermissionSetTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        
        test.startTest();
        Id permissionSetId=[Select Id from PermissionSet where Name='Associate_Community_Access'].Id;
        EMP_PolicyUtility.addPermissionSet(userList, permissionSetId);
        test.stopTest();
    }
    
    static testMethod void addPublicGroupTest()
    {
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'Test User%' AND CreatedDate=Today];
        
        test.startTest();
        Id groupId=[Select Id from Group where Name='All Emps - Assoc Comm Content Access'].Id;
        EMP_PolicyUtility.addPublicGroup(userList, groupId);
        test.stopTest();
    }
    
    private static void createContent(Id userId)
    {
        EMP_Policy__c policyRec=new EMP_Policy__c();
        policyRec.Name='Admin';
        policyRec.User_Name__c=userId;
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
}