/*
* RQ-04694
* 2015-10-16  - venkata.shrivol@cdk.com   - Created
* Description: second Test class for IMP_ProjectActivityCapture_Batch. Since it uses chatter API, this test class uses
			 (seeAllData=true) to cover the chatterAPI and the other test class don't use it. 
*---------------MODIFICATIONS-------------------------*	
* 2016-12-05 -venkata.shrivol@cdk.com -commented project object reference RQ-08305		 
*/
@isTest(seeAllData=true)
public class IMP_ProjectActivityCaptureBatch2_Test 
{
    static testMethod void testBatchToThrowException()
    {
		/*Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;*/
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject();
        insert testSubProject;
        system.debug('$$$ testSubProject : ' + testSubProject.id);
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        Contact testContact = IMP_TestFactory_Helper.buildContact(testAccount.Id);
        insert testContact;
        
        Laser_Artwork_Order__c testLaserArtworkOrder = IMP_TestFactory_Helper.buildLaserArtworkOrder(testContact.Id);
        testLaserArtworkOrder.A_P_Check_Order_Placed__c = Date.today() + 5;
        testLaserArtworkOrder.A_P_Check_Order_Actual_End_Date__c = Date.today() + 3;
        insert testLaserArtworkOrder;
        System.debug('$$$ testLaserArtworkOrder: ' + testLaserArtworkOrder.id);
        
        Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
        
        SubProject_External_Reference__c testExternalReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(testLaserArtworkOrder.Id, testSubProject.Id);
        testExternalReference.RecordTypeId = recordTypeInfo.get('FO').getRecordTypeId();
        insert testExternalReference;
        
        //IMP_ExternalReferenceRecordTypes__c testSetting = IMP_TestFactory_Helper.buildExternalReferenceRecordTypeItem(IMP_TestFactory_Helper.Enum_ExternalReferenceRecordTypes.FO);
        //insert testSetting;
        
        //List<Project_Activity_Detail_Mapping_Rule__c> testPADMappingRuleList = Test.loadData(Project_Activity_Detail_Mapping_Rule__c.sObjectType, 'IMP_PMActMappingRuleTestData_CSV'); 
        
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
        
        Test.startTest();
	    	IMP_ProjectActivityCapture_Batch batchJob3 = new IMP_ProjectActivityCapture_Batch();
	        Database.executeBatch(batchJob3);	
    	Test.stopTest();
    	
    	Project_Task__c updatedProjectTask = [
        	select Actual_Start_Date__c, Actual_End_Date__c 
        	from Project_Task__c
        	where CDK_Assignee__c = :UserInfo.getUserId()
        	order by CreatedDate desc limit 1
        ];
         
        System.assertEquals(null, updatedProjectTask.Actual_Start_Date__c);
        System.assertEquals(null, updatedProjectTask.Actual_End_Date__c);  	   
    }
}