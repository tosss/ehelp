/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test Class for IMP_MilestoneEdit_Controller
History
04/10/15     Rey Austral      Created
04/14/15     Samuel Oberes    Updated cloneTaskRecord_Test: Custom setting now uses multiple comma delimited names
05/04/15     Samuel Oberes    Fixed cloneTaskRecord_Test by adding settings under IMP_ProjectLinksUrls__c
------------------------------------------------------------*/
@isTest
public class IMP_MilestoneEdit_Controller_Test 
{
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
    
    //static testMethod void siteValueOption_Test() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    createCustomSettings();
        
    //    String NAME_LITERAL_MP  = 'Manny Pacquiao';
        
    //    Account accountWithName = IMP_TestFactory_Helper.buildAccount();
    //    accountWithName.Name = NAME_LITERAL_MP;
    //    insert accountWithName;
        
    //    SubProject__c subProjectWithDealerGroup = IMP_TestFactory_Helper.buildSubProject(project.Id);
    //    subProjectWithDealerGroup.Dealer_Group__c = accountWithName.Id;
    //    insert subProjectWithDealerGroup;
        
    //    CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(accountWithName.Id);
    //    insert testCMFInfo;
        
    //    SubProjectSite__c subProjectSite1 = IMP_TestFactory_Helper.buildSubProjectSite(accountWithName.Id, subProjectWithDealerGroup.Id, testCMFInfo.Id);        
    //    insert subProjectSite1;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProjectWithDealerGroup.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProjectWithDealerGroup.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
    //    controller.siteValueOption();
    //    controller.siteOptionsList.sort();
        
    //    // size is 2 --> '--None--' and the new site
    //    System.assertEquals(2, controller.siteOptionsList.size());
        
    //    // get the value of index 1 instead of index 0, because index 0 contains nothing (label = '--None--' and value = '')
    //    System.assertEquals(subProjectSite1.Id, controller.siteOptionsList.get(1).getValue());
        
    //    Test.stopTest();
    //}
    
    //static testMethod void externalIds_Test() 
    //{
    //    Test.StartTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Laser_Artwork_Order__c laserArtworkOrder = IMP_TestFactory_Helper.buildLaserArtworkOrder(contact_clientAssignee.Id);
    //    laserArtworkOrder.A_P_Check_Order_Placed__c          = Date.today() - 5;
    //    laserArtworkOrder.A_P_Check_Order_Actual_End_Date__c = Date.today() - 3;
    //    insert laserArtworkOrder;
        
    //    Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
    //    Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = resSchema.getRecordTypeInfosByName();
        
    //    SubProject_External_Reference__c subprojectExternalReference = IMP_TestFactory_Helper.buildSubProjectExternalReference(laserArtworkOrder.Id, subProject.Id, project.Id);
    //    subprojectExternalReference.RecordTypeId = recordTypeInfoMap.get('LAO').getRecordTypeId();
    //    insert subprojectExternalReference;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    // scenario 1 -- IMP_ExternalReferenceRecordTypes__c has no entry
    //    controller.ExternalIds();
        
    //    // size is 1 because it includes '--None--'
    //    System.assertEquals(1, controller.exIdList.size());
        
    //    // scenario 2 -- IMP_ExternalReferenceRecordTypes__c has an entry
    //    IMP_ExternalReferenceRecordTypes__c externalReferenceRecType = IMP_TestFactory_Helper.buildExternalReferenceRecordTypeItem(IMP_TestFactory_Helper.Enum_ExternalReferenceRecordTypes.LAO);
    //    insert externalReferenceRecType;
        
    //    controller.ExternalIds();
        
    //    // size is 2 --> '--None--' and the new external name
    //    System.assertEquals(2, controller.exIdList.size());
        
    //    Test.StopTest();
    //}
    
    //static testMethod void updateMilestone_Test() 
    //{
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    createCustomSettings();
        
    //    Date MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE = Date.newInstance(2014, 1, 1);
    //    String CONCAT_MILESTONE_ID = '';
    //    String MILESTONE_COMMENT_LITERAL = 'TEST MILESTONE COMMENT';
    //    String MILESTONE_DESCRIPTION_LITERAL = 'TEST MILESTONE DESCRIPTION';
    //    String MILESTONE_STATUS_LITERAL = 'Caution';
    //    Date ACTIVITY_ACTUAL_START_DATE = Date.newInstance(2014, 11, 4);
    //    Date ACTIVITY_ACTUAL_END_DATE   = Date.Today();
    //    String ACTIVITY_DESCRIPTION = 'TERMINAL ACTIVITY';
    //    String TASK_DESCRIPTION = 'TERMINAL TASK';
    //    Project_Milestone__c expectedMilestone;
    //    Project_Activity__c expectedActivity;
    //    Project_Task__c expectedTask;
    //    String description;
    //    String siteOptionValue;
        
    //    SubProject__c subProjectWithDealerGroup = IMP_TestFactory_Helper.buildSubProject(project.Id);
    //    subProjectWithDealerGroup.Dealer_Group__c = account.Id;
    //    insert subProjectWithDealerGroup;        
        
    //    CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(account.Id);
    //    insert testCMFInfo;
        
    //    SubProjectSite__c subProjectSite1 = IMP_TestFactory_Helper.buildSubProjectSite(account.Id, subProjectWithDealerGroup.Id, testCMFInfo.Id);
    //    insert subProjectSite1;
        
    //    // create 2 milestones, 1 activity each
    //    List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
    //    List<Project_Activity__c> activityList = new List<Project_Activity__c>();
    //    List<Project_Task__c> taskList = new List<Project_Task__c>();
        
    //    for (Integer ctr = 0; ctr < 2; ctr++) 
    //    {
    //        Project_Milestone__c milestoneNonGeneric = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProjectWithDealerGroup.Id, MILESTONE_DESCRIPTION_LITERAL + ' ' + ctr);
    //        milestoneNonGeneric.Comments__c = MILESTONE_COMMENT_LITERAL + ' ' + ctr;
    //        milestoneList.add(milestoneNonGeneric);
    //    }
    //    insert milestoneList;
        
    //    for (Project_Milestone__c miles: milestoneList) 
    //    {
    //        CONCAT_MILESTONE_ID = CONCAT_MILESTONE_ID +  ',' + miles.id;
    //        Project_Activity__c activityTerminal = IMP_TestFactory_Helper.buildProjectActivity(miles.Id);
    //        activityTerminal.CDK_Assignee__c = user_cdkAssignee.Id;
    //        activityTerminal.Description__c = ACTIVITY_DESCRIPTION;
    //        activityTerminal.Planned_Start_Date__c = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 2; //Date.newInstance(2014, 1, 3);
    //        activityTerminal.Planned_End_Date__c   = ACTIVITY_ACTUAL_END_DATE; //Date.newInstance(2014, 1, 4);
    //        activityTerminal.Terminal_Activity__c = true;
    //        activityList.add(activityTerminal);
    //    }   
    //    insert activityList;

    //    for (Project_Activity__c act: activityList) 
    //    {
    //        Project_Task__c taskTerminal = IMP_TestFactory_Helper.buildProjectTask(act.Id);
    //        taskTerminal.Actual_Start_Date__c = ACTIVITY_ACTUAL_START_DATE;
    //        taskTerminal.Actual_End_Date__c   = ACTIVITY_ACTUAL_END_DATE;
    //        taskTerminal.CDK_Assignee__c = user_cdkAssignee.Id;
    //        taskTerminal.Description__c = TASK_DESCRIPTION;
    //        taskTerminal.Planned_Start_Date__c = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 2; //Date.newInstance(2014, 1, 3);
    //        taskTerminal.Planned_End_Date__c   = ACTIVITY_ACTUAL_END_DATE; //Date.newInstance(2014, 1, 4);
    //        taskTerminal.Terminal_Task__c = true;
    //        taskTerminal.Actual_Time_Spent__c = 1;
    //        taskTerminal.Reason__c = 'None';
    //        taskList.add(taskTerminal);
            
    //    }
    //    insert taskList;
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
    //    Test.startTest();
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProjectWithDealerGroup.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', CONCAT_MILESTONE_ID);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    expectedMilestone = controller.milestoneContentList.get(0).projectMilestone;
    //    expectedMilestone.Description__c = MILESTONE_DESCRIPTION_LITERAL + '_EDITED';
    //    controller.milestoneContentList.get(0).isEdited = true;
        
    //    expectedActivity = controller.milestoneContentList.get(1).projectActivity.get(0).activity;
    //    expectedActivity.Description__c = ACTIVITY_DESCRIPTION + '_EDITED';
    //    controller.milestoneContentList.get(1).projectActivity.get(0).isEdited = true;
        
    //    expectedTask  = controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task;
    //    expectedTask.Description__c = TASK_DESCRIPTION + '_EDITED';
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).isEdited = true;
        
    //    controller.milestoneId = controller.milestoneContentList.get(1).projectMilestone.Id;
    //    controller.createNewActivity();
    //    controller.milestoneContentList.get(1).projectActivity.get(0).activity.Description__c = 'EDITED';
    //    controller.milestoneContentList.get(1).projectActivity.get(0).projectTask.get(0).isEdited = true;
    //    controller.milestoneContentList.get(1).projectActivity.get(0).projectTask.get(0).task.Terminal_Task__c = true;
        
    //    controller.inlineSave();
        
    //    Test.stopTest();
        
    //    Project_Milestone__c actualAndUpdatedMilestone = [SELECT Id, Description__c FROM Project_Milestone__c WHERE Description__c = :(MILESTONE_DESCRIPTION_LITERAL + '_EDITED')];
    //    Project_Activity__c  actualAndUpdatedActiviy   = [SELECT Id, Description__c FROM Project_Activity__c  WHERE Description__c = :(ACTIVITY_DESCRIPTION + '_EDITED')];
    //    Project_Task__c  actualAndUpdatedTask   = [SELECT Id, Description__c FROM Project_Task__c  WHERE Description__c = :(TASK_DESCRIPTION + '_EDITED')];
        
    //    // expect the milestone and activity to get updated
    //    System.assertEquals(expectedMilestone.Id, actualAndUpdatedMilestone.Id);
    //    System.assertEquals(expectedActivity.Id, actualAndUpdatedActiviy.Id);
    //    System.assertEquals(expectedTask.Id, actualAndUpdatedTask.Id);
        
    //}
    
    //static testMethod void updateMilestoneWithError_Test() 
    //{        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    createCustomSettings();
        
    //    Date MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE = Date.newInstance(2014, 1, 1);
    //    String CONCAT_MILESTONE_ID = '';
    //    String MILESTONE_COMMENT_LITERAL = 'TEST MILESTONE COMMENT';
    //    String MILESTONE_DESCRIPTION_LITERAL = 'TEST MILESTONE DESCRIPTION';
    //    String MILESTONE_STATUS_LITERAL = 'Caution';
    //    Date ACTIVITY_ACTUAL_START_DATE = Date.newInstance(2014, 11, 4);
    //    Date ACTIVITY_ACTUAL_END_DATE   = Date.Today();
    //    String ACTIVITY_DESCRIPTION = 'TERMINAL ACTIVITY';
    //    String TASK_DESCRIPTION = 'TERMINAL TASK';
    //    Project_Milestone__c expectedMilestone;
    //    Project_Activity__c expectedActivity;
    //    Project_Task__c expectedTask;
    //    String description;
    //    String siteOptionValue;
        
    //    SubProject__c subProjectWithDealerGroup = IMP_TestFactory_Helper.buildSubProject(project.Id);
    //    subProjectWithDealerGroup.Dealer_Group__c = account.Id;
    //    insert subProjectWithDealerGroup;        
        
    //    CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(account.Id);
    //    insert testCMFInfo;
        
    //    SubProjectSite__c subProjectSite1 = IMP_TestFactory_Helper.buildSubProjectSite(account.Id, subProjectWithDealerGroup.Id, testCMFInfo.Id);      
    //    insert subProjectSite1;
        
    //    // create 2 milestones, 1 activity each
    //    List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
    //    List<Project_Activity__c> activityList = new List<Project_Activity__c>();
    //    List<Project_Task__c> taskList = new List<Project_Task__c>();
        
    //    for (Integer ctr = 0; ctr < 2; ctr++) 
    //    {
    //        Project_Milestone__c milestoneNonGeneric = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProjectWithDealerGroup.Id, MILESTONE_DESCRIPTION_LITERAL + ' ' + ctr);
    //        milestoneNonGeneric.Comments__c = MILESTONE_COMMENT_LITERAL + ' ' + ctr;
    //        milestoneList.add(milestoneNonGeneric);
    //    }
    //    insert milestoneList;
        
    //    for (Project_Milestone__c miles: milestoneList) 
    //    {
    //        CONCAT_MILESTONE_ID = CONCAT_MILESTONE_ID +  ',' + miles.id;
    //        Project_Activity__c activityTerminal = IMP_TestFactory_Helper.buildProjectActivity(miles.Id);
    //        activityTerminal.CDK_Assignee__c = user_cdkAssignee.Id;
    //        activityTerminal.Description__c = ACTIVITY_DESCRIPTION;
    //        activityTerminal.Planned_Start_Date__c = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 2; //Date.newInstance(2014, 1, 3);
    //        activityTerminal.Planned_End_Date__c   = ACTIVITY_ACTUAL_END_DATE; //Date.newInstance(2014, 1, 4);
    //        activityTerminal.Terminal_Activity__c = true;
    //        activityList.add(activityTerminal);
    //    }   
    //    insert activityList;

    //    for (Project_Activity__c act: activityList) 
    //    {
    //        Project_Task__c taskTerminal = IMP_TestFactory_Helper.buildProjectTask(act.Id);
    //        taskTerminal.Actual_Start_Date__c = ACTIVITY_ACTUAL_START_DATE;
    //        taskTerminal.Actual_End_Date__c   = ACTIVITY_ACTUAL_END_DATE;
    //        taskTerminal.CDK_Assignee__c = user_cdkAssignee.Id;
    //        taskTerminal.Description__c = TASK_DESCRIPTION;
    //        taskTerminal.Planned_Start_Date__c = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE + 2; //Date.newInstance(2014, 1, 3);
    //        taskTerminal.Planned_End_Date__c   = ACTIVITY_ACTUAL_END_DATE; //Date.newInstance(2014, 1, 4);
    //        taskTerminal.Terminal_Task__c = true;
    //        taskTerminal.Actual_Time_Spent__c = 1;
    //        taskTerminal.Reason__c = 'None';
    //        taskList.add(taskTerminal);
            
    //    }
    //    insert taskList;
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
    //    Test.startTest();

    //    ApexPages.CurrentPage().getParameters().put('id', subProjectWithDealerGroup.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', CONCAT_MILESTONE_ID);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();        
        
    //    controller.milestoneContentList.get(0).isEdited = true;
    //    expectedMilestone = controller.milestoneContentList.get(0).projectMilestone;
    //    expectedMilestone.Description__c = '';        
    //    controller.milestoneContentList.get(0).isEdited = true;
        
    //    expectedActivity = controller.milestoneContentList.get(1).projectActivity.get(0).activity;
    //    expectedActivity.Description__c = ACTIVITY_DESCRIPTION + '_EDITED';
    //    expectedActivity.Planned_End_Date__c = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE;
    //    expectedActivity.Planned_Start_Date__c = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE +2;
    //    controller.milestoneContentList.get(1).projectActivity.get(0).isEdited = true;
        
    //    expectedTask  = controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task;
    //    expectedTask.Description__c = TASK_DESCRIPTION + '_EDITED';
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).isEdited = true;
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task.Actual_End_Date__c = MINIMUM_PROJECT_ACTIVITY_PLANNED_START_DATE;
    //    controller.inlineSave();

    //    Test.stopTest();
        
    //    system.assert( controller.milestoneContentList.get(1).projectActivity.get(0).hasError);
    //}
    
    //static testMethod void hasTerminalActivity_NegativeTest1() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Boolean containsTerminalActivity;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity1;
        
    //    Project_Activity__c activity2 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity2;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    containsTerminalActivity = controller.hasTerminalActivity(controller.milestoneContentList.get(0).projectActivity, controller.milestoneContentList.get(0).projectMilestone.Description__c);
        
    //    // expect the method hasTerminalActivity to return 'false' because the 2 inserted activities were not terminal
    //    System.assertEquals(false, containsTerminalActivity);
        
    //    // expect an error returned
    //    System.assertEquals(true, ApexPages.getMessages().get(ApexPages.getMessages().size() - 1).getDetail().contains(milestone.Description__c + ' - At least 1 Activity should be marked as a Terminal Activity'));
        
    //    Test.stopTest();
    //}
    
    //static testMethod void hasTerminalActivity_NegativeTest2() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Boolean containsTerminalActivity;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity1;
        
    //    Project_Activity__c activity2 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity2;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    controller.milestoneContentList.get(0).projectActivity.get(0).activity.Terminal_Activity__c = true;
    //    controller.milestoneContentList.get(0).projectActivity.get(1).activity.Terminal_Activity__c = true;
        
    //    containsTerminalActivity = controller.hasTerminalActivity(controller.milestoneContentList.get(0).projectActivity, controller.milestoneContentList.get(0).projectMilestone.Description__c);
        
    //    // expect the method hasTerminalActivity to return 'false' because there can be only 1 terminal activity per milestone, and we inserted 2
    //    System.assertEquals(false, containsTerminalActivity);
        
    //    // expect an error returned
    //    System.assertEquals(true, ApexPages.getMessages().get(ApexPages.getMessages().size() - 1).getDetail().contains(milestone.Description__c + ' - No more than 1 activity can be marked as a Terminal Activity at a time'));
        
    //    Test.stopTest();
    //}
    
    //static testMethod void hasTerminalActivity_PositiveTest() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Boolean containsTerminalActivity;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity1;
        
    //    Project_Activity__c activity2 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity2;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    controller.milestoneContentList.get(0).projectActivity.get(0).activity.Terminal_Activity__c = true;
    //    controller.milestoneContentList.get(0).projectActivity.get(1).activity.Terminal_Activity__c = false;        
    //    containsTerminalActivity = controller.hasTerminalActivity(controller.milestoneContentList.get(0).projectActivity, controller.milestoneContentList.get(0).projectMilestone.Description__c);
        
    //    // expect the method hasTerminalActivity to return 'true' all conditions were satisfied
    //    System.assertEquals(true, containsTerminalActivity);
        
    //    // expect no errors
    //    System.assertEquals(0, ApexPages.getMessages().size());
        
    //    Test.stopTest();
    //}
    
    //static testMethod void hasTerminalTask_NegativeTest1() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Boolean containsTerminalActivity;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    activity1.Terminal_Activity__c = true;
    //    insert activity1;
        
    //    Project_Task__c task1 = IMP_TestFactory_Helper.buildProjectTask(activity1.Id);
    //    task1.Terminal_Task__c = true;
    //    insert task1;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).isEdited = true;
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task.Terminal_Task__c = false;
    //    controller.inlineSave();
        
    //    // expect an error returned
    //    System.assertEquals(true, ApexPages.getMessages().get(0).getDetail().contains('At least 1 Task should be marked as a Terminal Task'));
        
    //    Test.stopTest();
    //}
    
    //static testMethod void hasTerminalTask_NegativeTest2() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Boolean containsTerminalActivity;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    activity1.Terminal_Activity__c = true;
    //    insert activity1;
        
    //    Project_Task__c task1 = IMP_TestFactory_Helper.buildProjectTask(activity1.Id);
    //    task1.Terminal_Task__c = true;
    //    insert task1;
        
    //    Project_Task__c task2 = IMP_TestFactory_Helper.buildProjectTask(activity1.Id);
    //    task2.Terminal_Task__c = false;
    //    insert task2;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).isEdited = true;
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(1).task.Terminal_Task__c = true;
    //    controller.inlineSave();
        
    //    // expect an error returned
    //    System.assertEquals(true, ApexPages.getMessages().get(0).getDetail().contains('No more than 1 Task can be marked as a Terminal Task at a time'));
        
    //    Test.stopTest();
    //}
    
    //static testMethod void addErrorInTheWrapper_Test() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity;
        
    //    Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);
    //    task.Terminal_Task__c = false;
    //    insert task;
        
    //    Map<Id, Id> errorMap;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    // expect no errors before calling the addErrorInTheWrapper method
    //    System.assertEquals(false, controller.milestoneContentList.get(0).hasError);
    //    System.assertEquals(false, controller.milestoneContentList.get(0).projectActivity.get(0).hasError);
        
    //    errorMap = new Map<Id, Id>();
    //    controller.addErrorInTheWrapper(errorMap);
        
    //    // expect no errors after calling the addErrorInTheWrapper method because we passed a blank map
    //    System.assertEquals(false, controller.milestoneContentList.get(0).hasError);
    //    System.assertEquals(false, controller.milestoneContentList.get(0).projectActivity.get(0).hasError); 
        
    //    errorMap = new Map<Id, Id> { milestone.Id => milestone.Id };
    //    controller.addErrorInTheWrapper(errorMap);
        
    //    // expect errors after calling the addErrorInTheWrapper method because we passed a map containing ID's of supposed to be records with error
    //    System.assertEquals(true, controller.milestoneContentList.get(0).hasError);
        
    //    errorMap = new Map<Id, Id> { activity.Id => activity.Id };
    //    controller.addErrorInTheWrapper(errorMap);
        
    //    // expect errors after calling the addErrorInTheWrapper method because we passed a map containing ID's of supposed to be records with error        
    //    System.assertEquals(true, controller.milestoneContentList.get(0).projectActivity.get(0).hasError);        
        
    //    errorMap = new Map<Id, Id> { task.Id => task.Id };
    //    controller.addErrorInTheWrapper(errorMap);
        
    //    // expect errors after calling the addErrorInTheWrapper method because we passed a map containing ID's of supposed to be records with error        
    //    System.assertEquals(true, controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).hasError);    
        
    //    Test.stopTest();
    //}
    
    //static testMethod void addErrorAndRemoveRecordInTheWrapper_Test() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity_2 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity_2;
        
    //    Project_Task__c task_2_1 = IMP_TestFactory_Helper.buildProjectTask(activity_2.Id);
    //    task_2_1.Terminal_Task__c = true;
    //    insert task_2_1;
        
    //    Project_Activity__c activity_1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity_1;
        
    //    Project_Task__c task_1_1 = IMP_TestFactory_Helper.buildProjectTask(activity_1.Id);
    //    task_1_1.Terminal_Task__c = true;
    //    insert task_1_1;
        
    //    Project_Task__c task_1_2 = IMP_TestFactory_Helper.buildProjectTask(activity_1.Id);
    //    task_1_2.Terminal_Task__c = false;
    //    insert task_1_2;
        
    //    Map<Id, Id> errorMap;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(1).toDelete = true;
    //    errorMap = new Map<Id, Id> { task_1_1.Id => task_1_1.Id };
    //    controller.addErrorInTheWrapper(errorMap);
        
    //    // expect errors after calling the addErrorInTheWrapper method because we passed a map containing ID's of supposed to be records with error        
    //    System.assertEquals(true, controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).hasError);    
    //    System.assertEquals(1,controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.size());
        
    //    controller.milestoneContentList.get(0).projectActivity.get(1).toDelete = true;
    //    errorMap = new Map<Id, Id> { activity_1.Id => activity_1.Id };
    //    controller.addErrorInTheWrapper(errorMap);
        
    //    // expect errors after calling the addErrorInTheWrapper method because we passed a map containing ID's of supposed to be records with error        
    //    System.assertEquals(true, controller.milestoneContentList.get(0).projectActivity.get(0).hasError);    
    //    System.assertEquals(1, controller.milestoneContentList.get(0).projectActivity.size());    
    //    Test.stopTest();
    //}
    
    //static testMethod void deleteMilestone_Test() 
    //{
    //    // TEST 1 
    //    // --> miles.toDelete == true
        
    //    Project_Milestone__c milestoneForDeletion = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, 'MILESTONE FOR DELETION');
    //    insert milestoneForDeletion;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestoneForDeletion.Id);
    //    insert activity1;
        
    //    Project_Activity__c activityTerminal = IMP_TestFactory_Helper.buildProjectActivity(milestoneForDeletion.Id);
    //    insert activityTerminal;
        
    //    Project_Task__c taskTerminal = IMP_TestFactory_Helper.buildProjectTask(activityTerminal.Id);
    //    insert taskTerminal;
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestoneForDeletion.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    System.assertEquals(false, controller.milestoneContentList.get(0).toDelete);
    //    System.assertEquals(1, [SELECT COUNT() FROM Project_Milestone__c WHERE Id = :milestoneForDeletion.Id]);
        
    //    controller.milestoneContentList.get(0).toDelete = true;        
    //    controller.deleteMilestone();
        
    //    // expect the milestone to get deleted
    //    System.assertEquals(0, [SELECT COUNT() FROM Project_Milestone__c WHERE Id = :milestoneForDeletion.Id]);        
        
    //}
    
    //static testMethod void deleteActivity_Test() 
    //{
    //    // TEST 1 
    //    // --> miles.toDelete == true
        
    //    Project_Milestone__c milestoneForDeletion = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, 'MILESTONE FOR DELETION');
    //    insert milestoneForDeletion;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestoneForDeletion.Id);
    //    insert activity1;
        
    //    Project_Task__c task1 = IMP_TestFactory_Helper.buildProjectTask(activity1.Id);
    //    task1.Terminal_Task__c = true;
    //    insert task1;
        
    //    Project_Activity__c activityTerminal = IMP_TestFactory_Helper.buildProjectActivity(milestoneForDeletion.Id);
    //    activityTerminal.Terminal_Activity__c = true;
    //    insert activityTerminal;
        
    //    Project_Task__c taskTerminal = IMP_TestFactory_Helper.buildProjectTask(activityTerminal.Id);
    //    taskTerminal.Terminal_Task__c = true;
    //    insert taskTerminal;
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestoneForDeletion.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller(); 
        
    //    System.assertEquals(false, controller.milestoneContentList.get(0).projectActivity.get(0).toDelete);
    //    System.assertEquals(false, controller.milestoneContentList.get(0).projectActivity.get(1).toDelete);
    //    System.assertEquals(2, [SELECT COUNT() FROM Project_Activity__c WHERE Id = :activity1.Id OR Id = :activityTerminal.Id]);
        
    //    for (Integer ctr = 0; ctr < 2; ctr++) 
    //    {
    //        controller.milestoneContentList.get(0).projectActivity.get(ctr).toDelete = (controller.milestoneContentList.get(0).projectActivity.get(ctr).activity.Id == activityTerminal.Id ? false : true);
    //    }

    //    Test.startTest();

    //    controller.deleteMilestone();

    //    Test.stopTest();
        
    //    // expect to successfully delete 1 activity, which is the non-terminal activity
    //    System.assertEquals(0, [SELECT COUNT() FROM Project_Activity__c WHERE Id = :activity1.Id]);
    //    System.assertEquals(1, [SELECT COUNT() FROM Project_Activity__c WHERE Id = :activityTerminal.Id]);    
    //}
    
    //static testMethod void deleteTask_Test() 
    //{
    //    // TEST 1 
    //    // --> miles.toDelete == true        
    //    Project_Milestone__c milestoneForDeletion = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, 'MILESTONE FOR DELETION');
    //    insert milestoneForDeletion;
        
    //    Project_Activity__c activityTerminal = IMP_TestFactory_Helper.buildProjectActivity(milestoneForDeletion.Id);
    //    activityTerminal.Terminal_Activity__c = true;
    //    insert activityTerminal;
        
    //    Project_Task__c taskTerminal = IMP_TestFactory_Helper.buildProjectTask(activityTerminal.Id);
    //    taskTerminal.Terminal_Task__c = true;
    //    insert taskTerminal;
        
    //    Project_Task__c task1 = IMP_TestFactory_Helper.buildProjectTask(activityTerminal.Id);        
    //    insert task1;
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestoneForDeletion.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller(); 
    //    //delete the task1 record        
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(1).toDelete = true;
        
    //    Test.startTest();

    //    controller.deleteMilestone();

    //    Test.stopTest();
    //    //check if the task1 is deleted in the database
    //    System.assertEquals(0, [SELECT COUNT() FROM Project_Activity__c WHERE Id = :task1.Id]);    
    //}
    
    //static testMethod void checkIfValidForDeletion_NegativeTest1() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Boolean isValidForDeletion;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity1;
        
    //    Project_Activity__c activity2 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity2;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    controller.milestoneContentList.get(0).projectActivity.get(0).toDelete = true;
    //    controller.milestoneContentList.get(0).projectActivity.get(1).toDelete = true;        
    //    controller.deleteMilestone();
    //    //expected error
    //    System.assertEquals(true, ApexPages.getMessages().get(ApexPages.getMessages().size() - 1).getDetail().contains(milestone.Description__c + ' - Cannot delete selected Activity, Milestone should have at least 1 Activity'));
        
    //    Test.stopTest();
    //}
    
    //static testMethod void checkIfValidForDeletion_NegativeTest2() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Boolean isValidForDeletion;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    activity1.Terminal_Activity__c = false;
    //    insert activity1;
        
    //    Project_Activity__c activityTerminal = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    activityTerminal.Terminal_Activity__c = true;
    //    insert activityTerminal;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    for (Integer ctr = 0; ctr < 2; ctr++) 
    //    {
    //        controller.milestoneContentList.get(0).projectActivity.get(ctr).toDelete = (controller.milestoneContentList.get(0).projectActivity.get(ctr).activity.Id == activityTerminal.Id ? true : false);
    //    }
        
    //    controller.deleteMilestone();
    //    //expected error 
    //    System.assertEquals(true, ApexPages.getMessages().get(ApexPages.getMessages().size() - 1).getDetail().contains(milestone.Description__c + ' -  At least 1 Activity should be marked as a Terminal Activity'));
        
    //    Test.stopTest();
    //}
    
    //static testMethod void checkIfValidForDeletion_NegativeTest3() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Boolean isValidForDeletion;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity1;
        
    //    Project_Task__c taskTerminal = IMP_TestFactory_Helper.buildProjectTask(activity1.Id);
    //    taskTerminal.Terminal_Task__c = true;
    //    taskTerminal.Expected_Time_Spent__c = 1;
    //    insert taskTerminal;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).toDelete = true;        
    //    controller.deleteMilestone();
    //    //expected errror    	
    //    System.assertEquals(true, ApexPages.getMessages().get(ApexPages.getMessages().size() - 1).getDetail().contains('Cannot delete selected Task, Activity should have at least 1 Task'));
        
    //    Test.stopTest();
    //}
    
    //static testMethod void checkIfValidForDeletion_NegativeTest4() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Boolean isValidForDeletion;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    activity1.Terminal_Activity__c = true;
    //    insert activity1;
        
    //    Project_Task__c taskTerminal = IMP_TestFactory_Helper.buildProjectTask(activity1.Id);
    //    taskTerminal.Terminal_Task__c = true;
    //    taskTerminal.Expected_Time_Spent__c = 1;
    //    insert taskTerminal;
        
    //    Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity1.Id);
    //    insert task;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).toDelete = true;        
    //    controller.deleteMilestone();

    //    //expected error result    	
    //    System.assertEquals(true, ApexPages.getMessages().get(ApexPages.getMessages().size() - 1).getDetail().contains('At least 1 Task should be marked as a Terminal Task'));
        
    //    Test.stopTest();
    //}
    
    //static testMethod void checkIfValidForDeletion_PositiveTest() 
    //{
    //    Test.startTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION 
        
    //    Boolean isValidForDeletion;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity1;
        
    //    Project_Activity__c activityTerminal = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    activityTerminal.Terminal_Activity__c = true;
    //    insert activityTerminal;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    for (Integer ctr = 0; ctr < 2; ctr++) 
    //    {
    //        controller.milestoneContentList.get(0).projectActivity.get(ctr).toDelete = (controller.milestoneContentList.get(0).projectActivity.get(ctr).activity.Id == activityTerminal.Id ? false : true);
    //    }
        
    //    isValidForDeletion = controller.checkIfValidForDeletion(controller.milestoneContentList.get(0).projectActivity, controller.milestoneContentList.get(0).projectMilestone.Description__c);
        
    //    //expect record is valid and no error message will return
    //    System.assertEquals(true, isValidForDeletion);
    //    System.assertEquals(0, ApexPages.getMessages().size());
        
    //    Test.stopTest();
    //}
    
    //static testMethod void createNewActivity_Test() 
    //{
    //    Test.StartTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    System.assertEquals(1, controller.milestoneContentList.get(0).projectActivity.size());
        
    //    controller.milestoneId = milestone.Id;
    //    controller.createNewActivity();
        
    //    System.assertEquals(2, controller.milestoneContentList.get(0).projectActivity.size());
        
    //    controller.createNewActivity();
    //    controller.createNewActivity();
        
    //    System.assertEquals(4, controller.milestoneContentList.get(0).projectActivity.size());
        
    //    Integer arCounter = 0;
    //    for (IMP_MilestoneEdit_Controller.ActivityWrapper ar : controller.milestoneContentList.get(0).projectActivity) 
    //    {
    //        if (ar.activity.Id == null) { arCounter++; }
    //    }
        
    //    // expect 3 new activities to get instantiated
    //    System.assertEquals(3, arCounter);
        
    //    Test.StopTest();
    //}
    
    //static testMethod void deleteNewActivity_Test() 
    //{
    //    Test.StartTest();
        
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    System.assertEquals(1, controller.milestoneContentList.get(0).projectActivity.size());
        
    //    controller.milestoneId = milestone.Id;
    //    controller.createNewActivity();
    //    controller.createNewActivity();
    //    controller.createNewActivity();
        
    //    System.assertEquals(4, controller.milestoneContentList.get(0).projectActivity.size());
        
    //    controller.activityIndex = '1';
    //    controller.deleteNewActivity();
        
    //    // expect 1 newly instantiated activity to get deleted
    //    System.assertEquals(3, controller.milestoneContentList.get(0).projectActivity.size());
        
        
    //    Test.StopTest();
    //}
    
    //static testMethod void createNewTask_Test() 
    //{
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity;
        
    //    Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);
    //    insert task;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
    //    Test.StartTest();
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    System.assertEquals(1, controller.milestoneContentList.get(0).projectActivity.size());
        
    //    controller.milestoneId = milestone.Id;
    //    controller.createNewTask();
        
    //    System.assertEquals(2, controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.size());
    //    controller.activityId = activity.id;
    //    controller.createNewTask();
    //    controller.createNewTask();

    //    //expect 4 task, createNewTask is called 3 times plus the initial task 
    //    System.assertEquals(4, controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.size());    
        
    //    Test.StopTest();
    //}
    
    //static testMethod void deleteNewTask_Test() 
    //{
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    insert activity;
        
    //    Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);
    //    task.Terminal_Task__c = true;
    //    insert task;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
    //    Test.StartTest();
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    System.assertEquals(1, controller.milestoneContentList.get(0).projectActivity.size());
        
    //    controller.milestoneId = milestone.Id;
    //    controller.createNewActivity(); 
    //    controller.createNewTask();
    //    controller.activityId = activity.Id;
    //    controller.createNewTask();

    //    controller.taskIndex = '0';
    //    controller.deleteNewTask();
        
    //    // expect 1 newly instantiated activity to get deleted
    //    System.assertEquals(2, controller.milestoneContentList.get(0).projectActivity.get(1).projectTask.size());
    //    controller.activityId = '';
    //    controller.activityExternalId = controller.milestoneContentList.get(0).projectActivity.get(0).Activity.External_ID__c;     
    //    controller.deleteNewTask();
        
    //    System.assertEquals(0, controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.size());
        
    //    Test.StopTest();
    //}
    
    static testMethod void cloneTaskRecord_Test() 
    {
        // --------------------------------------------------------------------
        // INITIALIZATION
        createCustomSettings();

        IMP_ProjectLinksUrls__c entityTypesCustomSetting = new IMP_ProjectLinksUrls__c();
        entityTypesCustomSetting.Name = 'CMF';
        entityTypesCustomSetting.HasFieldonProject__c    = true; 
        entityTypesCustomSetting.ProjectFieldName__c     = 'CMF_Numbers__c';
        entityTypesCustomSetting.HasFieldonSubproject__c = true; 
        entityTypesCustomSetting.SubProjectFieldName__c  = 'CMF_Numbers__c';
        insert entityTypesCustomSetting;

        CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(account.Id);
        insert testCMFInfo;

        SubProjectSite__c subProjectSite1 = IMP_TestFactory_Helper.buildSubProjectSite(account.Id, subProject.Id, testCMFInfo.Id);        
        insert subProjectSite1;

        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;

        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity.CDK_Assignee__c  = user_cdkAssignee.Id;
        activity.Terminal_Activity__c = true;
        insert activity;

        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);
        task.CDK_Assignee__c = user_cdkAssignee.Id;
        task.Terminal_Task__c = true;
        task.Migration_Status__c = 'Success';
        task.Planned_Start_Date__c = Date.today() - 1;
        task.Planned_End_Date__c = Date.today();
        insert task;

        // --------------------------------------------------------------------
        // TESTING PROPER
        IMP_TestFactory_Helper.buildCustomSettings();
        CustomSettings__c cs = [SELECT Users_Excluded_from_Business_Rules__c FROM CustomSettings__c LIMIT 1];
        cs.Users_Excluded_from_Business_Rules__c = 'Rey Austral, ' + UserInfo.getName();
        update cs;

        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
        IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();

        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).isEdited = true;
        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task.Actual_Start_Date__c = Date.today() -1;
        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task.Actual_End_Date__c = Date.today();
        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task.Actual_Time_Spent__c = 1;
        controller.inlineSave();

        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).isEdited = true;
        controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task.Migration_Status__c = 'Failure – Postgres – Extract';

        Test.StartTest();
        
        controller.inlineSave();
        
        Test.stopTest();

        //expect that there is now 2 task instead of 1 because of the clone
        List<Project_Task__c> updatedTaskList = [Select id, Migration_Status__c, Terminal_Task__c from Project_Task__c where Project_Activity__c =:  activity.id];
        system.assertEquals(2, updatedTaskList.size());

    }
    
    //static testMethod void saveAndCloseFunction_Test() 
    //{
    //    // --------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    activity.Terminal_Activity__c = true;       
    //    insert activity;
        
    //    CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(account.Id);
    //    insert testCMFInfo;
        
    //    SubProjectSite__c subProjectSite1 = IMP_TestFactory_Helper.buildSubProjectSite(account.Id, subProject.Id, testCMFInfo.Id);        
    //    insert subProjectSite1;
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    for (IMP_MilestoneEdit_Controller.MilestoneWrapper miles : controller.milestoneContentList)
    //    {   
    //        miles.expandActivity = true;  
    //        //checkbox in the ui
    //        miles.toDelete = true;
    //        miles.isEdited = true;
    //        miles.projectMilestone.Comments__c = 'Caution';    
            
    //        List<IMP_MilestoneEdit_Controller.ActivityWrapper> activitiesList = miles.projectActivity;
    //        for (IMP_MilestoneEdit_Controller.ActivityWrapper act : activitiesList)
    //        {
    //            act.toDelete = true;
    //        }
    //    }   

    //    Test.StartTest();

    //    controller.saveAndClose();     

    //    Test.stopTest();

    //    Project_Milestone__c updatedMilestone = [Select id, Comments__c from Project_Milestone__c where id =:  milestone.id];
    //    system.assertEquals('Caution', updatedMilestone.Comments__c);
    //    //expand and checkbox must be false
    //    for (IMP_MilestoneEdit_Controller.MilestoneWrapper miles : controller.milestoneContentList) 
    //    {   
    //        System.assert(miles.expandActivity);            
    //        List<IMP_MilestoneEdit_Controller.ActivityWrapper> activities = miles.projectActivity;           
    //    }         
    //}
    
    //static testMethod void noByPassPermission_Test()
    //{
    //     createCustomSettings();
        
    //    CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(account.Id);
    //    insert testCMFInfo;
        
    //    SubProjectSite__c subProjectSite1 = IMP_TestFactory_Helper.buildSubProjectSite(account.Id, subProject.Id, testCMFInfo.Id);        
    //    insert subProjectSite1;
        
    //    Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    activity.CDK_Assignee__c  = user_cdkAssignee.Id;
    //    activity.Terminal_Activity__c = true;
    //    activity.Planned_Start_Date__c = Date.today() - 1;
    //    activity.Planned_End_Date__c = Date.today();
    //    insert activity;
        
    //    Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);
    //    task.CDK_Assignee__c = user_cdkAssignee.Id;
    //    task.Terminal_Task__c = true;
    //    task.Migration_Status__c = 'Success';
    //    task.Planned_Start_Date__c = Date.today() - 1;
    //    task.Planned_End_Date__c = Date.today();
    //    insert task;
        
    //    // --------------------------------------------------------------------
    //    // TESTING PROPER
        
    //    ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
    //    ApexPages.CurrentPage().getParameters().put('mid', milestone.Id);
    //    IMP_MilestoneEdit_Controller controller = new IMP_MilestoneEdit_Controller();
        
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).isEdited = true;
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task.Actual_Start_Date__c = Date.today() -1;
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task.Actual_End_Date__c = Date.today();
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task.Actual_Time_Spent__c = 1;
    //    controller.inlineSave();
        
    //    Test.StartTest();
        
    //    controller.milestoneContentList.get(0).projectActivity.get(0).isEdited = true;
    //    controller.milestoneContentList.get(0).projectActivity.get(0).activity.Actual_Start_Date__c = Date.today() -1;
    //    controller.milestoneContentList.get(0).projectActivity.get(0).activity.Actual_End_Date__c = Date.today();
    //    controller.inlineSave();
        
    //    //test when the status is complete the canAddNewTask and canAddNewActivity must be false when the user cannot bypass business rule
    //    System.assertEquals(false,controller.milestoneContentList.get(0).projectActivity.get(0).canAddNewTask );
    //    System.assertEquals(false,controller.milestoneContentList.get(0).canAddNewActivity  );
        
    //    controller.resetWrapperDataAndExtensionField( controller.retrieveMilestoneRecords() );
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).isEdited = true;
    //    controller.milestoneContentList.get(0).projectActivity.get(0).projectTask.get(0).task.Comments__c = 'Try to Edit';
        
    //    controller.inlineSave();
        
    //    Test.stopTest();
        
    //    //test when the status is complete the canAddNewTask and canAddNewActivity must be false when the user cannot bypass business rule
    //    System.assertEquals(false,controller.milestoneContentList.get(0).projectActivity.get(0).canAddNewTask );
    //    System.assertEquals(false,controller.milestoneContentList.get(0).canAddNewActivity  );
        
    //    //test the clone function , the trigger should throw an error
    //    System.assertEquals(true, ApexPages.getMessages().get(ApexPages.getMessages().size() - 1).getDetail().contains(IMP_String_Utility.NO_BYPASS_TOUPDATE_TASK));
        
    //}
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
}