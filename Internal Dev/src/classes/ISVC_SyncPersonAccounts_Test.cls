@isTest
private class ISVC_SyncPersonAccounts_Test {
    @testSetup
    static void dataSetup() {
        Id cdkAdminIntegrationUserProfileId = ALL_Profiles_Utility.getCdkAdminIntegrationUserProfileId();
        ALL_User_Builder cdkAdminIntegrationUserBuilder = new ALL_User_Builder(cdkAdminIntegrationUserProfileId);
        cdkAdminIntegrationUserBuilder.userName('cdkadminintegrationuser@cdk.com');
        cdkAdminIntegrationUserBuilder.save();

        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.firstName('Anna').lastName('Green').userId('testmanager').fedId('TESTMANAGER');
        personAccountBuilder.save();
    }

    static testMethod void testSuccessfullPersonAccountsSync() {
        Integer batchSize = 3;

        User cdkAdminIntegrationUser = [SELECT Id FROM User WHERE Username = 'cdkadminintegrationuser@cdk.com'];
        Account managerAccount = [SELECT PersonContactId FROM Account WHERE FedId__c = 'TESTMANAGER'];

        //Given: list of person accounts
        List<Account> personAccounts = new List<Account>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
            Account personAccount = personAccountBuilder.userId('test00'+i).fedId('TEST00'+i)
                    .managerId(managerAccount.PersonContactId).build().getRecord();
            personAccounts.add(personAccount);
        }
        ISVC_Account_Handler.triggerDisabled = true;
        insert personAccounts;

        //When: ask to sync person accounts with users
        System.runAs(cdkAdminIntegrationUser){
        personAccounts = [
                SELECT Id, PersonContactId, User_Id__pc, FirstName, LastName, PersonEmail, FedId__c, Employee_Id__pc,
                        Manager__pc, Phone, Phone_Extension__pc, PersonMobilePhone, In_AD__pc
                FROM Account WHERE FedId__c LIKE 'TEST00%'];
            Test.startTest();
            Map<Id, Account> personAccountsMap = new Map<Id, Account>(personAccounts);
            System.enqueueJob(new ISVC_SyncPersonAccounts_Queueable(personAccountsMap));
            Test.stopTest();
        }

        //Then: new users with Company Community Profile and assigned manager are created
        Id companyCommunitiesUserProfileId = ALL_Profiles_Utility.getCompanyCommunitiesUserProfileId();
        User managerUser = [SELECT Id FROM User WHERE Person_Contact_Id__c = :managerAccount.PersonContactId];
        List<User> newUsers = [SELECT ProfileId, ManagerId, IsActive FROM User WHERE FederationIdentifier LIKE 'TEST00%'];
        System.assertEquals(batchSize, newUsers.size());
        for(User user : newUsers){
            System.assertEquals(companyCommunitiesUserProfileId, user.ProfileId);
            System.assertEquals(managerUser.Id, user.ManagerId);
            System.assertEquals(true, user.IsActive);
        }
    }

    static testMethod void testIntegrationError() {
        Integer batchSize = 3;

        User cdkAdminIntegrationUser = [SELECT Id FROM User WHERE Username = 'cdkadminintegrationuser@cdk.com'];

        //Given: list of person accounts without email address
        List<Account> personAccounts = new List<Account>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
            Account personAccount = personAccountBuilder.userId('test00'+i).fedId('TEST00'+i)
                    .personEmail('').build().getRecord();
            personAccounts.add(personAccount);
        }
        ISVC_Account_Handler.triggerDisabled = true;
        insert personAccounts;

        //When: ask to sync person accounts with users
        System.runAs(cdkAdminIntegrationUser){
            personAccounts = [
                    SELECT Id, PersonContactId, User_Id__pc, FirstName, LastName, PersonEmail, FedId__c, Employee_Id__pc,
                            Manager__pc, Phone, Phone_Extension__pc, PersonMobilePhone, In_AD__pc
                    FROM Account WHERE FedId__c LIKE 'TEST00%'];
            Test.startTest();
            Map<Id, Account> personAccountsMap = new Map<Id, Account>(personAccounts);
            System.enqueueJob(new ISVC_SyncPersonAccounts_Queueable(personAccountsMap));
            Test.stopTest();
        }

        //Then: users are not created and integration error is created for each person account
        Id companyCommunitiesUserProfileId = ALL_Profiles_Utility.getCompanyCommunitiesUserProfileId();
        List<User> newUsers = [SELECT Id FROM User WHERE FederationIdentifier LIKE 'TEST00%' AND ProfileId = :companyCommunitiesUserProfileId];
        System.assertEquals(0, newUsers.size());
        for(Account account : [SELECT Id, (SELECT Id FROM Integration_Errors__r) FROM Account WHERE FederationId__pc LIKE 'TEST00%']){
            System.assertEquals(1, account.Integration_Errors__r.size());
        }
    }
}