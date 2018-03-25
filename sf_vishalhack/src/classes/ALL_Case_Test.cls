// 2016-07-28 ragashalini.koka@cdk.com - RQ-07474 Created this class
// 2017-03-13 lalitha.adduru@cdk.com - RQ-08446 - modified this class to test updateCaseTerminationEmail in caseTriggers
@isTest
public class ALL_Case_Test {

    @testSetup static void setupTestData() {
        List<Trigger_Toggle__c> triggerToggleList = getTriggerToggleRecords();
      
       insert triggerToggleList;
        
       Trigger_Toggle_Profile__c caseProfileSetting = new Trigger_Toggle_Profile__c(Name='Integration_CB_MileStoneDatesOnCase', Profile_Id__c = UserInfo.getProfileId(),
																					Code_reference__c = 'CB_MileStoneDatesOnCase_Handler', On__c = false, sObject__c = 'Case');
       insert caseProfileSetting;
        
        Account acc = DS_TestObjects.NewAccount_Inserted();
        
        WebId__c webId = new WebId__c();
        webId.Name = 'Test WebId';
        webId.Account__c = acc.Id;
        insert webId;
        
        Contact testContact = DS_TestObjects.NewContact();
        testContact.FirstName = 'TestFirstNameOne';
        testContact.LastName = 'TestLastNameOne';
        testContact.Email = UserInfo.getUserEmail();
        testContact.AccountId = DS_TestObjects.NewAccount_Inserted().Id;
        ALL_SharedContact_Helper.insertContact(testContact, 'Test Role', null, null);
                
        Contact con = DS_TestObjects.NewContact();
        Con.FirstName = 'TestFirstNameTwo';
        Con.LastName = 'TestLastNameTwo';
        con.HR_Business_Partner__c = testContact.Id;
        con.AccountId = acc.Id;
        con.RecordType=[SELECT Id FROM RecordType WHERE Name='Customer Contact' and SobjectType='Contact'][0];
        ALL_SharedContact_Helper.insertContact(con, 'Test Role', null, null);
        
        List<Case> casesToInsert = new List<Case>();
        Case newCaseOne = new Case();
        newCaseOne.AccountId = acc.Id;
        newCaseOne.WebID__c = webId.Id;
        newCaseOne.ContactId = con.Id;
        newCaseOne.Subject = 'Test Case';
        newCaseOne.Origin = 'mail';
        newCaseOne.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Termination');
        casesToInsert.add(newCaseOne);
        
        Case newCaseTwo = new Case();
        newCaseTwo.AccountId = acc.Id;
        newCaseTwo.WebID__c = webId.Id;
        newCaseTwo.ContactId = con.Id;
        newCaseTwo.Subject = 'Test Case Two';
        newCaseTwo.Origin = 'mail';
        casesToInsert.add(newCaseTwo);
        
        insert casesToInsert;
               
    }
    
    static testmethod void validateToggleController() 
    {
        Case updateCase = [SELECT Id FROM Case where Subject='Test Case Two' LIMIT 1];
        updateCase.Units__c = 2;
        test.startTest();
        update updateCase;
        Case updatedCase = [SELECT Id, Units__c FROM Case WHERE Id = :updateCase.Id];
        System.assertEquals(2, updatedCase.Units__c);
        test.stopTest();
    }
    
    static testmethod void validateProfileFilter() {
        List<Case> caseList = [SELECT Id FROM Case ];
        ALL_TriggerToggle_Handler.ProfileFilter(caseList, 'Case');
    }
    
    static List<Trigger_Toggle__c> getTriggerToggleRecords() {
        List<Trigger_Toggle__c> triggerToggleList = new List<Trigger_Toggle__c>();
        
         // by lalitha
        triggerToggleList.add(new Trigger_Toggle__c(Name='ALL_Case_updateCaseTerminationEmail', sObject__c = 'Case',
                Code_Reference__c = 'UpdateCaseTerminationEmail', On__c = true, RecordType_Name__c = 'Termination'
        ));
        //by lalitha
        triggerToggleList.add(new Trigger_Toggle__c(Name='ALL_Case updateCaseTerminationEmail', sObject__c = 'Case',
                Code_Reference__c = 'UpdateCaseTerminationEmail', On__c = false
        ));
        
        triggerToggleList.add(new Trigger_Toggle__c(Name='ALL CB_UpdateContactAccount', sObject__c = 'Case',
                Code_Reference__c = 'CB_UpdateContactAccount', On__c = true
        ));
        triggerToggleList.add(new Trigger_Toggle__c(Name='ALL CB_MileStoneDatesOnCase_Handler', sObject__c = 'Case',
                Code_Reference__c = 'CB_MileStoneDatesOnCase_Handler', On__c = true
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='Tier 1 CB_MileStoneDatesOnCase', sObject__c = 'Case',
                Code_Reference__c = 'CB_MileStoneDatesOnCase_Handler', On__c = false, RecordType_Name__c = 'Tier 1'
        ));
       
        triggerToggleList.add(new Trigger_Toggle__c(Name='HR caseTriggers', sObject__c = 'Case',
                Code_Reference__c = 'caseTriggers', On__c = false, RecordType_Name__c = 'HR'
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='ALL caseTriggers', sObject__c = 'Case',
                Code_Reference__c = 'caseTriggers', On__c = true
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='ALL DSCB_CaseReferenceFields', sObject__c = 'Case',
                Code_Reference__c = 'DSCB_CaseReferenceFields', On__c = true
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='Traver DSCB_CaseReferenceFields', sObject__c = 'Case',
                Code_Reference__c = 'DSCB_CaseReferenceFields', On__c = false, RecordType_Name__c = 'Traver - Case'
        ));
        triggerToggleList.add(new Trigger_Toggle__c(Name='ALL DSCB_CaseUserManager', sObject__c = 'Case',
                Code_Reference__c = 'DSCB_CaseUserManager', On__c = true
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='Traver DSCB_CaseUserManager', sObject__c = 'Case',
                Code_Reference__c = 'DSCB_CaseUserManager', On__c = false, RecordType_Name__c = 'Traver - Case'
        ));
        triggerToggleList.add(new Trigger_Toggle__c(Name='HR DS_CaseDefaultAccount', sObject__c = 'Case',
                Code_Reference__c = 'DS_CaseDefaultAccount', On__c = false, RecordType_Name__c = 'HR'
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='ALL DS_CaseDefaultAccount', sObject__c = 'Case',
                Code_Reference__c = 'DS_CaseDefaultAccount', On__c = true
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='AA_DSCB_CaseConcatenate_Handler', sObject__c = 'Case',
                Code_Reference__c = 'DSCB_CaseConcatenate_Handler', On__c = true, RecordType_Name__c = 'Onboarding - AA'
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='ALL_DSCB_CaseConcatenate_Handler', sObject__c = 'Case',
                Code_Reference__c = 'DSCB_CaseConcatenate_Handler', On__c = false
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='ALL DSCB_UpdatesThroughCaseObject', sObject__c = 'Case',
                Code_Reference__c = 'DSCB_UpdatesThroughCaseObject', On__c = false
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='Tier 1 DSCB_UpdatesThroughCaseObject', sObject__c = 'Case',
                Code_Reference__c = 'DSCB_UpdatesThroughCaseObject', On__c = true, RecordType_Name__c = 'Tier 1'
        ));
          triggerToggleList.add(new Trigger_Toggle__c(Name='ALL DSCB_CaseAssignment', sObject__c = 'Case',
                Code_Reference__c = 'DSCB_CaseAssignment', On__c = true
        ));
          triggerToggleList.add(new Trigger_Toggle__c(Name='SEO DSCB_CaseAssignment', sObject__c = 'Case',
                Code_Reference__c = 'DSCB_CaseAssignment', On__c = false, RecordType_Name__c = 'Inquiry - SEO'
        ));
          triggerToggleList.add(new Trigger_Toggle__c(Name='ALL CB_EntitlementsToCaseAssignment', sObject__c = 'Case',
                Code_Reference__c = 'CB_EntitlementsToCaseAssignment_Handler', On__c = true
        ));
          triggerToggleList.add(new Trigger_Toggle__c(Name='Tier 2 -ETS CB_EntToCaseAssignment', sObject__c = 'Case',
                Code_Reference__c = 'CB_EntitlementsToCaseAssignment_Handler', On__c = false, RecordType_Name__c = 'Tier 2 - ETS'
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='Inquiry-CreativeCB_CrtiveCseTallyUpdte', sObject__c = 'Case',
                Code_Reference__c = 'CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler', On__c = true
        ));
         triggerToggleList.add(new Trigger_Toggle__c(Name='ALL CB_CrtiveCseTallyUpdte', sObject__c = 'Case',
                Code_Reference__c = 'CB_CrtiveCseTallyUpdteWbIdAccPlan_Hndler', On__c = false, RecordType_Name__c = 'Inquiry - Creative'
        ));
        
        return triggerToggleList;
    }
    
}