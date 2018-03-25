/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: ALL_DataTableComponent_Extension test class
History
03/24/15     Samuel Oberes       Created
------------------------------------------------------------*/
@isTest
private class ALL_DataTableComponent_Extension_Test 
{
    private static User vicUser;
    private static IMP_DataTableUISetting__c uiSetting;
    private static Project__c project;
    private static SubProject__c subProject;
    private static EntitySubscription followedRecord;
    private static ALL_DataTableComponent_Controller csDataTableInstance;

    static 
    {
        vicUser = IMP_TestFactory_Helper.buildUserImplementationVIC();
        try
        {
            insert vicUser;
        }
        catch (DmlException e) 
        {
            System.debug('DBG: Error encountered >>> ' + e.getMessage());
        }

        uiSetting                                = new IMP_DataTableUISetting__c();
        uiSetting.MaxNumberOfSearchResults__c    = 10;
        uiSetting.MinNumberOfSearchCharacters__c = 5;
        uiSetting.NumberOfRecordsPerObject__c    = 20;
        try
        {
            insert uiSetting;
        }
        catch (DmlException e) 
        {
            System.debug('DBG: Error encountered >>> ' + e.getMessage());
        }

        project                     = IMP_TestFactory_Helper.buildProject(0);
        project.Name                = 'projectName';
        project.CMF_Numbers__c      = 'testCMFNumber';
        project.Project_Status__c   = 'Open';
        project.Project_Region__c   = 'ARG-CANADA';
        try
        {
            insert project;
        }
        catch (DmlException e) 
        {
            System.debug('DBG: Error encountered >>> ' + e.getMessage());
        }

        subProject                               = IMP_TestFactory_Helper.buildSubProject(project.Id);
        subProject.SubProject_Region__c          = 'Alliance PC Solutions Admin';
        subProject.Secondary_Project_Type__c     = 'Competitive Buy-Sell';
        try
        {
            insert subProject;
        }
        catch (DmlException e) 
        {
            System.debug('DBG: Error encountered >>> ' + e.getMessage());
        }

        followedRecord              = new EntitySubscription();
        followedRecord.ParentId     = subProject.Id;
        followedRecord.SubscriberId = UserInfo.getUserId();
        try
        {
            insert followedRecord;
        }
        catch (DmlException e)
        {
            System.debug('DBG: Error encountered >>> ' + e.getMessage());
        }
        
        csDataTableInstance                         = new ALL_DataTableComponent_Controller();
        csDataTableInstance.objLabelName            = 'testObjectLabelName';
        csDataTableInstance.objApiName              = 'SubProject__c';
        csDataTableInstance.objIdPrefixCode         = '09213';
        csDataTableInstance.objEntityId             = '096171097412';
        csDataTableInstance.selectQueryString       = 'SELECT Id, Name, Project_Type__c, SubProject_Status__c, New_IP_Address__c FROM SubProject__c';
        csDataTableInstance.selectWhereClauseString = 'WHERE Project_Type__c=\'' + subProject.Project_Type__c + '\'';
        csDataTableInstance.queryLimitNum           = 5;
        csDataTableInstance.selectOrderString       = 'ORDER BY Id DESC';
        csDataTableInstance.objConsoleOpenInSubTab  = true;
        csDataTableInstance.showFilter              = true;
        csDataTableInstance.filterFieldSetName      = 'SubProjectFilterFields';
        csDataTableInstance.columnFieldSetName      = 'SubProjectDataTableFields';
        csDataTableInstance.useAltColumns           = true;
        csDataTableInstance.altColumnsJSONString    = 'testAltColumnJSON';
        csDataTableInstance.recordsPerPage          = 10;
        csDataTableInstance.size                    = 10;
        csDataTableInstance.noOfRecords             = 10;
        csDataTableInstance.showEditAll             = true;

    }

    private static testmethod void randomNumberGeneration_Test() 
    {
        ALL_DataTableComponent_Extension ctrlr = new ALL_DataTableComponent_Extension(csDataTableInstance);
        Integer rnd = ctrlr.randomNumber;
        for (Integer i = 0; i < 3; i++) 
        {
            System.assert(rnd > 0);
            System.assert(rnd < 1000);
        }
    }

    private static testmethod void editStatus_Test() 
    {
        ALL_DataTableComponent_Extension ctrlr = new ALL_DataTableComponent_Extension(csDataTableInstance);
        System.assertEquals(null, ctrlr.isEdit);
        ctrlr.edit();
        System.assertEquals(true, ctrlr.isEdit);
        ctrlr.cancelEdit();
        System.assertEquals(false, ctrlr.isEdit);
    }

    private static testmethod void refreshPage_Test() 
    {
        ALL_DataTableComponent_Extension ctrlr = new ALL_DataTableComponent_Extension(csDataTableInstance);
        System.assertEquals(null, ctrlr.refreshPage());
    }

    private static testmethod void saveAndClose_Test()
    {
        // INIT
        ALL_DataTableComponent_Extension dtcExt = new ALL_DataTableComponent_Extension(csDataTableInstance);

        // TESTS PROPER
        // --- POSITIVE
        String recordId        = (String)csDataTableInstance.recordsPerObj.selectSObjList.get(0).sObj.get('Id');
        String recordIpAddress = (String)csDataTableInstance.recordsPerObj.selectSObjList.get(0).sObj.get('New_IP_Address__c');

        String NEW_RECORD_IPADDRESS = '10.10.10.10';
        csDataTableInstance.recordsPerObj.selectSObjList.get(0).sObj.put('New_IP_Address__c', NEW_RECORD_IPADDRESS);

        dtcExt.saveAndClose();

        System.assertEquals(false, dtcExt.isEdit);
        System.assertEquals(0, ApexPages.getMessages().size());

        String queriedIpAddress = [SELECT New_IP_Address__c FROM SubProject__c WHERE Id = :recordId].New_IP_Address__c;
        System.assertNotEquals(recordIpAddress, queriedIpAddress);
        System.assertEquals(NEW_RECORD_IPADDRESS, queriedIpAddress);

        // --- NEGATIVE
        NEW_RECORD_IPADDRESS = '10.10.10.10.10.10.10.10.10.10.10.10.10.10.'; // 42 chars -> exceeds 40 limit
        String ERROR_MESSAGE = 'New IP Address: data value too large: 10.10.10.10.10.10.10.10.10.10.10.10.10.10. (max length=40)';
        csDataTableInstance.recordsPerObj.selectSObjList.get(0).sObj.put('New_IP_Address__c', NEW_RECORD_IPADDRESS);

        dtcExt.saveAndClose();

        System.assertEquals(true, dtcExt.isEdit);
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(ApexPages.Severity.ERROR, ApexPages.getMessages().get(0).getSeverity());
        System.assertEquals(ERROR_MESSAGE, ApexPages.getMessages().get(0).getDetail());
    }

    private static testmethod void followUnfollowItems_Test() 
    {
        ALL_DataTableComponent_Extension.followItem(subProject.Id);
        System.assertEquals(1, [SELECT COUNT() FROM EntitySubscription WHERE ParentId = :subProject.Id AND SubscriberId = :UserInfo.getUserId()]);

        ALL_DataTableComponent_Extension.unFollowItem(subProject.Id);
        System.assertEquals(0, [SELECT COUNT() FROM EntitySubscription WHERE ParentId = :subProject.Id AND SubscriberId = :UserInfo.getUserId()]);
    }

}