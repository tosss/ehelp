/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: 
Test Class: 
History
10/29/15    Kimiko Roberto      Created
12/05/16    Venkata Shrivol		Commented the project reference out RQ-08305
------------------------------------------------------------*/
@isTest
public class IMP_ForceLogicalRollup_Batch_Test{
    
    static testMethod void batchForceRollup_Test(){
        
       /* Project__c testProject = IMP_TestFactory_Helper.buildProject(1);
        insert testProject;*/
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject();
        insert testSubProject;
        
        Project_Milestone__c testMilestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testSubProject.Id, 'Test Milestone 1');
        insert testMilestone;
        
        Project_Activity__c testActivity = IMP_TestFactory_Helper.buildProjectActivity(testMilestone.Id);
        insert testActivity;
        
        Project_Task__c testTask = IMP_TestFactory_Helper.buildProjectTask(testActivity.Id);
        insert testTask;
        
        SubProject__c initialSubprojectwithTaskValue = [SELECT Count_of_Tasks_on_SubProject__c FROM SubProject__c WHERE Id = : testSubProject.Id];
        system.Debug('**initialSubprojectwithTaskValue : '+initialSubprojectwithTaskValue.Count_of_Tasks_on_SubProject__c);
        system.Assert(initialSubprojectwithTaskValue.Count_of_Tasks_on_SubProject__c == 1);
        
        //update Project Milestone total task to 0, so we can do the force rollup
        Project_Milestone__c emptyTotalTaskMilestone = [SELECT Total_Tasks__c FROM Project_Milestone__c WHERE Id = : testMilestone.Id];
        emptyTotalTaskMilestone.Total_Tasks__c = 0;
        update emptyTotalTaskMilestone;
        
        SubProject__c updatedSubprojectwithoutTask = [SELECT Count_of_Tasks_on_SubProject__c FROM SubProject__c WHERE Id = : testSubProject.Id];
        system.Debug('**updatedSubprojectwithoutTask : '+updatedSubprojectwithoutTask.Count_of_Tasks_on_SubProject__c);
        system.Assert(updatedSubprojectwithoutTask.Count_of_Tasks_on_SubProject__c == 0);
        
        //use the forcerollup batch to rollup the task up to the subproject level.
        Test.startTest();
        IMP_ForceLogicalRollup_Batch forceRollupBatch = new IMP_ForceLogicalRollup_Batch();
        forceRollupBatch.milestoneCount = 0;
        Database.executeBatch(forceRollupBatch);
        Test.stopTest();
        
        SubProject__c updatedSubprojectwithTask = [SELECT Count_of_Tasks_on_SubProject__c FROM SubProject__c WHERE Id = : testSubProject.Id];
        system.Debug('**updatedSubprojectwithTask: '+updatedSubprojectwithTask.Count_of_Tasks_on_SubProject__c);
        system.Assert(updatedSubprojectwithTask.Count_of_Tasks_on_SubProject__c == 1);
        
        Project_Activity__c falseForceRollupActivity = [SELECT Force_Rollup__c FROM Project_Activity__c WHERE Id = : testActivity.Id];
        system.Assert(falseForceRollupActivity.Force_Rollup__c == false);
        
        
    }
}