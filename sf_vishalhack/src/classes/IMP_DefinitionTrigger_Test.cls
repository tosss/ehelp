/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test class for trigger: IMP_ProjectMilestoneDefinition,IMP_ProjectActivityDefinition,IMP_ProjectTaskDefinition
History
09/16/15    Rey Austral      Created
------------------------------------------------------------*/
@isTest
public class IMP_DefinitionTrigger_Test 
{
    private static Milestone_Definition__c testActiveMilestoneDefinition { get { return [Select id from Milestone_Definition__c where Active__c = true ]; } }
    private static Activity_Definition__c testActiveActivityDefinition { get { return [Select id from Activity_Definition__c where Active__c = true ]; } }
    private static Task_Definition__c testActiveTaskDefinition { get { return [Select id from Task_Definition__c where Active__c = true ]; }  }
    private static Milestone_Definition__c testInActiveMilestoneDefinition { get { return [Select id from Milestone_Definition__c where Active__c = false ]; } }
    private static Activity_Definition__c testInActiveActivityDefinition { get { return [Select id from Activity_Definition__c where Active__c = false ]; } }
    private static Task_Definition__c testInActiveTaskDefinition { get { return [Select id from Task_Definition__c where Active__c = false ]; }  }
    
    @testSetup static void setup() 
    {
        Milestone_Definition__c testDataActiveMDef = IMP_TestFactory_Helper.buildMilestoneDefinition();        
        insert testDataActiveMDef;
        
        Activity_Definition__c testDataActiveADef = IMP_TestFactory_Helper.buildActivityDefinition(testDataActiveMDef.Id);
        insert testDataActiveADef;
        
        Task_Definition__c testDataActiveTDef =  IMP_TestFactory_Helper.buildTaskDefinition(testDataActiveADef.Id);
        testDataActiveTDef.Active__c = true;
        insert testDataActiveTDef;
        
        testDataActiveADef.Active__c = true;
        update testDataActiveADef;
        
        testDataActiveMDef.Active__c = true;
        update testDataActiveMDef;
        
        Milestone_Definition__c testDataInActiveMDef = IMP_TestFactory_Helper.buildMilestoneDefinition();        
        insert testDataInActiveMDef;
        
        Activity_Definition__c testDataInActiveADef = IMP_TestFactory_Helper.buildActivityDefinition(testDataInActiveMDef.Id);
        insert testDataInActiveADef;
        
        Task_Definition__c testDataInActiveTDef =  IMP_TestFactory_Helper.buildTaskDefinition(testDataInActiveADef.Id);      
        insert testDataInActiveTDef;
    }
    
    static testMethod void deleteActiveDefinition_Test()
    {
     	String errorMilestone = '',errorActivity='',errorTask='';   
        Test.StartTest();            
        try
        {
            delete testActiveMilestoneDefinition;
        }
        catch(Exception ex)
        {
            errorMilestone = ex.getMessage();
        }    
        
        try
        {
            delete testActiveActivityDefinition;
        }
        catch(Exception ex)
        {
            errorActivity = ex.getMessage();
        }    
        
        try
        {
            delete testActiveTaskDefinition;
        }
        catch(Exception ex)
        {
            errorTask = ex.getMessage();
        }    
        Test.StopTest();
        
      	system.assert( errorMilestone.contains(IMP_String_Utility.DELETE_ACTIVE_DEFINITION) );
        system.assert( errorActivity.contains(IMP_String_Utility.DELETE_ACTIVE_DEFINITION) );
        system.assert( errorTask.contains(IMP_String_Utility.DELETE_ACTIVE_DEFINITION) );
    }
    
    static testMethod void deleteNonActiveDefinitionWithActiveChild_Test()
    {
        String errorMilestone = '',errorActivity='',errorTask='';   
        Test.StartTest(); 
        Milestone_Definition__c deactivateMilestone = testActiveMilestoneDefinition;
        deactivateMilestone.Active__c = false;
        update deactivateMilestone;
        try
        {
            delete deactivateMilestone;
        }
        catch(Exception ex)
        {
            errorMilestone = ex.getMessage();
        }    
        Activity_Definition__c deactivateActivity = testActiveActivityDefinition;
        deactivateActivity.Active__c = false;
        update deactivateActivity;
        try
        {
            delete deactivateActivity;
        }
        catch(Exception ex)
        {
            errorActivity = ex.getMessage();
        }    
        
        try
        {
            delete testActiveTaskDefinition;
        }
        catch(Exception ex)
        {
            errorTask = ex.getMessage();
        }    
        Test.StopTest();        
      	system.assert( errorMilestone.contains(IMP_String_Utility.DELETE_HAS_ACTIVE_CHILD_ACTIVITY) );
        system.assert( errorActivity.contains(IMP_String_Utility.DELETE_HAS_ACTIVE_CHILD_TASK) );
        system.assert( errorTask.contains(IMP_String_Utility.DELETE_ACTIVE_DEFINITION) );
    }
    
    static testMethod void deleteInActiveDefinition_Test()
    {
        Test.StartTest();
        delete testInActiveTaskDefinition;
        delete testInActiveActivityDefinition;
        delete testInActiveMilestoneDefinition;
        Test.stopTest();
        integer countMilestone = database.countQuery('Select count() from Milestone_Definition__c where Active__c = false ');
        integer countActivity = database.countQuery('Select count() from Activity_Definition__c where Active__c = false ');
        integer countTask = database.countQuery('Select count() from Task_Definition__c where Active__c = false ');
        system.assertEquals(0, countMilestone);   
        system.assertEquals(0, countActivity);   
        system.assertEquals(0, countTask);   
    }
}