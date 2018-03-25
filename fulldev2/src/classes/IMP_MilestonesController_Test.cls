/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: IMP_Milestones_Controller test class
History
09/17/14    Michael Lasala      Created
11/19/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
12/08/14    Samuel Oberes       Major additions on test methods and coverage
01/03/15    Karl Simon          Replaced CMF_Info and SubprojectSite record generation and insertion logic into the siteValueOption_Test,
updateMilestone_Test, fieldupdateFunction_Test, and saveAndCloseFunction_Test methods to instead utilize the updated versions in the Test Factory class.
------------------------------------------------------------*/
@isTest
public class IMP_MilestonesController_Test {
    
    private static final String GENERIC_MILESTONE_DESCRIPTION = 'TEST MILESTONE DESCRIPTION';
    
    private static final Project__c project { get; set; }
    private static final SubProject__c subProject { get; set; }
    private static final Account account { get; set; }
    private static final User user_cdkAssignee { get; set; }
    private static final Contact contact_clientAssignee { get; set; }
    
    static 
    {
        project = IMP_TestFactory_Helper.buildProject(0);
        insert project;
        
        subProject = IMP_TestFactory_Helper.buildSubProject(project.Id);
        insert subProject;
        
        account = IMP_TestFactory_Helper.buildAccount();
        insert account;
        
        user_cdkAssignee = IMP_TestFactory_Helper.buildUser();
        insert user_cdkAssignee;
        
        contact_clientAssignee = IMP_TestFactory_Helper.buildContact(account.Id);
        insert contact_clientAssignee;
    }
    
    static testMethod void constructorNoRecords_Test()
    {
        // --------------------------------------------------------------------
        // TESTING PROPER
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_Milestones_Controller controller = new IMP_Milestones_Controller();
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
        task.Terminal_Task__c = true;
        insert task;
        
        IMP_TestFactory_Helper.buildCustomSettings();
        // --------------------------------------------------------------------
        // TESTING PROPER
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        
        IMP_Milestones_Controller controller = new IMP_Milestones_Controller();
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
        
        Date MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE = Date.newInstance(2014, 1, 1);
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
        String TASK_1_DESCRIPTION = 'TEST TASK 1 TERMINAL';        
        
        
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
        activity1Terminal.Planned_Start_Date__c = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 2; //Date.newInstance(2014, 1, 3);
        activity1Terminal.Planned_End_Date__c   = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 3; //Date.newInstance(2014, 1, 4);    
        activity1Terminal.Comments__c = ACTIVITY_1_COMMENTS;
        activity1Terminal.Terminal_Activity__c = true;
        insert activity1Terminal;
        
        Project_Task__c act1_task1 = createTask( activity1Terminal.Id, '1',  TASK_1_DEPARTMENT, ' TERMINAL', TASK_1_CDKASSIGNEEROLE);
        insert act1_task1;
        
        Project_Task__c act1_task2 = createTask( activity1Terminal.Id, '2',  TASK_1_DEPARTMENT, '', TASK_1_CDKASSIGNEEROLE);
        insert act1_task2;
        // --------------------------------------------------------------------
        // TESTING PROPER
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_Milestones_Controller controller = new IMP_Milestones_Controller();
        
        List<Project_Milestone__c> projectMList =  controller.retrieveMilestoneRecords();
        controller.resetWrapperDataAndExtensionField(projectMList);
        Test.StopTest();
        
        // >>> milestone tests
        
        // the milestone created earlier should now exist inside the milestoneContentList MilestoneWrapper list
        Project_Milestone__c milestoneUnderTest = controller.milestoneContentList.get(0).projectMilestone;
        
        // expect 1 milestone to be fetched
        System.assertEquals(1, controller.milestoneContentList.size());
        
        // expect 3 activities to be fetched connected under the milestone
        System.assertEquals(1, controller.milestoneContentList.get(0).projectActivity.size());
        
        // expect: milestone's planned start date == minimum planned start date among the child activities
        System.assertEquals(MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 2    , milestoneUnderTest.Planned_Start_Date__c);
        
        // expect: milestone's planned end date == maximum planned start date among the child activities
        System.assertEquals(MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 3, milestoneUnderTest.Planned_End_Date__c);
        
        System.assertEquals(MILESTONE_COMMENT_LITERAL,     milestoneUnderTest.Comments__c);
        System.assertEquals(MILESTONE_DESCRIPTION_LITERAL, milestoneUnderTest.Description__c);
        //System.assertEquals(MILESTONE_STATUS_LITERAL,      milestoneUnderTest.Status__c);
        
        // >>> project activity tests
        
        // the second activity created earlier should now exist inside the milestoneContentList ActivityWrapper list
        Project_Activity__c activityUnderTest1 = controller.milestoneContentList.get(0).projectActivity.get(0).activity;
        System.assertEquals(MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 2, activityUnderTest1.Planned_Start_Date__c);
        System.assertEquals(MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 3, activityUnderTest1.Planned_End_Date__c);
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
        Project_Task__c taskUnderTest1 = controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0);
        
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
        task.Terminal_Task__c = true;
        insert task;
        
        // --------------------------------------------------------------------
        // TESTING PROPER
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_Milestones_Controller controller = new IMP_Milestones_Controller();
        controller.milestoneContentList.get(0).expandActivity = true;
        controller.milestoneContentList.get(0).projectActivity.get(0).expandTask = true;
        controller.refresh();
        
        //Expand should still be true even the wrapper has been refresh
        System.assert(controller.milestoneContentList.get(0).expandActivity );
        System.assert(controller.milestoneContentList.get(0).projectActivity.get(0).expandTask);
        Test.StopTest();
    }
    
    static testMethod void milestoneSizeToEdit_Test()
    {
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);
        insert task;
        
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_TestFactory_Helper.buildCustomSettings();
        
        Test.StartTest();
        
        IMP_Milestones_Controller controller = new IMP_Milestones_Controller();
        
        Test.StopTest();
        
        CustomSettings__c cs = CustomSettings__c.getInstance();
        system.assertEquals(controller.milestoneSizeToEdit, cs.Max_Milestone_Threshold__c);
     }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
    
    public static Project_Task__c createTask( Id activityId, String name, String department, String terminal, String role)
    {
        Project_Task__c pt = IMP_TestFactory_Helper.buildProjectTask(activityId);
        
        pt.CDK_Assignee__c = user_cdkAssignee.Id;
        pt.CDK_Assignee_Role__c = role;
        pt.Client_Assignee__c = contact_clientAssignee.Id;      
        pt.Description__c = 'TEST TASK ' + name + terminal;
        pt.Display_on_PSR__c = true;  
        pt.Comments__c = 'TEST TASK COMMENT ' + name;
        pt.Actual_Time_Spent__c = 1;
        pt.Expected_Time_Spent__c = 1;
        if (terminal != '') 
        {
            pt.Terminal_Task__c = true;
        }        
        return pt;
    }
    
}