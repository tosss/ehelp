/*------------------------------------------------------------
    Author:      Kimiko Roberto
    Company:     Cloud Sherpas
    Description: Test class for IMP_SetMigrationIDtoDefinitions_Handler
    Inputs:      
    Returns:     
    History
    07/28/15     Kimiko Roberto    Created
	10/28/15	 Rey Austral	   Add a new test method called checkIfExistingMigrationIdIsNotChange
    ------------------------------------------------------------*/
@isTest
public class IMP_SetMigrationIDtoDefinitions_Test
{

    static
    {
        CustomSettings__c cs = IMP_TestFactory_Helper.buildCustomSettings();
        insert cs;
    }
    
    static testMethod void setMigrationIDMilestoneActTask()
    {
        //Milesteone Definition Creation
        Milestone_Definition__c newMilestoneDef = IMP_TestFactory_Helper.buildMilestoneDefinition();
        insert newMilestoneDef;
        
        Milestone_Definition__c createdMilestoneDef = [SELECT Name, Migration_ID__c, Active__c FROM Milestone_Definition__c WHERE Id =:newMilestoneDef.Id];
        
        //assert migration id value
        system.Assert(createdMilestoneDef.Migration_ID__c == createdMilestoneDef.Name + ':' +'TEST');

        
        //Activity Definition Creation
        Activity_Definition__c newActivityDef = IMP_TestFactory_Helper.buildActivityDefinition(newMilestoneDef.Id);
        insert newActivityDef;
        
        system.Debug('**We just inserted activity definition. Here are the values at this moment*****');
        system.Debug('****newActivityDef.RMS_Assignment_Type__c:' + newActivityDef.RMS_Assignment_Type__c);
        system.Debug('****newActivityDef.Total_Task_Definition_Children__c:' + newActivityDef.Total_Task_Definition_Children__c);
        system.Debug('****newActivityDef.Count_of_Children_RMS_Owned__c:' + newActivityDef.Count_of_Children_RMS_Owned__c);
        system.Debug('****newActivityDef.Active__c:' + newActivityDef.Active__c);
        system.Debug('****newActivityDef.Count_of_Children_Non_RMS_Owned__c :' + newActivityDef.Count_of_Children_Non_RMS_Owned__c );
        
        
        Activity_Definition__c createdActivityDef = [SELECT Name, Migration_ID__c, Active__c FROM Activity_Definition__c WHERE Id =:newActivityDef.Id];
        
        //assert migration id value
        system.Assert(createdActivityDef.Migration_ID__c == createdActivityDef.Name + ':' +'TEST');
        
        //Task Definition Creation
        Task_Definition__c newTaskDef = IMP_TestFactory_Helper.buildTaskDefinition(newActivityDef.Id);
        insert newTaskDef;
        
        system.Debug('**We just inserted Task definition. Here are the values at this moment*****');
        system.Debug('****newActivityDef.RMS_Assignment_Type__c:' + newActivityDef.RMS_Assignment_Type__c);
        system.Debug('****newActivityDef.Total_Task_Definition_Children__c:' + newActivityDef.Total_Task_Definition_Children__c);
        system.Debug('****newActivityDef.Count_of_Children_RMS_Owned__c:' + newActivityDef.Count_of_Children_RMS_Owned__c);
        system.Debug('****newActivityDef.Active__c:' + newActivityDef.Active__c);
        system.Debug('****newActivityDef.Count_of_Children_Non_RMS_Owned__c :' + newActivityDef.Count_of_Children_Non_RMS_Owned__c );
        
        Task_Definition__c createdTaskDef = [SELECT Name, Migration_ID__c,Active__c FROM Task_Definition__c WHERE Id =:newTaskDef.Id];
        
        //assert migration id value
        system.Assert(createdTaskDef.Migration_ID__c == createdTaskDef.Name + ':' +'TEST');
        
        
        //activate the definitions
        createdTaskDef.Active__c = true;
        update createdTaskDef;
        
        system.Debug('**We just activated Task definition. Here are the values at this moment*****');
        system.Debug('****newActivityDef.RMS_Assignment_Type__c:' + newActivityDef.RMS_Assignment_Type__c);
        system.Debug('****newActivityDef.Total_Task_Definition_Children__c:' + newActivityDef.Total_Task_Definition_Children__c);
        system.Debug('****newActivityDef.Count_of_Children_RMS_Owned__c:' + newActivityDef.Count_of_Children_RMS_Owned__c);
        system.Debug('****newActivityDef.Active__c:' + newActivityDef.Active__c);
        system.Debug('****newActivityDef.Count_of_Children_Non_RMS_Owned__c :' + newActivityDef.Count_of_Children_Non_RMS_Owned__c );
        
        createdActivityDef.Active__c = true;
        update createdActivityDef;
        
        system.Debug('**We just activated Activity definition. Here are the values at this moment*****');
        system.Debug('****newActivityDef.RMS_Assignment_Type__c:' + newActivityDef.RMS_Assignment_Type__c);
        system.Debug('****newActivityDef.Total_Task_Definition_Children__c:' + newActivityDef.Total_Task_Definition_Children__c);
        system.Debug('****newActivityDef.Count_of_Children_RMS_Owned__c:' + newActivityDef.Count_of_Children_RMS_Owned__c);
        system.Debug('****newActivityDef.Active__c:' + newActivityDef.Active__c);
        system.Debug('****newActivityDef.Count_of_Children_Non_RMS_Owned__c :' + newActivityDef.Count_of_Children_Non_RMS_Owned__c );
        
        createdMilestoneDef.Active__c = true;
        update createdMilestoneDef;
        
        system.Debug('**We just activated Milestone definition. Here are the values at this moment*****');
        system.Debug('****newActivityDef.RMS_Assignment_Type__c:' + newActivityDef.RMS_Assignment_Type__c);
        system.Debug('****newActivityDef.Total_Task_Definition_Children__c:' + newActivityDef.Total_Task_Definition_Children__c);
        system.Debug('****newActivityDef.Count_of_Children_RMS_Owned__c:' + newActivityDef.Count_of_Children_RMS_Owned__c);
        system.Debug('****newActivityDef.Active__c:' + newActivityDef.Active__c);
        system.Debug('****newActivityDef.Count_of_Children_Non_RMS_Owned__c :' + newActivityDef.Count_of_Children_Non_RMS_Owned__c );
    }
    
    static testMethod void checkIfExistingMigrationIdIsNotChange()
    {
         //Milesteone Definition Creation
        Milestone_Definition__c newMilestoneDef = IMP_TestFactory_Helper.buildMilestoneDefinition();
        newMilestoneDef.Migration_ID__c = 'Old MilesMigration';
        insert newMilestoneDef;
        
        Milestone_Definition__c createdMilestoneDef = [SELECT Name, Migration_ID__c, Active__c FROM Milestone_Definition__c WHERE Id =:newMilestoneDef.Id];
        
        //assert migration id value
        system.Assert(createdMilestoneDef.Migration_ID__c != createdMilestoneDef.Name + ':' +'TEST');
		system.assertEquals('Old MilesMigration', createdMilestoneDef.Migration_ID__c);
        
        //Activity Definition Creation
        Activity_Definition__c newActivityDef = IMP_TestFactory_Helper.buildActivityDefinition(newMilestoneDef.Id);
        newActivityDef.Migration_ID__c = 'Old ActMigration';
        insert newActivityDef;
        
        system.Debug('**We just inserted activity definition. Here are the values at this moment*****');
        system.Debug('****newActivityDef.RMS_Assignment_Type__c:' + newActivityDef.RMS_Assignment_Type__c);
        system.Debug('****newActivityDef.Total_Task_Definition_Children__c:' + newActivityDef.Total_Task_Definition_Children__c);
        system.Debug('****newActivityDef.Count_of_Children_RMS_Owned__c:' + newActivityDef.Count_of_Children_RMS_Owned__c);
        system.Debug('****newActivityDef.Active__c:' + newActivityDef.Active__c);
        system.Debug('****newActivityDef.Count_of_Children_Non_RMS_Owned__c :' + newActivityDef.Count_of_Children_Non_RMS_Owned__c );
        
        
        Activity_Definition__c createdActivityDef = [SELECT Name, Migration_ID__c, Active__c FROM Activity_Definition__c WHERE Id =:newActivityDef.Id];
        
        //assert migration id value
        system.Assert(createdActivityDef.Migration_ID__c != createdActivityDef.Name + ':' +'TEST');
        system.assertEquals('Old ActMigration', createdActivityDef.Migration_ID__c);
        
        //Task Definition Creation
        Task_Definition__c newTaskDef = IMP_TestFactory_Helper.buildTaskDefinition(newActivityDef.Id);
        newTaskDef.Migration_ID__c = 'Old TaskMigration';
        insert newTaskDef;
        
        system.Debug('**We just inserted Task definition. Here are the values at this moment*****');
        system.Debug('****newActivityDef.RMS_Assignment_Type__c:' + newActivityDef.RMS_Assignment_Type__c);
        system.Debug('****newActivityDef.Total_Task_Definition_Children__c:' + newActivityDef.Total_Task_Definition_Children__c);
        system.Debug('****newActivityDef.Count_of_Children_RMS_Owned__c:' + newActivityDef.Count_of_Children_RMS_Owned__c);
        system.Debug('****newActivityDef.Active__c:' + newActivityDef.Active__c);
        system.Debug('****newActivityDef.Count_of_Children_Non_RMS_Owned__c :' + newActivityDef.Count_of_Children_Non_RMS_Owned__c );
        
        Task_Definition__c createdTaskDef = [SELECT Name, Migration_ID__c,Active__c FROM Task_Definition__c WHERE Id =:newTaskDef.Id];
        
        //assert migration id value
        system.Assert(createdTaskDef.Migration_ID__c != createdTaskDef.Name + ':' +'TEST'); 
        system.assertEquals('Old TaskMigration', createdTaskDef.Migration_ID__c);
    }
    

}