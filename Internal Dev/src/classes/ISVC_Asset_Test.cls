@isTest
private class ISVC_Asset_Test {
    
    @testSetup
    static void dataSetup() {
        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.firstName('Anna').lastName('Green').userId('testmanager').fedId('TESTMANAGER');
        personAccountBuilder.save();
        
        ISVC_PersonAccount_Builder personAccountBuilder2 = new ISVC_PersonAccount_Builder();
        personAccountBuilder2.firstName('Anna2').lastName('Green2').userId('testmanager2').fedId('TESTMANAGER2');
        personAccountBuilder2.save();
    }

    static testMethod void testSuccessfullAssetInsert() {
        Account managerAccount = [SELECT Id, PersonContactId FROM Account WHERE FedId__c = 'TESTMANAGER'];
        Asset a = new Asset(
                AccountId = managerAccount.Id,
                Name = 'UNIT TEST ASSET',
                Last_Sms_Scan_Date_Time__c = DateTime.now()
            );
            
        Test.startTest();
        insert a;
        Test.stopTest();
        
        for(Asset r : [SELECT Id, Status, Hardware_Owner__c, Active_Asset_Owner__c, Software_Refresh_Required__c FROM Asset WHERE Id =: a.Id]) {
            System.assertEquals(r.Status, 'Active');
            System.assertEquals(r.Hardware_Owner__c, managerAccount.Id);
            System.assertEquals(r.Active_Asset_Owner__c, managerAccount.Id);
            System.assertEquals(r.Software_Refresh_Required__c, true);
        }
    }
    
    static testMethod void testSuccessfullAssetUpdate() {
        Account managerAccount = [SELECT Id, PersonContactId FROM Account WHERE FedId__c = 'TESTMANAGER'];
        Asset a = new Asset(
                AccountId = managerAccount.Id,
                Name = 'UNIT TEST ASSET',
                Last_Sms_Scan_Date_Time__c = DateTime.now()
            );
        insert a;
        
        Account managerAccount2 = [SELECT Id, PersonContactId FROM Account WHERE FedId__c = 'TESTMANAGER2'];
        a.Last_Sms_Scan_Date_Time__c = DateTime.now().addDays(2);
        a.AccountId = managerAccount2.Id;
        Test.startTest();
        update a;
        Test.stopTest();
        
        for(Asset r : [SELECT Id, Status, Hardware_Owner__c, Active_Asset_Owner__c, Software_Refresh_Required__c FROM Asset WHERE Id =: a.Id]) {
            System.assertEquals(r.Status, 'Active');
            System.assertEquals(r.Hardware_Owner__c, managerAccount2.Id);
            System.assertEquals(r.Active_Asset_Owner__c, managerAccount2.Id);
            System.assertEquals(r.Software_Refresh_Required__c, true);
        }
    }
}