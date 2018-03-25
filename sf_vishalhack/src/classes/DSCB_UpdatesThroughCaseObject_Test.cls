//2015-11-27 : vishal.bandari@cdk.com - RQ-05289:changed ContactUpdateTest method to add contact record type
@isTest
public class DSCB_UpdatesThroughCaseObject_Test 
{
    Public static testMethod void ContactUpdateTest()
    {
        list<trigger_Toggle__c> ToggleList = new List<trigger_Toggle__c>();
        ToggleList.add(
            new Trigger_Toggle__c(
                Name='ALL DSCB_UpdatesThroughCaseObject', sObject__c='Case', on__c=false, RecordType_Name__c=null,
                Code_Reference__c='DSCB_UpdatesThroughCaseObject'
            )
        );
        ToggleList.add(
            new Trigger_Toggle__c(
                Name='Tier 1 DSCB_UpdatesThroughCaseObject', on__c=true, sObject__c='Case', 
                Code_Reference__c='DSCB_UpdatesThroughCaseObject', RecordType_Name__c='Tier 1'
            )
        );
        insert ToggleList;
        
        Account a = DS_TestObjects.NewAccount_Inserted();
        Contact c = DS_TestObjects.NewContact();
        c.AccountId = a.Id;
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        
        // 2016-07-27 matt.keefe@cdk.com - added contact relationship for shared contacts (Case Lookup requires)
        Contact_Relationship__c cr1 = new Contact_Relationship__c(Contact__c = c.Id, Account__c = a.Id);
        cr1.Role__c = 'Accountant';
        insert cr1;
        
        Partner_Contacts__c partContact = new Partner_Contacts__c();
        partContact.Email__c = 'dfg.cva@cdkglobal.com';
        partContact.Name = 'someName';
        partContact.Partner_Organization__c = 'cdkglobal';
        partContact.Phone__c = '9796786473';
        partContact.Status__c = 'Active';
        partContact.Security_Code__c = '67gh';
        
        insert partContact;
        
        ID CaseTier1RecordType = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Tier 1');
        Case ca = DS_TestObjects.NewCase();
        ca.RecordTypeId = CaseTier1RecordType;
        ca.AccountId = a.Id;
        ca.ContactId = c.Id;
        ca.ResponseDate__c = DateTime.now();
        ca.Partner_Contact__c = partContact.ID;
        ca.CSI_Sent__c = true;
        insert ca;
        
        ca.ResponseDate__c = DateTime.now() + 5;
        update ca;
    }
}