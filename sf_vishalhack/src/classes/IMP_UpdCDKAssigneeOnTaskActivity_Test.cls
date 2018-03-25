//2015-01-05- venkata.shrivol@cdk.com- Created class IMP_UpdCDKAssigneeOnTaskActivty_Test For RQ-05996 Update CDK assignee on Tasks and Activities FROM SubProject.
//2016-03-11- anirudh.singh@cdk.com- Created this test class as the earlier class IMP_UpdCDKAssigneeOnTaskActivty_Test was not following naming standards.
//2016-03-11- anirudh.singh@cdk.com- Modified this class for Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
//2016-06-06- anirudh.singh@cdk.com- Modified to resolve error due to additional filter on Project_Manager__c field of SubProject for profile for Shared Contacts project.
//2016-12--5 -venkata.shrivol@cdk.com -commented project object reference RQ-08305
@isTest
public class IMP_UpdCDKAssigneeOnTaskActivity_Test
{
    @TestSetup
    private static void setupData()
    {
        //2016-06-06- anirudh.singh@cdk.com- Added to resolve error due to additional filter on Project_Manager__c field of SubProject for profile for Shared Contacts project.
        String Random=DS_TestObjects.NextTestUserRandom();
        Profile profileRecord=[SELECT Id, Name FROM Profile WHERE Name='ADPDS - Implementation - PM' LIMIT 1];
        
        User newUser=new User(
            UserName='IMP_UpdActivity_Test-'+Random+'@cdk.com', 
            Email='test-'+Random+'@cdk.com', 
            Alias=Random.length()>8?Random.substring(4, Random.length()):Random,
            EmailEncodingKey='UTF-8', 
            FirstName='Apex',
            LastName='Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid=profileRecord.Id, 
            TimeZoneSIDKey='America/Chicago',
            ADID__c='A'+Random,
            FederationIdentifier = 'F'+Random
        );
        insert newUser;
        
        List<User> userList=new List<User>();
        User userRecordOne=IMP_TestFactory_Helper.buildUser();
        userRecordOne.FirstName='Standard Test User 1';
        userList.add(userRecordOne);
        
        User userRecordTwo=IMP_TestFactory_Helper.buildUser();
        userRecordTwo.FirstName='Standard Test User 2';
        userList.add(userRecordTwo);
        
        User userRecordThree=IMP_TestFactory_Helper.buildUser();
        userRecordThree.FirstName='Standard Test User 3';
        userList.add(userRecordThree);
        insert userList;
        
        /*Project__c projectRecord=IMP_TestFactory_Helper.buildProject(0);
        insert projectRecord;*/
        
        SubProject__c subProjectRecord=IMP_TestFactory_Helper.buildSubProject();
        //2016-06-06- anirudh.singh@cdk.com- Commented the below line and added a new line for Project_Manager__c. 
        //2016-06-06- anirudh.singh@cdk.com- This change is made for resolving error due to additional filter on Project_Manager__c field of SubProject for profile for Shared Contacts project.
        //subProjectRecord.Project_Manager__c=UserInfo.getUserId();
        subProjectRecord.Project_Manager__c=newUser.Id;
        subProjectRecord.Training_Implementation_Client_Mgr__c=userRecordOne.Id;
        insert subProjectRecord;
        
        Milestone_Definition__c milestoneDefinitionRecord=IMP_TestFactory_Helper.buildMilestoneDefinition();
        insert milestoneDefinitionRecord;
        
        List<Activity_Definition__c> activityDefinitionsList=new List<Activity_Definition__c>();
        Activity_Definition__c activityDefinitionRecordOne=IMP_TestFactory_Helper.buildActivityDefinition(milestoneDefinitionRecord.Id);
        activityDefinitionRecordOne.CDK_Assignee_Role__c='Utilization & Training Project Manager';
        activityDefinitionsList.add(activityDefinitionRecordOne);
        
        Activity_Definition__c activityDefinitionRecordTwo=IMP_TestFactory_Helper.buildActivityDefinition(milestoneDefinitionRecord.Id);
        activityDefinitionRecordTwo.CDK_Assignee_Role__c='Training & Implementation Client Manager';
        activityDefinitionsList.add(activityDefinitionRecordTwo);
        insert activityDefinitionsList;
        
        Project_Milestone__c milestoneRecord=IMP_TestFactory_Helper.buildMilestoneNonStandard(subProjectRecord.Id, 'test Description');
        insert milestoneRecord;
        
        List<Project_Activity__c> activityList=new List<Project_Activity__c>();
        for(Integer i=0; i<2; i++)
        {
            Project_Activity__c activityRecord=IMP_TestFactory_Helper.buildProjectActivity(milestoneRecord.Id);
            activityRecord.Activity_Definition__c=activityDefinitionsList[i].Id;
            activityRecord.CDK_Assignee_Role__c=activityDefinitionsList[i].CDK_Assignee_Role__c;
            activityList.add(activityRecord); 
        }
        insert activityList;
        
        List<Project_Task__c> projectTasksList=new List<Project_Task__c>();
        for(Integer i=0; i<2; i++)
        {
            Project_Task__c taskRecord=IMP_TestFactory_Helper.buildProjectTask(activityList[i].Id);
            projectTasksList.add(taskRecord);    
        }
        insert projectTasksList;
    }
    
    private static testMethod void updateTasksAndActivitiesTestOne()
    {
        SubProject__c subProjectRecord=[SELECT Id, Project_Manager__c, Training_Implementation_Client_Mgr__c FROM SubProject__c];
        
        List<Project_Activity__c> activityList=[SELECT Name, CDK_Assignee_Role__c, CDK_Assignee__c FROM Project_Activity__c ORDER BY Name];
        List<Project_Task__c> projectTasksList=[SELECT Name, CDK_Assignee_Role__c, CDK_Assignee__c FROM Project_Task__c  ORDER BY Name];
        List<User> userList=[SELECT Id, Name FROM User WHERE Name LIKE 'Standard Test User%'];
        
        test.startTest();
        SubProject__c newSubProjectRecord=subProjectRecord.clone(true);
        newSubProjectRecord.Project_Manager__c=userList[1].Id;
        newSubProjectRecord.Training_Implementation_Client_Mgr__c=userList[2].Id;
        Map<Id, SubProject__c> subProjectMap=new Map<Id, SubProject__c>();
        subProjectMap.put(newSubProjectRecord.Id, newSubProjectRecord);
        
        IMP_UpdCDKAssigneeOnTaskActivity_Handler.updateTasksAndActivities(subProjectMap);
        List<Project_Activity__c> updatedActivityList=[SELECT Name, CDK_Assignee_Role__c, CDK_Assignee__c FROM Project_Activity__c  ORDER BY Name];
        system.assertNotEquals(activityList[0].CDK_Assignee__c, updatedActivityList[0].CDK_Assignee__c, 'CDK_Assignee__c on Activity Updated');
        system.assertEquals(updatedActivityList[0].CDK_Assignee__c, userList[1].Id, 'CDK_Assignee__c on Activity Updated');
        
        system.assertNotEquals(activityList[1].CDK_Assignee__c, updatedActivityList[1].CDK_Assignee__c, 'CDK_Assignee__c on Activity Updated');
        system.assertEquals(updatedActivityList[1].CDK_Assignee__c, userList[2].Id, 'CDK_Assignee__c on Activity Updated');
        
        List<Project_Task__c> updatedProjectTasksList=[SELECT Name, CDK_Assignee_Role__c, CDK_Assignee__c FROM Project_Task__c  ORDER BY Name];
        system.assertNotEquals(projectTasksList[0].CDK_Assignee__c, updatedProjectTasksList[0].CDK_Assignee__c, 'CDK_Assignee__c on Task Updated');
        system.assertEquals(updatedProjectTasksList[0].CDK_Assignee__c, userList[1].Id, 'CDK_Assignee__c on Task Updated');
        
        system.assertNotEquals(projectTasksList[1].CDK_Assignee__c, updatedProjectTasksList[1].CDK_Assignee__c, 'CDK_Assignee__c on Task Updated');
        system.assertEquals(updatedProjectTasksList[1].CDK_Assignee__c, userList[2].Id, 'CDK_Assignee__c on Task Updated');
        test.stopTest();
    }
    
    private static testMethod void updateTasksAndActivitiesTestTwo()
    {
        test.startTest();
        IMP_UpdCDKAssigneeOnTaskActivity_Handler.updateTasksAndActivities(new Map<Id, SubProject__c>());
        test.stopTest();
    }
}