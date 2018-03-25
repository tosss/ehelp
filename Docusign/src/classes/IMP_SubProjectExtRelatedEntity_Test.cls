/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Test class for the IMP_SubProjectExtRelatedEntity_Handler
History
12/29/14     Samuel Oberes      Created
01/01/15     Samuel Oberes      Added the updated scenario for insertDeleteRecord_Test
01/05/15     Samuel Oberes      renamed method from insertNewRecord to insertOrUpdateRecord
01/22/15     Samuel Oberes      Added System.runAs(userPM) logic all over the class
01/29/15     Samuel Oberes      Added first name for 'userPM' since a code in EMP needs this
                                Changed Implem PM name in where clause from 'ADPDS - Implementation - PM' to 'ADPDS - Implementation PM'
02/06/15     Samuel Oberes      Updated assertions in the UPDATE scenario of insertOrUpdateOrDeleteRecord
------------------------------------------------------------*/
@isTest
private class IMP_SubProjectExtRelatedEntity_Test {

    private static final String CMF_NAME_1 = 'CMF_1';
    private static final String CMF_NAME_2 = 'CMF_2';

    private static final Account account1;
    private static final Account account2;
    private static final Project__c project;
    private static final SubProject__c subProject;
    
    private static CMF_Info__c cmfInfo1;
    private static CMF_Info__c cmfInfo2;

    private static User userPM;

    static {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'ADPDS - Implementation - PM' or Name = 'ADPDS - Implementation PM' Limit 1]; 

        userPM = new User(Alias = 'standt', 
                          Email = 'standarduser@testorg.com123', 
                          EmailEncodingKey = 'UTF-8', 
                          FirstName = 'First Name', 
                          LastName = 'Testing', 
                          LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', 
                          ProfileId = profile.Id, 
                          TimeZoneSidKey = 'America/Los_Angeles', 
                          UserName = 'standarduser@testorg.com123', 
                          ADID__c = ALL_UtilitiesRandom.TrueRandomUpToAMillion());

        System.runAs(userPM) {
        
            account1 = IMP_TestFactory_Helper.buildAccount();
            insert account1;

            account2 = IMP_TestFactory_Helper.buildAccount();
            insert account2;

            project = IMP_TestFactory_Helper.buildProject(0);
            insert project;

            subProject = IMP_TestFactory_Helper.buildSubProject(project.Id);
            insert subProject;

            // CMF INFO that uses account1
            cmfInfo1 = new CMF_Info__c();
            cmfInfo1.Account__c = account1.Id;
            cmfInfo1.Name = CMF_NAME_1;
            cmfInfo1.Status__c = 'A';

            // CMF INFO that uses account2
            cmfInfo2 = new CMF_Info__c();
            cmfInfo2.Account__c = account2.Id;
            cmfInfo2.Name = CMF_NAME_2;
            cmfInfo2.Status__c = 'A';

        }
    }

    // =================================================================================

    private static testmethod void insertOrUpdateRecord_NullShipCmf_AsPM_Test() {
        System.runAs(userPM) {
            IMP_SubProjectExtRelatedEntity_Test.insertOrUpdateRecord_NullShipCmf();
        }
    }
    private static testmethod void insertOrUpdateRecord_NullShipCmf_Test() {
        IMP_SubProjectExtRelatedEntity_Test.insertOrUpdateRecord_NullShipCmf();
    }
    private static void insertOrUpdateRecord_NullShipCmf() {
        
        Test.startTest();

        // -------------------------------------------

        cmfInfo1.Ship_CMF__c = null;
        insert cmfInfo1;

        SubProjectSite__c subProjectSite = new SubProjectSite__c();
        subProjectSite.SubProject__c = subProject.Id;
        subProjectSite.CMF_Name__c = cmfInfo1.Id;
        insert subProjectSite;

        // no new SubProject_External_Related_Entity__c record should be created if Ship_CMF__c value inherited from CMF_Info__c is null
        System.assertEquals(0, [SELECT COUNT() FROM SubProject_External_Related_Entity__c]);

        // -------------------------------------------

        Test.stopTest();
    }

    // =================================================================================

    private static testmethod void insertOrUpdateOrDeleteRecord_AsPM_Test() {
        System.runAs(userPM) {
            IMP_SubProjectExtRelatedEntity_Test.insertOrUpdateOrDeleteRecord();
        }
    }
    private static testmethod void insertOrUpdateOrDeleteRecord_Test() {
        IMP_SubProjectExtRelatedEntity_Test.insertOrUpdateOrDeleteRecord();
    }
    private static void insertOrUpdateOrDeleteRecord() {
        
        Test.startTest();

        // -------------------------------------------

        List<SubProject_External_Related_Entity__c> relatedEntitiesList;

        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;

        cmfInfo2.Ship_CMF__c = CMF_NAME_2;
        insert cmfInfo2;

        // -------------------------------------------
        // SCENARIO: INSERTION

        SubProjectSite__c subProjectSite = new SubProjectSite__c();
        subProjectSite.SubProject__c = subProject.Id;
        subProjectSite.CMF_Name__c = cmfInfo1.Id;
        insert subProjectSite;

        // there should be 1 new successfully created related entity because Ship_CMF__c is not null; also, will confirm that the one that exist matches the one we just created.
        relatedEntitiesList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c, Entity_Type__c FROM SubProject_External_Related_Entity__c];
        System.assertEquals(1, relatedEntitiesList.size());

        // subProject site's cmf name should be equal to related entity's entity number
        System.assertEquals(CMF_NAME_1, relatedEntitiesList.get(0).Entity_Number__c);

        // subProject site's subProject Id should be equal to related entity's subProject Id
        System.assertEquals(subProject.Id, relatedEntitiesList.get(0).SubProject__c);

        // subProject site's project Id should be equal to related entity's project Id
        System.assertEquals(project.Id, relatedEntitiesList.get(0).Project__c);

        // related entity's entity type should be equal to 'CMF'
        System.assertEquals('CMF', relatedEntitiesList.get(0).Entity_Type__c);

        // -------------------------------------------
        // SCENARIO: INSERTION 2 (Test to show that insertion of a duplicate external related entity is not allowed. The transaction will actually be caught in as early as the subproject site level.)

        SubProjectSite__c subProjectSite2 = new SubProjectSite__c();
        subProjectSite2.SubProject__c = subProject.Id;
        subProjectSite2.CMF_Name__c = cmfInfo1.Id;

        try {
            insert subProjectSite2;
            System.assertEquals('Expecting not to reach this part of the code because a duplicate site should trigger an error.', 
                                'This code has been reached. The expected error due to duplicate site wasn\'t triggered');
        } catch (DmlException e) {
            System.assertEquals(true, e.getMessage().contains(IMP_SubProjectSite_Handler.ERR_MESSAGE_DUPLICATE_SITE));
        }

        // -------------------------------------------
        // SCENARIO: UPDATE

        subProjectSite.CMF_Name__c = cmfInfo2.Id;
        update subProjectSite;

        // confirm that the essence of 'updating' got triggered:
        //   - old spere representing old cmf -- deleted
        //   - new spere representing new cmf -- inserted

        relatedEntitiesList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Id = :relatedEntitiesList.get(0).Id];
        System.assertEquals(0, relatedEntitiesList.size());

        relatedEntitiesList = [SELECT Entity_Number__c, SubProject__c, Project__c, Entity_Type__c FROM SubProject_External_Related_Entity__c];

        System.assertEquals(1, relatedEntitiesList.size());

        // subProject site's cmf name should be equal to related entity's entity number
        System.assertEquals(CMF_NAME_2, relatedEntitiesList.get(0).Entity_Number__c);

        // subProject site's subProject Id should be equal to related entity's subProject Id
        System.assertEquals(subProject.Id, relatedEntitiesList.get(0).SubProject__c);

        // subProject site's project Id should be equal to related entity's project Id
        System.assertEquals(project.Id, relatedEntitiesList.get(0).Project__c);

        // related entity's entity type should be equal to 'CMF'
        System.assertEquals('CMF', relatedEntitiesList.get(0).Entity_Type__c);

        // -------------------------------------------
        // SCENARIO: DELETE

        delete subProjectSite;

        // related entity should be deleted once linked subproject side is deleted
        System.assertEquals(0, [SELECT COUNT() FROM SubProject_External_Related_Entity__c]);

        // -------------------------------------------

        Test.stopTest();
    }
}