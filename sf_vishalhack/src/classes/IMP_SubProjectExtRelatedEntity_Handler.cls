/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: - Responsible for the CRUD of subproject external related entities which are triggered by subproject site DML events
               Includes Business Unit to the created SubProjectExtRelatedEntity based on subprojectsite's Business Unit
             - Currently configured to cater for CMF and RMS ONLY. Empowering this handler to cater for other future entities might require a little refactoring across majority of the methods.
Test Class:  IMP_SubProjectExtRelatedEntity_Test
History
12/22/14     Samuel Oberes       Created
01/15/15     Kimiko Roberto      Included Business Unit to the created SubProjectExtRelatedEntity based on subprojectsite's Business Unit
02/05/15     Samuel Oberes       Major refactoring
07/28/15     Samuel Oberes       Renamed insertCMFEntityRecord to insertSpereRecordIdentifier AND updateCMFEntityRecord to updateSpereIdentifier
07/30/15     Samuel Oberes       Added usage of IMP_EntityTypeHelper__c
08/10/15     Samuel Oberes       Updated the updateSpereIdentifier method in support of SPERE processing associate with SubProjectSite reparenting.
10/06/15     Samuel Oberes       Added DUPLICATE ERROR logic in insertSpereRecordIdentifier and updateSpereIdentifier
12/13/16     Venkata Shrivol	 commented the project object reference RQ-08305
------------------------------------------------------------*/
public class IMP_SubProjectExtRelatedEntity_Handler {

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Responsible for the addition of new SubProject_External_Related_Entity__c records
    Parameters:  oldSitesMap - accepts the Trigger.oldMap values
                 newSitesMap - accepts the Trigger.newMap values
    History
    12/22/14     Samuel Oberes       Created
    12/31/14     Samuel Oberes       Added the update scenario
    01/15/15     Samuel Oberes       renamed method from insertNewRecord to insertOrUpdateRecord
    01/21/15     Samuel Oberes       renamed method from insertOrUpdateRecord to insertOrUpdateCMFEntityRecord
                                     added relatedEntity.Business_Unit__c inside the isUpdateScenario
                                     added setting of Site_Driven_Update_In_Progress__c to true
    01/22/15     Samuel Oberes       replaced Site_Driven_Update_In_Progress__c logic with IMP_ProcessingSupport__c
    02/05/15     Samuel Oberes       Superseded by insertCMFEntityRecord and updateCMFEntityRecord. Left for reference.
    ------------------------------------------------------------*/
    //public static void insertOrUpdateCMFEntityRecord(Map<Id, SubProjectSite__c> oldSitesMap, Map<Id, SubProjectSite__c> newSitesMap) {

    //    // 1) Get only external related entity records with: 
    //    //      - Ship_CMF__c values that are not null
    //    //      - Old_CMF__c != Ship_CMF__c
    //    //      - records with Ship_CMF__c length < 13
    //    // 2) Insert the concatenated values of SubProject__c, pipe, and Ship_CMF__c in a set.
    //    Map<String, SubProjectSite__c> subProjectAndCmfToSiteMap = new Map<String, SubProjectSite__c>();
    //    Set<Id> subProjectIdsSet = new Set<Id>();
    //    Set<String> cmfsSet = new Set<String>();
    //    Boolean isUpdateScenario;

    //    for (SubProjectSite__c newSite : newSitesMap.values()) {
    //        /*
    //            - old == null                          AND new <> null -> for insertion
    //            - old <> null AND old ship_cmf <> null AND new == null -> for deletion (this wont happen because SHIP_CMF is mandatory)
    //            - old <> null                          AND old <> new  -> for update
    //        */
    //        if (oldSitesMap == null && newSite.Ship_CMF__c != null) {

    //            // insertion scenario
    //            subProjectAndCmfToSiteMap.put(newSite.SubProject__c + '|' + newSite.Ship_CMF__c, newSite);
    //            cmfsSet.add(newSite.Ship_CMF__c);
                
    //            subProjectIdsSet.add(newSite.SubProject__c);
    //            isUpdateScenario = false;

    //        } else if (oldSitesMap != null && oldSitesMap.get(newSite.Id).Ship_CMF__c != newSite.Ship_CMF__c) {

    //            // update scenario
    //            subProjectAndCmfToSiteMap.put(oldSitesMap.get(newSite.Id).SubProject__c + '|' + oldSitesMap.get(newSite.Id).Ship_CMF__c, oldSitesMap.get(newSite.Id));
    //            cmfsSet.add(oldSitesMap.get(newSite.Id).Ship_CMF__c);

    //            subProjectIdsSet.add(oldSitesMap.get(newSite.Id).SubProject__c);
    //            isUpdateScenario = true;

    //        }
    //    }

    //    // if there is no subproject external related entity to create, exit the method
    //    if (subProjectAndCmfToSiteMap.size() == 0) {
    //        return;
    //    }

    //    // 3) Query records from SubProject_External_Related_Entity__c whose subProjectID-CMF pair already exist
    //    Map<Id, SubProject_External_Related_Entity__c> existingRelatedEntityMap = new Map<Id, SubProject_External_Related_Entity__c>([SELECT Id, SubProject__c, Entity_Number__c
    //                                                                                                                                    FROM SubProject_External_Related_Entity__c 
    //                                                                                                                                   WHERE SubProject__c IN :subProjectIdsSet
    //                                                                                                                                     AND Entity_Number__c IN :cmfsSet
    //                                                                                                                                     AND Entity_Type__c = 'CMF']);

    //    // 4) Create the set of existing external related entities. This will be used to pinpoint which of the new sites' subprojects already have an external related entity
    //    Map<String, SubProject_External_Related_Entity__c> subprojectAndCmfToExternalEntityMap = new Map<String, SubProject_External_Related_Entity__c>();
    //    for (SubProject_External_Related_Entity__c existingRelatedEntity : existingRelatedEntityMap.values()) {
    //        subprojectAndCmfToExternalEntityMap.put(existingRelatedEntity.SubProject__c + '|' + existingRelatedEntity.Entity_Number__c, existingRelatedEntity);
    //    }

    //    // 5) Perform the comparison to check if the subprojectID-CMF pair of the new subproject site is already existing in the external related entity. If no, add it. If yes, just move on.
    //    List<SubProject_External_Related_Entity__c> recordsToUpsertList = new List<SubProject_External_Related_Entity__c>();
    //    List<IMP_ProcessingSupport__c> processFlagsList = new List<IMP_ProcessingSupport__c>();
    //    for (String subProjectCmfPair : subProjectAndCmfToSiteMap.keySet()) {
    //        if (!subprojectAndCmfToExternalEntityMap.keySet().contains(subProjectCmfPair)) {
    //            recordsToUpsertList.add(new SubProject_External_Related_Entity__c(Entity_Number__c = subProjectAndCmfToSiteMap.get(subProjectCmfPair).Ship_CMF__c,
    //                                                                                 SubProject__c = subProjectAndCmfToSiteMap.get(subProjectCmfPair).SubProject__c, 
    //                                                                                    Project__c = subProjectAndCmfToSiteMap.get(subProjectCmfPair).Project__c, 
    //                                                                                Entity_Type__c = 'CMF',
    //                                                                              Business_Unit__c = subProjectAndCmfToSiteMap.get(subProjectCmfPair).Business_Unit__c));
    //        } else {
    //            if (isUpdateScenario) {
    //                SubProject_External_Related_Entity__c relatedEntity = subprojectAndCmfToExternalEntityMap.get(subProjectCmfPair);
    //                relatedEntity.Entity_Number__c = newSitesMap.get(subProjectAndCmfToSiteMap.get(subProjectCmfPair).Id).Ship_CMF__c;
    //                relatedEntity.Business_Unit__c = newSitesMap.get(subProjectAndCmfToSiteMap.get(subProjectCmfPair).Id).Business_Unit__c;
    //                recordsToUpsertList.add(relatedEntity);

    //                // set the ff. fields so that it would bypass the SPERE BEFORE-UPDATE check disallowing update of SPEREs
    //                IMP_ProcessingSupport__c processFlag = new IMP_ProcessingSupport__c();
    //                processFlag.Name = relatedEntity.Id;
    //                processFlag.Action__c = 'UPDATE';
    //                processFlag.Action_Driven_By__c = 'SUBPROJECTSITE';
    //                processFlag.Action_In_Progress__c = true;
    //                processFlagsList.add(processFlag);
    //            }
    //        }
    //    }
    //    insert processFlagsList;

    //    // 6) Only perform the INSERT DML if there is something to insert
    //    if (recordsToUpsertList.size() > 0) {
    //        try {
    //            upsert recordsToUpsertList;
    //        } catch (DmlException e) {
    //            System.debug('DBG: Error encountered while upserting records. Details below.\n' + 
    //                         'Message: ' + e.getMessage() + '\n' +
    //                         'Stack Trace: ' + e.getStackTraceString());
    //        }
    //    }

    //}

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Responsible for the addition of new SubProject_External_Related_Entity__c records
    Parameters:  newSitesMap - accepts the Trigger.newMap values
    History
    02/05/15     Samuel Oberes       Created
    07/28/15     Samuel Oberes       Renamed insertCMFEntityRecord to insertSpereRecordIdentifier
    ------------------------------------------------------------*/
    public static void insertSpereRecordIdentifier(Map<Id, SubProjectSite__c> newSitesMap, Map<Id, Map<String, Set<String>>> cmfOrRmsToExcludeFromInsertionMap) {

        // 1) Get only external related entity records with: 
        //      - Ship_CMF__c values that are not null
        //      - Old_CMF__c != Ship_CMF__c
        //      - records with Ship_CMF__c length < 13
        // 2) Insert the concatenated values of SubProject__c, pipe, and Ship_CMF__c in a set.

        Map<String, SubProjectSite__c> subProjectAndSpereAndTypeToSiteMap = new Map<String, SubProjectSite__c>();
        Set<Id> subProjectIdsSet = new Set<Id>();
        Set<String> spereSet = new Set<String>();
        Set<String> spereNumberesSet = new Set<String>();
        String field;

        for (SubProjectSite__c newSite : newSitesMap.values()) 
        {
            for (String entityType : IMP_EntityTypeHelper__c.getAll().keySet())
            {
                field = IMP_EntityTypeHelper__c.getInstance(entityType).Entity_Field_Name__c;
                spereNumberesSet = new Set<String>(IMP_Project_Utility.parseDelimitedString((String)newSite.get(field), ',', true));
                for (String spereNumber : spereNumberesSet) {

                    // only insert speres that are not tagged as "for exclusion"
                    if (cmfOrRmsToExcludeFromInsertionMap.size() == 0 || 
                        cmfOrRmsToExcludeFromInsertionMap.get(newSite.SubProject__c).keySet().size() == 0 || 
                        cmfOrRmsToExcludeFromInsertionMap.get(newSite.SubProject__c).get(entityType) == null || 
                        !cmfOrRmsToExcludeFromInsertionMap.get(newSite.SubProject__c).get(entityType).contains(spereNumber))
                    {
                        subProjectAndSpereAndTypeToSiteMap.put(newSite.SubProject__c + '|' + spereNumber + '|' + entityType, newSite);
                        spereSet.add(spereNumber);
                    }
                }
                subProjectIdsSet.add(newSite.SubProject__c);
            }
        }

        // if there is no subproject external related entity to create, exit the method
        if (subProjectAndSpereAndTypeToSiteMap.size() == 0) {
            return;
        }

        // 3) call the internal insertion process
        IMP_SubProjectExtRelatedEntity_Handler.insertSpere(subProjectIdsSet, spereSet, subProjectAndSpereAndTypeToSiteMap);
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Responsible for the update of existing SubProject_External_Related_Entity__c records
    Parameters:  oldSitesMap - accepts the Trigger.oldMap values
                 newSitesMap - accepts the Trigger.newMap values
    History
    02/05/15     Samuel Oberes       Created
    02/06/15     Samuel Oberes       added implementation of IMP_Project_Utility.getUniqueElementsOfSetOne
    07/28/15     Samuel Oberes       Renamed updateCMFEntityRecord to updateSpereIdentifier
    08/08/15     Samuel Oberes       Added re-parenting logic and the entityNumberToNewSubProjectIdMap code block
    08/10/15     Samuel Oberes       Added "copy-paste" logic of existing contracts and impact projects to the new subproject when site is reparented.
    ------------------------------------------------------------*/
    public static void updateSpereIdentifier(Map<Id, SubProjectSite__c> oldSitesMap, Map<Id, SubProjectSite__c> newSitesMap, Map<Id, Map<String, Set<String>>> cmfOrRmsToExcludeFromInsertionMap) {

        Map<String, SubProjectSite__c> subProjectAndSpereAndTypeToSiteMap = new Map<String, SubProjectSite__c>();
        Set<String> newSpereNumbersSet = new Set<String>();
        Set<String> oldSpereNumbersSet = new Set<String>();
        Set<String> speresToInsertSet = new Set<String>(); // all speres in new but not in old
        Set<String> speresToDeleteSet = new Set<String>(); // all speres in old but not in new
        Set<String> allSperesToInsertSetSet = new Set<String>();
        Set<String> allSperesToDeleteSetSet = new Set<String>();
        Set<Id> allSubProjectIdsToInsertSet = new Set<Id>();
        Set<Id> allSubProjectIdsToDeleteSet = new Set<Id>();
        String field;

        //List<SubProject_External_Related_Entity__c> updatedCMFSPEREstoUpdateList        = new List<SubProject_External_Related_Entity__c>();
        //List<SubProject_External_Related_Entity__c> updatedRMSRequestSPEREstoInsertList = new List<SubProject_External_Related_Entity__c>();
        List<SubProject_External_Related_Entity__c> updatedCMFandRMSSPEREstoUpdateList = new List<SubProject_External_Related_Entity__c>();
        Map<String, Id> entityNumberToNewSubProjectIdMap = new Map<String, Id>();
        Map<String, Id> entityNumberToOldSubProjectIdMap = new Map<String, Id>();
        Map<Id, Id> oldToNewSubProjectIds = new Map<Id, Id>();

        // loop through all the sites involved in the update context
        for (SubProjectSite__c newSite : newSitesMap.values()) 
        {
            // loop through all the SPERE fields of the site. 
            // As of time of writing, SPERE fields on site are CMF_Numbers__c and RMS_Request_IDs__c.
            for (String entityType : IMP_EntityTypeHelper__c.getAll().keySet())
            {
                field = IMP_EntityTypeHelper__c.getInstance(entityType).Entity_Field_Name__c;
                if (oldSitesMap != null && (String)oldSitesMap.get(newSite.Id).get(field) != (String)newSite.get(field)) 
                {
                    newSpereNumbersSet = new Set<String>(IMP_Project_Utility.parseDelimitedString((String)newSite.get(field), ',', true));
                    oldSpereNumbersSet = new Set<String>(IMP_Project_Utility.parseDelimitedString((String)oldSitesMap.get(newSite.Id).get(field), ',', true));

                    // ---------------------------------------
                    // for insertion

                    //speresToInsertSet = newSpereNumbersSet.clone();
                    //speresToInsertSet.removeAll(oldSpereNumbersSet);
                    speresToInsertSet = IMP_Project_Utility.getUniqueElementsOfSetOne(newSpereNumbersSet, oldSpereNumbersSet);

                    for (String spereNumber : speresToInsertSet) {

                        // only insert speres that are not tagged as "for exclusion"
                        if (cmfOrRmsToExcludeFromInsertionMap.size() == 0 || 
                            cmfOrRmsToExcludeFromInsertionMap.get(newSite.SubProject__c).keySet().size() == 0 || 
                            cmfOrRmsToExcludeFromInsertionMap.get(newSite.SubProject__c).get(entityType) == null || 
                            !cmfOrRmsToExcludeFromInsertionMap.get(newSite.SubProject__c).get(entityType).contains(spereNumber))
                        {
                            subProjectAndSpereAndTypeToSiteMap.put(newSite.SubProject__c + '|' + spereNumber + '|' + entityType, newSite);
                            allSperesToInsertSetSet.add(spereNumber);
                        }
                    }
                    allSubProjectIdsToInsertSet.add(newSite.SubProject__c);

                    // ---------------------------------------
                    // for deletion

                    //if (entityType == 'CMF')
                    //{
                        //speresToDeleteSet = oldSpereNumbersSet.clone();
                        //speresToDeleteSet.removeAll(newSpereNumbersSet);
                        speresToDeleteSet = IMP_Project_Utility.getUniqueElementsOfSetOne(oldSpereNumbersSet, newSpereNumbersSet);

                        for (String spereNumber : speresToDeleteSet) {
                            allSperesToDeleteSetSet.add(spereNumber);
                        }
                        allSubProjectIdsToDeleteSet.add(newSite.SubProject__c);
                    //}
                }
            }

            // if subproject changed (re-parenting mode)
            if (oldSitesMap != null && (Id)oldSitesMap.get(newSite.Id).get('Subproject__c') != newSite.SubProject__c)
            {
                // CMFs
                for (String spere : IMP_Project_Utility.parseDelimitedString((String)newSite.get('CMF_Numbers__c'), ',', true))
                {
                    entityNumberToNewSubProjectIdMap.put(spere, newSite.SubProject__c);
                    entityNumberToOldSubProjectIdMap.put(spere, (Id)oldSitesMap.get(newSite.Id).get('Subproject__c'));
                }

                // RMSs
                for (String spere : IMP_Project_Utility.parseDelimitedString((String)newSite.get('RMS_Request_IDs__c'), ',', true))
                {
                    entityNumberToNewSubProjectIdMap.put(spere, newSite.SubProject__c);
                    entityNumberToOldSubProjectIdMap.put(spere, (Id)oldSitesMap.get(newSite.Id).get('Subproject__c'));
                }

                oldToNewSubProjectIds.put((Id)oldSitesMap.get(newSite.Id).get('Subproject__c'), newSite.SubProject__c);
            }

        }

        if (!entityNumberToNewSubProjectIdMap.keySet().isEmpty())
        {
            List<SubProject_External_Related_Entity__c> speresFromOldSubProjectList = [SELECT Id, Entity_Number__c, Entity_Type__c, SubProject__c 
                                                                                         FROM SubProject_External_Related_Entity__c 
                                                                                        WHERE SubProject__c IN :entityNumberToOldSubProjectIdMap.values()
                                                                                          AND Entity_Number__c IN :entityNumberToOldSubProjectIdMap.keySet()
                                                                                          AND (   Entity_Type__c = 'CMF' 
                                                                                               OR Entity_Type__c = 'RMS Request')];

            for (SubProject_External_Related_Entity__c spere : speresFromOldSubProjectList) 
            {
                if (spere.Entity_Type__c == 'CMF' || spere.Entity_Type__c == 'RMS Request')
                {
                    spere.SubProject__c = entityNumberToNewSubProjectIdMap.get(spere.Entity_Number__c);
                    updatedCMFandRMSSPEREstoUpdateList.add(spere);
                }
            }
            update updatedCMFandRMSSPEREstoUpdateList;
        }

        // if re-parented, copy-paste CONTRACT and IMPACT PROJECT SPERES to new SUBPROJECT
        if (!oldToNewSubProjectIds.keySet().isEmpty())
        {
            // get all the SPERES from the NEW SUBPROJECT
            List<SubProject_External_Related_Entity__c> queriedNewSperes = [SELECT Entity_Number__c, Entity_Type__c, SubProject__c 
                                                                              FROM SubProject_External_Related_Entity__c 
                                                                             WHERE SubProject__c IN :oldToNewSubProjectIds.values()
                                                                               AND (   Entity_Type__c = 'Contract' 
                                                                                    OR Entity_Type__c = 'Impact Project')];
            
            // Create a unique-id by concatenating the subproject ID, spere number, and spere type.
            // This unique id will be used for checking if the spere to insert already exists. If it does, then the insertion is aborted.
            Set<String> impactOrContractUniqueIdentifierSet = new Set<String>();
            for (SubProject_External_Related_Entity__c rec : queriedNewSperes)
            {
                impactOrContractUniqueIdentifierSet.add(rec.SubProject__c + '|' + rec.Entity_Number__c + '|' + rec.Entity_Type__c);
            }

            // get all the SPERES from the OLD SUBPROJECT. These are the potential speres to insert under a NEW SUBPROJECT.
            List<SubProject_External_Related_Entity__c> toInsertList = new List<SubProject_External_Related_Entity__c>();
            List<SubProject_External_Related_Entity__c> queriedOldSperes = [SELECT Entity_Number__c, Entity_Type__c, SubProject__c 
                                                                              FROM SubProject_External_Related_Entity__c 
                                                                             WHERE SubProject__c IN :oldToNewSubProjectIds.keySet()
                                                                               AND (   Entity_Type__c = 'Contract' 
                                                                                    OR Entity_Type__c = 'Impact Project')];
            
            // Create and insert the SPERE under its new home subproject, only if it doesn't exist there yet.
            for (SubProject_External_Related_Entity__c rec : queriedOldSperes)
            {
                if (!impactOrContractUniqueIdentifierSet.contains(oldToNewSubProjectIds.get(rec.SubProject__c) + '|' + rec.Entity_Number__c + '|' + rec.Entity_Type__c))
                {
                    toInsertList.add(new SubProject_External_Related_Entity__c(Entity_Number__c = rec.Entity_Number__c, 
                                                                               Entity_Type__c = rec.Entity_Type__c, 
                                                                               SubProject__c = oldToNewSubProjectIds.get(rec.SubProject__c)));
                }
            }
            insert toInsertList;
        }
        

        // if there is ata least 1 subproject external related entity to create, do not exit the method
        if (allSperesToInsertSetSet.size() > 0 && subProjectAndSpereAndTypeToSiteMap.size() > 0) {
            IMP_SubProjectExtRelatedEntity_Handler.insertSpere(allSubProjectIdsToInsertSet, allSperesToInsertSetSet, subProjectAndSpereAndTypeToSiteMap);
        }

        if (allSperesToDeleteSetSet.size() > 0) {
            IMP_SubProjectExtRelatedEntity_Handler.deleteSpere(allSubProjectIdsToDeleteSet, allSperesToDeleteSetSet);
        }

    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Responsible for the deletion of SubProject_External_Related_Entity__c records
    Parameters:  oldSitesMap - accepts the Trigger.oldMap values
    History
    12/23/14     Samuel Oberes       Created
    01/21/15     Samuel Oberes       renamed method from deleteRecord to deleteCMFEntityRecord
                                     added setting of Site_Driven_Update_In_Progress__c to true
    01/22/15     Samuel Oberes       replaced Site_Driven_Update_In_Progress__c logic with IMP_ProcessingSupport__c
    02/05/15     Samuel Oberes       Added delimitation of CMF_Numbers__c. Abstracted deletion part for reusability.
    ------------------------------------------------------------*/
    public static void deleteCMFEntityRecord(Map<Id, SubProjectSite__c> oldSitesMap) {
        Set<Id> subProjectIdsSet = new Set<Id>();
        Set<String> spereSet = new Set<String>();
        Set<String> spereNumberesSet = new Set<String>();

        for (SubProjectSite__c sps : oldSitesMap.values()) {
            subProjectIdsSet.add(sps.SubProject__c);

            spereNumberesSet = new Set<String>(IMP_Project_Utility.parseDelimitedString(sps.CMF_Numbers__c, ',', true));
            for (String spereNumber : spereNumberesSet) {
                spereSet.add(spereNumber);
            }
        }

        IMP_SubProjectExtRelatedEntity_Handler.deleteSpere(subProjectIdsSet, spereSet);
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Private method responsible for the internal insertion process
    Parameters:  subProjectIdsSet - subproject ids to be used for querying the SPERE table
                 spereSet - speres to be used for querying the SPERE table
                 subProjectAndSpereAndTypeToSiteMap
    History
    02/05/15     Samuel Oberes       Created
    07/28/15     Samuel Oberes       Added "Entity_Type__c = 'RMS Request'" condition for existingRelatedEntityMap's query
    ------------------------------------------------------------*/
    @Testvisible
    private static void insertSpere(Set<Id> subProjectIdsSet, Set<String> spereSet, Map<String, SubProjectSite__c> subProjectAndSpereAndTypeToSiteMap) {

        // 1) Query records from SubProject_External_Related_Entity__c whose subProjectID-spereNumber-spereType pair already exist
        Map<Id, SubProject_External_Related_Entity__c> existingRelatedEntityMap = new Map<Id, SubProject_External_Related_Entity__c>([SELECT Id, SubProject__c, Entity_Number__c
                                                                                                                                        FROM SubProject_External_Related_Entity__c 
                                                                                                                                       WHERE SubProject__c IN :subProjectIdsSet
                                                                                                                                         AND Entity_Number__c IN :spereSet
                                                                                                                                         AND (   Entity_Type__c = 'CMF' 
                                                                                                                                              OR Entity_Type__c = 'RMS Request')]);

        // 2) Create the set of existing external related entities. This will be used to pinpoint which of the new sites' subprojects already have an external related entity
        Map<String, SubProject_External_Related_Entity__c> subprojectAndSpereToExternalEntityMap = new Map<String, SubProject_External_Related_Entity__c>();
        for (SubProject_External_Related_Entity__c existingRelatedEntity : existingRelatedEntityMap.values()) {
            subprojectAndSpereToExternalEntityMap.put(existingRelatedEntity.SubProject__c + '|' + existingRelatedEntity.Entity_Number__c, existingRelatedEntity);
        }

        // 3) Perform the comparison to check if the subprojectID-spereNumber-spereType concatenated value of the new subproject site is already existing in the external related entity. If no, add it. If yes, just move on.
        List<SubProject_External_Related_Entity__c> recordsToInsertList = new List<SubProject_External_Related_Entity__c>();
        List<IMP_ProcessingSupport__c> processFlagsList = new List<IMP_ProcessingSupport__c>();
        for (String subProjectAndSpereAndType : subProjectAndSpereAndTypeToSiteMap.keySet()) {
            if (!subprojectAndSpereToExternalEntityMap.keySet().contains(subProjectAndSpereAndType)) {

                List<String> subProjectAndSpereAndTypeList = IMP_Project_Utility.parseDelimitedString(subProjectAndSpereAndType, '|', false);
                recordsToInsertList.add(new SubProject_External_Related_Entity__c(Entity_Number__c = subProjectAndSpereAndTypeList.get(1),
                                                                                     SubProject__c = subProjectAndSpereAndTypeToSiteMap.get(subProjectAndSpereAndType).SubProject__c, 
                                                                                        //Project__c = subProjectAndSpereAndTypeToSiteMap.get(subProjectAndSpereAndType).Project__c, 
                                                                                    Entity_Type__c = subProjectAndSpereAndTypeList.get(2),
                                                                                  Business_Unit__c = subProjectAndSpereAndTypeToSiteMap.get(subProjectAndSpereAndType).Business_Unit__c));
            }
        }

        // 4) Only perform the INSERT DML if there is something to insert
        if (recordsToInsertList.size() > 0) {
            try {
                insert recordsToInsertList;
            } catch (DmlException e) {
                System.debug('DBG: Error encountered while inserting records. Details below.\n' + 
                             'Message: ' + e.getMessage() + '\n' +
                             'Stack Trace: ' + e.getStackTraceString());
            }
        }

    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Private method responsible for the internal deletion process
    Parameters:  subProjectIdsSet - subproject ids to be used for querying the SPERE table
                 spereSet - speres to be used for querying the SPERE table
    History
    02/05/15     Samuel Oberes       Created
    ------------------------------------------------------------*/
    private static void deleteSpere(Set<Id> subProjectIdsSet, Set<String> spereSet) {

        List<SubProject_External_Related_Entity__c> recordsToDeleteList = [SELECT Id 
                                                                             FROM SubProject_External_Related_Entity__c 
                                                                            WHERE SubProject__c IN :subProjectIdsSet
                                                                              AND Entity_Number__c IN :spereSet
                                                                              AND Entity_Type__c = 'CMF'];
        
        if (recordsToDeleteList.size() > 0) {

            List<IMP_ProcessingSupport__c> processFlagsList = new List<IMP_ProcessingSupport__c>();
            for (SubProject_External_Related_Entity__c spereNumber : recordsToDeleteList) {
                
                // set the ff. fields so that it would bypass the SPERE BEFORE-DELETE check disallowing delete of SPEREs
                IMP_ProcessingSupport__c processFlag = new IMP_ProcessingSupport__c();
                processFlag.Name = spereNumber.Id;
                processFlag.Action__c = 'DELETE';
                processFlag.Action_Driven_By__c = 'SUBPROJECTSITE';
                processFlag.Action_In_Progress__c = true;
                processFlagsList.add(processFlag);
            }
            insert processFlagsList;

            try {
                delete recordsToDeleteList;
            } catch (DmlException e) {
                System.debug('DBG: Error encountered while deleting records inside "deleteCMFEntityRecord". Details below.\n' + 
                             'Message: ' + e.getMessage() + '\n' +
                             'Stack Trace: ' + e.getStackTraceString());
            }
        }

    }

}