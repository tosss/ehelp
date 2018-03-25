/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Test class for IMP_DisplayMissionController
Test Class:
History
10/02/14    Kimiko Roberto      Created
------------------------------------------------------------*/
@isTest
private class IMP_DisplayMissionController_Test{
    
    static testMethod void IMP_DisplayMissionController_Test(){
        //test page for displating NIS Mission records by adding a Mission Name to see if tehre is a matching record
        PageReference page = new PageReference('/apex/IMP_DisplayMission?param1='+'123');  
        test.setCurrentPage(page);
        IMP_DisplayMission_Controller controller = new IMP_DisplayMission_Controller();
        system.AssertNotEquals(controller.generateJsonParam1, null);
        
    }
        
}