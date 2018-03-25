@isTest
private class CB_CrtiveCseTallyUpdteWbIdAccPlan_Test {
    
    static testMethod void caseTallyUpdateTest() 
    {
        Account acc = DS_TestObjects.NewAccount_Inserted();
        
        Contact testContact = new Contact();
        testContact.FirstName = 'First';
        testContact.LastName = 'Last';
        testContact.AccountId = acc.Id;
        insert testContact;
        
        // 2016-07-27 matt.keefe@cdk.com - added contact relationship for shared contacts (Case Lookup requires)
        Contact_Relationship__c cr1 = new Contact_Relationship__c(Contact__c = testContact.Id, Account__c = acc.Id);
        cr1.Role__c = 'Accountant';
        insert cr1;
        
        WebID__c testId = new WebID__c();
        testId.Account__c = acc.Id;
        testId.Name = 'gmps-test';
        insert testId;
        
        String caseRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Inquiry - Creative');
        
        list<Case> caselist = new list<Case>();
        Case testCase = new Case();
        testCase.RecordTypeId = caseRecordTypeId;
        testCase.AccountId = acc.Id;
        testCase.ContactId = testContact.Id;
        testCase.WebID__c= testId.Id;
        testCase.Status = 'Open';
        //2016-12-23- anirudh.singh@cdk.com- Changed Product_Category__c from Assets to Online Marketing
        //and Problem_Code__c from Background to LMA. As the earlier values were not valid for Inquiry - Creative case record type.
        testCase.Product_Category__c = 'Online Marketing';
        testCase.Problem_Code__c = 'LMA';
        caselist.add(testCase);
        
        Case testCase2 = new Case();
        testCase2.RecordTypeId = caseRecordTypeId;
        testCase2.AccountId = acc.Id;
        testCase2.ContactId = testContact.Id;
        testCase2.WebID__c= testId.Id;
        //2016-12-23- anirudh.singh@cdk.com- Commented the below line.
        //testCase2.Problem_Code__c = 'Power Brand';
        testCase2.Status = 'Open';
        //2016-12-23- anirudh.singh@cdk.com- Changed Product_Category__c from Assets to Online Marketing
        //and Problem_Code__c from Background to LMA. As the earlier values were not valid for Inquiry - Creative case record type.
        testCase.Product_Category__c = 'Online Marketing';
        testCase.Problem_Code__c = 'LMA';
        caselist.add(testCase2);
        
        Case testCase3 = new Case();
        testCase3.RecordTypeId = caseRecordTypeId;
        testCase3.AccountId = acc.Id;
        testCase3.ContactId = testContact.Id;
        testCase3.WebID__c= testId.Id;
        //2016-12-23- anirudh.singh@cdk.com- Commented the below line.
        //testCase3.Problem_Code__c = 'Power Brand';
        testCase3.Status = 'Fixes';
        //2016-12-23- anirudh.singh@cdk.com- Changed Product_Category__c from Assets to Online Marketing
        //and Problem_Code__c from Background to LMA. As the earlier values were not valid for Inquiry - Creative case record type.
        testCase.Product_Category__c = 'Online Marketing';
        testCase.Problem_Code__c = 'LMA';
        caselist.add(testCase3);
        
        insert caselist;
        
        String aPlanRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c','DAA Account Plan');
        Account_Plan__c testPlan = new Account_Plan__c();
        testPlan.RecordTypeId = aPlanRecordTypeId;
        testPlan.WebID__c = testId.Id;
        testPlan.Account__c = acc.Id;
        insert testPlan;
        
        set<Id> caseIds = new set<Id>();
        caseIds.add(testCase.ID);
        caseIds.add(testCase2.ID);
        caseIds.add(testCase3.ID);
        
        CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler.creativeCaseTallyUpdate(caseIds);
        
        //system.assertEquals(testCase2.Creative_Case_Tally__c,1);
        
    }
}