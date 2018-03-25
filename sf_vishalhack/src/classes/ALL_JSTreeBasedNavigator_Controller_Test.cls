/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test Class for ALL_JSTreeBasedNavigator_Controller
History
07/06/15     Rey Austral      Created
12/06/16     Venkata Shrivol  commented the project object reference RQ-08305
12/12/16     Venkata shrivol  commented the class as it is no longer required
------------------------------------------------------------*/
@isTest
public class ALL_JSTreeBasedNavigator_Controller_Test 
{
   /* private static final String GENERIC_MILESTONE_DESCRIPTION = 'TEST MILESTONE DESCRIPTION';    
    //private static final Project__c project { get; set; }
    private static final SubProject__c subProject { get; set; }
    
    static 
    {
        /*project = IMP_TestFactory_Helper.buildProject(0);
        insert project;
        
        subProject = IMP_TestFactory_Helper.buildSubProject();
        insert subProject;
        
    }
    
    static testMethod void constructorWithRecords_Test() 
    {
        // --------------------------------------------------------------------
        // INITIALIZATION
        
        createCustomSettings();
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);
        //task.Terminal_Task__c = true;
        insert task;
        
        CustomSettings__c cust = IMP_TestFactory_Helper.buildCustomSettings();
        insert cust;
        // --------------------------------------------------------------------
        // TESTING PROPER
        
        PageReference pRef=Page.ALL_RecordsView;
        Test.setCurrentPage(pRef);
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        ALL_RecordsView_Controller controller = new ALL_RecordsView_Controller();    
       
        ALL_JSTreeBasedNavigator_Controller treeController = new ALL_JSTreeBasedNavigator_Controller();
        treeController.pageController = controller.getThis();
        treeController.key = 'treeComponent';
        
        treeController.triggerRefresh = true;
        Test.StopTest();
        //check if the variable generatedJSON in the ALL_JSTreeBasedNavigator_Controller has value
        system.assert(treeController.generatedJSON.contains(milestone.Description__c));
        //check of the maxSelectedRecord has the same value if the custom settings
        system.assertEquals(treeController.maxSelectedRecord, cust.Max_Milestone_Tree_Threshold__c);
    }
    
    static testMethod void selectTreeRecords_Test() 
    {
        // --------------------------------------------------------------------
        // INITIALIZATION
        
        createCustomSettings();
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);     
        insert task;        
     
        Project_Milestone__c milestone2 = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        milestone2.Description__c = milestone2.Description__c + '123456789012345678901234567890';
        insert milestone2;
        
        Project_Activity__c activity2 = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity2;
        
        Project_Task__c task2 = IMP_TestFactory_Helper.buildProjectTask(activity.Id);        
        insert task2;
        
        IMP_TestFactory_Helper.buildCustomSettings();
        // --------------------------------------------------------------------
        // TESTING PROPER
        
        PageReference pRef=Page.ALL_RecordsView;
        Test.setCurrentPage(pRef);
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        
        ALL_RecordsView_Controller controller = new ALL_RecordsView_Controller();    
       
        ALL_JSTreeBasedNavigator_Controller treeController = new ALL_JSTreeBasedNavigator_Controller();
        treeController.pageController = controller.getThis();
        treeController.key = 'treeComponent';
        
        treeController.triggerRefresh = true;
        
        treeController.openedIds = milestone.id;
        treeController.parentObjectName = 'Project_Milestone__c';
        treeController.childObjectName = 'Project_Activity__c';
        treeController.checkedParentIds= milestone.id;
        treeController.checkedChildIds = activity.id;
        treeController.somethingSelected();
        
        treeController.triggerRefresh = true;
        Test.StopTest();
        //check if the varibale attributesCollection in ALL_RecordsView_Controller contains a value
        system.assertEquals('Project_Milestone__c', controller.attributesCollection.parentAPIName);
    }
    
    private static void createCustomSettings()
    {
        ALL_JSTree_Relationship__c rel = new ALL_JSTree_Relationship__c();
        rel.Name = 'MilestoneEdit_1';
        rel.Parent_Object__c = 'Project_Milestone__c';
        rel.Child_Relationship__c = 'Project_Activities__r';
        rel.Order__c = 1;
        rel.Key__c = 'Milestone';
        rel.Child_Object__c = 'Project_Activity__c';
        rel.Parent_Description__c = 'Milestones';
        rel.Child_Description__c = 'Activities';
        rel.Parent_Fieldset__c = 'Milestone_Edit_Common';
        rel.Child_Fieldset__c = 'Activity_Edit_Common';
        rel.Field_To_Sort_Parent_Record__c = 'Description__c';
        rel.Parent_Relationship_Field_Name__c = 'Milestone__c';
        rel.Parent_Requires_Children__c = true;
        //rel.Child_Requires_Children__c = true;
        rel.Parent_FieldOrderSet__c = 'Milestone_Sort_Commons';
        rel.Child_FieldOrderSet__c = 'Activity_Sort_Commons';
        rel.Parent_FieldstoDisableForRow__c = 'RMS_Owner_Disable_Fields_Set';
        rel.Child_FieldstoDisableForRow__c = 'RMS_Owner_Disable_Fields_Set';
        rel.Parent_DisableCheckField__c='RMS_Owned_Flag__c';
        rel.Child_DisableCheckField__c='RMS_Owned_Flag__c';
        insert rel;
        
        ALL_JSTree_Relationship__c rel2 = new ALL_JSTree_Relationship__c();
        rel2.Name = 'MilestoneEdit_2';
        rel2.Parent_Object__c = 'Project_Activity__c';
        rel2.Child_Relationship__c = 'Project_Tasks__r';
        rel2.Order__c = 2;
        rel2.Key__c = 'Milestone';
        rel2.Child_Object__c = 'Project_Task__c';
        rel2.Parent_Description__c = 'Activities';
        rel2.Child_Description__c = 'Tasks';
        rel2.Parent_Fieldset__c = 'Activity_Edit_Common';
        rel2.Child_Fieldset__c = 'Task_Edit_Commons';
        rel2.Field_To_Sort_Parent_Record__c = 'Description__c';
        rel2.Parent_Relationship_Field_Name__c = 'Project_Activity__c';
        rel2.Parent_Requires_Children__c = true;
        rel2.Parent_Create_Enabled__c = true;
        rel2.Child_Create_Enabled__c = true;
        rel2.GrandParent_Relationship_Field__c = 'Milestone__c';
        rel2.Parent_FieldOrderSet__c = 'Activity_Sort_Commons';
        rel2.Child_FieldOrderSet__c = 'Task_Sort_Commons';
        rel2.Grandparent_Display_Field__c = 'Description__c';
        rel2.Parent_FieldstoDisableForRow__c = 'RMS_Owner_Disable_Fields_Set';
        rel2.Child_FieldstoDisableForRow__c = 'RMS_Owner_Disable_Fields_Set';
        rel2.Parent_DisableCheckField__c='RMS_Owned_Flag__c';
        rel2.Child_DisableCheckField__c='RMS_Owned_Flag__c';
        insert rel2;
        
        ALL_JSTree_Fields__c field = new ALL_JSTree_Fields__c();
        field.Name = 'MilestoneEdit_1';
        field.Key__c = 'Milestone';
        field.Condition_Field__c = 'SubProject__c';
        field.Object_Name__c = 'Project_Milestone__c';
        field.Description_Field_Name__c = 'Description__c';
        field.Field_Order_Set__c = 'Milestone_Sort_Commons';
        
        insert field;
        
        ALL_JSTree_Fields__c field2 = new ALL_JSTree_Fields__c();
        field2.Name = 'MilestoneEdit_2';
        field2.Key__c = 'Milestone';
        field2.Condition_Field__c = 'SubProject_ID__c';
        field2.Object_Name__c = 'Project_Activity__c';
        field2.Description_Field_Name__c = 'Description__c';
        field2.Field_Order_Set__c = 'Activity_Sort_Commons';
        field2.Parent_Field_Name__c = 'Milestone__c';
        insert field2;
    }*/
}