@isTest
private class ISVC_Account_Test {
    @testSetup
    static void dataSetup() {
        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.firstName('Anna').lastName('Green').userId('testmanager').fedId('TESTMANAGER');
        personAccountBuilder.save();
    }

    static testMethod void testSuccessfullUsersInsert() {
        Integer batchSize = 3;
        Account managerAccount = [SELECT PersonContactId FROM Account WHERE FedId__c = 'TESTMANAGER'];

        //Given: list of person accounts
        List<Account> personAccounts = new List<Account>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
            Account personAccount = personAccountBuilder.userId('test00'+i).fedId('TEST00'+i)
                    .managerId(managerAccount.PersonContactId).build().getRecord();
            personAccounts.add(personAccount);
        }

        //When: insert person accounts
        Test.startTest();
        insert personAccounts;
        Test.stopTest();

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

    static testMethod void testSuccessfullUsersUpdate() {
        Integer batchSize = 3;

        //Given: list of person accounts
        List<Account> personAccounts = new List<Account>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
            Account personAccount = personAccountBuilder.userId('test00'+i).fedId('TEST00'+i).build().getRecord();
            personAccounts.add(personAccount);
        }
        insert personAccounts;

        //When: update email address on person accounts
        for(Account account : personAccounts){
            account.In_AD__pc = false;
        }
        Test.startTest();
        update personAccounts;
        Test.stopTest();

        //Then: email address on users is updated
        List<User> newUsers = [SELECT IsActive FROM User WHERE FederationIdentifier LIKE 'TEST00%'];
        System.assertEquals(batchSize, newUsers.size());
        for(User user : newUsers){
            System.assertEquals(false, user.IsActive);
        }
    }
}