//2016-08-18 - vishal.bandari@cdk.com - RQ-07433:created the class
//2017-01-18 - ragashalini.koka@cdk.com - RQ-07433 - modified code according to the changes
@IsTest
public class ALL_CMFInfo_Test 
{
	@testsetup
    public static void setupData()
    {
        List<Account> accList = new List<Account>();
        Account acc1 = DS_TestObjects.NewAccount();
        acc1.Name = 'Test Account1';
        Account acc2 = DS_TestObjects.NewAccount();
        acc2.Name = 'Test Account2';
        accList.add(acc1);
        accList.add(acc2);
        insert accList;
        
        List<CMF_Info__c> cmfInfoList = new List<CMF_Info__c>();
       
        CMF_Info__c cmfObj1 = DS_TestObjects.NewCMFInfo();
        cmfObj1.Name = 'Test CMF1';
        cmfObj1.Account__c = accList[0].Id;
        cmfObj1.SLS_Baseline_CMF_Number__c = '1234';
        cmfObj1.Ship_CMF__c = '1234';
        cmfObj1.Status__c = 'A';
        
        CMF_Info__c cmfObj2 = DS_TestObjects.NewCMFInfo();
        cmfObj2.Name = 'Test CMF2';
        cmfObj2.Account__c = accList[1].Id;
        cmfObj2.SLS_Baseline_CMF_Number__c = '12334';
        cmfObj2.Ship_CMF__c = '12334';
        cmfObj2.Status__c = 'A';
        
        CMF_Info__c cmfObj3 = DS_TestObjects.NewCMFInfo();
        cmfObj3.Name = 'Test CMF3';
        cmfObj3.Account__c = accList[1].Id;
        cmfObj3.SLS_Baseline_CMF_Number__c = '12345';
        cmfObj3.Ship_CMF__c = '12346';
        cmfObj3.Status__c = 'A';
        
        cmfInfoList.add(cmfObj1);
        cmfInfoList.add(cmfObj2);
        cmfInfoList.add(cmfObj3);
        
        insert cmfInfoList;
       
    }
    
    private testmethod static void insertTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        CMF_Info__c cmfRecord = DS_TestObjects.NewCMFInfo();
        cmfRecord.Name = 'Test CMF4';
        cmfRecord.Account__c = acc.Id;
        insert cmfRecord;
    }
    
    private testmethod static void updateTest1()
    {
        CMF_Info__c cmfObj = [SELECT Id, Account__c, SLS_BaseLine_CMF_Number__c,Ship_CMF__c FROM  CMF_Info__c WHERE Name Like '%CMF1%' Limit 1];
        cmfObj.SLS_Baseline_CMF_Number__c = '123456';
        cmfObj.Ship_CMF__c = '123456';
        update cmfObj;
        
        Account accObj = [Select Id,SLS_BaseLine_CMF_Number__c From Account WHERE Id =: cmfObj.Account__c];
        System.assertEquals(accObj.SLS_BaseLine_CMF_Number__c,'123456');
    }
    
    private testmethod static void updateTest2() {
        CMF_Info__c cmfRecord = [SELECT Id FROM CMF_Info__c WHERE Name LIKE '%CMF3%'];
        cmfRecord.Status__c = 'I';
        update cmfRecord;
        
        
    }
}