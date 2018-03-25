/*------------------------------------------------------------
Author:      Rey Austral
Company:     Cloud Sherpas
Description: Test class for IMP_CascadetoChild_Handler
Inputs:      
Returns:     
History
02/19/15     Rey Austral    Created
------------------------------------------------------------*/
@isTest
public class IMP_CascadetoChild_Handler_Test {
    public static final String GENERIC_MILESTONE_DESCRIPTION = 'TEST MILESTONE DESCRIPTION';
    
    public static final Project__c project { get; set; }
    public static final SubProject__c subProject { get; set; }
    public static final Account account { get; set; }
    public static final User user_cdkAssignee { get; set; }
    public static final Contact contact_clientAssignee { get; set; }   
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
        
    }
    
    static testMethod void rollDownWhenNewTaskCreated()
    {
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);      
        activity.CDK_Assignee__c = user_cdkAssignee.Id;
        activity.Client_Assignee__c = contact_clientAssignee.id;
        insert activity;
        
        Test.StartTest();
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);        
        insert task1;
        //test if the activity cdk at client assignee is roll down to the new task
        Project_Task__c tsk = [Select CDK_Assignee__c, Client_Assignee__c from  Project_Task__c where id =: task1.id ];
        system.assertEquals(activity.CDK_Assignee__c, tsk.CDK_Assignee__c);
        system.assertEquals(activity.Client_Assignee__c, tsk.Client_Assignee__c);
        Test.stopTest();
    }
    
    static testMethod void rollDownExistingTask()
    {   
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);          
        insert activity;
        
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);     
        task1.Actual_Start_Date__c = null;
        insert task1;
        
        Test.StartTest();
        
        activity.CDK_Assignee__c = user_cdkAssignee.Id;
        activity.Client_Assignee__c = contact_clientAssignee.id;
        update activity;
        //test if the activity client and cdk assignee is updated the existing task with null assignee will be updated
        Project_Task__c tsk = [Select CDK_Assignee__c, Client_Assignee__c from  Project_Task__c where id =: task1.id ];
        system.assertEquals(activity.CDK_Assignee__c, tsk.CDK_Assignee__c);
        system.assertEquals(activity.Client_Assignee__c, tsk.Client_Assignee__c);
        Test.stopTest();
    }
    
    static testMethod void rollDownAssigneeOnlyifTaskisNull()
    {
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);          
        insert activity;
        
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);   
        task1.Actual_Start_Date__c = null;
        insert task1;
        
        User user_cdkAssignee2 = IMP_TestFactory_Helper.buildUser();
        insert user_cdkAssignee2;
        
        Contact contact_clientAssignee2 = IMP_TestFactory_Helper.buildContact(account.Id);
        insert contact_clientAssignee2;
       
        Project_Task__c task2 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false); 
        task2.Actual_Start_Date__c = null;
        task2.CDK_Assignee__c = user_cdkAssignee2.Id;
        task2.Client_Assignee__c = contact_clientAssignee.id;
        insert task2;
        
        Test.StartTest();
        
        activity.CDK_Assignee__c = user_cdkAssignee.Id;
        activity.Client_Assignee__c = contact_clientAssignee.id;
        update activity;
        //test if the task with null assignee will be updated and task with non-null assignee value is not replace
        Project_Task__c tsk = [Select CDK_Assignee__c, Client_Assignee__c from  Project_Task__c where id =: task1.id ]; 
        system.assertEquals(activity.CDK_Assignee__c, tsk.CDK_Assignee__c);
        system.assertEquals(activity.Client_Assignee__c, tsk.Client_Assignee__c);
        
        Project_Task__c tsk2 = [Select CDK_Assignee__c, Client_Assignee__c from  Project_Task__c where id =: task2.id ];
        system.assertEquals(user_cdkAssignee2.Id, tsk2.CDK_Assignee__c);
        system.assertEquals(contact_clientAssignee.id, tsk2.Client_Assignee__c);
        Test.stopTest();
    }
    
    static testMethod void rollDownOnlyCDKAssignee()
    {
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);          
        insert activity;
        
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);   
        task1.Actual_Start_Date__c = null;
        insert task1;
        
        User user_cdkAssignee2 = IMP_TestFactory_Helper.buildUser();
        insert user_cdkAssignee2;
        
        Contact contact_clientAssignee2 = IMP_TestFactory_Helper.buildContact(account.Id);
        insert contact_clientAssignee2;
        
        Project_Task__c task2 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false); 
        task2.Actual_Start_Date__c = null;
        task2.CDK_Assignee__c = user_cdkAssignee2.Id;
        task2.Client_Assignee__c = contact_clientAssignee.id;
        insert task2;
        
        Test.StartTest();
        
        activity.CDK_Assignee__c = user_cdkAssignee.Id;        
        update activity;
        //test if the task cdk assignee will be updated
        Project_Task__c tsk = [Select CDK_Assignee__c, Client_Assignee__c from  Project_Task__c where id =: task1.id ]; 
        system.assertEquals(activity.CDK_Assignee__c, tsk.CDK_Assignee__c);
        system.assertEquals(activity.Client_Assignee__c, null);
        
        Project_Task__c tsk2 = [Select CDK_Assignee__c, Client_Assignee__c from  Project_Task__c where id =: task2.id ];
        system.assertEquals(user_cdkAssignee2.Id, tsk2.CDK_Assignee__c);
        system.assertEquals(contact_clientAssignee.id, tsk2.Client_Assignee__c);
        Test.stopTest();
    }
    
    static testMethod void rollDownOnlyClientAssignee()
    {
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);          
        insert activity;
        
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);   
        task1.Actual_Start_Date__c = null;
        insert task1;
        
        User user_cdkAssignee2 = IMP_TestFactory_Helper.buildUser();
        insert user_cdkAssignee2;
        
        Contact contact_clientAssignee2 = IMP_TestFactory_Helper.buildContact(account.Id);
        insert contact_clientAssignee2;
        
        Project_Task__c task2 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false); 
        task2.Actual_Start_Date__c = null;
        task2.CDK_Assignee__c = user_cdkAssignee2.Id;
        task2.Client_Assignee__c = contact_clientAssignee.id;
        insert task2;
        
        Test.StartTest();        
        
        activity.Client_Assignee__c = contact_clientAssignee.id;
        update activity;
        
        //test if the task client assignee will be updated
        Project_Task__c tsk = [Select CDK_Assignee__c, Client_Assignee__c from  Project_Task__c where id =: task1.id ]; 
        system.assertEquals(activity.CDK_Assignee__c, null);
        system.assertEquals(activity.Client_Assignee__c, tsk.Client_Assignee__c);
        
        Project_Task__c tsk2 = [Select CDK_Assignee__c, Client_Assignee__c from  Project_Task__c where id =: task2.id ];
        system.assertEquals(user_cdkAssignee2.Id, tsk2.CDK_Assignee__c);
        system.assertEquals(contact_clientAssignee.id, tsk2.Client_Assignee__c);
        Test.stopTest();
    }
}