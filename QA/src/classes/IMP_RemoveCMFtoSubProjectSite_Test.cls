/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: test class for IMP_RemoveCMFtoSubProjectSite_Controller
Test Class: 
History
2/6/15    Rey Austral         Created
8/12/15	  Rey Austral		  Add testPreventRemovingCMF and use @testSetup
------------------------------------------------------------*/
@isTest
public class IMP_RemoveCMFtoSubProjectSite_Test 
{   
    private static Account account1 { get { return [Select Id from Account where Name = 'CHILD ACCOUNT' Limit 1]; } }    
    private static SubProject__c subProject { get { return [Select Id from SubProject__c where SubProject_Name__c = 'With Site' Limit 1 ]; } }
    private static SubProject__c subProject_2 { get { return [Select Id from SubProject__c where SubProject_Name__c = 'No Site' Limit 1 ]; } }
    private static SubProjectSite__c subProjectSite { get { return [Select Id,CMF_Numbers__c from SubProjectSite__c Limit 1 ]; } }
    private static CMF_Info__c cmfInfo { get { return [Select Id,Ship_CMF__c from CMF_Info__c Limit 1];} }
    @testSetup static void setup() 
    {  
        Site_Type__c siteType = IMP_TestFactory_Helper.buildSiteType();
        siteType.Group_Flag__c = true;
        insert siteType;
        
        Account testAccount1_parent = IMP_TestFactory_Helper.buildAccount();
        testAccount1_parent.Name = 'PARENT ACCOUNT';
        testAccount1_parent.Site_Type__c = siteType.Id;
        insert testAccount1_parent;
        
        Account testChildAccount = IMP_TestFactory_Helper.buildAccount();
        testChildAccount.Name = 'CHILD ACCOUNT';
        testChildAccount.Site_Type__c = siteType.Id;
        testChildAccount.ParentId = testAccount1_parent.Id;
        insert testChildAccount;
        
        Account testAccount2 = IMP_TestFactory_Helper.buildAccount();
        insert testAccount2;
        
        Project__c project = IMP_TestFactory_Helper.buildProject(0);
        insert project;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(project.Id);
        testSubProject.SubProject_Name__c = 'With Site';
        insert testSubProject;
        
        SubProject__c testSubProject2 = IMP_TestFactory_Helper.buildSubProject(project.Id);
        testSubProject2.SubProject_Name__c = 'No Site';
        insert testSubProject2;
        
        CMF_Info__c testCmfInfo = IMP_TestFactory_Helper.buildCMFInfo(account1.Id);
        testCmfInfo.Name = 'TEST CMF NAME';        
        insert testCmfInfo;     
        
        SubProjectSite__c testSubProjectSite = IMP_TestFactory_Helper.buildSubProjectSite( account1.Id,  subProject.Id,  testCmfInfo.Id);        
        testSubProjectSite.CMF_Numbers__c = testCmfInfo.Ship_CMF__c + ',12';
        insert testSubProjectSite; 
    }
    
    static testMethod void testLoadNoSiteExistsForSubproject() 
    {                
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject_2.Id);
        IMP_RemoveCMFtoSubProjectSite_Controller controller = new IMP_RemoveCMFtoSubProjectSite_Controller();
        Test.StopTest();
        ApexPages.CurrentPage().getParameters().put('hasError','true');  
        
        List<Apexpages.Message> msgsList = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgsList)
        {
            if (msg.getDetail().contains('There is no existing site for this sub project, Please create a new site first.')) b = true;
        }
        //test if the error message will appear if no site is created
        system.assert(b);       
    }
    
     static testMethod void testLoadNoCMFRemainingToRemove() 
     {
        Id testDataSubprojectId = subProject.Id;
         
      	SubProjectSite__c site = subProjectSite;
        site.CMF_Numbers__c = '';
        update site;
         
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', testDataSubprojectId);
        IMP_RemoveCMFtoSubProjectSite_Controller controller = new IMP_RemoveCMFtoSubProjectSite_Controller();
        controller.selectedSite = subProjectSite.id;
        controller.populateGrid();  
        Test.StopTest();
         
        List<Apexpages.Message> msgsList = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgsList)
        {
            if (msg.getDetail().contains('There are no more CMFs on the site to delete.  Please either select a different site, or exit by clicking the ‘Cancel button’')) b = true;
        }
         //this if the error message will show if the site have no other cmf to remove
        system.assert(b);
        system.assertEquals(0, controller.cmfList.size());           
    }
    
    static testMethod void testSavingCMF() 
    {   
        Id subProjectSiteId = subProjectSite.id;
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_RemoveCMFtoSubProjectSite_Controller controller = new IMP_RemoveCMFtoSubProjectSite_Controller();
        controller.selectedSite = subProjectSiteId;      
        controller.populateGrid();
        controller.cmfList.get(0).isSelected = true;       
        controller.Save();
        Test.StopTest();
        
        SubProjectSite__c testSite = [Select Id,CMF_Numbers__c from SubProjectSite__c where id =: subProjectSiteId];
        //test if the selected cmf number is remove
        system.assertEquals(2, controller.siteOptions.size());       
        system.assertEquals(cmfInfo.Ship_CMF__c,testSite.CMF_Numbers__c);
    }
    
    static testMethod void testSaveWithNoCMFSelected() 
    {   
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_RemoveCMFtoSubProjectSite_Controller controller = new IMP_RemoveCMFtoSubProjectSite_Controller();
        controller.selectedSite = subProjectSite.id;      
        controller.populateGrid();        
        controller.Save();
        Test.StopTest();
        
        List<Apexpages.Message> msgsList = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgsList)
        {
            if (msg.getDetail().contains('No CMF record(s) selected!')) b = true;
        }
        //test if the error message will show if the user did not select any record then try to save it
        system.assert(b);    
    }
    
    static testMethod void testPreventRemovingCMF() 
    { 
        Id testDataSubprojectId = subProject.Id;
        
        Project_Milestone__c milestone = IMP_TestFactory_Helper.buildMilestoneNonStandard(testDataSubprojectId, 'test');
        milestone.Site__c = subProjectSite.Id;
        insert milestone;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', testDataSubprojectId);
        IMP_RemoveCMFtoSubProjectSite_Controller controller = new IMP_RemoveCMFtoSubProjectSite_Controller();
        controller.selectedSite = subProjectSite.id;      
        controller.populateGrid();   
        Test.StopTest();
        
        List<Apexpages.Message> msgsList = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgsList)
        {
            if (msg.getDetail().contains('The SubProjectSite is already associated with one or more milestones.  As a result, it is no longer possible to remove a CMF from it')) b = true;
        }
        //test if the error message will show if the user select a site that has a milestone reference on it
        system.assert(b);  
    }
}