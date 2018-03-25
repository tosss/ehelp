@isTest
private class CB_EntitlementWebIdAssignmentHndler_Test {

    static testMethod void webIdAssignmentTest () {
    	
    	User u = DS_TestObjects.NewUser_Inserted();
        Account acc1 = DS_TestObjects.NewAccount_Inserted(); 
    	
    	list<WebID__c> testWebIdList = new list<WebID__c>();
    	WebID__c createTestWebId = new WebID__c();
    	createTestWebId.Name = 'gmps-test';
    	createTestWebId.Status__c = 'Active';
    	createTestWebId.Account__c = acc1.Id;
    	testWebIdList.add(createTestWebId);
    	
    	WebID__c createTestWebId2 = new WebID__c();
    	createTestWebId2.Name = 'holden-test';
    	createTestWebId2.Status__c = 'Active';
    	createTestWebId2.Account__c = acc1.Id;
    	testWebIdList.add(createTestWebId2);
    	
    	WebID__c createTestWebId3 = new WebID__c();
    	createTestWebId3.Name = 'Other';
    	createTestWebId3.Status__c = 'Inactive';
    	createTestWebId3.Account__c = acc1.Id;
    	testWebIdList.add(createTestWebId3);
    	
    	list<SlaProcess_Settings__c> testSettingslist = new list<SlaProcess_Settings__c>();
    	SlaProcess_Settings__c testSettings = new SlaProcess_Settings__c();
    	testSettings.Name = 'Creative Support';
    	testSettings.EntitlementProcessName__c = 'Creative Support';
    	testSettingslist.add(testSettings);
    	
    	SlaProcess_Settings__c testSettings2 = new SlaProcess_Settings__c();
    	testSettings2.Name = 'GM';
    	testSettings2.EntitlementProcessName__c = 'GM OEM Tech Support';
    	testSettingslist.add(testSettings2);
    	
    	SlaProcess_Settings__c testSettings3 = new SlaProcess_Settings__c();
    	testSettings3.Name = 'Holden';
    	testSettings3.EntitlementProcessName__c = 'Holden Tech Support';
    	testSettingslist.add(testSettings3);
    	
    	SlaProcess_Settings__c testSettings4 = new SlaProcess_Settings__c();
    	testSettings4.Name = 'Other';
    	testSettings4.EntitlementProcessName__c = 'US Canada OEM Tech Support';
    	testSettingslist.add(testSettings4);
    	insert testSettingslist;
    	
    	insert testWebIdList;
    	
    	CB_EntitlementsToWebIdAssignment_Handler.isFirstRun = true;
    	
    	
    	
    	Entitlement testEnt = new Entitlement();
    	testEnt.Name = 'Creative Support';
    	testEnt.AccountId = createTestWebId.Account__c;
    	testEnt.WebID__c = createTestWebId.Id;
    	insert testEnt;
    	
    	testWebIdList.clear();
    	createTestWebId.Status__c = 'Inactive';
    	testWebIdList.add(createTestWebId);
    	
    	createTestWebId3.Status__c = 'Active';
    	testWebIdList.add(createTestWebId3);
    	update testWebIdList;
    	
    	
    	/*system.debug('----For GM Tech------'+createTestWebId3.OEM_Hidden__c);
    	//system.debug('--------OEM------'+createTestWebId3.OEM__c);
    	
    	map<Id, WebID__c> newtestMap = new map<Id, WebID__c>();
    	newtestMap.put(createTestWebId2.Id, createTestWebId2);
    	newtestMap.put(createTestWebId3.Id, createTestWebId3);
    	system.debug('----------newtestMap------------'+newtestMap);
    	system.debug('---------------oldMap----------'+oldMap);
    	
    	//CB_EntitlementsToWebIdAssignment_Handler.createEntitlementOnUpdate(oldMap, newtestMap);*/
    }
}