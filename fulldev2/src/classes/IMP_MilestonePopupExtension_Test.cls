/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: IMP_MilestonePopup_Extension test class
History
09/17/14    Michael Lasala      Created
10/02/14    Rey Austral         Add dealer group in sub project
11/18/14    Samuel Oberes       Fixed buildSubProject parameter
01/03/15    Karl Simon          Added CMF_Info and SubprojectSite record generation and insertion logic into the createNewStandardRecord_Test method.
The addition accommodates the decommissioning of prior functionality that auto-generated a Subproject Site upon population or change of the Subproject__c.Main_Site__c
field (which is planned for de-commission during Phase 1 R3).
04/29/15    Samuel Oberes       Fixed errors in insertWithError_Test and moreThan1terminalTaskError_Test
------------------------------------------------------------*/
@isTest
public class IMP_MilestonePopupExtension_Test 
{
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
    
    static testMethod void createNewNonStandardRecord_Test() 
    {
        Project_Milestone__c testProjectMilestone = new Project_Milestone__c();
        
        Test.StartTest();
        
        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(testProjectMilestone);
        ApexPages.CurrentPage().getParameters().put('subProjectId', subProject.Id);
        ApexPages.CurrentPage().getParameters().put('standard', 'false');
        IMP_MilestonePopup_Extension popup = new IMP_MilestonePopup_Extension(standardCon);
        popup.createNewActivity();
        popup.projectMilestone.Description__c = 'Test';
        popup.projectActivityList.get(0).activity.Description__c = 'Test';
        popup.projectActivityList.get(0).activity.Planned_Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() );
        popup.projectActivityList.get(0).activity.Planned_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 1);
        popup.projectActivityList.get(0).activity.CDK_Assignee__c =  user_cdkAssignee.Id;
        popup.projectActivityList.get(0).activity.Client_Assignee__c =  contact_clientAssignee.Id;
        popup.projectActivityList.get(0).activity.CDK_Assignee_Role__c = '3PA';
        //popup.projectActivityList.get(0).activity.Terminal_Activity__c = true;
        
        //popup.projectActivityList.get(0).projectTask.get(0).task.Terminal_Task__c = true;
        popup.projectActivityList.get(0).projectTask.get(0).task.Description__c = 'test task';
        popup.projectActivityList.get(0).projectTask.get(0).task.Expected_Time_Spent__c = 1;
        popup.saveRecords();
        
        Test.StopTest();
        
        List<Project_Milestone__c> createdProjectMilestoneList = [SELECT Id FROM Project_Milestone__c WHERE SubProject__c =: subProject.Id];
        List<Project_Activity__c> createdProjectActivityList = [SELECT Id FROM Project_Activity__c WHERE Milestone__c =: createdProjectMilestoneList.get(0).Id];
        List<Project_Task__c> createdProjectTaskList = [SELECT Id FROM Project_Task__c WHERE Project_Activity__c =: createdProjectActivityList.get(0).Id];
        
        System.assertEquals(project.Id, subProject.Project__c);
        System.assertEquals(subProject.Id, popup.subProjectId);
        System.assertEquals(subProject.Id, popup.subProject.Id);
     
        System.assertNotEquals(0, createdProjectMilestoneList.size());
        System.assertNotEquals(0, createdProjectActivityList.size());
        System.assertNotEquals(0, createdProjectTaskList.size());
    }
    
    static testMethod void insertWithError_Test()
    {
      
        Project_Milestone__c testProjectMilestone = new Project_Milestone__c();
        
        Test.StartTest();
        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(testProjectMilestone);
        ApexPages.CurrentPage().getParameters().put('subProjectId', subproject.Id);       
        IMP_MilestonePopup_Extension popup = new IMP_MilestonePopup_Extension(standardCon);
        popup.projectMilestone.Description__c = 'Test';
        popup.createNewActivity();
        //popup.projectActivityList.get(0).activity.Terminal_Activity__c = true;
        //popup.projectActivityList.get(0).projectTask.get(0).task.Terminal_Task__c = true;
        popup.projectActivityList.get(0).projectTask.get(0).task.Description__c = 'test task';
        popup.projectActivityList.get(0).activity.Description__c = 'test0';      
        popup.createNewActivity();
        //popup.projectActivityList.get(1).activity.Terminal_Activity__c = false;
        popup.projectActivityList.get(1).activity.Description__c = 'test';        
        //popup.projectActivityList.get(1).projectTask.get(0).task.Terminal_Task__c = true;   
        popup.projectActivityList.get(1).projectTask.get(0).task.Expected_Time_Spent__c = 1;
        popup.projectActivityList.get(1).projectTask.get(0).task.Actual_End_Date__c =  Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() );
        
        popup.saveRecords();
        
        Test.StopTest();
        
        Boolean isError = false;
      
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages();       
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {                 
                if(msg.getDetail().contains('Actual End Date cannot be entered before you enter a value for Actual Days Spent.'))
                {
                    isError = true;
                }
            }
        }  
       
        System.assert(isError);
    }
    
    static testMethod void addAdditionalTask_Test()
    {
        Project_Milestone__c testProjectMilestone = new Project_Milestone__c();
        
        Test.StartTest();
        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(testProjectMilestone);
        ApexPages.CurrentPage().getParameters().put('subProjectId', subProject.Id);
        ApexPages.CurrentPage().getParameters().put('standard', 'false');
        IMP_MilestonePopup_Extension popup = new IMP_MilestonePopup_Extension(standardCon);
        
        popup.createNewActivity();
        popup.projectMilestone.Description__c = 'Test';
        popup.projectActivityList.get(0).activity.Description__c = 'Test';
        popup.projectActivityList.get(0).activity.Planned_Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() );
        popup.projectActivityList.get(0).activity.Planned_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 1);
        popup.projectActivityList.get(0).activity.CDK_Assignee__c =  user_cdkAssignee.Id;
        popup.projectActivityList.get(0).activity.Client_Assignee__c =  contact_clientAssignee.Id;
        popup.projectActivityList.get(0).activity.CDK_Assignee_Role__c = '3PA';
        
        //popup.projectActivityList.get(0).activity.Terminal_Activity__c = true;
        //popup.projectActivityList.get(0).projectTask.get(0).task.Terminal_Task__c = true;
        popup.projectActivityList.get(0).projectTask.get(0).task.Description__c = 'test task';
        popup.projectActivityList.get(0).projectTask.get(0).task.Expected_Time_Spent__c = 1;
        
        popup.activityExternalId = popup.projectActivityList.get(0).activity.External_ID__c;
        popup.createNewTask();
        //popup.projectActivityList.get(0).projectTask.get(0).task.Terminal_Task__c = true;
        popup.projectActivityList.get(0).projectTask.get(0).task.Description__c = 'test task 2';
        popup.projectActivityList.get(0).projectTask.get(0).task.Expected_Time_Spent__c = 1;
        popup.saveRecords();
        Test.StopTest();
        
        List<Project_Milestone__c> createdProjectMilestoneList = [SELECT Id FROM Project_Milestone__c WHERE SubProject__c =: subProject.Id];
        List<Project_Activity__c> createdProjectActivityList = [SELECT Id FROM Project_Activity__c WHERE Milestone__c =: createdProjectMilestoneList.get(0).Id];
        List<Project_Task__c> createdProjectTaskList = [SELECT Id FROM Project_Task__c WHERE Project_Activity__c =: createdProjectActivityList.get(0).Id];
        
        System.assertNotEquals(0, createdProjectMilestoneList.size());
        System.assertNotEquals(0, createdProjectActivityList.size());
        System.assertEquals(2, createdProjectTaskList.size());
    }
    
    static testMethod void deleteActivity_Test()
    {
        Project_Milestone__c testProjectMilestone = new Project_Milestone__c();
        
        Test.StartTest();
        
        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(testProjectMilestone);
        ApexPages.CurrentPage().getParameters().put('subProjectId', subProject.Id);
        ApexPages.CurrentPage().getParameters().put('standard', 'false');
        IMP_MilestonePopup_Extension popup = new IMP_MilestonePopup_Extension(standardCon);
        
        popup.createNewActivity();
        popup.createNewActivity();
        popup.activityIndex = '1';
        popup.deleteNewActivity();
        
        Test.StopTest();
        
        System.assertEquals(1, popup.projectActivityList.size());
    }
    
    static testMethod void deleteTask_Test()
    {
        Project_Milestone__c testProjectMilestone = new Project_Milestone__c();
        
        Test.StartTest();
        
        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(testProjectMilestone);
        ApexPages.CurrentPage().getParameters().put('subProjectId', subProject.Id);
        ApexPages.CurrentPage().getParameters().put('standard', 'false');
        IMP_MilestonePopup_Extension popup = new IMP_MilestonePopup_Extension(standardCon);
        
        popup.createNewActivity();
        popup.activityExternalId = popup.projectActivityList.get(0).activity.External_ID__c;
     	popup.createNewTask();
        popup.taskIndex = '1';
        popup.deleteNewTask();
        
        Test.StopTest();
        
        System.assertEquals(1, popup.projectActivityList.get(0).projectTask.size());
    }
    
    static testMethod void validateSaving_Test()
    {
        Project_Milestone__c testProjectMilestone = new Project_Milestone__c();
        
        Test.StartTest();
        
        ApexPages.Standardcontroller standardCon = new ApexPages.Standardcontroller(testProjectMilestone);
        ApexPages.CurrentPage().getParameters().put('subProjectId', subProject.Id);
        ApexPages.CurrentPage().getParameters().put('standard', 'false');
        IMP_MilestonePopup_Extension popup = new IMP_MilestonePopup_Extension(standardCon);
        
        popup.projectMilestone.Description__c = 'Test';
        popup.saveRecords();
        
        Boolean isError = false;
       
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {              
                if(msg.getDetail().contains( IMP_String_Utility.MILESTONE_AT_LEAST_ONE_ACTIVITY ))
                {
                    isError = true;
                }
            }
        }
       
        System.assert(isError);
        ApexPages.getMessages().clear();  
        popup.createNewActivity();
        popup.projectActivityList.get(0).activity.Description__c = 'Test';
        popup.projectActivityList.get(0).activity.Planned_Start_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() );
        popup.projectActivityList.get(0).activity.Planned_End_Date__c = Date.newInstance(Date.today().year(), Date.today().month(), Date.today().day() + 1);
        popup.projectActivityList.get(0).activity.CDK_Assignee__c =  user_cdkAssignee.Id;
        popup.projectActivityList.get(0).activity.Client_Assignee__c =  contact_clientAssignee.Id;
        popup.projectActivityList.get(0).activity.CDK_Assignee_Role__c = '3PA';
        
        popup.activityExternalId = popup.projectActivityList.get(0).activity.External_ID__c;
        popup.taskIndex = '0';
        popup.deleteNewTask();
        popup.saveRecords();
        
        Boolean isError2 = false;
       
        errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {   
                
                if(msg.getDetail().contains( 'Activity should have at least 1 Task' ))
                {
                    isError2 = true;
                }
            }
        }
       
        System.assert(isError2);
        
        Test.StopTest();
        
       
    }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
}