/*--------------------------------------------------
 * 2016-09-30   -venkata.shrivol@cdk.com     -Created
 * Test Class for : ALL_HoursOfOperation_Handler
----------------------------------------------------*/
@isTest
public class ALL_HoursOfOperation_Test 
{
    @testSetup static void prepareTestData()
    {	
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        testAccount.Name = 'Discovery app test';
        insert testAccount;
        
		Opportunity testOpp = IMP_TestFactory_Helper.buildOpportunity();
        testOpp.AccountId = testAccount.Id;
        insert testOpp;
        
        string siteRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Site');
        system.debug(siteRecordTypeId);
        
        Opportunity_Location__c siteLocation = null;
        list<Opportunity_Location__c> siteLocations = [
            SELECT Id FROM Opportunity_Location__c 
            WHERE RecordTypeId= :siteRecordTypeId 
            And Opportunity__c= :testOpp.Id 
            AND Site__c= :testAccount.Id
        ];
        
        if(siteLocations != null && !siteLocations.isEmpty()) { 
            siteLocation = siteLocations.get(0); 
        }
        else {
            siteLocation = new Opportunity_Location__c(RecordTypeId = siteRecordTypeId);
            siteLocation.Opportunity__c = testOpp.Id;
            siteLocation.Site__c = testAccount.Id;
            insert siteLocation;
        }
            
        Hours_Of_Operation__c hof = new Hours_Of_Operation__c();
        hof.Opportunity_Location__c = siteLocation.Id;
        hof.Common_End_Time__c = '05:00 PM';
        hof.Common_Start_Time__c = '08:00 AM';
        hof.Days_to_Select__c = 'Monday;Tuesday';
        hof.Department__c = 'Sales;Service';
        insert hof;
    }
    
    testMethod static void testOnInsert()
    {
    	list<Hours_Of_Operation__c> hofList = [
            select Id, Monday_Start_Time__c, Monday_End_time__c, Tuesday_Start_time__c, Tuesday_End_Time__c, Department__c,
            Common_Start_Time__c, Common_End_Time__c
            from Hours_Of_Operation__c];
        
        system.assertEquals(2, hofList.size()); 
        system.assertEquals(hofList.get(0).Monday_Start_Time__c, hofList.get(0).Common_Start_Time__c);
        system.assertEquals(hofList.get(0).Tuesday_End_Time__c, hofList.get(0).Common_End_Time__c);
        
        list<Opportunity_Location__c> siteList = [select Id from Opportunity_Location__c where RecordType.Name = 'Site'];
        Opportunity_Location__c thisSite = siteList.size() > 0 ? siteList.get(0) : new Opportunity_Location__c();
        
        Hours_Of_Operation__c hof = new Hours_Of_Operation__c();
        hof.Opportunity_Location__c = thisSite.Id;
        hof.Common_End_Time__c = '09:00 PM';
        hof.Common_Start_Time__c = '09:00 AM';
        hof.Days_to_Select__c = 'Wednesday';
        hof.Department__c = 'Sales';
       
        Database.SaveResult dsr = Database.insert(hof, false);
        if(!dsr.isSuccess())
        {
            list<Database.Error> insertionErrors = dsr.getErrors();
            if(insertionErrors !=null && insertionErrors.size() > 0)
            {
                System.assertEquals(insertionErrors[0].getStatusCode(), StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION, 'Exception occured is not a CUSTOM_VALIDATION_EXCEPTION');
                system.assert(insertionErrors[0].getMessage().contains('Oops! There is already a record for Sales deparment on this Site'),
                              'Assertion failed due to unexpected error message from the insertion of record');
            }
            else{
                system.assert(false, 'Something went wrong in testOnInsert method!');
            }
        }
        else
        {
            system.assert(false, 'Duplicate record got created in testOnInsert Method');    
        }
        /*try
        {
        insert hof; 
        }
        catch(DmlException ex)
        {
        system.assertEquals(ex.getDmlType(0), StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
        system.assert(ex.getMessage().contains('Oops! There is already a record for Sales deparment on this Site'));    
        }*/
                
    }
    
    testMethod static void testOnUpdate()
    {
        list<Hours_Of_Operation__c> hofList = [
            select Id, Monday_Start_Time__c, Monday_End_time__c, Tuesday_Start_time__c, Tuesday_End_Time__c, Department__c,
            Common_Start_Time__c, Common_End_Time__c
            from Hours_Of_Operation__c];
        
        Hours_Of_Operation__c hof = hofList.size() > 0 ? hofList.get(0) : new Hours_Of_Operation__c();
        hof.Department__c = 'Sales;Parts';
        hof.Common_Start_Time__c = '09:00 AM';
        upsert hof;
        
        Test.startTest();
        
        list<Hours_Of_Operation__c> updatedList = [
            select Id, Monday_Start_Time__c, Monday_End_time__c, Tuesday_Start_time__c, Tuesday_End_Time__c, Department__c,
            Common_Start_Time__c, Common_End_Time__c
            from Hours_Of_Operation__c];
        
        system.assertEquals(3, updatedList.size()); 
        Test.stopTest();
    }
}