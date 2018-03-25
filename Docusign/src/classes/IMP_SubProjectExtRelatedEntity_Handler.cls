/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Responsible for the CRUD of subproject external related entities which are triggered by subproject site DML events
             Includes Business Unit to the created SubProjectExtRelatedEntity based on subprojectsite's Business Unit
Test Class:  IMP_SubProjectExtRelatedEntity_Test
History
12/22/14     Samuel Oberes       Created
01/15/15     Kimiko Roberto      Included Business Unit to the created SubProjectExtRelatedEntity based on subprojectsite's Business Unit
02/05/15     Samuel Oberes       Major refactoring
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
    ------------------------------------------------------------*/
    public static void insertCMFEntityRecord(Map<Id, SubProjectSite__c> newSitesMap) {

        // 1) Get only external related entity records with: 
        //      - Ship_CMF__c values that are not null
        //      - Old_CMF__c != Ship_CMF__c
        //      - records with Ship_CMF__c length < 13
        // 2) Insert the concatenated values of SubProject__c, pipe, and Ship_CMF__c in a set.

        Map<String, SubProjectSite__c> subProjectAndCmfToSiteMap = new Map<String, SubProjectSite__c>();
        Set<Id> subProjectIdsSet = new Set<Id>();
        Set<String> cmfsSet = new Set<String>();
        Set<String> cmfNumbersSet = new Set<String>();
        
        for (SubProjectSite__c newSite : newSitesMap.values()) {
            cmfNumbersSet = new Set<String>(IMP_Project_Utility.parseDelimitedString(newSite.CMF_Numbers__c, ',', true));
            for (String cmf : cmfNumbersSet) {
                subProjectAndCmfToSiteMap.put(newSite.SubProject__c + '|' + cmf, newSite);
                cmfsSet.add(cmf);
            }
            subProjectIdsSet.add(newSite.SubProject__c);
        }

        // if there is no subproject external related entity to create, exit the method
        if (subProjectAndCmfToSiteMap.size() == 0) {
            return;
        }

        // 3) call the internal insertion process
        IMP_SubProjectExtRelatedEntity_Handler.insertSpere(subProjectIdsSet, cmfsSet, subProjectAndCmfToSiteMap);
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
    ------------------------------------------------------------*/
    public static void updateCMFEntityRecord(Map<Id, SubProjectSite__c> oldSitesMap, Map<Id, SubProjectSite__c> newSitesMap) {

        Map<String, SubProjectSite__c> subProjectAndCmfToSiteMap = new Map<String, SubProjectSite__c>();
        Set<String> newCmfNumbersSet = new Set<String>();
        Set<String> oldCmfNumbersSet = new Set<String>();
        Set<String> cmfsToInsertSet = new Set<String>(); // all cmfs in new but not in old
        Set<String> cmfsToDeleteSet = new Set<String>(); // all cmfs in old but not in new
        Set<String> allcmfsToInsertSetSet = new Set<String>();
        Set<String> allcmfsToDeleteSetSet = new Set<String>();
        Set<Id> allSubProjectIdsToInsertSet = new Set<Id>();
        Set<Id> allSubProjectIdsToDeleteSet = new Set<Id>();
        
        for (SubProjectSite__c newSite : newSitesMap.values()) {

            if (oldSitesMap != null && oldSitesMap.get(newSite.Id).CMF_Numbers__c != newSite.CMF_Numbers__c) {
                newCmfNumbersSet = new Set<String>(IMP_Project_Utility.parseDelimitedString(newSite.CMF_Numbers__c, ',', true));
                oldCmfNumbersSet = new Set<String>(IMP_Project_Utility.parseDelimitedString(oldSitesMap.get(newSite.Id).CMF_Numbers__c, ',', true));

                // ---------------------------------------
                // for insertion

                //cmfsToInsertSet = newCmfNumbersSet.clone();
                //cmfsToInsertSet.removeAll(oldCmfNumbersSet);
                cmfsToInsertSet = IMP_Project_Utility.getUniqueElementsOfSetOne(newCmfNumbersSet, oldCmfNumbersSet);

                for (String cmf : cmfsToInsertSet) {
                    subProjectAndCmfToSiteMap.put(newSite.SubProject__c + '|' + cmf, newSite);
                    allcmfsToInsertSetSet.add(cmf);
                }
                allSubProjectIdsToInsertSet.add(newSite.SubProject__c);

                // ---------------------------------------
                // for deletion

                //cmfsToDeleteSet = oldCmfNumbersSet.clone();
                //cmfsToDeleteSet.removeAll(newCmfNumbersSet);
                cmfsToDeleteSet = IMP_Project_Utility.getUniqueElementsOfSetOne(oldCmfNumbersSet, newCmfNumbersSet);

                for (String cmf : cmfsToDeleteSet) {
                    allcmfsToDeleteSetSet.add(cmf);
                }
                allSubProjectIdsToDeleteSet.add(newSite.SubProject__c);
                
            }

        }

        // if there is ata least 1 subproject external related entity to create, do not exit the method
        if (allcmfsToInsertSetSet.size() > 0 && subProjectAndCmfToSiteMap.size() > 0) {
            IMP_SubProjectExtRelatedEntity_Handler.insertSpere(allSubProjectIdsToInsertSet, allcmfsToInsertSetSet, subProjectAndCmfToSiteMap);
        }

        if (allcmfsToDeleteSetSet.size() > 0) {
            IMP_SubProjectExtRelatedEntity_Handler.deleteSpere(allSubProjectIdsToDeleteSet, allcmfsToDeleteSetSet);
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
        Set<String> cmfsSet = new Set<String>();
        Set<String> cmfNumbersSet = new Set<String>();

        for (SubProjectSite__c sps : oldSitesMap.values()) {
            subProjectIdsSet.add(sps.SubProject__c);

            cmfNumbersSet = new Set<String>(IMP_Project_Utility.parseDelimitedString(sps.CMF_Numbers__c, ',', true));
            for (String cmf : cmfNumbersSet) {
                cmfsSet.add(cmf);
            }
        }

        IMP_SubProjectExtRelatedEntity_Handler.deleteSpere(subProjectIdsSet, cmfsSet);
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Private method responsible for the internal insertion process
    Parameters:  subProjectIdsSet - subproject ids to be used for querying the SPERE table
                 cmfsSet - cmfs to be used for querying the SPERE table
                 subProjectAndCmfToSiteMap
    History
    02/05/15     Samuel Oberes       Created
    ------------------------------------------------------------*/
    @Testvisible
    private static void insertSpere(Set<Id> subProjectIdsSet, Set<String> cmfsSet, Map<String, SubProjectSite__c> subProjectAndCmfToSiteMap) {

        // 1) Query records from SubProject_External_Related_Entity__c whose subProjectID-CMF pair already exist
        Map<Id, SubProject_External_Related_Entity__c> existingRelatedEntityMap = new Map<Id, SubProject_External_Related_Entity__c>([SELECT Id, SubProject__c, Entity_Number__c
                                                                                                                                        FROM SubProject_External_Related_Entity__c 
                                                                                                                                       WHERE SubProject__c IN :subProjectIdsSet
                                                                                                                                         AND Entity_Number__c IN :cmfsSet
                                                                                                                                         AND Entity_Type__c = 'CMF']);

        // 2) Create the set of existing external related entities. This will be used to pinpoint which of the new sites' subprojects already have an external related entity
        Map<String, SubProject_External_Related_Entity__c> subprojectAndCmfToExternalEntityMap = new Map<String, SubProject_External_Related_Entity__c>();
        for (SubProject_External_Related_Entity__c existingRelatedEntity : existingRelatedEntityMap.values()) {
            subprojectAndCmfToExternalEntityMap.put(existingRelatedEntity.SubProject__c + '|' + existingRelatedEntity.Entity_Number__c, existingRelatedEntity);
        }

        // 3) Perform the comparison to check if the subprojectID-CMF pair of the new subproject site is already existing in the external related entity. If no, add it. If yes, just move on.
        List<SubProject_External_Related_Entity__c> recordsToInsertList = new List<SubProject_External_Related_Entity__c>();
        List<IMP_ProcessingSupport__c> processFlagsList = new List<IMP_ProcessingSupport__c>();
        for (String subProjectCmfPair : subProjectAndCmfToSiteMap.keySet()) {
            if (!subprojectAndCmfToExternalEntityMap.keySet().contains(subProjectCmfPair)) {
                recordsToInsertList.add(new SubProject_External_Related_Entity__c(Entity_Number__c = IMP_Project_Utility.parseDelimitedString(subProjectCmfPair, '|', false)[1],
                                                                                     SubProject__c = subProjectAndCmfToSiteMap.get(subProjectCmfPair).SubProject__c, 
                                                                                        Project__c = subProjectAndCmfToSiteMap.get(subProjectCmfPair).Project__c, 
                                                                                    Entity_Type__c = 'CMF',
                                                                                  Business_Unit__c = subProjectAndCmfToSiteMap.get(subProjectCmfPair).Business_Unit__c));
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
                 cmfsSet - cmfs to be used for querying the SPERE table
    History
    02/05/15     Samuel Oberes       Created
    ------------------------------------------------------------*/
    private static void deleteSpere(Set<Id> subProjectIdsSet, Set<String> cmfsSet) {

        List<SubProject_External_Related_Entity__c> recordsToDeleteList = [SELECT Id 
                                                                             FROM SubProject_External_Related_Entity__c 
                                                                            WHERE SubProject__c IN :subProjectIdsSet
                                                                              AND Entity_Number__c IN :cmfsSet
                                                                              AND Entity_Type__c = 'CMF'];
        
        if (recordsToDeleteList.size() > 0) {

            List<IMP_ProcessingSupport__c> processFlagsList = new List<IMP_ProcessingSupport__c>();
            for (SubProject_External_Related_Entity__c spere : recordsToDeleteList) {
                
                // set the ff. fields so that it would bypass the SPERE BEFORE-DELETE check disallowing delete of SPEREs
                IMP_ProcessingSupport__c processFlag = new IMP_ProcessingSupport__c();
                processFlag.Name = spere.Id;
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