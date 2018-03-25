/*------------------------------------------------------------
Author:      Michael Lasala
Company:     Cloud Sherpas
Description: Test class for the IMP_RMSActions_Handler class
History
07/20/14     Samuel Oberes       Created
09/21/15     Samuel Oberes       Added stampFieldsWithDefinitionValues_test
06/15/16     ragashalini.koka@cdk.com  changed the Sort_Sequence__c to Sequence__c on Project_Milestone__c
06/29/16     Venkata Shrivol     changed the Sort_Sequence__c to Sequence__c on Milestone defintion object
12/06/16     Venkata Shrivol	  commented the project object reference RQ-08305
------------------------------------------------------------*/
@isTest
public class IMP_RMSActions_Handler_Test {

    private static String  MILESTONE_DESCRIPTION = 'TEST MILESTONE DEFINITION DESCRIPTION';
    private static String  MILESTONE_PROCESS_STEP = '01-Implementation Discovery';
    private static Integer MILESTONE_SORT_SEQUENCE = 1;
    private static String  ACTIVITY_DESCRIPTION = 'TEST ACTIVITY DEFINITION DESCRIPTION';
    private static Integer ACTIVITY_SEQUENCE = 1;
    private static String  ACTIVITY_CDK_ASSIGNEE_ROLE = '3PA';
    private static String  TASK_DESCRIPTION = 'TEST TASK DEFINITION DESCRIPTION';
    private static Integer TASK_SEQUENCE = 1;
    private static Integer TASK_EXPECTED_TIME_SPENT = 1;
    private static String  SUBPROJECT_NAME = 'TEST_SP';

    private class TestFixtures
    {
        // public Project__c project { get; set; }
        public SubProject__c subProject 
        { 
            get
            {
                return [SELECT Id FROM SubProject__c LIMIT 1];
            }
        }
        public Milestone_Definition__c milestoneDefinition
        {
            get
            {
                return [SELECT Id FROM Milestone_Definition__c LIMIT 1];
            }
        }
        public Activity_Definition__c activityDefinition
        {
            get
            {
                return [SELECT Id FROM Activity_Definition__c LIMIT 1];
            }
        }
        public Task_Definition__c taskDefinition
        {
            get
            {
                return [SELECT Id FROM Task_Definition__c LIMIT 1];
            }
        }
        // public Site_Type__c siteType { get; set; }
        // public Account account { get; set; }
        // public CMF_Info__c cmfInfo { get; set; }
        public SubProjectSite__c subProjectSite 
        {
            get
            {
                return [SELECT Id FROM SubProjectSite__c LIMIT 1];
            }
        }
        public Project_Milestone__c milestoneRMSOwnedWithDefinition
        {
            get
            {
                return [SELECT Id FROM Project_Milestone__c LIMIT 1];
            }
        }
        public Project_Activity__c activityRMSOwnedWithDefinition
        {
            get
            {
                return [SELECT Id FROM Project_Activity__c LIMIT 1];
            }
        }
        // public Project_Task__c taskRMSOwnedWithDefinition { get; set; }
    }

    @testSetup 
    static void setup() {

        // 1-time test data creation
        /*Project__c project = IMP_TestFactory_Helper.buildProject(0);
        insert project;*/

        SubProject__c subProject = IMP_TestFactory_Helper.buildSubProject();
        subProject.SubProject_Name__c = SUBPROJECT_NAME;
        insert subProject;

        Milestone_Definition__c milestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        milestoneDefinition.Description__c = MILESTONE_DESCRIPTION;
        milestoneDefinition.Process_Step__c = MILESTONE_PROCESS_STEP;
        milestoneDefinition.Sequence__c = MILESTONE_SORT_SEQUENCE;
        insert milestoneDefinition;

        Activity_Definition__c activityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(milestoneDefinition.Id);
        activityDefinition.Description__c = ACTIVITY_DESCRIPTION;
        activityDefinition.Sequence__c = ACTIVITY_SEQUENCE;
        activityDefinition.CDK_Assignee_Role__c = ACTIVITY_CDK_ASSIGNEE_ROLE;
        insert activityDefinition;

        Task_Definition__c taskDefinition = IMP_TestFactory_Helper.buildTaskDefinition(activityDefinition.Id);
        taskDefinition.Active__c = false; // IMPORTANT! -> THIS MUST ALWAYS BE FALSE WHEN INSERTING BECAUSE A VALIDATION RULE WILL TRIGGER AN ERROR IF OTHERWISE. UPDATE TO TRUE LATER AFTER INSERTION.
        taskDefinition.Description__c = TASK_DESCRIPTION;
        taskDefinition.Sequence__c = TASK_SEQUENCE;
        taskDefinition.Expected_Time_Spent__c = TASK_EXPECTED_TIME_SPENT;
        insert taskDefinition;

        taskDefinition.Active__c = true;
        update taskDefinition;

        activityDefinition.Active__c = true;
        update activityDefinition;

        milestoneDefinition.Active__c = true;
        update milestoneDefinition;

        Site_Type__c siteType = IMP_TestFactory_Helper.buildSiteType();
        siteType.Group_Flag__c = true;
        insert siteType;

        Account account = IMP_TestFactory_Helper.buildAccount();
        account.Name = 'TEST ACCOUNT';
        account.Site_Type__c = siteType.Id;
        insert account;

        CMF_Info__c cmfInfo = IMP_TestFactory_Helper.buildCMFInfo(account.Id);
        cmfInfo.Name = 'TEST CMF NAME';        
        insert cmfInfo;  

        SubProjectSite__c subProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(account.Id, subProject.Id, cmfInfo.Id);
        insert subProjectSite;

        Project_Milestone__c milestoneRMSOwnedWithDefinition = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, 'FIXTURE_MILESTONE');
        milestoneRMSOwnedWithDefinition.Process_Step__c = null;
        milestoneRMSOwnedWithDefinition.Sequence__c = null;
        milestoneRMSOwnedWithDefinition.Milestone_Definition__c = milestoneDefinition.Id;
        milestoneRMSOwnedWithDefinition.Site__c = subProjectSite.Id;
        milestoneRMSOwnedWithDefinition.RMS_Owned_Flag__c = true;
        insert milestoneRMSOwnedWithDefinition;

        Project_Activity__c activityRMSOwnedWithDefinition = IMP_TestFactory_Helper.buildProjectActivity(milestoneRMSOwnedWithDefinition.Id);
        activityRMSOwnedWithDefinition.Description__c = 'FIXTURE_ACTIVITY';
        activityRMSOwnedWithDefinition.Sequence__c = null;
        activityRMSOwnedWithDefinition.CDK_Assignee_Role__c = null;
        activityRMSOwnedWithDefinition.Activity_Definition__c = activityDefinition.Id;
        activityRMSOwnedWithDefinition.RMS_Owned_Flag__c = true;
        insert activityRMSOwnedWithDefinition;
    }

    public static testmethod void stampFieldsWithDefinitionValues_milestoneContext_test() 
    {

        TestFixtures tf = new TestFixtures();

        // SCENARIO 1: project milestone's RMS_Owned_Flag__c == false
        // EXPECTATION: respective fields will not be stamped
        Project_Milestone__c milestone1 = IMP_TestFactory_Helper.buildMilestoneNonStandard(tf.subProject.Id, 'NULL');
        milestone1.Process_Step__c = null;
        milestone1.Sequence__c = null;
        milestone1.Milestone_Definition__c = null;
        milestone1.Site__c = tf.subProjectSite.Id;
        milestone1.RMS_Owned_Flag__c = false;
        insert milestone1;

        milestone1 = [SELECT Id, Description__c,Sequence__c, Process_Step__c FROM Project_Milestone__c WHERE Id = :milestone1.Id];
		
		
        System.assertEquals('NULL', milestone1.Description__c);
        System.assertEquals(null, milestone1.Process_Step__c);
        System.assertEquals(null, milestone1.Sequence__c);

        // SCENARIO 2: project milestone without definition
        // EXPECTATION: respective fields will not be stamped
        Project_Milestone__c milestone2 = IMP_TestFactory_Helper.buildMilestoneNonStandard(tf.subProject.Id, 'NULL');
        milestone2.Process_Step__c = null;
        milestone2.Sequence__c = null;
        milestone2.Milestone_Definition__c = null;
        milestone2.Site__c = tf.subProjectSite.Id;
        milestone2.RMS_Owned_Flag__c = true;
        insert milestone2;

        milestone2 = [SELECT Id, Description__c, Sequence__c, Process_Step__c  FROM Project_Milestone__c WHERE Id = :milestone2.Id];
		
		
		
        System.assertEquals('NULL', milestone2.Description__c);
        System.assertEquals(null, milestone2.Process_Step__c);
        System.assertEquals(null, milestone2.Sequence__c);

        // SCENARIO 3: project milestone with definition
        // EXPECTATION: respective fields will be stamped
        Project_Milestone__c milestone3 = IMP_TestFactory_Helper.buildMilestoneNonStandard(tf.subProject.Id, 'NULL');
        milestone3.Process_Step__c = null;
        milestone3.Sequence__c = null;
        milestone3.Milestone_Definition__c = tf.milestoneDefinition.Id;
        milestone3.Site__c = tf.subProjectSite.Id;
        milestone3.RMS_Owned_Flag__c = true;
        insert milestone3;
        
        milestone3 = [SELECT Id, Description__c, Sequence__c, Process_Step__c FROM Project_Milestone__c WHERE Id = :milestone3.Id];
        

        System.assertEquals(MILESTONE_DESCRIPTION, milestone3.Description__c);
        System.assertEquals(MILESTONE_PROCESS_STEP, milestone3.Process_Step__c);
        System.assertEquals(MILESTONE_SORT_SEQUENCE, milestone3.Sequence__c);

    }

    public static testmethod void stampFieldsWithDefinitionValues_activityContext_test()
    {
        TestFixtures tf = new TestFixtures();

        // SCENARIO 1: project activity's RMS_Owned_Flag__c == false
        // EXPECTATION: respective fields will not be stamped
        Project_Activity__c activity1 = IMP_TestFactory_Helper.buildProjectActivity(tf.milestoneRMSOwnedWithDefinition.Id);
        activity1.Description__c = 'NULL';
        activity1.Sequence__c = null;
        activity1.CDK_Assignee_Role__c = null;
        activity1.Activity_Definition__c = null;
        activity1.RMS_Owned_Flag__c = false;
        insert activity1;

        activity1 = [SELECT Id, Description__c, Sequence__c, CDK_Assignee_Role__c FROM Project_Activity__c WHERE Id = :activity1.Id];

        System.assertEquals('NULL', activity1.Description__c);
        System.assertEquals(null, activity1.Sequence__c);
        System.assertEquals(null, activity1.CDK_Assignee_Role__c);

        // SCENARIO 2: project activity without definition
        // EXPECTATION: respective fields will not be stamped
        Project_Activity__c activity2 = IMP_TestFactory_Helper.buildProjectActivity(tf.milestoneRMSOwnedWithDefinition.Id);
        activity2.Description__c = 'NULL';
        activity2.Sequence__c = null;
        activity2.CDK_Assignee_Role__c = null;
        activity2.Activity_Definition__c = null;
        activity2.RMS_Owned_Flag__c = true;
        insert activity2;

        activity2 = [SELECT Id, Description__c, Sequence__c, CDK_Assignee_Role__c FROM Project_Activity__c WHERE Id = :activity2.Id];

        System.assertEquals('NULL', activity2.Description__c);
        System.assertEquals(null, activity2.Sequence__c);
        System.assertEquals(null, activity2.CDK_Assignee_Role__c);

        // SCENARIO 3: project activity with definition
        // EXPECTATION: respective fields will be stamped
        Project_Activity__c activity3 = IMP_TestFactory_Helper.buildProjectActivity(tf.milestoneRMSOwnedWithDefinition.Id);
        activity3.Description__c = 'NULL';
        activity3.Sequence__c = null;
        activity3.CDK_Assignee_Role__c = null;
        activity3.Activity_Definition__c = tf.activityDefinition.Id;
        activity3.RMS_Owned_Flag__c = true;
        insert activity3;
        
        activity3 = [SELECT Id, Description__c, Sequence__c, CDK_Assignee_Role__c FROM Project_Activity__c WHERE Id = :activity3.Id];

        System.assertEquals(ACTIVITY_DESCRIPTION, activity3.Description__c);
        System.assertEquals(ACTIVITY_SEQUENCE, activity3.Sequence__c);
        System.assertEquals(ACTIVITY_CDK_ASSIGNEE_ROLE, activity3.CDK_Assignee_Role__c);
    }

    /*public static testmethod void stampFieldsWithDefinitionValues_taskContext_test()
    {
        TestFixtures tf = new TestFixtures();

        Integer someSequence = 11;
        Integer someExpectedTimeSpent = 99;

        // SCENARIO 1: project task's RMS_Owned_Flag__c == false
        // EXPECTATION: respective fields will not be stamped
        Project_Task__c task1 = IMP_TestFactory_Helper.buildProjectTask(tf.activityRMSOwnedWithDefinition.Id);
        task1.Description__c = 'NULL';
        task1.Sequence__c = someSequence;
        task1.Expected_Time_Spent__c = someExpectedTimeSpent;
        task1.Task_Definition__c = null;
        task1.RMS_Owned_Flag__c = false;
        insert task1;

        task1 = [SELECT Id, Description__c, Sequence__c, Expected_Time_Spent__c FROM Project_Task__c WHERE Id = :task1.Id];

        System.assertEquals('NULL', task1.Description__c);
        System.assertEquals(someSequence, task1.Sequence__c);
        System.assertEquals(someExpectedTimeSpent, task1.Expected_Time_Spent__c);

        // SCENARIO 2: project task without definition
        // EXPECTATION: respective fields will not be stamped
        Project_Task__c task2 = IMP_TestFactory_Helper.buildProjectTask(tf.activityRMSOwnedWithDefinition.Id);
        task2.Description__c = 'NULL';
        task2.Sequence__c = someSequence;
        task2.Expected_Time_Spent__c = someExpectedTimeSpent;
        task2.Task_Definition__c = null;
        task2.RMS_Owned_Flag__c = true;
        insert task2;

        task2 = [SELECT Id, Description__c, Sequence__c, Expected_Time_Spent__c FROM Project_Task__c WHERE Id = :task2.Id];

        System.assertEquals('NULL', task2.Description__c);
        System.assertEquals(someSequence, task2.Sequence__c);
        System.assertEquals(someExpectedTimeSpent, task2.Expected_Time_Spent__c);

        // SCENARIO 3: project task with definition
        // EXPECTATION: respective fields will be stamped
        Project_Task__c task3 = IMP_TestFactory_Helper.buildProjectTask(tf.activityRMSOwnedWithDefinition.Id);
        task3.Description__c = 'NULL';
        task3.Sequence__c = null;
        task3.Expected_Time_Spent__c = null;
        task3.Task_Definition__c = tf.taskDefinition.Id;
        task3.RMS_Owned_Flag__c = true;
        insert task3;
        
        task3 = [SELECT Id, Description__c, Sequence__c, Expected_Time_Spent__c FROM Project_Task__c WHERE Id = :task3.Id];
        
        System.assertEquals(TASK_DESCRIPTION, task3.Description__c);
        System.assertEquals(TASK_SEQUENCE, task3.Sequence__c);
        System.assertEquals(TASK_EXPECTED_TIME_SPENT, task3.Expected_Time_Spent__c);
    }
  */
    public static testmethod void stampFieldsWithDefinitionValues_test()
    {
        // SCENARIO: When inserting a milestone/activity/task, if its corresponding definition is already deleted, a ENTITY_IS_DELETED status code should be catched.

        TestFixtures tf = new TestFixtures();

        Milestone_Definition__c md = IMP_TestFactory_Helper.buildMilestoneDefinition();
        md.Description__c = MILESTONE_DESCRIPTION;
        md.Process_Step__c = MILESTONE_PROCESS_STEP;
        md.Sequence__c = MILESTONE_SORT_SEQUENCE;
        insert md;

        Activity_Definition__c ad = IMP_TestFactory_Helper.buildActivityDefinition(md.Id);
        ad.Description__c = ACTIVITY_DESCRIPTION;
        ad.Sequence__c = ACTIVITY_SEQUENCE;
        ad.CDK_Assignee_Role__c = ACTIVITY_CDK_ASSIGNEE_ROLE;
        insert ad;

        Task_Definition__c td = IMP_TestFactory_Helper.buildTaskDefinition(ad.Id);
        td.Active__c = false; // IMPORTANT! -> THIS MUST ALWAYS BE FALSE WHEN INSERTING BECAUSE A VALIDATION RULE WILL TRIGGER AN ERROR IF OTHERWISE. UPDATE TO TRUE LATER AFTER INSERTION.
        td.Description__c = TASK_DESCRIPTION;
        td.Sequence__c = TASK_SEQUENCE;
        td.Expected_Time_Spent__c = TASK_EXPECTED_TIME_SPENT;
        insert td;

         //td.Active__c = true;
         //update td;

        // ad.Active__c = true;
        // update ad;

        // md.Active__c = true;
        // update md;

        Id mDefId = md.Id;
        Id aDefId = ad.Id;
        Id tDefId = td.Id;

        
        // by deleting the task definition, any child object referencing to this object's ID will throw an ENTITY_IS_DELETED error
        delete td;

       /* Project_Task__c t = IMP_TestFactory_Helper.buildProjectTask(tf.activityRMSOwnedWithDefinition.Id);
        t.Description__c = 'NULL';
        t.Sequence__c = null;
        t.Expected_Time_Spent__c = null;
        t.Task_Definition__c = tDefId;
        t.RMS_Owned_Flag__c = true;

        List<Database.SaveResult> dsrList = Database.insert(new List<Project_Task__c> { t }, false);
        System.assertNotEquals(StatusCode.ENTITY_IS_DELETED, dsrList.get(0).getErrors().get(0).getStatusCode());
        System.assertEquals(IMP_String_Utility.MISSING_DEFINITION, dsrList.get(0).getErrors().get(0).getMessage());*/
        
        
        
        
        
        
        // by deleting the activity definition, any child object referencing to this object's ID will throw an ENTITY_IS_DELETED error
        delete ad;

        Project_Activity__c a = IMP_TestFactory_Helper.buildProjectActivity(tf.milestoneRMSOwnedWithDefinition.Id);
        a.Description__c = 'NULL';
        a.Sequence__c = null;
        a.CDK_Assignee_Role__c = null;
        a.Activity_Definition__c = aDefId;
        a.RMS_Owned_Flag__c = true;

        List<Database.SaveResult> dsrList = Database.insert(new List<Project_Activity__c> { a }, false);
        System.assertNotEquals(StatusCode.ENTITY_IS_DELETED, dsrList.get(0).getErrors().get(0).getStatusCode());
        System.assertEquals(IMP_String_Utility.MISSING_DEFINITION, dsrList.get(0).getErrors().get(0).getMessage());
        
        
        
        
        
        
        
        // by deleting the milestone definition, any child object referencing to this object's ID will throw an ENTITY_IS_DELETED error
        delete md;

        Project_Milestone__c m = IMP_TestFactory_Helper.buildMilestoneNonStandard(tf.subProject.Id, 'NULL');
        m.Process_Step__c = null;
       // m.Sequence__c = null;
        m.Milestone_Definition__c = mDefId;
        m.Site__c = tf.subProjectSite.Id;
        m.RMS_Owned_Flag__c = true;

        dsrList = Database.insert(new List<Project_Milestone__c> { m }, false);
        System.assertNotEquals(StatusCode.ENTITY_IS_DELETED, dsrList.get(0).getErrors().get(0).getStatusCode());
        System.assertEquals(IMP_String_Utility.MISSING_DEFINITION, dsrList.get(0).getErrors().get(0).getMessage());
        
    }

}