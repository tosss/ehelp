@isTest
public with sharing class ISVC_Deactivation_Test {
	
    public static testmethod void testTermCaseCreation() 
    {
    		ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.country('United States').save();
        Account employeeAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAccountBuilder.getRecord().Id];
        
        ISVC_PersonAccount_Builder mgrAccountBuilder = new ISVC_PersonAccount_Builder();
        mgrAccountBuilder.country('United States').userId('companycommunityuser1').fedId('COMPANYCOMMUNITYUSER1').save();
        Account mgrAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :mgrAccountBuilder.getRecord().Id];
    	
        Test.startTest();
        Deactivation__c d = new Deactivation__c(Employee__c = employeeAccount.Id, Event_Date__c = Date.today());
        insert d;
        Test.stopTest();
        
        // Make sure we do not have any integration errors
        for (Integration_Error__c e : [SELECT Id, Error__c FROM Integration_Error__c]) {
        		System.assert(false);
        }
        
        for (Case c : [SELECT Id, Subject, Description, Sub_Case_Type__c, Impact__c, Severity__c, Origin, RecordTypeId, RecordType.Name, Deactivation__c, Effective_Date__c FROM Case WHERE Subject like 'Termination%']) {
        		System.assertEquals(c.Deactivation__c, d.Id);
        		System.assertEquals(c.RecordTypeId, ALL_RecordTypes_Utility.getTerminationRecordTypeId());
        		System.assertEquals(c.Effective_Date__c, d.Event_Date__c);
        		return;
        }
        
        // If it reaches here, that means the process didn't create a termination case
        System.assert(false);
    }
}