/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: IMP_ProjectActivityCapture_Scheduler test class
History
09/25/14    Michael Lasala      Created
11/25/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/
@isTest
public class IMP_ProjectActivityCaptureScheduler_Test {
    
    static testMethod void schedule_Test(){
        
        String startTime = '0 0 12 * * ?';
         
        Test.StartTest();
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        Contact testContact = IMP_TestFactory_Helper.buildContact(testAccount.Id);
        insert testContact;
        
        Laser_Artwork_Order__c testLaserArtworkOrder = IMP_TestFactory_Helper.buildLaserArtworkOrder(testContact.Id);
        testLaserArtworkOrder.A_P_Check_Order_Placed__c = Date.today() - 5;
        testLaserArtworkOrder.A_P_Check_Order_Actual_End_Date__c = Date.today() - 3;
        insert testLaserArtworkOrder;
        
        Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
        
        SubProject_External_Reference__c testExternalReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(testLaserArtworkOrder.Id, testSubProject.Id, testProject.Id);
        testExternalReference.RecordTypeId = recordTypeInfo.get('LAO').getRecordTypeId();
        insert testExternalReference;
        
        IMP_ExternalReferenceRecordTypes__c testSetting = IMP_TestFactory_Helper.buildExternalReferenceRecordTypeItem(IMP_TestFactory_Helper.Enum_ExternalReferenceRecordTypes.LAO);
        insert testSetting;
        
        List<Project_Activity_Detail_Mapping_Rule__c> testPADMappingRuleList = new List<Project_Activity_Detail_Mapping_Rule__c>();
        
        Project_Activity_Detail_Mapping_Rule__c testPADMappingRuleStartDate = IMP_TestFactory_Helper.buildProjectActivityDetailMappingRuleActualStart();
        testPADMappingRuleList.add(testPADMappingRuleStartDate);
        
        Project_Activity_Detail_Mapping_Rule__c testPADMappingRuleEndDate = IMP_TestFactory_Helper.buildProjectActivityDetailMappingRuleActualEnd();
        testPADMappingRuleList.add(testPADMappingRuleEndDate);
        
        //insert testPADMappingRuleList;
        
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        insert testMilestoneDefinition;
        
        Activity_Definition__c testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinition.Id);
        testActivityDefinition.External_Activity__c = 'ap_check_ordered';
        insert testActivityDefinition;

        Task_Definition__c testTaskDefinition = IMP_TestFactory_Helper.buildTaskDefinition(testActivityDefinition.Id);
        testTaskDefinition.External_Activity_Name__c = 'ap_check_ordered';
        insert testTaskDefinition;
        System.debug('$$$ testTaskDefinition Id : ' + testTaskDefinition.id);
        
        Project_Milestone__c testProjectMilestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testSubProject.Id, 'Test');
        //testProjectMilestone.External_System_ID__c = testLaserArtworkOrder.Id;
        //testProjectMilestone.Site__c = 'Test;';
        testProjectMilestone.External_System_New_Id__c = testExternalReference.Id;
        insert testProjectMilestone;
        
        Project_Activity__c testProjectActivity = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.Id);
        testProjectActivity.Activity_Definition__c = testActivityDefinition.Id;
        testProjectActivity.Client_Assignee__c = testContact.id;
        testProjectActivity.CDK_Assignee__c = UserInfo.getUserId();
        insert testProjectActivity;

        Project_Task__c testTask = IMP_TestFactory_Helper.buildProjectTask(testProjectActivity.Id);
        testTask.Task_Definition__c = testTaskDefinition.Id;
        testTask.CDK_Assignee__c = UserInfo.getUserId();
        testTask.Description__c = 'Desc';
        testTask.Actual_Time_Spent__c = 2;
        testTask.Actual_Start_Date__c = Date.today() - 5;
        testTask.Actual_End_Date__c = Date.today() - 3;
        testTask.Terminal_Task__c = true;
        insert testTask;
        
        // Schedule the test job
        IMP_ProjectActivityCapture_Scheduler scheduler = new IMP_ProjectActivityCapture_Scheduler();
        String jobId = System.schedule('Test Job', '0 0 12 * * ?', scheduler);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(startTime, ct.CronExpression);
        
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        String currentMonth = (Date.today().month()>=10) ? String.valueOf(Date.today().month()) : '0'+String.valueOf(Date.today().month());
        String currentDate = (Datetime.now().hour()<12) ? String.valueOf(Date.today().day()) : String.valueOf(Date.today().day()+1);
        //System.assertEquals(String.valueOf(Date.today().year())+'-'+currentMonth+'-'+currentDate+' 12:00:00', String.valueOf(ct.NextFireTime));
        Test.StopTest();
    }
    
    static testMethod void scheduleLAO_Test(){
        
        String startTime = '0 0 12 * * ?';
        
        Test.StartTest();
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        Contact testContact = IMP_TestFactory_Helper.buildContact(testAccount.Id);
        insert testContact;
        
        Laser_Artwork_Order__c testLaserArtworkOrder = IMP_TestFactory_Helper.buildLaserArtworkOrder(testContact.Id);
        testLaserArtworkOrder.A_P_Check_Order_Placed__c = Date.today() - 5;
        testLaserArtworkOrder.A_P_Check_Order_Actual_End_Date__c = Date.today() - 3;
        insert testLaserArtworkOrder;
        
        Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
        
        SubProject_External_Reference__c testExternalReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(testLaserArtworkOrder.Id, testSubProject.Id, testProject.Id);
        testExternalReference.RecordTypeId = recordTypeInfo.get('LAO').getRecordTypeId();
        insert testExternalReference;
        
        IMP_ExternalReferenceRecordTypes__c testSetting = IMP_TestFactory_Helper.buildExternalReferenceRecordTypeItem(IMP_TestFactory_Helper.Enum_ExternalReferenceRecordTypes.LAO);
        insert testSetting;
        
        List<Project_Activity_Detail_Mapping_Rule__c> testPADMappingRuleList = new List<Project_Activity_Detail_Mapping_Rule__c>();
        
        Project_Activity_Detail_Mapping_Rule__c testPADMappingRuleStartDate = IMP_TestFactory_Helper.buildProjectActivityDetailMappingRuleActualStart();
        testPADMappingRuleList.add(testPADMappingRuleStartDate);
        
        Project_Activity_Detail_Mapping_Rule__c testPADMappingRuleEndDate = IMP_TestFactory_Helper.buildProjectActivityDetailMappingRuleActualEnd();
        testPADMappingRuleList.add(testPADMappingRuleEndDate);
        
        //insert testPADMappingRuleList;
        
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        insert testMilestoneDefinition;
        
        Activity_Definition__c testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinition.Id);
        testActivityDefinition.External_Activity__c = 'ap_check_ordered';
        insert testActivityDefinition;

        Task_Definition__c testTaskDefinition = IMP_TestFactory_Helper.buildTaskDefinition(testActivityDefinition.Id);
        testTaskDefinition.External_Activity_Name__c = 'ap_check_ordered';
        insert testTaskDefinition;
        System.debug('$$$ testTaskDefinition Id : ' + testTaskDefinition.id);
        
        Project_Milestone__c testProjectMilestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testSubProject.Id, 'Test');
        //testProjectMilestone.External_System_ID__c = testLaserArtworkOrder.Id;
        //testProjectMilestone.Site__c = 'Test;';
        testProjectMilestone.External_System_New_Id__c = testExternalReference.Id;
        insert testProjectMilestone;
        
        Project_Activity__c testProjectActivity = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.Id);
        testProjectActivity.Activity_Definition__c = testActivityDefinition.Id;
        testProjectActivity.Client_Assignee__c = testContact.id;
        testProjectActivity.CDK_Assignee__c = UserInfo.getUserId();
        insert testProjectActivity;

        Project_Task__c testTask = IMP_TestFactory_Helper.buildProjectTask(testProjectActivity.Id);
        testTask.Task_Definition__c = testTaskDefinition.Id;
        testTask.CDK_Assignee__c = UserInfo.getUserId();
        testTask.Description__c = 'Desc';
        testTask.Actual_Time_Spent__c = 2;
        testTask.Actual_Start_Date__c = Date.today() - 5;
        testTask.Actual_End_Date__c = Date.today() - 3;
        testTask.Terminal_Task__c = true;
        insert testTask;
        
        // Schedule the test job
        IMP_ProjectActivityCapture_Scheduler scheduler = new IMP_ProjectActivityCapture_Scheduler();
        scheduler.recordTypeNameString = 'LAO';
        String jobId = System.schedule('Test Job', '0 0 12 * * ?', scheduler);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(startTime, ct.CronExpression);
        
        // Verify the job has not run 
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        String currentMonth = (Date.today().month()>=10) ? String.valueOf(Date.today().month()) : '0'+String.valueOf(Date.today().month());
        String currentDate = (Datetime.now().hour()<12) ? String.valueOf(Date.today().day()) : String.valueOf(Date.today().day()+1);
        //System.assertEquals(String.valueOf(Date.today().year())+'-'+currentMonth+'-'+currentDate+' 12:00:00', String.valueOf(ct.NextFireTime));
        Test.StopTest();
    }
}