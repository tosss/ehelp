@isTest
public class DSCB_CaseConcatenate_Test 
{
    @testSetUp static void setUpData()
    {
        list<sObject> settingsObjects = new list<sObject>{
            new Trigger_Toggle__c(Name='001', Code_Reference__c='DSCB_CaseConcatenate_Handler', On__c=false, RecordType_Name__c=null, sObject__c='Case'),
            new Trigger_Toggle__c(Name='002', Code_Reference__c='DSCB_CaseConcatenate_Handler', On__c=true, RecordType_Name__c='Onboarding - OMS', sObject__c='Case'),
            new ALL_Template_Values__c(Name='001', Field_Name__c='Status__c', Identifier__c='001', Label__c='Status'),
            new ALL_Template_Values__c(Name='002', Field_Name__c='Account__r.Name', Identifier__c='002', Label__c='Customer Name'),
            new ALL_Template_Values__c(Name='003', Identifier__c='003', Label__c='Link to Launch'),
            new ALL_Template_Values__c(Name='004', Identifier__c='004', Label__c='next line'),
            new ALL_Template_Decisionbox__c(Name='001', Condition_Check__c='001 AND 002', Value_Assignment__c='001 AND 002 AND 003 AND 004'),
            new Field_Value_Conditions__c(Name='001', Identifier__c='001', Field_Name__c='Status__c', Field_Value__c='Friday', EqualsTo__c=true),
            new Field_Value_Conditions__c(Name='002', Identifier__c='002', Field_Name__c='Brand__c', Field_Value__c='Subaru', EqualsTo__c=true),
            new GlobalSettings__c(Launch_Onboarding_Switch__c=true)   
            
        };
        insert settingsObjects;            
    }
    
    static testMethod void executeTest()
    {
        Group grp = [select Id, Name From Group Where Name='OMS Queue'];
        ID recordTypeID = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Onboarding - OMS'); 
        Launch__c newLaunch = DS_TestObjects.NewLaunch();
        newLaunch.Status__c = 'Friday';
        newLaunch.Brand__c = 'Subaru';
        
        insert newLaunch;
        
        Case newCase = DS_TestObjects.NewCase();
        newCase.recordTypeID = recordTypeID;
        newCase.OwnerId = grp.ID;
        newCase.Launch__c = newLaunch.ID;
        
        insert newCase;
         
    /*    Case insertedCase = [Select Id, CaseNumber, Description From Case Where ID = :newCase.ID limit 1];
        string descriptionString = insertedCase.Description;
        boolean bool = descriptionString.contains('Friday');
        system.assertEquals(bool, true);
*/
    }

}