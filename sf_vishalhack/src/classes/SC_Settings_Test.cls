/**
 * Test Class for Service Connect Settings
 *
 * Visual Force Page: SC_Settings
 * Test Class: SC_Settings_Test (This Class)
 */

// 2017-04-26 Sudhir.Moolky@cdk.com    Created
// 2017-05-03 Jack.Click@cdk.com       Add functionality


@isTest
public class SC_Settings_Test {
    /**
     * Test retrieval of global launch setting
     */
    @isTest static void testGetLaunchSetting()
    {
        insert new GlobalSettings__c(Launch_Service_Connect__c = true);
        GlobalSettings__c globalSettings = GlobalSettings__c.getInstance();

        SC_Settings_Handler scSettingsHandler = new SC_Settings_Handler();

        System.assert(globalSettings.Launch_Service_Connect__c);
        System.assert(scSettingsHandler.launchSetting);
        System.assertEquals(null, scSettingsHandler.launchComment);
    }

    /**
     * Test setting of global launch setting
     */
    @isTest static void testSetLaunchSetting()
    {
        insert new GlobalSettings__c(Launch_Service_Connect__c = true);
        GlobalSettings__c globalSettings = GlobalSettings__c.getInstance();

        SC_Settings_Handler scSettingsHandler = new SC_Settings_Handler();

        scSettingsHandler.launchSetting = false;
        scSettingsHandler.launchComment = 'test setting launch service connect';

        scSettingsHandler.saveSetting();

        globalSettings = GlobalSettings__c.getInstance();

        System.assert(!globalSettings.Launch_Service_Connect__c);
        System.assertEquals(null, scSettingsHandler.launchComment);
    }

    /**
     * Test auditing
     */
    @isTest static void testAuditing()
    {
        SC_Settings_Handler scSettingsHandler = new SC_Settings_Handler();
        scSettingsHandler.launchSetting = true;
        scSettingsHandler.launchComment = 'test audit';

        scSettingsHandler.createAudit();
        scSettingsHandler.createAudit();

        List<SC_Launch_Setting_Audit_Trail__c> audits = SC_Launch_Setting_Audit_Trail__c.getAll().values();
        System.assertEquals(2, audits.size());

        Integer auditLimit = 1;
        scSettingsHandler.cleanAudit(auditLimit);

        audits = SC_Launch_Setting_Audit_Trail__c.getAll().values();
        System.assertEquals(auditLimit, audits.size());
    }
}