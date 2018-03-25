//2017-06-21- anirudh.singh@cdk.com- Created this class for RQ-09460.
@isTest
public class ALL_TaskEvent_Test
{
    @TestSetup
    private static void setupData()
    {
        List<All_SharedContactsActivityRelationships__c> csList=new List<All_SharedContactsActivityRelationships__c>();
        All_SharedContactsActivityRelationships__c csRec1=new All_SharedContactsActivityRelationships__c();
        csRec1.Name='001';
        csRec1.Object__c='Account';
        csRec1.Field__c='Id';
        csList.add(csRec1);
        
        All_SharedContactsActivityRelationships__c csRec2=new All_SharedContactsActivityRelationships__c();
        csRec2.Name='003';
        csRec2.Object__c='Contact';
        csRec2.Field__c='AccountID';
        csList.add(csRec2);
        
        All_SharedContactsActivityRelationships__c csRec3=new All_SharedContactsActivityRelationships__c();
        csRec3.Name='a05';
        csRec3.Object__c='Laser_Case__c';
        csRec3.Field__c='Laser_Billing_Info__c';
        csRec3.Object_L1__c='Laser_Billing_Info__c';
        csRec3.Field_L1__c='Ship_To_CMF_Name__c';
        csRec3.Object_L2__c='CMF_Info__c';
        csRec3.Field_L2__c='Account__c';
        csList.add(csRec3);
        
        All_SharedContactsActivityRelationships__c csRec4=new All_SharedContactsActivityRelationships__c();
        csRec4.Name='a0G';
        csRec4.Object__c='Installed_Laser_Forms__c';
        csRec4.Field__c='CMF_Info__c';
        csRec4.Object_L1__c='CMF_Info__c';
        csRec4.Field_L1__c='Account__c';
        csList.add(csRec4);
        insert csList;
        
        Site_Type__c siteTypeRec=DS_TestObjects.NewSiteType();
        siteTypeRec.Group_Flag__c=true;
        insert siteTypeRec;
        
        Account acc1=DS_TestObjects.NewAccount();
        acc1.Name='ALL_TaskEvent_Test Acc1';
        acc1.Site_Type__c=siteTypeRec.Id;
        acc1.Duplicate__c=false;
        insert acc1;
        
        Contact cont1=DS_TestObjects.NewContact();
        cont1.LastName='ALL_TaskEvent_Test Con1';
        insert cont1;
        
        Account acc2=DS_TestObjects.NewAccount();
        acc2.Name='ALL_TaskEvent_Test Acc2';
        acc2.Group__c=acc1.Id;
        insert acc2;
        
        Contact cont2=DS_TestObjects.NewContact();
        cont2.LastName='ALL_TaskEvent_Test Con2';
        insert cont2;
        
        Campaign campRec=new Campaign();
        campRec.Name='Test Campaign';
        insert campRec;
        
        CMF_Info__c cmfInfoRec=DS_TestObjects.NewCMFInfo();
        cmfInfoRec.Account__c=acc1.Id;
        insert cmfInfoRec;
        
        Laser_Billing_Info__c bilInfoRec=new Laser_Billing_Info__c();
        bilInfoRec.C__c='623546';
        bilInfoRec.Ship_To_CMF_Name__c=cmfInfoRec.Id;
        insert bilInfoRec;
        
        Laser_Case__c laserCaseRec=new Laser_Case__c();
        laserCaseRec.Laser_Billing_Info__c=bilInfoRec.Id;
        laserCaseRec.Case__c='623546';
        insert laserCaseRec;
        
        Installed_Laser_Forms__c installedLaserFormRec=new Installed_Laser_Forms__c();
        installedLaserFormRec.CMF_Info__c=cmfInfoRec.Id;
        insert installedLaserFormRec;
        
        List<Task> taskList=new List<Task>();
        Task task1=DS_TestObjects.NewTask();
        task1.Type='Call';
        task1.Subject='Call 1';
        task1.WhatId=acc2.Id;
        task1.DS_Service_Connect_Visit__c='No';
        taskList.add(task1);
        
        Task task2=DS_TestObjects.NewTask();
        task2.Type='Call';
        task2.Subject='Call 2';
        task2.WhatId=acc2.Id;
        task2.DS_Service_Connect_Visit__c='Yes';
        taskList.add(task2);
        
        Task task3=DS_TestObjects.NewTask();
        task3.Type='Call';
        task3.Subject='Call 3';
        task1.WhatId=campRec.Id;
        task3.WhoId=cont1.Id;
        taskList.add(task3);
        
        Task task4=DS_TestObjects.NewTask();
        task4.Type='Call';
        task4.Subject='Call 4';
        task4.WhatId=laserCaseRec.Id;
        taskList.add(task4);
        
        Task task5=DS_TestObjects.NewTask();
        task5.Type='Call';
        task5.Subject='Call 5';
        task5.WhatId=installedLaserFormRec.Id;
        taskList.add(task5);
        insert taskList;
    }
    
    private static testMethod void populatePrimaryAccFieldTestOne()
    {
        Test.startTest();
        List<sObject> recsToModifyList=ALL_TaskEvent_Helper.populatePrimaryAccField(Null);
        Test.stopTest();
        
        system.assertEquals(0, recsToModifyList.size(), 'No records to process.');
    }
    
    private static testMethod void populatePrimaryAccFieldTestTwo()
    {
        Test.startTest();
        List<sObject> recsToModifyList=ALL_TaskEvent_Helper.populatePrimaryAccField(new List<Task>());
        Test.stopTest();
        
        system.assertEquals(0, recsToModifyList.size(), 'No records to process.');
    }
    
    private static testMethod void populatePrimaryAccFieldTestThree()
    {
        List<Task> taskList=[SELECT Id, WhatId, WhoId, AccountId, Primary_Account__c FROM Task];
        
        Test.startTest();
        List<sObject> recsToModifyList=ALL_TaskEvent_Helper.populatePrimaryAccField(taskList);
        Test.stopTest();
        
        system.assertEquals(1, recsToModifyList.size(), 'Records processed.');
    }
    
    private static testMethod void updateServiceConnectVisitTrackingTestOne()
    {
        Test.startTest();
        ALL_TaskEvent_Helper.updateServiceConnectVisitTracking(Null, 'Task');
        Test.stopTest();
    }
    
    private static testMethod void updateServiceConnectVisitTrackingTestTwo()
    {
        Test.startTest();
        ALL_TaskEvent_Helper.updateServiceConnectVisitTracking(new Map<Id, Task>(), 'Task');
        Test.stopTest();
    }
    
    private static testMethod void updateServiceConnectVisitTrackingTestThree()
    {
        Map<Id, Task> taskMap=new Map<Id, Task>([SELECT Id, WhatId, WhoId, AccountId, Primary_Account__c FROM Task]);
        
        Test.startTest();
        ALL_TaskEvent_Helper.updateServiceConnectVisitTracking(taskMap, '');
        Test.stopTest();
    }
    
    private static testMethod void updateServiceConnectVisitTrackingTestFour()
    {
        Map<Id, Task> taskMap=new Map<Id, Task>([SELECT Id, WhatId, WhoId, AccountId, Primary_Account__c FROM Task]);
        
        Test.startTest();
        ALL_TaskEvent_Helper.updateServiceConnectVisitTracking(taskMap, 'Task');
        Test.stopTest();
    }
    
    private static testMethod void batchTestOne()
    {
        Test.startTest();
        ALL_TaskEvent_Batch batchRef=new ALL_TaskEvent_Batch();
        batchRef.queryStr='SELECT WhatId, WhoId, AccountId, Primary_Account__c FROM Task WHERE (WhatId!=Null OR WhoId!=Null)';
        Id batchId=Database.executeBatch(batchRef);
        Test.stopTest();
    }
    
    private static testMethod void schedulerTestOne()
    {
        Test.startTest();
        String jobId=System.schedule('Test ALL_TaskEvent_Scheduler', 
                                     '0 0 0 ? * 1', 
                                     new ALL_TaskEvent_Scheduler());
        Test.stopTest();
    }
}