@isTest
private class CB_GMTechMileStoneTimeTrigger_Test {
    static Case testCase, testCase2, testCase3, testCase4, testCase5;
    static MilestoneType sameDayMT, oneDayMT,twoDayMT,threeDayMT,tenDayMT;
    static list<MilestoneType> milestoneList;
    static void prepareTestData(){
        
        //User u = DS_TestObjects.NewUser_Inserted();
        Account acc = DS_TestObjects.NewAccount_Inserted();
        Contact c = new Contact();
        c.FirstName = 'TestFirst';
        c.LastName = 'TestLast';
        c.AccountId =acc.Id;
        insert c;
        
        //MilestoneType[] milestoneList = [select Id, Name from MilestoneType limit 1];
        //MilestoneType mt = milestoneList[0];
        
        list<String> mileStoneNameList = new list<String>{'%0 %Day%','%1 Day%','%2 Day%','%3 Day%','%10 Day%'};
        milestoneList = [Select Id, Name from MilestoneType where name like :mileStoneNameList];
        for(MilestoneType mt:milestoneList)
        {
            if(mt.Name.equalsIgnoreCase('0 Same Day'))
            {
                sameDayMT = mt;
            }
            if(mt.Name.equalsIgnoreCase('1 Day'))
            {
                oneDayMT = mt;
            }
            if(mt.Name.equalsIgnoreCase('2 Day'))
            {
                twoDayMT = mt;
            }
            if(mt.Name.equalsIgnoreCase('3 Day'))
            {
                threeDayMT = mt;
            }
            if(mt.Name.equalsIgnoreCase('10 Day'))
            {
                tenDayMT = mt;
            }
            
        }
        
        BusinessHours[] testHours = [select Id, Name from BusinessHours where Name = :'GM Tech Support Business Hours' limit 1];
        BusinessHours th = testHours[0];
        
        list<Case> testList = new list<Case>();
        
        WebID__c testWebId = new WebID__c();
        testWebId.Name='gmps-test';
        testWebId.Account__c =acc.Id;
        insert testWebId;
        
        Entitlement testEnt = new Entitlement();
        testEnt.Name = 'TestEntitlement';
        testEnt.AccountId = acc.Id;
        testEnt.WebID__c = testWebId.Id;
        testEnt.BusinessHoursId = th.Id;
        insert testEnt;
        
        testCase = new Case();
        testCase.Priority = 'Standard';
        //testCase.Escalation_Reason__c='Pricing/Inventory Issue';
        testCase.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');
        testCase.EntitlementId = testEnt.Id;
        testCase.Account = acc;
        testCase.ContactId = c.Id;
        testCase.WebID__c = testWebId.Id;
        testCase.SlaStartDate = DateTime.newInstance(2015,03,02,10,01,01);
        testList.add(testCase);
        
        
        testCase2 = new Case();
        testCase2.Priority = 'Standard';
        testCase2.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');
        //testCase2.Escalation_Reason__c='Other Technical Issue';
        testCase2.EntitlementId = testEnt.Id;
        testCase2.Account = acc;
        testCase2.ContactId = c.Id;
        testCase2.WebID__c = testWebId.Id;
        testCase2.SlaStartDate = DateTime.newInstance(2015,03,05,10,01,01);
        testList.add(testCase2);
        
        testCase3 = new Case();
        testCase3.Priority = 'Standard';
        testCase3.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');
        //testCase3.Escalation_Reason__c='OEM Compliance Issue';
        testCase3.EntitlementId = testEnt.Id;
        testCase3.Account = acc;
        testCase3.ContactId = c.Id;
        testCase3.WebID__c = testWebId.Id;
        testCase3.SlaStartDate = DateTime.newInstance(2015,03,05,10,01,01);
        testList.add(testCase3);
      
        
        testCase4 = new Case();
        testCase4.Priority = 'Standard';
        testCase4.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');
        //testCase4.Escalation_Reason__c='Other Technical Issue';
        testCase4.EntitlementId = testEnt.Id;
        testCase4.Account = acc;
        testCase4.ContactId = c.Id;
        testCase4.WebID__c = testWebId.Id;
        testCase4.Product_Category__c = '3rd Party Implementations';
        testCase4.SlaStartDate = DateTime.newInstance(2015,03,05,10,01,01);
        testList.add(testCase4);
        
        testCase5 = new Case();
        testCase5.Priority = 'Standard';
        testCase5.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');
        //testCase5.Escalation_Reason__c='Other Technical Issue';
        testCase5.EntitlementId = testEnt.Id;
        testCase5.Product_Category__c = 'Page Customization';
        testCase5.Problem_Code__c = 'Redesign';
        testCase5.Account = acc;
        testCase5.ContactId = c.Id;
        testCase5.WebID__c = testWebId.Id;
        testCase5.SlaStartDate = DateTime.newInstance(2015,03,05,10,01,01);
        testList.add(testCase5);        
        insert testList;
        
        /*testCase.Priority = 'Same Day';
        testCase2.Priority = '1 Business Day';
        testCase3.Priority = '2 Business Days';
        testCase4.Priority = 'Normal';
        testCase5.Priority = 'Normal';*/
        
    }
    static testMethod void gmTechTimetriggerTest(){
        
        prepareTestData();
        Test.startTest();
        //For TestCase-2 Start//
        CB_GMTechMileStonesTimeTriggerUpdate testCalculator = new CB_GMTechMileStonesTimeTriggerUpdate();
        
        testCase2.SlaStartDate = DateTime.newInstance(2015,03,06,10,01,01);
        update testCase2;
        testCalculator.calculateMilestoneTriggerTime(testCase2.Id, oneDayMT.Id);
        
        testCase2.SlaStartDate = DateTime.newInstance(2015,03,07,12,01,01);
        update testCase2;
        testCalculator.calculateMilestoneTriggerTime(testCase2.Id, oneDayMT.Id);
        //For TestCase-2 End//
        
        //For TestCase-3 Start//
        //testCalculator.calculateMilestoneTriggerTime(testCase3.Id, twoDayMT.Id);
        
        testCase3.SlaStartDate = DateTime.newInstance(2015,03,06,10,01,01);
        update testCase3;
        testCalculator.calculateMilestoneTriggerTime(testCase3.Id, twoDayMT.Id);
        
        testCase3.SlaStartDate = DateTime.newInstance(2015,03,07,12,01,01);
        update testCase3;
        testCalculator.calculateMilestoneTriggerTime(testCase3.Id, twoDayMT.Id);
        //For TestCase-3 End//
        
        // For TestCase-4 Start
        testCalculator.calculateMilestoneTriggerTime(testCase4.Id, threeDayMT.Id);
        
        testCase4.SlaStartDate = DateTime.newInstance(2015,03,06,10,01,01);
        update testCase4;
        testCalculator.calculateMilestoneTriggerTime(testCase4.Id, threeDayMT.Id);
        
        testCase4.SlaStartDate = DateTime.newInstance(2015,03,06,03,01,01);
        update testCase4;
        testCalculator.calculateMilestoneTriggerTime(testCase4.Id, threeDayMT.Id);
        
        testCase4.SlaStartDate = DateTime.newInstance(2015,03,06,20,01,01);
        update testCase4;
        testCalculator.calculateMilestoneTriggerTime(testCase4.Id, threeDayMT.Id);
        // For TestCase-4 End
        
        //For TestCase-5 Start
        testCalculator.calculateMilestoneTriggerTime(testCase5.Id, tenDayMT.Id);
        
        testCase5.SlaStartDate = DateTime.newInstance(2015,03,06,10,01,01);
        update testCase5;
        testCalculator.calculateMilestoneTriggerTime(testCase5.Id, tenDayMT.Id);
        
        testCase5.SlaStartDate = DateTime.newInstance(2015,03,07,10,01,01);
        update testCase5;
        testCalculator.calculateMilestoneTriggerTime(testCase5.Id, tenDayMT.Id);
        //For TestCase-5 End
        
        Test.stopTest();
        
        
        
    }
    static testMethod void testCase1(){
        prepareTestData();
        Test.startTest();
        CB_GMTechMileStonesTimeTriggerUpdate testCalculator = new CB_GMTechMileStonesTimeTriggerUpdate();
        CB_GMTechMileStonesTimeTriggerUpdate.TimeWrap testTimeWrap = new CB_GMTechMileStonesTimeTriggerUpdate.TimeWrap();
        
        //testList.clear();
        //For TestCase-1 Start//
        testCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,03,10,01,01);
        testCase.Priority = 'Same Day';
        testCase.Escalation_Reason__c = 'VIP Account';
        update testCase;
        testCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,04,10,01,01);
        update testCase;
        testCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,05,10,01,01);
        update testCase;
        testCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,06,10,01,01);
        update testCase;
        testCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,07,10,01,01);
        update testCase;
        testCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        testCase.SlaStartDate = DateTime.newInstance(2015,03,08,10,01,01);
        update testCase;
        testCalculator.calculateMilestoneTriggerTime(testCase.Id, sameDayMT.Id);
        
        
        //For TestCase-1 End//
        Test.stopTest();
    }

}