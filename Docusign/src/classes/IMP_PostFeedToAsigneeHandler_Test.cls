/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Test class for IMP_PostFeedToAsigneeHandler
Test Class:
History
10/06/14    Kimiko Roberto      Created
11/14/14    Samuel Oberes       Updated postToChatterFeed_Test and removed postToChatterFeedNegative_Test due to redundancy
11/19/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/
@isTest
private class IMP_PostFeedToAsigneeHandler_Test{
    
    //public static final String GENERIC_MILESTONE_DESCRIPTION = 'TEST MILESTONE DESCRIPTION';
    
    //public static final Project__c project { get; set; }
    //public static final SubProject__c subProject { get; set; }
    //public static final Account account { get; set; }
    //public static final User user_cdkAssignee { get; set; }
    //public static final Contact contact_clientAssignee { get; set; }
    //public static final Project_Activity__c activity {get;set;}
    //public static final Project_Milestone__c milestone {get;set;}
    
    ////create test data that would allow Project Task creation
    //static {
    //    project = IMP_TestFactory_Helper.buildProject(0);
    //    insert project;
        
    //    subProject = IMP_TestFactory_Helper.buildSubProject(project.Id);
    //    insert subProject;
        
    //    account = IMP_TestFactory_Helper.buildAccount();
    //    insert account;
        
    //    user_cdkAssignee = IMP_TestFactory_Helper.buildUser();
    //    insert user_cdkAssignee;
        
    //    contact_clientAssignee = IMP_TestFactory_Helper.buildContact(account.Id);
    //    insert contact_clientAssignee;
        
    //    milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
    //    insert milestone;
        
    //    activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
    //    activity.CDK_Assignee__c = user_cdkAssignee.Id;
    //    insert activity;
        
        
    //}
    
    //static testMethod void postToChatterFeed_Test(){
    //    //create test data for enabling posting feeds and adding asignees as follower of the project and subproject through Project Activities

    //    Test.startTest();

    //    // ------------------------------------------------------------------------------------------------------
    //    // INITIALIZATION
        
    //    User testUser1 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testUser1.FirstName = 'Sam';
    //    testUser1.LastName = 'Testing';
    //    testUser1.ADID__c = 'testAdid'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser1;
        
    //    User testUser2 = IMP_TestFactory_Helper.buildUserAdmin();
    //    testuser2.FirstName = 'Sam2';
    //    testUser2.LastName = 'Testing2';
    //    testUser2.ADID__c = 'testAdid2'; // IMPORTANT: To avoid encountering DUPLICATE_VALUE error, add a unique value for this
    //    insert testUser2;
        
    //    Account testChildAccount = IMP_TestFactory_Helper.buildAccount(); //Test Child Account Name
    //    insert testChildAccount;
        
    //    Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
    //    testProject.Name = 'Test Project Name'; // name value will be used exactly below. do not change.
    //    testProject.Dealer_Group__c = testChildAccount.Id;
    //    insert testProject;
        
    //    SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
    //    testSubProject.SubProject_Name__c = 'Test SubProject Name'; // name value will be used exactly below. do not change.
    //    testSubProject.Dealer_Group__c = testChildAccount.Id;
    //    insert testSubProject;
        
    //    EntitySubscription testFollower = new EntitySubscription(ParentId = testSubProject.Id, SubscriberId = testUser2.Id);
    //    insert testFollower;
        
    //    EntitySubscription testFollower2 = new EntitySubscription(ParentId = testProject.Id, SubscriberId = testUser2.Id);
    //    insert testFollower2;
        
    //    Project_Milestone__c testProjectMilestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testSubProject.Id, 'Test Description Milestone');
    //    insert testProjectMilestone;
        
    //    Project_Activity__c testProjectActivity = IMP_TestFactory_Helper.buildProjectActivity(testProjectMilestone.Id);
    //    testProjectActivity.Description__c = 'Test Description Activity'; // name value will be used exactly below. do not change.
    //    testProjectActivity.Planned_Start_Date__c = null;
    //    testProjectActivity.Planned_End_Date__c = null;
    //    insert testProjectActivity;

        
    //    String expectedBodyForContact;
    //    String expectedBodyForSubProject;
    //    String actualBodyForContact;
    //    String actualBodyForSubProject;
    //    String testUserIds;
    //    Date startDate;
    //    Date endDate;
    //    Integer subscriptionInstanceCounter;
    //    // ------------------------------------------------------------------------------------------------------
    //    // TESTS PROPER

    //    // 1A) Feed-body testing 1 of 2
    //    //     Check whether the Feed body is being created
    //    //     Check differences in the planned start and end date

    //    testProjectActivity.CDK_Assignee__c = testUser1.Id;
        
    //    update testProjectActivity;

    //    expectedBodyForContact    = 'Project Activity: Test Description Activity has been assigned to you.\n' + 
    //                                'SubProject: Test SubProject Name'+ 
    //                                '\nProject: Test Project Name'+ 
    //                                '\nPlanned Start Date: ' + IMP_String_Utility.ERR_MSG_NO_START_DATE_ASSIGNED + 
    //                                '\nPlanned End Date: ' + IMP_String_Utility.ERR_MSG_NO_END_DATE_ASSIGNED;
    //    /*
    //    expectedBodyForSubProject = 'Project Activity: Test Description Activity has been assigned to Sam Testing\n' + 
    //                                'Planned Start Date: ' + IMP_PostFeedToAsignee_Handler.ERR_MSG_NO_START_DATE_ASSIGNED + '\n' + 
    //                                'Planned End Date: ' + IMP_PostFeedToAsignee_Handler.ERR_MSG_NO_END_DATE_ASSIGNED;
    //                                */

    //    actualBodyForContact      = [SELECT Body FROM FeedItem WHERE ParentId = :testProjectActivity.CDK_Assignee__c].Body;
    //    //actualBodyForSubProject   = [SELECT Body FROM FeedItem WHERE ParentId = :testSubProject.Id].Body;

    //    system.assertEquals(expectedBodyForContact, actualBodyForContact);
    //    //system.assertEquals(expectedBodyForSubProject, actualBodyForSubProject);
        
        
        
        
    //    // 1B) Feed-body testing 2 of 2
    //    //     Check whether the Feed body is being created
    //    //     Check differences in the planned start and end date
        
    //    // cleanup first so that the succeeding queries won't get unnecessary entries from the above tests
    //    delete [SELECT Body FROM FeedItem WHERE ParentId = :testProjectActivity.CDK_Assignee__c];
    //    //delete [SELECT Body FROM FeedItem WHERE ParentId = :testSubProject.Id];

    //    // proceed testing
    //    testProjectActivity.CDK_Assignee__c       = testUser2.Id;
    //    testProjectActivity.Planned_Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
    //    testProjectActivity.Planned_End_Date__c   = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 1);

    //    update testProjectActivity;
        
    //    //Project_Activity__c updatedPrjAct = [SELECT Planned_Start_Date__c,Planned_End_Date__c FROM Project_Activity__c WHERE Id =: testProjectActivity.Id];
        
    //    /*
    //    startDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
    //    endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 1);

    //    expectedBodyForContact    = 'Project Activity: Test Description Activity has been assigned to you.\n' + 
    //                                'SubProject: Test SubProject Name'+ 
    //                                '\nProject: Test Project Name'+ 
    //                                '\nPlanned Start Date: ' + startDate.format() + 
    //                                '\nPlanned End Date: ' + endDate.format() ;
    //    */
    //    /*
    //    expectedBodyForSubProject = 'Project Activity: Test Description Activity has been assigned to Sam2 Testing2\n' + 
    //                                'Planned Start Date: ' + startDate.format() + '\n' + 
    //                                'Planned End Date: ' + endDate.format();
    //                                */
        
    //    actualBodyForContact = [SELECT Body FROM FeedItem WHERE ParentId = :testProjectActivity.CDK_Assignee__c].Body;
    //    //actualBodyForSubProject   = [SELECT Body FROM FeedItem WHERE ParentId = :testSubProject.Id].Body;

    //    system.assert(actualBodyForContact != null);
    //    //system.assertEquals(expectedBodyForSubProject, actualBodyForSubProject);
        
        
        
        
    //    // 2A) Entity subscription testing (for subprojects)
    //    //     Since testUser1 and testUser2 has been used as CDK_Assignee__c for test 1A and 1B above, they should now be followers of the project and subproject.
    //    //     Check whether above assumption is true for subprojects.

    //    testUserIds = testUser1.Id + ';' + testUser2.Id;
    //    Integer subprojectFollowerCount = 2;
    //    List<EntitySubscription> subprojectFollowers = [SELECT SubscriberId FROM EntitySubscription WHERE ParentId = :testSubProject.Id];

    //    system.assertEquals(subprojectFollowerCount, subprojectFollowers.size());

    //    for (EntitySubscription es : subprojectFollowers) {
    //        system.assertEquals(true, testUserIds.contains(es.SubscriberId));
    //    }




    //    // 2B) Entity subscription testing (for projects)
    //    //     Since testUser1 and testUser2 has been used as CDK_Assignee__c for test 1A and 1B above, they should now be followers of the project and subproject.
    //    //     Check whether above assumption is true for projects.

    //    testUserIds = testUser1.Id + ';' + testUser2.Id;
    //    Integer projectFollowerCount = 2;
    //    List<EntitySubscription> projectFollowers = [SELECT SubscriberId FROM EntitySubscription WHERE ParentId = :testProject.Id];

    //    system.assertEquals(projectFollowerCount, projectFollowers.size());

    //    for (EntitySubscription es : projectFollowers) {
    //        system.assertEquals(true, testUserIds.contains(es.SubscriberId));
    //    }




    //    // 3A) Entity subscription testing
    //    //     Right now, testUser2 is the current CDK_Assignee__c. Change CDK_Assignee__c to testUser1.
    //    //     Expect that there will be no new entries for subproject. Instance count will remain at 1.
 
    //    testProjectActivity.CDK_Assignee__c = testUser1.Id;
        
    //    update testProjectActivity;

    //    subscriptionInstanceCounter = [SELECT COUNT() FROM EntitySubscription WHERE ParentId = :testSubProject.Id AND SubscriberId = :testProjectActivity.CDK_Assignee__c];

    //    system.assertEquals(1, subscriptionInstanceCounter);




    //    // 3B) Entity subscription testing
    //    //     Right now, testUser1 is the current CDK_Assignee__c. Change CDK_Assignee__c to testUser2.
    //    //     Expect that there will be no new entries for project. Instance count will remain at 1.

    //    testProjectActivity.CDK_Assignee__c = testUser2.Id;
        
    //    update testProjectActivity;

    //    subscriptionInstanceCounter = [SELECT COUNT() FROM EntitySubscription WHERE ParentId = :testProject.Id AND SubscriberId = :testProjectActivity.CDK_Assignee__c];

    //    system.assertEquals(1, subscriptionInstanceCounter);
        
    //    // ------------------------------------------------------------------------------------------------------

    //    Test.stopTest();
    //}
    
    //static testMethod void postToChatterFeedCompleteTask_Test()
    //{
    //    Milestone_Definition__c milestoneDef = IMP_TestFactory_Helper.buildMilestoneDefinition();
    //    insert milestoneDef;
        
    //    Activity_Definition__c activityDef = IMP_TestFactory_Helper.buildActivityDefinition(milestoneDef.Id);
    //    insert activityDef;
        
    //    Task_Definition__c taskDef = IMP_TestFactory_Helper.buildTaskDefinition(activityDef.Id);
    //    taskDef.NotifyWhenComplete__c = true;
    //    insert taskDef;
        
    //    Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
    //    task1.CDK_Assignee__c = user_cdkAssignee.Id;
    //    insert task1;
        
    //    task1.Actual_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
    //    task1.Task_Definition__c = taskDef.Id;
    //    update task1;
        
    //    String subProjectFeed;
    //    List<String> taskAsigneeFeed = new List<String>();
        
    //    for(FeedItem feed : [SELECT Body FROM FeedItem WHERE ParentId = :user_cdkAssignee.Id])
    //    {
    //        taskAsigneeFeed.add(feed.Body);
    //    }
        
    //    subProjectFeed = [SELECT Body FROM FeedItem WHERE ParentId = :subProject.Id].Body;
        
    //    system.Assert(subProjectFeed != null);
    //    system.Assert(taskAsigneeFeed != null);
    //    system.Assert(taskAsigneeFeed.size() == 2);
        
        
    //}
    
    
}