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
    private static final Account account1;
    private static final Account account2;
    private static final Account account3;
    private static final Account account4;
    private static final CMF_Info__c cmfInfo1;
    private static final CMF_Info__c cmfInfo2;
    private static final CMF_Info__c cmfInfo3;
    private static final CMF_Info__c cmfInfo4;
    private static final Project__c project;
    private static final SubProject__c subProject1;
    private static IMP_ProjectLinksUrls__c entityTypesCustomSetting;

    static {

        Site_Type__c siteType = IMP_TestFactory_Helper.buildSiteType();
        siteType.Group_Flag__c = true;
        insert siteType;

        account4 = IMP_TestFactory_Helper.buildAccount();
        account4.Name = 'THIRD PARENT (GREAT GRAND PARENT)';
        account4.Site_Type__c = siteType.Id;
        insert account4;

        account3 = IMP_TestFactory_Helper.buildAccount();
        account3.Name = 'SECOND PARENT (GRAND PARENT)';
        account3.Site_Type__c = siteType.Id;
        account3.ParentId = account4.Id;
        insert account3;

        account2 = IMP_TestFactory_Helper.buildAccount();
        account2.Name = 'FIRST PARENT';
        account2.Site_Type__c = siteType.Id;
        account2.ParentId = account3.Id;
        insert account2;

        account1 = IMP_TestFactory_Helper.buildAccount();
        account1.Name = 'CHILD ACCOUNT';
        account1.Site_Type__c = siteType.Id;
        account1.ParentId = account2.Id;
        insert account1;

        cmfInfo1 = IMP_TestFactory_Helper.buildCMFInfo(account1.Id);
        cmfInfo1.Main_CMF__c = CMF_INFO_1;
        cmfInfo1.Ship_CMF__c = CMF_INFO_1;
        cmfInfo1.Ship_CMF_Business_Unit__c = 'West';
        insert cmfInfo1;

        cmfInfo2 = IMP_TestFactory_Helper.buildCMFInfo(account2.Id);
        cmfInfo2.Main_CMF__c = CMF_INFO_2;
        cmfInfo2.Ship_CMF__c = CMF_INFO_2;
        insert cmfInfo2;

        cmfInfo3 = IMP_TestFactory_Helper.buildCMFInfo(account3.Id);
        cmfInfo3.Main_CMF__c = CMF_INFO_3;
        cmfInfo3.Ship_CMF__c = CMF_INFO_3;
        insert cmfInfo3;

        cmfInfo4 = IMP_TestFactory_Helper.buildCMFInfo(account4.Id);
        cmfInfo4.Main_CMF__c = CMF_INFO_4;
        cmfInfo4.Ship_CMF__c = CMF_INFO_4;
        insert cmfInfo4;

        project = IMP_TestFactory_Helper.buildProject(0);
        project.Business_Unit_Changed__c = false;
        insert project;

        subProject1 = IMP_TestFactory_Helper.buildSubProject(project.Id);
        subProject1.Business_Unit_Changed__c = false;
        insert subProject1;

    }

    private static testmethod void updateFields_Test() {
        Test.startTest();
        
        // =============================================================================================
        // INITIALIZATION

        List<SubProject_External_Related_Entity__c> impactProjectsList = new List<SubProject_External_Related_Entity__c>();
        List<SubProject_External_Related_Entity__c> cmfsList = new List<SubProject_External_Related_Entity__c>();
        SubProjectSite__c site1;
        SubProjectSite__c site2;
        List<SubProjectSite__c> sitesList;
        SubProject__c testSubproject;
        Project__c testProject;

        // -------------------------------------------
        // custom settings

        entityTypesCustomSetting = new IMP_ProjectLinksUrls__c();
        entityTypesCustomSetting.Name = ENTITY_TYPE_CMF;
        entityTypesCustomSetting.HasFieldonProject__c    = true; 
        entityTypesCustomSetting.ProjectFieldName__c     = FIELD_NAME_CMF_NUMBERS;
        entityTypesCustomSetting.HasFieldonSubproject__c = true; 
        entityTypesCustomSetting.SubProjectFieldName__c  = FIELD_NAME_CMF_NUMBERS;
        insert entityTypesCustomSetting;

        entityTypesCustomSetting = new IMP_ProjectLinksUrls__c();
        entityTypesCustomSetting.Name = ENTITY_TYPE_IMPACT;
        entityTypesCustomSetting.HasFieldonSubproject__c = true; 
        entityTypesCustomSetting.SubProjectFieldName__c  = FIELD_NAME_IMP_NUMBERS;
        insert entityTypesCustomSetting;

        // -------------------------------------------
        // impact project entities

        SubProject_External_Related_Entity__c impact1 = new SubProject_External_Related_Entity__c();
        impact1.SubProject__c = subProject1.Id;
        impact1.Entity_Type__c = ENTITY_TYPE_IMPACT;
        impact1.Entity_Number__c = ENTITY_NAME_IMPACT_1;
        impactProjectsList.add(impact1);

        SubProject_External_Related_Entity__c impact2 = new SubProject_External_Related_Entity__c();
        impact2.SubProject__c = subProject1.Id;
        impact2.Entity_Type__c = ENTITY_TYPE_IMPACT;
        impact2.Entity_Number__c = ENTITY_NAME_IMPACT_2;
        impactProjectsList.add(impact2);

        insert impactProjectsList;

        // -------------------------------------------
        // cmf entities

        sitesList = new List<SubProjectSite__c>();

        site1 = new SubProjectSite__c();
        site1.SubProject__c = subProject1.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        sitesList.add(site1);
        
        site2 = new SubProjectSite__c();
        site2.SubProject__c = subProject1.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        sitesList.add(site2);

        insert sitesList;

        // =============================================================================================
        // TESTING PROPER

        impactProjectsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(2, impactProjectsList.size());

        cmfsList = [SELECT Id, Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_CMF];
        System.assertEquals(2, cmfsList.size());

        testSubProject = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :impactProjectsList.get(0).SubProject__c];
        System.assertNotEquals(null, testSubProject.CMF_Numbers__c);
        System.assertNotEquals(null, testSubProject.Impact_Project_Numbers__c);
        System.assertEquals(true, testSubProject.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, testSubProject.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));
        System.assertEquals(true, testSubProject.Impact_Project_Numbers__c.contains(impactProjectsList.get(0).Entity_Number__c));
        System.assertEquals(true, testSubProject.Impact_Project_Numbers__c.contains(impactProjectsList.get(1).Entity_Number__c));

        testProject = [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :impactProjectsList.get(0).Project__c];
        System.assertNotEquals(null, testProject.CMF_Numbers__c);
        System.assertEquals(true, testProject.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, testProject.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));

        // -------------------------------------------
        // SCENARIO: delete all cmfs
        // EXPECT:   all impacts must remain

        delete sitesList;

        cmfsList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_CMF];
        System.assertEquals(0, cmfsList.size());

        impactProjectsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(2, impactProjectsList.size());

        testSubProject = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :impactProjectsList.get(0).SubProject__c];
        System.assertEquals(null, testSubProject.CMF_Numbers__c);
        System.assertNotEquals(null, testSubProject.Impact_Project_Numbers__c);
        System.assertEquals(true, testSubProject.Impact_Project_Numbers__c.contains(impactProjectsList.get(0).Entity_Number__c));
        System.assertEquals(true, testSubProject.Impact_Project_Numbers__c.contains(impactProjectsList.get(1).Entity_Number__c));

        testProject = [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :impactProjectsList.get(0).Project__c];
        System.assertEquals(null, testProject.CMF_Numbers__c);

        // -------------------------------------------
        // SCENARIO: add 2 new cmfs
        // EXPECT:   2 new cmfs get created
        //           existing impacts must remain as-is

        sitesList = new List<SubProjectSite__c>();

        site1 = new SubProjectSite__c();
        site1.SubProject__c = subProject1.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        sitesList.add(site1);
        
        site2 = new SubProjectSite__c();
        site2.SubProject__c = subProject1.Id;
        site2.CMF_Name__c = cmfInfo2.Id;
        sitesList.add(site2);

        insert sitesList;

        cmfsList = [SELECT Id, Entity_Number__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_CMF];
        System.assertEquals(2, cmfsList.size());

        impactProjectsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(2, impactProjectsList.size());

        testSubProject = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :impactProjectsList.get(0).SubProject__c];
        System.assertNotEquals(null, testSubProject.CMF_Numbers__c);
        System.assertNotEquals(null, testSubProject.Impact_Project_Numbers__c);
        System.assertEquals(true, testSubProject.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, testSubProject.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));
        System.assertEquals(true, testSubProject.Impact_Project_Numbers__c.contains(impactProjectsList.get(0).Entity_Number__c));
        System.assertEquals(true, testSubProject.Impact_Project_Numbers__c.contains(impactProjectsList.get(1).Entity_Number__c));

        testProject = [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :impactProjectsList.get(0).Project__c];
        System.assertNotEquals(null, testProject.CMF_Numbers__c);
        System.assertEquals(true, testProject.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, testProject.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));

        // -------------------------------------------
        // SCENARIO: delete all impacts
        // EXPECT:   all cmfs must remian

        delete impactProjectsList;

        cmfsList = [SELECT Id, Entity_Number__c, SubProject__c, Project__c FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_CMF];
        System.assertEquals(2, cmfsList.size());

        impactProjectsList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(0, impactProjectsList.size());

        testSubProject = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :cmfsList.get(0).SubProject__c];
        System.assertNotEquals(null, testSubProject.CMF_Numbers__c);
        System.assertEquals(null, testSubProject.Impact_Project_Numbers__c);
        System.assertEquals(true, testSubProject.CMF_Numbers__c.contains(cmfsList.get(0).Entity_Number__c));
        System.assertEquals(true, testSubProject.CMF_Numbers__c.contains(cmfsList.get(1).Entity_Number__c));

        // -------------------------------------------
        // SCENARIO: delete all cmfs
        // EXPECT:   no cmf and impact should persist

        Id tempSubProjectId = cmfsList.get(0).SubProject__c;
        Id tempProjectId = cmfsList.get(0).Project__c;

        delete sitesList;

        cmfsList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_CMF];
        System.assertEquals(0, cmfsList.size());

        impactProjectsList = [SELECT Id FROM SubProject_External_Related_Entity__c WHERE Entity_Type__c = :ENTITY_TYPE_IMPACT];
        System.assertEquals(0, impactProjectsList.size());

        testSubProject = [SELECT CMF_Numbers__c, Impact_Project_Numbers__c FROM SubProject__c WHERE Id = :tempSubProjectId];
        System.assertEquals(null, testSubProject.CMF_Numbers__c);
        System.assertEquals(null, testSubProject.Impact_Project_Numbers__c);

        testProject = [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :tempProjectId];
        System.assertEquals(null, testProject.CMF_Numbers__c);

        // =============================================================================================

        Test.stopTest();
    }

    private static testmethod void updateFields_CustomSettingsTest() {
        
        Test.startTest();

        // =============================================================================================
        // IMPACT PROJECT

        // -------------------------------------------
        // SCENARIO: HasFieldonSubproject__c == false
        // EXPECT:   Subproject's Impact_Project_Numbers__c will be blank

        entityTypesCustomSetting = new IMP_ProjectLinksUrls__c();
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
        System.assertEquals(null, [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :project.Id].CMF_Numbers__c);

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
        System.assertEquals(null, [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :project.Id].CMF_Numbers__c);

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

        System.assertEquals(site1NewShipCmf + ',' + site2NewShipCmf + ',' + site3NewShipCmf, [SELECT CMF_Numbers__c FROM Project__c WHERE Id = :project.Id].CMF_Numbers__c);

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

        SubProjectSite__c site1 = new SubProjectSite__c();
        site1.SubProject__c = subProject1.Id;
        site1.CMF_Name__c = cmfInfo1.Id;
        insert site1;

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

        System.assertEquals(project.Id, new List<Id>(idToEntityMap.keySet())[0]);

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

        SubProject_External_Related_Entity__c entity = new SubProject_External_Related_Entity__c();
        entity.SubProject__c = subProject1.Id;
        entity.Entity_Type__c = ENTITY_TYPE_IMPACT;
        entity.Entity_Number__c = ENTITY_NAME_IMPACT_1;
        insert entity;

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
        entityTypesCustomSetting = new IMP_ProjectLinksUrls__c();
        entityTypesCustomSetting.Name = ENTITY_TYPE_CMF;
        entityTypesCustomSetting.HasFieldonProject__c    = true; 
        entityTypesCustomSetting.ProjectFieldName__c     = FIELD_NAME_CMF_NUMBERS;
        entityTypesCustomSetting.HasFieldonSubproject__c = true; 
        entityTypesCustomSetting.SubProjectFieldName__c  = FIELD_NAME_CMF_NUMBERS;
        insert entityTypesCustomSetting;
        
        SubProjectSite__c testSite = new SubProjectSite__c(CMF_Name__c = cmfInfo1.Id, SubProject__c = subProject1.Id);
        insert testSite;
        SubProject_External_Related_Entity__c testSpere = [SELECT id, Entity_Type__c, Business_Unit__c FROM SubProject_External_Related_Entity__c WHERE SubProject__c = :subProject1.Id];
        SubProject__c testSubProject = [SELECT Id, SubProject_Region__c FROM SubProject__c WHERE Id = : subProject1.Id];
        Project__c testProject = [SELECT Id, Project_Region__c FROM Project__c WHERE Id = :project.Id];
        system.Debug('***business unit: '+ testSpere.Business_Unit__c + '***'+ testSubProject.SubProject_Region__c);
        system.Debug('***testSpere: '+ testSpere);
        system.Assert(testSpere.Business_Unit__c == testSubProject.SubProject_Region__c);
        system.Assert(testSpere.Business_Unit__c == testProject.Project_Region__c);
    }
}