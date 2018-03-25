/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Test Class for EMP_ITSupport_Application_Controller
History
1/21/15    Rey Austral      Created
------------------------------------------------------------*/
@isTest
public class EMP_ITSupport_Application_Test {
    testMethod static void test_LoadData() {
        generateContent();
        test.startTest();
        EMP_ITSupport_Application_Controller controller = new EMP_ITSupport_Application_Controller();
        test.stopTest();
    }
    
    private static void generateContent() {
        List<EMP_IT_Support_List__c>  c = new List<EMP_IT_Support_List__c>();
        Integer ctr = 0;
        for (ctr=0;ctr>6;ctr++) 
        {
            EMP_IT_Support_List__c sample = new EMP_IT_Support_List__c();
            sample.Name = 'Test Name' + ctr;
            sample.Url__c = 'google.com';
            sample.Image_URL__c = 'image.png';
            c.add(sample);
        }
        insert c;
    }
}