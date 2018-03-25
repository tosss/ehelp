/*------------------------------------------------------------
    Author:      Kimiko Roberto
    Company:     Cloud Sherpas
    Description: Test class for IMP_CDKClientContacts_Controller
    Inputs:      
    Returns:     
    History
    02/19/15     Kimiko Roberto    Created
    12/05/16    Venkata Shrivol		Commented the project reference out RQ-08305
    ------------------------------------------------------------*/
@isTest
public class IMP_CDKClientContacts_Controller_Test
{
    
    public static final String GENERIC_MILESTONE_DESCRIPTION = 'TEST MILESTONE DESCRIPTION';
    
    //public static final Project__c project { get; set; }
    public static final SubProject__c subProject { get; set; }
    public static final Account account { get; set; }
    public static final User user_cdkAssignee { get; set; }
    public static final Contact contact_clientAssignee { get; set; }
    public static final Project_Activity__c activity {get;set;}
    public static final Project_Milestone__c milestone {get;set;}
    
    //create required data to enable task creation
    static {
        /*project = IMP_TestFactory_Helper.buildProject(0);
        insert project;*/
        
        subProject = IMP_TestFactory_Helper.buildSubProject();
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
        activity.Client_Assignee__c = contact_clientAssignee.Id;
        insert activity;   
    }
    
    
    static testMethod void checkSubProjectCDKContactswithDuplicate()
    {
        //add a contact that will be shown at the virtual table
        SubProject_CDK_Contact__c cdkContact = new SubProject_CDK_Contact__c(CDK_Contact__c = user_cdkAssignee.Id, Role__c = '3PA', SubProject__c = subProject.Id);
        insert cdkContact;
        
        //add a CDK asignee the same with the cdkContact created to test if it will only show 1 contact at the table
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        task1.CDK_Assignee__c = user_cdkAssignee.Id;
        task1.Client_Assignee__c = contact_clientAssignee.Id;
        insert task1;
        
        PageReference page = new PageReference('/apex/IMP_CDKClientContacts?id='+subProject.Id);  
        test.setCurrentPage(page);
        
        IMP_CDKClientContacts_Controller cont = new IMP_CDKClientContacts_Controller();

        Boolean isContactVisible = !cont.cdkContactsMap.isEmpty();
         
        //assert that the contact was retrieved and only has a size of 1
        system.Assert(isContactVisible == true);
        system.ASsert(cont.cdkContactsMap.size() == 1);
        
    
    }
    
     
    static testMethod void checkSubProjectCDKContacts()
    {
        
        //add a CDK asignee at the task
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        task1.CDK_Assignee__c = user_cdkAssignee.Id;
        task1.Client_Assignee__c = contact_clientAssignee.Id;
        insert task1;
        
        PageReference page = new PageReference('/apex/IMP_CDKClientContacts?id='+subProject.Id);  
        test.setCurrentPage(page);
        
        IMP_CDKClientContacts_Controller cont = new IMP_CDKClientContacts_Controller();

        Boolean isContactVisible = !cont.cdkContactsMap.isEmpty();
         
        //assert that the contact was retrieved and only has a size of 1
        system.Assert(isContactVisible == true);
        system.ASsert(cont.cdkContactsMap.size() == 1);
        
    
    }
    
    static testMethod void checkSubProjectClientContacts()
    {
        
        //add a CDK asignee at the task
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        task1.CDK_Assignee__c = user_cdkAssignee.Id;
        task1.Client_Assignee__c = contact_clientAssignee.Id;
        insert task1;
        
        PageReference page = new PageReference('/apex/IMP_CDKClientContacts?id='+subProject.Id);  
        test.setCurrentPage(page);
        
        IMP_CDKClientContacts_Controller cont = new IMP_CDKClientContacts_Controller();

        Boolean isContactVisible = !cont.clientContactsMap.isEmpty();
         
        //assert that the contact was retrieved and only has a size of 1
        system.Assert(isContactVisible == true);
        system.ASsert(cont.clientContactsMap.size() == 1);
        
    
    }
    
    static testMethod void checkSubProjectClientContactsWithDuplicate()
    {
        SubProject_Client_Contact__c clientContact = new SubProject_Client_Contact__c(Client_Contact__c = contact_clientAssignee.Id, Role__c = '3PA', SubProject__c = subProject.Id);
        insert clientContact;
        //add a CDK asignee at the task
        Project_Task__c task1 = IMP_TestFactory_Helper.createTask(activity.Id, '1', false);
        task1.CDK_Assignee__c = user_cdkAssignee.Id;
        task1.Client_Assignee__c = contact_clientAssignee.Id;
        insert task1;
        
        PageReference page = new PageReference('/apex/IMP_CDKClientContacts?id='+subProject.Id);  
        test.setCurrentPage(page);
        
        IMP_CDKClientContacts_Controller cont = new IMP_CDKClientContacts_Controller();

        Boolean isContactVisible = !cont.clientContactsMap.isEmpty();
         
        //assert that the contact was retrieved and only has a size of 1
        system.Assert(isContactVisible == true);
        system.ASsert(cont.clientContactsMap.size() == 1);
        
    
    }


}