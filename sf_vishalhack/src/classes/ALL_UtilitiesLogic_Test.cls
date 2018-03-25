//2017-05-02 - siva.pragada@cdk.com - added spacing in composite expression for identifier change to alphanumeric. 
@isTest
public class ALL_UtilitiesLogic_Test 
{  
    @testSetUp static void setUpData()
    {  
        string recordTypeID = (string)ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Launch__c', 'A La Carte Launch');
        string currentOrg = ALL_UtilitiesMiscellaneous.GetCurrentInstanceName();
        boolean isThisProductionOrg = ALL_UtilitiesMiscellaneous.isProductionOrg();
        
        currentOrg = '.' + currentOrg;
        
        if(isThisProductionOrg)
        {
            currentOrg = '';
        }
        
        list<sObject> settingsObjects = new list<sObject>{
            
            new ALL_Query_Conditions__c(Name='001', sObject__c='Group', Key__c='Name', Operator__c='=', Value__c='OMS Queue', Identifier__c='001'),
            new ALL_Query_Conditions__c(Name='002', sObject__c='Case', Key__c='Name', Operator__c='=', Value__c='Onboarding - OMS', 
                                            Class_Name__c='DynamicSOQL_Helper', Method_Name__c='getRecordTypeId()', Describe_Call__c=true, Identifier__c='002'),
            new ALL_Query_Conditions__c(Name='003', sObject__c='User', Key__c='	UserName', Operator__c='=', 
                                            Class_Name__c='DynamicSOQL_Helper', Method_Name__c='getAdminUser()', Identifier__c='003'),         
            new ALL_Field_Value_Assignment_Settings__c(Name='001', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='OwnerId', Query_Field_s__c='ID', 
                                                           Query_sObject__c='Group', Query_Conditions_Identifier__c='001', Identifier__c='001'),
            new ALL_Field_Value_Assignment_Settings__c(Name='002', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='RecordTypeId', Query_Conditions_Identifier__c='002', 
                                                           Identifier__c='002'), 
            new ALL_Field_Value_Assignment_Settings__c(Name='003', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='Requested_By__c', Query_Field_s__c='ID', 
                                                           Query_sObject__c='User', Query_Conditions_Identifier__c='003',Identifier__c='003'), 
            new ALL_Field_Value_Assignment_Settings__c(Name='004', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='AccountId', Lending_sObject__c='Launch__c',
                                                           Lending_Field_Name__c='Account__c', Identifier__c='004'),
            new ALL_Field_Value_Assignment_Settings__c(Name='005', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='WebID__c', Lending_sObject__c='Launch__c',
                                                           Lending_Field_Name__c='WebID__c', Identifier__c='005'),
            new ALL_Field_Value_Assignment_Settings__c(Name='006', 	Receiving_sObject__c='Case', Receiving_Field_Name__c='Launch__c', Lending_sObject__c='Launch__c',
                                                           Lending_Field_Name__c='ID', Identifier__c='006'),
            new Field_Value_Conditions__c(Name='001', Identifier__c='001', Contains__c=true, Field_Name__c='Product_Type__c', Field_Value__c='Pre-Roll Video',  
                                              sObject__c='Launch__c'),
            new Field_Value_Conditions__c(Name='002', Identifier__c='002', EqualsTo__c=true, Field_Name__c='RecordTypeID', Field_Value__c=recordTypeID, sObject__c='Launch__c'),
            new Field_Value_Conditions__c(Name='003', Identifier__c='003', EqualsTo__c=true, Field_Name__c='WebID__r.Status__c', Field_Value__c='Active', sObject__c='Launch__c'),
            new Field_Value_Conditions__c(Name='004', Identifier__c='004', Field_Name__c='WebID__r.Status__c', Field_Value__c='InActive', Not_EqualsTo__c=true, 
                                              sObject__c='Launch__c'),
            new Field_Value_Conditions__c(Name='005', Identifier__c='005', Field_Name__c='Send_Onboarding__c', isBoolean__c=true, isTrue__c=false, sObject__c='Launch__c'),
            new ALL_Decision_Box_Settings__c(
                    Name='001', Assignment_sObject__c='Case', Condition_Check__c='( ( 001 AND 004 ) OR 003 ) AND 002 AND 005', 
                    ConditionCheck_sObject__c='Launch__c',Value_Assignment__c='001 AND 002 AND 003 AND 004 AND 005 AND 006'),
            new GlobalSettings__c(Admin_Integration_Username__c='integration_user@adp.com'+ currentOrg),
            new Trigger_Toggle__c(Name='001', Code_Reference__c='DSCB_CaseConcatenate_Handler', On__c=false, RecordType_Name__c=null, sObject__c='Case'),
            new Trigger_Toggle__c(Name='002', Code_Reference__c='DSCB_CaseConcatenate_Handler', On__c=true, RecordType_Name__c='Onboarding - OMS', sObject__c='Case')
       };
                    
       insert settingsObjects;
        
    }
    
    static testMethod void executeTest()
    {
        string recordTypeID = (string)ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Launch__c', 'A La Carte Launch');
        Launch__c newLaunch = DS_TestObjects.NewLaunch();
        Account acc = (Account)newLaunch.getsObject('Account__r');
        WebID__c webID = DS_TestObjects.NewWebID();
        webID.Account__c = acc.ID;
        contact con  = DS_TestObjects.NewContact();
        con.AccountId = acc.ID;
        insert new list<sObject>{ webID, con };
        
        newLaunch.Product_Type__c = 'Pre-Roll Video';
        newLaunch.RecordTypeId = recordTypeID;
        newLaunch.Send_Onboarding__c = false;
        newLaunch.WebID__c = webID.ID;
        
        ALL_Decision_Box_Settings__c adb = ALL_Decision_Box_Settings__c.getInstance('001');
        
        boolean bool = ALL_UtilitiesLogic.getcompositeExpressionsEvaluatedValue(adb.Condition_Check__c, newLaunch);
        
        system.assertEquals(bool, true);
        
        sObject newObject = ALL_UtilitiesLogic.createRecords(adb.Value_Assignment__c, adb.Assignment_sObject__c, newLaunch);
        
        Case newCase = (Case)newObject;
        ID caseRecordTypeID = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Onboarding - OMS');
        
        system.assertEquals(newCase.RecordTypeId, caseRecordTypeID);
    }

}