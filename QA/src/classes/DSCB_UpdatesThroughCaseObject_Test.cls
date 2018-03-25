//2015-11-27 : vishal.bandari@cdk.com - RQ-05289:changed ContactUpdateTest method to add contact record type
@isTest
public class DSCB_UpdatesThroughCaseObject_Test 
{
    Public static testMethod void ContactUpdateTest()
    {
        list<trigger_Toggle__c> ToggleList = new List<trigger_Toggle__c>();
        ToggleList.add(new Trigger_Toggle__c(Name='ALL DSCB_UpdatesThroughCaseObject', sObject__c='Case', 
                                             Code_Reference__c='DSCB_UpdatesThroughCaseObject'));
        ToggleList.add(new Trigger_Toggle__c(Name='Tier 1 DSCB_UpdatesThroughCaseObject', on__c=true, sObject__c='Case', 
                                             Code_Reference__c='DSCB_UpdatesThroughCaseObject', RecordType_Name__c='Tier 1'));
        insert ToggleList;
        
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact();
        c.AccountId = a.Id;
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        
        ID CaseTier1RecordType = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');
        Case ca = DS_TestObjects.NewCase();
        ca.RecordTypeId = CaseTier1RecordType;
        ca.AccountId = a.Id;
        ca.ContactId = c.Id;
        ca.ResponseDate__c = DateTime.now();
        insert ca;       
        
    }
}