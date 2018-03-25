/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: IMP_AddMilestones_Controller test class
History
12/09/14    Rey Austral      Created
08/10/14    Rey Austral      Add new test Method testAppendExistingRMSMilestone,testLoadNoMoreMilestoneForSelectedSite,NoSiteInSubproject_PreventRecordLoad
                             testAddProductMilestoneFilterPreventDuplicate
                             Consolidate all the creation of definition and place it in the static section
------------------------------------------------------------*/
@isTest
public class IMP_AddMilestones_Controller_Test 
{
    private static Project__c project { get { return [Select id from Project__c Limit 1]; } }
    private static SubProject__c subProject { get { return [Select id from SubProject__c where SubProject_Name__c = 'Product Subproject' Limit 1]; } }
    private static SubProject__c standardSubProject { get { return [Select id from SubProject__c where SubProject_Name__c = 'Standard Subproject' Limit 1]; } }           
    private static SubProjectSite__c site { get { return [Select id from SubProjectSite__c Limit 1]; } }
    private static Milestone_Definition__c testStandardMilestoneDefinition { get { return [Select id from Milestone_Definition__c where Project_Type__c != '' Limit 1]; } }
    private static Milestone_Definition__c testRMSMilestoneDefinition { get { return [Select id from Milestone_Definition__c where RMS_Activity_Code__c = 'RMS-Code' Limit 1]; } }
    private static List<Milestone_Definition__c> testMilestoneDefinitionList { get { return [Select id from Milestone_Definition__c where Project_Type__c = '' and RMS_Activity_Code__c = '']; } }
    private static List<Activity_Definition__c> testActivityDefinitionList { get { return [Select id from Activity_Definition__c where Description__c = 'Product Activity Definition' ]; } }
    private static List<Task_Definition__c> testTaskDefinitionList { get { return [Select id from Task_Definition__c where Description__c = 'Product Task Definition' ]; }  }
    
    @testSetup static void setup() 
    {
        //Creation of Test Data        
        Project__c testDataProject = IMP_TestFactory_Helper.buildProject(0);
        insert testDataProject;
        
        Account account = IMP_TestFactory_Helper.buildAccount();
        insert account;
        
        SubProject__c testDataSubProject = IMP_TestFactory_Helper.buildSubProject(testDataProject.Id);
        testDataSubProject.SubProject_Name__c = 'Product Subproject';
        insert testDataSubProject;
        
        SubProject__c testDataStandardSubProject = IMP_TestFactory_Helper.buildSubProject(testDataProject.Id);
        testDataStandardSubProject.SubProject_Name__c = 'Standard Subproject';
        testDataStandardSubProject.Project_Manager__c = UserInfo.getUserId();
        testDataStandardSubProject.Contract_Roll_Called__c = Date.today();
        //testDataStandardSubProject.Dealer_Group__c = account.Id;
        insert testDataStandardSubProject;
        
        User user_cdkAssignee = IMP_TestFactory_Helper.buildUser();
        insert user_cdkAssignee;
        
        Contact contact_clientAssignee = IMP_TestFactory_Helper.buildContact(account.Id);
        insert contact_clientAssignee;
        
        CMF_Info__c cmf = new CMF_Info__c();
        cmf.Account__c = account.Id;
        cmf.Name = 'WITH SHIP CMF | USING ACCOUNT 1';
        cmf.Ship_CMF__c = '00000001';
        cmf.Status__c = 'A';
        insert cmf;
        
        SubProjectSite__c testDataSite = new SubProjectSite__c();
        testDataSite.SubProject__c = testDataSubProject.Id;
        testDataSite.CMF_Name__c = cmf.Id;
        
        insert testDataSite;
        
        //Create Standard Milestone Definition
        
        Milestone_Definition__c testDataStandardMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();        
        insert testDataStandardMilestoneDefinition;
        
        Activity_Definition__c testStandardActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testDataStandardMilestoneDefinition.Id);
        insert testStandardActivityDefinition;
        
        Task_Definition__c testStandardTaskDefinition =  IMP_TestFactory_Helper.buildTaskDefinition(testStandardActivityDefinition.Id);
        testStandardTaskDefinition.Active__c = true;
        insert testStandardTaskDefinition;
        
        testStandardActivityDefinition.Active__c = true;
        update testStandardActivityDefinition;
        
        testDataStandardMilestoneDefinition.Active__c = true;
        update testDataStandardMilestoneDefinition;
        
        //Create Product Definition       
        
        List<Milestone_Definition__c> testDataMilestoneDefinitionList = new List<Milestone_Definition__c>();
        Milestone_Definition__c testMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();
        //Since we're creating a Milestone Definition record associated with a Product definition, the definition cannot have the Project Type specified
        //Otherwise, the "Project Milestone Definition Validation" will fail. Force Project Type to be blank to avoid the validation error.
        testMilestoneDefinition.Project_Type__c = '';        
        testDataMilestoneDefinitionList.add(testMilestoneDefinition);
        
        Milestone_Definition__c testMilestoneDefinition2 = IMP_TestFactory_Helper.buildMilestoneDefinition();
        //Since we're creating a Milestone Definition record associated with a Product definition, the definition cannot have the Project Type specified
        //Otherwise, the "Project Milestone Definition Validation" will fail. Force Project Type to be blank to avoid the validation error.
        testMilestoneDefinition2.Project_Type__c = '';         
        
        testDataMilestoneDefinitionList.add(testMilestoneDefinition2);        
        insert testDataMilestoneDefinitionList;
        
        List<Activity_Definition__c> testDataActivityDefinitionList = new List<Activity_Definition__c>();
        for(Integer i=0; i<3; i++)
        {
            Activity_Definition__c testActivityDefinition = new Activity_Definition__c();
            if(i>=1)
            {
                testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testDataMilestoneDefinitionList.get(0).Id);
            } 
            else 
            {
                testActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testDataMilestoneDefinitionList.get(1).Id);
            }
            testActivityDefinition.Description__c = 'Product Activity Definition';
            testDataActivityDefinitionList.add(testActivityDefinition);
        }
        
        insert testDataActivityDefinitionList;
        
        List<Task_Definition__c> testDataTaskDefinitionList = new List<Task_Definition__c>();
        for (Activity_Definition__c actD : testDataActivityDefinitionList) 
        {
            actD.Active__c = true;
            Task_Definition__c ptd =  IMP_TestFactory_Helper.buildTaskDefinition(actD.Id);
            ptd.Description__c = 'Product Task Definition';
            ptd.Active__c = true;
            testDataTaskDefinitionList.add(ptd);
        } 
        insert testDataTaskDefinitionList;
        update testDataActivityDefinitionList;
        
        testMilestoneDefinition.active__c = true;
        testMilestoneDefinition2.Active__c = true;
        update testMilestoneDefinition;
        update testMilestoneDefinition2;
        
        //Create RMS Milestone Definition with non-rms activity and task     
        Milestone_Definition__c testDataRMSMilestoneDefinition = IMP_TestFactory_Helper.buildMilestoneDefinition();       
        testDataRMSMilestoneDefinition.RMS_Activity_Code__c = 'RMS-Code';
        testDataRMSMilestoneDefinition.Project_Type__c = '';
        insert testDataRMSMilestoneDefinition;
        
        Activity_Definition__c testRMSActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testDataRMSMilestoneDefinition.Id);      
        insert testRMSActivityDefinition;
        
        Task_Definition__c testRMSTaskDefinition =  IMP_TestFactory_Helper.buildTaskDefinition(testRMSActivityDefinition.Id);
        testRMSTaskDefinition.Active__c = true;       
        insert testRMSTaskDefinition;
        
        testRMSActivityDefinition.Active__c = true;
        update testRMSActivityDefinition;
        
        testDataRMSMilestoneDefinition.Active__c = true;
        update testDataRMSMilestoneDefinition;
        
        //Create milestone product
        Question_Category__c testDealershipNeeded = IMP_TestFactory_Helper.buildDealershipNeed();
        insert testDealershipNeeded;
        
        Solution__c testSolution = IMP_TestFactory_Helper.buildSolution(testDealershipNeeded.Id);
        insert testSolution;
        
        List<Product__c> testProductList = new List<Product__c>();
        Product__c testProduct = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        testProductList.add(testProduct);
        
        Product__c testProduct2 = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        testProductList.add(testProduct2);
        
        Product__c testProduct3 = IMP_TestFactory_Helper.buildProduct(testSolution.Id);
        testProductList.add(testProduct3);
        
        insert testProductList;
        
        List<Project_Milestone_Definition_Product__c> testProjectMilestoneDefinitionProductList = new List<Project_Milestone_Definition_Product__c>();
        Project_Milestone_Definition_Product__c testProjectMilestoneDefinitionProduct = IMP_TestFactory_Helper.buildProjectMilestoneDefinitionProduct(testMilestoneDefinition.Id, testProduct.Id);
        testProjectMilestoneDefinitionProductList.add(testProjectMilestoneDefinitionProduct);
        
        Project_Milestone_Definition_Product__c testProjectMilestoneDefinitionProduct2 = IMP_TestFactory_Helper.buildProjectMilestoneDefinitionProduct(testMilestoneDefinition2.Id, testProduct2.Id);
        testProjectMilestoneDefinitionProductList.add(testProjectMilestoneDefinitionProduct2);
        
        Project_Milestone_Definition_Product__c testProjectMilestoneDefinitionProduct3 = IMP_TestFactory_Helper.buildProjectMilestoneDefinitionProduct(testDataRMSMilestoneDefinition.Id, testProduct3.Id);
        testProjectMilestoneDefinitionProductList.add(testProjectMilestoneDefinitionProduct3);
        
        insert testProjectMilestoneDefinitionProductList;
    }
    
    static testMethod void productLoadData_Test()
    {
        //test if the selection of product milestone(s) will be loaded based on the Subproject's Market      
        Id testDataSubprojectId = subProject.Id;
        Test.StartTest();        
        ApexPages.CurrentPage().getParameters().put('subProjectId', testDataSubprojectId);
        ApexPages.CurrentPage().getParameters().put('type', 'Product');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        projectMilestone.selectedSite = site.id;
        projectMilestone.loadMilestone();
        Test.StopTest();
        
        System.assertEquals(testDataSubprojectId, projectMilestone.subProjectId);
        System.assertEquals(testDataSubprojectId, projectMilestone.subProject.Id);
        System.assertEquals(testMilestoneDefinitionList.size(), projectMilestone.milestoneDefinitionWrapperList.size());
    }
    
    static testMethod void createProductMilestoneRecords_Test()
    {
        Id testDataSubprojectId = subProject.Id;
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', testDataSubprojectId);
        ApexPages.CurrentPage().getParameters().put('type', 'Product');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        projectMilestone.selectedSite = site.id;
        projectMilestone.loadMilestone();
        projectMilestone.milestoneDefinitionWrapperList.get(0).isSelected = true;
        projectMilestone.milestoneDefinitionWrapperList.get(1).isSelected = true;
        projectMilestone.createProjectMilestones();
        Test.StopTest();
        
        System.assertEquals(testDataSubprojectId, projectMilestone.subProjectId);
        System.assertEquals(testDataSubprojectId, projectMilestone.subProject.Id);
        System.assertEquals(testMilestoneDefinitionList.size(), projectMilestone.milestoneDefinitionWrapperList.size());
        System.assertEquals(true, projectMilestone.isValid);
        
        List<Project_Milestone__c> createdProjectMilestones = [SELECT Id, Milestone_Definition__c FROM Project_Milestone__c WHERE SubProject__c =: testDataSubprojectId];
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
        Id testDataSubprojectId = subProject.Id;
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', testDataSubprojectId);
        ApexPages.CurrentPage().getParameters().put('type', 'Product');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        projectMilestone.selectedSite = site.id;
        projectMilestone.loadMilestone();
        projectMilestone.createProjectMilestones();
        Test.StopTest();
        
        System.assertEquals(testDataSubprojectId, projectMilestone.subProjectId);
        System.assertEquals(testDataSubprojectId, projectMilestone.subProject.Id);
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
        Id testDataSubprojectId = standardSubProject.Id;
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', standardSubProject.Id);
        ApexPages.CurrentPage().getParameters().put('type', 'Standard');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();        
        projectMilestone.loadMilestone();
        Test.StopTest();        
        
        System.assertEquals(testDataSubprojectId, projectMilestone.subProjectId);
        System.assertEquals(testDataSubprojectId, projectMilestone.subProject.Id);
        System.assertEquals(1, projectMilestone.milestoneDefinitionWrapperList.size());
    }
    
    static testMethod void createNewStandardMilestoneRecord_Test()
    {
        //test if the Project Milestones and Project Activities will be created in the subproject based on the selected
        //standard (non-product-based) milestone(s)
        createCustomSettings();        
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', standardSubProject.Id);
        ApexPages.CurrentPage().getParameters().put('type', 'Standard');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();     
        projectMilestone.loadMilestone();
        projectMilestone.milestoneDefinitionWrapperList.get(0).isSelected = true;         
        projectMilestone.createProjectMilestones();
        Test.StopTest();
        
        List<Project_Milestone__c> createdProjectMilestonesList = [SELECT Id, Milestone_Definition__c FROM Project_Milestone__c WHERE SubProject__c =: standardSubProject.Id];
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
        
        System.assertEquals(testStandardMilestoneDefinition.Id, createdProjectMilestonesList.get(0).Milestone_Definition__c);      
        System.assertEquals(1, createdProjectActivities.size());
        System.assertEquals(1, createdProjectTask.size());
    }
    
    static testMethod void noSelectedMilestonesCreateRecordsforStandardFail_Test()
    {
        //test what will happen when attempting to create Project Milestones and Project Activities when
        //no standard (non-product-based) milestone is selected
        createCustomSettings();
        
        Test.StartTest();
        
        ApexPages.CurrentPage().getParameters().put('subProjectId', standardSubProject.Id);
        ApexPages.CurrentPage().getParameters().put('type', 'Standard');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();   
        //projectMilestone.selectedSite = site.id;
        projectMilestone.loadMilestone();
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
    
    //This method tests the Add Product Milestone page functionality to exclude a milestone from the available user selectable list for
    //creating a new milestone or creating new activities underneath it. We assume the records have already been previously created
    //by the user (likely during a previous invocation of the same Add Product Milestone page).
    static testMethod void testAddProductMilestoneFilterPreventDuplicate()
    {   
        Project_Milestone__c insertMilestone = IMP_TestFactory_Helper.buildMilestoneStandard(subproject.id);       
        insertMilestone.Site__c = site.id;
        insertMilestone.Milestone_Definition__c = testMilestoneDefinitionList.get(0).id;
        insert insertMilestone;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', subProject.Id);
        ApexPages.CurrentPage().getParameters().put('type', 'Product');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        projectMilestone.selectedSite = site.id;
        projectMilestone.loadMilestone();
        //expect only 1 instead of 2 because the other milestone definition is already reference in a milestone record
        system.assertEquals(1, projectMilestone.milestoneDefinitionWrapperList.size());
        Test.stopTest();
    }
    
    static testMethod void NoSiteInSubproject_PreventRecordLoad()
    {
        SubProject__c subProject1 = IMP_TestFactory_Helper.buildSubProject(project.Id);
        insert subProject1;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', subProject1.Id);
        ApexPages.CurrentPage().getParameters().put('type', 'Product');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();      
        Boolean isError = false;
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {    
                if(msg.getDetail().contains( 'There is no existing site for this sub project, Please create a new site first.' )  )
                {
                    isError = true;
                }
            }
        }
        system.assert(isError);
        Test.stopTest();
    }
    
    static testMethod void testLoadNoMoreMilestoneForSelectedSite()
    {  
        Id testDataSubprojectId = subProject.Id;
        
        List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
        Project_Milestone__c insertMilestone = IMP_TestFactory_Helper.buildMilestoneStandard(testDataSubprojectId);       
        insertMilestone.Site__c = site.id;       
        insertMilestone.Milestone_Definition__c = testMilestoneDefinitionList.get(0).id;
        milestoneList.add(insertMilestone);
        
        Project_Milestone__c insertMilestone_2 = IMP_TestFactory_Helper.buildMilestoneStandard(testDataSubprojectId);        
        insertMilestone_2.Site__c = site.id;       
        insertMilestone_2.Milestone_Definition__c =testMilestoneDefinitionList.get(1).id;
        milestoneList.add(insertMilestone_2);
        
        insert milestoneList;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', testDataSubprojectId);
        ApexPages.CurrentPage().getParameters().put('type', 'Product');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        projectMilestone.selectedSite = site.id;
        projectMilestone.loadMilestone();
        Boolean isError = false;
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages(); 
        if (errorMessagesList != null) 
        {
            for(Apexpages.Message msg: errorMessagesList)
            {    
                if(msg.getDetail().contains( 'You already have added all Milestone to the site.  Please either select a different site, or exit by clicking the ‘Cancel button’' )  )
                {
                    isError = true;
                }
            }
        }
        system.assert(isError);
        Test.stopTest();
    }
    
    static testMethod void testRMSOwnedMilestoneDefinitionExcluded()
    {
        //Test if the RMS owned Definition is not included in the list       
        
        //create a milestone that is RMS owned/RMS Integration created it
        //activity and task will automatically be created because the rms milestone def has non-rms activity and task
        Id testDataSubprojectId = subProject.Id;
        Project_Milestone__c insertMilestone = IMP_TestFactory_Helper.buildMilestoneStandard(testDataSubprojectId);   
        insertMilestone.Site__c = site.id;
        insertMilestone.RMS_Owned_Flag__c = true;
        insertMilestone.Milestone_Definition__c = testRMSMilestoneDefinition.id;
        insert insertMilestone;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('subProjectId', testDataSubprojectId);
        ApexPages.CurrentPage().getParameters().put('type', 'Product');
        IMP_AddMilestones_Controller projectMilestone = new IMP_AddMilestones_Controller();
        projectMilestone.selectedSite = site.id;
        projectMilestone.loadMilestone();
        projectMilestone.milestoneDefinitionWrapperList.get(0).isSelected = true;         
        projectMilestone.createProjectMilestones();        
        Test.stopTest();
                
        List<Project_Activity__c> createdProjectActivitiesList = [SELECT Id FROM Project_Activity__c];
        List<Project_Task__c> createdProjectTaskList = [SELECT Id FROM Project_Task__c WHERE Project_Activity__c IN: createdProjectActivitiesList];
        List<Project_Milestone__c> existingMilestoneList = [SELECT id From Project_Milestone__c];
        //expect 2, there are only 2 that is a non-rms product milestone def, rms owned milestone def should not be included in the list
        system.assertEquals(2, projectMilestone.milestoneDefinitionWrapperList.size());
        //expect 3 , one is the automatic creation function the other two are from the add milestone function
        system.assertEquals(3, createdProjectActivitiesList.size());
        //expect 3 , one is the automatic creation function the other two are from the add milestone function
        system.assertEquals(3, createdProjectTaskList.size());
        //expect 2, one is rms the other one is non rms
        system.assertEquals(2, existingMilestoneList.size());
    }
    
    private static void createCustomSettings()
    {
        IMP_ProfilesToByPass__c profile = IMP_TestFactory_Helper.buildProfilesToByPass();
        insert profile;
    }
    
}