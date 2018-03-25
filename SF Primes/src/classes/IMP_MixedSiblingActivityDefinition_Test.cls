/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test class for automatic creation of non-rms owned activity and task when a rms owned milestone is created
History
09/22/15    Rey Austral      Created
------------------------------------------------------------*/
@isTest
public class IMP_MixedSiblingActivityDefinition_Test 
{
    private static SubProjectSite__c site { get { return [Select id from SubProjectSite__c where SubProject_Name__c = 'Product Subproject' Limit 1]; } }
    private static Milestone_Definition__c testRMSMilestoneDefinition { get { return [Select id from Milestone_Definition__c where RMS_Activity_Code__c = 'RMS-Code' Limit 1]; } }
    private static SubProject__c subProject { get { return [Select id from SubProject__c where SubProject_Name__c = 'Product Subproject' Limit 1]; } }
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
        
        SubProject__c testDataSubProject2 = IMP_TestFactory_Helper.buildSubProject(testDataProject.Id);
        testDataSubProject2.SubProject_Name__c = 'Product Subproject 2';
        insert testDataSubProject2;
        
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
        
        SubProjectSite__c testDataSite2 = new SubProjectSite__c();
        testDataSite2.SubProject__c = testDataSubProject2.Id;
        testDataSite2.CMF_Name__c = cmf.Id;
        
        insert testDataSite2;
        
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
        
        insert testProductList;
        
        List<Project_Milestone_Definition_Product__c> testProjectMilestoneDefinitionProductList = new List<Project_Milestone_Definition_Product__c>();
        Project_Milestone_Definition_Product__c testProjectMilestoneDefinitionProduct = IMP_TestFactory_Helper.buildProjectMilestoneDefinitionProduct(testDataRMSMilestoneDefinition.Id, testProduct.Id);
        testProjectMilestoneDefinitionProductList.add(testProjectMilestoneDefinitionProduct);
        
        insert testProjectMilestoneDefinitionProductList;
    }
    
    static testMethod void testCreateNonRMSInRMSOwnedMilestone()
    // This test method confirms that if an RMS-Owned Project Milestone is created, the IMP_ProjectMilestone trigger extends the processing
    // to also create the non-RMS-Owned Project Activity children, if the RMS-Owned Project Milestone's definition record has a non-RMS-Owned
    // child Activity Definition record.
    {    
        User castIron = IMP_TestFactory_Helper.buildUser();
        castIron.ProfileId = [select id from profile where name = 'Cobalt Cast Iron Integration'].id;
        insert castIron;
        
        Test.StartTest();
        System.runAs(castIron) 
        {
            Project_Milestone__c insertMilestone = IMP_TestFactory_Helper.buildMilestoneStandard( subProject.Id);   
            insertMilestone.Site__c = site.id;
            insertMilestone.RMS_Owned_Flag__c = true;
            insertMilestone.Milestone_Definition__c = testRMSMilestoneDefinition.id;
            insert insertMilestone;
        }
        Test.stopTest();
        //test if a non-rms owned activity and task is created even if the dml statement only insert a milestone but is rms owned
        List<Project_Activity__c> createdProjectActivitiesList = [SELECT Id FROM Project_Activity__c];
        List<Project_Task__c> createdProjectTaskList = [SELECT Id FROM Project_Task__c WHERE Project_Activity__c IN: createdProjectActivitiesList];
        
        system.assertEquals(1, createdProjectActivitiesList.size());
        system.assertEquals(1, createdProjectTaskList.size());
    }
    
    static testMethod void testCreationOfMixedSiblingMultipleSubproject()
    // This test method confirms that if an RMS-Owned Project Milestone is created, the IMP_ProjectMilestone trigger extends the processing
    // to also create the non-RMS-Owned Project Activity children even if the milestone comes from different subproject, if the RMS-Owned Project Milestone's definition record has a non-RMS-Owned
    // child Activity Definition record.
    {    
        User castIron = IMP_TestFactory_Helper.buildUser();
        castIron.ProfileId = [select id from profile where name = 'Cobalt Cast Iron Integration'].id;
        insert castIron;
        
        SubProject__c subProject2 = [Select id from SubProject__c where SubProject_Name__c = 'Product Subproject 2' Limit 1];
        SubProjectSite__c site2 =  [Select id from SubProjectSite__c where SubProject_Name__c = 'Product Subproject 2' Limit 1]; 
                                        
        Test.StartTest();
        System.runAs(castIron) 
        {
            List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
                
            Project_Milestone__c insertMilestone = IMP_TestFactory_Helper.buildMilestoneStandard( subProject.Id);   
            insertMilestone.Site__c = site.id;
            insertMilestone.RMS_Owned_Flag__c = true;
            insertMilestone.Milestone_Definition__c = testRMSMilestoneDefinition.id;
            milestoneList.add(insertMilestone);
            
            Project_Milestone__c insertMilestone2 = IMP_TestFactory_Helper.buildMilestoneStandard( subProject2.Id);   
            insertMilestone2.Site__c = site2.id;
            insertMilestone2.RMS_Owned_Flag__c = true;
            insertMilestone2.Milestone_Definition__c = testRMSMilestoneDefinition.id;
            milestoneList.add(insertMilestone2);
            
            insert milestoneList;
            
            //test if a non-rms owned activity and task is created even if the dml statement only insert a milestone but is rms owned in all subproject
            List<Project_Activity__c> createdProjectActivitiesList = [SELECT Id FROM Project_Activity__c where Milestone__c =: insertMilestone.Id];
            List<Project_Task__c> createdProjectTaskList = [SELECT Id FROM Project_Task__c WHERE Project_Activity__c IN: createdProjectActivitiesList];
            
            List<Project_Activity__c> createdProjectActivitiesList2 = [SELECT Id FROM Project_Activity__c where Milestone__c =: insertMilestone2.Id];
            List<Project_Task__c> createdProjectTaskList2 = [SELECT Id FROM Project_Task__c WHERE Project_Activity__c IN: createdProjectActivitiesList2];
            
            system.assertEquals(1, createdProjectActivitiesList.size());
            
            system.assertEquals(1, createdProjectTaskList.size());
            
            system.assertEquals(1, createdProjectActivitiesList2.size());
            system.assertEquals(1, createdProjectTaskList2.size());
        }
        Test.stopTest();
       
    }
    
    static testMethod void testCreateOnlyNonRMSDefinition()
    // This test method confirms that if an RMS-Owned Project Milestone is created, the IMP_ProjectMilestone trigger extends the processing
    // to also create the non-RMS-Owned Project Activity children, if the RMS-Owned Project Milestone's definition record has a non-RMS-Owned
    // child Activity Definition record.  However, it does not create the RMS-Owned child Project Activity record, even though an RMS-Owned child
    // of the same parent Milestone Definition record exists, since, the trigger's role in creating records does not act as a proxy for the
    // Cast Iron Integration User, who is responsible for creating the same records through the load process.
    {
        User castIron = IMP_TestFactory_Helper.buildUser();
        castIron.ProfileId = [select id from profile where name = 'Cobalt Cast Iron Integration'].id;
        insert castIron;
        
        Activity_Definition__c testRMSActivityDefinition = IMP_TestFactory_Helper.buildActivityDefinition(testRMSMilestoneDefinition.Id);   
        testRMSActivityDefinition.RMS_Assignment_Type__c = 'RMS-Assign';
        insert testRMSActivityDefinition;
        
        Task_Definition__c testRMSTaskDefinition =  IMP_TestFactory_Helper.buildTaskDefinition(testRMSActivityDefinition.Id);
        testRMSTaskDefinition.Active__c = true;       
        testRMSTaskDefinition.Is_RMS_Owned__c = true;
        insert testRMSTaskDefinition;
        
        testRMSActivityDefinition.Active__c = true;
        update testRMSActivityDefinition;
        
        Test.StartTest();
        System.runAs(castIron) 
        {
            Project_Milestone__c insertMilestone = IMP_TestFactory_Helper.buildMilestoneStandard( subProject.Id);   
            insertMilestone.Site__c = site.id;
            insertMilestone.RMS_Owned_Flag__c = true;
            insertMilestone.Milestone_Definition__c = testRMSMilestoneDefinition.id;
            insert insertMilestone;
        }
        Test.stopTest();
        
        List<Project_Activity__c> createdProjectActivitiesList = [SELECT Id FROM Project_Activity__c];
        List<Project_Task__c> createdProjectTaskList = [SELECT Id FROM Project_Task__c WHERE Project_Activity__c IN: createdProjectActivitiesList];
        
        //Test if only non rms owned activity and task defintion is created
        //expected to be one even if there are two activity in the milestone definition because only 1 non-rms owned activity is assign to the milestone definition
        system.assertEquals(1, createdProjectActivitiesList.size());
        //expected to be one because only 1 non-rms owned task is assign to the activity definition
        system.assertEquals(1, createdProjectTaskList.size());
    }
}