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

01/26/15    Venkata Shrivol      Added logic to update the Contract number from SPERE object to Deal State record
------------------------------------------------------------*/
trigger IMP_SubProjectExternalRelatedEntity on SubProject_External_Related_Entity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger.isBefore) {

        // -------------------------------------------------
        // INSERT

        // update the project field via trigger in the backend, rather than allowing the user to manually select the value of the project field while creating a new Project External Related Entity
        if(trigger.isInsert){
            
            Set<Id> subProjectIds = new Set<Id>();
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
            }
        }

        // -------------------------------------------------
        // UPDATE

        Profile userProfile = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        system.Debug('**userProfile: '+userProfile.Name);
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
            In this part, we prepare 3 things:
                1) insertedOrUpdatedOrDeletedEntitiesList - This will contain all the entities involved when this trigger was invoked. 
                                                          - If the DML subcontext is INSERT, this will contain the Trigger.New values
                                                          - If the DML subcontext is UPDATE or DELETE, this will contain the Trigger.Old values
                2) projectIdsSet - This will contain a unique collection of all the project IDs of all the involved entities when this trigger was invoked.
                2) removedEntitiesIdSet - This will contain a unique collection of all the entity IDs involved when this trigger was invoked.
                                        - Usage will be explained in the next part.
        */
        List<SubProject_External_Related_Entity__c> insertedOrUpdatedOrDeletedEntitiesList = new List<SubProject_External_Related_Entity__c>();
        Set<Id> projectIdsSet = new Set<Id>();
        Set<Id> removedEntitiesIdSet = new Set<Id>();

        if (Trigger.isInsert) {
            insertedOrUpdatedOrDeletedEntitiesList = Trigger.New;
        } else {         
            insertedOrUpdatedOrDeletedEntitiesList = Trigger.Old;
        }

        Set<Id> updatedCMFsSet = new Set<Id>();
        for (SubProject_External_Related_Entity__c entity : insertedOrUpdatedOrDeletedEntitiesList) {
            projectIdsSet.add(entity.Project__c);

            if (Trigger.isDelete) {
                removedEntitiesIdSet.add(entity.Id);
            } else {
                if (entity.Entity_Type__c == 'CMF') {
                    updatedCMFsSet.add(entity.Id);
                }
            }
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

        List<SubProject_External_Related_Entity__c> entitiesOfParentProjectList = [SELECT Id,
                                                                                          Entity_Number__c,
                                                                                          Entity_Type__c,
                                                                                          SubProject__c,
                                                                                          Project__c,
                                                                                          SubProject__r.Business_Unit_Changed__c,
                                                                                          SubProject__r.SubProject_Region__c,
                                                                                          Project__r.Business_Unit_Changed__c,
                                                                                          Project__r.Project_Region__c,
                                                                                          Business_Unit__c
                                                                                     FROM SubProject_External_Related_Entity__c
                                                                                    WHERE Entity_Type__c IN :entityTypesToFetch.keySet()
                                                                                      AND Project__c IN :projectIdsSet];

        
        if (Trigger.isDelete) {
            entitiesOfParentProjectList.addAll(insertedOrUpdatedOrDeletedEntitiesList);
        }

        // Explanation of the inclusion of deleted entities in the list of entities to process ( => entitiesOfParentProjectList.addAll(insertedOrUpdatedOrDeletedEntitiesList) )
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
        IMP_MaintainObjectFields_Handler.updateFields(removedEntitiesIdSet, entitiesOfParentProjectList, projectIdsSet, entityTypesToFetch, updatedCMFsSet);

        /* Updating Contract Numbers - Start */
        
        if(Trigger.isInsert)
        {
            List<SubProject_External_Related_Entity__c> contractEntityList = [SELECT Id, Entity_Number__c,
                                                                                         Entity_Type__c,                                                                                          
                                                                                         SubProject__r.Deal_id__c
                                                                                    FROM SubProject_External_Related_Entity__c
                                                                                   WHERE Entity_Type__c = 'Contract' AND 
                                                                                   		 ID IN :Trigger.NewMap.keyset()];
            Set<Id> subProjectIdList = new Set<Id>();
            system.Debug('**contractEntityList: '+contractEntityList);
            
            Map<String,list<string>> dealContractMap = new Map<String,list<string>>(); // Map<DealId, Contract number>
            String tempString = '';
            
            //get related subproject to be updated
            for(SubProject_External_Related_Entity__c entity : contractEntityList)
            {
                if(entity.Entity_Type__c == 'Contract')
                {
                    tempString = entity.SubProject__r.Deal_id__c;
                    if(tempString != null && tempString != '')
                    {
                        if(tempString.contains(';'))
                        {
                            for(String str : tempString.split(';'))
                            {
                                list<string> contNumList = dealContractMap.containsKey(str) ? dealContractMap.get(str) : new list<string>();
                                contNumList.add(entity.Entity_Number__c);
                                dealContractMap.put(str, contNumList);
                            }
                        }
                        else
                        {
                        	list<string> contNumList = dealContractMap.containsKey(entity.SubProject__r.Deal_id__c) ? dealContractMap.get(entity.SubProject__r.Deal_id__c) : new list<string>();
                            contNumList.add(entity.Entity_Number__c);
                            dealContractMap.put(entity.SubProject__r.Deal_id__c , contNumList);
                        }
                    }
                    
                }
                system.debug('-------dealContractMap inside loop----------'+dealContractMap);
            }
            system.Debug('**tempString: '+ tempString);
            system.Debug('**dealContractMap: '+ dealContractMap);
                     
            //update contract numbers 
            if(!dealContractMap.isEmpty()){
            	
    			IMP_UpdateDealStateContractNum_Handler.updateContractNumbers(dealContractMap); 
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