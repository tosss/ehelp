/**
 * Class for handling Service Connect Settings
 *
 * Allow users to manage global custom settings such as "Launch Service Connect"
 *
 * Visual Force Page: SC_Settings
 * Test Class: SC_Settings_Test
 */

// 2017-04-17 Sudhir.Moolky@cdk.com    Created
// 2017-05-03 Jack.Click@cdk.com       Add functionality

global with sharing class SC_Settings_Handler {
    global GlobalSettings__c globalSettings;
    public boolean launchSetting { get; set; }
    public string launchComment { get; set; }
    public List<SC_Launch_Setting_Audit_Trail__c> launchChanges { get; set; }

    public SC_Settings_Handler()
    {
        globalSettings = GlobalSettings__c.getOrgDefaults();

        launchSetting = globalSettings.Launch_Service_Connect__c;
        launchComment = null;

        launchChanges = [SELECT Name, ModifiedAt__c, ModifiedBy__c, Comment__c, Action__c FROM SC_Launch_Setting_Audit_Trail__c ORDER BY ModifiedAt__c DESC];
    }

    public void saveSetting()
    {
        globalSettings.Launch_Service_Connect__c = launchSetting;
        update globalSettings;

        createAudit();

        launchComment = null;
    }

    @TestVisible private void createAudit()
    {
        SC_Launch_Setting_Audit_Trail__c newAudit = new SC_Launch_Setting_Audit_Trail__c(
            Name          = 'audit' + DateTime.now().getTime(),
            Action__c     = launchSetting ? 'enabled' : 'disabled',
            Comment__c    = launchComment,
            ModifiedBy__c = UserInfo.getName(),
            ModifiedAt__c = DateTime.now()
        );

        insert newAudit;

        launchChanges.add(newAudit);

        cleanAudit(10);
    }

    @TestVisible private void cleanAudit(Integer auditLimit) {
        List<SC_Launch_Setting_Audit_Trail__c> oldAudits = new List<SC_Launch_Setting_Audit_Trail__c>();

        while(launchChanges.size() > auditLimit) {
            oldAudits.add(launchChanges[0]);
            launchChanges.remove(0);
        }

        if (oldAudits.size() > 0) {
            delete oldAudits;
        }
    }
}