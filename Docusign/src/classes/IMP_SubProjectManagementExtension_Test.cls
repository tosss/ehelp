/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: IMP_SubProjectManagementExtension test class
History
09/17/14    Michael Lasala      Created
11/27/14    Samuel Oberes       Implemented IMP_TestFactory_Helper methods
------------------------------------------------------------*/
@isTest
public class IMP_SubProjectManagementExtension_Test {
    
    static testMethod void constructorNoTab_Test(){
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        Test.StartTest();
      
        ApexPages.CurrentPage().getParameters().put('id', testSubProject.Id);
        IMP_SubProjectManagement_Extension subproject = new IMP_SubProjectManagement_Extension();
        Test.StopTest();
        
        System.assertEquals(testProject.Id, testSubProject.Project__c);
        System.assertEquals(testSubProject.Id, subproject.subProject.Id);
        System.assertEquals(testSubProject.Milestones_Auto_Generated_Flag__c, subproject.isGenerated);
        System.assertEquals(IMP_Project_Utility.TAB_SUBPROJECT, subproject.defaultTab);
    }
}