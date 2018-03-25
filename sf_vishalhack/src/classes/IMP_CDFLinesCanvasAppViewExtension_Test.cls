// RQ-05791    - SubProject Home Page changes.
// Description - Test class for IMP_CDFLinesCanvasAppViewExtension 
// 2015-12-09  - Venkata.shrivol@cdk.com  - Created
//2016-12-05   -venkata.shrivol@cdk.com    -commented the project object reference RQ-08305
// 2017-03-01  - vishal.bandari@cdk.com - updated code to work with list of subproject Ids - RQ-08666
@isTest
public class IMP_CDFLinesCanvasAppViewExtension_Test 
{
	static testMethod void canvasAppExtensionTest()
    {
        
        SubProject__c testSubProject = IMP_TestFactory_Helper.buildSubProject();
        insert testSubProject;
        
        SubProject__c testSubProject2 = IMP_TestFactory_Helper.buildSubProject();
        insert testSubProject2;
        
        SubProject_Client_Contact__c spclientCont = new SubProject_Client_Contact__c();
        spclientCont.SubProject__c = testSubProject.Id;
        insert spclientCont;
        
        SubProject_CDK_Contact__c spcdkCont = new SubProject_CDK_Contact__c();
        spcdkCont.SubProject__c = testSubProject.Id;
        insert spcdkCont;
        
        Test.startTest();
        ApexPages.CurrentPage().getParameters().put('subProjectIds',testSubProject.Id+'|'+testSubProject2.Id);
        IMP_CDFLinesCanvasAppView_Extension testExtension = new IMP_CDFLinesCanvasAppView_Extension(new ApexPages.StandardController(testSubProject));
        testExtension.getParameterString();
        Test.stopTest();
    }
}