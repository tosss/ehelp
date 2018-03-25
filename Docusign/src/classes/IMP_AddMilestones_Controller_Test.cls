/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: IMP_AddMilestones_Controller test class
History
12/09/14    Rey Austral      Created
------------------------------------------------------------*/
@isTest
public class IMP_AddMilestones_Controller_Test 
{
    static testMethod void productLoadData_Test()
    {
        //test if the selection of product milestone(s) will be loaded based on the Subproject's Market 
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        List<Milestone_Definition__c> testMilestoneDefinitionList = new List<Milestone_Definition__c>();
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        //Since we're creating a Milestone Definition record associated with a Product definition, the definition cannot have the Project Type specified
        //Otherwise, the "Project Milestone Definition Validation" will fail. Force Project Type to be blank to avoid the validation error.
        testMilestoneDefinition.Project_Type__c = '';
        testMilestoneDefinitionList.add(testMilestoneDefinition);
        
        Milestone_Definition__c testMilestoneDefinition2 = IMP_TestFactory_Helper.buildMilestoneDefinition();
        //Since we're creating a Milestone Definition record associated with a Product definition, the definition cannot have the Project Type specified
        //Otherwise, the "Project Milestone Definition Validation" will fail. Force Project Type to be blank to avoid the validation error.
        testMilestoneDefinition2.Project_Type__c = ''; 

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
        ApexPages.CurrentPage().getParameters().put('type', 'Product');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        Test.StopTest();
        
        System.assertEquals(testSubProject.Id, projectMilestone.subProjectId);
        System.assertEquals(testSubProject.Id, projectMilestone.subProject.Id);
        System.assertEquals(testMilestoneDefinitionList.size(), projectMilestone.milestoneDefinitionWrapperList.size());
    }
    
    static testMethod void createProductMilestoneRecords_Test()
    {
        //test if the Project Milestones and Project Activities will be created in the subproject based on the product-based milestones selected
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        List<Milestone_Definition__c> testMilestoneDefinitionList = new List<Milestone_Definition__c>();
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        //Since we're creating a Milestone Definition record associated with a Product definition, the definition cannot have the Project Type specified
        //Otherwise, the "Project Milestone Definition Validation" will fail. Force Project Type to be blank to avoid the validation error.
        testMilestoneDefinition.Project_Type__c = ''; 
        
        testMilestoneDefinitionList.add(testMilestoneDefinition);
        
        Milestone_Definition__c testMilestoneDefinition2 = IMP_TestFactory_Helper.buildMilestoneDefinition();
        //Since we're creating a Milestone Definition record associated with a Product definition, the definition cannot have the Project Type specified
        //Otherwise, the "Project Milestone Definition Validation" will fail. Force Project Type to be blank to avoid the validation error.
        testMilestoneDefinition2.Project_Type__c = ''; 

        testMilestoneDefinitionList.add(testMilestoneDefinition2);
        
        insert testMilestoneDefinitionList;
        
        List<Activity_Definition__c> testActivityDefinitionList = new List<Activity_Definition__c>();
        for(Integer i=0; i<3; i++)
        {
            Activity_Definition__c testActivityDefinition = new Activity_Definition__c();
            if(i>=1)
            {
                testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinitionList.get(0).Id);
            } 
            else 
            {
                testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinitionList.get(1).Id);
            }
            testActivityDefinitionList.add(testActivityDefinition);
        }
        
        insert testActivityDefinitionList;
        
        List<Task_Definition__c> testTaskDefinitionList = new List<Task_Definition__c>();
        for (Activity_Definition__c actD : testActivityDefinitionList) 
        {
            actD.Active__c = true;
            Task_Definition__c ptd =  IMP_TestFactory_Helper.buildTaskDefinition(actD.Id);
            testTaskDefinitionList.add(ptd);
        } 
        insert testTaskDefinitionList;
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
        ApexPages.CurrentPage().getParameters().put('type', 'Product');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        projectMilestone.milestoneDefinitionWrapperList.get(0).isSelected = true;
        projectMilestone.milestoneDefinitionWrapperList.get(1).isSelected = true;
        projectMilestone.createProjectMilestones();
        Test.StopTest();
        
        System.assertEquals(testSubProject.Id, projectMilestone.subProjectId);
        System.assertEquals(testSubProject.Id, projectMilestone.subProject.Id);
        System.assertEquals(testMilestoneDefinitionList.size(), projectMilestone.milestoneDefinitionWrapperList.size());
        System.assertEquals(true, projectMilestone.isValid);
        
        List<Project_Milestone__c> createdProjectMilestones = [SELECT Id, Milestone_Definition__c FROM Project_Milestone__c WHERE SubProject__c =: testSubProject.Id];
        Set<Id> createdProjectMilestoneIdsSet = new Set<Id>();
        if(!createdProjectMilestones.isEmpty())
        {
            for(Project_Milestone__c pm: createdProjectMilestones)
            {
                createdProjectMilestoneIdsSet.add(pm.Id);
            }
        }
        List<Project_Activity__c> createdProjectActivities = [SELECT Id FROM Project_Activity__c WHERE Milestone__c IN: createdProjectMilestoneIdsSet];
        List<Project_Task__c> createdProjectTask = [SELECT Id FROM Project_Task__c WHERE Project_Activity__c IN: createdProjectActivities];
        System.assertEquals(testMilestoneDefinitionList.get(0).Id, createdProjectMilestones.get(0).Milestone_Definition__c);
        System.assertEquals(testMilestoneDefinitionList.get(1).Id, createdProjectMilestones.get(1).Milestone_Definition__c);
        System.assertEquals(testActivityDefinitionList.size(), createdProjectActivities.size());
        System.assertEquals(testTaskDefinitionList.size(), createdProjectTask.size());
    }
    
    static testMethod void noSelectedMilestonesCreateRecordsforProductFail_Test()
    {
        //test what will happen when attempting to create Project Milestones and Project Activities when no product milestone selected
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        List<Milestone_Definition__c> testMilestoneDefinitionList = new List<Milestone_Definition__c>();
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        //Since we're creating a Milestone Definition record associated with a Product definition, the definition cannot have the Project Type specified
        //Otherwise, the "Project Milestone Definition Validation" will fail. Force Project Type to be blank to avoid the validation error.
        testMilestoneDefinition.Project_Type__c = ''; 

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
        ApexPages.CurrentPage().getParameters().put('type', 'Product');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        projectMilestone.createProjectMilestones();
        Test.StopTest();
        
        System.assertEquals(testSubProject.Id, projectMilestone.subProjectId);
        System.assertEquals(testSubProject.Id, projectMilestone.subProject.Id);
        System.assertNotEquals(0, projectMilestone.milestoneDefinitionWrapperList.size());
        System.assertEquals(false, projectMilestone.isValid);
        
        Boolean isError = false;
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null)
        {
            for(Apexpages.Message msg: errorMessagesList)
            {
                if(msg.getDetail().contains('No Milestone selected'))
                {
                    isError = true;
                }
            }
        }
        
        System.assert(isError);
        
    }
    
    static testMethod void standardMilestoneLoadData_Test()
    {
        //test if the standard (non-product-based) milestone list will be loaded based on the market and product type of the subproject
        createCustomSettings();
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();   
        insert testAccount;
        
        Question_Category__c testDealershipNeeded = IMP_TestFactory_Helper.buildDealershipNeed();
        insert testDealershipNeeded;
        
        Solution__c testSolution =  IMP_TestFactory_Helper.buildSolution(testDealershipNeeded.Id);
        insert testSolution;
        
        Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        insert testProduct;
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        testSubProject.Project_Manager__c = UserInfo.getUserId();
        testSubProject.Contract_Roll_Called__c = Date.today();
        testSubProject.Dealer_Group__c = testAccount.Id;
        insert testSubProject;
        
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        insert testMilestoneDefinition;
        
        Activity_Definition__c testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinition.Id);
        insert testActivityDefinition;    
        
        Task_Definition__c testTaskDefinition =  IMP_TestFactory_Helper.buildTaskDefinition(testActivityDefinition.Id);
        insert testTaskDefinition;
        
        testActivityDefinition.Active__c = true;
        Update testActivityDefinition;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', testSubProject.Id);
        ApexPages.CurrentPage().getParameters().put('type', 'Standard');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        Test.StopTest();        
        
        System.assertEquals(testSubProject.Id, projectMilestone.subProjectId);
        System.assertEquals(testSubProject.Id, projectMilestone.subProject.Id);
        System.assertEquals(1, projectMilestone.milestoneDefinitionWrapperList.size());
    }
    
    static testMethod void createNewStandardMilestoneRecord_Test()
    {
        //test if the Project Milestones and Project Activities will be created in the subproject based on the selected
        //standard (non-product-based) milestone(s)
        createCustomSettings();
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();   
        insert testAccount;
        
        Question_Category__c testDealershipNeeded = IMP_TestFactory_Helper.buildDealershipNeed();
        insert testDealershipNeeded;
        
        Solution__c testSolution =  IMP_TestFactory_Helper.buildSolution(testDealershipNeeded.Id);
        insert testSolution;
        
        Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        insert testProduct;
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        testSubProject.Project_Manager__c = UserInfo.getUserId();
        testSubProject.Contract_Roll_Called__c = Date.today();
        testSubProject.Dealer_Group__c = testAccount.Id;
        insert testSubProject;
        
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        insert testMilestoneDefinition;
        
        Activity_Definition__c testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinition.Id);
        insert testActivityDefinition;  
        
        Task_Definition__c testTaskDefinition =  IMP_TestFactory_Helper.buildTaskDefinition(testActivityDefinition.Id);
        insert testTaskDefinition;
        
        testActivityDefinition.Active__c = true;
        Update testActivityDefinition;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', testSubProject.Id);
        ApexPages.CurrentPage().getParameters().put('type', 'Standard');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        
        projectMilestone.milestoneDefinitionWrapperList.get(0).isSelected = true;         
        projectMilestone.createProjectMilestones();
        Test.StopTest();
        
        List<Project_Milestone__c> createdProjectMilestonesList = [SELECT Id, Milestone_Definition__c FROM Project_Milestone__c WHERE SubProject__c =: testSubProject.Id];
        Set<Id> createdProjectMilestoneIdsSet = new Set<Id>();
        if(!createdProjectMilestonesList.isEmpty())
        {
            for(Project_Milestone__c pm: createdProjectMilestonesList)
            {
                createdProjectMilestoneIdsSet.add(pm.Id);
            }
        }
        
        List<Project_Activity__c> createdProjectActivities = [SELECT Id FROM Project_Activity__c WHERE Milestone__c in: createdProjectMilestoneIdsSet];
        List<Project_Task__c> createdProjectTask = [SELECT Id FROM Project_Task__c WHERE Project_Activity__c IN: createdProjectActivities];
        
        System.assertEquals(testMilestoneDefinition.Id, createdProjectMilestonesList.get(0).Milestone_Definition__c);      
        System.assertEquals(1, createdProjectActivities.size());
        System.assertEquals(1, createdProjectTask.size());
    }
    
    static testMethod void noSelectedMilestonesCreateRecordsforStandardFail_Test()
    {
        //test what will happen when attempting to create Project Milestones and Project Activities when
        //no standard (non-product-based) milestone is selected
        createCustomSettings();
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();   
        insert testAccount;
        
        Question_Category__c testDealershipNeeded = IMP_TestFactory_Helper.buildDealershipNeed();
        insert testDealershipNeeded;
        
        Solution__c testSolution =  IMP_TestFactory_Helper.buildSolution(testDealershipNeeded.Id);
        insert testSolution;
        
        Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        insert testProduct;
        
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        testSubProject.Project_Manager__c = UserInfo.getUserId();
        testSubProject.Contract_Roll_Called__c = Date.today();
        testSubProject.Dealer_Group__c = testAccount.Id;
        insert testSubProject;
        
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        insert testMilestoneDefinition;
        
        Activity_Definition__c testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testMilestoneDefinition.Id);
        insert testActivityDefinition;
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('subProjectId', testSubProject.Id);
        ApexPages.CurrentPage().getParameters().put('type', 'Standard');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();       
        projectMilestone.createProjectMilestones();
        
        Test.StopTest();
        
        Boolean isError;
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        for(Apexpages.Message msg: errorMessagesList)
        {
            if(msg.getDetail().contains('No Milestone selected'))
            {
                isError = true;
            }
        }
        System.assert(isError);
    }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
}