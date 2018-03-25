/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: IMP_ProductMilestones_Controller test class
History
10/23/14    Michael Lasala      Created
11/25/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/
@isTest
public class IMP_ProductMilestonesController_Test{
    
    static testMethod void constructorNull_Test(){
        
        Test.StartTest();
        IMP_ProductMilestones_Controller projectMilestone = new IMP_ProductMilestones_Controller();
        Test.StopTest();
        
        System.assertEquals(null, projectMilestone.subProjectId);
    }
    
    static testMethod void constructor_Test(){
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        List<Milestone_Definition__c> testMilestoneDefinitionList = new List<Milestone_Definition__c>();
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        testMilestoneDefinition.Project_Type__c = ''; // force this to be blank to avoid the validation error "Project Milestone Definition Validation"
        testMilestoneDefinitionList.add(testMilestoneDefinition);
        
        Milestone_Definition__c testMilestoneDefinition2 = IMP_TestFactory_Helper.buildMilestoneDefinition();
        testMilestoneDefinition2.Project_Type__c = ''; // force this to be blank to avoid the validation error "Project Milestone Definition Validation"
        testMilestoneDefinitionList.add(testMilestoneDefinition2);
        
        insert testMilestoneDefinitionList;
        
        Question_Category__c testDealershipNeeded = IMP_TestFactory_Helper.buildDealershipNeed();
        insert testDealershipNeeded;
        
        Solution__c testSolution = IMP_TestFactory_Helper.buildSolution(testDealershipNeeded.Id);
        insert testSolution;
        
        List<Product__c> testProductList = new List<Product__c>();
        Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        testProductList.add(testProduct);
        
        Product__c testProduct2 = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        testProductList.add(testProduct2);
        
        insert testProductList;
        
        List<Project_Milestone_Definition_Product__c> testProjectMilestoneDefinitionProductList = new List<Project_Milestone_Definition_Product__c>();
        Project_Milestone_Definition_Product__c testProjectMilestoneDefinitionProduct = IMP_TestFactory_Helper.buildProjectMilestoneDefinitionProduct(testMilestoneDefinition.Id, testProduct.Id);
        testProjectMilestoneDefinitionProductList.add(testProjectMilestoneDefinitionProduct);
        
        Project_Milestone_Definition_Product__c testProjectMilestoneDefinitionProduct2 = IMP_TestFactory_Helper.buildProjectMilestoneDefinitionProduct(testMilestoneDefinition2.Id, testProduct2.Id);
        testProjectMilestoneDefinitionProductList.add(testProjectMilestoneDefinitionProduct2);
        
        insert testProjectMilestoneDefinitionProductList;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', testSubProject.Id);
        IMP_ProductMilestones_Controller projectMilestone = new IMP_ProductMilestones_Controller();
        Test.StopTest();
        
        System.assertEquals(testSubProject.Id, projectMilestone.subProjectId);
        System.assertEquals(testSubProject.Id, projectMilestone.subProject.Id);
        System.assertEquals(testMilestoneDefinitionList.size(), projectMilestone.milestoneDefinitionWrapperList.size());
    }
    
    static testMethod void createRecords_Test(){
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        List<Milestone_Definition__c> testMilestoneDefinitionList = new List<Milestone_Definition__c>();
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        testMilestoneDefinition.Project_Type__c = ''; // force this to be blank to avoid the validation error "Project Milestone Definition Validation"
        testMilestoneDefinitionList.add(testMilestoneDefinition);
        
        Milestone_Definition__c testMilestoneDefinition2 = IMP_TestFactory_Helper.buildMilestoneDefinition();
        testMilestoneDefinition2.Project_Type__c = ''; // force this to be blank to avoid the validation error "Project Milestone Definition Validation"
        testMilestoneDefinitionList.add(testMilestoneDefinition2);
        
        insert testMilestoneDefinitionList;
        
        List<Activity_Definition__c> testActivityDefinitionList = new List<Activity_Definition__c>();
        for(Integer i=0; i<3; i++){
            Activity_Definition__c testActivityDefinition = new Activity_Definition__c();
            if(i>=1){
                testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinitionList.get(0).Id);
            } else {
                testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinitionList.get(1).Id);
            }
            testActivityDefinitionList.add(testActivityDefinition);
        }
        
        insert testActivityDefinitionList;
        
        List<Task_Definition__c> testTaskDefinitionList = new List<Task_Definition__c>();
        
        Task_Definition__c testTaskDefinition = IMP_TestFactory_Helper.buildTaskDefinition(testActivityDefinitionList.get(0).Id);
        testTaskDefinitionList.add(testTaskDefinition);
        
        Task_Definition__c testTaskDefinition2 =IMP_TestFactory_Helper.buildTaskDefinition(testActivityDefinitionList.get(1).Id);
        testTaskDefinitionList.add(testTaskDefinition2);
        
        Task_Definition__c testTaskDefinition3 =IMP_TestFactory_Helper.buildTaskDefinition(testActivityDefinitionList.get(2).Id);
        testTaskDefinitionList.add(testTaskDefinition3);
        
        insert testTaskDefinitionList;
        
        testActivityDefinitionList.get(0).Active__c = true;
        testActivityDefinitionList.get(1).Active__c = true;
        testActivityDefinitionList.get(2).Active__c = true;
        update testActivityDefinitionList;
        
        Question_Category__c testDealershipNeeded = IMP_TestFactory_Helper.buildDealershipNeed();
        insert testDealershipNeeded;
        
        Solution__c testSolution = IMP_TestFactory_Helper.buildSolution(testDealershipNeeded.Id);
        insert testSolution;
        
        List<Product__c> testProductList = new List<Product__c>();
        Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        testProductList.add(testProduct);
        
        Product__c testProduct2 = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        testProductList.add(testProduct2);
        
        insert testProductList;
        
        List<Project_Milestone_Definition_Product__c> testProjectMilestoneDefinitionProductList = new List<Project_Milestone_Definition_Product__c>();
        Project_Milestone_Definition_Product__c testProjectMilestoneDefinitionProduct = IMP_TestFactory_Helper.buildProjectMilestoneDefinitionProduct(testMilestoneDefinition.Id, testProduct.Id);
        testProjectMilestoneDefinitionProductList.add(testProjectMilestoneDefinitionProduct);
        
        Project_Milestone_Definition_Product__c testProjectMilestoneDefinitionProduct2 = IMP_TestFactory_Helper.buildProjectMilestoneDefinitionProduct(testMilestoneDefinition2.Id, testProduct2.Id);
        testProjectMilestoneDefinitionProductList.add(testProjectMilestoneDefinitionProduct2);
        
        insert testProjectMilestoneDefinitionProductList;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', testSubProject.Id);
        IMP_ProductMilestones_Controller projectMilestone = new IMP_ProductMilestones_Controller();
        projectMilestone.milestoneDefinitionWrapperList.get(0).isSelected = true;
        projectMilestone.milestoneDefinitionWrapperList.get(1).isSelected = true;
        projectMilestone.createProjectMilestones();
        Test.StopTest();
        
        System.assertEquals(testSubProject.Id, projectMilestone.subProjectId);
        System.assertEquals(testSubProject.Id, projectMilestone.subProject.Id);
        System.assertEquals(testMilestoneDefinitionList.size(), projectMilestone.milestoneDefinitionWrapperList.size());
        System.assertEquals(true, projectMilestone.isValid);
        
        List<Project_Milestone__c> createdProjectMilestones = [SELECT Id, Milestone_Definition__c FROM Project_Milestone__c WHERE SubProject__c =: testSubProject.Id];
        Set<Id> createdProjectMilestoneIds = new Set<Id>();
        if(!createdProjectMilestones.isEmpty()){
            for(Project_Milestone__c pm: createdProjectMilestones){
                createdProjectMilestoneIds.add(pm.Id);
            }
        }
        List<Project_Activity__c> createdProjectActivities = [SELECT Id FROM Project_Activity__c ];
        
        System.assertEquals(testMilestoneDefinitionList.get(0).Id, createdProjectMilestones.get(0).Milestone_Definition__c);
        System.assertEquals(testMilestoneDefinitionList.get(1).Id, createdProjectMilestones.get(1).Milestone_Definition__c);
        System.assertEquals(testActivityDefinitionList.size(), createdProjectActivities.size());
    }
    
    static testMethod void createRecordsNegative_Test(){
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        List<Milestone_Definition__c> testMilestoneDefinitionList = new List<Milestone_Definition__c>();
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        testMilestoneDefinition.Project_Type__c = ''; // force this to be blank to avoid the validation error "Project Milestone Definition Validation"
        insert testMilestoneDefinition;
        
        Question_Category__c testDealershipNeeded = IMP_TestFactory_Helper.buildDealershipNeed();
        insert testDealershipNeeded;
        
        Solution__c testSolution = IMP_TestFactory_Helper.buildSolution(testDealershipNeeded.Id);
        insert testSolution;
        
        Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        insert testProduct;
        
        Project_Milestone_Definition_Product__c testProjectMilestoneDefinitionProduct = IMP_TestFactory_Helper.buildProjectMilestoneDefinitionProduct(testMilestoneDefinition.Id, testProduct.Id);
        insert testProjectMilestoneDefinitionProduct;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', testSubProject.Id);
        IMP_ProductMilestones_Controller projectMilestone = new IMP_ProductMilestones_Controller();
        projectMilestone.createProjectMilestones();
        Test.StopTest();
        
        System.assertEquals(testSubProject.Id, projectMilestone.subProjectId);
        System.assertEquals(testSubProject.Id, projectMilestone.subProject.Id);
        System.assertNotEquals(0, projectMilestone.milestoneDefinitionWrapperList.size());
        System.assertEquals(false, projectMilestone.isValid);
        
        Boolean isError;
        List<Apexpages.Message> errorMessages = ApexPages.getMessages(); 
        for(Apexpages.Message msg: errorMessages){
            if(msg.getDetail().contains('No Milestones selected')){
                isError = true;
            }
        }
        System.assert(isError);
        
    }
}