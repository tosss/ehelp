/*
Have to look after the update scenario's for all time trigger classes
*/
@isTest
private class CB_HoldenTechMileStonesTimeTrigger_Test {

    static testMethod void holdenTimeTriggerTest() {
    	Account acc = DS_TestObjects.NewAccount_Inserted();
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Last';
        c.AccountId =acc.Id;
        insert c;
        
        MilestoneType sameDayMT = [Select Id, Name from MilestoneType where name like '%0 %Day%' limit 1];
        
        //system.debug('---MileStoneType----'+mt);
        BusinessHours[] testHours = [select Id, Name from BusinessHours where Name = :'Holden Business Hours' limit 1];
        BusinessHours th = testHours[0];
        
        list<Case> testList = new list<Case>();
        
        WebID__c testWebId = new WebID__c();
        testWebId.Name='holden-test';
        testWebId.Account__c =acc.Id;
        insert testWebId;
        
        Entitlement testEnt = new Entitlement();
        testEnt.Name = 'TestEntitlement';
        testEnt.AccountId = acc.Id;
        testEnt.WebID__c = testWebId.Id;
        testEnt.BusinessHoursId = th.Id;
        insert testEnt;
        
        Case testCase = new Case();
        testCase.Priority = 'Same Day';
        testCase.Escalation_Reason__c='Pricing/Inventory Issue';
        testCase.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');
        testCase.EntitlementId = testEnt.Id;
        testCase.Account = acc;
        testCase.ContactId = c.Id;
        testCase.WebID__c = testWebId.Id;
        testCase.SlaStartDate = DateTime.newInstance(2015,03,02,10,01,01);
        testList.add(testCase);
        insert testList;
        
        Test.startTest();
        CB_HoldenTechMileStonesTimeTriggerUpdate testHoldenCalculator = new CB_HoldenTechMileStonesTimeTriggerUpdate();
        
        //For TestCase-1 Start//
        testHoldenCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,03,10,01,01);
        update testCase;
        testHoldenCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,04,10,01,01);
        update testCase;
        testHoldenCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,05,10,01,01);
        update testCase;
        testHoldenCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,06,10,01,01);
        update testCase;
        testHoldenCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,07,10,01,01);
        update testCase;
        testHoldenCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,08,10,01,01);
        update testCase;
        testHoldenCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,05,03,01,01);
        update testCase;
        testHoldenCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,05,07,01,01);
        update testCase;
        testHoldenCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        //For TestCase-1 End//
    }
}