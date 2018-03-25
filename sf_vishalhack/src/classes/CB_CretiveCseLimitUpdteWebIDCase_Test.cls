/* 
Test Class for CB_CretiveCseLimitUpdteWebIDCase_Handler
*/
@isTest
public class CB_CretiveCseLimitUpdteWebIDCase_Test {

    static testMethod void creativeCaseLimitUpdateTest() 
    {
        //User u = DS_TestObjects.NewUser_Inserted();
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
        
        WebID__c testId2 = new WebID__c();
        testId2.Account__c = acc.Id;
        testId2.Name = 'kia-test';
        insert testId2;
        
        String caseRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Inquiry - Creative');
        
        Case testCase = new Case();
        testCase.RecordTypeId = caseRecordTypeId;
        testCase.AccountId = acc.Id;
        testCase.ContactId = testContact.Id;
        testCase.Creative_Case_Limit__c = 0;
        testCase.WebID__c= testId.Id;
        testCase.Status = 'Open';
        insert testCase;
        
        Account_Plan__c testPlan = new Account_Plan__c();
        //testPlan.RecordType.Name= 'DAA Account Plan';
        testPlan.Creative_Case_Limit__c = 10;
        testPlan.WebID__c = testId.Id;
        testPlan.Account__c = acc.Id;
        insert testPlan;
    
        Map<Id,decimal> testLimitMap = new Map<Id,decimal>();
        testLimitMap.put(testPlan.WebID__c, testPlan.Creative_Case_Limit__c);
        
        CB_CretiveCseLimitUpdteWebIDCase_Handler.creativeCaseLimitUpdate(testLimitMap);
        testLimitMap.clear();
        
        testPlan.Creative_Case_Limit__c = 12;
        update testPlan;
        testLimitMap.put(testPlan.WebID__c, testPlan.Creative_Case_Limit__c);
        CB_CretiveCseLimitUpdteWebIDCase_Handler.creativeCaseLimitUpdate(testLimitMap);
        
        Account_Plan__c testPlan2 = new Account_Plan__c();
        testPlan2.WebID__c = testId2.Id;
        testPlan2.Account__c = acc.Id;
        insert testPlan2;
        testLimitMap.clear();
        testLimitMap.put(testPlan2.WebID__c, testPlan2.Creative_Case_Limit__c);
        CB_CretiveCseLimitUpdteWebIDCase_Handler.creativeCaseLimitUpdate(testLimitMap);
    }
}