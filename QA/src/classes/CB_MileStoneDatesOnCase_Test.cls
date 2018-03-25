/**
 * 06/02/15 - Venkata Shrivol - Created
 * Description - Test Class for CB_MileStoneDatesOnCase_Handler
 */
//2015-11-27    vishal.bandari@cdk.com    RQ-05289:changed prepareData method to add contact record type
@isTest 
private class CB_MileStoneDatesOnCase_Test {
    static Case testCase;
    static WebID__c testWebId;
    static CaseMilestone testCaseMilestone;
    static void prepareData()
    {
        list<Trigger_Toggle__c> triggerToggleList = new list<Trigger_Toggle__c>();
        Trigger_Toggle__c triggerToggle1 = new Trigger_Toggle__c();
        triggerToggle1.Name = ' ALL CB_MileStoneDatesOnCase_Handler';
        triggerToggle1.Code_Reference__c='CB_MileStoneDatesOnCase_Handler';
        triggerToggle1.On__c = true;
        triggerToggle1.RecordType_Name__c='Tier 1';
        triggerToggle1.sObject__c='Case';
        triggerToggleList.add(triggerToggle1);
        
        Trigger_Toggle__c triggerToggle2 = new Trigger_Toggle__c();
        triggerToggle2.Name = 'Tier 1 CB_MileStoneDatesOnCase';
        triggerToggle2.Code_Reference__c='CB_MileStoneDatesOnCase_Handler';
        triggerToggle2.On__c = false;
        triggerToggle2.RecordType_Name__c='';
        triggerToggle2.sObject__c='Case';
        triggerToggleList.add(triggerToggle2);
        
        insert triggerToggleList;
        
        SlaProcess_Settings__c testSettings = new SlaProcess_Settings__c();
        testSettings.Name = 'GM';
        testSettings.EntitlementProcessName__c = 'GM OEM Tech Support';
        insert testSettings;
        
        Account acc = DS_TestObjects.NewAccount_Inserted();
        Contact c = new Contact();
        c.FirstName = 'TestFirst';
        c.LastName = 'TestLast';
        c.AccountId =acc.Id;
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        
        BusinessHours[] testHours = [select Id, Name from BusinessHours where Name = :'GM Tech Support Business Hours' limit 1];
        BusinessHours th = testHours[0];
        
        testWebId = new WebID__c();
        testWebId.Name='gmps-test';
        testWebId.Account__c =acc.Id;
        insert testWebId;
        
        Entitlement testEnt = new Entitlement();
        testEnt.Name = 'GM OEM Tech Support';
        testEnt.AccountId = acc.Id;
        testEnt.WebID__c = testWebId.Id;
        testEnt.BusinessHoursId = th.Id;
        insert testEnt;
        
        testCase = new Case();
        testCase.Priority = 'Standard';
        //testCase.Escalation_Reason__c='Pricing/Inventory Issue';
        testCase.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');
        testCase.EntitlementId = testEnt.Id;
        testCase.Status='Open';
        testCase.Account = acc;
        testCase.ContactId = c.Id;
        testCase.WebID__c = testWebId.Id;
        testCase.SlaStartDate = DateTime.newInstance(2015,03,02,10,01,01);
        insert testCase;
        
    }

    static testMethod void myUnitTest() 
    {
        prepareData();
        set<Id> webIds = new set<Id>();
        webIds.add(testWebId.ID);
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlements(webIds, false);
        set<Id> caseIds = new set<Id>();
        
        testCase.Priority = '1 Business Day';
        testCase.Escalation_Reason__c= 'OEM Compliance Issue';
        testCase.Status='Resolved';
        update testCase;
        caseIds.add(testCase.Id);
        
        
        CB_MileStoneDatesOnCase_Handler.updateTargetDateTimeAI(caseIds);
        CB_MileStoneDatesOnCase_Handler.updateCaseAU(caseIds, caseIds);
       
        
    }
}