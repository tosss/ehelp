/*------------------------------------------------------------
    Author:      Kimiko Roberto
    Company:     Cloud Sherpas
    Description: Test class for IMP_NotApplicableStatus_Handler
    Inputs:      
    Returns:     
    History
    05/20/15     Kimiko Roberto    Created
    09/24/15     Karl Simon        Updated to exclude the test for wiping out the Actual Time Spent, which should be preserved.
    ------------------------------------------------------------*/
@isTest

private class IMP_NotApplicableStatus_Handler_Test
{
    public static final String GENERIC_MILESTONE_DESCRIPTION = 'TEST MILESTONE DESCRIPTION';
    
    public static final Project__c project { get; set; }
    public static final SubProject__c subProject { get; set; }
    public static final Account account { get; set; }
    public static final User user_cdkAssignee { get; set; }
    public static final Contact contact_clientAssignee { get; set; }
    public static final Project_Activity__c activity {get;set;}
    public static final Project_Milestone__c milestone {get;set;}
    
     //create test data from Project up to Project Task
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
        
        milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        activity.CDK_Assignee__c = user_cdkAssignee.Id;
        activity.Client_Assignee__c = contact_clientAssignee.id;
        insert activity;
        
        
    }
    /*
    static testMethod void blankPlannedDatesActualDaysSpentInsert_Test()
    {
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        task1.Reason__c = 'Client Declined Work';
        insert task1;
        
        Project_Task__c updatedTask = [SELECT Id, Planned_Start_Date__c,Planned_End_Date__c, Actual_Time_Spent__c FROM Project_Task__c WHERE Id = : task1.Id ];
                
        system.Assert(updatedTask != null);
        system.Assert(updatedTask.Planned_Start_Date__c == null);
        system.Assert(updatedTask.Planned_End_Date__c == null);
        system.Assert(updatedTask.Actual_Time_Spent__c == null);
        
    }
    */
    
    static testMethod void blankPlannedDatesActualDaysSpentUpdate_Test()
    {
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        insert task1;
        
        task1.Reason__c = 'Client Declined Work';
        
        update task1;
        
        Project_Task__c updatedTask = [SELECT Id, Planned_Start_Date__c,Planned_End_Date__c, Actual_Time_Spent__c FROM Project_Task__c WHERE Id = : task1.Id ];
                
        system.Assert(updatedTask != null);
        system.Assert(updatedTask.Planned_Start_Date__c == null);
        system.Assert(updatedTask.Planned_End_Date__c == null);
        // 09/24/15 - Karl Simon - Updated to exclude the test for wiping out the Actual Time Spent, which should be preserved.
        // system.Assert(updatedTask.Actual_Time_Spent__c == null);
        
    }

}