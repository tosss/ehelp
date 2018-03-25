/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: 
Test Class: 
History
12/11/14    Rey Austral      Created
------------------------------------------------------------*/
public class EMP_ITSupport_Answers_Controller {
    public String answerId { get; set; }
   
    public EMP_ITSupport_Answers_Controller()
    {        
        EMP_IT_Support__c cs = [Select name, ID__c from EMP_IT_Support__c where name = 'Chatter Answer' Limit 1];        
        if (cs != null) {
        	answerId = cs.ID__c;	
        }
    }
}