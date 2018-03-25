@isTest
private class ISVC_FeedItem_Test {

    @testSetup
    static void dataSetup() {
        Integer batchSize = 3;

        Id cdkSystemAdminProfileId = ALL_Profiles_Utility.getCdkAdminSystemAdministratorProfileId();
        Id requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();

        ISVC_PersonAccount_Builder personAccountBuilder = new ISVC_PersonAccount_Builder();
        personAccountBuilder.build();
        Account personAccount = personAccountBuilder.getRecord();
        ISVC_Account_Handler.triggerDisabled = true;
        insert personAccount;

        ALL_User_Builder cdkSystemAdminUserBuilder = new ALL_User_Builder(cdkSystemAdminProfileId);
        cdkSystemAdminUserBuilder.userName('cdksystemadminuser@cdk.com');
        cdkSystemAdminUserBuilder.build();
        User cdkSystemAdminUser = cdkSystemAdminUserBuilder.getRecord();

        personAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :personAccount.Id];
        cdkSystemAdminUser.Person_Account_Id__c = personAccount.Id;
        cdkSystemAdminUser.Person_Contact_Id__c = personAccount.PersonContactId;
        insert cdkSystemAdminUser;

        List<Case> requests = new List<Case>();
        for(Integer i=0; i<batchSize; i++){
            ISVC_Case_Builder requestCaseBuilder = new ISVC_Case_Builder();
            requestCaseBuilder.recordTypeId(requestRecordTypeId).subject('Request Test Case 00'+i)
                    .accountId(personAccount.Id).contactId(personAccount.PersonContactId).build();
            requests.add(requestCaseBuilder.getRecord());
        }
        insert requests;
    }

    //Succesfull flow
    static testMethod void testChangeCaseStatusToReContactUser() {
        Id requestRecordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId();
        User cdkSystemAdminUser = [SELECT Id FROM User WHERE Username = 'cdksystemadminuser@cdk.com'];
        //Given: list of request cases
        List<Case> requests = [SELECT Id, Status FROM Case WHERE RecordTypeId = :requestRecordTypeId];
        List<FeedItem> feedItems = new List<FeedItem>();
        for(Case request : requests){
            FeedItem feedItem = new FeedItem();
            feedItem.ParentId = request.Id;
            feedItem.Type = 'TextPost';
            feedItem.Body = 'test';
            feedItems.add(feedItem);
        }
        //When: insert feed items by case related accounts
        System.runAs(cdkSystemAdminUser) {
            Test.startTest();
            insert feedItems;
            Test.stopTest();
        }
        //Then: all related cases status is changed to Re-Contact User
        for(Case relatedCase : [SELECT Status FROM Case WHERE Id IN :requests]){
            System.assertEquals(ALL_Picklists_Utility.STATUS_RECONTACT_USER, relatedCase.Status);
        }
    }
}