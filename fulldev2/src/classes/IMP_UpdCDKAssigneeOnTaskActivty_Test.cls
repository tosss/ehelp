/*--------------------------------------------------------------
RQ-05996 
Test Class for : IMP_UpdCDKAssigneeOnTaskAndActivty_Hndlr
Additional Comments: This test class also partly covers the before insert context of Project Activity Trigger
i.e.., checking the CDK Assignee assignment to tasks and activities.
-------------------------------------------------------------------
2015-01-05  -venkata.shrivol@cdk.com  -Created 
----------------------------------------------------------------*/
//2016-03-11- anirudh.singh@cdk.com- Commented this class due to naming standards issue.
//2016-03-11- anirudh.singh@cdk.com- Created a new test class with the name IMP_UpdCDKAssigneeOnTaskActivity_Test. To be deleted after deployment.
@isTest
public class IMP_UpdCDKAssigneeOnTaskActivty_Test 
{
    /*@testSetup static void prepareTestData()
    {
        User testUser = DS_TestObjects.NewUser();
        testUser.FirstName='CDK Assignee Test User';
        insert testUser;
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c subprj1 = IMP_TestFactory_Helper.buildSubProject(testProject.id);
        subprj1.Project_Manager__c = UserInfo.getUserId();
        subprj1.Training_Implementation_Client_Mgr__c = testUser.Id;
        subprj1.SubProject_Name__c='Test Name';
        insert subprj1;
        
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        insert testMilestoneDefinition;
        
        list<Activity_Definition__c> actDeflist = new list<Activity_Definition__c>();
        Activity_Definition__c testActivityDefinition1 = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinition.Id);
        testActivityDefinition1.CDK_Assignee_Role__c = 'Utilization & Training Project Manager​';
        actDeflist.add(testActivityDefinition1);
        Activity_Definition__c testActivityDefinition2 = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinition.Id);
        testActivityDefinition2.CDK_Assignee_Role__c = 'Training & Implementation Client Manager';
        actDeflist.add(testActivityDefinition2);
        insert actDeflist;
        
        Project_Milestone__c testMilestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subprj1.Id, 'test Description');
        insert testMilestone;
        
        list<Project_Activity__c> testActList = new list<Project_Activity__c>();
        for(integer i=0;i<2;i++)
        {
            Project_Activity__c pactivity = IMP_TestFactory_Helper.buildProjectActivity(testMilestone.Id);
            pactivity.Activity_Definition__c = actDeflist.get(i).Id;
            pactivity.CDK_Assignee_Role__c = actDeflist.get(i).CDK_Assignee_Role__c;
            testActList.add(pactivity); 
        }
        insert testActList;
        
        list<Project_Task__c> testTaskList = new list<Project_Task__c>();
        for(integer i=0;i<2;i++)
        {
            Project_Task__c pTask = IMP_TestFactory_Helper.buildProjectTask(testActList.get(i).Id);
            testTaskList.add(pTask);    
        }
        insert testTaskList;
         
    }
    
    // This testMethod will check for cdk assignee values of activities and tasks 
    // which are inserted above in testSetup Method
    static testMethod void testTheCDKAssigneeInitially()
    {
        Project_Activity__c[] mlist = [
            select Id, CDK_Assignee__c, CDK_Assignee_Role__c 
            from Project_Activity__c 
            where Milestone__r.Description__c='test Description'
            ];
        
        list<SubProject__c> subPrjList = [
            select Id, Project_Manager__c, Training_Implementation_Client_Mgr__c
            from SubProject__c 
            where SubProject_Name__c = 'Test Name'];
        SubProject__c thisSubProject = subPrjList.size()>0? subPrjList.get(0) : new SubProject__c();
        
        for(Project_Activity__c pact:mlist)
        {
            //1st-Check : CDK Assignee should not be null for the activities
            system.assertNotEquals(null, pact.CDK_Assignee__c);
            if(pact.CDK_Assignee_Role__c == 'Utilization & Training Project Manager')
            {
                //2nd Check : Project Manager of Subproject to CDK Assignee of Activity
                system.assertEquals(thisSubProject.Project_Manager__c, pact.CDK_Assignee__c);
            }
            else
            {
                //3rd Check : Training & Client Manager of Subproject to CDK Assignee of Activity
                system.assertEquals(thisSubProject.Training_Implementation_Client_Mgr__c, pact.CDK_Assignee__c);
            }
        }
    }
    
    static testMethod void testTheOnSubProjectUpdate()
    {
        list<SubProject__c> subPrjList = [
            select Id, Project_Manager__c, Training_Implementation_Client_Mgr__c
            from SubProject__c 
            where SubProject_Name__c = 'Test Name'];
        SubProject__c thisSubProject = subPrjList.size()>0? subPrjList.get(0) : new SubProject__c();
        
        Test.startTest();
            //Changing the project ant training manager values that are previously
            //given in above testSetup method 
            thisSubProject.Project_Manager__c=null;
            thisSubProject.Training_Implementation_Client_Mgr__c = UserInfo.getUserId();
            update thisSubProject;
        Test.stopTest();        
        
        list<SubProject__c> retrieveSubPrjAgain = [
            select Id, Project_Manager__c, Training_Implementation_Client_Mgr__c
            from SubProject__c 
            where SubProject_Name__c = 'Test Name'];
        SubProject__c updatedSubPrj = retrieveSubPrjAgain.size()>0? retrieveSubPrjAgain.get(0) : new SubProject__c();
        
        Project_Activity__c[] actVitylist = [
            select Id, CDK_Assignee__c, CDK_Assignee_Role__c 
            from Project_Activity__c 
            where Milestone__r.Description__c='test Description'
            ];
        
        for(Project_Activity__c pact:actVitylist)
        {
            
            if(pact.CDK_Assignee_Role__c == 'Utilization & Training Project Manager')
            {
                //1st Check : Project Manager of Subproject to CDK Assignee of Activity
                system.assertEquals(thisSubProject.Project_Manager__c, pact.CDK_Assignee__c);
                
                //2nd Check: Additional Check for null Value
                system.assertEquals(null, pact.CDK_Assignee__c);
            }
            else
            {
                //3rd Check : Training & Client Manager of Subproject to CDK Assignee of Activity
                system.assertEquals(thisSubProject.Training_Implementation_Client_Mgr__c, pact.CDK_Assignee__c);
            }
        }
    }*/
}