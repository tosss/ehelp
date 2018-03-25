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
        MilestoneType threeDayMT = [Select Id, Name from MilestoneType where name like '%3 %Day%' limit 1];
        
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
                
        DateTime tenThirty = DateTime.newInstance(date.today(), time.newInstance(10, 30, 0, 0));
        
        Case testCase = new Case();
        testCase.EntitlementId = testEnt.Id;
        testCase.Account = acc;
        testCase.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Inquiry - Creative');
        testCase.ContactId = c.Id;
        testCase.WebID__c = testWebId.Id;
        testCase.X911_Escalation__c = 'Our Mistake';
        testCase.DA_Echelon_Level__c = 'Platinum';
        testCase.SlaStartDate = tenThirty.addHours(-2).addMinutes(-30);
        testList.add(testCase);
        insert testList;
        
        CB_CreativeSupportMStoneTimeTriggUpdte testCSupportCalculator = new CB_CreativeSupportMStoneTimeTriggUpdte();
        
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);  
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, threeDayMT.Id);
        
        testCase.SlaStartDate = tenThirty.addHours(2).addMinutes(30);
        update testCase;
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, threeDayMT.Id); 
        
        testCase.SlaStartDate = DateTime.now() + 3;
        update testCase;
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        testCSupportCalculator.calculateMilestoneTriggerTime(testCase.Id, threeDayMT.Id); 
	}

}