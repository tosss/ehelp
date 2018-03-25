/*------------------------------------------------------------
Author:      Jerick Laurio
Company:     Cloud Sherpas
Description: [Phase 2 Rel 1]Test Class for IMP_EnhanceListComponent_Controller
Test Class:  
History
03/13/15     Jerick Laurio          Created
03/20/15     Jerick Laurio          Cleaned and refactored
------------------------------------------------------------*/
@isTest
private class IMP_EnhanceListComponent_Controller_Test {
    
    /************************************************
     * Author: jlaurio@cloudsherpas.com
     * Date: 3/13/2015
     * Description: Positive scenario happy path
     ***********************************************/
    @isTest
    static void UnitTest_PositiveHappyPath()
    {
        // Given
        IMP_ListViewDataSetting__c lvdSetting = IMP_TestFactory_Helper.createListViewDataSetting();
        insert lvdSetting;
        // When
        //set Page
        PageReference pageRef = Page.IMP_HomePageFollowedTabSection;
        pageRef.getParameters().put('strIndex', '0');
        Test.setCurrentPage(pageRef);

        IMP_EnhanceListComponent_Controller controller = new IMP_EnhanceListComponent_Controller();

        List<String> objectsToDisplayList = controller.objectsToDisplayList;
        List<IMP_Library.genericDataTableAttributeWrapper> dataTableWrapper = controller.dataTableWrapper;
        String selectedIndex = controller.selectedIndex;
        controller.toggleTabItems();
        // Then
        system.assert(objectsToDisplayList!=null);
        system.assert(controller.dataTableWrapper!=null);
    }
    
}