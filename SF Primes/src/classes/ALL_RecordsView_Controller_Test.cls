@isTest
public class ALL_RecordsView_Controller_Test 
{
    private static final String GENERIC_MILESTONE_DESCRIPTION = 'TEST MILESTONE DESCRIPTION';    
    private static final Project__c project { get; set; }
    private static final SubProject__c subProject { get; set; }
    
    static 
    {
        project = IMP_TestFactory_Helper.buildProject(0);
        insert project;
        
        subProject = IMP_TestFactory_Helper.buildSubProject(project.Id);
        insert subProject;
    
    }
    
    static testMethod void constructorWithRecords_Test() 
    {
        // --------------------------------------------------------------------
        // INITIALIZATION
        
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(subProject.Id, GENERIC_MILESTONE_DESCRIPTION);
        insert milestone;
        
        Project_Activity__c activity = IMP_TestFactory_Helper.buildProjectActivity(milestone.Id);
        insert activity;
        
        Project_Task__c task = IMP_TestFactory_Helper.buildProjectTask(activity.Id);
        //task.Terminal_Task__c = true;
        insert task;
        
        IMP_TestFactory_Helper.buildCustomSettings();
        // --------------------------------------------------------------------
        // TESTING PROPER
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        ApexPages.CurrentPage().getHeaders().put('User-Agent', 'MSIE');
        ALL_RecordsView_Controller controller = new ALL_RecordsView_Controller();
        Test.StopTest();
        
        System.assertEquals(project.Id, subProject.Project__c);
        System.assertEquals(subProject.Id, milestone.SubProject__c);
        System.assertEquals(milestone.Id, activity.Milestone__c);
        System.assertEquals(subProject.Id, controller.objectId);
    }
        
}