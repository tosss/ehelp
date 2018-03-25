@isTest
private class CB_CreativeSupportMStoneTimeTrigg_Test {
	
	static testMethod void creativeSupportTest()
	{
		Account acc = DS_TestObjects.NewAccount_Inserted();
        Contact c = new Contact();
        c.FirstName = 'First';
        c.LastName = 'Last';
        c.AccountId =acc.Id;
        insert c;
        
        MilestoneType sameDayMT = [Select Id, Name from MilestoneType where name like '%0 %Day%' limit 1];
        
        //system.debug('---MileStoneType----'+mt);
        BusinessHours testHours = [select Id, Name from BusinessHours where Name = :'Creative Team Business Hours' limit 1];
        
        
        list<Case> testList = new list<Case>();
        
        WebID__c testWebId = new WebID__c();
        testWebId.Name='test';
        testWebId.Account__c =acc.Id;
        insert testWebId;
        
        Entitlement testEnt = new Entitlement();
        testEnt.Name = 'TestEntitlement';
        testEnt.AccountId = acc.Id;
        testEnt.WebID__c = testWebId.Id;
        testEnt.BusinessHoursId = testHours.Id;
        insert testEnt;
        
        Case testCase = new Case();
        testCase.EntitlementId = testEnt.Id;
        testCase.Account = acc;
        //testCase.Escalation_Reason__c='Pricing/Inventory Issue';
        testCase.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');
        testCase.ContactId = c.Id;
        testCase.WebID__c = testWebId.Id;
        testCase.X911_Escalation__c = 'Our Mistake';
        testCase.DA_Echelon_Level__c = 'Platinum';
        testCase.SlaStartDate = DateTime.newInstance(2015,03,02,14,01,01);
        testList.add(testCase);
        insert testList;
        
        Test.startTest();
        CB_CreativeSupportMStoneTimeTriggUpdte testCSupportCalculator = new CB_CreativeSupportMStoneTimeTriggUpdte();
        
        //For TestCase-1 Start//
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,03,14,01,01);
        update testCase;
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,04,14,01,01);
        update testCase;
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,05,14,01,01);
        update testCase;
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,06,14,01,01);
        update testCase;
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,07,03,01,01);
        update testCase;
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,08,14,01,01);
        update testCase;
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        //For TestCase-1 End//
	}

}