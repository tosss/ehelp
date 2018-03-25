// RQ-05791    - SubProject Home Page changes.
// Description - Test class for IMP_CDFLinesCanvasAppViewExtension 
// 2015-12-09  - Venkata.shrivol@cdk.com  - Created

@isTest
public class IMP_CDFLinesCanvasAppViewExtension_Test 
{
	static testMethod void canvasAppExtensionTest()
    {
        Project__c testProject = IMP_TestFactory_Helper.buildProject(0);
        insert testProject;
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
        insert testSubProject;
        
        SubProject_Client_Contact__c spclientCont = new SubProject_Client_Contact__c();
        spclientCont.SubProject__c = testSubProject.Id;
        insert spclientCont;
        
        SubProject_CDK_Contact__c spcdkCont = new SubProject_CDK_Contact__c();
        spcdkCont.SubProject__c = testSubProject.Id;
        insert spcdkCont;
        
        Test.startTest();
        IMP_CDFLinesCanvasAppView_Extension testExtension = new IMP_CDFLinesCanvasAppView_Extension(new ApexPages.StandardController(testSubProject));
        testExtension.getParameterString();
        Test.stopTest();
    }
}