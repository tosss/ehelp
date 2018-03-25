/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: IMP_GenerateMilestones_Controller test class
History
11/07/14    Kimiko Roberto      Created
11/19/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
01/03/15    Karl Simon          Added CMF_Info and SubprojectSite record generation and insertion logic into the IMP_GenerateMilestones_Controller_Test,
getStandardMilestonesNoMilestonesifNoProjAct_Test,  and setSubprojectAsNull_Test methods.
The addition accommodates the decommissioning of prior functionality that auto-generated a Subproject Site upon population or
change of the Subproject__c.Main_Site__c  field (which is planned for de-commission during Phase 1 R3).
08/12/2015  Rey Austral         Remove unnecessary test data, add rms record, add consolidate test data and create @testSetup block
08/27/2015  Rey Austral         Add RMS_Activity_Code__c when creating a milestone definition, add Is_RMS_Owned__c in creating rms task definition
------------------------------------------------------------*/
@isTest
public class IMP_GenerateMilestones_Controller_Test 
{
    private static SubProject__c subProject { get { return [Select Id,Project_Type__c,Market__c,Estimated_Install_Date_EID__c from SubProject__c Limit 1 ]; } }
    
    @testSetup static void setup() 
    {  
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        insert testAccount;
        
        Question_Category__c testDealershipNeeded = IMP_TestFactory_Helper.buildDealershipNeed();
        testDealershipNeeded.Active__c = true;
        insert testDealershipNeeded;
        
        Solution__c testSolution = IMP_TestFactory_Helper.buildSolution(testDealershipNeeded.Id);
        insert testSolution;
        
        Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        insert testProduct;
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        testSubProject.Estimated_Install_Date_EID__c = Date.today();
        //testSubProject.Dealer_Group__c = testAccount.Id;
        insert testSubProject;
       
        CMF_Info__c testCMFInfo = IMP_TestFactory_Helper.buildCMFInfo(testAccount.Id);
        insert testCMFInfo;
        
        SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite(testAccount.Id, testSubProject.Id, testCMFInfo.Id);
        insert testSubProjectSite;
        
        SubProject_External_Related_Entity__c testSubProjectExternalEntity = IMP_TestFactory_Helper.buildSubProjectExternalRelatedEntity(testSubProject.Id);
        insert testSubProjectExternalEntity;
        
        List<Milestone_Definition__c> testMilestoneDefinitionList = new List<Milestone_Definition__c>();
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        testMilestoneDefinition.RMS_Activity_Code__c = 'RMS CODE';
        testMilestoneDefinitionList.add(testMilestoneDefinition);
        insert testMilestoneDefinitionList;
        testMilestoneDefinition.Active__c = true;
        
        Activity_Definition__c testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinition.Id);
        testActivityDefinition.Offset_Criteria__c = IMP_Project_Utility.OFFSET_CRITERIA_ESTIMATED_INSTALL;
        testActivityDefinition.Planned_Start_Date_Offset__c = 3;
        testActivityDefinition.Planned_End_Date_Offset__c = 2;
        testActivityDefinition.CDK_Assignee_Role__c = '3PA';        
        insert testActivityDefinition;
        
        Activity_Definition__c testRMSActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinition.Id);
        testRMSActivityDefinition.Offset_Criteria__c = IMP_Project_Utility.OFFSET_CRITERIA_ESTIMATED_INSTALL;
        testRMSActivityDefinition.Planned_Start_Date_Offset__c = 3;
        testRMSActivityDefinition.Planned_End_Date_Offset__c = 2;
        testRMSActivityDefinition.CDK_Assignee_Role__c = '3PA';    
        testRMSActivityDefinition.RMS_Assignment_Type__c = 'RMS';       
        insert testRMSActivityDefinition;
        
        Task_Definition__c testTaskDefinition = IMP_TestFactory_Helper.buildTaskDefinition(testActivityDefinition.Id);
        testTaskDefinition.Active__c = true;
        insert testTaskDefinition;
        
        Task_Definition__c testRMSTaskDefinition = IMP_TestFactory_Helper.buildTaskDefinition(testRMSActivityDefinition.Id);
        testRMSTaskDefinition.RMS_Task_Code__c  = 'RMS-01';
        testRMSTaskDefinition.Is_RMS_Owned__c = true;
        testRMSTaskDefinition.Active__c = true;
        insert testRMSTaskDefinition;
        
        testActivityDefinition.Active__c = true;
        update testActivityDefinition;
        
        testRMSActivityDefinition.Active__c = true;
        update testRMSActivityDefinition;
        
        update testMilestoneDefinitionList;
    }
    
    static testMethod void getStandardMilestones_Test()
    {
        createCustomSettings();
        Id testDataSubprojectId = subProject.Id;
        Test.StartTest();
        IMP_GenerateMilestones_Controller.getStandardMilestones(testDataSubprojectId);
        Test.StopTest();
        
        List<Project_Milestone__c> createdProjectMilestoneList = [SELECT Id FROM Project_Milestone__c WHERE SubProject__c =: testDataSubprojectId];
        List<Project_Activity__c> createdProjectActivityList = [SELECT Id FROM Project_Activity__c WHERE Milestone__c =: createdProjectMilestoneList.get(0).Id];
        List<Project_Task__c> createdProjectTaskList = [SELECT id FROM Project_Task__c where Project_Activity__c in: createdProjectActivityList];
        SubProject__c updatedSubProject = [SELECT Milestones_Auto_Generated_Flag__c FROM SubProject__c WHERE Id =: testDataSubprojectId];
        //records should not include rms records,
        System.assertEquals(1, createdProjectMilestoneList.size());
        System.assertEquals(1, createdProjectActivityList.size());
        System.assertEquals(1, createdProjectTaskList.size());
        System.assertEquals(true, updatedSubProject.Milestones_Auto_Generated_Flag__c);
    }
    
    //Test generate milestone if no milestone definition match the project type and market of the subproject
    static testMethod void getStandardMilestonesNoMilestones_Test()
    {
        createCustomSettings();
        SubProject__c testSubproject = subProject;
        testSubproject.Project_Type__c = IMP_TestFactory_Helper.LITERAL_PFW_HEAVY_EQUIPMENT;
        testSubproject.Market__c = IMP_TestFactory_Helper.LITERAL_BUY_SELL;
        update testSubproject;
        
        Test.StartTest();
        String testString = IMP_GenerateMilestones_Controller.getStandardMilestones(testSubProject.Id);
        Test.StopTest();
        
        List<Project_Milestone__c> createdProjectMilestoneList = [SELECT Id FROM Project_Milestone__c WHERE SubProject__c =: testSubProject.Id];
        SubProject__c updatedSubProject = [SELECT Milestones_Auto_Generated_Flag__c FROM SubProject__c WHERE Id =: testSubProject.Id];
        
        System.assertEquals(0, createdProjectMilestoneList.size());
        System.assertEquals(false, updatedSubProject.Milestones_Auto_Generated_Flag__c);
        
        System.assertEquals('No standard Milestones found based on SubProject criteria', testString);
    }
    
    static testMethod void setSubprojectDateAsPast_Test()
    {
        createCustomSettings();
        SubProject__c testSubproject = subProject;
        testSubproject.Estimated_Install_Date_EID__c = Date.today() -1 ;        
        update testSubproject;
        
        Test.StartTest();
        String testString = IMP_GenerateMilestones_Controller.getStandardMilestones(testSubProject.Id);
        Test.StopTest();
        
        system.assert('Estimated Install Date cannot be set to the past' == testString);        
    }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
}