/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Test class for the IMP_MaintainObjectFields_Handler
History
12/29/14     Samuel Oberes      Created
01/05/15     Samuel Oberes      Renamed class and method to align to handler names
                                Added creation and population of IMP_ProjectLinksUrls__c custom setting
01/06/15     Samuel Oberes      Added logic to check if impact numbers are inadvertently getting added in the cmf numbers field of the project
01/13/15     Samuel Oberes      Updated test class to handle a lot of new logic in the handler
01/15/15     Kimiko Roberto     Added scenario for stamping business units if business unit changed checkbox is false
01/16/15     Samuel Oberes      Added updateFields_Test method
08/03/15     Samuel Oberes      Added creation of IMP_EntityTypeHelper__c in static initializer block
11/19/15     Samuel Oberes      Refactored for changed query in IMP_SubProjectExternalRelatedEntity that retrieves the
                                entitiesofParentProjectList to include full set of ids that were not just inserted, updated,
                                but now also those deleted….previously, we hadn’t add those which were deleted to the set,
                                and, it caused processing to exclude required records that led to the CMF_Numbers__c fields
                                on both Project__c and SubProject__c to have their concatenated cmf values ‘blanked out’
                                whenever a single site was deleted, but others still remained.  Also refactored to use @testSetup
------------------------------------------------------------*/
@isTest
private class IMP_MaintainObjectFields_Test {

    private static final String ENTITY_TYPE_IMPACT     = 'Impact Project';
    private static final String ENTITY_TYPE_CMF        = 'CMF';
    private static final String ENTITY_NAME_IMPACT_1   = 'IMPACT_1';
    private static final String ENTITY_NAME_IMPACT_2   = 'IMPACT_2';
    private static final String ENTITY_NAME_CMF_1      = 'CMF_1';
    private static final String ENTITY_NAME_CMF_2      = 'CMF_2';
    private static final String CMF_INFO_1             = 'CMFINF_1';
    private static final String CMF_INFO_2             = 'CMFINF_2';
    private static final String CMF_INFO_3             = 'CMFINF_3';
    private static final String CMF_INFO_4             = 'CMFINF_4';
    private static final String FIELD_NAME_CMF_NUMBERS = 'CMF_Numbers__c';
    private static final String FIELD_NAME_IMP_NUMBERS = 'Impact_Project_Numbers__c';
    private static final String ACCOUNT_NAME_1         = 'CHILD ACCOUNT';
    private static final String ACCOUNT_NAME_2         = 'FIRST PARENT';
    private static final String ACCOUNT_NAME_3         = 'SECOND PARENT (GRAND PARENT)';
    private static final String ACCOUNT_NAME_4         = 'THIRD PARENT (GREAT GRAND PARENT)';
    private static final String SUBPROJECT_NAME        = 'SP1';
    private static final String PROJECT_NAME           = 'P1';

    private static Account account1
    { 
        get
        {
            if (account1 == null)
            {
                account1 = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME_1];
            }
            return account1;
        } 
    }

    private static CMF_Info__c cmfInfo1 
    { 
        get
        {
            if (cmfInfo1 == null)
            {
                cmfInfo1 = [SELECT Id, Ship_CMF__c FROM CMF_Info__c WHERE Ship_CMF__c = :CMF_INFO_1];
            }
            return cmfInfo1;
        } 
    }

    private static CMF_Info__c cmfInfo2
    { 
        get
        {
            if (cmfInfo2 == null)
            {
                cmfInfo2 = [SELECT Id FROM CMF_Info__c WHERE Ship_CMF__c = :CMF_INFO_2];
            }
            return cmfInfo2;
        } 
    }

    private static CMF_Info__c cmfInfo3
    { 
        get
        {
            if (cmfInfo3 == null)
            {
                cmfInfo3 = [SELECT Id FROM CMF_Info__c WHERE Ship_CMF__c = :CMF_INFO_3];
            }
            return cmfInfo3;
        } 
    }

    private static CMF_Info__c cmfInfo4
    { 
        get
        {
            if (cmfInfo4 == null)
            {
                cmfInfo4 = [SELECT Id FROM CMF_Info__c WHERE Ship_CMF__c = :CMF_INFO_4];
            }
            return cmfInfo4;
        } 
    }

    private static Project__c project 
    { 
        get
        {
            if (project == null)
            {
                project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
            }
            return project;
        }
    }

    private static SubProject__c subProject1 
    { 
        get
        {
            if (subProject1 == null)
            {
                subProject1 = [SELECT Id FROM SubProject__c WHERE SubProject_Name__c = :SUBPROJECT_NAME];
            }
            return subProject1;
        }
    }

    @testSetup
    private static void setupRecurringTestData()
    {
        List<IMP_ProjectLinksUrls__c> entityTypesCustomSettingList = new List<IMP_ProjectLinksUrls__c>();

        IMP_ProjectLinksUrls__c entityTypesCustomSetting = new IMP_ProjectLinksUrls__c();
        entityTypesCustomSetting.Name = ENTITY_TYPE_CMF;
        entityTypesCustomSetting.HasFieldonProject__c    = true; 
        entityTypesCustomSetting.ProjectFieldName__c     = FIELD_NAME_CMF_NUMBERS;
        entityTypesCustomSetting.HasFieldonSubproject__c = true; 
        entityTypesCustomSetting.SubProjectFieldName__c  = FIELD_NAME_CMF_NUMBERS;
        entityTypesCustomSettingList.add(entityTypesCustomSetting);

        entityTypesCustomSetting = new IMP_ProjectLinksUrls__c();
        entityTypesCustomSetting.Name = ENTITY_TYPE_IMPACT;
        entityTypesCustomSetting.HasFieldonSubproject__c = true; 
        entityTypesCustomSetting.SubProjectFieldName__c  = FIELD_NAME_IMP_NUMBERS;
        entityTypesCustomSettingList.add(entityTypesCustomSetting);
        
        insert entityTypesCustomSettingList;


        // populate custom setting IMP_EntityTypeHelper__c. This is needed in the creation of a SPERE.
        IMP_EntityTypeHelper__c eh1 = new IMP_EntityTypeHelper__c(Name = 'CMF', Entity_Field_Name__c = 'CMF_Numbers__c');
        IMP_EntityTypeHelper__c eh2 = new IMP_EntityTypeHelper__c(Name = 'RMS Request', Entity_Field_Name__c = 'RMS_Request_Ids__c');
        insert new List<IMP_EntityTypeHelper__c>{ eh1, eh2 };

        Site_Type__c siteType = IMP_TestFactory_Helper.buildSiteType();
        siteType.Group_Flag__c = true;
        insert siteType;

        Account account4 = IMP_TestFactory_Helper.buildAccount();
        account4.Name = ACCOUNT_NAME_4;
        account4.Site_Type__c = siteType.Id;
        insert account4;

        Account account3 = IMP_TestFactory_Helper.buildAccount();
        account3.Name = ACCOUNT_NAME_3;
        account3.Site_Type__c = siteType.Id;
        account3.ParentId = account4.Id;
        insert account3;

        Account account2 = IMP_TestFactory_Helper.buildAccount();
        account2.Name = ACCOUNT_NAME_2;
        account2.Site_Type__c = siteType.Id;
        account2.ParentId = account3.Id;
        insert account2;

        account1 = IMP_TestFactory_Helper.buildAccount();
        account1.Name = ACCOUNT_NAME_1;
        account1.Site_Type__c = siteType.Id;
        account1.ParentId = account2.Id;
        insert account1;

        List<CMF_Info__c> cmfInfoList = new List<CMF_Info__c>();

        cmfInfo1 = IMP_TestFactory_Helper.buildCMFInfo(account1.Id);
        cmfInfo1.Main_CMF__c = CMF_INFO_1;
        cmfInfo1.Ship_CMF__c = CMF_INFO_1;
        cmfInfo1.Ship_CMF_Business_Unit__c = 'West';
        cmfInfoList.add(cmfInfo1);

        cmfInfo2 = IMP_TestFactory_Helper.buildCMFInfo(account2.Id);
        cmfInfo2.Main_CMF__c = CMF_INFO_2;
        cmfInfo2.Ship_CMF__c = CMF_INFO_2;
        cmfInfoList.add(cmfInfo2);

        cmfInfo3 = IMP_TestFactory_Helper.buildCMFInfo(account3.Id);
        cmfInfo3.Main_CMF__c = CMF_INFO_3;
        cmfInfo3.Ship_CMF__c = CMF_INFO_3;
        cmfInfoList.add(cmfInfo3);

        cmfInfo4 = IMP_TestFactory_Helper.buildCMFInfo(account4.Id);
        cmfInfo4.Main_CMF__c = CMF_INFO_4;
        cmfInfo4.Ship_CMF__c = CMF_INFO_4;
        cmfInfoList.add(cmfInfo4);
        
        insert cmfInfoList;

        Project__c p = IMP_TestFactory_Helper.buildProject(0);
        p.Name = PROJECT_NAME;
        p.Business_Unit_Changed__c = false;
        insert p;

        SubProject__c sp = IMP_TestFactory_Helper.buildSubProject(p.Id);
        sp.SubProject_Name__c = SUBPROJECT_NAME;
        sp.Business_Unit_Changed__c = false;
        insert sp;

        List<SubProject_External_Related_Entity__c> impactProjectsList = new List<SubProject_External_Related_Entity__c>();

        SubProject_External_Related_Entity__c spere_impact1 = new SubProject_External_Related_Entity__c();
        spere_impact1.SubProject__c = subProject1.Id;
        spere_impact1.Entity_Type__c = ENTITY_TYPE_IMPACT;
        spere_impact1.Entity_Number__c = ENTITY_NAME_IMPACT_1;
        impactProjectsList.add(spere_impact1);

        SubProject_External_Related_Entity__c spere_impact2 = new SubProject_External_Related_Entity__c();
        spere_impact2.SubProject__c = subProject1.Id;
        spere_impact2.Entity_Type__c = ENTITY_TYPE_IMPACT;
        spere_impact2.Entity_Number__c = ENTITY_NAME_IMPACT_2;
        impactProjectsList.add(spere_impact2);

        insert impactProjectsList;


        List<SubProjectSite__c> sitesList = new List<SubProjectSite__c>();

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProject1.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        sitesList.add(site1);
        
        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProject1.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        sitesList.add(site2);

        insert sitesList;
        
    }

    private static testmethod void confirmInitialValuesExpectations_Test() {
        
        Test.startTest();

        // =============================================================================================
        // INITIALIZATION

        // =============================================================================================
        // TESTING PROPER

        // confirm that initially, we have 2 speres of type IMPACT
        List<SubProject_External_Related_Entity__c> impactProjectsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c 
                                                                            FROM SubProject_External_Related_Entity__c 
                                                                           WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(2, impactProjectsList.size());

        // confirm that initially, we have 2 sites
        List<SubProjectSite__c> sitesList = [SELECT Id
                                               FROM SubProjectSite__c];
        System.assertEquals(2, sitesList.size());

        // confirm that initially, we have 2 speres of type CMF
        List<SubProject_External_Related_Entity__c> cmfsList = [SELECT Id, Entity_Number__c 
                                                                  FROM SubProject_External_Related_Entity__c 
                                                                 WHERE Entity_Type__c = :ENTITY_TYPE_CMF];
        System.assertEquals(2, cmfsList.size());

        // 1) confirm that initially, SubProject__c.CMF_Numbers__c have 2 comma-separated CMFS
        // 2) confirm that initially, SubProject__c.Impact_Project_Numbers__c have 2 comma-separated IMPACTS
        SubProject__c sp = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :impactProjectsList.get(0).SubProject__c];
        System.assertNotEquals(null, sp.CMF_Numbers__c);
        System.assertNotEquals(null, sp.Impact_Project_Numbers__c);
        System.assertEquals(true, sp.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, sp.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));
        System.assertEquals(true, sp.Impact_Project_Numbers__c.contains(impactProjectsList.get(0).Entity_Number__c));
        System.assertEquals(true, sp.Impact_Project_Numbers__c.contains(impactProjectsList.get(1).Entity_Number__c));

        // confirm that initially, Project__c.CMF_Numbers__c have 2 comma-separated CMFS
        Project__c p = [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :impactProjectsList.get(0).Project__c];
        System.assertNotEquals(null, p.CMF_Numbers__c);
        System.assertEquals(true, p.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, p.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));
        
        // -------------------------------------------

        Test.stopTest();
    }

    private static testmethod void deleteCmfsRetainImpact_Test() {
        Test.startTest();

        // =============================================================================================
        // INITIALIZATION

        // -------------------------------------------
        // SCENARIO: delete all cmfs
        // EXPECT:   all impacts must remain

        List<SubProjectSite__c> sitesList = [SELECT Id FROM SubProjectSite__c];
        System.assertEquals(2, sitesList.size());

        delete sitesList;

        // confirm that deleting all sites will also delete its corresponding CMFs only
        List<SubProject_External_Related_Entity__c> cmfsList = [SELECT Id 
                                                                  FROM SubProject_External_Related_Entity__c 
                                                                 WHERE Entity_Type__c = :ENTITY_TYPE_CMF];
        System.assertEquals(0, cmfsList.size());

        List<SubProject_External_Related_Entity__c> impactProjectsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c 
                                                                            FROM SubProject_External_Related_Entity__c 
                                                                           WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(2, impactProjectsList.size());

        SubProject__c sp = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :impactProjectsList.get(0).SubProject__c];
        System.assertEquals(null, sp.CMF_Numbers__c);
        System.assertNotEquals(null, sp.Impact_Project_Numbers__c);
        System.assertEquals(true, sp.Impact_Project_Numbers__c.contains(impactProjectsList.get(0).Entity_Number__c));
        System.assertEquals(true, sp.Impact_Project_Numbers__c.contains(impactProjectsList.get(1).Entity_Number__c));

        Project__c p = [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :impactProjectsList.get(0).Project__c];
        System.assertEquals(null, p.CMF_Numbers__c);
        
        // -------------------------------------------

        Test.stopTest();
    }

    private static testmethod void addCmfsRetainImpact_Test() {

        Test.startTest();
        
        // -------------------------------------------
        // SCENARIO: add 2 new cmfs
        // EXPECT:   2 new cmfs get created
        //           existing impacts must remain as-is

        List<SubProjectSite__c> sitesList = new List<SubProjectSite__c>();

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProject1.Id;
        site1.CMF_Name__c = cmfInfo3.Id;
        sitesList.add(site1);
        
        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProject1.Id;
        site2.CMF_Name__c = cmfInfo4.Id;
        sitesList.add(site2);

        insert sitesList;

        List<SubProject_External_Related_Entity__c> cmfsList = [SELECT Id, Entity_Number__c 
                                                                  FROM SubProject_External_Related_Entity__c 
                                                                 WHERE Entity_Type__c = :ENTITY_TYPE_CMF 
                                                              ORDER BY Entity_Number__c];
        System.assertEquals(4, cmfsList.size());

        List<SubProject_External_Related_Entity__c> impactProjectsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c 
                                                                            FROM SubProject_External_Related_Entity__c 
                                                                           WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(2, impactProjectsList.size());

        SubProject__c sp = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :impactProjectsList.get(0).SubProject__c];
        System.assertNotEquals(null, sp.CMF_Numbers__c);
        System.assertNotEquals(null, sp.Impact_Project_Numbers__c);
        System.assertEquals(true, sp.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, sp.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));
        System.assertEquals(true, sp.CMF_Numbers__c.contains(cmfsList.get(2).Entity_Number__c));
        System.assertEquals(true, sp.CMF_Numbers__c.contains(cmfsList.get(3).Entity_Number__c));
        System.assertEquals(true, sp.Impact_Project_Numbers__c.contains(impactProjectsList.get(0).Entity_Number__c));
        System.assertEquals(true, sp.Impact_Project_Numbers__c.contains(impactProjectsList.get(1).Entity_Number__c));

        Project__c p = [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :impactProjectsList.get(0).Project__c];
        System.assertNotEquals(null, p.CMF_Numbers__c);
        System.assertEquals(true, p.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, p.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));
        System.assertEquals(true, p.CMF_Numbers__c.contains(cmfsList.get(2).Entity_Number__c));
        System.assertEquals(true, p.CMF_Numbers__c.contains(cmfsList.get(3).Entity_Number__c));
        
        // -------------------------------------------

        Test.stopTest();
    }
    
    private static testmethod void siteDeletionCascadingEffect_Test() {

        Test.startTest();

        // -------------------------------------------
        // SCENARIO: add 2 new sites, and delete only one of the 2 sites
        // EXPECT:   all of the existing cmfs of the remaining site must not get deleted/altered
        //           (Test for fix to PROD issue raised last 2015-11-19)

        // confirm that initially, we have 2 sites
        List<SubProjectSite__c> sitesList = [SELECT Id
                                               FROM SubProjectSite__c];
        System.assertEquals(2, sitesList.size());

        // confirm that initially, we have 2 speres of type CMF
        List<SubProject_External_Related_Entity__c> cmfsList = [SELECT Id, Entity_Number__c 
                                                                  FROM SubProject_External_Related_Entity__c 
                                                                 WHERE Entity_Type__c = :ENTITY_TYPE_CMF
                                                              ORDER BY Entity_Number__c];
        System.assertEquals(2, cmfsList.size());

        // confirm that initially, we have 2 speres of type IMPACT
        List<SubProject_External_Related_Entity__c> impactProjectsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c 
                                                                            FROM SubProject_External_Related_Entity__c 
                                                                           WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(2, impactProjectsList.size());

        // delete 1 site. its CMFs must be removed from the Project__c.CMF_Numbers__c and SubProject__c.CMF_Numbers__c field
        // remaining site's CMFs must remain unaltered in Project__c.CMF_Numbers__c and SubProject__c.CMF_Numbers__c field

        delete [SELECT Id FROM SubProjectSite__c WHERE CMF_Name__c = :cmfInfo1.Id]; //site1

        SubProject__c sp = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :impactProjectsList.get(0).SubProject__c];
        System.assertNotEquals(null, sp.CMF_Numbers__c);
        System.assertNotEquals(null, sp.Impact_Project_Numbers__c);
        System.assertEquals(1, sp.CMF_Numbers__c.split(',').size());
        System.assertEquals(false, sp.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, sp.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));
        System.assertEquals(true, sp.Impact_Project_Numbers__c.contains(impactProjectsList.get(0).Entity_Number__c));
        System.assertEquals(true, sp.Impact_Project_Numbers__c.contains(impactProjectsList.get(1).Entity_Number__c));

        Project__c p = [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :impactProjectsList.get(0).Project__c];
        System.assertNotEquals(null, p.CMF_Numbers__c);
        System.assertEquals(1, p.CMF_Numbers__c.split(',').size());
        System.assertEquals(false, p.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, p.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));

        // -------------------------------------------

        Test.stopTest();
    }

    private static testmethod void impactsDeletion_Test() {

        Test.startTest();

        // -------------------------------------------
        // SCENARIO: delete all impacts
        // EXPECT:   all cmfs must remian

        // confirm that initially, we have 2 sites
        List<SubProjectSite__c> sitesList = [SELECT Id
                                               FROM SubProjectSite__c];
        System.assertEquals(2, sitesList.size());

        // confirm that initially, we have 2 speres of type CMF
        List<SubProject_External_Related_Entity__c> cmfsList = [SELECT Id, Entity_Number__c 
                                                                  FROM SubProject_External_Related_Entity__c 
                                                                 WHERE Entity_Type__c = :ENTITY_TYPE_CMF
                                                              ORDER BY Entity_Number__c];
        System.assertEquals(2, cmfsList.size());

        // confirm that initially, we have 2 speres of type IMPACT
        List<SubProject_External_Related_Entity__c> impactProjectsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c 
                                                                            FROM SubProject_External_Related_Entity__c 
                                                                           WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(2, impactProjectsList.size());

        // delete all IMPACTS
        delete impactProjectsList;

        // after the deletion of the IMPACTS, all CMFS must remain as-is
        cmfsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_CMF];
        System.assertEquals(2, cmfsList.size());

        // all IMPACTS should now be deleted
        impactProjectsList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(0, impactProjectsList.size());

        SubProject__c sp = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :cmfsList.get(0).SubProject__c];
        System.assertEquals(null, sp.Impact_Project_Numbers__c);
        System.assertNotEquals(null, sp.CMF_Numbers__c);
        System.assertEquals(true, sp.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, sp.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));
        System.assertEquals(2, sp.CMF_Numbers__c.split(',').size());

        // -------------------------------------------

        Test.stopTest();

    }

    private static testmethod void allSperesDeletion_Test() {

        Test.startTest();

        // -------------------------------------------
        // SCENARIO: delete all cmfs AND impacts
        // EXPECT:   no cmf and impact should persist

        // confirm that initially, we have 2 sites
        List<SubProjectSite__c> sitesList = [SELECT Id
                                               FROM SubProjectSite__c];
        System.assertEquals(2, sitesList.size());

        // confirm that initially, we have 2 speres of type CMF
        List<SubProject_External_Related_Entity__c> cmfsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c 
                                                                  FROM SubProject_External_Related_Entity__c 
                                                                 WHERE Entity_Type__c = :ENTITY_TYPE_CMF
                                                              ORDER BY Entity_Number__c];
        System.assertEquals(2, cmfsList.size());

        // confirm that initially, we have 2 speres of type IMPACT
        List<SubProject_External_Related_Entity__c> impactProjectsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c 
                                                                            FROM SubProject_External_Related_Entity__c 
                                                                           WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(2, impactProjectsList.size());

        Id tempSubProjectId = cmfsList.get(0).SubProject__c;
        Id tempProjectId = cmfsList.get(0).Project__c;

        // delete all CMFS
        delete sitesList;

        // delete all IMPACTS
        delete impactProjectsList;

        // expect all CMFs to be deleted
        cmfsList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_CMF];
        System.assertEquals(0, cmfsList.size());

        // expect all IMPACTS to be deleted
        impactProjectsList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(0, impactProjectsList.size());

        // expect SubProject__c.CMF_Numbers__c and SubProject__c.Impact_Project_Numbers__c to get cleared out
        SubProject__c sp = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :tempSubProjectId];
        System.assertEquals(null, sp.CMF_Numbers__c);
        System.assertEquals(null, sp.Impact_Project_Numbers__c);

        // expect Project__c.CMF_Numbers__c to get cleared out
        Project__c p = [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :tempProjectId];
        System.assertEquals(null, p.CMF_Numbers__c);

        // -------------------------------------------

        Test.stopTest();
    }

    private static testmethod void updateFields_CustomSettingsTest() {
        
        

        // =============================================================================================
        // IMPACT PROJECT

        // clear all sites and CMFs
        delete [SELECT Id FROM SubProjectSite__c];

        // clear all IMPACTS
        delete [SELECT Id FROM SubProject_External_Related_Entity__c];

        // clear all the settings
        delete [SELECT Id FROM IMP_ProjectLinksUrls__c];


        Test.startTest();

        // -------------------------------------------
        // SCENARIO: HasFieldonSubproject__c == false
        // EXPECT:   Subproject's Impact_Project_Numbers__c will be blank

        IMP_ProjectLinksUrls__c entityTypesCustomSetting = new IMP_ProjectLinksUrls__c();
        entityTypesCustomSetting.Name = ENTITY_TYPE_IMPACT;
        entityTypesCustomSetting.HasFieldonSubproject__c = false; 
        entityTypesCustomSetting.SubProjectFieldName__c  = FIELD_NAME_IMP_NUMBERS;
        insert entityTypesCustomSetting;

        System.assertEquals(1, [SELECT COUNT() FROM IMP_ProjectLinksUrls__c WHERE Name = :ENTITY_TYPE_IMPACT]);

        SubProject_External_Related_Entity__c impact1 = new SubProject_External_Related_Entity__c();
        impact1.SubProject__c = subProject1.Id;
        impact1.Entity_Type__c = ENTITY_TYPE_IMPACT;
        impact1.Entity_Number__c = ENTITY_NAME_IMPACT_1;
        insert impact1;

        System.assertEquals(null, [SELECT Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :subProject1.Id].Impact_Project_Numbers__c);

        // -------------------------------------------
        // SCENARIO: HasFieldonSubproject__c == true
        // EXPECT:   Subproject's Impact_Project_Numbers__c == previous and current external entity's Entity_Number__c
        
        entityTypesCustomSetting.HasFieldonSubproject__c = true;
        update entityTypesCustomSetting;

        SubProject_External_Related_Entity__c impact2 = new SubProject_External_Related_Entity__c();
        impact2.SubProject__c = subProject1.Id;
        impact2.Entity_Type__c = ENTITY_TYPE_IMPACT;
        impact2.Entity_Number__c = ENTITY_NAME_IMPACT_2;
        insert impact2;

        System.assertEquals(impact1.Entity_Number__c + ', ' + impact2.Entity_Number__c, [SELECT Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :subProject1.Id].Impact_Project_Numbers__c);

        // =============================================================================================
        // CMF

        // -------------------------------------------
        // SCENARIO: HasFieldonSubproject__c == false
        //           HasFieldonProject__c    == false
        // EXPECT:   Subproject's CMF_Numbers__c will be blank
        //           Project's CMF_Numbers__c will be blank

        entityTypesCustomSetting = new IMP_ProjectLinksUrls__c();
        entityTypesCustomSetting.Name = ENTITY_TYPE_CMF;
        entityTypesCustomSetting.HasFieldonProject__c    = false; 
        entityTypesCustomSetting.ProjectFieldName__c     = FIELD_NAME_CMF_NUMBERS;
        entityTypesCustomSetting.HasFieldonSubproject__c = false; 
        entityTypesCustomSetting.SubProjectFieldName__c  = FIELD_NAME_CMF_NUMBERS;
        insert entityTypesCustomSetting;

        System.assertEquals(1, [SELECT COUNT() FROM IMP_ProjectLinksUrls__c WHERE Name = :ENTITY_TYPE_CMF]);

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProject1.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        insert site1;

        System.assertEquals(null, [SELECT CMF_Numbers__c FROM SubProject__c WHERE Id = :subProject1.Id].CMF_Numbers__c);
        System.assertEquals(null, [SELECT CMF_Numbers__c FROM Project__c].get(0).CMF_Numbers__c);

        // -------------------------------------------
        // SCENARIO: HasFieldonSubproject__c == true
        //           HasFieldonProject__c    == false
        // EXPECT:   Subproject's CMF_Numbers__c == previous and current site 's Ship_CMF__c
        //           Project's CMF_Numbers__c will still be blank
        
        entityTypesCustomSetting.HasFieldonSubproject__c = true;
        update entityTypesCustomSetting;

        SubProjectSite__c site2 = new SubProjectSite__c();
        site2.SubProject__c = subProject1.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        insert site2;

        String site1NewShipCmf = [SELECT Ship_CMF__c FROM SubProjectSite__c WHERE Id = :site1.Id].Ship_CMF__c;
        String site2NewShipCmf = [SELECT Ship_CMF__c FROM SubProjectSite__c WHERE Id = :site2.Id].Ship_CMF__c;

        System.assertEquals(site1NewShipCmf + ', ' + site2NewShipCmf, [SELECT CMF_Numbers__c FROM SubProject__c WHERE Id = :subProject1.Id].CMF_Numbers__c);
        System.assertEquals(null, [SELECT CMF_Numbers__c FROM Project__c].get(0).CMF_Numbers__c);

        // -------------------------------------------
        // SCENARIO: HasFieldonProject__c     == true
        // EXPECT:   Project's CMF_Numbers__c == previous and current site 's Ship_CMF__c
        
        entityTypesCustomSetting.HasFieldonProject__c = true;
        update entityTypesCustomSetting;

        SubProjectSite__c site3 = new SubProjectSite__c();
        site3.SubProject__c = subProject1.Id;
        site3.CMF_Name__c = cmfInfo3.Id;
        insert site3;

        String site3NewShipCmf = [SELECT Ship_CMF__c FROM SubProjectSite__c WHERE Id = :site3.Id].Ship_CMF__c;

        System.assertEquals(site1NewShipCmf + ',' + site2NewShipCmf + ',' + site3NewShipCmf, [SELECT CMF_Numbers__c FROM Project__c].get(0).CMF_Numbers__c);

        // =============================================================================================

        Test.stopTest();
    }

    private static testmethod void getIdToEntityMap_Test() {

        Test.startTest();

        // =============================================================================================
        // INITIALIZATION

        Map<String, Set<String>> temporaryHolderOfEntitiesMap;
        Map<Id, Map<String, Set<String>>> idToEntityMap;
        Set<String> entityValueNames;

        SubProject_External_Related_Entity__c cmf1 = [SELECT Id, 
                                                             Entity_Number__c, 
                                                             Entity_Type__c, 
                                                             SubProject__c, 
                                                             Project__c 
                                                        FROM SubProject_External_Related_Entity__c 
                                                       WHERE SubProject__c = :subProject1.Id 
                                                         AND Entity_Number__c = :cmfInfo1.Ship_CMF__c];

        // -------------------------------------------
        // SCENARIO: Use subproject ID (set true for last parameter of method getIdToEntityMap)
        // EXPECT:   key of idToEntityMap == Subproject's ID
        //           mappings are correct

        temporaryHolderOfEntitiesMap = new Map<String, Set<String>>();

        idToEntityMap = IMP_MaintainObjectFields_Handler.getIdToEntityMap(temporaryHolderOfEntitiesMap, cmf1, null, 
                                                                          true);

        System.assertEquals(1, idToEntityMap.keySet().size());
        System.assertEquals(subProject1.Id, new List<Id>(idToEntityMap.keySet())[0]);
        System.assertEquals(1, idToEntityMap.values().size());

        Map<String, Set<String>> entityToValuesMap = idToEntityMap.get(subProject1.Id);
        for (String entity : entityToValuesMap.keySet()) {
            System.assertEquals(cmf1.Entity_Type__c, entity);
        }

        entityValueNames = entityToValuesMap.get(cmf1.Entity_Type__c);
        System.assertEquals(1, entityValueNames.size());
        System.assertEquals(true, entityValueNames.contains(cmf1.Entity_Number__c));

        // -------------------------------------------
        // SCENARIO: Use project ID (set false for last parameter of method getIdToEntityMap)
        // EXPECT:   key of idToEntityMap == Project's ID

        temporaryHolderOfEntitiesMap = new Map<String, Set<String>>();

        idToEntityMap = IMP_MaintainObjectFields_Handler.getIdToEntityMap(temporaryHolderOfEntitiesMap, cmf1, null, 
                                                                          false);

        System.assertEquals([SELECT Id FROM Project__c].get(0).Id, new List<Id>(idToEntityMap.keySet())[0]);

        // -------------------------------------------
        // SCENARIO: Use subproject ID (set true for last parameter of method getIdToEntityMap) and pass a removedEntitiesIdSet to simulate the AFTER-DELETE trigger context scenario
        // EXPECT:   size of set of entity values should be 0

        temporaryHolderOfEntitiesMap = new Map<String, Set<String>>();

        Set<Id> removedEntitiesIdSet = new Set<ID>{ cmf1.Id };

        idToEntityMap = IMP_MaintainObjectFields_Handler.getIdToEntityMap(temporaryHolderOfEntitiesMap, cmf1, removedEntitiesIdSet, 
                                                                          true);

        System.assertEquals(1, idToEntityMap.keySet().size());
        System.assertEquals(subProject1.Id, new List<Id>(idToEntityMap.keySet())[0]);
        System.assertEquals(1, idToEntityMap.values().size());

        entityValueNames = idToEntityMap.get(subProject1.Id).get(cmf1.Entity_Type__c);
        System.assertEquals(0, entityValueNames.size());

        // =============================================================================================

        Test.stopTest();
    }

    private static testmethod void isEntityDeleted_Test() {

        SubProject_External_Related_Entity__c entity = [SELECT Id 
                                                          FROM SubProject_External_Related_Entity__c 
                                                         WHERE SubProject__c = :subProject1.Id 
                                                           AND Entity_Type__c = :ENTITY_TYPE_IMPACT 
                                                           AND Entity_Number__c = :ENTITY_NAME_IMPACT_1];
        
        Set<Id> removedEntitiesIdSet = new Set<ID>{ entity.Id };

        System.assertEquals(true, IMP_MaintainObjectFields_Handler.isEntityDeleted(removedEntitiesIdSet, entity.Id));

        removedEntitiesIdSet = new Set<ID>();
        
        System.assertEquals(0, removedEntitiesIdSet.size());
        System.assertEquals(false, IMP_MaintainObjectFields_Handler.isEntityDeleted(removedEntitiesIdSet, entity.Id));

        removedEntitiesIdSet = null;

        System.assertEquals(null, removedEntitiesIdSet);
        System.assertEquals(false, IMP_MaintainObjectFields_Handler.isEntityDeleted(removedEntitiesIdSet, entity.Id));
    }
    
    private static testMethod void stampBusinessUnitToProjectAndSubProject(){

        //subProject1 = [SELECT Id FROM SubProject__c].get(0);

        //IMP_ProjectLinksUrls__c entityTypesCustomSetting = new IMP_ProjectLinksUrls__c();
        //entityTypesCustomSetting.Name = ENTITY_TYPE_CMF;
        //entityTypesCustomSetting.HasFieldonProject__c    = true; 
        //entityTypesCustomSetting.ProjectFieldName__c     = FIELD_NAME_CMF_NUMBERS;
        //entityTypesCustomSetting.HasFieldonSubproject__c = true; 
        //entityTypesCustomSetting.SubProjectFieldName__c  = FIELD_NAME_CMF_NUMBERS;
        //insert entityTypesCustomSetting;
        
        // clear everything to start from scratch.
        delete [SELECT Id FROM SubProjectSite__c];
        delete [SELECT Id FROM SubProject_External_Related_Entity__c];

        SubProjectSite__c testSite = new SubProjectSite__c(CMF_Name__c = cmfInfo1.Id, SubProject__c = subProject1.Id);
        insert testSite;

        SubProject_External_Related_Entity__c testSpere = [SELECT id, Entity_Type__c, Business_Unit__c FROM SubProject_External_Related_Entity__c WHERE SubProject__c = :subProject1.Id];
        SubProject__c testSubProject = [SELECT Id, SubProject_Region__c FROM SubProject__c WHERE Id = : subProject1.Id];
        Project__c testProject = [SELECT Id, Project_Region__c FROM Project__c].get(0);
        system.Debug('***business unit: '+ testSpere.Business_Unit__c + '***'+ testSubProject.SubProject_Region__c);
        system.Debug('***testSpere: '+ testSpere);
        system.Assert(testSpere.Business_Unit__c == testSubProject.SubProject_Region__c);
        system.Assert(testSpere.Business_Unit__c == testProject.Project_Region__c);
    }
    
}