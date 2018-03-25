/*------------------------------------------------------------
Author:      Jerick Laurio
Company:     Cloud Sherpas
Description: [Phase 2 Rel 1]Test Class for IMP_FollowedRecords_Controller
Test Class:  
History
03/12/15     Jerick Laurio          Created
03/20/15     Jerick Laurio          Cleaned and refactored
04/30/15     Jerick Laurio          Bug fixing
------------------------------------------------------------*/
@isTest
private class IMP_FollowedRecords_Controller_Test {
    
    /************************************************
    * Author: jlaurio@cloudsherpas.com
    * Date: 3/12/2015
    * Description: Positive scenario happy path
    **********************************************
    @isTest
    static void UnitTest_PositiveHappyPath()
    {
        // Given

        IMP_DataTableUISetting__c uiSetting = new IMP_DataTableUISetting__c();
        uiSetting.MaxNumberOfSearchResults__c = 5;
        uiSetting.NumberOfRecordsPerObject__c = 5;
        insert uiSetting;

        IMP_FollowedRecordsSetting__c frSetting = new IMP_FollowedRecordsSetting__c();
        frSetting.SobjectFieldsetPair__c = 'SubProject__c.SubProjectDataTableFields\nProject_Task__c.ProjectTaskDataTableFields\nProject_Log__c.ProjectLogDataTableFields'; 
        insert frSetting;

        Project__c testProject              = IMP_TestFactory_Helper.buildProject(1);
            testProject.CMF_Numbers__c      = 'testCMFNumber';
            testProject.Project_Status__c   = 'Open';
            testProject.Project_Region__c   = 'ARG-CANADA';
        insert testProject;

        EntitySubscription followRec1 = IMP_TestFactory_Helper.createFollowedRecord(testProject.Id);
        insert followRec1;

        SubProject__c subProjectRec             = IMP_TestFactory_Helper.buildSubProject(testProject.Id);
            subProjectRec.SubProject_Region__c  = 'Alliance PC Solutions Admin';
            subProjectRec.Number_of_User_Connections__c = 10;
            subProjectRec.Secondary_Project_Type__c     = 'Competitive Buy-Sell';
        insert subProjectRec;

        EntitySubscription followRec2 = IMP_TestFactory_Helper.createFollowedRecord(subProjectRec.Id);
        insert followRec2;

        // When
        PageReference pageRef = Page.IMP_HomePageFollowedTabSection;
        pageRef.getParameters().put('strIndex', '0');        
        Test.setCurrentPage(pageRef);
        IMP_FollowedRecords_Controller controller = new IMP_FollowedRecords_Controller();
        String selected = controller.selected;
        List<String> objectsToDisplayList = controller.objectsToDisplayList;
        controller.followedRecDTSetting = null;
        controller.objectsFieldSetMap = null;
        IMP_FollowedRecordsSetting__c userDTSetting = controller.userDTSetting;
        String selectedIndex = controller.selectedIndex;
        Map<String,String> objectsFieldSetMap = controller.objectsFieldSetMap;
        Set<Id> subProjectIds = new Set<Id>();
        subProjectIds.add(subProjectRec.Id);
        subProjectIds.add(testProject.Id);
        String createStringIdSet = controller.createStringIdSet(subProjectIds);
        controller.saveUserDataTableSetting();
        //String createSOQLSelect = controller.createSOQLSelect(Schema.FieldSet fieldSetName, String objectAPIName)SubProjectDataTableFields
        // Then
        System.debug('@#@#@#[TEST] controller.dataTableWrapper='+controller.dataTableWrapper);
        system.assert(controller.dataTableWrapper!=null);
    }

    /************************************************
    * Author: jlaurio@cloudsherpas.com
    * Date: 3/12/2015
    * Description: Negative scenario
    **********************************************
    @isTest
    static void UnitTest_PositiveNoSubscription()
    {
        // Given
        IMP_DataTableUISetting__c uiSetting = new IMP_DataTableUISetting__c();
        uiSetting.MaxNumberOfSearchResults__c = 5;
        uiSetting.NumberOfRecordsPerObject__c = 5;
        insert uiSetting;

        IMP_FollowedRecordsSetting__c frSetting = new IMP_FollowedRecordsSetting__c();
        frSetting.SobjectFieldsetPair__c = 'SubProject__c.SubProjectDataTableFields\nProject_Task__c.ProjectTaskDataTableFields\nProject_Log__c.ProjectLogDataTableFields'; 
        insert frSetting;

        // When
        IMP_FollowedRecords_Controller controller = new IMP_FollowedRecords_Controller();

        // Then
        System.debug('@#@#@#[TEST] controller.dataTableWrapper='+controller.dataTableWrapper);
        system.assert(controller.dataTableWrapper!=null);
    }*/
    
}