//2016-02-23- anirudh.singh@cdk.com- Modified this class for testing Batch class and the Scheduler Class.
//2016-02-23- anirudh.singh@cdk.com- Changed the API Version from 31.0 to 35.0.
//2016-02-23- anirudh.singh@cdk.com- Also, re-written the whole test class for following test class standards.
@IsTest
public class CB_WebIDAccountTeamMembers_Test
{
    @TestSetup
    private static void setupData()
    {
        CustomSettings__c customSettingsRef=new CustomSettings__c();
        customSettingsRef.Name='Test';
        customSettingsRef.WebIDTriggers_On__c=true;
        insert customSettingsRef;
        
        List<Account_Team_Sync_Settings__c> accTeamSettingsList=DS_TestObjects.getAcountTeamSyncSettings();
    }
    
    private static testMethod void batchTestOne()
    {
        test.startTest();
        CB_WebIDAccountTeamMembers_Batch batch=new CB_WebIDAccountTeamMembers_Batch();
        
        Id batchId=Database.executeBatch(batch);
        test.stopTest();
    }
    
    private static testMethod void batchTestTwo()
    {
        List<Account> accList=new List<Account>();
        for(Integer i=0; i<7; i++)
        {
            accList.add(new Account(Name='Test Account '+i));
        }
        insert accList;
        
        CB_WebIDAccountTeamMembers_Batch batch=new CB_WebIDAccountTeamMembers_Batch(accList);
        
        test.startTest();
        Id batchId=Database.executeBatch(batch);
        test.stopTest();
    }
    
    private static testMethod void schedulerTest()
    {
        Account acc=new Account();
        acc.Name='Test Account';
        insert acc;
        
    	test.startTest();
    	// Cron Expression Syntax: Seconds, Minutes, Hours, Day of month, Month, Day of week, optional Year
    	// 0 0 0 * * ? means, run every day at 12am
    	String jobId=System.schedule('TestWebIdScheduler', '0 0 0 * * ?', new CB_WebIDAccountTeamMembers_Scheduler());
        //System.abortJob(jobId);
    	test.stopTest();
    }
}