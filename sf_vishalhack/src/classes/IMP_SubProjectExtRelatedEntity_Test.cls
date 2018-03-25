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
08/04/15     Samuel Oberes      Added creation of IMP_EntityTypeHelper__c in static initializer block
08/27/15     Samuel Oberes      Added reparentingSiteWithCmfAndRms_s01_Test to reparentingSiteWithCmfAndRms_s11_Test and reparentingSiteWithContractAndImpact_Test
12/06/16     Venkata Shrivol	commented the project object reference RQ-08305
------------------------------------------------------------*/
@isTest
private class IMP_SubProjectExtRelatedEntity_Test {

    private static final String CMF_NAME_1 = 'CMF_1';
    private static final String CMF_NAME_2 = 'CMF_2';

    private static final Account account1;
    private static final Account account2;
    //private static final Project__c project;
    private static final SubProject__c subProject;
    
    private static CMF_Info__c cmfInfo1;
    private static CMF_Info__c cmfInfo2;

    private static User userPM;

    private static Integer ctr = 0;

    static {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'ADPDS - Implementation - PM' or Name = 'ADPDS - Implementation PM' Limit 1]; 

        userPM = new User(Alias = 'standt', 
                          Email = 'standarduser@cdk.com', 
                          EmailEncodingKey = 'UTF-8', 
                          FirstName = 'First Name', 
                          LastName = 'Testing', 
                          LanguageLocaleKey = 'en_US', 
                          LocaleSidKey = 'en_US', 
                          ProfileId = profile.Id, 
                          TimeZoneSidKey = 'America/Los_Angeles', 
                          UserName = 'standarduser@cdk.com', 
                          ADID__c = DS_TestObjects.TrueRandomUpToAMillion());

        System.runAs(userPM) {

            // populate custom setting IMP_EntityTypeHelper__c. This is needed in the creation of a SPERE.
            IMP_EntityTypeHelper__c eh1 = new IMP_EntityTypeHelper__c(Name = 'CMF', Entity_Field_Name__c = 'CMF_Numbers__c');
            IMP_EntityTypeHelper__c eh2 = new IMP_EntityTypeHelper__c(Name = 'RMS Request', Entity_Field_Name__c = 'RMS_Request_Ids__c');
            insert new List<IMP_EntityTypeHelper__c>{ eh1, eh2 };
        
            account1 = IMP_TestFactory_Helper.buildAccount();
            insert account1;

            account2 = IMP_TestFactory_Helper.buildAccount();
            insert account2;

            /*project = IMP_TestFactory_Helper.buildProject(0);
            insert project;*/

            subProject = IMP_TestFactory_Helper.buildSubProject();
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
        relatedEntitiesList = [SELECT Id, Entity_Number__c, SubProject__c, Entity_Type__c FROM SubProject_External_Related_Entity__c];
        System.assertEquals(1, relatedEntitiesList.size());

        // subProject site's cmf name should be equal to related entity's entity number
        System.assertEquals(CMF_NAME_1, relatedEntitiesList.get(0).Entity_Number__c);

        // subProject site's subProject Id should be equal to related entity's subProject Id
        System.assertEquals(subProject.Id, relatedEntitiesList.get(0).SubProject__c);

        // subProject site's project Id should be equal to related entity's project Id
        //System.assertEquals(project.Id, relatedEntitiesList.get(0).Project__c);

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

        relatedEntitiesList = [SELECT Entity_Number__c, SubProject__c, Entity_Type__c FROM SubProject_External_Related_Entity__c];

        System.assertEquals(1, relatedEntitiesList.size());

        // subProject site's cmf name should be equal to related entity's entity number
        System.assertEquals(CMF_NAME_2, relatedEntitiesList.get(0).Entity_Number__c);

        // subProject site's subProject Id should be equal to related entity's subProject Id
        System.assertEquals(subProject.Id, relatedEntitiesList.get(0).SubProject__c);

        // subProject site's project Id should be equal to related entity's project Id
        //System.assertEquals(project.Id, relatedEntitiesList.get(0).Project__c);

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



    private static testmethod void reparentingSiteWithCmfAndRms_s01_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;

        Test.startTest();

        /*
            SCENARIO 1:
                Context: 
                    > source      = 1 site (1 cmf)
                    > destination = 0 site
                Action:
                    > transfer 1 site
                Expect: 
                    > source      = 0 site
                    > destination = 1 site (1 cmf)
        */

        SubProjectSite__c site = new SubProjectSite__c();
        site.SubProject__c = subProjectSource.Id;
        site.CMF_Name__c = cmfInfo1.Id;
        insert site;

        site = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo1.Id].get(0);

        String singleCmfNumber = IMP_Project_Utility.parseDelimitedString(site.CMF_Numbers__c, ',', true).get(0);

        // establishing context truths in source and dest
        //System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());
        //System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectSource.Id].size());

        //System.assertEquals(0, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());
        //System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectDestination.Id].size());

        Map<Id, SubProjectSite__c> spSite = new Map<Id, SubProjectSite__c>([SELECT Id, SubProject__c
                                                                              FROM SubProjectSite__c 
                                                                             WHERE SubProject__c IN :new List<Id>{ subProjectSource.Id, subProjectDestination.Id }]);
        
        System.assertEquals(1, spSite.size());
        System.assertEquals(true, spSite.keySet().contains(site.Id) && spSite.get(site.Id).SubProject__c == subProjectSource.Id);
        System.assertEquals(false, spSite.keySet().contains(site.Id) && spSite.get(site.Id).SubProject__c == subProjectDestination.Id);

        List<SubProject_External_Related_Entity__c> spereList = [SELECT Id, Entity_Number__c, SubProject__c
                                                                   FROM SubProject_External_Related_Entity__c 
                                                                  WHERE Entity_Type__c = 'CMF' 
                                                                    AND Entity_Number__c = :singleCmfNumber 
                                                                    AND SubProject__c IN :new List<Id>{ subProjectSource.Id, subProjectDestination.Id }];

        System.assertEquals(1, spereList.size());
        System.assertEquals(true, spereList.get(0).Entity_Number__c == singleCmfNumber && spereList.get(0).SubProject__c == subProjectSource.Id);
        System.assertEquals(false, spereList.get(0).Entity_Number__c == singleCmfNumber && spereList.get(0).SubProject__c == subProjectDestination.Id);

        // do reparenting
        site.SubProject__c = subProjectDestination.Id;
        update site;

        // assert truths in source and dest after reparenting
        //System.assertEquals(0, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());
        //System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectSource.Id].size());

        //System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());
        //System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectDestination.Id].size());

        spSite = new Map<Id, SubProjectSite__c>([SELECT Id, SubProject__c
                                                   FROM SubProjectSite__c 
                                                  WHERE SubProject__c IN :new List<Id>{ subProjectSource.Id, subProjectDestination.Id }]);
        
        System.assertEquals(1, spSite.size());
        System.assertEquals(false, spSite.keySet().contains(site.Id) && spSite.get(site.Id).SubProject__c == subProjectSource.Id);
        System.assertEquals(true, spSite.keySet().contains(site.Id) && spSite.get(site.Id).SubProject__c == subProjectDestination.Id);

        spereList = [SELECT Id, Entity_Number__c, SubProject__c
                       FROM SubProject_External_Related_Entity__c 
                      WHERE Entity_Type__c = 'CMF' 
                        AND Entity_Number__c = :singleCmfNumber 
                        AND SubProject__c IN :new List<Id>{ subProjectSource.Id, subProjectDestination.Id }];

        System.assertEquals(1, spereList.size());
        System.assertEquals(false, spereList.get(0).Entity_Number__c == singleCmfNumber && spereList.get(0).SubProject__c == subProjectSource.Id);
        System.assertEquals(true, spereList.get(0).Entity_Number__c == singleCmfNumber && spereList.get(0).SubProject__c == subProjectDestination.Id);

        Test.stopTest();
    }

    private static testmethod void reparentingSiteWithCmfAndRms_s02_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;
        cmfInfo2.Ship_CMF__c = CMF_NAME_2;
        insert cmfInfo2;

        Test.startTest();

        /*
            SCENARIO 2:
                Context: 
                    > source      = 2 site (1 cmf each)
                    > destination = 0 site
                Action:
                    > transfer 1st site
                Expect: 
                    > source      = 1 site (1 cmf)
                    > destination = 1 site (1 cmf)
        */

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProjectSource.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        //insert site1;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProjectSource.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        //insert site2;

        insert new List<SubProjectSite__c>{ site1, site2 };

        site1 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo1.Id].get(0);
        site2 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo2.Id].get(0);

        String site1CmfNumber = IMP_Project_Utility.parseDelimitedString(site1.CMF_Numbers__c, ',', true).get(0);
        String site2CmfNumber = IMP_Project_Utility.parseDelimitedString(site2.CMF_Numbers__c, ',', true).get(0);

        // establishing context truths in source and dest
        //System.assertEquals(2, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());
        //System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectSource.Id].size());

        //System.assertEquals(0, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());
        //System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectDestination.Id].size());

        Map<Id, SubProjectSite__c> spSite = new Map<Id, SubProjectSite__c>([SELECT Id , SubProject__c
                                                                              FROM SubProjectSite__c 
                                                                             WHERE SubProject__c IN :new List<Id>{ subProjectSource.Id, subProjectDestination.Id }]);
        
        System.assertEquals(2, spSite.size());
        System.assertEquals(true, spSite.keySet().contains(site1.Id) && spSite.get(site1.Id).SubProject__c == subProjectSource.Id);
        System.assertEquals(true, spSite.keySet().contains(site2.Id) && spSite.get(site2.Id).SubProject__c == subProjectSource.Id);
        System.assertEquals(false, spSite.keySet().contains(site1.Id) && spSite.get(site1.Id).SubProject__c == subProjectDestination.Id);
        System.assertEquals(false, spSite.keySet().contains(site2.Id) && spSite.get(site2.Id).SubProject__c == subProjectDestination.Id);

        List<SubProject_External_Related_Entity__c> spereList = [SELECT Id, Entity_Number__c, SubProject__c
                                                                   FROM SubProject_External_Related_Entity__c 
                                                                  WHERE SubProject__c IN :new List<Id>{ subProjectSource.Id, subProjectDestination.Id }
                                                               ORDER BY Entity_Number__c];

        System.assertEquals(2, spereList.size());
        System.assertEquals(true, spereList.get(0).Entity_Number__c == site1CmfNumber && spereList.get(0).SubProject__c == subProjectSource.Id);
        System.assertEquals(true, spereList.get(1).Entity_Number__c == site2CmfNumber && spereList.get(1).SubProject__c == subProjectSource.Id);
        System.assertEquals(false, spereList.get(0).Entity_Number__c == site1CmfNumber && spereList.get(0).SubProject__c == subProjectDestination.Id);
        System.assertEquals(false, spereList.get(1).Entity_Number__c == site2CmfNumber && spereList.get(1).SubProject__c == subProjectDestination.Id);

        // do reparenting
        site1.SubProject__c = subProjectDestination.Id;
        update site1;

        // assert truths in source and dest after reparenting
        //System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());
        //System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectSource.Id].size());

        //System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());
        //System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectDestination.Id].size());

        spSite = new Map<Id, SubProjectSite__c>([SELECT Id, SubProject__c
                                                   FROM SubProjectSite__c 
                                                  WHERE SubProject__c IN :new List<Id>{ subProjectSource.Id, subProjectDestination.Id }]);
        
        System.assertEquals(2, spSite.size());
        System.assertEquals(false, spSite.keySet().contains(site1.Id) && spSite.get(site1.Id).SubProject__c == subProjectSource.Id);
        System.assertEquals(true, spSite.keySet().contains(site2.Id) && spSite.get(site2.Id).SubProject__c == subProjectSource.Id);
        System.assertEquals(true, spSite.keySet().contains(site1.Id) && spSite.get(site1.Id).SubProject__c == subProjectDestination.Id);
        System.assertEquals(false, spSite.keySet().contains(site2.Id) && spSite.get(site2.Id).SubProject__c == subProjectDestination.Id);

       spereList = [SELECT Id, Entity_Number__c, SubProject__c
                      FROM SubProject_External_Related_Entity__c 
                     WHERE SubProject__c IN :new List<Id>{ subProjectSource.Id, subProjectDestination.Id }
                  ORDER BY Entity_Number__c];

        System.assertEquals(2, spereList.size());
        System.assertEquals(false, spereList.get(0).Entity_Number__c == site1CmfNumber && spereList.get(0).SubProject__c == subProjectSource.Id);
        System.assertEquals(true, spereList.get(1).Entity_Number__c == site2CmfNumber && spereList.get(1).SubProject__c == subProjectSource.Id);
        System.assertEquals(true, spereList.get(0).Entity_Number__c == site1CmfNumber && spereList.get(0).SubProject__c == subProjectDestination.Id);
        System.assertEquals(false, spereList.get(1).Entity_Number__c == site2CmfNumber && spereList.get(1).SubProject__c == subProjectDestination.Id);

        Test.stopTest();
    }

    private static testmethod void reparentingSiteWithCmfAndRms_s03_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;
        cmfInfo2.Ship_CMF__c = CMF_NAME_2;
        insert cmfInfo2;

        Account account3 = IMP_TestFactory_Helper.buildAccount();
        insert account3;

        CMF_Info__c cmfInfo3 = new CMF_Info__c();
        cmfInfo3.Account__c = account3.Id;
        cmfInfo3.Name = 'CMF_3';
        cmfInfo3.Status__c = 'A';
        cmfInfo3.Ship_CMF__c = 'CMF_3';
        insert cmfInfo3;

        Test.startTest();

        /*
            SCENARIO 3:
                Context: 
                    > source      = 2 site (1 cmf each)
                    > destination = 1 site (1 cmf)
                Action:
                    > transfer 1st site
                Expect: 
                    > source      = 1 site (1 cmf)
                    > destination = 2 site (1 cmf each)
        */

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProjectSource.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        //insert site1;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProjectSource.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        //insert site2;

        SubProjectSite__c site3 = new SubProjectSite__c();
        site3.SubProject__c = subProjectDestination.Id;
        site3.CMF_Name__c = cmfInfo3.Id;
        //insert site3;

        insert new List<SubProjectSite__c>{ site1, site2, site3 };

        site1 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo1.Id].get(0);
        site2 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo2.Id].get(0);
        site3 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id AND CMF_Name__c = :cmfInfo3.Id].get(0);

        String site1cmfNumber = IMP_Project_Utility.parseDelimitedString(site1.CMF_Numbers__c, ',', true).get(0);
        String site2cmfNumber = IMP_Project_Utility.parseDelimitedString(site2.CMF_Numbers__c, ',', true).get(0);
        String site3cmfNumber = IMP_Project_Utility.parseDelimitedString(site3.CMF_Numbers__c, ',', true).get(0);

        // establishing context truths in source and dest
        System.assertEquals(2, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        Set<String> sourceSubProjectEntitiesSet = new Set<String>();
        for (SubProject_External_Related_Entity__c ent : [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectSource.Id])
        {
            sourceSubProjectEntitiesSet.add(ent.Entity_Number__c);
        }
        System.assertEquals(2, sourceSubProjectEntitiesSet.size());
        System.assertEquals(true, sourceSubProjectEntitiesSet.contains(site1cmfNumber));
        System.assertEquals(true, sourceSubProjectEntitiesSet.contains(site2cmfNumber));
        System.assertEquals(false, sourceSubProjectEntitiesSet.contains(site3cmfNumber));

        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        Set<String> destinationSubProjectEntitiesSet = new Set<String>();
        for (SubProject_External_Related_Entity__c ent : [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectDestination.Id])
        {
            destinationSubProjectEntitiesSet.add(ent.Entity_Number__c);
        }
        System.assertEquals(1, destinationSubProjectEntitiesSet.size());
        System.assertEquals(false, destinationSubProjectEntitiesSet.contains(site1cmfNumber));
        System.assertEquals(false, destinationSubProjectEntitiesSet.contains(site2cmfNumber));
        System.assertEquals(true, destinationSubProjectEntitiesSet.contains(site3cmfNumber));

        // do reparenting
        site1.SubProject__c = subProjectDestination.Id;
        update site1;

        // assert truths in source and dest after reparenting
        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        sourceSubProjectEntitiesSet = new Set<String>();
        for (SubProject_External_Related_Entity__c ent : [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectSource.Id])
        {
            sourceSubProjectEntitiesSet.add(ent.Entity_Number__c);
        }
        System.assertEquals(1, sourceSubProjectEntitiesSet.size());
        System.assertEquals(false, sourceSubProjectEntitiesSet.contains(site1cmfNumber)); // since site1 got reparented, site1 should not appear in the source subproject anymore
        System.assertEquals(true, sourceSubProjectEntitiesSet.contains(site2cmfNumber));
        System.assertEquals(false, sourceSubProjectEntitiesSet.contains(site3cmfNumber));

        System.assertEquals(2, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        destinationSubProjectEntitiesSet = new Set<String>();
        for (SubProject_External_Related_Entity__c ent : [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectDestination.Id])
        {
            destinationSubProjectEntitiesSet.add(ent.Entity_Number__c);
        }
        System.assertEquals(2, destinationSubProjectEntitiesSet.size());
        System.assertEquals(true, destinationSubProjectEntitiesSet.contains(site1cmfNumber));  // since site1 got reparented, site1 should now appear in the destination subproject
        System.assertEquals(false, destinationSubProjectEntitiesSet.contains(site2cmfNumber));
        System.assertEquals(true, destinationSubProjectEntitiesSet.contains(site3cmfNumber));

        Test.stopTest();
    }

    private static testmethod void reparentingSiteWithCmfAndRms_s04_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;
        cmfInfo2.Ship_CMF__c = CMF_NAME_2;
        insert cmfInfo2;

        Test.startTest();

        /*
            SCENARIO 4:
                Context: 
                    > source      = 1 site (1 cmf)
                    > destination = 1 site (1 cmf)
                Action:
                    > transfer 1 site
                Expect: 
                    > source      = 0 site (0 cmf)
                    > destination = 2 site (1 cmf each)
        */

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProjectSource.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        //insert site1;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProjectDestination.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        //insert site2;

        insert new List<SubProjectSite__c>{ site1, site2 };

        site1 = [SELECT Id, SubProject__c, CMF_Name__c, CMF_Numbers__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo1.Id].get(0);

        String singleCmfNumber = IMP_Project_Utility.parseDelimitedString(site1.CMF_Numbers__c, ',', true).get(0);

        // establishing context truths in source and dest
        Map<Id, SubProjectSite__c> sourceSiteMap = new Map<Id, SubProjectSite__c>([SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id]);
        System.assertEquals(true, sourceSiteMap.containsKey(site1.Id));
        System.assertEquals(1, sourceSiteMap.size());
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectSource.Id].size());

        Map<Id, SubProjectSite__c> destinationSiteMap = new Map<Id, SubProjectSite__c>([SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id]);
        System.assertEquals(false, destinationSiteMap.containsKey(site1.Id));
        System.assertEquals(1, destinationSiteMap.size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectDestination.Id].size());

        // do reparenting
        site1.SubProject__c = subProjectDestination.Id;
        update site1;

        // assert truths in source and dest after reparenting
        sourceSiteMap = new Map<Id, SubProjectSite__c>([SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id]);
        System.assertEquals(false, sourceSiteMap.containsKey(site1.Id));
        System.assertEquals(0, sourceSiteMap.size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectSource.Id].size());

        destinationSiteMap = new Map<Id, SubProjectSite__c>([SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id]);
        System.assertEquals(true, destinationSiteMap.containsKey(site1.Id));
        System.assertEquals(2, destinationSiteMap.size());
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectDestination.Id].size());

        Test.stopTest();
    }

    private static testmethod void reparentingSiteWithCmfAndRms_s05_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;
        cmfInfo2.Ship_CMF__c = CMF_NAME_2;
        insert cmfInfo2;

        Test.startTest();

        /*
            SCENARIO 5: (NOTE: Thru UI, bulk reparenting [2 sites simultaneous reparenting] might never happen. But thru code/backend, this might happen.)
                Context: 
                    > source      = 2 site (1 cmf each)
                    > destination = 0 site
                Action:
                    > transfer 2 site
                Expect: 
                    > source      = 0 site
                    > destination = 2 site (1 cmf each)
        */

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProjectSource.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        //insert site1;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProjectSource.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        //insert site2;

        insert new List<SubProjectSite__c>{ site1, site2 };

        site1 = [SELECT Id, SubProject__c, CMF_Name__c, CMF_Numbers__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo1.Id].get(0);
        site2 = [SELECT Id, SubProject__c, CMF_Name__c, CMF_Numbers__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo2.Id].get(0);

        String site1CmfNumber = IMP_Project_Utility.parseDelimitedString(site1.CMF_Numbers__c, ',', true).get(0);
        String site2CmfNumber = IMP_Project_Utility.parseDelimitedString(site2.CMF_Numbers__c, ',', true).get(0);

        // establishing context truths in source and dest
        Map<Id, SubProjectSite__c> sourceSiteMap = new Map<Id, SubProjectSite__c>([SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id]);
        System.assertEquals(true, sourceSiteMap.containsKey(site1.Id));
        System.assertEquals(true, sourceSiteMap.containsKey(site2.Id));
        System.assertEquals(2, sourceSiteMap.size());
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :site1CmfNumber AND SubProject__c = :subProjectSource.Id].size());
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :site2CmfNumber AND SubProject__c = :subProjectSource.Id].size());

        Map<Id, SubProjectSite__c> destinationSiteMap = new Map<Id, SubProjectSite__c>([SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id]);
        System.assertEquals(false, destinationSiteMap.containsKey(site1.Id));
        System.assertEquals(false, destinationSiteMap.containsKey(site2.Id));
        System.assertEquals(0, destinationSiteMap.size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :site1CmfNumber AND SubProject__c = :subProjectDestination.Id].size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :site2CmfNumber AND SubProject__c = :subProjectDestination.Id].size());

        // do reparenting
        site1.SubProject__c = subProjectDestination.Id;
        site2.SubProject__c = subProjectDestination.Id;
        update new List<SubProjectSite__c>{ site1, site2 };

        // assert truths in source and dest after reparenting
        sourceSiteMap = new Map<Id, SubProjectSite__c>([SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id]);
        System.assertEquals(false, sourceSiteMap.containsKey(site1.Id));
        System.assertEquals(false, sourceSiteMap.containsKey(site2.Id));
        System.assertEquals(0, sourceSiteMap.size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :site1CmfNumber AND SubProject__c = :subProjectSource.Id].size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :site2CmfNumber AND SubProject__c = :subProjectSource.Id].size());

        destinationSiteMap = new Map<Id, SubProjectSite__c>([SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id]);
        System.assertEquals(true, destinationSiteMap.containsKey(site1.Id));
        System.assertEquals(true, destinationSiteMap.containsKey(site2.Id));
        System.assertEquals(2, destinationSiteMap.size());
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :site1CmfNumber AND SubProject__c = :subProjectDestination.Id].size());
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :site2CmfNumber AND SubProject__c = :subProjectDestination.Id].size());

        Test.stopTest();
    }

    private static testmethod void reparentingSiteWithCmfAndRms_s06_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;

        Test.startTest();

        /*
            SCENARIO 6:
                Context: 
                    > source      = 1 site (1 cmf, 1 REQID)
                    > destination = 0 site
                Action:
                    > transfer 1 site
                Expect: 
                    > source      = 0 site
                    > destination = 1 site (1 cmf, 1 REQID)
        */

        SubProjectSite__c site = new SubProjectSite__c();
        site.SubProject__c = subProjectSource.Id;
        site.CMF_Name__c = cmfInfo1.Id;
        insert site;

        CMFtoSubProjectSite__c cmfToSite = new CMFtoSubProjectSite__c();
        cmfToSite.SubProjectSite__c = site.Id;
        cmfToSite.CMF_Info__c = cmfInfo1.Id;
        cmfToSite.RMS_Request_Id__c = 'RMS_1';
        insert cmfToSite;

        site = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c, RMS_Request_Ids__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo1.Id].get(0);

        String singleCmfNumber = IMP_Project_Utility.parseDelimitedString(site.CMF_Numbers__c, ',', true).get(0);
        String singleRmsReqId = IMP_Project_Utility.parseDelimitedString(site.RMS_Request_Ids__c, ',', true).get(0);

        List<String> allSperes = new List<String>{ singleCmfNumber, singleRmsReqId };

        System.assertEquals(CMF_NAME_1, singleCmfNumber);
        System.assertEquals('RMS_1', singleRmsReqId);

        // establishing context truths in source and dest
        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectSource.Id].size());
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND Entity_Number__c = :singleRmsReqId AND SubProject__c = :subProjectSource.Id].size());
        System.assertEquals(2, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE (Entity_Type__c = 'CMF' OR Entity_Type__c = 'RMS Request') AND Entity_Number__c IN :allSperes AND SubProject__c = :subProjectSource.Id].size());

        System.assertEquals(0, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectDestination.Id].size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND Entity_Number__c = :singleRmsReqId AND SubProject__c = :subProjectDestination.Id].size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE (Entity_Type__c = 'CMF' OR Entity_Type__c = 'RMS Request') AND Entity_Number__c IN :allSperes AND SubProject__c = :subProjectDestination.Id].size());

        // do reparenting
        site.SubProject__c = subProjectDestination.Id;
        update site;

        // assert truths in source and dest after reparenting
        System.assertEquals(0, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectSource.Id].size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND Entity_Number__c = :singleRmsReqId AND SubProject__c = :subProjectSource.Id].size());
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE (Entity_Type__c = 'CMF' OR Entity_Type__c = 'RMS Request') AND Entity_Number__c IN :allSperes AND SubProject__c = :subProjectSource.Id].size());

        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND Entity_Number__c = :singleCmfNumber AND SubProject__c = :subProjectDestination.Id].size());
        System.assertEquals(1, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND Entity_Number__c = :singleRmsReqId AND SubProject__c = :subProjectDestination.Id].size());
        System.assertEquals(2, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE (Entity_Type__c = 'CMF' OR Entity_Type__c = 'RMS Request') AND Entity_Number__c IN :allSperes AND SubProject__c = :subProjectDestination.Id].size());

        Test.stopTest();

    }

    private static testmethod void reparentingSiteWithCmfAndRms_s07_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;
        cmfInfo2.Ship_CMF__c = CMF_NAME_2;
        insert cmfInfo2;



        Test.startTest();



        /*
            SCENARIO 7:
                Context: 
                    > source      = 2 site (2 cmf, 2 REQID)
                    > destination = 0 site
                Action:
                    > transfer 2 site
                Expect: 
                    > source      = 0 site
                    > destination = 2 site (2 cmf, 2 REQID)
        */

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProjectSource.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        //insert site1;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProjectSource.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        //insert site2;

        insert new List<SubProjectSite__c>{ site1, site2 };

        CMFtoSubProjectSite__c cmfToSite1 = new CMFtoSubProjectSite__c();
        cmfToSite1.SubProjectSite__c = site1.Id;
        cmfToSite1.CMF_Info__c = cmfInfo1.Id;
        cmfToSite1.RMS_Request_Id__c = 'RMS_1';
        //insert cmfToSite1;

        CMFtoSubProjectSite__c cmfToSite2 = new CMFtoSubProjectSite__c();
        cmfToSite2.SubProjectSite__c = site2.Id;
        cmfToSite2.CMF_Info__c = cmfInfo2.Id;
        cmfToSite2.RMS_Request_Id__c = 'RMS_2';
        //insert cmfToSite2;

        insert new List<CMFtoSubProjectSite__c>{ cmfToSite1, cmfToSite2 };



        site1 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c, RMS_Request_Ids__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo1.Id].get(0);
        site2 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c, RMS_Request_Ids__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo2.Id].get(0);

        String site1CmfNumber = IMP_Project_Utility.parseDelimitedString(site1.CMF_Numbers__c, ',', true).get(0);
        String site2CmfNumber = IMP_Project_Utility.parseDelimitedString(site2.CMF_Numbers__c, ',', true).get(0);
        String site1RmsReqId = IMP_Project_Utility.parseDelimitedString(site1.RMS_Request_Ids__c, ',', true).get(0);
        String site2RmsReqId = IMP_Project_Utility.parseDelimitedString(site2.RMS_Request_Ids__c, ',', true).get(0);

        List<String> allSperes = new List<String>{ site1CmfNumber, site2CmfNumber, site1RmsReqId, site2RmsReqId };

        System.assertEquals(CMF_NAME_1, site1CmfNumber);
        System.assertEquals(CMF_NAME_2, site2CmfNumber);
        System.assertEquals('RMS_1', site1RmsReqId);
        System.assertEquals('RMS_2', site2RmsReqId);



        // establishing context truths in source and dest
        // --- SOURCE
        System.assertEquals(2, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        List<SubProject_External_Related_Entity__c> sourceCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, sourceCmfNumbersList.size());
        System.assertEquals(site1CmfNumber, sourceCmfNumbersList.get(0).Entity_Number__c);
        System.assertEquals(site2CmfNumber, sourceCmfNumbersList.get(1).Entity_Number__c);

        List<SubProject_External_Related_Entity__c> sourceRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, sourceRmsReqIdsList.size());
        System.assertEquals(site1RmsReqId, sourceRmsReqIdsList.get(0).Entity_Number__c);
        System.assertEquals(site2RmsReqId, sourceRmsReqIdsList.get(1).Entity_Number__c);
        
        //--- DEST
        System.assertEquals(0, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        List<SubProject_External_Related_Entity__c> destinationCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(0, destinationCmfNumbersList.size());

        List<SubProject_External_Related_Entity__c> destinationRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(0, destinationRmsReqIdsList.size());
        
        


        // do reparenting
        site1.SubProject__c = subProjectDestination.Id;
        site2.SubProject__c = subProjectDestination.Id;
        update new List<SubProjectSite__c>{ site1, site2 };



        // assert truths in source and dest after reparenting
        // --- SOURCE
        System.assertEquals(0, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        sourceCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(0, sourceCmfNumbersList.size());

        sourceRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(0, sourceRmsReqIdsList.size());
        
        
        //--- DEST
        System.assertEquals(2, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        destinationCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, destinationCmfNumbersList.size());
        System.assertEquals(site1CmfNumber, destinationCmfNumbersList.get(0).Entity_Number__c);
        System.assertEquals(site2CmfNumber, destinationCmfNumbersList.get(1).Entity_Number__c);

        destinationRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, destinationRmsReqIdsList.size());
        System.assertEquals(site1RmsReqId, destinationRmsReqIdsList.get(0).Entity_Number__c);
        System.assertEquals(site2RmsReqId, destinationRmsReqIdsList.get(1).Entity_Number__c);
        
        


        Test.stopTest();
    }

    private static testmethod void reparentingSiteWithCmfAndRms_s08_Test()
    {

        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;
        cmfInfo2.Ship_CMF__c = CMF_NAME_2;
        insert cmfInfo2;



        Test.startTest();



        /*
            SCENARIO 8:
                Context: 
                    > source      = 2 site (2 cmf, 3 REQID [1 on 1st, 2 on 2nd])
                    > destination = 0 site
                Action:
                    > transfer 2nd site (1 cmf, 2 REQID)
                Expect: 
                    > source      = 1 site (1 cmf, 1 REQID)
                    > destination = 1 site (1 cmf, 2 REQID)
        */

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProjectSource.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        //insert site1;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProjectSource.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        //insert site2;

        insert new List<SubProjectSite__c>{ site1, site2 };

        CMFtoSubProjectSite__c cmfToSite1 = new CMFtoSubProjectSite__c();
        cmfToSite1.SubProjectSite__c = site1.Id;
        cmfToSite1.CMF_Info__c = cmfInfo1.Id;
        cmfToSite1.RMS_Request_Id__c = 'RMS_1';
        //insert cmfToSite1;

        CMFtoSubProjectSite__c cmfToSite2 = new CMFtoSubProjectSite__c();
        cmfToSite2.SubProjectSite__c = site2.Id;
        cmfToSite2.CMF_Info__c = cmfInfo2.Id;
        cmfToSite2.RMS_Request_Id__c = 'RMS_2_1';
        //insert cmfToSite2;

        CMFtoSubProjectSite__c cmfToSite3 = new CMFtoSubProjectSite__c();
        cmfToSite3.SubProjectSite__c = site2.Id;
        cmfToSite3.CMF_Info__c = cmfInfo2.Id;
        cmfToSite3.RMS_Request_Id__c = 'RMS_2_2';
        //insert cmfToSite3;

        insert new List<CMFtoSubProjectSite__c>{ cmfToSite1, cmfToSite2, cmfToSite3 };



        site1 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c, RMS_Request_Ids__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo1.Id].get(0);
        site2 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c, RMS_Request_Ids__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo2.Id].get(0);


        String site1CmfNumber = IMP_Project_Utility.parseDelimitedString(site1.CMF_Numbers__c, ',', true).get(0);
        String site2CmfNumber = IMP_Project_Utility.parseDelimitedString(site2.CMF_Numbers__c, ',', true).get(0);
        String site1RmsReqId  = IMP_Project_Utility.parseDelimitedString(site1.RMS_Request_Ids__c, ',', true).get(0);
        String site2RmsReqId1 = IMP_Project_Utility.parseDelimitedString(site2.RMS_Request_Ids__c, ',', true).get(0);
        String site2RmsReqId2 = IMP_Project_Utility.parseDelimitedString(site2.RMS_Request_Ids__c, ',', true).get(1);

        List<String> allSperes = new List<String>{ site1CmfNumber, site2CmfNumber, site1RmsReqId, site2RmsReqId1, site2RmsReqId2 };

        System.assertEquals(CMF_NAME_1, site1CmfNumber);
        System.assertEquals(CMF_NAME_2, site2CmfNumber);
        System.assertEquals('RMS_1', site1RmsReqId);
        System.assertEquals('RMS_2_1', site2RmsReqId1);
        System.assertEquals('RMS_2_2', site2RmsReqId2);



        // establishing context truths in source and dest
        // --- SOURCE
        System.assertEquals(2, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        List<SubProject_External_Related_Entity__c> sourceCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, sourceCmfNumbersList.size());
        System.assertEquals(site1CmfNumber, sourceCmfNumbersList.get(0).Entity_Number__c);
        System.assertEquals(site2CmfNumber, sourceCmfNumbersList.get(1).Entity_Number__c);

        List<SubProject_External_Related_Entity__c> sourceRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(3, sourceRmsReqIdsList.size());
        System.assertEquals(site1RmsReqId, sourceRmsReqIdsList.get(0).Entity_Number__c);
        System.assertEquals(site2RmsReqId1, sourceRmsReqIdsList.get(1).Entity_Number__c);
        System.assertEquals(site2RmsReqId2, sourceRmsReqIdsList.get(2).Entity_Number__c);
        
        System.assertEquals(5, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE (Entity_Type__c = 'CMF' OR Entity_Type__c = 'RMS Request') AND Entity_Number__c IN :allSperes AND SubProject__c = :subProjectSource.Id].size());
        
        //--- DEST
        System.assertEquals(0, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        List<SubProject_External_Related_Entity__c> destinationCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(0, destinationCmfNumbersList.size());

        List<SubProject_External_Related_Entity__c> destinationRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(0, destinationRmsReqIdsList.size());
        
        System.assertEquals(0, [SELECT Id FROM SubProject_External_Related_Entity__c WHERE (Entity_Type__c = 'CMF' OR Entity_Type__c = 'RMS Request') AND Entity_Number__c IN :allSperes AND SubProject__c = :subProjectDestination.Id].size());



        // do reparenting
        site2.SubProject__c = subProjectDestination.Id;
        update site2;



        // assert truths in source and dest after reparenting
        // --- SOURCE
        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        sourceCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(1, sourceCmfNumbersList.size());
        System.assertEquals(site1CmfNumber, sourceCmfNumbersList.get(0).Entity_Number__c);

        sourceRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(1, sourceRmsReqIdsList.size());
        System.assertEquals(site1RmsReqId, sourceRmsReqIdsList.get(0).Entity_Number__c);
        
        
        //--- DEST
        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        destinationCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(1, destinationCmfNumbersList.size());
        System.assertEquals(site2CmfNumber, destinationCmfNumbersList.get(0).Entity_Number__c);

        destinationRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, destinationRmsReqIdsList.size());
        System.assertEquals(site2RmsReqId1, destinationRmsReqIdsList.get(0).Entity_Number__c);
        System.assertEquals(site2RmsReqId2, destinationRmsReqIdsList.get(1).Entity_Number__c);
        
        


        Test.stopTest();
    }

    private static testmethod void reparentingSiteWithCmfAndRms_s09_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;
        cmfInfo2.Ship_CMF__c = CMF_NAME_2;
        insert cmfInfo2;

        Boolean preserveId = false;
        Boolean isDeepClone = true;
        Boolean preserveReadonlyTimestamps = false;
        Boolean preserveAutonumber = false;

        CMF_Info__c cmfInfo2_dup = cmfInfo1.clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber);
        cmfInfo2_dup.Name = CMF_NAME_2 + '_D';
        cmfInfo2_dup.Ship_CMF__c = cmfInfo2_dup.Name;
        insert cmfInfo2_dup;



        Test.startTest();



        /*
            SCENARIO 9:
                Context: 
                    > source      = 2 site (3 cmf [1 on 1st, 2 on 2nd], 2 REQID)
                    > destination = 0 site
                Action:
                    > transfer 2nd site (2 cmf, 1 REQID)
                Expect: 
                    > source      = 1 site (1 cmf, 1 REQID)
                    > destination = 1 site (2 cmf, 1 REQID)
        */

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProjectSource.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        //insert site1;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProjectSource.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        //insert site2;

        insert new List<SubProjectSite__c>{ site1, site2 };

        // get original value of CMF_Numbers__c, parse, transform returned list to a set, add new shipcmf to that set, transform set to delimited string, stamp the resulting string to site's CMF_Numbers__c field, then update.
        Set<String> cmfNumbersSet = new Set<String>(IMP_Project_Utility.parseDelimitedString([SELECT CMF_Numbers__c FROM SubProjectSite__c WHERE Id = :site2.Id].CMF_Numbers__c, ',', true));
        cmfNumbersSet.add(cmfInfo2_dup.Ship_CMF__c);
        site2.CMF_Numbers__c = String.join(new List<String>(cmfNumbersSet), ',');
        update site2;

        CMFtoSubProjectSite__c cmfToSite1 = new CMFtoSubProjectSite__c();
        cmfToSite1.SubProjectSite__c = site1.Id;
        cmfToSite1.CMF_Info__c = cmfInfo1.Id;
        cmfToSite1.RMS_Request_Id__c = 'RMS_1';
        //insert cmfToSite1;

        CMFtoSubProjectSite__c cmfToSite2 = new CMFtoSubProjectSite__c();
        cmfToSite2.SubProjectSite__c = site2.Id;
        cmfToSite2.CMF_Info__c = cmfInfo2.Id;
        cmfToSite2.RMS_Request_Id__c = 'RMS_2';
        //insert cmfToSite2;

        insert new List<CMFtoSubProjectSite__c>{ cmfToSite1, cmfToSite2 };



        site1 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c, RMS_Request_Ids__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo1.Id].get(0);
        site2 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c, RMS_Request_Ids__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo2.Id].get(0);


        String site1CmfNumber  = IMP_Project_Utility.parseDelimitedString(site1.CMF_Numbers__c, ',', true).get(0);
        String site2CmfNumber1 = IMP_Project_Utility.parseDelimitedString(site2.CMF_Numbers__c, ',', true).get(0);
        String site2CmfNumber2 = IMP_Project_Utility.parseDelimitedString(site2.CMF_Numbers__c, ',', true).get(1);
        String site1RmsReqId   = IMP_Project_Utility.parseDelimitedString(site1.RMS_Request_Ids__c, ',', true).get(0);
        String site2RmsReqId   = IMP_Project_Utility.parseDelimitedString(site2.RMS_Request_Ids__c, ',', true).get(0);

        List<String> allSperes = new List<String>{ site1CmfNumber, site2CmfNumber1, site2CmfNumber2, site1RmsReqId, site2RmsReqId };

        System.assertEquals(CMF_NAME_1, site1CmfNumber);
        System.assertEquals(CMF_NAME_2, site2CmfNumber1);
        System.assertEquals(CMF_NAME_2 + '_D', site2CmfNumber2);
        System.assertEquals('RMS_1', site1RmsReqId);
        System.assertEquals('RMS_2', site2RmsReqId);



        // establishing context truths in source and dest
        // --- SOURCE
        System.assertEquals(2, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        List<SubProject_External_Related_Entity__c> sourceCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(3, sourceCmfNumbersList.size());
        System.assertEquals(site1CmfNumber, sourceCmfNumbersList.get(0).Entity_Number__c);
        System.assertEquals(site2CmfNumber1, sourceCmfNumbersList.get(1).Entity_Number__c);
        System.assertEquals(site2CmfNumber2, sourceCmfNumbersList.get(2).Entity_Number__c);

        List<SubProject_External_Related_Entity__c> sourceRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, sourceRmsReqIdsList.size());
        System.assertEquals(site1RmsReqId, sourceRmsReqIdsList.get(0).Entity_Number__c);
        System.assertEquals(site2RmsReqId, sourceRmsReqIdsList.get(1).Entity_Number__c);
        
        
        //--- DEST
        System.assertEquals(0, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        List<SubProject_External_Related_Entity__c> destinationCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(0, destinationCmfNumbersList.size());

        List<SubProject_External_Related_Entity__c> destinationRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(0, destinationRmsReqIdsList.size());
        
        


        // do reparenting
        site2.SubProject__c = subProjectDestination.Id;
        update site2;



        // assert truths in source and dest after reparenting
        // --- SOURCE
        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        sourceCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(1, sourceCmfNumbersList.size());
        System.assertEquals(site1CmfNumber, sourceCmfNumbersList.get(0).Entity_Number__c);

        sourceRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(1, sourceRmsReqIdsList.size());
        System.assertEquals(site1RmsReqId, sourceRmsReqIdsList.get(0).Entity_Number__c);
        
        
        //--- DEST
        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        destinationCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, destinationCmfNumbersList.size());
        System.assertEquals(site2CmfNumber1, destinationCmfNumbersList.get(0).Entity_Number__c);
        System.assertEquals(site2CmfNumber2, destinationCmfNumbersList.get(1).Entity_Number__c);

        destinationRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(1, destinationRmsReqIdsList.size());
        System.assertEquals(site2RmsReqId, destinationRmsReqIdsList.get(0).Entity_Number__c);
        
        


        Test.stopTest();
    }

    private static testmethod void reparentingSiteWithCmfAndRms_s10_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;
        cmfInfo2.Ship_CMF__c = CMF_NAME_2;
        insert cmfInfo2;

        Boolean preserveId = false;
        Boolean isDeepClone = true;
        Boolean preserveReadonlyTimestamps = false;
        Boolean preserveAutonumber = false;

        CMF_Info__c cmfInfo2_dup = cmfInfo2.clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber);
        cmfInfo2_dup.Name = CMF_NAME_2 + '_D';
        cmfInfo2_dup.Ship_CMF__c = cmfInfo2_dup.Name;
        insert cmfInfo2_dup;

        Account account3 = IMP_TestFactory_Helper.buildAccount();
        insert account3;
        
        CMF_Info__c cmfInfo3 = new CMF_Info__c();
        cmfInfo3.Account__c = account3.Id;
        cmfInfo3.Name = 'CMF_3';
        cmfInfo3.Status__c = 'A';
        cmfInfo3.Ship_CMF__c = 'CMF_3';
        insert cmfInfo3;

        CMF_Info__c cmfInfo3_dup = cmfInfo3.clone(preserveId, isDeepClone, preserveReadonlyTimestamps, preserveAutonumber);
        cmfInfo3_dup.Name ='CMF_3_D';
        cmfInfo3_dup.Ship_CMF__c = cmfInfo3_dup.Name;
        insert cmfInfo3_dup;



        Test.startTest();



        /*
            SCENARIO 10:
                Context: 
                    > source      = 2 site (3 cmf [1 on 1st, 2 on 2nd], 2 REQID)
                    > destination = 1 site (2 cmf, 2 REQID)
                Action:
                    > transfer 1st site (1 cmf, 1 REQID)
                Expect: 
                    > source      = 1 site (2 cmf, 1 REQID)
                    > destination = 2 site (3 cmf, 3 REQID)
        */

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProjectSource.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        //insert site1;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProjectSource.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        //insert site2;

        SubProjectSite__c site3 = new SubProjectSite__c();
        site3.SubProject__c = subProjectDestination.Id;
        site3.CMF_Name__c = cmfInfo3.Id;
        //insert site3;

        insert new List<SubProjectSite__c>{ site1, site2, site3 };

        // get original value of CMF_Numbers__c, parse, transform returned list to a set, add new shipcmf to that set, transform set to delimited string, stamp the resulting string to site's CMF_Numbers__c field, then update.
        Set<String> cmfNumbersSet = new Set<String>(IMP_Project_Utility.parseDelimitedString([SELECT CMF_Numbers__c FROM SubProjectSite__c WHERE Id = :site2.Id].CMF_Numbers__c, ',', true));
        cmfNumbersSet.add(cmfInfo2_dup.Ship_CMF__c);
        site2.CMF_Numbers__c = String.join(new List<String>(cmfNumbersSet), ',');
        update site2;

        // get original value of CMF_Numbers__c, parse, transform returned list to a set, add new shipcmf to that set, transform set to delimited string, stamp the resulting string to site's CMF_Numbers__c field, then update.
        cmfNumbersSet = new Set<String>(IMP_Project_Utility.parseDelimitedString([SELECT CMF_Numbers__c FROM SubProjectSite__c WHERE Id = :site3.Id].CMF_Numbers__c, ',', true));
        cmfNumbersSet.add(cmfInfo3_dup.Ship_CMF__c);
        site3.CMF_Numbers__c = String.join(new List<String>(cmfNumbersSet), ',');
        update site3;

        CMFtoSubProjectSite__c cmfToSite1 = new CMFtoSubProjectSite__c();
        cmfToSite1.SubProjectSite__c = site1.Id;
        cmfToSite1.CMF_Info__c = cmfInfo1.Id;
        cmfToSite1.RMS_Request_Id__c = 'RMS_1';
        //insert cmfToSite1;

        CMFtoSubProjectSite__c cmfToSite2 = new CMFtoSubProjectSite__c();
        cmfToSite2.SubProjectSite__c = site2.Id;
        cmfToSite2.CMF_Info__c = cmfInfo2.Id;
        cmfToSite2.RMS_Request_Id__c = 'RMS_2';
        //insert cmfToSite2;

        CMFtoSubProjectSite__c cmfToSite3 = new CMFtoSubProjectSite__c();
        cmfToSite3.SubProjectSite__c = site3.Id;
        cmfToSite3.CMF_Info__c = cmfInfo3.Id;
        cmfToSite3.RMS_Request_Id__c = 'RMS_3_1';
        //insert cmfToSite3;

        CMFtoSubProjectSite__c cmfToSite4 = new CMFtoSubProjectSite__c();
        cmfToSite4.SubProjectSite__c = site3.Id;
        cmfToSite4.CMF_Info__c = cmfInfo3.Id;
        cmfToSite4.RMS_Request_Id__c = 'RMS_3_2';
        //insert cmfToSite4;

        insert new List<CMFtoSubProjectSite__c>{ cmfToSite1, cmfToSite2, cmfToSite3, cmfToSite4 };



        site1 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c, RMS_Request_Ids__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo1.Id].get(0);
        site2 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c, RMS_Request_Ids__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id AND CMF_Name__c = :cmfInfo2.Id].get(0);
        site3 = [SELECT SubProject__c, CMF_Name__c, CMF_Numbers__c, RMS_Request_Ids__c FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id AND CMF_Name__c = :cmfInfo3.Id].get(0);


        String site1CmfNumber  = IMP_Project_Utility.parseDelimitedString(site1.CMF_Numbers__c, ',', true).get(0);
        String site2CmfNumber1 = IMP_Project_Utility.parseDelimitedString(site2.CMF_Numbers__c, ',', true).get(0);
        String site2CmfNumber2 = IMP_Project_Utility.parseDelimitedString(site2.CMF_Numbers__c, ',', true).get(1);
        String site1RmsReqId   = IMP_Project_Utility.parseDelimitedString(site1.RMS_Request_Ids__c, ',', true).get(0);
        String site2RmsReqId   = IMP_Project_Utility.parseDelimitedString(site2.RMS_Request_Ids__c, ',', true).get(0);
        String site3CmfNumber1 = IMP_Project_Utility.parseDelimitedString(site3.CMF_Numbers__c, ',', true).get(0);
        String site3CmfNumber2 = IMP_Project_Utility.parseDelimitedString(site3.CMF_Numbers__c, ',', true).get(1);
        String site3RmsReqId1  = IMP_Project_Utility.parseDelimitedString(site3.RMS_Request_Ids__c, ',', true).get(0);
        String site3RmsReqId2  = IMP_Project_Utility.parseDelimitedString(site3.RMS_Request_Ids__c, ',', true).get(1);

        List<String> allSperes = new List<String>{ site1CmfNumber, site2CmfNumber1, site2CmfNumber2, site1RmsReqId, site2RmsReqId, site3CmfNumber1, site3CmfNumber2, site3RmsReqId1, site3RmsReqId2 };

        System.assertEquals(CMF_NAME_1, site1CmfNumber);
        System.assertEquals(CMF_NAME_2, site2CmfNumber1);
        System.assertEquals(CMF_NAME_2 + '_D', site2CmfNumber2);
        System.assertEquals('RMS_1', site1RmsReqId);
        System.assertEquals('RMS_2', site2RmsReqId);
        System.assertEquals('CMF_3', site3CmfNumber1);
        System.assertEquals('CMF_3_D', site3CmfNumber2);
        System.assertEquals('RMS_3_1', site3RmsReqId1);
        System.assertEquals('RMS_3_2', site3RmsReqId2);



        // establishing context truths in source and dest
        // --- SOURCE
        System.assertEquals(2, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        List<SubProject_External_Related_Entity__c> sourceCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(3, sourceCmfNumbersList.size());
        System.assertEquals(site1CmfNumber, sourceCmfNumbersList.get(0).Entity_Number__c);
        System.assertEquals(site2CmfNumber1, sourceCmfNumbersList.get(1).Entity_Number__c);
        System.assertEquals(site2CmfNumber2, sourceCmfNumbersList.get(2).Entity_Number__c);

        List<SubProject_External_Related_Entity__c> sourceRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, sourceRmsReqIdsList.size());
        System.assertEquals(site1RmsReqId, sourceRmsReqIdsList.get(0).Entity_Number__c);
        System.assertEquals(site2RmsReqId, sourceRmsReqIdsList.get(1).Entity_Number__c);
        
        
        //--- DEST
        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        List<SubProject_External_Related_Entity__c> destinationCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, destinationCmfNumbersList.size());
        System.assertEquals(site3CmfNumber1, destinationCmfNumbersList.get(0).Entity_Number__c);
        System.assertEquals(site3CmfNumber2, destinationCmfNumbersList.get(1).Entity_Number__c);

        List<SubProject_External_Related_Entity__c> destinationRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, destinationRmsReqIdsList.size());
        System.assertEquals(site3RmsReqId1, destinationRmsReqIdsList.get(0).Entity_Number__c);
        System.assertEquals(site3RmsReqId2, destinationRmsReqIdsList.get(1).Entity_Number__c);
        
        


        // do reparenting
        site1.SubProject__c = subProjectDestination.Id;
        update site1;



        // assert truths in source and dest after reparenting
        // --- SOURCE
        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        sourceCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(2, sourceCmfNumbersList.size());
        System.assertEquals(site2CmfNumber1, sourceCmfNumbersList.get(0).Entity_Number__c);
        System.assertEquals(site2CmfNumber2, sourceCmfNumbersList.get(1).Entity_Number__c);

        sourceRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectSource.Id ORDER BY Entity_Number__c];
        System.assertEquals(1, sourceRmsReqIdsList.size());
        System.assertEquals(site2RmsReqId, sourceRmsReqIdsList.get(0).Entity_Number__c);
        
        
        //--- DEST
        System.assertEquals(2, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        destinationCmfNumbersList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'CMF' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(3, destinationCmfNumbersList.size());
        System.assertEquals(site1CmfNumber, destinationCmfNumbersList.get(0).Entity_Number__c);
        System.assertEquals(site3CmfNumber1, destinationCmfNumbersList.get(1).Entity_Number__c);
        System.assertEquals(site3CmfNumber2, destinationCmfNumbersList.get(2).Entity_Number__c);

        destinationRmsReqIdsList = [SELECT Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = 'RMS Request' AND SubProject__c = :subProjectDestination.Id ORDER BY Entity_Number__c];
        System.assertEquals(3, destinationRmsReqIdsList.size());
        System.assertEquals(site1RmsReqId, destinationRmsReqIdsList.get(0).Entity_Number__c);
        System.assertEquals(site3RmsReqId1, destinationRmsReqIdsList.get(1).Entity_Number__c);
        System.assertEquals(site3RmsReqId2, destinationRmsReqIdsList.get(2).Entity_Number__c);



        Test.stopTest();
    }

    private static testmethod void reparentingSiteWithCmfAndRms_s11_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;

        Test.startTest();

        /*
            SCENARIO 11:
                Context: 
                    > source      = 1 site (1 cmf named CMF1)
                    > destination = 1 site (1 cmf named CMF1)
                Action:
                    > transfer 1 site (1 cmf named CMF1)
                Expect: 
                    > source      = 1 site (1 cmf named CMF1)
                    > destination = 1 site (1 cmf named CMF1)
                    > NOTE: The SUBPROJECT_SITE_EXISTING error must be triggered since the account of site in the source is the same as the account of site in the destination.
        */

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProjectSource.Id;
        site1.CMF_Name__c = cmfInfo1.Id;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProjectDestination.Id;
        site2.CMF_Name__c = cmfInfo1.Id;

        insert new List<SubProjectSite__c>{ site1, site2 };

        
        // do reparenting
        site1.SubProject__c = subProjectDestination.Id;
        try
        {
            update site1;
            System.assert(false, 'THIS ASSERTION SHOULD NOT BE TRIGGERED. THE ERROR \'IMP_String_Utility.SUBPROJECT_SITE_EXISTING\' IS EXPECTED BECAUSE SITE1 AND SITE2 HAS THE SAME ACCOUNT.');
        }
        catch(Exception e)
        {
            System.assertEquals(true, e.getMessage().contains(IMP_String_Utility.SUBPROJECT_SITE_EXISTING));
        }

        Test.stopTest();
    }

    private static testmethod void reparentingSiteWithContractAndImpact_Test()
    {
        SubProject__c subProjectSource = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectSource;
        SubProject__c subProjectDestination = IMP_TestFactory_Helper.buildSubProject();
        insert subProjectDestination;
        cmfInfo1.Ship_CMF__c = CMF_NAME_1;
        insert cmfInfo1;
        cmfInfo1.Ship_CMF__c = CMF_NAME_2;
        insert cmfInfo2;

        Test.startTest();

        /*
            SCENARIO 1:
                Context: 
                    > source      = 1 site (1 con [CON-A], 1 imp [IMP-A])
                    > destination = 1 site (1 con [CON-B], 1 imp [IMP-B])
                Action:
                    > transfer 1 site
                Expect: 
                    > source      = 0 site (1 con [CON-A], 1 imp [IMP-A])
                    > destination = 2 site (2 con [CON-A | CON-B], 2 imp [IMP-A | IMP-B])
        */

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProjectSource.Id;
        site1.CMF_Name__c = cmfInfo1.Id;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProjectDestination.Id;
        site2.CMF_Name__c = cmfInfo2.Id;

        insert new List<SubProjectSite__c>{ site1, site2 };

        SubProject_External_Related_Entity__c cona = new SubProject_External_Related_Entity__c();
        cona.Entity_Number__c = 'CON-A';
        cona.Entity_Type__c = 'Contract';
        cona.SubProject__c = subProjectSource.Id;

        SubProject_External_Related_Entity__c conb = new SubProject_External_Related_Entity__c();
        conb.Entity_Number__c = 'CON-B';
        conb.Entity_Type__c = 'Contract';
        conb.SubProject__c = subProjectDestination.Id;

        SubProject_External_Related_Entity__c impa = new SubProject_External_Related_Entity__c();
        impa.Entity_Number__c = 'IMP-A';
        impa.Entity_Type__c = 'Impact Project';
        impa.SubProject__c = subProjectSource.Id;

        SubProject_External_Related_Entity__c impb = new SubProject_External_Related_Entity__c();
        impb.Entity_Number__c = 'IMP-B';
        impb.Entity_Type__c = 'Impact Project';
        impb.SubProject__c = subProjectDestination.Id;

        insert new List<SubProject_External_Related_Entity__c>{ cona, conb, impa, impb };

        // establishing context truths in source and dest
        // --- SOURCE
        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        List<SubProject_External_Related_Entity__c> speresList = [SELECT Entity_Number__c 
                                                                    FROM SubProject_External_Related_Entity__c 
                                                                   WHERE (   Entity_Type__c = 'Impact Project' 
                                                                          OR Entity_Type__c = 'Contract') 
                                                                     AND SubProject__c = :subProjectSource.Id 
                                                                ORDER BY Entity_Type__c, Entity_Number__c];
        System.assertEquals(2, speresList.size());
        System.assertEquals('CON-A', speresList.get(0).Entity_Number__c);
        System.assertEquals('IMP-A', speresList.get(1).Entity_Number__c);

        //--- DEST
        System.assertEquals(1, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        speresList = [SELECT Entity_Number__c 
                        FROM SubProject_External_Related_Entity__c 
                       WHERE (   Entity_Type__c = 'Impact Project' 
                              OR Entity_Type__c = 'Contract') 
                         AND SubProject__c = :subProjectDestination.Id 
                    ORDER BY Entity_Type__c, Entity_Number__c];
        System.assertEquals(2, speresList.size());
        System.assertEquals('CON-B', speresList.get(0).Entity_Number__c);
        System.assertEquals('IMP-B', speresList.get(1).Entity_Number__c);



        // do reparenting
        site1.SubProject__c = subProjectDestination.Id;
        update site1;



        // assert truths in source and dest after reparenting
        // --- SOURCE
        System.assertEquals(0, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectSource.Id].size());

        speresList = [SELECT Entity_Number__c 
                        FROM SubProject_External_Related_Entity__c 
                       WHERE (   Entity_Type__c = 'Impact Project' 
                              OR Entity_Type__c = 'Contract') 
                         AND SubProject__c = :subProjectSource.Id 
                    ORDER BY Entity_Type__c, Entity_Number__c];
        System.assertEquals(2, speresList.size());
        System.assertEquals('CON-A', speresList.get(0).Entity_Number__c);
        System.assertEquals('IMP-A', speresList.get(1).Entity_Number__c);

        //--- DEST
        System.assertEquals(2, [SELECT Id FROM SubProjectSite__c WHERE SubProject__c = :subProjectDestination.Id].size());

        speresList = [SELECT Entity_Number__c 
                        FROM SubProject_External_Related_Entity__c 
                       WHERE (   Entity_Type__c = 'Impact Project' 
                              OR Entity_Type__c = 'Contract') 
                         AND SubProject__c = :subProjectDestination.Id 
                    ORDER BY Entity_Type__c, Entity_Number__c];
        System.assertEquals(4, speresList.size());
        System.assertEquals('CON-A', speresList.get(0).Entity_Number__c);
        System.assertEquals('CON-B', speresList.get(1).Entity_Number__c);
        System.assertEquals('IMP-A', speresList.get(2).Entity_Number__c);
        System.assertEquals('IMP-B', speresList.get(3).Entity_Number__c);



        Test.stopTest();
    }
}