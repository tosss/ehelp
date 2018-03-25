//2016-01-13- anirudh.singh@cdk.com- Created this class as the name of the previously existing test class was not as per standards.
//Previous classes CB_CreativeCseTallyOnWebIDScheduler_Test and CB_CretiveCseTallyOnWebIdResetBatch_Test are removed.
//Also, brought the test class up to Standards.
@isTest
public class CB_CreativeCaseTallyReset_Test
{
    @TestSetup
    private static void setupData()
    {
        Account acc=DS_TestObjects.NewAccount_Inserted();
        
        Contact testContact=new Contact();
        testContact.FirstName='First';
        testContact.LastName='Last';
        testContact.AccountId=acc.Id;
        insert testContact;
        
        List<WebID__c> testWebIdList=new List<WebID__c>();
        
        for(integer i=0; i<2; i++)
        {
            WebID__c testId=new WebID__c();
            testId.Account__c=acc.Id;
            
            if(i==0)
            {
                testId.Name='gmps-test';
                testId.Creative_Case_Tally__c=5;
            }
            else
            {
                testId.Name='holden-test';
                testId.Creative_Case_Tally__c=0;
            }
            
            testId.Status__c='Active';
            testWebIdList.add(testId);
        }
        insert testWebIdList;
        
        String caseRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'Inquiry - Creative');
        
        list<Case> testCaseList=new list<Case>();
        
        for(integer j=0; j<testWebIdList.size(); j++)
        {
            for(integer k=0;k<5;k++)
            {
                Case testCase=new Case();
                testCase.RecordTypeId=caseRecordTypeId;
                testCase.AccountId=acc.Id;
                testCase.ContactId=testContact.Id;
                testCase.WebID__c=testWebIdList.get(j).Id;
                testCase.Problem_Code__c='Power Brand';
                if(j==0)
                {
                    testCase.Creative_Case_Tally__c=5; 
                }
                else
                {
                    testCase.Creative_Case_Tally__c=0;
                }
                testCase.Status='Open';
                testCaseList.add(testCase);
            }
        }
        insert testCaseList;
        
        String accountPlanRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'DAA Account Plan');
        
        list<Account_Plan__c> accPlanList=new list<Account_Plan__c>();
        
        for(integer i=0; i<testWebIdList.size(); i++)
        {
            Account_Plan__c testPlan=new Account_Plan__c();
            testPlan.WebID__c=testWebIdList.get(i).Id;
            testPlan.Account__c=acc.Id;
            if(i==0)
            {
                testPlan.Creative_Case_Tally__c=5; 
            }
            else
            {
                testPlan.Creative_Case_Tally__c=0;
            }
            accPlanList.add(testPlan);
        }
        insert accPlanList;
    }
    
    static testMethod void prepareWebIDCaseAccPlanDataTest()
    {
        Test.startTest();
        CB_CreativeCaseTallyReset_Batch executeBatchTest=new CB_CreativeCaseTallyReset_Batch();
        Database.executeBatch(executeBatchTest);
        Test.stopTest();
    }
    
    static testMethod void schedularTest() 
    {
        Test.startTest();
        CB_CreativeCaseTallyReset_Scheduler testCCTallyScheduler= new CB_CreativeCaseTallyReset_Scheduler();
        //CB_CreativeCaseTallyReset_Scheduler.schedulefunc();
        string testScheduleString = '0 0 3 1 * ?'; //Every 1st of the month at 3AM
        system.schedule('Test for CCTally Reset Schedular', testScheduleString, testCCTallyScheduler);
        
        CB_CreativeCaseTallyReset_Scheduler.schedulefunc();
        Test.stopTest();
    }
}