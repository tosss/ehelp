/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: IMP_MilestoneView_Controller test class
History
10/06/15    Rey Austral      Created
10/27/15	Rey Austral      Add new test method called overideThresholdCountForPagination
04/25/16    Venkata Shrivol  Modified refreshMilestonesAndProjectActivites_Test method for RQ-06652
------------------------------------------------------------*/
@isTest
public class IMP_MilestoneView_Controller_Test 
{
    private static final String GENERIC_MILESTONE_DESCRIPTION = 'TEST MILESTONE DESCRIPTION';
    
    private static Project__c project { get { return [Select id from Project__c Limit 1]; } }
    private static SubProject__c subProject { get { return [Select id,Project__c from SubProject__c Limit 1]; } }   
    private static User user_cdkAssignee { get { return [Select id from User Limit 1]; } }
    private static Contact contact_clientAssignee { get { return [Select id from Contact Limit 1]; } }
    private static Account account { get { return [Select id from Account Limit 1]; } }
    @testSetup static void setup()  
    {
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        User testUser_cdkAssignee = IMP_TestFactory_Helper.buildUser();
        insert testUser_cdkAssignee;
        
        Contact testContact_clientAssignee = IMP_TestFactory_Helper.buildContact(account.Id);
        insert testContact_clientAssignee;
        
        CustomSettings__c cust = IMP_TestFactory_Helper.buildCustomSettings();
        insert cust;
    }
    
    static testMethod void constructorNoRecords_Test()
    {
        // --------------------------------------------------------------------
        // TESTING PROPER
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        Test.StopTest();
        
        System.assertEquals(project.Id, subProject.Project__c);
        System.assertEquals(subProject.Id, controller.objectId);
    }
    
    static testMethod void constructorWithRecords_Test() 
    {
        // --------------------------------------------------------------------
        // INITIALIZATION
        
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);
        //task.Terminal_Task__c = true;
        insert task;
        
        IMP_TestFactory_Helper.buildCustomSettings();
        // --------------------------------------------------------------------
        // TESTING PROPER
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        Test.StopTest();
        
        System.assertEquals(project.Id, subProject.Project__c);
        System.assertEquals(subProject.Id, milestone.SubProject__c);
        System.assertEquals(milestone.Id, activity.Milestone__c);
        System.assertEquals(subProject.Id, controller.objectId);
    }
    
    static testMethod void refreshMilestonesAndProjectActivites_Test() 
    {
        // --------------------------------------------------------------------
        // INITIALIZATION
        
        Date MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        String MILESTONE_COMMENT_LITERAL = 'TEST MILESTONE COMMENT';
        String MILESTONE_DESCRIPTION_LITERAL = 'TEST MILESTONE';
        Date ACTIVITY_1_ACTUAL_START_DATE = Date.newInstance(2014, 10, 4);
        Date ACTIVITY_1_ACTUAL_END_DATE   = Date.newInstance(2014, 10, 4);
        
        String ACTIVITY_1_DEPARTMENT = 'Accounting';      
        String ACTIVITY_1_CDKASSIGNEEROLE = '3PA';    
        String ACTIVITY_1_DESCRIPTION = 'TEST ACTIVITY 1'; 
        String ACTIVITY_1_COMMENTS = 'TEST ACTIVITY COMMENT 1';
        
        String TASK_1_DEPARTMENT = 'Accounting';       
        String TASK_1_CDKASSIGNEEROLE = '3PA';       
        String TASK_1_DESCRIPTION = 'TEST TASK 1';        
        
        
        Project_Milestone__c milestoneNonGeneric = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, 'NON-GENERIC TEST MILESTONE');
        milestoneNonGeneric.Comments__c = MILESTONE_COMMENT_LITERAL;
        milestoneNonGeneric.Description__c = MILESTONE_DESCRIPTION_LITERAL;
        insert milestoneNonGeneric;
        
        Project_Activity__c activity1Terminal = IMP_TestFactory_Helper.buildProjectActivity(milestoneNonGeneric.Id);
        activity1Terminal.Actual_Start_Date__c = ACTIVITY_1_ACTUAL_START_DATE;
        activity1Terminal.CDK_Assignee__c = user_cdkAssignee.Id;
        activity1Terminal.CDK_Assignee_Role__c = ACTIVITY_1_CDKASSIGNEEROLE;
        activity1Terminal.Client_Assignee__c = contact_clientAssignee.Id;
        activity1Terminal.Department__c = ACTIVITY_1_DEPARTMENT;
        activity1Terminal.Description__c = ACTIVITY_1_DESCRIPTION;
        activity1Terminal.Display_on_PSR__c = true;
        //activity1Terminal.Planned_Start_Date__c = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 2; //Date.newInstance(2014, 1, 3);
        //activity1Terminal.Planned_End_Date__c   = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 3; //Date.newInstance(2014, 1, 4);    
        activity1Terminal.Comments__c = ACTIVITY_1_COMMENTS;        
        insert activity1Terminal;
        
        Project_Task__c act1_task1 = createTask( activity1Terminal.Id, '1',  TASK_1_DEPARTMENT,  TASK_1_CDKASSIGNEEROLE);
        insert act1_task1;
        
        Project_Task__c act1_task2 = createTask( activity1Terminal.Id, '2',  TASK_1_DEPARTMENT, TASK_1_CDKASSIGNEEROLE);
        insert act1_task2;
        // --------------------------------------------------------------------
        // TESTING PROPER
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
		
		system.debug('--------controller.milestoneContentList.get(0)-------'+controller.milestoneContentList);        
        //List<Project_Milestone__c> projectMList =  controller.retrieveMilestoneRecords();
        //controller.resetWrapperDataAndExtensionField(projectMList);
        Test.StopTest();
        
        // >>> milestone tests
        
        // the milestone created earlier should now exist inside the milestoneContentList MilestoneWrapper list
        Project_Milestone__c milestoneUnderTest = controller.milestoneContentList.get(0).projectMilestone;
        
        // expect 1 milestone to be fetched
        System.assertEquals(1, controller.milestoneContentList.size());
        
        // expect 3 activities to be fetched connected under the milestone
        System.assertEquals(1, controller.milestoneContentList.get(0).projectActivity.size());
        
        // expect: milestone's planned start date == minimum planned start date among the child activities
        System.assertEquals(MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE, milestoneUnderTest.Planned_Start_Date__c);
        
        // expect: milestone's planned end date == maximum planned start date among the child activities
        System.assertEquals(MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 1, milestoneUnderTest.Planned_End_Date__c);
        
        System.assertEquals(MILESTONE_COMMENT_LITERAL,     milestoneUnderTest.Comments__c);
        System.assertEquals(MILESTONE_DESCRIPTION_LITERAL, milestoneUnderTest.Description__c);
        //System.assertEquals(MILESTONE_STATUS_LITERAL,      milestoneUnderTest.Status__c);
        
        // >>> project activity tests
        
        // the second activity created earlier should now exist inside the milestoneContentList ActivityWrapper list
        Project_Activity__c activityUnderTest1 = controller.milestoneContentList.get(0).projectActivity.get(0).activity;
        System.assertEquals(MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE, activityUnderTest1.Planned_Start_Date__c);
        System.assertEquals(MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 1, activityUnderTest1.Planned_End_Date__c);
        System.assertEquals(user_cdkAssignee.Id, activityUnderTest1.CDK_Assignee__c);
        System.assertEquals(ACTIVITY_1_CDKASSIGNEEROLE, activityUnderTest1.CDK_Assignee_Role__c);
        System.assertEquals(contact_clientAssignee.Id, activityUnderTest1.Client_Assignee__c);
        System.assertEquals(ACTIVITY_1_DEPARTMENT, activityUnderTest1.Department__c);
        System.assertEquals(ACTIVITY_1_DESCRIPTION, activityUnderTest1.Description__c);
        System.assertEquals(ACTIVITY_1_DESCRIPTION, activityUnderTest1.Description__c);
        System.assertEquals(true, activityUnderTest1.Display_on_PSR__c);      
        System.assertEquals(ACTIVITY_1_COMMENTS, activityUnderTest1.Comments__c);
        
        // >>> project task tests
        
        // the first activity created earlier should now exist inside the milestoneContentList ActivityWrapper list
        Project_Task__c taskUnderTest1 = controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task;
        
        System.assertEquals(user_cdkAssignee.Id, taskUnderTest1.CDK_Assignee__c);
        System.assertEquals(TASK_1_CDKASSIGNEEROLE, taskUnderTest1.CDK_Assignee_Role__c);
        System.assertEquals(contact_clientAssignee.Id, taskUnderTest1.Client_Assignee__c);
        
        System.assertEquals(TASK_1_DESCRIPTION, taskUnderTest1.Description__c);
        System.assertEquals(true, taskUnderTest1.Display_on_PSR__c);
        System.assertEquals('TEST TASK COMMENT 1', taskUnderTest1.Comments__c);
    }
    
    static testMethod void refresh_Test() 
    {
        // --------------------------------------------------------------------
        // INITIALIZATION
        
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);        
        insert task;
        
        // --------------------------------------------------------------------
        // TESTING PROPER
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).expandActivity = true;
        controller.milestoneContentList.get(0).projectActivity.get(0).expandTask = true;
        controller.refresh();
        
        //Expand should still be true even the wrapper has been refresh
        System.assert(controller.milestoneContentList.get(0).expandActivity );
        System.assert(controller.milestoneContentList.get(0).projectActivity.get(0).expandTask);
        Test.StopTest();
    }
    
    static testMethod void DeleteMilestonePositive_Test()
    {
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity1;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        insert task;
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).toDelete = true;
        controller.deleteMilestone();
        
        system.assertEquals(0, controller.milestoneContentList.size());
        Test.StopTest();
    }
    
    static testMethod void deleteMilestoneNegative_Test()
    {
        //test if the system will fire an error message when trying to delete a milestone that is already complete
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity1.CDK_Assignee__c = user_cdkAssignee.Id;
        insert activity1;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        task.Actual_Start_Date__c = date.today();
        task.Actual_End_Date__c = date.today();
        task.Actual_Time_Spent__c = 1;
        task.CDK_Assignee__c = user_cdkAssignee.Id;
        insert task;
        
        CustomSettings__c custom = [select Users_Excluded_from_Business_Rules__c from CustomSettings__c];
        custom.Users_Excluded_from_Business_Rules__c = '';
        Update custom;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).toDelete = true;
        controller.deleteMilestone();
        
        Boolean isError = false;
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {              
                String[] arguments = new String[] { milestone.Description__c };   
                    if(msg.getDetail().contains( String.format(IMP_String_Utility.NO_BYPASS_TODELETE_MILESTONE, arguments) )  )
                {
                    isError = true;
                }
            }
        }
        system.assert(isError);
        Test.StopTest();
    }
    
    static testMethod void deleteMilestoneNegative2_Test()
    {
        Id testDataSubprojectId = subProject.Id;
        
        //Deleting 2 milestone records, 1 record will cause an error but the other record is deleted successfully in the database
        List<Project_Milestone__c> toInsertMilestoneList = new List<Project_Milestone__c>();
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testDataSubprojectId, GENERIC_MILESTONE_DESCRIPTION);
        toInsertMilestoneList.add(milestone);
        
        Project_Milestone__c milestone2 = IMP_TestFactory_Helper.buildMilestoneNonStandard(testDataSubprojectId, GENERIC_MILESTONE_DESCRIPTION);
        toInsertMilestoneList.add(milestone2);
        
        Insert toInsertMilestoneList;
        
        List<Project_Activity__c> toInsertActivityList = new List<Project_Activity__c>();
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity1.CDK_Assignee__c = user_cdkAssignee.Id;
        toInsertActivityList.add(activity1);
        
        Project_Activity__c activity2 = IMP_TestFactory_Helper.buildProjectActivity(milestone2.Id);       
        toInsertActivityList.add(activity2);
        
        Insert toInsertActivityList;
        
        List<Project_Task__c> toInsertTaskList = new List<Project_Task__c>();        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        task.Actual_Start_Date__c = date.today();
        task.Actual_End_Date__c = date.today();
        task.Actual_Time_Spent__c = 1;
        task.CDK_Assignee__c = user_cdkAssignee.Id;
        toInsertTaskList.add(task);
        
        Project_Task__c task2 = IMP_TestFactory_Helper.buildProjectTask(activity2.id);      
        toInsertTaskList.add(task2);
        
        Insert toInsertTaskList;
        
        CustomSettings__c custom = [select Users_Excluded_from_Business_Rules__c from CustomSettings__c];
        custom.Users_Excluded_from_Business_Rules__c = '';
        Update custom;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', testDataSubprojectId);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).toDelete = true;
        controller.milestoneContentList.get(1).toDelete = true;
        controller.deleteMilestone();
        
        Boolean isError = false;
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {    
                String[] arguments = new String[] { milestone.Description__c };  
                    if(msg.getDetail().contains( String.format(IMP_String_Utility.NO_BYPASS_TODELETE_MILESTONE, arguments) )  )
                {
                    isError = true;
                }
            }
        }
        system.assert(isError);
        system.assertEquals(1, controller.milestoneContentList.size());
        Test.StopTest();
    }
    
    static testMethod void deleteActivityPositive_Test()
    {
        Id testDataSubprojectId = subProject.Id;
        
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testDataSubprojectId, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity1;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        insert task;
        
        Project_Activity__c activity2 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity2;
        
        Project_Task__c task2 = IMP_TestFactory_Helper.buildProjectTask(activity2.id);
        insert task2;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', testDataSubprojectId);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).projectActivity.get(0).toDelete  = true;
        controller.deleteMilestone();
        
        system.assertEquals(1, controller.milestoneContentList.get(0).projectActivity.size());
        Test.StopTest();
    }
    
    
    static testMethod void deleteActivityNegative_Test()
    {
        Id testDataSubprojectId = subProject.Id;
        
        //test if the system will fire an error message when trying to delete all the activity in a milestone
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testDataSubprojectId, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity1;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        insert task;
        
        CustomSettings__c custom = [select Users_Excluded_from_Business_Rules__c from CustomSettings__c];
        custom.Users_Excluded_from_Business_Rules__c = '';
        Update custom;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', testDataSubprojectId);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).projectActivity.get(0).toDelete  = true;
        controller.deleteMilestone();
        
        Boolean isError = false;
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {              
                if(msg.getDetail().contains( IMP_String_Utility.MILESTONE_AT_LEAST_ONE_ACTIVITY ))
                {
                    isError = true;
                }
            }
        }
        system.assert(isError);
        Test.StopTest();
    }
    
    static testMethod void deleteActivityNegative2_Test()
    {
        //test if the system will fire an error message when trying to delete an activity that is already complete
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity1.CDK_Assignee__c = user_cdkAssignee.Id;
        activity1.Sequence__c = 2;
        insert activity1;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        task.Actual_Start_Date__c = date.today();
        task.Actual_End_Date__c = date.today();
        task.Actual_Time_Spent__c = 1;
        task.CDK_Assignee__c = user_cdkAssignee.Id;
        insert task;
        
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity.CDK_Assignee__c = user_cdkAssignee.Id;
        activity.Sequence__c = 1;
        insert activity;
        
        Project_Task__c task1 = IMP_TestFactory_Helper.buildProjectTask(activity.id);
        insert task1;
        
        CustomSettings__c custom = [select Users_Excluded_from_Business_Rules__c from CustomSettings__c];
        custom.Users_Excluded_from_Business_Rules__c = '';
        Update custom;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();       
        controller.milestoneContentList.get(0).projectActivity.get(1).toDelete  = true;
        controller.deleteMilestone();
        
        Boolean isError2 = false;
        String allerrors ='';
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            
            for(Apexpages.Message msg: errorMessagesList)
            {  
                //allerrors = allerrors + ' ' + msg.getDetail();
                String[] arguments = new String[] { activity1.Description__c };    
                    if(msg.getDetail().contains(  String.format(IMP_String_Utility.NO_BYPASS_TODELETE_ACTIVITY, arguments) ) )
                {
                    isError2 = true;
                }
            }
        }
        //system.assertEquals('', allerrors);
        System.assert(isError2);
        Test.StopTest();
    }
    
    static testMethod void deleteActivityNegative3_Test()
    {
        Id testDataSubprojectId = subProject.Id;
        Id testDataUser_cdkAssigneeId = user_cdkAssignee.Id;
        //Deleting 2 activity records, 1 record will cause an error but the other record is deleted successfully in the database
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testDataSubprojectId, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        List<Project_Activity__c> toInsertActivityList =  new List<Project_Activity__c>();       
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity1.CDK_Assignee__c = testDataUser_cdkAssigneeId;
        toInsertActivityList.add( activity1);
        
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);        
        toInsertActivityList.add(activity);
        
        Project_Activity__c activity2 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);        
        toInsertActivityList.add(activity2);
        
        Insert toInsertActivityList;
        
        List<Project_Task__c> toInsertTaskList = new List<Project_Task__c>();
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        task.Actual_Start_Date__c = date.today();
        task.Actual_End_Date__c = date.today();
        task.Actual_Time_Spent__c = 1;
        task.CDK_Assignee__c = testDataUser_cdkAssigneeId;
        toInsertTaskList.add(task);
        
        Project_Task__c task1 = IMP_TestFactory_Helper.buildProjectTask(activity.id);
        toInsertTaskList.add(task1);
        
        Project_Task__c task2 = IMP_TestFactory_Helper.buildProjectTask(activity2.id);
        toInsertTaskList.add(task2);
        
        Insert toInsertTaskList;
        
        CustomSettings__c custom = [select Users_Excluded_from_Business_Rules__c from CustomSettings__c];
        custom.Users_Excluded_from_Business_Rules__c = '';
        Update custom;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', testDataSubprojectId);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).projectActivity.get(1).toDelete  = true;
        controller.milestoneContentList.get(0).projectActivity.get(0).toDelete  = true;
        controller.deleteMilestone();
        
        Boolean isError2 = false;
        String allerrors ='';
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            
            for(Apexpages.Message msg: errorMessagesList)
            {  
                String[] arguments = new String[] { activity1.Description__c };     
                    
                    if(msg.getDetail().contains(   String.format(IMP_String_Utility.NO_BYPASS_TODELETE_ACTIVITY, arguments) )  )
                {
                    isError2 = true;
                }
            }
        }
        //system.assertEquals('', allerrors);
        System.assert(isError2);
        Test.StopTest();
    }
    
    static testMethod void deleteTaskPositive_Test()
    {
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity1;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        insert task;
        
        Project_Task__c task2 = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        insert task2;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).toDelete  = true;
        controller.deleteMilestone();
        
        system.assertEquals(1, controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.size());
        Test.StopTest();
    }
    
    static testMethod void deleteTaskNegative_Test()
    {
        //test if the system will fire an error message when trying to delete all the task in an activity
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity1;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        insert task;
        
        CustomSettings__c custom = [select Users_Excluded_from_Business_Rules__c from CustomSettings__c];
        custom.Users_Excluded_from_Business_Rules__c = '';
        Update custom;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).toDelete  = true;
        controller.deleteMilestone();
        
        Boolean isError2 = false;
        
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {   
                
                if(msg.getDetail().contains( 'Activity should have at least 1 Task' ))
                {
                    isError2 = true;
                }
            }
        }
        
        System.assert(isError2);
        Test.StopTest();
    }
    
    static testMethod void deleteTaskNegative2_Test()
    {
        //test if the system will fire an error message when trying to delete a task that is already complete
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity1.CDK_Assignee__c = user_cdkAssignee.Id;
        insert activity1;
        
        Project_Task__c task0 = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        task0.Sequence__c = 1;
        insert task0;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        task.Actual_Start_Date__c = date.today();
        task.Actual_End_Date__c = date.today();
        task.Actual_Time_Spent__c = 1;
        task.CDK_Assignee__c = user_cdkAssignee.Id;
        task.Sequence__c = 2;
        insert task;
        
        CustomSettings__c custom = [select Users_Excluded_from_Business_Rules__c from CustomSettings__c];
        custom.Users_Excluded_from_Business_Rules__c = '';
        Update custom;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(1).toDelete  = true;
        controller.deleteMilestone();
        
        Boolean isError2 = false;
        
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {   
                String[] arguments = new String[] { task.Description__c };       
                    if(msg.getDetail().contains( String.format(IMP_String_Utility.NO_BYPASS_TODELETE_TASK, arguments) )  )
                {
                    isError2 = true;
                }
            }
        }
        
        System.assert(isError2);
        Test.StopTest();
    }
    
    static testMethod void deleteTaskNegative3_Test()
    {
        //Deleting 2 task records, 1 record will cause an error but the other record is deleted successfully in the database
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity1.CDK_Assignee__c = user_cdkAssignee.Id;
        insert activity1;
        
        Project_Task__c task0 = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        insert task0;
        
        Project_Task__c task1 = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        insert task1;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        task.Actual_Start_Date__c = date.today();
        task.Actual_End_Date__c = date.today();
        task.Actual_Time_Spent__c = 1;
        task.CDK_Assignee__c = user_cdkAssignee.Id;
        insert task;
        
        CustomSettings__c custom = [select Users_Excluded_from_Business_Rules__c from CustomSettings__c];
        custom.Users_Excluded_from_Business_Rules__c = '';
        Update custom;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(1).toDelete  = true;
        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(2).toDelete  = true;
        controller.deleteMilestone();
        
        Boolean isError2 = false;
        
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {   
                String[] arguments = new String[] { task.Description__c };
                    if(msg.getDetail().contains( String.format(IMP_String_Utility.NO_BYPASS_TODELETE_TASK, arguments) )  )
                {
                    isError2 = true;
                }
            }
        }
        
        System.assert(isError2);
        system.assertEquals(2, controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.size());
        Test.StopTest();
    }
    
    static testMethod void updatePSR_Test()
    {
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity1.CDK_Assignee__c = user_cdkAssignee.Id;
        insert activity1;
        
        Project_Task__c task0 = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        insert task0;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.toDisplay = true;
        controller.allRecords = true;
        controller.includeTasksForPSR = true;
        controller.updateAllDisplayPSR();        
        
        Project_Milestone__c updateMilestone = [Select Display_on_PSR__c from Project_Milestone__c where id =: milestone.id];
        Project_Activity__c updateActivity = [Select Display_on_PSR__c from Project_Activity__c where id =: activity1.id];
        Project_Task__c updateTask = [Select Display_on_PSR__c from Project_Task__c where id =: task0.id];
        
        system.assert(updateMilestone.Display_on_PSR__c);
        system.assert(updateActivity.Display_on_PSR__c);
        system.assert(updateTask.Display_on_PSR__c);
        
        controller.toDisplay = false;
        controller.updateAllDisplayPSR();
        Test.StopTest();
        
        Project_Milestone__c updateMilestone2 = [Select Display_on_PSR__c from Project_Milestone__c where id =: milestone.id];
        Project_Activity__c updateActivity2 = [Select Display_on_PSR__c from Project_Activity__c where id =: activity1.id];
        Project_Task__c updateTask2 = [Select Display_on_PSR__c from Project_Task__c where id =: task0.id];
        
        system.assert(!updateMilestone2.Display_on_PSR__c);
        system.assert(!updateActivity2.Display_on_PSR__c);
        system.assert(!updateTask2.Display_on_PSR__c);
    }
    
    static testMethod void deleteRMSRecordPositive_Test()
    {
        IMP_ProfilesToByPass__c profile1 = IMP_TestFactory_Helper.buildProfilesToByPass();
        profile1.Name = 'ByPass_RMS_Record_Delete';
        profile1.Profile__c =  [select name from profile where id =: userinfo.getProfileId()].name;
        insert profile1;
        
        CMF_Info__c cmfInfo_RMS = new CMF_Info__c();
        cmfInfo_RMS.Account__c = account.id;
        cmfInfo_RMS.Name = 'WITH SHIP CMF | USING ACCOUNT';
        cmfInfo_RMS.Ship_CMF__c = '00000001';
        cmfInfo_RMS.Status__c = 'A';
        insert cmfInfo_RMS;
        
        SubProjectSite__c siteRMS = new SubProjectSite__c();
        siteRMS.SubProject__c = subProject.Id;
        siteRMS.CMF_Name__c = cmfInfo_RMS.Id;
        insert siteRMS;
        
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        milestone.RMS_Owned_Flag__c = true;
        milestone.Site__c = siteRMS.id;
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity1.RMS_Owned_Flag__c = true;
        insert activity1;      
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        task.RMS_Owned_Flag__c = true;
        insert task;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        controller.milestoneContentList.get(0).toDelete  = true;
        controller.deleteMilestone();
        
        system.assertEquals(0, controller.milestoneContentList.size());
        Test.StopTest();
    }
    
    static testMethod void deleteRMSRecordNegative_Test()
    {
        //Test if the milestone view page will throw an error and prevent the NON RMS Integration user or NON Admin user in deleting rms owned record
        
        createCustomSettings();
        
        User nonRMSAdmin = IMP_TestFactory_Helper.buildUser();
        nonRMSAdmin.ProfileId = [select id from profile where name = 'ADPDS - Implementation - PM'].id;
        insert nonRMSAdmin;
        
        CMF_Info__c cmfInfo_RMS = new CMF_Info__c();
        cmfInfo_RMS.Account__c = account.id;
        cmfInfo_RMS.Name = 'WITH SHIP CMF | USING ACCOUNT';
        cmfInfo_RMS.Ship_CMF__c = '00000001';
        cmfInfo_RMS.Status__c = 'A';
        insert cmfInfo_RMS;
        
        SubProjectSite__c siteRMS = new SubProjectSite__c();
        siteRMS.SubProject__c = subProject.Id;
        siteRMS.CMF_Name__c = cmfInfo_RMS.Id;
        insert siteRMS;
        
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        milestone.RMS_Owned_Flag__c = true;
        milestone.Site__c = siteRMS.id;
        insert milestone;
        
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity1.RMS_Owned_Flag__c = true;
        insert activity1;      
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.id);
        task.RMS_Owned_Flag__c = true;
        
        Test.StartTest();
        IMP_MilestoneView_Controller controller;
        System.runAs(nonRMSAdmin) 
        {  
            insert task;            
            ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
            controller = new IMP_MilestoneView_Controller();
            controller.milestoneContentList.get(0).toDelete  = true;
            controller.deleteMilestone();
        }
        
        Boolean isErrorMilestone = false;
        Boolean isErrorActivity = false;
        Boolean isErrorTask = false;
        
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {   
                String[] arguments = new String[] { milestone.Description__c };
                    String[] argumentsActivity = new String[] { activity1.Description__c };
                        String[] argumentsTask = new String[] { task.Description__c };
                            if(msg.getDetail().contains( String.format(IMP_String_Utility.NO_BYPASS_TODELETE_RMSMILESTONE, arguments) )  )
                        {
                            isErrorMilestone = true;
                        }
                if(msg.getDetail().contains( String.format(IMP_String_Utility.NO_BYPASS_TODELETE_RMSACTIVITY, argumentsActivity) )  )
                {
                    isErrorActivity = true;
                }
                if(msg.getDetail().contains( String.format(IMP_String_Utility.NO_BYPASS_TODELETE_RMSTASK, argumentsTask) )  )
                {
                    isErrorTask = true;
                } 
            }
        }
        
        System.assert(isErrorMilestone);
        System.assert(isErrorActivity);        
        System.assert(isErrorTask);       
        system.assertEquals(1, controller.milestoneContentList.size());
        Test.StopTest();
    }
    
    static testMethod void testPagination()
    {
        //test if the pagination of the view page load the correct size and data        
        List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
        for(Integer cnt=1;cnt<=5;cnt++)
        {
            Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);            
            milestone.Description__c = 'milestone ' + cnt;   
            milestone.Sort_Sequence__c = cnt;
            milestoneList.add(milestone);
        }
        insert milestoneList;
        List<Project_Activity__c> activityList = new List<Project_Activity__c>();
        for(Project_Milestone__c miles : milestoneList)
        {
            for (Integer cnt=1;cnt<=2;cnt++)
            {
                Project_Activity__c act = new Project_Activity__c();
                act.Milestone__c = miles.Id;
                act.Description__c = 'Activity ' + miles.Id + ' - ' + cnt;
                activityList.add(act); 
            }            
        }
        insert activityList;
        List<Project_Task__c> taskList = new List<Project_Task__c>();
        for (Project_Activity__c act: activityList )
        {
            for (Integer cnt=1;cnt<=2;cnt++)
            {
                Project_Task__c tsk = new Project_Task__c();
                tsk.Description__c = 'Task ' + act.Id + ' - ' + cnt;
                tsk.Project_Activity__c = act.Id;
                tsk.Expected_Time_Spent__c = 1;
                taskList.add(tsk);
            }            
        }
        insert taskList;
        CustomSettings__c custom = [select Max_Total_Rec_Count_Threshold__c from CustomSettings__c];
        custom.Max_Total_Rec_Count_Threshold__c = 14;
        Update custom;
        
        test.startTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        //test the size of the record in the initial load of the page
        //expected to be 2 because the Max_Total_Rec_Count_Threshold__c is set to 14 and every milestone has 6 records
        system.assertEquals(2, controller.milestoneContentList.size());
        //test the last page function, expect to be 1 since the total records are 5 and the limit per page is 2 records
        controller.gotoLastPage();
        system.assertEquals(1, controller.milestoneContentList.size());
        system.assertEquals('milestone 5', controller.milestoneContentList.get(0).projectMilestone.description__c);
        //test the first page function, expect to go back to the previous size
        controller.gotoFirstPage();
        system.assertEquals(2, controller.milestoneContentList.size());
        system.assertEquals('milestone 1', controller.milestoneContentList.get(0).projectMilestone.description__c);
        //test the next page function, expect to be 2 since the total records are 5 and the limit per page is 2 records and the next page is not the last page
        controller.gotoNextPage();
        system.assertEquals(2, controller.milestoneContentList.size());
        system.assertEquals('milestone 3', controller.milestoneContentList.get(0).projectMilestone.description__c);
        //test the previous page function,  expect to go back to the previous size or go back to the 1st page
        controller.gotoPrevPage();
        system.assertEquals(2, controller.milestoneContentList.size());
        system.assertEquals('milestone 2', controller.milestoneContentList.get(1).projectMilestone.description__c);
        
        test.stopTest();
    }
    
    static testMethod void testPaginationWhileDeleting()
    {
        //test the behavior of pagination when a record is deleted
        List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
        for(Integer cnt=1;cnt<=5;cnt++)
        {
            Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);            
            milestone.Description__c = 'milestone ' + cnt;   
            milestone.Sort_Sequence__c = cnt;
            milestoneList.add(milestone);
        }
        insert milestoneList;
        List<Project_Activity__c> activityList = new List<Project_Activity__c>();
        for(Project_Milestone__c miles : milestoneList)
        {
            for (Integer cnt=1;cnt<=2;cnt++)
            {
                Project_Activity__c act = new Project_Activity__c();
                act.Milestone__c = miles.Id;
                act.Description__c = 'Activity ' + miles.Id + ' - ' + cnt;
                activityList.add(act); 
            }            
        }
        insert activityList;
        List<Project_Task__c> taskList = new List<Project_Task__c>();
        for (Project_Activity__c act: activityList )
        {
            for (Integer cnt=1;cnt<=2;cnt++)
            {
                Project_Task__c tsk = new Project_Task__c();
                tsk.Description__c = 'Task ' + act.Id + ' - ' + cnt;
                tsk.Project_Activity__c = act.Id;
                tsk.Expected_Time_Spent__c = 1;
                taskList.add(tsk);
            }            
        }
        insert taskList;
        
        CustomSettings__c custom = [select Max_Total_Rec_Count_Threshold__c from CustomSettings__c];
        custom.Max_Total_Rec_Count_Threshold__c = 14;
        Update custom;
        
        test.startTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        
        //test the last page function, expect to be 1 since the total records are 5 and the limit per page is 2 records
        controller.gotoLastPage();
        system.assertEquals(1, controller.milestoneContentList.size());
        system.assertEquals('milestone 5', controller.milestoneContentList.get(0).projectMilestone.description__c);
        //select and delete the last record
        controller.milestoneContentList.get(0).toDelete = true;
        controller.deleteMilestone();
        //expect the current page will be the previous 2nd page
        system.assertEquals(2, controller.milestoneContentList.size());
        system.assertEquals('milestone 3', controller.milestoneContentList.get(0).projectMilestone.description__c);
        
        //test again the last page function if the record is still the same
        controller.gotoLastPage();
        system.assertEquals(2, controller.milestoneContentList.size());
        system.assertEquals('milestone 3', controller.milestoneContentList.get(0).projectMilestone.description__c);
        
        //test the behavior of pagination if the 1st record will be deleted
        controller.gotoFirstPage();
        system.assertEquals(2, controller.milestoneContentList.size());
        controller.milestoneContentList.get(0).toDelete = true;
        controller.deleteMilestone();
        //expect the previous 2nd record will now be the 1st
        system.assertEquals('milestone 2', controller.milestoneContentList.get(0).projectMilestone.description__c);
        //exect the size will stay 2 because the 3rd record that is on the 2nd page will move to the first page        
        system.assertEquals(2, controller.milestoneContentList.size());
        test.stopTest();
    }
    
    static testMethod void overideThresholdCountForPagination()
    {
         //test if the pagination of the view page load the correct size and data        
        List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
        for(Integer cnt=1;cnt<=5;cnt++)
        {
            Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);            
            milestone.Description__c = 'milestone ' + cnt;   
            milestone.Sort_Sequence__c = cnt;
            milestoneList.add(milestone);
        }
        insert milestoneList;
        List<Project_Activity__c> activityList = new List<Project_Activity__c>();
        for(Project_Milestone__c miles : milestoneList)
        {
            for (Integer cnt=1;cnt<=2;cnt++)
            {
                Project_Activity__c act = new Project_Activity__c();
                act.Milestone__c = miles.Id;
                act.Description__c = 'Activity ' + miles.Id + ' - ' + cnt;
                activityList.add(act); 
            }            
        }
        insert activityList;
        List<Project_Task__c> taskList = new List<Project_Task__c>();
        for (Project_Activity__c act: activityList )
        {
            for (Integer cnt=1;cnt<=2;cnt++)
            {
                Project_Task__c tsk = new Project_Task__c();
                tsk.Description__c = 'Task ' + act.Id + ' - ' + cnt;
                tsk.Project_Activity__c = act.Id;
                tsk.Expected_Time_Spent__c = 1;
                taskList.add(tsk);
            }            
        }
        insert taskList;
        CustomSettings__c custom = [select Max_Total_Rec_Count_Threshold__c from CustomSettings__c];
        custom.Max_Total_Rec_Count_Threshold__c = 14;
        Update custom;
        
        Subproject__c sub = subProject;
        sub.Max_Tot_Rec_Threshold_Override__c = 7;
        Update sub;
        
        test.startTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_MilestoneView_Controller controller = new IMP_MilestoneView_Controller();
        //test the size of the record in the initial load of the page
        //expected to be 7 not 14 because we overide the Max_Total_Rec_Count_Threshold__c 
        system.assertEquals(7, controller.recordLimit);
        //previously the milestone count would be 2 because the record limit is set to 14 and for each milestone it contains 7 records
        //now expected to be 1 because we overide the Max_Total_Rec_Count_Threshold__c 
        system.assertEquals(1, controller.milestoneContentList.size());
        //test the last page function, expect to be 1 since the total records are 5 and the limit per page is 1 records
        controller.gotoLastPage();
        system.assertEquals(1, controller.milestoneContentList.size());
        system.assertEquals('milestone 5', controller.milestoneContentList.get(0).projectMilestone.description__c);
        test.stopTest();
    }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();        
        insert profile;
    }
    
    public static Project_Task__c createTask( Id activityId, String name, String department, String role)
    {
        Project_Task__c pt = IMP_TestFactory_Helper.buildProjectTask(activityId);
        
        pt.CDK_Assignee__c = user_cdkAssignee.Id;
        pt.CDK_Assignee_Role__c = role;
        pt.Client_Assignee__c = contact_clientAssignee.Id;      
        pt.Description__c = 'TEST TASK ' + name ;
        pt.Display_on_PSR__c = true;  
        pt.Comments__c = 'TEST TASK COMMENT ' + name;
        pt.Actual_Time_Spent__c = 1;
        pt.Expected_Time_Spent__c = 1;
        
        return pt;
    }
}