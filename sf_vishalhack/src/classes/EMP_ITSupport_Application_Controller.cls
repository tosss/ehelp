/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: 
Test Class: 
History
12/11/14    Rey Austral      Created
1/16/2015	Rey Austral		 Add function that hide/show the show more
------------------------------------------------------------*/
public class EMP_ITSupport_Application_Controller
{
    public String communityUrl { get; set; }
    public List<EMP_IT_Support_List__c> listApplicationImage { get; set;}
    public Boolean showAll { get; set; }
    public EMP_ITSupport_Application_Controller()
    {
        listApplicationImage  = [Select Name, Url__c, Image_Url__c from EMP_IT_Support_List__c where Section__c = 'IT Application'];
        showAll = false;
        if (listApplicationImage.size() == 5) {
            showAll = true;
        }
        communityUrl = Site.getBaseUrl();
    }
}