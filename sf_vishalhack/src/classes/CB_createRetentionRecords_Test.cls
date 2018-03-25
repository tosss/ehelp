@isTest
public class CB_createRetentionRecords_Test 
{
    @testSetUp static void setUpData()
    {
        string recordTypeID = (string)ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Cancellation');
        
        list<sObject> settingsObjects = new list<sObject>{ 
                new ALL_Query_Conditions__c(Name='001', sObject__c='CB_Retention__c', Key__c='Name', Operator__c='=', Value__c='Cancellation Survey', Identifier__c='001', 
                                        Method_Name__c='getRecordTypeId()', Class_Name__c='DynamicSOQL_Helper', Describe_Call__c=true),
                        
                new ALL_Field_Value_Assignment_Settings__c(Name='001', 	Receiving_sObject__c='CB_Retention__c', Receiving_Field_Name__c='Account__c', Lending_sObject__c='Case', 
                                                           Lending_Field_Name__c='AccountId', Identifier__c='001'),
                    
                new ALL_Field_Value_Assignment_Settings__c(Name='002', 	Receiving_sObject__c='CB_Retention__c', Receiving_Field_Name__c='WebId__c', Identifier__c='002', Lending_sObject__c='Case', 
                                                           Lending_Field_Name__c='WebId__c'), 
                    
                new ALL_Field_Value_Assignment_Settings__c(Name='003', 	Receiving_sObject__c='CB_Retention__c', Receiving_Field_Name__c='Case__c', Lending_sObject__c='Case', 
                                                           Lending_Field_Name__c='ID', Identifier__c='003'), 
                    
                new ALL_Field_Value_Assignment_Settings__c(Name='004', 	Receiving_sObject__c='CB_Retention__c', Receiving_Field_Name__c='Contact__c', Lending_sObject__c='Case',
                                                           Lending_Field_Name__c='ContactId', Identifier__c='004'),
                    
                /*new ALL_Field_Value_Assignment_Settings__c(Name='005', 	Receiving_sObject__c='CB_Retention__c', Receiving_Field_Name__c='Multiple_Webid_Cancellation__c', Lending_sObject__c='Case',
                                                           Lending_Field_Name__c='Multi_Webid_Cancellation__c', Identifier__c='005'),*/
                    
                new ALL_Field_Value_Assignment_Settings__c(Name='006', 	Receiving_sObject__c='CB_Retention__c', Receiving_Field_Name__c='Products_Cancelled__c', Lending_sObject__c='Case',
                                                           Lending_Field_Name__c='Products_to_Cancel__c', Identifier__c='006'),
                    
                new ALL_Field_Value_Assignment_Settings__c(Name='007', 	Receiving_sObject__c='CB_Retention__c', Receiving_Field_Name__c='RecordTypeId', Query_Conditions_Identifier__c='001', 
                                                       Identifier__c='007'),
                    
                new Field_Value_Conditions__c(Name='001', Identifier__c='001', Contains__c=true, Field_Name__c='Products_to_Cancel__c', Field_Value__c='Website',  
                                              sObject__c='Case'),
                new Field_Value_Conditions__c(Name='002', Identifier__c='002', Contains__c=true, Field_Name__c='Products_to_Cancel__c', Field_Value__c='Audience Management Package',  
                                              sObject__c='Case'),
                new Field_Value_Conditions__c(Name='003', Identifier__c='003', EqualsTo__c=true, Field_Name__c='RecordTypeID', Field_Value__c=recordTypeID, sObject__c='Case'),
                new Field_Value_Conditions__c(Name='004', Identifier__c='004', Not_EqualsTo__c=true, Field_Name__c='Assigned_To__c', Field_Value__c=null, sObject__c='Case'),
                new Field_Value_Conditions__c(Name='005', Identifier__c='005', Field_Name__c='Type', Field_Value__c='Cancellation', EqualsTo__c=true, 
                                              sObject__c='Case'),
               
                new ALL_Decision_Box_Settings__c(
                    Name='001', Assignment_sObject__c='CB_Retention__c', Condition_Check__c='(001 OR 002) AND 003 AND 004 AND 005', 
                    ConditionCheck_sObject__c='Case',Value_Assignment__c='001 AND 002 AND 003 AND 004 AND 005 AND 006 AND 007'),
                new GlobalSettings__c(Retention_Switch__c=true),
                new Trigger_Toggle__c(Name='001', Code_Reference__c='CB_createRetentionRecords', On__c=false, RecordType_Name__c=null, sObject__c='Case'),
                new Trigger_Toggle__c(Name='002', Code_Reference__c='CB_createRetentionRecords', On__c=true, RecordType_Name__c='Cancellation', sObject__c='Case')                
                };
                    
                insert settingsObjects;
    }
    
    static testMethod void unitTest()
    {
        string recordTypeID = (string)ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Cancellation');
        WebID__c webID = DS_TestObjects.NewWebID_Inserted();
        
        Case newCase = new Case();
        newCase.recordTypeID = recordTypeID;
        newCase.Type = 'Cancellation';
        newCase.Assigned_To__c = userInfo.getUserId();
        newCase.Products_to_Cancel__c = 'WebSite';
        
        newCase.WebID__c = WebID.ID;
        Account acc = (Account)WebID.getSobject('Account__r');
        
        newCase.AccountId = acc.ID;
        
        Insert newCase;
    }
}