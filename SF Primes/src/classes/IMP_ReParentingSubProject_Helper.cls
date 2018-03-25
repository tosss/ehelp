/*------------------------------------------------------------
Author:Rey Austral
Company: Cloud Sherpas       
Description: Changing the Project__c field value for all Subproject child object 
when the subproject is re-parent with a new project
Test Class: IMP_ReParentingSubProject_Test
History
11/13/14    Rey Austral             Created
01/15/15    Samuel Oberes           Refactored: Made the getSubProjectLog project log type agnostic
                                    Introduced the updateSubProjectChildObject method that caters for all the subproject child objects
10/29/15    Venkata Shrivol			Added a null check for SubProject in  getSubProjectLog method.                                   
------------------------------------------------------------*/
public class IMP_ReParentingSubProject_Helper {
    public static void executeReParent(Map<Id,Subproject__c> subprojectDefinitionAfterUpdate, Map<Id,Subproject__c> subprojectDefinitionBeforeUpdate)
    {
        Set<Id> setSubProjectId = new Set<Id>();
        Set<Id> setProjectIds = new Set<Id>();
        
        //get all ids of subproject and project that will be used in the query for selecting related record
        for(Subproject__c sub : subprojectDefinitionAfterUpdate.values()) {
            setSubProjectId.add(sub.Id);
            Subproject__c oldValue = subprojectDefinitionBeforeUpdate.get(sub.Id);
            setProjectIds.add(oldValue.Project__c);
        }
        
        //get all records that have lookup in subproject and project object in preparation to update the project field
        List<SubProjectOpp__c>                      listToUpdateSubOpp         = (List<SubProjectOpp__c>)                      updateSubProjectChildObject(setSubProjectId, subprojectDefinitionAfterUpdate, 'SubProjectOpp__c');
        List<SubProject_External_Related_Entity__c> listToUpdateSubExRelated   = (List<SubProject_External_Related_Entity__c>) updateSubProjectChildObject(setSubProjectId, subprojectDefinitionAfterUpdate, 'SubProject_External_Related_Entity__c');
        List<SubProject_External_Reference__c>      listToUpdateSubExReference = (List<SubProject_External_Reference__c>)      updateSubProjectChildObject(setSubProjectId, subprojectDefinitionAfterUpdate, 'SubProject_External_Reference__c');
        List<SubProjectSite__c>                     listToUpdateSubSite        = (List<SubProjectSite__c>)                     updateSubProjectChildObject(setSubProjectId, subprojectDefinitionAfterUpdate, 'SubProjectSite__c'); 
        
        //...in continuation of getting all records, we create separate lists for each of the Project log types
        //since each log record has Lookup fields to Subproject for each log type, but only 1 can be populated based upon type;
        //we're looking to match against subproject, and, it'll require 5 separate passes to cover the 5 types

        List<Schema.FieldSetMember> consolidatedFieldSetMembersList = new List<Schema.FieldSetMember>();
        consolidatedFieldSetMembersList.addAll(SObjectType.Project_Log__c.FieldSets.Action_Item_Commons.getFields());
        consolidatedFieldSetMembersList.addAll(SObjectType.Project_Log__c.FieldSets.Change_Request_Commons.getFields());
        consolidatedFieldSetMembersList.addAll(SObjectType.Project_Log__c.FieldSets.Issue_Commons.getFields());
        consolidatedFieldSetMembersList.addAll(SObjectType.Project_Log__c.FieldSets.Lesson_Learned_Commons.getFields());
        consolidatedFieldSetMembersList.addAll(SObjectType.Project_Log__c.FieldSets.Risk_Commons.getFields());

        Set<String> fieldSetMembersFieldPathSet = new Set<String>();
        List<Schema.FieldSetMember> distinctFieldSetMembers = new List<Schema.FieldSetMember>();
        
        for(Schema.FieldSetMember fieldSetMember : consolidatedFieldSetMembersList){
            if (!fieldSetMembersFieldPathSet.contains(fieldSetMember.getFieldPath())) {
                distinctFieldSetMembers.add(fieldSetMember);
                fieldSetMembersFieldPathSet.add(fieldSetMember.getFieldPath());
            }
        }

        // NOTE:
        //   - The last parameter ('SubProject_Id__c') is the ID to be used in checking for equality against the first parameter (setSubProjectId) in the predicate evaluation.
        //   - The last parameter is a field that contains an ID coming from 1 of the ff. if they are not null: 
        //     - 'Sub_Project_Action_Items__c'
        //     - 'Sub_Project_Change_Request__c'
        //     - 'Sub_Project_Issue__c'
        //     - 'Sub_Project_Lessons_Learned__c'
        //     - 'Sub_Project_Risk__c'

        List<Project_Log__c> projectLogsToUpdateList = getSubProjectLog(setSubProjectId, subprojectDefinitionAfterUpdate, distinctFieldSetMembers, 'SubProject_Id__c');
        
        //get projects that will be empty when its last subproject has ben moved in preparation to close it    
        List<Project__c> listToUpdateProject = getProjectsToClose(setProjectIds);     
        
        if(!listToUpdateSubOpp.isEmpty())
        {
            update listToUpdateSubOpp;
        }
        
        if(!listToUpdateSubExRelated.isEmpty())
        {
            update listToUpdateSubExRelated; 
        }
        
        if(!listToUpdateSubExReference.isEmpty())
        {
            update listToUpdateSubExReference; 
        }
        
        if(!listToUpdateSubSite.isEmpty())
        {
            update listToUpdateSubSite;
        }

        if (!projectLogsToUpdateList.isEmpty()) {
            update projectLogsToUpdateList;
        }
        
        if(!listToUpdateProject.isEmpty())
        {           
            update listToUpdateProject;
        }
    }
    
    private static List<SObject> updateSubProjectChildObject(Set<Id> subProjectIdsSet, Map<Id,Subproject__c> subProject, String subProjectChildObject) {

        List<FieldSetMember> fieldsList;

        if (subProjectChildObject == 'SubProjectOpp__c') {
            fieldsList = SObjectType.SubProjectOpp__c.FieldSets.SubProject_Opp_Commons.getFields();
        } else if (subProjectChildObject == 'SubProject_External_Related_Entity__c') {
            fieldsList = SObjectType.SubProject_External_Related_Entity__c.FieldSets.External_Related_Entity_Commons.getFields();
        } else if (subProjectChildObject == 'SubProject_External_Reference__c') {
            fieldsList = SObjectType.SubProject_External_Reference__c.FieldSets.External_Reference_Commons.getFields();
        } else { // SubProjectSite__c
            fieldsList = SObjectType.SubProjectSite__c.FieldSets.SubProject_Site_Common.getFields();
        }

        //get all subproject child objects 
        List<SObject> objectList = IMP_Project_Utility.queryRelatedRecords(
            fieldsList, 
            subProjectChildObject, 
            'SubProject__c', 
            null, 
            subProjectIdsSet, 
            null, 
            null, 
            true, 
            1000
        );         
        
        //change the value of the child object's project id to the new project id
        Subproject__c subProj;
        for (SObject obj : objectList) {
            subProj = subProject.get((Id)obj.get('SubProject__c'));
            obj.put('Project__c', subProj.Project__c);
        } 
        return objectList;
    }

    private static List<Project_Log__c> getSubProjectLog(Set<Id> subProjectIdsSet, Map<Id,Subproject__c> subProject, List<Schema.FieldSetMember> listFieldSetMembers, String subprojectField) {

        // NOTE: DO NOT PASS A SET OF IDs TO THE QUERY BELOW, BECAUSE THE SET OF IDs WILL ALWAYS CONTAIN 18-DIGIT IDs
        //       INSTEAD, PASS A LIST OF STRINGS, WHEREIN THE STRINGS ARE ALREADY TRIMMED 15-CHARACTER STRING IDs.
        List<String> subProjectIdsList = new List<String>();
        for (Id id : subProjectIdsSet) {
            subProjectIdsList.add( String.valueOf(id).substring(0, 15) );
        }

        List<Project_Log__c> projectLogsList = (List<Project_Log__c>)IMP_Project_Utility.queryRelatedRecords(listFieldSetMembers, 'Project_Log__c', subprojectField, null, null, subProjectIdsList, null, true, 1000);

        //change the value of project to the new project id
        Subproject__c subProj;
        String projectLogType;
        for (SObject projectLog : projectLogsList) {

            projectLogType = (String)projectLog.get('Lookup_Field_API_Name_to_Subproject__c');

            subProj = subProject.get( (Id)projectLog.get( 'Sub_Project_' + projectLogType ) );
            
            //Added this check because projectLogsList is retrieving the irrelevant project log records 
            //by matching first 15-digit string of subProjectID 
            if(subProj!=null)
            {
            	projectLog.put( 'Project_' + projectLogType , subProj.Project__c);	
            }
        }    
        
        return projectLogsList;
    }
    
    private static List<Project__c> getProjectsToClose(Set<Id> setProjectIds) 
    {
        //retrieve all subprojects of the source project
        List<SubProject__c> listSubProjects =  (List<SubProject__c>)IMP_Project_Utility.queryRelatedRecords(SObjectType.SubProject__c.FieldSets.SubProject_Commons.getFields(), 'SubProject__c', 'Project__c', null, setProjectIds, null, null, true, 1000);         
        
        Set<Id> setForClosedProjectIds = new Set<Id>();
        
        //in the result query of subproject get all the project id
        Map<Id, ID> mapSubProjectIds = getProjectIdFromSubProject(listSubProjects);
        
        //iterate the source projectId
        for(Id ids : setProjectIds) {
            
            //check the projectId is in the map, if the id is not in the map it means the project does not contain any subproject 
            if (!mapSubProjectIds.containsKey(ids)) {
                
                //check the project id if already contains in the list to be closed
                if (!setForClosedProjectIds.contains(ids)) {
                    setForClosedProjectIds.add(ids);                     
                }
            }
        }
        
        List<Project__c> listProjects = new List<Project__c>();
        if (!setForClosedProjectIds.isEmpty()) {
            
            //query the list of id to be closed
            listProjects = (List<Project__c>)IMP_Project_Utility.queryRelatedRecords(SObjectType.Project__c.FieldSets.Project_Commons.getFields(), 'Project__c', 'Id', null, setForClosedProjectIds, null, null, true, 1000);         
            
            if (!listProjects.isEmpty()) {
                for (Project__c proj : listProjects) {
                    proj.Project_Status__c = 'Closed';
                }
            }
        }
        return listProjects;
    }
    
    private static Map<Id, Id> getProjectIdFromSubProject(List<SubProject__c> listSubprojects) {
        Map<Id,Id> convertMap = new Map<Id,Id>();
        for (SubProject__c s : listSubprojects) {
            if (!convertMap.containsKey(s.Project__c)) 
            {
                convertMap.put(s.Project__c, s.Project__c);
            }
        }
        
        return convertMap;
    }
}