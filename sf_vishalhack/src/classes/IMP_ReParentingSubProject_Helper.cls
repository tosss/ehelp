/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas       
Description: Changing the Project__c field value for all Subproject child object 
when the subproject is re-parent with a new project
Test Class: IMP_ReParentingSubProject_Test
History
11/13/14    Rey Austral             Created
01/15/15    Samuel Oberes           Refactored: Made the getSubProjectLog project log type agnostic
Introduced the updateSubProjectChildObject method that caters for all the subproject child objects
10/29/15    Venkata Shrivol			Added a null check for SubProject in  getSubProjectLog method.       
12/05/16    Venkata Shrivol			commented the below code as project object reference is deleted on subproject RQ-08305
------------------------------------------------------------*/
//2016-03-03- anirudh.singh@cdk.com- Modified this class for Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
public class IMP_ReParentingSubProject_Helper
{
   /* public static void executeReParent(Map<Id, SubProject__c> filteredSubProjectMap, Map<Id, SubProject__c> oldSubProjectsMap)
    {
        system.debug('Start executeReParent---->');
        
        Set<Id> subProjectIds=new Set<Id>();
        Set<Id> projectIds=new Set<Id>();
        
        //Get all Ids of SubProject and Project that will be used in the query for selecting related record.
        for(SubProject__c subProjectRecord: filteredSubProjectMap.values())
        {
            subProjectIds.add(subProjectRecord.Id);
            
            projectIds.add(oldSubProjectsMap.get(subProjectRecord.Id).Project__c);
        }
        
        //get all records that have lookup in subproject and project object in preparation to update the project field
        List<SubProjectOpp__c> subProjectOppList=(List<SubProjectOpp__c>)fetchSubProjectChildObjectList(subProjectIds, filteredSubProjectMap, 'SubProjectOpp__c');
        
        List<SubProject_External_Related_Entity__c> subProjectExternalRelatedEntityList=(List<SubProject_External_Related_Entity__c>)fetchSubProjectChildObjectList(subProjectIds, filteredSubProjectMap, 'SubProject_External_Related_Entity__c');
        
        List<SubProject_External_Reference__c> subProjectExternalReferenceList=(List<SubProject_External_Reference__c>)fetchSubProjectChildObjectList(subProjectIds, filteredSubProjectMap, 'SubProject_External_Reference__c');
        
        List<SubProjectSite__c> subProjectSiteList=(List<SubProjectSite__c>)fetchSubProjectChildObjectList(subProjectIds, filteredSubProjectMap, 'SubProjectSite__c'); 
        
        //...in continuation of getting all records, we create separate lists for each of the Project log types
        //since each log record has Lookup fields to Subproject for each log type, but only 1 can be populated based upon type;
        //we're looking to match against subproject, and, it'll require 5 separate passes to cover the 5 types
        List<Schema.FieldSetMember> consolidatedFieldSetMembersList=new List<Schema.FieldSetMember>();
        consolidatedFieldSetMembersList.addAll(SObjectType.Project_Log__c.FieldSets.Action_Item_Commons.getFields());
        consolidatedFieldSetMembersList.addAll(SObjectType.Project_Log__c.FieldSets.Change_Request_Commons.getFields());
        consolidatedFieldSetMembersList.addAll(SObjectType.Project_Log__c.FieldSets.Issue_Commons.getFields());
        consolidatedFieldSetMembersList.addAll(SObjectType.Project_Log__c.FieldSets.Lesson_Learned_Commons.getFields());
        consolidatedFieldSetMembersList.addAll(SObjectType.Project_Log__c.FieldSets.Risk_Commons.getFields());
        
        Set<String> fieldSetMembersFieldPaths=new Set<String>();
        List<Schema.FieldSetMember> fieldSetMembersList=new List<Schema.FieldSetMember>();
        
        for(Schema.FieldSetMember fieldSetMemberRef: consolidatedFieldSetMembersList)
        {
            if(!fieldSetMembersFieldPaths.contains(fieldSetMemberRef.getFieldPath()))
            {
                fieldSetMembersList.add(fieldSetMemberRef);
                fieldSetMembersFieldPaths.add(fieldSetMemberRef.getFieldPath());
            }
        }
        
        // NOTE:
        //   - The last parameter('SubProject_Id__c') is the ID to be used in checking for equality against the first parameter(subProjectIds) in the predicate evaluation.
        //   - The last parameter is a field that contains an ID coming from 1 of the ff. if they are not null: 
        //     - 'Sub_Project_Action_Items__c'
        //     - 'Sub_Project_Change_Request__c'
        //     - 'Sub_Project_Issue__c'
        //     - 'Sub_Project_Lessons_Learned__c'
        //     - 'Sub_Project_Risk__c'
        
        List<Project_Log__c> projectLogsList=fetchSubProjectLog(subProjectIds, filteredSubProjectMap, fieldSetMembersList, 'SubProject_Id__c');
        
        //get projects that will be empty when its last subproject has ben moved in preparation to close it    
        List<Project__c> projectsList=fetchProjectsToClose(projectIds);     
        
        //2016-03-03- anirudh.singh@cdk.com- Added Null checks for all the below IF Blocks for updating records.
        if(subProjectOppList!=Null && !subProjectOppList.isEmpty())
        {
            update subProjectOppList;
        }
        
        if(subProjectExternalRelatedEntityList!=Null && !subProjectExternalRelatedEntityList.isEmpty())
        {
            update subProjectExternalRelatedEntityList; 
        }
        
        if(subProjectExternalReferenceList!=Null && !subProjectExternalReferenceList.isEmpty())
        {
            update subProjectExternalReferenceList; 
        }
        
        if(subProjectSiteList!=Null && !subProjectSiteList.isEmpty())
        {
            update subProjectSiteList;
        }
        
        if(projectLogsList!=Null && !projectLogsList.isEmpty())
        {
            update projectLogsList;
        }
        
        if(projectsList!=Null && !projectsList.isEmpty())
        {           
            update projectsList;
        }
        
        system.debug('End executeReParent---->');
    }
    
    private static List<sObject> fetchSubProjectChildObjectList(Set<Id> subProjectIds, Map<Id, SubProject__c> filteredSubProjectMap, String subProjectChildObject)
    {
        system.debug('Start fetchSubProjectChildObjectList---->');
        
        List<FieldSetMember> fieldSetMembersList;
        
        if(subProjectChildObject=='SubProjectOpp__c')
        {
            fieldSetMembersList=sObjectType.SubProjectOpp__c.FieldSets.SubProject_Opp_Commons.getFields();
        }
        else if(subProjectChildObject=='SubProject_External_Related_Entity__c')
        {
            fieldSetMembersList=sObjectType.SubProject_External_Related_Entity__c.FieldSets.External_Related_Entity_Commons.getFields();
        }
        else if(subProjectChildObject=='SubProject_External_Reference__c')
        {
            fieldSetMembersList=sObjectType.SubProject_External_Reference__c.FieldSets.External_Reference_Commons.getFields();
        }
        else
        {
            fieldSetMembersList=sObjectType.SubProjectSite__c.FieldSets.SubProject_Site_Common.getFields();
        }
        
        //get all subproject child objects 
        List<sObject> objectList=IMP_Project_Utility.queryRelatedRecords(fieldSetMembersList, subProjectChildObject, 'SubProject__c', 
                                                                         null, subProjectIds, null, null, true, 1000);         
        
        //change the value of the child object's project id to the new project id
        SubProject__c subProj;
        
        for(sObject obj: objectList)
        {
            subProj=filteredSubProjectMap.get((Id)obj.get('SubProject__c'));
            obj.put('Project__c', subProj.Project__c);
        }
        
        system.debug('End fetchSubProjectChildObjectList---->');
        return objectList;
    }
    
    private static List<Project_Log__c> fetchSubProjectLog(Set<Id> subProjectIds, Map<Id, SubProject__c> subProjectMap, List<Schema.FieldSetMember> fieldSetMembersList, String subProjectField)
    {
        system.debug('Start fetchSubProjectLog---->');
        
        // NOTE: DO NOT PASS A SET OF IDs TO THE QUERY BELOW, BECAUSE THE SET OF IDs WILL ALWAYS CONTAIN 18-DIGIT IDs
        //       INSTEAD, PASS A LIST OF STRINGS, WHEREIN THE STRINGS ARE ALREADY TRIMMED 15-CHARACTER STRING IDs.
        List<String> subProjectIdsList=new List<String>();
        
        for(Id idRef: subProjectIds)
        {
            subProjectIdsList.add(String.valueOf(idRef).substring(0, 15));
        }
        
        List<Project_Log__c> projectLogsList=(List<Project_Log__c>)IMP_Project_Utility.queryRelatedRecords(fieldSetMembersList, 'Project_Log__c', subProjectField, 
                                                                                                           null, null, subProjectIdsList, null, true, 1000);
        
        //change the value of project to the new project id
        SubProject__c subProjectRecord;
        String projectLogType;
        
        for(SObject projectLog: projectLogsList)
        {
            projectLogType=(String)projectLog.get('Lookup_Field_API_Name_to_Subproject__c');
            
            subProjectRecord=subProjectMap.get((Id)projectLog.get('Sub_Project_' + projectLogType));
            
            //Added this check because projectLogsList is retrieving the irrelevant project log records 
            //by matching first 15-digit string of subProjectID 
            if(subProjectRecord!=null)
            {
                projectLog.put('Project_'+projectLogType, subProjectRecord.Project__c);	
            }
        }   
        
        system.debug('End fetchSubProjectLog---->');
        return projectLogsList;
    }
    
    private static List<Project__c> fetchProjectsToClose(Set<Id> projectIds) 
    {
        system.debug('Start fetchProjectsToClose---->');
        
        //retrieve all subprojects of the source project
        List<SubProject__c> subProjectsList=(List<SubProject__c>)IMP_Project_Utility.queryRelatedRecords(SObjectType.SubProject__c.FieldSets.SubProject_Commons.getFields(), 'SubProject__c', 
                                                                                                         'Project__c', null, projectIds, null, null, true, 1000);         
        
        Set<Id> setForClosedProjectIds=new Set<Id>();
        
        //2016-03-03- anirudh.singh@cdk.com- Commented the below line. Now using Set as Map is irrelevant here and Set satisfies the purpose.
        //in the result query of subproject get all the project id
        //Map<Id, Id> mapSubProjectIds=getProjectIdFromSubProject(subProjectsList);
        
        //2016-03-03- anirudh.singh@cdk.com- Created this variable for using it instead of Map.
        Set<Id> subProjectIds=new Set<Id>();
        for(SubProject__c subProjectRecord: subProjectsList)
        {
            subProjectIds.add(subProjectRecord.Project__c);
        }
        
        //2016-03-03- anirudh.singh@cdk.com- Changed the use of Map and now using Set instead.
        //Iterate the source projectId
        for(Id idRef: projectIds)
        {
            //check the projectId is in the Set, if the id is not in the Set it means the project does not contain any subproject.
            if(!subProjectIds.contains(idRef))
            {
                //check the project id if already contains in the list to be closed.
                if(!setForClosedProjectIds.contains(idRef))
                {
                    setForClosedProjectIds.add(idRef);                     
                }
            }
        }
        
        List<Project__c> projectsList=new List<Project__c>();
        
        if(!setForClosedProjectIds.isEmpty())
        {
            //query the list of id to be closed
            projectsList=(List<Project__c>)IMP_Project_Utility.queryRelatedRecords(SObjectType.Project__c.FieldSets.Project_Commons.getFields(), 'Project__c', 'Id', 
                                                                                   null, setForClosedProjectIds, null, null, true, 1000);         
            
            if(!projectsList.isEmpty())
            {
                for(Project__c projectRecord: projectsList)
                {
                    projectRecord.Project_Status__c='Closed';
                }
            }
        }
        
        system.debug('End fetchProjectsToClose---->');
        return projectsList;
    }
    
    //2016-03-03- anirudh.singh@cdk.com- Commented this method as it was not needed.
    /*private static Map<Id, Id> getProjectIdFromSubProject(List<SubProject__c> subProjectsList)
    {
        system.debug('Start getProjectIdFromSubProject---->');
        Map<Id, Id> convertMap=new Map<Id, Id>();
        
        for(SubProject__c subProjectRecord: subProjectsList)
        {
            if(!convertMap.containsKey(subProjectRecord.Project__c)) 
            {
                convertMap.put(subProjectRecord.Project__c, subProjectRecord.Project__c);
            }
        }
        
        system.debug('End getProjectIdFromSubProject---->');
        return convertMap;
    }*/
}