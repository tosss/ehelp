/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: IMP_ProjectActivityCapture_Batch test class
History
10/09/14    Michael Lasala      Created
11/25/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
04/23/15    Samuel Oberes       Fixed test class by adding project task and correctly setting its actual end date
09/17/15    Venkata Shrivol		Changed the IMP_TestFactory Helper enumerated test reference to FO from LAO
10/09/15    Venkata Shrivol		Loaded the PM activity mapping rule object data through a CSV.
------------------------------------------------------------*/
@isTest
public class IMP_ProjectActivityCaptureBatch_Test{

    @testSetup static void prepareTestData()
    {       
        CustomSettings__c testCustomSettings = CustomSettings__c.getOrgDefaults();
		testCustomSettings.Users_Excluded_from_Business_Rules__c = userInfo.getFirstName() +' '+userInfo.getLastName();
		upsert testCustomSettings;
    	
    	        
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
        testLaserArtworkOrder.LAS_Name__c = userInfo.getUserId();
        insert testLaserArtworkOrder;
        System.debug('$$$ testLaserArtworkOrder: ' + testLaserArtworkOrder.id);
        
        Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
        
        SubProject_External_Reference__c testExternalReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(testLaserArtworkOrder.Id, testSubProject.Id, testProject.Id);
        testExternalReference.RecordTypeId = recordTypeInfo.get('FO').getRecordTypeId();
        insert testExternalReference;
        
        IMP_ExternalReferenceRecordTypes__c testSetting = IMP_TestFactory_Helper.buildExternalReferenceRecordTypeItem(IMP_TestFactory_Helper.Enum_ExternalReferenceRecordTypes.FO);
        insert testSetting;
        
        List<Project_Activity_Detail_Mapping_Rule__c> testPADMappingRuleList = Test.loadData(Project_Activity_Detail_Mapping_Rule__c.sObjectType, 'IMP_PMActMappingRuleTestData_CSV'); 
        
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
        
        //testTask.Actual_Start_Date__c = Date.today() - 5;
        //testTask.Actual_End_Date__c = Date.today() - 3;
        //testTask.Actual_Time_Spent__c = 2;
        
        //testTask.Terminal_Task__c = true;
        insert testTask;

        System.debug('$$$ Project external id : ' + testProjectActivity.Activity_Definition__c);
        System.debug('$$$ Project external name : ' + testProjectActivity.External_Activity_Name__c);
        System.debug('$$$ Project Act Id : ' + testProjectActivity.Id);
    }
    
    static testMethod void testBatchWithOutRecordType()
    {
    	Test.StartTest();
	        IMP_ProjectActivityCapture_Batch batchJob = new IMP_ProjectActivityCapture_Batch();
	        Database.executeBatch(batchJob);	
        Test.StopTest();
        
        Laser_Artwork_Order__c insertedLaserArtworkRecord = [
        	select A_P_Check_Order_Placed__c, A_P_Check_Order_Actual_End_Date__c 
        	from Laser_Artwork_Order__c
        	where LAS_Name__c = :userInfo.getUserId()
        ];
        Project_Task__c updatedProjectTask = [
        	select Actual_Start_Date__c, Actual_End_Date__c 
        	from Project_Task__c
        	where CDK_Assignee__c = :UserInfo.getUserId()
         ];
         
         System.assertEquals(insertedLaserArtworkRecord.A_P_Check_Order_Placed__c, updatedProjectTask.Actual_Start_Date__c);
         System.assertEquals(insertedLaserArtworkRecord.A_P_Check_Order_Actual_End_Date__c, updatedProjectTask.Actual_End_Date__c);
    }
    
    static testMethod void testBatchWithRecordType()
    {
    	Test.StartTest();
	    	IMP_ProjectActivityCapture_Batch batchJob2 = new IMP_ProjectActivityCapture_Batch();
	        batchJob2.recordTypeName = 'FO';
	        Database.executeBatch(batchJob2);
        Test.StopTest();
        
        Laser_Artwork_Order__c insertedLaserArtworkRecord = [
        	select A_P_Check_Order_Placed__c, A_P_Check_Order_Actual_End_Date__c 
        	from Laser_Artwork_Order__c
        	where LAS_Name__c = :userInfo.getUserId()
        	limit 1
        ];
        Project_Task__c updatedProjectTask = [
        	select Actual_Start_Date__c, Actual_End_Date__c 
        	from Project_Task__c
        	where CDK_Assignee__c = :UserInfo.getUserId()
        	limit 1
         ];
         
         System.assertEquals(insertedLaserArtworkRecord.A_P_Check_Order_Placed__c, updatedProjectTask.Actual_Start_Date__c);
         System.assertEquals(insertedLaserArtworkRecord.A_P_Check_Order_Actual_End_Date__c, updatedProjectTask.Actual_End_Date__c);
    }
}