/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test Class for IMP_MilestoneEdit_Controller
History
06/23/15     Rey Austral      Created
------------------------------------------------------------*/
@isTest
public class IMP_ProjectTaskClone_Test 
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
    
    static testMethod void cloneTaskRecord_Test() 
    {
        // --------------------------------------------------------------------
        // INITIALIZATION
        createCustomSettings();
       
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity.CDK_Assignee__c  = user_cdkAssignee.Id;
        activity.Client_Assignee__c = contact_clientAssignee.id;
        insert activity;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);
        task.Client_Assignee__c = contact_clientAssignee.id;
        task.CDK_Assignee__c = user_cdkAssignee.Id;
        
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
       
        task.Actual_Start_Date__c = Date.today() -1;
        task.Actual_End_Date__c = Date.today();
        task.Actual_Time_Spent__c = 1;
        update task;
        
        Test.StartTest();
        task.Migration_Status__c = 'Failure – Postgres – Extract';
        update task;
        
        Test.stopTest();
        
        //expect that there is now 2 task instead of 1 because of the clone
        List<Project_Task__c> updatedTaskList = [Select id, Migration_Status__c from Project_Task__c where Project_Activity__c =:  activity.id];
        system.assertEquals(2, updatedTaskList.size());
        
    }
    
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
}