//2016-01-21- anirudh.singh@cdk.com- Created this Test Class for handler class CB_WebID_Handler for Request RQ-06027, as the earlier Test Class was not naming standards.
//2016-01-21- anirudh.singh@cdk.com- Also, re-written the whole test class for following test class standards.
@isTest
public class CB_WebID_Test
{
    @TestSetup
    private static void setupData()
    {
        CustomSettings__c customSettingRecord=new CustomSettings__c();
        customSettingRecord.Name='Test';
        customSettingRecord.WebIDTriggers_On__c=true;
        insert customSettingRecord;
        
        List<Account_Team_Sync_Settings__c> accTeamSettingsList=DS_TestObjects.getAcountTeamSyncSettings();
        
        List<SlaProcess_Settings__c> entitlementProcessSettingsList=new List<SlaProcess_Settings__c>();
        SlaProcess_Settings__c entitlementProcessSettingsOne=new SlaProcess_Settings__c();
        entitlementProcessSettingsOne.Name='Porsche';
        entitlementProcessSettingsOne.EntitlementProcessName__c='US Canada OEM Tech Support';
        entitlementProcessSettingsList.add(entitlementProcessSettingsOne);
        
        SlaProcess_Settings__c entitlementProcessSettingsTwo=new SlaProcess_Settings__c();
        entitlementProcessSettingsTwo.Name='Other';
        entitlementProcessSettingsTwo.EntitlementProcessName__c='US Canada OEM Tech Support';
        entitlementProcessSettingsList.add(entitlementProcessSettingsTwo);
        insert entitlementProcessSettingsList;
        
        List<Account> accList=new List<Account>();
        for(Integer i=0; i<7; i++)
        {
            accList.add(new Account(Name='Test Account'+i));
        }
        insert accList;
        
        //Creating Test Users.
        Profile standardProfile=DS_TestObjects.getStandardProfile();
        
        List<String> randomNumbersList=new List<String>();
        for(Integer i=0; i<8; i++)
        {
            String randomNum=ALL_UtilitiesRandom.TrueRandomUpToAMillion();
            randomNumbersList.add(randomNum);
        }
        
        List<String> randomUserNamesList=new List<String>();
        for(Integer i=0; i<8; i++)
        {
            String randomUserName=ALL_UtilitiesRandom.RandomUserName('RequestTeamMember'+i);
            randomUserNamesList.add(randomUserName);
        }
        
        List<User> testUserList=new List<User>();
        for(Integer i=0; i<8; i++)
        {
            User userRecord=new User(Username=randomUserNamesList[i], 
                                     IsActive=true, 
                                     Email=randomUserNamesList[i], 
                                     LastName='WebIdTriggerTestUser'+String.valueOf(i), 
                                     FirstName='test'+String.valueOf(i), 
                                     Alias=randomNumbersList[i].length()>8?randomNumbersList[i].substring(4, randomNumbersList[i].length()):randomNumbersList[i], 
                                     CommunityNickName='testNickName'+String.valueOf(i), 
                                     TimeZoneSidKey='America/Los_Angeles', 
                                     LocaleSidKey='en_US', 
                                     EmailEncodingKey='UTF-8', 
                                     ProfileId=standardProfile.Id, 
                                     LanguageLocaleKey='en_US', 
                                     ADID__c='test'+String.valueOf(i)+'UserAdid', 
                                     FederationIdentifier='F'+randomNumbersList[i]
                                    );
            testUserList.add(userRecord);
        }
        insert testUserList;
    }
    
    private static WebID__c generateWebIdRecord(Integer recordNumber, List<Account_Team_Sync_Settings__c> accTeamSettingsList, List<User> userList)
    {
        WebID__c newWebIdRecord=new WebID__c();
        newWebIdRecord.Name='test-WebID-'+recordNumber;
        newWebIdRecord.Status__c='Inactive';
        for(Integer j=0; j<accTeamSettingsList.size(); j++)
        {
            ALL_UtilitiesData.PutDataInNestedFields(accTeamSettingsList[j].User_ID_Field_API_Name__c, newWebIdRecord, userList[j].Id);
        }
        return newWebIdRecord;
    }
    
    private static testMethod void initializeAndProcessRecordsTestOne()
    {
        test.startTest();
        CB_WebID_Handler.initializeAndProcessRecords(Null, Null, Null);
        
        CB_WebID_Handler.initializeAndProcessRecords('Account', new Map<Id, Account>(), Null);
        
        CB_WebID_Handler.initializeAndProcessRecords('WebID__c', Null, new Map<Id, WebID__c>());
        test.stopTest();
    }
    
    private static testMethod void initializeAndProcessRecordsTestTwo()
    {
        List<Account> accList=[SELECT Id, Name FROM Account];
        List<Account_Team_Sync_Settings__c> accTeamSettingsList=[SELECT sObject__c, Team_Role__c, User_ID_Field_API_Name__c from Account_Team_Sync_Settings__c WHERE sObject__c='WebID__c'];
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'WebIdTriggerTestUser%'];
        
        test.startTest();
        
        WebID__c webIdRecordOne=generateWebIdRecord(0, accTeamSettingsList, userList);
        webIdRecordOne.Account__c=accList[0].Id;
        insert webIdRecordOne;
        
        Map<Id, WebID__c> oldWebIdMap=new Map<Id, WebID__c>();
        oldWebIdMap.put(webIdRecordOne.Id, webIdRecordOne);
        
        Map<Id, WebID__c> newWebIdMap=new Map<Id, WebID__c>();
        WebID__c webIdRecordTwo=webIdRecordOne.clone(true);
        newWebIdMap.put(webIdRecordTwo.Id, webIdRecordTwo);
        newWebIdMap.values()[0].Status__c='Active';
        
        CB_WebID_Handler.initializeAndProcessRecords('WebID__c', oldWebIdMap, newWebIdMap);
        
        update newWebIdMap.values();
        List<WebID__c> webIdsToInsertList=new List<WebID__c>();
        for(Integer i=0; i<7; i++)
        {
            WebID__c newWebId=generateWebIdRecord(i, accTeamSettingsList, userList);
            webIdsToInsertList.add(newWebId);
        }
        
        try
        {
            insert webIdsToInsertList;
        }
        catch(Exception ex)
        {
            system.assert(ex.getMessage().contains('Only one WebID may be inserted or updated at a time. Please ensure the batch size is set to 1.'));
        }
        
        WebID__c webIdRecordThree=generateWebIdRecord(1, accTeamSettingsList, userList);
        webIdRecordThree.Account__c=accList[0].Id;
        insert webIdRecordThree;
        
        webIdsToInsertList.clear();
        webIdsToInsertList.add(webIdRecordOne);
        webIdsToInsertList.add(webIdRecordThree);
        
        webIdsToInsertList[0].Status__c='';
        webIdsToInsertList[1].Status__c='';
        
        try
        {
            update webIdsToInsertList;
        }
        catch(Exception ex)
        {
            system.assert(ex.getMessage().contains('Only one WebID may be inserted or updated at a time. Please ensure the batch size is set to 1.'));
        }
        test.stopTest();
    }
    
    private static testMethod void syncAccountTeamAndWebIdUsersTest()
    {
        List<Account> accList=[SELECT Id, Name FROM Account];
        
        test.startTest();
        List<Id> accountIdsList=new List<Id>();
        accountIdsList.add(accList[0].Id);
        accountIdsList.add(accList[1].Id);
        
        CB_WebID_Handler.initializeAndProcessRecords('WebID__c', Null, new Map<Id, WebID__c>());
        
        CB_WebID_Handler.syncAccountTeamAndWebIdUsers(accountIdsList);
        test.stopTest();
    }
    
    private static testMethod void processWebIdsAfterInsertTest()
    {
        List<Account> accList=[SELECT Id, Name FROM Account];
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'WebIdTriggerTestUser%'];
        List<Account_Team_Sync_Settings__c> accTeamSettingsList=[SELECT sObject__c, Team_Role__c, User_ID_Field_API_Name__c from Account_Team_Sync_Settings__c WHERE sObject__c='WebID__c'];
        
        test.startTest();
        
        WebID__c webIdRecordOne=generateWebIdRecord(0, accTeamSettingsList, userList);
        webIdRecordOne.Account__c=accList[0].Id;
        insert webIdRecordOne;
        
        Map<Id, WebID__c> newWebIdMap=new Map<Id, WebID__c>();
        newWebIdMap.put(webIdRecordOne.Id, webIdRecordOne);
        
        CB_WebID_Handler.initializeAndProcessRecords('WebID__c', Null, newWebIdMap);
        
        CB_WebID_Handler.processWebIdsAfterInsert(newWebIdMap);
        test.stopTest();
    }
    
    private static testMethod void processWebIdsAfterUpdateTest()
    {
        List<Account> accList=[SELECT Id, Name FROM Account];
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'WebIdTriggerTestUser%'];
        List<Account_Team_Sync_Settings__c> accTeamSettingsList=[SELECT sObject__c, Team_Role__c, User_ID_Field_API_Name__c from Account_Team_Sync_Settings__c WHERE sObject__c='WebID__c'];
        
        test.startTest();
        
        WebID__c webIdRecordOne=generateWebIdRecord(0, accTeamSettingsList, userList);
        webIdRecordOne.Account__c=accList[0].Id;
        insert webIdRecordOne;
        
        Map<Id, WebID__c> oldWebIdMap=new Map<Id, WebID__c>();
        oldWebIdMap.put(webIdRecordOne.Id, webIdRecordOne);
        
        Map<Id, WebID__c> newWebIdMap=new Map<Id, WebID__c>();
        WebID__c webIdRecordTwo=webIdRecordOne.clone(true);
        webIdRecordTwo.Id=webIdRecordOne.Id;
        newWebIdMap.put(webIdRecordOne.Id, webIdRecordTwo);
        newWebIdMap.values()[0].Status__c='Active';
        
        CB_WebID_Handler.initializeAndProcessRecords('WebID__c', oldWebIdMap, Null);
        CB_WebID_Handler.processWebIdsAfterUpdate(oldWebIdMap, newWebIdMap);
        test.stopTest();
    }
    
    private static testMethod void setAccountPlanFieldsTest()
    {
        List<Account> accList=[SELECT Id, Name FROM Account];
        List<User> userList=[SELECT Id FROM User WHERE LastName LIKE 'WebIdTriggerTestUser%'];
        List<Account_Team_Sync_Settings__c> accTeamSettingsList=[SELECT sObject__c, Team_Role__c, User_ID_Field_API_Name__c from Account_Team_Sync_Settings__c WHERE sObject__c='WebID__c'];
        
        test.startTest();
        
        WebID__c webIdRecordOne=generateWebIdRecord(0, accTeamSettingsList, userList);
        webIdRecordOne.Account__c=accList[0].Id;
        insert webIdRecordOne;
        
        Account_Plan__c AccountPlan=DS_TestObjects.NewAccountPlan_Inserted();
        
        Account_Plan__c newAccountPlan=new Account_Plan__c();
        newAccountPlan.Account__c=webIdRecordOne.Account__c;
        newAccountPlan.WebID__c=webIdRecordOne.Id;
        RecordType accountPlanRecordType=[Select Id, Name From RecordType Where SobjectType='Account_Plan__c' AND Name='DAA Account Plan'];
        newAccountPlan.RecordTypeId=accountPlanRecordType.Id;
        insert newAccountPlan;
        
        Map<Id, WebID__c> newWebIdMap=new Map<Id, WebID__c>();
        newWebIdMap.put(webIdRecordOne.Id, webIdRecordOne);
        
        webIdRecordOne.Status__c='Active';
        update webIdRecordOne;
        
        CB_WebID_Handler.initializeAndProcessRecords('WebID__c', Null, newWebIdMap);
        
        CB_WebID_Handler.processWebIdsAfterInsert(newWebIdMap);
        
        webIdRecordOne.Digital_Advertising_Strategist__c=userList[0].Id;
        webIdRecordOne.Status__c='Inactive';
        update webIdRecordOne;
        
        CB_WebID_Handler.processWebIdsAfterInsert(newWebIdMap);
        
        accountPlanRecordType=[Select Id, Name From RecordType Where SobjectType='Account_Plan__c' AND Name='AMA Account Plan'];
        newAccountPlan.RecordTypeId=accountPlanRecordType.Id;
        update newAccountPlan;
        
        webIdRecordOne.LMA_Strategist__c=userList[0].Id;
        webIdRecordOne.Status__c='Active';
        update webIdRecordOne;
        test.stopTest();
    }
}