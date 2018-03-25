//2016-05-06- anirudh.singh@cdk.com- Created this class for EMP_AcknowledgementPage_Controller for RQ-06978.
//2016-09-13- lalitha.aduru@cdk.com- modified code to avoid 'List has no rows to assign' error for correct deployments
@isTest
public class EMP_AcknowledgementPage_Test
{
    @TestSetup
    private static void setupData()
    {
        generateContent(true);
        
        //Insert account.
        Account acc=DS_TestObjects.NewAccount_Inserted();
        
        //Insert custom setting.
        CustomSettings__c customSettingsRecord=new CustomSettings__c();
        customSettingsRecord.CDK_Global_Account_Id__c=acc.Id;
        insert customSettingsRecord;
        
        Date myDate=Date.today().addDays(-1);
        //Insert EMP_User_HireDate__c record.
        EMP_User_HireDate__c defaultHireDate=new EMP_User_HireDate__c(SetupOwnerID=Userinfo.getOrganizationID(), Hire_Date__c=myDate);
        insert defaultHireDate;
        
        //List of System Admin Profiles.
        List<Profile> adminProfiles=[
            SELECT Id, Name 
            FROM Profile 
            WHERE PermissionsModifyAllData=true AND PermissionsApiEnabled=true AND Name LIKE '%System Administrator%' 
            LIMIT 1
        ];
        
        //Insert user record.
        User userRecord;
        if(adminProfiles!=Null && !adminProfiles.isEmpty())
        {
            Profile adminProfile=adminProfiles.get(0);
            String randomUserName=ALL_UtilitiesRandom.RandomUserName('EMP_AcknowledgementPage_Test');
            String randomNum=ALL_UtilitiesRandom.TrueRandomUpToAMillion();
            
            userRecord=new User(
                UserName=randomUserName, 
                Email=randomUserName, 
                Alias=randomNum.length()>8 ? randomNum.substring(4, randomNum.length()) : randomNum,
                EmailEncodingKey='UTF-8', 
                FirstName='Apex',
                LastName='Test User', 
                LanguageLocaleKey='en_US', 
                LocaleSIDKey='en_US', 
                profileId=AdminProfile.Id, 
                TimeZoneSIDKey='America/Chicago',
                ADID__c='A'+randomNum,
                FederationIdentifier='F'+randomNum,
                Contractor__c=false,
                Non_Employee__c=false,
                Non_Interactive_User__c=false,
                IsActive=true,
                Hire_date__c=Date.today()
            );
            userRecord.putSObject('Profile', adminProfile);
            insert userRecord;
        }
    }
    
    private static Id generateContent(Boolean enableAcknowledge)
    {
        RecordType ContentRT=[select Id FROM RecordType WHERE Name='Policy']; 
        
        ContentVersion testContentInsert=new ContentVersion();
        testContentInsert.ContentURL='http://www.google.com/';
        testContentInsert.Title='Google.com';
        testContentInsert.RecordTypeId=ContentRT.Id; 
        
        insert testContentInsert;
        
        ContentVersion testContent=[SELECT ContentDocumentId FROM ContentVersion where Id=:testContentInsert.Id];        
        ContentWorkspace testWorkspace=[SELECT Id FROM ContentWorkspace WHERE Name='Policy'];
        
        ContentWorkspaceDoc newWorkspaceDoc=new ContentWorkspaceDoc();        
        newWorkspaceDoc.ContentWorkspaceId=testWorkspace.Id;
        newWorkspaceDoc.ContentDocumentId=testContent.ContentDocumentId;
        
        insert newWorkspaceDoc;
        
        testContent.Acknowledgement_Required__c=enableAcknowledge;
        testContent.Geographic_Applicability__c='Global';
        testContent.Expiration_Date__c=date.today().addDays(3);
        testContent.Policy_Effective_Date__c=date.today();
        
        update testContent; 
        return testContent.id;
    }
    
    private static testMethod void constructorTestPositiveOne()
    {
        User userRecord=[SELECT Id FROM User WHERE UserName LIKE '%EMP_AcknowledgementPage_Test%'];
        
        test.startTest();
        System.runAs(userRecord)
        {
            EMP_AcknowledgementPage_Controller controllerRef=new EMP_AcknowledgementPage_Controller();
        }
        test.stopTest();
    }
    
    private static testMethod void constructorTestPositiveTwo()
    {
        User userRecord=[SELECT Id FROM User WHERE UserName LIKE '%EMP_AcknowledgementPage_Test%'];
        Contact testUserContactRecord=[SELECT Id, User__c FROM Contact WHERE User__c=:userRecord.Id];
        List<EMP_Policy__c> testPolicyRecord = new List<EMP_Policy__c>();
        testPolicyRecord=[SELECT Id, Acknowledgement_Status__c FROM EMP_Policy__c WHERE Employee_Contact__c=:testUserContactRecord.Id];
        if(!testPolicyRecord.isEMpty())
        {
            testPolicyRecord[0].Acknowledgement_Status__c=true;
            update testPolicyRecord;
        }
        
        test.startTest();
        System.runAs(userRecord)
        {
            EMP_AcknowledgementPage_Controller controllerRef=new EMP_AcknowledgementPage_Controller();
        }
        test.stopTest();
    }
    
    private static testMethod void constructorTestNegativeOne()
    {
        User userRecord=[SELECT Id FROM User WHERE UserName LIKE '%EMP_AcknowledgementPage_Test%'];
        Contact testUserContactRecord=[SELECT Id, User__c FROM Contact WHERE User__c=:userRecord.Id];
        delete testUserContactRecord;
        
        test.startTest();
        System.runAs(userRecord)
        {
            EMP_AcknowledgementPage_Controller controllerRef=new EMP_AcknowledgementPage_Controller();
        }
        test.stopTest();
    }
    
    private static testMethod void constructorTestNegativeTwo()
    {
        User userRecord=[SELECT Id FROM User WHERE UserName LIKE '%EMP_AcknowledgementPage_Test%'];
        Contact testUserContactRecord=[SELECT Id, User__c FROM Contact WHERE User__c=:userRecord.Id];
        List<EMP_Policy__c> testPolicyRecord = new List<EMP_Policy__c>();
        testPolicyRecord=[SELECT Id, Acknowledgement_Status__c FROM EMP_Policy__c WHERE Employee_Contact__c=:testUserContactRecord.Id];
        if(!testPolicyRecord.isEmpty())
        {
            delete testPolicyRecord;
        }
        
        test.startTest();
        System.runAs(userRecord)
        {
            EMP_AcknowledgementPage_Controller controllerRef=new EMP_AcknowledgementPage_Controller();
        }
        test.stopTest();
    }
    
    private static testMethod void acknowledgePolicyTest()
    {
        User userRecord=[SELECT Id FROM User WHERE UserName LIKE '%EMP_AcknowledgementPage_Test%'];
        Contact testUserContactRecord=[SELECT Id, User__c FROM Contact WHERE User__c=:userRecord.Id];
        List<EMP_Policy__c> testPolicyRecord = new List<EMP_Policy__c>(); 
        testPolicyRecord=[SELECT Id, Acknowledgement_Status__c FROM EMP_Policy__c WHERE Employee_Contact__c=:testUserContactRecord.Id];
        
        if(!testPolicyRecord.isEmpty())
        {
            test.startTest();
            System.runAs(userRecord)
            {
                EMP_AcknowledgementPage_Controller controllerRef=new EMP_AcknowledgementPage_Controller();
                controllerRef.policyId=testPolicyRecord[0].Id;
                controllerRef.acknowledgePolicy();
            }
            test.stopTest();
        }
    }
}