/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: test class for IMP_RemoveCMFtoSubProjectSite_Controller
Test Class: 
History
2/6/15    Rey Austral         Created
------------------------------------------------------------*/
@isTest
public class IMP_RemoveCMFtoSubProjectSite_Test {
    private static final Account account1_parent;
    private static final Account account1;
    private static final Account account2;
    private static final SubProject__c subProject;
    
    static {
        
        Site_Type__c siteType = IMP_TestFactory_Helper.buildSiteType();
        siteType.Group_Flag__c = true;
        insert siteType;
        
        account1_parent = IMP_TestFactory_Helper.buildAccount();
        account1_parent.Name = 'PARENT ACCOUNT';
        account1_parent.Site_Type__c = siteType.Id;
        insert account1_parent;
        
        account1 = IMP_TestFactory_Helper.buildAccount();
        account1.Name = 'CHILD ACCOUNT';
        account1.Site_Type__c = siteType.Id;
        account1.ParentId = account1_parent.Id;
        insert account1;
        
        account2 = IMP_TestFactory_Helper.buildAccount();
        insert account2;
        
        Project__c project = IMP_TestFactory_Helper.buildProject(0);
        insert project;
        
        subProject = IMP_TestFactory_Helper.buildSubProject(project.Id);
        insert subProject;
        
    }
    
    static testMethod void testLoadNoSiteExistsForSubproject() {        
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_RemoveCMFtoSubProjectSite_Controller controller = new IMP_RemoveCMFtoSubProjectSite_Controller();
        Test.StopTest();
        ApexPages.CurrentPage().getParameters().put('hasError','true');  
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('There is no existing site for this sub project, Please create a new site first.')) b = true;
        }
        //test if the error message will appear if no site is created
        system.assert(b);       
    }
    
     static testMethod void testLoadNoCMFRemainingToRemove() {
        CMF_Info__c cmfInfo = IMP_TestFactory_Helper.buildCMFInfo(account1.Id);
        cmfInfo.Name = 'TEST CMF NAME';        
        insert cmfInfo; 
        
        SubProjectSite__c subProjectSite = IMP_TestFactory_Helper.buildSubProjectSite( account1.Id,  subProject.Id,  cmfInfo.Id);        
        insert subProjectSite;        
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_RemoveCMFtoSubProjectSite_Controller controller = new IMP_RemoveCMFtoSubProjectSite_Controller();
        controller.selectedSite = subProjectSite.id;
        controller.populateGrid();  
        Test.StopTest();
         
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('There are no more CMFs on the site to delete.  Please either select a different site, or exit by clicking the ‘Cancel button’')) b = true;
        }
         //this if the error message will show if the site have no other cmf to remove
        system.assert(b);
        system.assertEquals(0, controller.cmfList.size());           
    }
    
    static testMethod void testSavingCMF() {
        CMF_Info__c cmfInfo = IMP_TestFactory_Helper.buildCMFInfo(account1.Id);
        cmfInfo.Name = 'TEST CMF NAME';        
        insert cmfInfo;     
        
        SubProjectSite__c subProjectSite = IMP_TestFactory_Helper.buildSubProjectSite( account1.Id,  subProject.Id,  cmfInfo.Id);        
        insert subProjectSite; 
        
        subProjectSite.CMF_Numbers__c = cmfInfo.Ship_CMF__c + ',12';
        update subProjectSite;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_RemoveCMFtoSubProjectSite_Controller controller = new IMP_RemoveCMFtoSubProjectSite_Controller();
        controller.selectedSite = subProjectSite.id;      
        controller.populateGrid();
        controller.cmfList.get(0).isSelected = true;       
        controller.Save();
        Test.StopTest();
        
        SubProjectSite__c testSite = [Select Id,CMF_Numbers__c from SubProjectSite__c where id =: subProjectSite.id];
        //test if the selected cmf number is remove
        system.assertEquals(2, controller.siteOptions.size());       
        system.assertEquals(cmfInfo.Ship_CMF__c,testSite.CMF_Numbers__c);
    }
    
    static testMethod void testSaveWithNoCMFSelected() {      
        
        CMF_Info__c cmfInfo = IMP_TestFactory_Helper.buildCMFInfo(account1.Id);
        cmfInfo.Name = 'TEST CMF NAME';        
        insert cmfInfo;     
        
        SubProjectSite__c subProjectSite = IMP_TestFactory_Helper.buildSubProjectSite( account1.Id,  subProject.Id,  cmfInfo.Id);        
        insert subProjectSite; 
        
        subProjectSite.CMF_Numbers__c = cmfInfo.Ship_CMF__c + ',12';
        update subProjectSite;
        
        Test.StartTest();
        ApexPages.CurrentPage().getParameters().put('id', subProject.Id);
        IMP_RemoveCMFtoSubProjectSite_Controller controller = new IMP_RemoveCMFtoSubProjectSite_Controller();
        controller.selectedSite = subProjectSite.id;      
        controller.populateGrid();        
        controller.Save();
        Test.StopTest();
        
        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('No CMF record(s) selected!')) b = true;
        }
        //test if the error message will show if the user did not select any record then try to save it
        system.assert(b);    
    }
}