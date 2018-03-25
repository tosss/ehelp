//Author: anirudh.singh@cdk.com
//Created Date: 2015-11-24
//Description: This class will contain generic methods to be used in Batch Classes.
//2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
@isTest
public class ALL_UtilitiesBatch_Test
{
    @TestSetup
    private static void setupData()
    {
        List<Job_Settings__c> jobSettingsList=new List<Job_Settings__c>();
        
        Job_Settings__c batchSettingRef1=new Job_Settings__c();
        batchSettingRef1.Name='Record 1';
        batchSettingRef1.Class_Name__c='SyncAccountNWebIDJob';
        //2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
        batchSettingRef1.Finish_Emails__c='anirudh.singh@cdk.com';
        jobSettingsList.add(batchSettingRef1);
        
        Job_Settings__c batchSettingRef2=new Job_Settings__c();
        batchSettingRef2.Name='Record 2';
        batchSettingRef2.Class_Name__c='DS_Account_LastActivity';
        //2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
        batchSettingRef2.Finish_Emails__c='anirudh.singh@cdk.com';
        jobSettingsList.add(batchSettingRef2);
        
        Job_Settings__c batchSettingRef3=new Job_Settings__c();
        batchSettingRef3.Name='Record 3';
        batchSettingRef3.Class_Name__c='CB_UpdateExistingWebIdsToEntilmnts_Batch';
        //2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
        batchSettingRef3.Finish_Emails__c='anirudh.singh@cdk.com';
        jobSettingsList.add(batchSettingRef3);
        
        insert jobSettingsList;
    }
    
    private static testMethod void testFinishNegativeOne()
    {
        test.startTest();
        ALL_UtilitiesBatch.Logger log=new ALL_UtilitiesBatch.Logger();
        ALL_UtilitiesBatch.finish('', log);
        test.stopTest();
    }
    
    private static testMethod void testFinishNegativeTwo()
    {
        test.startTest();
        ALL_UtilitiesBatch.Logger log=new ALL_UtilitiesBatch.Logger();
        ALL_UtilitiesBatch.finish('abc', log);
        test.stopTest();
    }
    
    private static testMethod void testFinishNegativeThree()
    {
        test.startTest();
        ALL_UtilitiesBatch.Logger log=new ALL_UtilitiesBatch.Logger();
        ALL_UtilitiesBatch.finish('SyncAccountNWebIDJob', log);
        test.stopTest();
    }
    
    private static testMethod void testFinishPositiveOne()
    {
        test.startTest();
        SyncAccountNWebIDJob batch=new SyncAccountNWebIDJob();
        Database.executeBatch(batch, 1);
        test.stopTest();
    }
    
    private static testMethod void testFinishPositiveTwo()
    {
        test.startTest();
        DS_Account_LastActivity batch=new DS_Account_LastActivity();
        Database.executeBatch(batch, 1);
        
        List<Batch_Failure__c> batchFailureList=new List<Batch_Failure__c>();
        
        Batch_Failure__c batchRef1=new Batch_Failure__c();
        batchRef1.Source__c='DS_Account_LastActivity';
        batchRef1.Error_Message__c='error 1';
        batchFailureList.add(batchRef1);
        
        Batch_Failure__c batchRef2=new Batch_Failure__c();
        batchRef2.Source__c='DS_Account_LastActivity';
        batchRef2.Error_Message__c='error 2';
        batchFailureList.add(batchRef2);
        
        insert batchFailureList;
        
        ALL_UtilitiesBatch.Logger log=new ALL_UtilitiesBatch.Logger();
        log.useLastRunConditions=false;
        log.title='Last Activity Batch Job Summary';
        log.description='Logged Last Activities (Events and Tasks)';
        log.message='';
        ALL_UtilitiesBatch.finish('DS_Account_LastActivity', log);
        test.stopTest();
    }
    
    private static testMethod void testFinishPositiveThree()
    {
        test.startTest();
        CB_UpdateExistingWebIdsToEntilmnts_Batch batch=new CB_UpdateExistingWebIdsToEntilmnts_Batch();
        Database.executeBatch(batch, 1);
        test.stopTest();
    }
}