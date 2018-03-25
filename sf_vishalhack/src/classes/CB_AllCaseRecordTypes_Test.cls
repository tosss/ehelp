//2017-04-03 - siva.pragada@cdk.com - created
@isTest
public class CB_AllCaseRecordTypes_Test 
{  
     @testSetUp Static void setUpData()
     {
         Contact_Relationship__c crs = DS_TestObjects.newContactRelationship_Inserted();
         string recordTypeID = (string)ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');
         list<sObject> settingsObjects = new list<sObject>{
            new Trigger_Toggle__c(Name='001', Code_Reference__c='CB_AllCaseRecordTypes_Handler', On__c=false, RecordType_Name__c=null, sObject__c='Case'),
            new Trigger_Toggle__c(Name='002', Code_Reference__c='CB_AllCaseRecordTypes_Handler', On__c=true, RecordType_Name__c='Service Connect', sObject__c='Case')            
         };
         insert settingsObjects;
     }
    
    static testMethod void testForChangeInPhone()
    {
        Contact_Relationship__c crs = [Select ID, Phone__c From Contact_Relationship__c Limit 1]; 
        string recordTypeID = (string)ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Service Connect');
        Case newCase = DS_TestObjects.NewCase();
        newCase.RecordTypeId = recordTypeID;
        newCase.Contact_Name_Relationship__c = crs.ID;
        
        insert newCase;
        
        crs.phone__c = '111-111-1111';
        Update crs;
    }
}