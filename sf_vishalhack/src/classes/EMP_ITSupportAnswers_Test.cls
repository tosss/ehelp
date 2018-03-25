/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test Class for EMP_ITSupport_Answers_Controller
History
1/21/15    Rey Austral      Created
------------------------------------------------------------*/
@isTest
public class EMP_ITSupportAnswers_Test {
    testMethod static void testLoadData() 
    {
        string answerId = generateCustomSettings();
        test.startTest();
        EMP_ITSupport_Answers_Controller controller = new EMP_ITSupport_Answers_Controller();
        test.stopTest();
        system.assertEquals(controller.answerId,answerId);
    }
    
	private static string generateCustomSettings()
    {
        EMP_IT_Support__c it = new EMP_IT_Support__c();
        it.Name = 'Chatter Answer';
        it.Id__c = '09ae00000004Cs8';
        insert it;
        return it.Id__c;
    }
}