/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: IMP_ProjectActivityCapture_Batch test class
History
10/09/14    Michael Lasala      Created
11/25/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
04/23/15    Samuel Oberes       Fixed test class by adding project task and correctly setting its actual end date
------------------------------------------------------------*/
@isTest(SeeAllData=true)
public class IMP_ProjectActivityCaptureBatch_Test{
    /*
    static testMethod void batchNoRecordType_Test(){                    
        Project__c testProject = new Project__c();
        testProject.Name = 'Test Project';
        insert testProject;
        
        SubProject__c testSubProject = new SubProject__c();
        testSubProject.SubProject_Name__c = 'Test SubProject';
        testSubProject.Project__c = testProject.Id;
        testSubProject.Project_Type__c = 'Upgrade';
        testSubProject.Market__c = 'Drive - Baseline';
        testSubProject.Number_of_Rooftops__c = 1;
        testSubProject.Number_of_User_Connections__c = 1;
        insert testSubProject;
        system.debug('$$$ testSubProject : ' + testSubProject.id);
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Role__c = 'Accountant';
        insert testContact;
        
        Laser_Artwork_Order__c testLaserArtworkOrder = new Laser_Artwork_Order__c();
        testLaserArtworkOrder.Contact__c = testContact.Id;
        testLaserArtworkOrder.Order_Type__c = 'Add/Change - DASH';
        testLaserArtworkOrder.Order_Status__c = 'Sold';
        testLaserArtworkOrder.Order_Priority__c = 'Standard';
        testLaserArtworkOrder.Prev_SO__c = '12345';
        testLaserArtworkOrder.Stock_Order__c = '12345';
        testLaserArtworkOrder.Contract_PO__c = '12345';
        testLaserArtworkOrder.Change_Notes__c = 'Test';
        testLaserArtworkOrder.A_P_Check_Order_Placed__c = Date.today() - 5;
        testLaserArtworkOrder.A_P_Check_Order_Actual_End_Date__c = Date.today() - 2;
        insert testLaserArtworkOrder;
        System.debug('$$$ testLaserArtworkOrder: ' + testLaserArtworkOrder.id);
        Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
        
        SubProject_External_Reference__c testExternalReference = new SubProject_External_Reference__c();
        testExternalReference.LAO_ID__c = testLaserArtworkOrder.Id;
        testExternalReference.SubProject__c = testSubProject.Id;
        testExternalReference.Project__c = testProject.Id;
        testExternalReference.RecordTypeId = recordTypeInfo.get('LAO').getRecordTypeId();
        insert testExternalReference;
        
        IMP_ExternalReferenceRecordTypes__c testSetting = new IMP_ExternalReferenceRecordTypes__c();
        testSetting.Name = 'LAO';
        testSetting.Partner_Id__c = 'LAO_ID__c';
        testSetting.Field_Map_API_Name__c = 'Source_API_Field_Name__c';
        testSetting.Record_Type_Map_API_Name__c = 'External_Entity_Type__c';
        testSetting.Source_Object_API_Name__c = 'Laser_Artwork_Order__c';
        testSetting.Target_Activity_Date_Type_API_Field_Name__c = 'Target_Unique_Act_Plus_Date_Type__c';
        //insert testSetting;
        
        List<Project_Activity_Detail_Mapping_Rule__c> testPADMappingRuleList = new List<Project_Activity_Detail_Mapping_Rule__c>();
        
        Project_Activity_Detail_Mapping_Rule__c testPADMappingRuleStartDate = new Project_Activity_Detail_Mapping_Rule__c();
        testPADMappingRuleStartDate.External_Entity_Type__c = 'LAO';
        testPADMappingRuleStartDate.Target_Activity_Name__c = 'Test_Mapping';
        testPADMappingRuleStartDate.Date_Type__c = 'Actual Start';
        testPADMappingRuleStartDate.Source_API_Field_Name__c = 'A_P_Check_Order_Actual_Start_Date__c';
        testPADMappingRuleStartDate.Active__c = true;
        testPADMappingRuleList.add(testPADMappingRuleStartDate);
        
        Project_Activity_Detail_Mapping_Rule__c testPADMappingRuleEndDate = new Project_Activity_Detail_Mapping_Rule__c();
        testPADMappingRuleEndDate.External_Entity_Type__c = 'LAO';
        testPADMappingRuleEndDate.Target_Activity_Name__c = 'Test_Mapping';
        testPADMappingRuleEndDate.Date_Type__c = 'Actual End';
        testPADMappingRuleEndDate.Source_API_Field_Name__c = 'A_P_Check_Order_Actual_End_Date__c';
        testPADMappingRuleEndDate.Active__c = true;
        testPADMappingRuleList.add(testPADMappingRuleEndDate);
        
        //insert testPADMappingRuleList;
        
        Milestone_Definition__c testMilestoneDefinition = new Milestone_Definition__c();
        testMilestoneDefinition.Description__c = 'Test Milestone Definition';
        testMilestoneDefinition.Project_Type__c = 'Unhook;Upgrade;';
        testMilestoneDefinition.Market__c = 'Drive - Baseline;Dash - Small Auto;';
        testMilestoneDefinition.Active__c = true;
        insert testMilestoneDefinition;
        
        Activity_Definition__c testActivityDefinition = new Activity_Definition__c();
        testActivityDefinition.Milestone_Definition__c = testMilestoneDefinition.Id;
        testActivityDefinition.Active__c = true;
        testActivityDefinition.Terminal_Activity__c = true;
        testActivityDefinition.Offset_Criteria__c = IMP_Project_Utility.OFFSET_CRITERIA_ROLL_CALL;
        testActivityDefinition.Planned_Start_Date_Offset__c = 1;
        testActivityDefinition.Planned_End_Date_Offset__c = 2;
        testActivityDefinition.External_Activity__c = 'ap_check_ordered';
        insert testActivityDefinition;
        
        Project_Milestone__c testProjectMilestone = new Project_Milestone__c();
        testProjectMilestone.SubProject__c = testSubProject.Id;
        testProjectMilestone.External_System_ID__c = testLaserArtworkOrder.Id;
        testProjectMilestone.Site__c = 'Test;';
        testProjectMilestone.Description__c = 'Test';
        insert testProjectMilestone;
        System.debug('$$$ SubProject Id : ' + testProjectMilestone.id);
        Project_Activity__c testProjectActivity = new Project_Activity__c();
        testProjectActivity.Milestone__c = testProjectMilestone.Id;
        testProjectActivity.Activity_Definition__c = testActivityDefinition.Id;
        testProjectActivity.Description__c = 'Test';
        testProjectActivity.Client_Assignee__c = testContact.id;
        testProjectActivity.CDK_Assignee__c = UserInfo.getUserId();
        insert testProjectActivity;
        System.debug('$$$ testActivity Id : ' + testProjectActivity.id);
        System.assertEquals(null, testProjectActivity.Actual_Start_Date__c);
        System.assertEquals(null, testProjectActivity.Actual_End_Date__c);
        
        String query = 'SELECT Id FROM SubProject__c WHERE SubProject_Status__c != \'Closed\'';
        
        Test.StartTest();
        IMP_ProjectActivityCapture_Batch batchJob = new IMP_ProjectActivityCapture_Batch();
        Database.executeBatch(batchJob);
        Test.StopTest();
        
        Project_Activity__c updatedProjectActivity = [SELECT Actual_Start_Date__c, Actual_End_Date__c FROM Project_Activity__c WHERE Id =: testProjectActivity.Id];
        System.assertEquals(testLaserArtworkOrder.A_P_Check_Order_Placed__c, updatedProjectActivity.Actual_Start_Date__c);
        System.assertEquals(testLaserArtworkOrder.A_P_Check_Order_Actual_End_Date__c, updatedProjectActivity.Actual_End_Date__c);
    }
    */
    static testMethod void batchLAORecordType_Test(){                    
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        system.debug('$$$ testSubProject : ' + testSubProject.id);
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        Contact testContact = IMP_TestFactory_Helper.buildContact(testAccount.Id);
        insert testContact;
        
        Laser_Artwork_Order__c testLaserArtworkOrder = IMP_TestFactory_Helper.buildLaserArtworkOrder(testContact.Id);
        testLaserArtworkOrder.A_P_Check_Order_Placed__c = Date.today() - 5;
        testLaserArtworkOrder.A_P_Check_Order_Actual_End_Date__c = Date.today() - 3;
        insert testLaserArtworkOrder;
         System.debug('$$$ testLaserArtworkOrder: ' + testLaserArtworkOrder.id);
        Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
        
        SubProject_External_Reference__c testExternalReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(testLaserArtworkOrder.Id, testSubProject.Id, testProject.Id);
        testExternalReference.RecordTypeId = recordTypeInfo.get('LAO').getRecordTypeId();
        insert testExternalReference;
        
        IMP_ExternalReferenceRecordTypes__c testSetting = IMP_TestFactory_Helper.buildExternalReferenceRecordTypeItem(IMP_TestFactory_Helper.Enum_ExternalReferenceRecordTypes.LAO);
        //insert testSetting;
        
        List<Project_Activity_Detail_Mapping_Rule__c> testPADMappingRuleList = new List<Project_Activity_Detail_Mapping_Rule__c>();
        
        Project_Activity_Detail_Mapping_Rule__c testPADMappingRuleStartDate = IMP_TestFactory_Helper.buildProjectActivityDetailMappingRuleActualStart();
        testPADMappingRuleList.add(testPADMappingRuleStartDate);
        
        Project_Activity_Detail_Mapping_Rule__c testPADMappingRuleEndDate = IMP_TestFactory_Helper.buildProjectActivityDetailMappingRuleActualEnd();
        testPADMappingRuleList.add(testPADMappingRuleEndDate);
        
        //insert testPADMappingRuleList
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
        //testProjectMilestone.External_System_Id2__c = testLaserArtworkOrder.Id;
        //testProjectMilestone.Site__c = 'Test';
        testProjectMilestone.External_System_New_Id__c = testExternalReference.Id;
        insert testProjectMilestone;
        System.debug('$$$ testProjectMilestone : ' + testProjectMilestone);
         
        Project_Activity__c testProjectActivity = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.Id);
        testProjectActivity.Activity_Definition__c = testActivityDefinition.Id;
        testProjectActivity.Client_Assignee__c = testContact.id;
        testProjectActivity.CDK_Assignee__c = UserInfo.getUserId();    
        //testProjectActivity.Terminal_Activity__c = true;    
        insert testProjectActivity;

        Project_Task__c testTask = IMP_TestFactory_Helper.buildProjectTask(testProjectActivity.Id);
        testTask.Task_Definition__c = testTaskDefinition.Id;
        testTask.CDK_Assignee__c = UserInfo.getUserId();
        testTask.Description__c = 'Desc';
        
        testTask.Actual_Start_Date__c = Date.today() - 5;
        testTask.Actual_End_Date__c = Date.today() - 3;
        testTask.Actual_Time_Spent__c = 2;
        
        testTask.Terminal_Task__c = true;
        insert testTask;

        System.debug('$$$ Project external id : ' + testProjectActivity.Activity_Definition__c);
        System.debug('$$$ Project external name : ' + testProjectActivity.External_Activity_Name__c);
        System.debug('$$$ Project Act Id : ' + testProjectActivity.Id);
        
        System.debug(testSubProject.Id);
        System.assertEquals(null, testProjectActivity.Actual_Start_Date__c);
        System.assertEquals(null, testProjectActivity.Actual_End_Date__c);
        
        String query = 'SELECT Id FROM SubProject__c WHERE SubProject_Status__c != \'Closed\'';

        Test.StartTest();
        IMP_ProjectActivityCapture_Batch batchJob = new IMP_ProjectActivityCapture_Batch();
        batchJob.recordTypeName = 'LAO';
        Database.executeBatch(batchJob);
        Test.StopTest();
        
        Project_Activity__c updatedProjectActivity = [SELECT Actual_Start_Date__c, Actual_End_Date__c FROM Project_Activity__c WHERE Id =: testProjectActivity.Id];
        System.assertEquals(testLaserArtworkOrder.A_P_Check_Order_Placed__c, updatedProjectActivity.Actual_Start_Date__c);
        System.assertEquals(testLaserArtworkOrder.A_P_Check_Order_Actual_End_Date__c, updatedProjectActivity.Actual_End_Date__c);
    }
    /*
    @isTest(SeeAllData=true)  
    static void batchWithError_Test(){
        Project__c testProject = new Project__c();
        testProject.Name = 'Test Project';
        insert testProject;
        
        SubProject__c testSubProject = new SubProject__c();
        testSubProject.SubProject_Name__c = 'Test SubProject';
        testSubProject.Project__c = testProject.Id;
        testSubProject.Project_Type__c = 'Upgrade';
        testSubProject.Market__c = 'Drive - Baseline';
        testSubProject.Number_of_Rooftops__c = 1;
        testSubProject.Number_of_User_Connections__c = 1;
        insert testSubProject;
        
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.AccountId = testAccount.Id;
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Role__c = 'Accountant';
        insert testContact;
        
        Laser_Artwork_Order__c testLaserArtworkOrder = new Laser_Artwork_Order__c();
        testLaserArtworkOrder.Contact__c = testContact.Id;
        testLaserArtworkOrder.Order_Type__c = 'Add/Change - DASH';
        testLaserArtworkOrder.Order_Status__c = 'Sold';
        testLaserArtworkOrder.Order_Priority__c = 'Standard';
        testLaserArtworkOrder.Prev_SO__c = '12345';
        testLaserArtworkOrder.Stock_Order__c = '12345';
        testLaserArtworkOrder.Contract_PO__c = '12345';
        testLaserArtworkOrder.Change_Notes__c = 'Test';
        testLaserArtworkOrder.A_P_Check_Order_Placed__c = Date.today().addDays(5);
        testLaserArtworkOrder.A_P_Check_Order_Actual_End_Date__c = Date.today();
        insert testLaserArtworkOrder;
        
        Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
        
        SubProject_External_Reference__c testExternalReference = new SubProject_External_Reference__c();
        testExternalReference.LAO_ID__c = testLaserArtworkOrder.Id;
        testExternalReference.SubProject__c = testSubProject.Id;
        testExternalReference.Project__c = testProject.Id;
        testExternalReference.RecordTypeId = recordTypeInfo.get('LAO').getRecordTypeId();
        insert testExternalReference;
        
        Milestone_Definition__c testMilestoneDefinition = new Milestone_Definition__c();
        testMilestoneDefinition.Description__c = 'Test Milestone Definition';
        testMilestoneDefinition.Project_Type__c = 'Unhook;Upgrade;';
        testMilestoneDefinition.Market__c = 'Drive - Baseline;Dash - Small Auto;';
        testMilestoneDefinition.Active__c = true;
        insert testMilestoneDefinition;
        
        Activity_Definition__c testActivityDefinition = new Activity_Definition__c();
        testActivityDefinition.Milestone_Definition__c = testMilestoneDefinition.Id;
        testActivityDefinition.Active__c = true;
        testActivityDefinition.Terminal_Activity__c = true;
        testActivityDefinition.Offset_Criteria__c = IMP_Project_Utility.OFFSET_CRITERIA_ROLL_CALL;
        testActivityDefinition.Planned_Start_Date_Offset__c = 1;
        testActivityDefinition.Planned_End_Date_Offset__c = 2;
        testActivityDefinition.External_Activity__c = 'ap_check_ordered';
        insert testActivityDefinition;
        
        Project_Milestone__c testProjectMilestone = new Project_Milestone__c();
        testProjectMilestone.SubProject__c = testSubProject.Id;
        testProjectMilestone.External_System_ID__c = testLaserArtworkOrder.Id;
        testProjectMilestone.Site__c = 'Test;';
        testProjectMilestone.Description__c = 'Test';
        insert testProjectMilestone;
        
        Project_Activity__c testProjectActivity = new Project_Activity__c();
        testProjectActivity.Milestone__c = testProjectMilestone.Id;
        testProjectActivity.Activity_Definition__c = testActivityDefinition.Id;
        testProjectActivity.Description__c = 'Test';
        insert testProjectActivity;
        
        System.assertEquals(null, testProjectActivity.Actual_Start_Date__c);
        System.assertEquals(null, testProjectActivity.Actual_End_Date__c);
        
        Test.StartTest();
        IMP_ProjectActivityCapture_Batch batchJob = new IMP_ProjectActivityCapture_Batch();
        Database.executeBatch(batchJob);
        Test.StopTest();
        
        Project_Activity__c updatedProjectActivity = [SELECT Actual_Start_Date__c, Actual_End_Date__c FROM Project_Activity__c WHERE Id =: testProjectActivity.Id];
        System.assertEquals(null, updatedProjectActivity.Actual_Start_Date__c);
        System.assertEquals(null, updatedProjectActivity.Actual_End_Date__c);
    }
    */
}