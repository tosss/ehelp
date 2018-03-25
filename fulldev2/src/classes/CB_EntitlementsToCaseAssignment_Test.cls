@isTest
private class CB_EntitlementsToCaseAssignment_Test 
{
    static testmethod void caseToEntTest()
    {
        Account acc = DS_TestObjects.NewAccount_Inserted();
    	list<SObject> contactWebIdList = new list<SObject>();
    	Contact testContact = new Contact();
    	testContact.FirstName = 'First';
    	testContact.LastName = 'Last';
    	testContact.AccountId = acc.Id;
    	insert testContact;
        
        list<SlaProcess_Settings__c> testSettingslist = new list<SlaProcess_Settings__c>();
    	SlaProcess_Settings__c testSettings = new SlaProcess_Settings__c();
    	testSettings.Name = 'Creative Support';
    	testSettings.EntitlementProcessName__c = 'Creative Support';
    	testSettingslist.add(testSettings);
    	
    	SlaProcess_Settings__c testSettings2 = new SlaProcess_Settings__c();
    	testSettings2.Name = 'Kia';
    	testSettings2.EntitlementProcessName__c = 'US Canada OEM Tech Support';
    	testSettingslist.add(testSettings2);
    	
        insert testSettingslist;
        
        list<CB_CaseRecordTypes__c> customSettingList = new list<CB_CaseRecordTypes__c>();
        CB_CaseRecordTypes__c customSetting1 = new CB_CaseRecordTypes__c();
        customSetting1.Name='Tier 2 - Content';
        customSetting1.EntitlementSupport_Type__c = 'Technical Support';
        customSettingList.add(customSetting1);
        
        CB_CaseRecordTypes__c customSetting2 = new CB_CaseRecordTypes__c();
        customSetting2.Name='Inquiry - Creative';
        customSetting2.EntitlementSupport_Type__c = 'Creative Support';
        customSettingList.add(customSetting2);
        
        insert customSettingList;
        
        list<Trigger_Toggle__c> triggerToggleList = new list<Trigger_Toggle__c>();
        Trigger_Toggle__c triggerToggle1 = new Trigger_Toggle__c();
        triggerToggle1.Name = 'Tier 2 -Content CB_EntToCaseAssignment';
        triggerToggle1.Code_Reference__c='CB_EntitlementsToCaseAssignment_Handler';
        triggerToggle1.On__c = true;
        triggerToggle1.RecordType_Name__c='Tier 2 - Content';
        triggerToggle1.sObject__c='Case';
        triggerToggleList.add(triggerToggle1);
        
        Trigger_Toggle__c triggerToggle3 = new Trigger_Toggle__c();
        triggerToggle3.Name = '	Inquiry-CreativeCB_EntToCaseAssignment';
        triggerToggle3.Code_Reference__c='CB_EntitlementsToCaseAssignment_Handler';
        triggerToggle3.On__c = true;
        triggerToggle3.RecordType_Name__c='Inquiry - Creative';
        triggerToggle3.sObject__c='Case';
        triggerToggleList.add(triggerToggle3);
        
        Trigger_Toggle__c triggerToggle2 = new Trigger_Toggle__c();
        triggerToggle2.Name = 'ALL CB_EntitlementsToCaseAssignment';
        triggerToggle2.Code_Reference__c='CB_EntitlementsToCaseAssignment_Handler';
        triggerToggle2.On__c = false;
        triggerToggle2.RecordType_Name__c='';
        triggerToggle2.sObject__c='Case';
        triggerToggleList.add(triggerToggle2);
        
        insert triggerToggleList;
        
        
        Set<Id> testSet = new Set<Id>();
        list<WebID__c> webIdlist = new list<WebID__c>();
    	/*WebID__c testId = new WebID__c();
    	testId.Account__c = acc.Id;
    	testId.Name = 'gmps-test';
        testId.Status__c = 'Active';
        webIdlist.add(testId);
    	//insert testId;*/
        
        WebID__c testId2 = new WebID__c();
    	testId2.Account__c = acc.Id;
    	testId2.Name = 'kia-test';
        testId2.Status__c = 'Active';
        webIdlist.add(testId2);
    	insert webIdlist;
        //testSet.add(testId.Id);
        testSet.add(testId2.Id);
        
        //CB_EntitlementsToWebIdAssignment_Handler.createEntitlements(testSet, false);
        
        list<Entitlement> testEntList = new list<Entitlement>();
        Entitlement testEnt = new Entitlement();
        testEnt.Name = 'Creative Support';
        testEnt.AccountId = acc.Id;
        testEnt.Type = 'Creative Support';
        testEnt.WebID__c = testId2.Id;
        testEnt.StartDate = system.today();
        testEntList.add(testEnt);
        
        
        Entitlement testEnt2 = new Entitlement();
        testEnt2.Name = 'US Canada Technical Support';
        testEnt2.AccountId = acc.Id;
        testEnt2.Type = 'Technical Support';
        testEnt2.WebID__c = testId2.Id;
        testEnt2.StartDate = system.today();
        testEntList.add(testEnt2);
        insert testEntList;
        
        list<Case> testCaselist = new list<Case>();
        String creativeRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Inquiry - Creative');
        Case testCase = new Case();
    	testCase.RecordTypeId = creativeRecordTypeId;
    	testCase.AccountId = acc.Id;
    	testCase.ContactId = testContact.Id;
    	//testCase.Creative_Case_Limit__c = 0;
    	testCase.WebID__c= testId2.Id;
    	testCase.Status = 'Open';
        testCaselist.add(testCase);
        
        String tierRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 2 - Content');
        Case testCase2 = new Case();
    	testCase2.RecordTypeId = tierRecordTypeId;
    	testCase2.AccountId = acc.Id;
    	testCase2.ContactId = testContact.Id;
    	//testCase2.Creative_Case_Limit__c = 0;
    	testCase2.WebID__c= testId2.Id;
    	testCase2.Status = 'Open';
        testCaselist.add(testCase2);
    	insert testCaselist;
        
        
        CB_EntitlementsToCaseAssignment_Handler.updateEntToCaseOnWebIdUpdate(testSet);
     
    }

}