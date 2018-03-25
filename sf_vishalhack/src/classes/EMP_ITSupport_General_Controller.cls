/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: 
Test Class: EMP_ITSupportGeneral_Test
History
12/11/14    Rey Austral      Created
------------------------------------------------------------*/
public class EMP_ITSupport_General_Controller {
    public List<EMP_IT_Support_List__c> listGeneralSection { get; set; }
    public EMP_ITSupport_General_Controller () {
          listGeneralSection  =  [Select Name, Url__c, Description__c from EMP_IT_Support_List__c where Section__c = 'IT Onboarding'];
    }
}