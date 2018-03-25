/*------------------------------------------------------------
    Author:      Kimiko Roberto
    Company:     Cloud Sherpas
    Description: Test class for IMP_BuildActivityRollups_Handler
    Inputs:      
    Returns:     
    History
    02/19/15     Kimiko Roberto    Created
    ------------------------------------------------------------*/
@isTest
public class IMP_BuildActivityRollups_Handler_Test
{


    public static final String GENERIC_MILESTONE_DESCRIPTION = 'TEST MILESTONE DESCRIPTION';
    
    public static final Project__c project { get; set; }
    public static final SubProject__c subProject { get; set; }
    public static final Account account { get; set; }
    public static final User user_cdkAssignee { get; set; }
    public static final Contact contact_clientAssignee { get; set; }
    public static final Project_Activity__c activity {get;set;}
    public static final Project_Milestone__c milestone {get;set;}
    
    //create test data that would allow Project Task creation
    static {
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
        insert activity;
        
        
    }
    
    
    //create a task and check rolled up values up to project milestone
    static testMethod void checkProjectActivityMilestoneRollupValues()
    {
       Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
       task1.CDK_Assignee__c = user_cdkAssignee.Id;
       insert task1;

       system.Assert(task1 != null);
       
       Project_Task__c updatedTask1 = [SELECT Id, Status__c FROM Project_Task__c WHERE Id = : task1.Id];
       Project_Activity__c updatedProjectActivity = [SELECT Id, Total_Actual_Time_Spent__c, Total_Expected_Time_Spent__c, Actual_Start_Date__c, Status__c, Expected_Remaining_Duration__c FROM Project_Activity__c WHERE Id = : activity.Id];
       system.Assert(updatedProjectActivity != null);
       system.Assert(updatedProjectActivity.Total_Actual_Time_Spent__c == 1);
       system.Assert(updatedProjectActivity.Total_Expected_Time_Spent__c == 1);
       system.Assert(updatedProjectActivity.Actual_Start_Date__c == task1.Actual_Start_Date__c );
       system.Assert(updatedProjectActivity.Expected_Remaining_Duration__c == 1 );
       
       Project_Milestone__c updatedProjectMilestone = [SELECT Id, Actual_Start_Date__c, Expected_Remaining_Duration__c,  Status__c FROM Project_Milestone__c WHERE Id = : milestone.Id];
       system.Assert(updatedProjectMilestone != null);
       system.Assert(updatedProjectMilestone.Actual_Start_Date__c == task1.Actual_Start_Date__c );
       system.Assert(updatedProjectMilestone.Expected_Remaining_Duration__c == 1);
       
    }
    
    
    //create a task with status not applicable checked
    static testMethod void addStatusNotApplicableTask()
    {
       Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
       task1.CDK_Assignee__c = user_cdkAssignee.Id;
       task1.Reason__c = 'None';
       insert task1;
       
       //task1.Status_Not_Applicable__c = true;
       
       update task1;
       
       system.Assert(task1 != null);
       
       Project_Task__c notApplicableTask = [SELECT Id, Status__c FROM Project_Task__c WHERE Id = : task1.Id];
       
       system.Assert(notApplicableTask != null);
       system.Assert(notApplicableTask.Status__c == 'Not Applicable');
       
    }
    
    //add an actual end date to a task created to make the status complete
    static testMethod void addStatusCompleteTask(){
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        task1.CDK_Assignee__c = user_cdkAssignee.Id;
        insert task1;
        
        task1.Actual_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
       
        update task1;
       
        system.Assert(task1 != null);
       
        Project_Task__c completeTask = [SELECT Id, Status__c FROM Project_Task__c WHERE Id = : task1.Id];
       
        system.Assert(completeTask != null);
        system.Assert(completeTask.Status__c == 'Complete');
    }
    
    //create a task that would make activity and milestone status At Risk
    static testMethod void checkStatusActivityMilestoneAtRisk(){
        
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        task1.CDK_Assignee__c = user_cdkAssignee.Id;
        insert task1;
    
        
        
        Project_Activity__c updatedProjectActivityStatus = [SELECT Id, Status__c FROM Project_Activity__c WHERE Id = : activity.Id];
        system.Debug('^^updatedProjectActivityStatus.Status__c: ' + updatedProjectActivityStatus.Status__c);
        system.Assert(updatedProjectActivityStatus != null);
        system.Assert(updatedProjectActivityStatus.Status__c == 'At Risk');
        
        Project_Milestone__c updatedProjectMilestoneStatus = [SELECT Id, Status__c FROM Project_Milestone__c WHERE Id = : milestone.Id];
        system.Debug('^^updatedProjectMilestoneStatus.Status__c: ' + updatedProjectMilestoneStatus.Status__c);
        system.Assert(updatedProjectMilestoneStatus != null);
        system.Assert(updatedProjectMilestoneStatus.Status__c == 'At Risk');
    }
    
    //create a task that would make activity and milestone status On Target
    static testMethod void checkStatusActivityMilestoneOnTarget(){
        
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        task1.CDK_Assignee__c = user_cdkAssignee.Id;
        insert task1;
    
        Project_Activity__c updatedProjectActivityStatus = [SELECT Id, Status__c, Planned_Start_Date__c, Planned_End_Date__c FROM Project_Activity__c WHERE Id = : activity.Id];
        updatedProjectActivityStatus.Planned_End_Date__c = updatedProjectActivityStatus.Planned_End_Date__c + 2;
        update updatedProjectActivityStatus;
        
        Project_Activity__c updatedProjectActivityStatusOnTarget = [SELECT Id, Status__c, Planned_Start_Date__c, Planned_End_Date__c FROM Project_Activity__c WHERE Id = : activity.Id];
        
        
        system.Debug('^^updatedProjectActivityStatusOnTarget.Status__c: ' + updatedProjectActivityStatusOnTarget.Status__c);
        system.Assert(updatedProjectActivityStatusOnTarget != null);
        system.Assert(updatedProjectActivityStatusOnTarget.Status__c == 'On Target');
 
        Project_Milestone__c updatedProjectMilestoneStatusOnTarget = [SELECT Id, Status__c, Planned_Start_Date__c, Planned_End_Date__c FROM Project_Milestone__c WHERE Id = : milestone.Id];
        
        system.Debug('^^updatedProjectMilestoneStatusOnTarget.Status__c: ' + updatedProjectMilestoneStatusOnTarget.Status__c);
        system.Assert(updatedProjectMilestoneStatusOnTarget != null);
        system.Assert(updatedProjectMilestoneStatusOnTarget.Status__c == 'On Target');
    }
    
    //create a task that would make activity and milestone status Caution
    static testMethod void checkStatusActivityMilestoneCaution(){
        
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        task1.CDK_Assignee__c = user_cdkAssignee.Id;
        task1.Expected_Time_Spent__c = 10;
        insert task1;
        
        
        
        
        
        Project_Activity__c updatedProjectActivityStatus = [SELECT Id, Status__c, Planned_Start_Date__c, Planned_End_Date__c FROM Project_Activity__c WHERE Id = : activity.Id];
        updatedProjectActivityStatus.Planned_End_Date__c = updatedProjectActivityStatus.Planned_End_Date__c + 11;
        update updatedProjectActivityStatus;
        
        Project_Activity__c updatedProjectActivityStatusCaution = [SELECT Id, Status__c, Planned_Start_Date__c, Planned_End_Date__c, Duration_Buffer__c FROM Project_Activity__c WHERE Id = : activity.Id];
        
        
        system.Debug('^^updatedProjectActivityStatusCaution.Status__c: ' + updatedProjectActivityStatusCaution.Status__c);
        system.Debug('^^updatedProjectActivityStatusCaution.Duration_Buffer__c: ' + updatedProjectActivityStatusCaution.Duration_Buffer__c);
        system.Assert(updatedProjectActivityStatusCaution != null);
        system.AssertEquals(updatedProjectActivityStatusCaution.Status__c, 'Caution');
 
        Project_Milestone__c updatedProjectMilestoneStatusCaution = [SELECT Id, Status__c, Planned_Start_Date__c, Planned_End_Date__c FROM Project_Milestone__c WHERE Id = : milestone.Id];
        
        system.Debug('^^updatedProjectMilestoneStatusOnTarget.Status__c: ' + updatedProjectMilestoneStatusCaution.Status__c);
        system.Assert(updatedProjectMilestoneStatusCaution != null);
        system.AssertEquals(updatedProjectMilestoneStatusCaution.Status__c, 'Caution');
    }
    
    //create a task that would make activity and milestone status complete
    static testMethod void checkStatusActivityMilestoneComplete(){
        
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        task1.CDK_Assignee__c = user_cdkAssignee.Id;
        insert task1;
        
        task1.Actual_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        update task1;
        
        Project_Activity__c updatedProjectActivityStatus = [SELECT Id, Status__c, Planned_Start_Date__c, Planned_End_Date__c FROM Project_Activity__c WHERE Id = : activity.Id];
        updatedProjectActivityStatus.Actual_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        update updatedProjectActivityStatus;
        
        Project_Activity__c updatedProjectActivityStatusComplete = [SELECT Id, Status__c, Planned_Start_Date__c, Planned_End_Date__c FROM Project_Activity__c WHERE Id = : activity.Id];
        
        
        system.Debug('^^updatedProjectActivityStatusComplete.Status__c: ' + updatedProjectActivityStatusComplete.Status__c);
        system.Assert(updatedProjectActivityStatusComplete != null);
        system.AssertEquals(updatedProjectActivityStatusComplete.Status__c, 'Complete');
 
        Project_Milestone__c updatedProjectMilestoneStatus = [SELECT Id, Status__c, Planned_Start_Date__c, Planned_End_Date__c, Actual_End_Date__c FROM Project_Milestone__c WHERE Id = : milestone.Id];
        updatedProjectMilestoneStatus.Actual_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day());
        
        update updatedProjectMilestoneStatus;
        
        Project_Milestone__c updatedProjectMilestoneStatusComplete = [SELECT Id, Status__c, Planned_Start_Date__c, Planned_End_Date__c, Actual_End_Date__c FROM Project_Milestone__c WHERE Id = : milestone.Id];
        
        system.Debug('^^updatedProjectMilestoneStatusComplete.Status__c: ' + updatedProjectMilestoneStatusComplete.Status__c);
        system.Assert(updatedProjectMilestoneStatusComplete != null);
        system.AssertEquals(updatedProjectMilestoneStatusComplete.Status__c, 'Complete');
    }

}