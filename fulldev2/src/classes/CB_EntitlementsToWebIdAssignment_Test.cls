//2016-02-22- anirudh.singh@cdk.com- Created the below test class. As the earlier was not following naming standards.
//2016-02-22- anirudh.singh@cdk.com- Also, re-written the whole test class for following test class standards.
@isTest
public class CB_EntitlementsToWebIdAssignment_Test
{
    @TestSetup
    private static void setupData()
    {
        List<SlaProcess_Settings__c> testSettingsList=new List<SlaProcess_Settings__c>();
        SlaProcess_Settings__c testSettingsOne=new SlaProcess_Settings__c();
        testSettingsOne.Name='Creative Support';
        testSettingsOne.EntitlementProcessName__c='Creative Support';
        testSettingsList.add(testSettingsOne);
        
        SlaProcess_Settings__c testSettingsTwo=new SlaProcess_Settings__c();
        testSettingsTwo.Name='GM';
        testSettingsTwo.EntitlementProcessName__c='GM OEM Tech Support';
        testSettingsList.add(testSettingsTwo);
        
        SlaProcess_Settings__c testSettingsThree=new SlaProcess_Settings__c();
        testSettingsThree.Name='Holden';
        testSettingsThree.EntitlementProcessName__c='Holden Tech Support';
        testSettingsList.add(testSettingsThree);
        
        SlaProcess_Settings__c testSettingsFour=new SlaProcess_Settings__c();
        testSettingsFour.Name='Other';
        testSettingsFour.EntitlementProcessName__c='US Canada OEM Tech Support';
        testSettingsList.add(testSettingsFour);
        insert testSettingsList;
        
        Account acc=DS_TestObjects.NewAccount_Inserted();
        
        List<WebID__c> testWebIdList=new List<WebID__c>();
        WebID__c createTestWebId=new WebID__c();
        createTestWebId.Name='gmps-test';
        createTestWebId.Status__c='Active';
        createTestWebId.Account__c=acc.Id;
        testWebIdList.add(createTestWebId);
        
        WebID__c createTestWebId2=new WebID__c();
        createTestWebId2.Name='holden-test';
        createTestWebId2.Status__c='Active';
        createTestWebId2.Account__c=acc.Id;
        testWebIdList.add(createTestWebId2);
        
        WebID__c createTestWebId3=new WebID__c();
        createTestWebId3.Name='Other';
        createTestWebId3.Status__c='Inactive';
        createTestWebId3.Account__c=acc.Id;
        testWebIdList.add(createTestWebId3);
        insert testWebIdList;
    }
    
    private static testMethod void createEntitlementOnInsertUpdateTest()
    {
        List<WebID__c> testWebIdList=[SELECT Id, Status__c, OEM__c, Account__c FROM WebID__c];
        
        Map<Id, WebID__c> newWebIdMap=new Map<Id, WebID__c>(testWebIdList);
        
        test.startTest();
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlementOnInsert(newWebIdMap);
        test.stopTest();
    }
    
    private static testMethod void createEntitlementOnUpdateTest()
    {
        List<WebID__c> testWebIdList=[SELECT Id, Status__c, OEM__c, Account__c FROM WebID__c];
        
        Map<Id, WebID__c> newWebIdMap=new Map<Id, WebID__c>(testWebIdList);
        
        Map<Id, WebID__c> oldWebIdMap=newWebIdMap.clone();
        List<WebID__c> webIdsList=oldWebIdMap.values();
        webIdsList[0].Status__c='Inactive';
        webIdsList[2].Status__c='Active';
        
        test.startTest();
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlementOnUpdate(oldWebIdMap, newWebIdMap);
        test.stopTest();
    }
    
    private static testMethod void createEntitlementsTest()
    {
        List<WebID__c> testWebIdList=[SELECT Id, Status__c, OEM__c, Account__c FROM WebID__c];
        
        Set<Id> webIds=new Set<Id>();
        webIds.add(testWebIdList[0].Id);
        webIds.add(testWebIdList[1].Id);
        webIds.add(testWebIdList[2].Id);
        
        test.startTest();
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlements(webIds, false);
        
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlements(webIds, true);
        test.stopTest();
    }
    
    private static testMethod void webIdAssignmentTestOne()
    {
        List<WebID__c> testWebIdList=[SELECT Id, Status__c, OEM__c, Account__c FROM WebID__c];
        
        Entitlement testEnt=new Entitlement();
        testEnt.Name='Creative Support';
        testEnt.AccountId=testWebIdList[0].Account__c;
        testEnt.WebID__c=testWebIdList[0].Id;
        insert testEnt;
        
        List<WebID__c> updateWebIdList=new List<WebID__c>();
        testWebIdList[0].Status__c='Inactive';
        updateWebIdList.add(testWebIdList[0]);
        
        testWebIdList[2].Status__c='Active';
        updateWebIdList.add(testWebIdList[2]);
        update updateWebIdList;
        
        Set<Id> webIds=new Set<Id>();
        webIds.add(updateWebIdList[0].Id);
        webIds.add(updateWebIdList[1].Id);
        
        test.startTest();
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlements(webIds, false);
        
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlements(webIds, true);
        test.stopTest();
    }
    
    private static testMethod void webIdAssignmentTestTwo()
    {
        List<WebID__c> testWebIdList=[SELECT Id, Status__c, OEM__c, Account__c FROM WebID__c];
        
        Entitlement testEnt=new Entitlement();
        testEnt.Name='Test Entitlement';
        testEnt.AccountId=testWebIdList[0].Account__c;
        testEnt.WebID__c=testWebIdList[0].Id;
        insert testEnt;
        
        List<WebID__c> updateWebIdList=new List<WebID__c>();
        testWebIdList[0].Status__c='Inactive';
        updateWebIdList.add(testWebIdList[0]);
        
        testWebIdList[2].Status__c='Active';
        updateWebIdList.add(testWebIdList[2]);
        update updateWebIdList;
        
        Set<Id> webIds=new Set<Id>();
        webIds.add(updateWebIdList[0].Id);
        webIds.add(updateWebIdList[1].Id);
        
        test.startTest();
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlements(webIds, false);
        
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlements(webIds, true);
        test.stopTest();
    }
}