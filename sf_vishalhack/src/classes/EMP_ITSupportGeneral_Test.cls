/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test Class for EMP_ITSupport_General_Controller
History
1/21/15    Rey Austral      Created
------------------------------------------------------------*/
@isTest
public class EMP_ITSupportGeneral_Test {
	testMethod static void testLoadData()
    {
        generateContent();
        test.startTest();
        EMP_ITSupport_General_Controller controller = new EMP_ITSupport_General_Controller();
        test.stopTest();
        system.assertEquals(1, controller.listGeneralSection.size());
    }
    
    private static void generateContent()
    {
        EMP_IT_Support_List__c onboard = new EMP_IT_Support_List__c();
        onboard.Name = 'Test name';
        onboard.Url__c = 'www.yahoo.com';
        onboard.Description__c = 'Test';
        onboard.Section__c = 'IT Onboarding';
        insert onboard;
    }
}