/*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Provides a centralized service to maintain values on targeted object fields.  At the moment, the primarily client of this service is the
             IMP_SubProjectExternalRelatedEntity trigger, which calls this handler to update one or more 'entity number fields' of the related subproject
             In advance, the handler knows little about the target object(s), or values that it'll process and apply - it dynamically receives its
             requirements for processing entity types (including the types and the target objects/fields) from the IMP_ProjectLinksUrls__c custom setting.
             It does know some of the requirements in advance - for example, the need to populate Business Unit on Project and Subproject if a condition is met.
             Future requirements may drive future extensions to maintain fields through existing and future custom settings.
Test Class:  IMP_MaintainObjectFields_Test
History
09/23/14     Kimiko Roberto      Created
10/06/14     Kimiko Roberto      Added same function to CMF numbers
12/23/14     Samuel Oberes       Added project logic and updated subproject logic
01/01/15     Samuel Oberes       Added proper error handling in the update of subprojects and projects
01/05/15     Samuel Oberes       Merged source query for subproject and project
                                 Renamed class from 'IMP_UpdateSubProjectImpactNumber_Handler' to 'IMP_MaintainObjectFields_Handler'
                                 Renamed method from 'updateImpactNumbers' to 'updateFields'
01/13/15     Samuel Oberes       Major refactor of the updateFields method to make it more dynamic. 95% of code was refactored.
01/15/15     Kimiko Roberto      Added functionality to check whether a project or subproject's Business_Unit_Changed = false and
                                 stamps the subproject related entities Business Unit if it is.
01/16/15     Samuel Oberes       Updated the query of Project__c and made it use the more dynamic queryRelatedRecords method instead of hardcoded field names
08/07/15     Samuel Oberes       Updated comments, method brackets, and a bit of refactoring.
12/14/16     Venkata Shrivol	 commented the project object reference RQ-08305
------------------------------------------------------------*/
public class IMP_MaintainObjectFields_Handler 
{
    // The project and subproject contains fields that are being stamped with concatenated values of speres.
    // These fields are re-created everytime a CRUD is invoked on the SPERE.
    public static void updateFields(Set<Id> removedEntitiesIdSet, 
                                    List<SubProject_External_Related_Entity__c> entitiesOfParentProjectList, 
                                    Set<Id> projectIdsSet, 
                                    Map<String, IMP_ProjectLinksUrls__c> entityTypesToFetch, 
                                    Set<Id> updatedCMFsSet) 
    {
        // -------------------------------------------------------------------------------------------------------------
        // INITIALIZATION 

        // The entityTypeToEntityNumbersMap is a map that contains a key of type String, and a set of strings as its value.
        // The key is the entity type, while the value, the set of strings, are the entity numbers found under that certain entity type.
        // This map is not meant to be used independently. This SHOULD ALWAYS BE USED with subProjectIdToEntityMap OR projectIdToEntityMap.
        Map<String, Set<String>> entityTypeToEntityNumbersMap = new Map<String, Set<String>>();

        // The subProjectIdToEntityMap is a map that contains a key of type Id, and its value is a map. To be specific, 'entityTypeToEntityNumbersMap' should be used for inserting the value for this map.
        // The key is a subproject ID, and the value, which is an instance of 'entityTypeToEntityNumbersMap', will contain a key-value pair of 'entity type'-'entity number', wherein the pair is contained in that subproject
        Map<Id, Map<String, Set<String>>> subProjectIdToEntityMap = new Map<Id, Map<String, Set<String>>>(); 

        // The projectIdToEntityMap is a map that contains a key of type Id, and its value is a map. To be specific, 'entityTypeToEntityNumbersMap' should be used for inserting the value for this map.
        // The key is a project ID, and the value, which is an instance of 'entityTypeToEntityNumbersMap', will contain a key-value pair of 'entity type'-'entity number', wherein the pair is contained in that subproject
        Map<Id, Map<String, Set<String>>> projectIdToEntityMap = new Map<Id, Map<String, Set<String>>>();

        // The temporaryHolderOfEntityNumbersSet is a set that contains strings, and those strings are entity numbers.
        // This set is not meant to be used independently. This SHOULD ALWAYS BE USED with entityTypeToEntityNumbersMap.
        Set<String> temporaryHolderOfEntityNumbersSet = new Set<String>();

        // The subProjectIdsSet is a set of Ids of all the subprojects of all the entities. This will later on be used as a parameter in the query for the delimitation process of subproject.
        Set<Id> subProjectIdsSet = new Set<Id>();

        Map<Id, String> subProjectBusinessUnit = new Map<Id, String>();
        Map<Id, String> projectBusinessUnit = new Map<Id, String>();

        // -------------------------------------------------------------------------------------------------------------
        // SEGREGATION PROCESS

        // The entitiesOfParentProjectList contains the newly inserted/updated/deleted speres, including their siblings. All of them are grandchildren of only 1 grandparent Project (SubProject_External_Related_Entity__c.Project__c).
        // We are looping through all of these entities for us to be able to group the entity numbers by entity type by subproject/project.
        // The objective is to re-create the contents of the SPERE fields on the project and subproject (ex. CMF_Numbers__c, etc.). After the grouping, the re-creation/stamping of the new values begins.
        // NOTE: If the context is AFTER-DELETE, the list will contain extra records (it will contain those deleted entities, because the loop must go through them in order to properly populate(or clear) the field where they appear)
        
        for(SubProject_External_Related_Entity__c entity : entitiesOfParentProjectList) 
        {
            // --------------------------------
            // SUBPROJECT related grouping
            
            // Check SubProject's Business_Unit_Changed__c checkbox and collect those SubProject's with false values
            // Later on this will be used for the stamping of Business Unit from SPERE to SubProject.
            if(!entity.SubProject__r.Business_Unit_Changed__c && updatedCMFsSet.contains(entity.Id))
            {
                //if(!subProjectBusinessUnit.containsKey(entity.SubProject__c)){
                    subProjectBusinessUnit.put(entity.SubProject__c,entity.Business_Unit__c);
                //}
            }
            
            // for the current entity at hand ('entity' variable), basing on its type (entity.Entity_Type__c), does the subproject it is associated with (entity.SubProject__c) have a field for it to be stamped on to (HasFieldonSubproject__c)?
            if (entityTypesToFetch.containsKey(entity.Entity_Type__c) && entityTypesToFetch.get(entity.Entity_Type__c).HasFieldonSubproject__c) 
            {
                // When you reach this part, it means that the current entity's name (entity.Entity_Number__c) must be stamped/appended to a designated 
                // field (the fieldname depending on the entity type is found here -> entityTypesToFetch.SubProjectFieldName__c) on the subproject.
                
                // From here, we can already stamp the respective subproject fields, but we have to think of a bulkified approach, just in case there are multiple subprojects in play.
                // We then build the subProjectIdToEntityMap. You can think of this map as:
                //     SUBPROJECT -< ENTITY TYPE -< ENTITY NUMBER
                // In short, each subproject has unique entity types, and each entity type has unique entity numbers.

                if (subProjectIdToEntityMap.containsKey(entity.SubProject__c)) 
                {
                    entityTypeToEntityNumbersMap = subProjectIdToEntityMap.get(entity.SubProject__c);
                    if (entityTypeToEntityNumbersMap.containsKey(entity.Entity_Type__c)) 
                    {
                        temporaryHolderOfEntityNumbersSet = entityTypeToEntityNumbersMap.get(entity.Entity_Type__c);
                        if ( IMP_MaintainObjectFields_Handler.isEntityDeleted(removedEntitiesIdSet, entity.Id) == false ) 
                        {
                            temporaryHolderOfEntityNumbersSet.add(entity.Entity_Number__c);
                        }
                        Map<String, Set<String>> temporaryHolderOfEntitiesMap = subProjectIdToEntityMap.get(entity.SubProject__c);
                        temporaryHolderOfEntitiesMap.put(entity.Entity_Type__c, temporaryHolderOfEntityNumbersSet);
                        subProjectIdToEntityMap.put(entity.SubProject__c, temporaryHolderOfEntitiesMap);
                    } 
                    else 
                    {
                        Map<String, Set<String>> temporaryHolderOfEntitiesMap = subProjectIdToEntityMap.get(entity.SubProject__c);
                        subProjectIdToEntityMap.putAll( IMP_MaintainObjectFields_Handler.getIdToEntityMap(temporaryHolderOfEntitiesMap, entity, removedEntitiesIdSet, true) );
                    }
                } 
                else 
                {
                    Map<String, Set<String>> temporaryHolderOfEntitiesMap = new Map<String, Set<String>>();
                    subProjectIdToEntityMap.putAll( IMP_MaintainObjectFields_Handler.getIdToEntityMap(temporaryHolderOfEntitiesMap, entity, removedEntitiesIdSet, true) );
                }
            }

            // --------------------------------
            // PROJECT related grouping
            
            // Check Project's Business_Unit_Changed__c checkbox and collect those Project's with false values
            // Later on this will be used for the stamping of Business Unit from SPERE to Project.
           /* if(!entity.Project__r.Business_Unit_Changed__c && updatedCMFsSet.contains(entity.Id))
            {
                //if(!projectBusinessUnit.containsKey(entity.Project__c)){
                    projectBusinessUnit.put(entity.Project__c,entity.Business_Unit__c);
                //}
            }

            if (entityTypesToFetch.containsKey(entity.Entity_Type__c) && entityTypesToFetch.get(entity.Entity_Type__c).HasFieldonProject__c) 
            {
                if (projectIdToEntityMap.containsKey(entity.Project__c)) 
                {
                    entityTypeToEntityNumbersMap = projectIdToEntityMap.get(entity.Project__c);
                    if (entityTypeToEntityNumbersMap.containsKey(entity.Entity_Type__c)) 
                    {
                        temporaryHolderOfEntityNumbersSet = entityTypeToEntityNumbersMap.get(entity.Entity_Type__c);

                        if ( IMP_MaintainObjectFields_Handler.isEntityDeleted(removedEntitiesIdSet, entity.Id) == false ) 
                        {
                            temporaryHolderOfEntityNumbersSet.add(entity.Entity_Number__c);
                        }
                        Map<String, Set<String>> temporaryHolderOfEntitiesMap = projectIdToEntityMap.get(entity.Project__c);
                        temporaryHolderOfEntitiesMap.put(entity.Entity_Type__c, temporaryHolderOfEntityNumbersSet);
                        projectIdToEntityMap.put(entity.Project__c, temporaryHolderOfEntitiesMap);
                    } 
                    else 
                    {
                        Map<String, Set<String>> temporaryHolderOfEntitiesMap = projectIdToEntityMap.get(entity.Project__c);
                        projectIdToEntityMap.putAll( IMP_MaintainObjectFields_Handler.getIdToEntityMap(temporaryHolderOfEntitiesMap, entity, removedEntitiesIdSet, false) );
                    }
                } 
                else 
                {
                    Map<String, Set<String>> temporaryHolderOfEntitiesMap = new Map<String, Set<String>>();
                    projectIdToEntityMap.putAll( IMP_MaintainObjectFields_Handler.getIdToEntityMap(temporaryHolderOfEntitiesMap, entity, removedEntitiesIdSet, false) );
                }
            }*/

            subProjectIdsSet.add(entity.SubProject__c);
        }
        
        // -------------------------------------------------------------------------------------------------------------
        // DELIMITATION PROCESS: SUBPROJECT: CONVERTING THE SUBPROJECT ENTITIES LIST INTO A COMMA-DELIMITED STRING

        Map<Id, SubProject__c> subProjectToUpdateMap = new Map<Id, SubProject__c>();
        List<Id> subProjectIdsList = new List<Id>();
        String concatenatedEntities;
        List<String> entityNumbersList;
        for (SObject subProject : IMP_Project_Utility.queryRelatedRecords(SObjectType.SubProject__c.FieldSets.SubProject_Commons.getFields(), 
                                                                          IMP_Project_Utility.OBJECT_NAME_SUBPROJECT, 
                                                                          IMP_Project_Utility.QUERY_NAME_ID, 
                                                                          null, 
                                                                          subProjectIdsSet, 
                                                                          null, 
                                                                          null, 
                                                                          false, 
                                                                          0)) 
        {    
            // Populate 'entityTypeToEntityNumbersMap' with the map of 'entity type'-'entity number' pairs under the currently selected subproject
            entityTypeToEntityNumbersMap = subProjectIdToEntityMap.get((Id)subProject.get('Id'));

            // Loop through the set of entity type names. These were the same names used as the criteria for fetching the entities.
            for (String entityType : entityTypesToFetch.keySet()) 
            {
                // If the entity type is found in 'entityTypeToEntityNumbersMap', it means that the subproject currently being evaluated contains that entity type.
                if (entityTypeToEntityNumbersMap != null && entityTypeToEntityNumbersMap.containsKey(entityType)) 
                {
                    // Get that entity type and convert its set of entity numbers into a comma-delimited string.
                    entityNumbersList = new List<String>(entityTypeToEntityNumbersMap.get(entityType));
                    entityNumbersList.sort();
                    concatenatedEntities = String.join(entityNumbersList, ', ');

                    // Get the proper field name where the entity values should reside inside the subproject object. You can find that inside the SubProjectFieldName__c field of the custom setting.
                    // Pass the freshly created string as the value of the entity type field of the subproject.
                    subProject.put(entityTypesToFetch.get(entityType).SubProjectFieldName__c, concatenatedEntities);

                    // Check if entity type is CMF and update the SubProject's business unit based on the mapped values
                    // Please note: Business Unit has recently become a required field, and this code to stamp it through the SPERE
                    // trigger might become retired.
                    if(entityType == 'CMF')
                    {
                        if(subProjectBusinessUnit.containsKey((Id)subProject.get('Id')))
                        {
                            subProject.put('SubProject_Region__c', subProjectBusinessUnit.get((Id)subProject.get('Id')));
                        }           
                    }
                }

                // Populate the subProjectToUpdateMap. The map's value are the subprojects that we would send to the update DML later on.
                subProjectToUpdateMap.put((Id)subProject.get('Id'), (SubProject__c)subProject);

                // IMPORTANT: Do not just convert the set of subproject IDs into a list. The order of IDs inserted as key in the subProjectToUpdateMap must be of the same order as below. 
                //            Not doing so will have an impact in the error reporting.
                subProjectIdsList.add((Id)subProject.get('Id'));
            }
        }

        // -------------------------------------------------------------------------------------------------------------
        // SUBPROJECT UPDATE PROCESS

        // This is nothing but an update DML. The only reason it looks this complicated is because we wanted to catch hidden errors being fired from the subproject object from validation errors.
        if(!subProjectToUpdateMap.isEmpty())
        {
            Map<Id, String> subprojectToErrorMessageMap = new Map<Id, String>();
            String errorMessage = '';
            List<Database.SaveResult> dsrs = Database.Update(subProjectToUpdateMap.values(), false);
            for(Integer saveResultsIndex = 0; saveResultsIndex < dsrs.size(); saveResultsIndex++)
            {
                Database.SaveResult dsr = dsrs[saveResultsIndex];            
                if(!dsr.isSuccess())
                {
                    if (dsr.getErrors().size() > 1) 
                    {
                        for (Database.Error err : dsr.getErrors()) 
                        {
                            errorMessage = 'ERROR: \n' + 
                                           '   - Affected field(s): ' + err.getFields() + '\n' +
                                           '   - Status Code:       ' + err.getStatusCode() + '\n' +
                                           '   - Message:           ' + err.getMessage() + '\n';
                        }
                        errorMessage = errorMessage.substring(0, errorMessage.length() - 1);
                    } 
                    else 
                    {
                        errorMessage = 'ERROR: \n' + 
                                       '   - Affected field(s): ' + dsr.getErrors()[0].getFields() + '\n' +
                                       '   - Status Code:       ' + dsr.getErrors()[0].getStatusCode() + '\n' +
                                       '   - Message:           ' + dsr.getErrors()[0].getMessage();
                    }
                    subprojectToErrorMessageMap.put(subProjectIdsList[saveResultsIndex], errorMessage);
                }
            }
            if (!subprojectToErrorMessageMap.isEmpty()) 
            {
                for (Id subProjectId : subprojectToErrorMessageMap.keySet()) 
                {
                    //SubProject__c sp = subProjectToUpdateMap.get(subProjectId);
                    //sp.addError(subprojectToErrorMessageMap.get(subProjectId));
                    System.debug('DBG: SUBPROJECT ERROR(S): \n' + subprojectToErrorMessageMap.get(subProjectId));
                }
            }
        }

        // -------------------------------------------------------------------------------------------------------------
        // DELIMITATION PROCESS: PROJECT: CONVERTING THE PROJECT ENTITIES LIST INTO A COMMA-DELIMITED STRING

       /* Map<Id, Project__c> projectToUpdateMap = new Map<Id, Project__c>();
        List<Id> projectIdsList = new List<Id>();
        //String concatenatedEntities;
        //List<String> entityNumbersList;
        for (SObject project : IMP_Project_Utility.queryRelatedRecords(SObjectType.Project__c.FieldSets.Project_Commons.getFields(), 
                                                                       IMP_Project_Utility.OBJECT_NAME_PROJECT, 
                                                                       IMP_Project_Utility.QUERY_NAME_ID, 
                                                                       null, 
                                                                       projectIdsSet, 
                                                                       null, 
                                                                       null, 
                                                                       false, 
                                                                       0)) 
        {
            // Populate 'entityTypeToEntityNumbersMap' with the map of 'entity type'-'entity number' pairs under the currently selected project
            entityTypeToEntityNumbersMap = projectIdToEntityMap.get((Id)project.get('Id'));

            // Loop through the set of entity type names. These were the same names used as the criteria for fetching the entities.
            for (String entityType : entityTypesToFetch.keySet()) 
            {
                // If the entity type is found in 'entityTypeToEntityNumbersMap', it means that the project currently being evaluated contains that entity type.
                if (entityTypeToEntityNumbersMap != null && entityTypeToEntityNumbersMap.containsKey(entityType)) 
                {
                    // Get that entity type and convert its set of entity numbers into a comma-delimited string.
                    entityNumbersList = new List<String>(entityTypeToEntityNumbersMap.get(entityType));
                    entityNumbersList.sort();
                    concatenatedEntities = String.join(entityNumbersList, ',');

                    // Get the proper field name where the entity values should reside inside the project object. You can find that inside the ProjectFieldName__c field of the custom setting.
                    // Pass the freshly created string as the value of the entity type field of the project.
                    project.put(entityTypesToFetch.get(entityType).ProjectFieldName__c, concatenatedEntities);

                    // Check if entity type is CMF and update the Project's business unit based on the mapped values
                    // Please note: Business Unit has recently become a required field, and this code to stamp it through the SPERE
                    // trigger might become retired
                    if(entityType == 'CMF')
                    {
                        if(projectBusinessUnit.containsKey((Id)project.get('Id')))
                        {
                            project.put('Project_Region__c', projectBusinessUnit.get((Id)project.get('Id')));
                        }           
                    }
                }

                // Populate the projectToUpdateMap. The map's value are the projects that we would send to the update DML later on.
                projectToUpdateMap.put((Id)project.get('Id'), (Project__c)project);

                // IMPORTANT: Do not just convert the set of subproject IDs into a list. The order of IDs inserted as key in the projectToUpdateMap must be of the same order as below. 
                //            Not doing so will have an impact in the error reporting.
                projectIdsList.add((Id)project.get('Id'));
            }
        }

        // -------------------------------------------------------------------------------------------------------------
        // PROJECT UPDATE PROCESS

        // This is nothing but an update DML. The only reason it looks this complicated is because we wanted to catch hidden errors being fired from the subproject object from validation errors.
        if(!projectToUpdateMap.isEmpty())
        {
            Map<Id, String> projectToErrorMessageMap = new Map<Id, String>();
            String errorMessage = '';
            List<Database.SaveResult> dsrs = Database.Update(projectToUpdateMap.values(), false);
            for(Integer saveResultsIndex = 0; saveResultsIndex < dsrs.size(); saveResultsIndex++)
            {
                Database.SaveResult dsr = dsrs[saveResultsIndex];            
                if(!dsr.isSuccess())
                {
                    if (dsr.getErrors().size() > 1) 
                    {
                        for (Database.Error err : dsr.getErrors()) 
                        {
                            errorMessage = 'ERROR: \n' + 
                                           '   - Affected field(s): ' + err.getFields() + '\n' +
                                           '   - Status Code:       ' + err.getStatusCode() + '\n' +
                                           '   - Message:           ' + err.getMessage() + '\n';
                        }
                        errorMessage = errorMessage.substring(0, errorMessage.length() - 1);
                    } 
                    else 
                    {
                        errorMessage = 'ERROR: \n' + 
                                       '   - Affected field(s): ' + dsr.getErrors()[0].getFields() + '\n' +
                                       '   - Status Code:       ' + dsr.getErrors()[0].getStatusCode() + '\n' +
                                       '   - Message:           ' + dsr.getErrors()[0].getMessage();
                    }
                    projectToErrorMessageMap.put(projectIdsList[saveResultsIndex], errorMessage);
                }
            }
            if (!projectToErrorMessageMap.isEmpty()) 
            {
                for (Id projectId : projectToErrorMessageMap.keySet()) 
                {
                    //Project__c sp = projectToUpdateMap.get(projectId);
                    //sp.addError(projectToErrorMessageMap.get(projectId));
                    System.debug('DBG: PROJECT ERROR(S): \n' + projectToErrorMessageMap.get(projectId));
                }
            }
        }*/



    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Abstraction of repetitive logic, wherein a Map<Id, Map<String, Set<String>>> is being populated
    History
    01/13/15     Samuel Oberes       Created
    ------------------------------------------------------------*/
    @TestVisible 
    private static Map<Id, Map<String, Set<String>>> getIdToEntityMap (Map<String, Set<String>> temporaryHolderOfEntitiesMap, SubProject_External_Related_Entity__c entity, Set<Id> removedEntitiesIdSet, Boolean isSubProject) 
    {
        Id projectOrSubProjectId;
        Map<Id, Map<String, Set<String>>> idToEntityMap = new Map<Id, Map<String, Set<String>>>();

        if ( IMP_MaintainObjectFields_Handler.isEntityDeleted(removedEntitiesIdSet, entity.Id) ) 
        {
            temporaryHolderOfEntitiesMap.put(entity.Entity_Type__c, new Set<String>());
        } 
        else 
        {
            temporaryHolderOfEntitiesMap.put(entity.Entity_Type__c, new Set<String>{ entity.Entity_Number__c });
        }

        if (isSubProject) 
        {
            projectOrSubProjectId = entity.SubProject__c;
        } 
        /*else 
        {
            projectOrSubProjectId = entity.Project__c;
        }*/
        
        idToEntityMap.put(projectOrSubProjectId, temporaryHolderOfEntitiesMap);

        return idToEntityMap;

    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Abstraction of repetitive logic, wherein an entity is being checked if it's under the deletion context.
    History
    01/13/15     Samuel Oberes       Created
    ------------------------------------------------------------*/
    @TestVisible 
    private static Boolean isEntityDeleted(Set<Id> removedEntitiesIdSet, Id entityId) 
    {
        return (removedEntitiesIdSet != null && removedEntitiesIdSet.contains(entityId));
    }
    
}