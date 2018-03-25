/*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: - The value of the external entity's project field is automatically populated with the entity's subproject's project value.
             - Updates the "entity type field" of the project and subproject object. The entity type field(s) can be any entity (as of time of writing [1/16/15], there are 2 entity type fields
               in subproject for CMF and IMPACT, and 1 field in project for CMF). Only those entities found in the IMP_ProjectLinksUrls__c custom setting with its HasFieldonProject__c and 
               HasFieldonSubproject__c values set to true, will be used as a filter for the entity selection properties.
Test Class:  
History
09/23/14     Kimiko Roberto      Created
10/06/14     Kimiko Roberto      Added same function to CMF numbers
10/21/14     Kimiko Roberto      Merged IMP_UpdateProjectExternalRelated trigger function
12/23/14     Samuel Oberes       Added projectIdList as new argument to method updateImpactNumbers
01/05/15     Samuel Oberes       Removed projectIdList
                                 Removed impactEntityList. Querying back to table has been replaced by the IMP_ProjectLinksUrls__c approach
01/16/15     Samuel Oberes       Fixed comments
01/20/15     Kimiko Roberto      Added checking at before update/delete contexts if an Entity type of CMF is being edited or deleted by a non-administrator user.
01/21/15     Samuel Oberes       Added updatedCMFsSet
                                 Added logic involving Site_Driven_Update_In_Progress__c
01/22/15     Samuel Oberes       replaced Site_Driven_Update_In_Progress__c logic with IMP_ProcessingSupport__c
08/08/15     Samuel Oberes       Refactored the AFTER DML context and added the subProjectsToUpdate code block to help clear out the SubProject__c.CMF_Numbers__c field whenever a SubProjectSite__c is re-parented, along with all its related SPERES.
01/26/15     Venkata Shrivol     Added logic to update the Contract number from SPERE object to Deal State record
08/28/15     Venkata Shrivol      Renamed the IMP_UpdateDealStateContractNum_Handler to IMP_UpdateEntityNumsOnDealState_Handler and modified its logic
                                 since Impact project number is also pushing to deal state along with the Contract numbers
10/06/15     Samuel Oberes       Added DUPLICATE ERROR logic
11/19/15     Samuel Oberes       Changed query to SPERE object that retrieves the entitiesofParentProjectList to include full set of ids that were not just inserted, updated, but also deleted….previously, we didn’t add those which were deleted to
                                 the set, and, it caused processing to exclude required records that led to the CMF_Numbers__c fields on both Project__c and SubProject__c to have their concatenated cmf values ‘blanked out’ whenever a single site
                                 was deleted, but others still remained.
------------------------------------------------------------*/
trigger IMP_SubProjectExternalRelatedEntity on SubProject_External_Related_Entity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger.isBefore) {

        // -------------------------------------------------
        // added by Sam 2015-10-06

        Map<Id, Map<String, Set<String>>> speresToExcludeFromInsertionMap = new Map<Id, Map<String, Set<String>>>();

        if (Trigger.isInsert || Trigger.isUpdate)
        {
            Set<String> spereNumbersSet = new Set<String>();
            Set<String> spereTypesSet = new Set<String>();
            String field = '';
            Set<Id> subProjectIdsSet = new Set<Id>();

            // loop through all the speres involved in this context
            for (SubProject_External_Related_Entity__c newSpere : Trigger.new) 
            {
                spereNumbersSet.add(newSpere.Entity_Number__c);
                spereTypesSet.add(newSpere.Entity_Type__c);
                subProjectIdsSet.add(newSpere.SubProject__c);
            }

            List<SubProject_External_Related_Entity__c> alreadyExistingSperes = [SELECT Id, Entity_Type__c, Entity_Number__c, SubProject__c 
                                                                                   FROM SubProject_External_Related_Entity__c 
                                                                                  WHERE Entity_Type__c IN :spereTypesSet 
                                                                                    AND Entity_Number__c IN :spereNumbersSet
                                                                                    AND SubProject__c IN :subProjectIdsSet];
            // Populate the map > map > set.
            // The first map contains a key which is a subproject id, and the map's value is another map.
            // The second map contains a key which is an entity type, and its value is a set of all the entity numbers that is associated with that entity type.
            // This map is part of the overall logic that will be used in determining whether or not the current entity number should be deemed a duplicate, leading to its insertion/update cancelation.
            for (SubProject_External_Related_Entity__c spere : alreadyExistingSperes)
            {
                if (speresToExcludeFromInsertionMap.keySet().contains(spere.SubProject__c))
                {
                    if (speresToExcludeFromInsertionMap.get(spere.SubProject__c).keySet().contains(spere.Entity_Type__c))
                    {
                        speresToExcludeFromInsertionMap.get(spere.SubProject__c).get(spere.Entity_Type__c).add(spere.Entity_Number__c);
                    }
                    else
                    {
                        speresToExcludeFromInsertionMap.get(spere.SubProject__c).put(spere.Entity_Type__c, new Set<String>{ spere.Entity_Number__c });
                    }
                }
                else
                {
                    speresToExcludeFromInsertionMap.put(spere.SubProject__c, new Map<String, Set<String>>{ spere.Entity_Type__c => new Set<String>{ spere.Entity_Number__c } });
                }
            }

            for (SubProject_External_Related_Entity__c newSpere : Trigger.new)
            {
                // Safely check if the current entity number is tagged as a duplicate (already existing in the SPERE table). If yes, proceed.
                if (speresToExcludeFromInsertionMap.size() != 0 && 
                    speresToExcludeFromInsertionMap.get(newSpere.SubProject__c).keySet().size() != 0 &&
                    speresToExcludeFromInsertionMap.get(newSpere.SubProject__c).get(newSpere.Entity_Type__c).contains(newSpere.Entity_Number__c))
                {
                    // If the current process is:
                    //  - Insertion DML
                    //  - Update DML + the entity number changed
                    // Cancel the insert/update request.
                    // NOTE: For the UPDATE context, we are specifically checking if the entity number changed from a unique entity number to an entity number that already exists in the SPERE table.
                    //       If this check is omitted, all updates (business ID, etc.) will not be permitted.
                    if (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(newSpere.Id).Entity_Number__c != newSpere.Entity_Number__c))
                    {
                        newSpere.addError('DUPLICATE ERROR: The entity number for that entity type under that subProject already exists.');
                    }
                }
            }

        }

        // -------------------------------------------------

        // -------------------------------------------------
        // INSERT

        // update the project field via trigger in the backend, rather than allowing the user to manually select the value of the project field while creating a new Project External Related Entity
        if(trigger.isInsert){
            
           /* Set<Id> subProjectIds = new Set<Id>();
            List<SubProject_External_Related_Entity__c> subprojExternalRelatedToUpdate = new List<SubProject_External_Related_Entity__c>();
            
            for(SubProject_External_Related_Entity__c sere : Trigger.New){
                if(sere.SubProject__c != null){
                    subprojExternalRelatedToUpdate.add(sere);
                    
                    //Add SubProject Id to set to be used for query in handler
                    subProjectIds.add(sere.SubProject__c);
                }
            }
            
            //Process records
            if(!subprojExternalRelatedToUpdate.isEmpty()){
                //Update Project value on SubProject External Related Entity based on SubProject's Project
                IMP_Project_Utility.updateProjectField(null, null, null, subprojExternalRelatedToUpdate, subProjectIds);
            }*/

        }

        // -------------------------------------------------
        // UPDATE

        Profile userProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        
        if(Trigger.isUpdate){
            // Check the ff and throw an error if false:
            //  1. if a user is trying to edit a SPERE CMF NUMBER
            //  2. if a user is trying to edit a SPERE CMF TYPE
            //  3. if the user is not a System Admin
            //  4. if the SPERE is being updated, and the update command is NOT sent from an SPS
            String oldEntityNumber = '';
            String oldEntityType = '';
            List<IMP_ProcessingSupport__c> processFlagsList = [SELECT Name 
                                                                 FROM IMP_ProcessingSupport__c 
                                                                WHERE Action__c = 'UPDATE' 
                                                                  AND Action_Driven_By__c = 'SUBPROJECTSITE' 
                                                                  AND Action_In_Progress__c = true];

            Set<Id> recordsInProcess = new Set<Id>();
            Set<Id> recordsToDelete = new Set<Id>();
            for (IMP_ProcessingSupport__c flag : processFlagsList) {
                recordsInProcess.add(flag.Name);
            }

            for(SubProject_External_Related_Entity__c spere : Trigger.New) {
                oldEntityNumber = Trigger.oldMap.get(spere.Id).Entity_Number__c;
                oldEntityType   = Trigger.oldMap.get(spere.Id).Entity_Type__c;
                if(oldEntityType == 'CMF' && userProfile.Name != 'ADPDS - Admin - System Administrator' && 
                    (spere.Entity_Number__c != oldEntityNumber || spere.Entity_Type__c != oldEntityType) && 
                    !recordsInProcess.contains(spere.Id)) {
                    spere.addError('Updating an existing SubProject External Related Entity record originally defined as a CMF entity type can cause its future value to become misaligned with the cmf value in the originating Subproject Site.  Please update the CMF through the Subproject Site to cascade the changes to this record.  If you do require a direct update here, please submit a request to a System Administrator.');
                }

                // delete the bypass setting to make sure it won't introduce wrong bypassing the next time it's used
                recordsToDelete.add(spere.Id);
            }
            
            delete [SELECT Name 
                      FROM IMP_ProcessingSupport__c 
                     WHERE Name IN :recordsToDelete 
                       AND Action__c = 'UPDATE' 
                       AND Action_Driven_By__c = 'SUBPROJECTSITE' 
                       AND Action_In_Progress__c = true];
        }
        
        // -------------------------------------------------
        // DELETE

        if(Trigger.isDelete){
            // Check the ff and throw an error if false:
            //  1. if a user is trying to delete a SPERE CMF NUMBER
            //  2. if the user is not a System Admin
            //  3. if the SPERE is being deleted, and the delete command is NOT sent from an SPS

            List<IMP_ProcessingSupport__c> processFlagsList = [SELECT Name 
                                                                 FROM IMP_ProcessingSupport__c 
                                                                WHERE Action__c = 'DELETE' 
                                                                  AND Action_Driven_By__c = 'SUBPROJECTSITE' 
                                                                  AND Action_In_Progress__c = true];


            Set<Id> recordsInProcess = new Set<Id>();
            Set<Id> recordsToDelete = new Set<Id>();
            for (IMP_ProcessingSupport__c flag : processFlagsList) {
                recordsInProcess.add(flag.Name);
            }

            for(SubProject_External_Related_Entity__c spere : Trigger.Old) {
                if(spere.Entity_Type__c == 'CMF' && userProfile.Name != 'ADPDS - Admin - System Administrator' && !recordsInProcess.contains(spere.Id)) {
                    spere.addError('Directly deleting a SubProject External Related Entity record for a CMF can cause misalignment with the cmf value in the originating Subproject Site.  Please delete this record by deleting the Subproject Site, which will automatically drive the deletion of this record.  If you do require a direct deletion here, please submit a request to a System Administrator.');
                }

                // delete the bypass setting to make sure it won't introduce wrong bypassing the next time it's used
                recordsToDelete.add(spere.Id);
            }
            
            delete [SELECT Name 
                      FROM IMP_ProcessingSupport__c 
                     WHERE Name IN :recordsToDelete 
                       AND Action__c = 'DELETE' 
                       AND Action_Driven_By__c = 'SUBPROJECTSITE' 
                       AND Action_In_Progress__c = true];
        }

    }

    if(Trigger.isAfter) {
        // ==================================================================================================
        // PROJECT AND SUBPROJECT EXTERNAL ENTITY FIELD MAINTENANCE PROCESS
        //
        //  - PURPOSE:  updates the external entity field of the project/subproject of the external entity record that invoked this trigger.
        //  - SCOPE:    ranges across all the ISAFTER trigger subcontexts
        //  - OVERVIEW: (see below)
        /*
            UPDATE the SUBPROJECT'S CMF NUMBERS field only if
                - an external entity of type 'CMF' of that SUBPROJECT is recently inserted/updated/deleted
                    - if inserted, add the external entity's ship cmf to the external entity's parent subproject's collection of cmf numbers
                    - if updated,  same as above
                    - if deleted,  remove the external entity's ship cmf from the external entity's parent subproject's collection of cmf numbers
            UPDATE the SUBPROJECT'S IMPACT NUMBERS field only if
                - an external entity of type 'IMPACT PROJECT' of that SUBPROJECT is recently inserted/updated/deleted
                    - if inserted, add the external entity's impact project number to the external entity's parent subproject's collection of impact numbers
                    - if updated,  same as above
                    - if deleted,  remove the external entity's impact project number from the external entity's parent subproject's collection of impact numbers
            UPDATE the PROJECT'S CMF NUMBERS field only if
                - an external entity of type 'CMF' of one of its SUBPROJECTS is recently inserted/updated/deleted
                    - if inserted, add the external entity's ship cmf to the external entity's grandparent project's collection of cmf numbers
                    - if updated,  same as above
                    - if deleted,  remove the external entity's ship cmf from the external entity's grandparent project's collection of cmf numbers
            NO IMPACT NUMBERS TO UPDATE FOR PROJECT
        */
        
        // -------------------------------------------------
        /*
            From a custom setting, get all the entity types that needs to get fetched
            As of 1/7/2015, only the below entity types are included in the custom setting:
                - CMF
                - IMPACT NUMBERS
        */
        Map<String, IMP_ProjectLinksUrls__c> entityTypesToFetch = new Map<String, IMP_ProjectLinksUrls__c>();
        for (IMP_ProjectLinksUrls__c entityType : IMP_ProjectLinksUrls__c.getAll().values()) {
            if (entityType.HasFieldonProject__c || entityType.HasFieldonSubproject__c) {
                entityTypesToFetch.put(entityType.Name, entityType);
            }
        }

        // -------------------------------------------------
        /*
            In this part, we prepare 4 things:
                1) insertedOrUpdatedEntitiesList - This will contain all the entities involved when this trigger was invoked. 
                                                 - If the DML subcontext is INSERT OR UPDATE, this will contain the Trigger.New values
                2) deletedEntitiesList - If the DML subcontext is DELETE, this will contain the Trigger.Old values
                3) projectIdsSet - This will contain a unique collection of all the project IDs of all the involved entities when this trigger was invoked.
                4) removedEntitiesIdSet - This will contain a unique collection of all the entity IDs involved when this trigger was invoked.
                                        - Usage will be explained in the next part.
        */
        
        List<SubProject_External_Related_Entity__c> insertedOrUpdatedEntitiesList = new List<SubProject_External_Related_Entity__c>();
        List<SubProject_External_Related_Entity__c> deletedEntitiesList = new List<SubProject_External_Related_Entity__c>();
        Set<Id> projectIdsSet = new Set<Id>();
        //Set<Id> projectIdsOfInsertedOrUpdatedSperesSet = new Set<Id>();
        //Set<Id> projectIdsOfDeletedSperesSet = new Set<Id>();
        Set<Id> subProjectIdsOfInsertedOrUpdatedSperesSet = new Set<Id>();
        Set<Id> subProjectIdsOfDeletedSperesSet = new Set<Id>();
        
        Set<Id> removedEntitiesIdSet = new Set<Id>();
        Set<Id> updatedCMFsSet = new Set<Id>();
        Map<Id, Set<String>> oldSubProjectIdsOfReparentedSperesMap = new Map<Id, Set<String>>();

        if (Trigger.isDelete)
        {
            deletedEntitiesList = Trigger.Old;
        }
        else
        {
            insertedOrUpdatedEntitiesList = Trigger.New;
        }

        for (SubProject_External_Related_Entity__c entity : insertedOrUpdatedEntitiesList)
        {
            //projectIdsOfInsertedOrUpdatedSperesSet.add(entity.Project__c);
            subProjectIdsOfInsertedOrUpdatedSperesSet.add(entity.Subproject__c);
            if (entity.Entity_Type__c == 'CMF')
            {
                updatedCMFsSet.add(entity.Id);
                if (Trigger.isUpdate && Trigger.oldMap.get(entity.Id).SubProject__c != entity.SubProject__c)
                {
                    if (oldSubProjectIdsOfReparentedSperesMap.containsKey(Trigger.oldMap.get(entity.Id).SubProject__c))
                    {
                        oldSubProjectIdsOfReparentedSperesMap.get(Trigger.oldMap.get(entity.Id).SubProject__c).add(entity.Entity_Number__c);
                    }
                    else
                    {
                        oldSubProjectIdsOfReparentedSperesMap.put(Trigger.oldMap.get(entity.Id).SubProject__c, new Set<String> { entity.Entity_Number__c });
                    }
                }
            }
        }

        for (SubProject_External_Related_Entity__c entity : deletedEntitiesList) {
            //projectIdsOfDeletedSperesSet.add(entity.Project__c);
            subProjectIdsOfDeletedSperesSet.add(entity.SubProject__c);
            removedEntitiesIdSet.add(entity.Id);
        }

       /* if (!projectIdsOfInsertedOrUpdatedSperesSet.isEmpty())
        {
            projectIdsSet.addAll(projectIdsOfInsertedOrUpdatedSperesSet);
        } */

       /* if (!projectIdsOfDeletedSperesSet.isEmpty())
        {
            projectIdsSet.addAll(projectIdsOfDeletedSperesSet);
        }*/
        if (!subProjectIdsOfInsertedOrUpdatedSperesSet.isEmpty())
        {
            projectIdsSet.addAll(subProjectIdsOfInsertedOrUpdatedSperesSet);
        } 

        if (!subProjectIdsOfDeletedSperesSet.isEmpty())
        {
            projectIdsSet.addAll(subProjectIdsOfDeletedSperesSet);
        }

        ////List<String> stringList = new List<String>( entityTypesToFetch.keySet() );

        ////Map<String, List<String>> fieldValueMap = new Map<String, List<String>>();
        ////fieldValueMap.put('Entity_Type__c', stringList);

        //List<SubProject_External_Related_Entity__c> entitiesOfParentProjectList2 = IMP_Project_Utility.retrieveExternalRelatedEntityBySet(
        //    IMP_Project_Utility.Enum_RetrieveExternalRelatedEntityBySetsOf.PROJECTS, 
        //    projectIdsSet, 
        //    new Map<String, List<String>> { 
        //        'Entity_Type__c' => new List<String>( entityTypesToFetch.keySet() ) 
        //    }
        //);
        
        // will fetch INSERTED/UPDATED values
        // updated by Sam on 2015-11-19 to change predicate to find all Project__c IN :projectIdsSet
        List<SubProject_External_Related_Entity__c> entitiesOfParentProjectList = [SELECT Id,
                                                                                          Entity_Number__c,
                                                                                          Entity_Type__c,
                                                                                          SubProject__c,
                                                                                          //Project__c,
                                                                                          SubProject__r.Business_Unit_Changed__c,
                                                                                          SubProject__r.SubProject_Region__c,
                                                                                          //Project__r.Business_Unit_Changed__c,
                                                                                          //Project__r.Project_Region__c,
                                                                                          Business_Unit__c
                                                                                     FROM SubProject_External_Related_Entity__c
                                                                                    WHERE Entity_Type__c IN :entityTypesToFetch.keySet()
                                                                                      AND SubProject__c IN :projectIdsSet
                                                                                      ];
                                                                                       // :projectIdsOfInsertedOrUpdatedSperesSet

        if (Trigger.isDelete && !deletedEntitiesList.isEmpty()) {
            entitiesOfParentProjectList.addAll(deletedEntitiesList);
        }

        // Explanation of the inclusion of deleted entities in the list of entities to process ( => entitiesOfParentProjectList.addAll(deletedEntitiesList) )
        /*
            Everytime an entity/ies invoke/s this trigger, the entity field of the project and subproject gets refreshed by recreating its content.
            The recreation process is like this:
             - Loop through all the entities of 'entitiesOfParentProjectList'
             - Per each entity type in the list, keep a delimited string of all its entity numbers
            However, if there is only 1 entity under a subproject, and that entity's deletion eventually invokes this trigger, the 'entitiesOfParentProjectList' will 
            contain nothing (remember, we are in the AFTER-DELETE subcontext, all entities for deletion are already deleted at this stage).
            Without a list containing the project/subproject IDs, the update process will not be able to continue, leaving the project/subproject's entity field unrefreshed/unrecreated.
        */

        // Explanation of usage of 'removedEntitiesIdSet'
        /*
            Continuing from the context of the above explanation, since the deleted entities will get evaluated in the loop, there should be a reference to confirm an entity 'to delete'
            prior to including an entry in the map with BLANK value for the Entity_Number__c field. The 'removedEntitiesIdSet' will be that lookup reference.
        */
        IMP_MaintainObjectFields_Handler.updateFields(removedEntitiesIdSet, entitiesOfParentProjectList, null, entityTypesToFetch, updatedCMFsSet);


        // 2015-08-08: added by Sam
        // This step of explicitly stamping values to the Subproject__c.CMF_Numbers__c is NECESSARY for scenarios wherein the reparenting of a SITE will migrate ALL remaining SPERE-CMFS of a subproject.
        // If a SPERE reparenting will not remove ALL REMAINING SPERE-CMFS (most likely scenario is that there is still 1 SITE left after the reparenting), then this code block is not needed.
        List<SubProject__c> subProjectsToUpdate = [SELECT Id, CMF_Numbers__c FROM SubProject__c WHERE Id IN :oldSubProjectIdsOfReparentedSperesMap.keySet()];
        for (SubProject__c subProject : subProjectsToUpdate) 
        {
            Set<String> cmfsToRemoveSet = oldSubProjectIdsOfReparentedSperesMap.get(subProject.Id);
            List<String> currentCmfsList = IMP_Project_Utility.parseDelimitedString(subProject.CMF_Numbers__c, ',', true);
            List<String> remainingCmfsToStampBackList = new List<String>();
            for (String currentCmf : currentCmfsList) 
            {
                String currentCmfTrimmed = currentCmf.trim();
                if (!cmfsToRemoveSet.contains(currentCmfTrimmed))
                {
                    remainingCmfsToStampBackList.add(currentCmfTrimmed);
                }
            }
            subProject.CMF_Numbers__c = String.join(remainingCmfsToStampBackList, ',');
        }
        update subProjectsToUpdate;

    
    
        /* Updating Contract Numbers - Start */
        
        
        if(Trigger.isInsert)
        {
            map<string, IMPDS_SpereToDealState__c> validEntityTypesToDStateMap = new map<string, IMPDS_SpereToDealState__c>(); 
            if(IMPDS_SpereToDealState__c.getAll()!=null)
            {
                validEntityTypesToDStateMap = IMPDS_SpereToDealState__c.getAll();
            }
            List<SubProject_External_Related_Entity__c> entityToDealStateList = [SELECT Id, Entity_Number__c,
                                                                                         Entity_Type__c,                                                                                          
                                                                                         SubProject__r.Deal_id__c
                                                                                    FROM SubProject_External_Related_Entity__c
                                                                                   WHERE Entity_Type__c IN:validEntityTypesToDStateMap.keySet() AND 
                                                                                         ID IN :Trigger.NewMap.keyset()];
            Set<Id> subProjectIdList = new Set<Id>();
            
            
            //Map<String, set<string>> eTypeToNumbersMap = new Map<String, set<string>>(); // Map<DealId, Contract number>
            map<string, map<string, set<string>>> dealIdToEntityMap = new map<String, map<string, set<string>>>();
            String tempString = '';
            
            //get related subproject to be updated
            for(SubProject_External_Related_Entity__c entity : entityToDealStateList)
            {
                if(validEntityTypesToDStateMap.containsKey(entity.Entity_Type__c))
                {
                    tempString = entity.SubProject__r.Deal_id__c;
                    if(tempString != null && tempString != '')
                    {
                        if(tempString.contains(';'))
                        {
                            for(String str : tempString.split(';'))
                            {
                                map<string, set<string>> eTypeToNumbersMap = dealIdToEntityMap.containsKey(str) ? dealIdToEntityMap.get(str) : new map<string, set<string>>();
                                set<string> entNumberSet = eTypeToNumbersMap.containsKey(entity.Entity_Type__c) ? eTypeToNumbersMap.get(entity.Entity_Type__c) : new set<string>();
                                entNumberSet.add(entity.Entity_Number__c);
                                eTypeToNumbersMap.put(entity.Entity_Type__c, entNumberSet);
                                dealIdToEntityMap.put(str, eTypeToNumbersMap);
                            }
                        }
                        else
                        {
                            map<string, set<string>> eTypeToNumbersMap = dealIdToEntityMap.containsKey(tempString) ? dealIdToEntityMap.get(tempString) : new map<string, set<string>>();
                            set<string> entNumberSet = eTypeToNumbersMap.containsKey(entity.Entity_Type__c) ? eTypeToNumbersMap.get(entity.Entity_Type__c) : new set<string>();
                            entNumberSet.add(entity.Entity_Number__c);
                            eTypeToNumbersMap.put(entity.Entity_Type__c, entNumberSet);
                            dealIdToEntityMap.put(tempString, eTypeToNumbersMap);
                        }
                    }
                    
                }
                //system.debug('-------dealContractMap inside loop----------'+dealContractMap);
            }
            //system.Debug('**tempString: '+ tempString);
            system.Debug('**dealIdToEntityMap: '+ dealIdToEntityMap);
                     
            //update entity numbers 
            if(!dealIdToEntityMap.isEmpty()){
                
                IMP_UpdateEntityNumsOnDealState_Handler.updateEntityNumbers(dealIdToEntityMap);
            }
            
            
        }

        /* Updating Contract Numbers - End */
        // ==================================================================================================
        // OLD LOGIC

        //if(Trigger.isInsert){
        //    //get all the newly created Related External Entity  with entity type Impact Number or CMF
        //    //these values will be stamped on the subproject to capture the impact number and cmf field values
        //    //List<SubProject_External_Related_Entity__c> impactEntityList = [SELECT Id,
        //    //                                                                Entity_Number__c,
        //    //                                                                SubProject__c,
        //    //                                                                Project__c
        //    //                                                                FROM SubProject_External_Related_Entity__c
        //    //                                                                WHERE (Entity_Type__c = 'Impact Project'
        //    //                                                                       OR Entity_Type__c = 'CMF')
        //    //                                                                AND Id IN : Trigger.New];

        //    Set<Id> subProjectIdList = new Set<Id>();
        //    //get related subproject to be updated
        //    //for(SubProject_External_Related_Entity__c entity : impactEntityList){
        //    //    subProjectIdList.add(entity.SubProject__c);
        //    //}

        //    for (SubProject_External_Related_Entity__c entity : Trigger.New) {
        //        if (entityTypesToFetch.contains(entity.Entity_Type__c)) {
        //            subProjectIdList.add(entity.SubProject__c);
        //        }
        //    }

        //    //update SubProject Impact Number and CMF Fields
        //    IMP_MaintainObjectFields_Handler.updateFields(subProjectIdList);
            
        //}

        //if(Trigger.isUpdate || Trigger.isDelete){

        //    Set<Id> subProjectIdList = new Set<Id>();
        //    //get all the updated Related External Entity  with entity type Impact Number or CMF
        //    //these values will be stamped on the subproject to capture the impact number and cmf field values
        //    //for(SubProject_External_Related_Entity__c entity : Trigger.Old){
        //    //    subProjectIdList.add(entity.SubProject__c);
        //    //}

        //    for (SubProject_External_Related_Entity__c entity : Trigger.Old) {
        //        if (entityTypesToFetch.contains(entity.Entity_Type__c)) {
        //            subProjectIdList.add(entity.SubProject__c);
        //        }
        //    }

        //    //update SubProject Impact Number and CMF Fields
        //    IMP_MaintainObjectFields_Handler.updateFields(subProjectIdList);
            
        //}

        // ==================================================================================================
        
    }
    
    
    
    
}