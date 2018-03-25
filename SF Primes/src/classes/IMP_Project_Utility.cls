/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Project Management utility class
Test Class: IMP_ProjectUtility_Test
History
09/11/14    Michael Lasala      Created
09/11/14    Michael Lasala      Changed class to global when invoked from custom button
09/15/14    Michael Lasala      Added null checking of dates in getCalculatedDate method
09/15/14    Michael Lasala      Changed return of getStandardMilestones from Void to String
09/15/14    Michael Lasala      Added retrieveProjectTypeProductMilestoneDefinitionList method, retrieveProductIds method, buildSiteNames method, 
09/15/14    Michael Lasala      Added buildProjectTypeString method, buildProjectMilestone method, retrieveActivities method
09/16/14    Michael Lasala      Added updateMilestoneActualEndDate method, retrieveMilestonesBySet method
09/17/14    Michael Lasala      Added retrieveProjectMilestone method, retrieveActivityDefinitions method
09/23/14    Michael Lasala      Added validateStatus method, retrieveSubProjectExternalReferences method
09/23/14    Michael Lasala      Added projectActivityDetailsToCaptureFields method, generateQueryString method
09/24/14    Michael Lasala      Added processActivityDetails method, Refactored ACTIVITY DETAIL CAPTURE UTILITY METHODS to cater all record types scenario
10/01/14    Michael Lasala      Added retrieveCDKContactsBySet and retrieveClientContactsBySet
10/07/14    Michael Lasala      Added retrievePSRActivities method
10/10/14    Michael Lasala      Added retrieveDealerships method, retrieveSolutions method, retrieveProducts method
10/11/14    Michael Lasala      Added retrieveProject method
10/13/14    Michael Lasala      Added retrieveProjectCheckList method, retrieveCheckListCategoryBySet method, retrieveUserBySet method
10/13/14    Michael Lasala      Added queryRelatedEntityRecords method, retrieveExternalRelatedEntity method, retrieveExternalReference method
10/13/14    Michael Lasala      Added retrieveSubProjectOpps method
10/14/14    Michael Lasala      Added retrieveAnswers method, retrieveActiveQuestions method, retrieveWorkbookInterviewees method
10/14/14    Michael Lasala      Added retrieveWorkbookInterviewers method, queryRelatedRecordsWithAndCriteria method
10/14/14    Michael Lasala      Added retrieveInterviewersWithAndCriteria method, retrieveIntervieweesWithAndCriteria method
10/14/14    Michael Lasala      Added retrieveQuestionProductBySet method, queryWithSubquery method, retrieveSolutionsWithSubquery method
10/14/14    Michael Lasala      Added retrieveAllActiveCheckListCategories method, retrieveChecklistItems method, retrieveSiteWorkbooks method
10/14/14    Michael Lasala      Added retrieveProjectWithSubquery method, retrieveWorkborkCategoryWithSubquery method, retrieveDealershipsWithQuestions method
10/14/14    Michael Lasala      Added retrieveQuestions method, retrieveAccount method, retrieveCMFInfo method
10/15/14    Michael Lasala      Added retrieveOppQuotesBySet method, queryRelatedRecordsWithOrCriteria method, retrieveExternalRelatedEntityBySet method
10/15/14    Michael Lasala      Added retrieveEntitySubscription method. buildIdSet method
10/22/14    Michael Lasala      Added retrieveMilestoneDefinitionProductsIdSet method, retrieveMilestonesDefinitionsBySet method
11/11/14    Kimiko Roberto      Added checkUserPermission method
11/26/14    Samuel Oberes       Added retrieveSiteWorkbooks (overload), retrieveSiteWorkbook_projectId, retrieveSiteWorkbook_projectIds, retrieveSiteWorkbooks_MainLogic
Added retrieveProjectCheckList (overload), retrieveProjectCheckList_projectId, retrieveProjectCheckList_projectId, retrieveProjectCheckList_MainLogic
12/04/14    Samuel Oberes       Added IMP_SalesforceObjectWrapper
01/03/15    Karl Simon          Added null exception handling for the profileCanByPass method.
02/03/15    Rey Austral         Update buildSiteNames,getSites to not allow duplicate site
03/16/15    Rey Austral         Added createProjectTask,retrieveTaskDefinitionsBySet,buildProjectTask
05/28/15    Karl Simon          Updated sort strings generated in retrieveMilestonesBySet and retrievePSRActivities methods.
06/03/15    Kimiko Roberto      Added a method to bypass updating of expected time spent named userCanByPass
08/12/15    Venkata Shrivol     Modified processActivityDetails method.
09/21/15    Rey Austral         Add new method createProjectActivity
11/03/15    Venkata Shrivol     deleted the methods which use inactive discovery objects
12/02/15    Karl Simon          Extended checked to include 'Not Applicable'
------------------------------------------------------------*/

global class IMP_Project_Utility{
    
    public final static String OBJECT_NAME_ACCOUNT = 'Account';
    public final static String OBJECT_NAME_ACTIVITY_DETAIL_MAPPING = 'Project_Activity_Detail_Mapping_Rule__c';
    public final static String OBJECT_NAME_ACTIVITY_DEFINITION = 'Activity_Definition__c';
    public final static String OBJECT_NAME_ANSWER = 'Answer__c';
    public final static String OBJECT_NAME_CMF_INFO = 'CMF_Info__c';
    public final static String OBJECT_NAME_DISCOVERY_QUESTION_PRODUCT = 'Discovery_Question_Product__c';
    public final static String OBJECT_NAME_DISCOVERY_SITE_WORKBOOK = 'Site_Workbook__c';
    public final static String OBJECT_NAME_DISCOVERY_WORKBOOK_CATEGORY = 'Discovery_Workbook_Category__c';
    public final static String OBJECT_NAME_DISCOVERY_WORKBOOK_INTERVIEWEE = 'Discovery_Workbook_Interviewee__c';
    public final static String OBJECT_NAME_DISCOVERY_WORKBOOK_INTERVIEWER = 'Discovery_Workbook_Interviewer__c';
    public final static String OBJECT_NAME_MILESTONE = 'Milestone__c';
    public final static String OBJECT_NAME_MILESTONE_DEFINITION = 'Milestone_Definition__c';
    public final static String OBJECT_NAME_OPPORTUNITY_QUOTES = 'Opportunity_Quotes__c';
    public final static String OBJECT_NAME_PRODUCT = 'Product__c';
    public final static String OBJECT_NAME_PROJECT = 'Project__c';
    public final static String OBJECT_NAME_PROJECT_ACTIVITY = 'Project_Activity__c';
    public final static String OBJECT_NAME_PROJECT_TASK = 'Project_Task__c';
    public final static String OBJECT_NAME_PROJECT_LOG = 'Project_Log__c';
    public final static String OBJECT_NAME_PROJECT_MILESTONE = 'Project_Milestone__c';
    public final static String OBJECT_NAME_PROJECT_MILESTONE_DEFINITION_PRODUCT = 'Project_Milestone_Definition_Product__c';
    public final static String OBJECT_NAME_QUESTION = 'Question__c';
    public final static String OBJECT_NAME_QUESTION_CATEGORY = 'Question_Category__c';
    public final static String OBJECT_NAME_SOLUTION = 'Solution__c';
    public final static String OBJECT_NAME_SUBPROJECT = 'SubProject__c';
    public final static String OBJECT_NAME_SUBPROJECT_CDK_CONTACT = 'SubProject_CDK_Contact__c';
    public final static String OBJECT_NAME_SUBPROJECT_CLIENT_CONTACT = 'SubProject_Client_Contact__c';
    public final static String OBJECT_NAME_SUBPROJECT_EXTERNAL_REFERENCE = 'SubProject_External_Reference__c';
    public final static String OBJECT_NAME_SUBPROJECT_EXTERNAL_RELATED_ENTITY = 'SubProject_External_Related_Entity__c';
    public final static String OBJECT_NAME_SUBPROJECT_OPP = 'SubProjectOpp__c';
    public final static String OBJECT_NAME_SUBPROJECT_PRODUCT = 'SubProject_Product__c';
    public final static String OBJECT_NAME_USER = 'User';
    public final static String OFFSET_CRITERIA_ESTIMATED_INSTALL = 'Estimated Install Date';
    public final static String OFFSET_CRITERIA_ROLL_CALL = 'Roll Call Date';
    public final static String TAB_SUBPROJECT = 'detailsTab';
    public final static String FIELD_NAME_ACTIVE = 'Active__c';
    public final static String FIELD_NAME_CREATEDDATE = 'CreatedDate';
    public final static String FIELD_NAME_DISPLAY_PSR = 'Display_on_PSR__c';
    public final static String FIELD_NAME_DESCRIPTION = 'Description__c';
    public final static String FIELD_NAME_ENTITY_TYPE = 'Entity_Type__c';
    public final static String FIELD_NAME_EXTERNAL_ENTITY_TYPE = 'External_Entity_Type__c';
    public final static String QUERY_NAME_ID = 'Id';
    public final static String FIELD_NAME_LASTMODIFIEDDATE = 'LastModifiedDate';
    public final static String FIELD_NAME_ORDER = 'Order__c';
    public final static String FIELD_NAME_PLANNED_START_DATE = 'Planned_Start_Date__c';
    public final static String FIELD_NAME_PLANNED_END_DATE = 'Planned_End_Date__c';
    public final static String FIELD_NAME_RECORD = 'Name';
    public final static String FIELD_NAME_RECORD_TYPE_NAME = 'Record_Type_Name__c';
    public final static String FIELD_NAME_RECORDTYPEID = 'RecordTypeId';
    public final static String FIELD_NAME_SEQUENCE = 'Sequence__c';
    public final static String FIELD_NAME_PROCESS_STEP = 'Process_Step__c';
    public final static String FIELD_NAME_SORT_SEQUENCE = 'Sort_Sequence__c';
    public final static String STATUS_CLOSED = 'Closed';
    public final static String STATUS_NOT_APPLICABLE = 'Not Applicable';
    public final static String STATUS_COMPLETE = 'Complete';
    public final static String DATE_TYPE_SUFFIX_START = 'Actual Start';
    public final static String DATE_TYPE_SUFFIX_END = 'Actual End';
    public final static String OPERATOR_RELATIONAL_EQUAL = '=';
    public final static String OPERATOR_RELATIONAL_NOT_EQUAL = '!=';
    public final static String OPERATOR_RELATIONAL_IN = 'IN';
    public final static String OBJECT_NAME_SUBPROJECT_SITE = 'SubProjectSite__c';
    public final static String OBJECT_NAME_TASK_DEFINITION = 'Task_Definition__c';
    public final static String OPERATOR_RELATIONAL_GREATER_THAN = '>';
    public final static String OBJECT_NAME_MILESTONE_ID = 'Milestone_Id__c';
    public final static String FIELD_NAME_SITE_NAME = 'Site_Name__c';
    
    private static String  retrieveSiteWorkbook_projectId { get; set; }
    private static Set<Id> retrieveSiteWorkbook_projectIds { get; set; }
    
    public enum Enum_Operator_Relational { 
        EQUAL, 
            NOT_EQUAL
            }
    
    public enum Enum_RetrieveExternalRelatedEntityBySetsOf {
        PROJECTS,
            SUBPROJECTS
            }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Method called from Generate Milestone custom button in SubProject page layout via JavaScript
Inputs: SubProject Id
Returns: Error/Success String
History
09/10/14    Michael Lasala      Created
10/09/14    Michael Lasala      Added scenario when there are no milestones based on SubProject criteria
04/29/15    Samuel Oberes       Decommissioned
------------------------------------------------------------*/
    //webservice static String getStandardMilestones(Id subProjectId){
    
    //    //Retrieve SubProject record
    //    SubProject__c subProject = retrieveSubProject(subProjectId);
    
    //    List<String> selectedProjectTypes = new List<String>();
    //    selectedProjectTypes.add(subProject.Project_Type__c);
    
    //    List<String> selectedMarkets = new List<String>();
    //    selectedMarkets.add(subProject.Market__c);
    
    //    //Build Project Type string to be used for query
    //    String projectTypeString = buildProjectTypeString(selectedProjectTypes);
    
    //    //Build Market string to be used for query
    //    String marketString = buildProjectTypeString(selectedMarkets);
    
    //    //Retrieve Milestone Definition records based on selected Project Type and Product/s
    //    Map<Id, Project_Milestone__c> milestoneDefinitionProjectMap = createProjectMilestones(subProject.Id, projectTypeString,  marketString);
    
    //    //Retrieve Activity_Definition__c records based on Milestone Definition results
    //    List<Activity_Definition__c> activityDefinitionList = retrieveActivityDefinitionsBySet(milestoneDefinitionProjectMap.keySet());
    
    //    if(!milestoneDefinitionProjectMap.keySet().isEmpty() && !activityDefinitionList.isEmpty()){
    
    //        //Build Project Activity records
    //        List<Project_Activity__c> projectActivitiesToInsert = new List<Project_Activity__c>();
    
    //        //Iterate through Activity Definition and instantiate a new Project_Activity__c record for each and map respective fields
    //        for(Activity_Definition__c ad: activityDefinitionList){
    
    //            Project_Activity__c projectActivity = buildProjectActivity(ad, milestoneDefinitionProjectMap.get(ad.Milestone_Definition__c).Id, subProject);
    
    //            //Add Project Activity to list that will be inserted later
    //            projectActivitiesToInsert.add(projectActivity);
    //        }
    
    //        //Insert Project Activities
    //        if(!projectActivitiesToInsert.isEmpty()){
    
    //            try{
    
    //                insert projectActivitiesToInsert;
    
    //                //Set SubProject flag to true
    //                subProject.Milestones_Auto_Generated_Flag__c = true;
    
    //            } catch (DmlException e){
    //                return String.valueOf(e.getMessage());
    //                System.debug('$$$: '+e.getMessage());
    //            }
    //        }
    
    
    //        try{
    
    //            update subProject;
    
    //        } catch (DmlException e){
    //            return String.valueOf(e.getMessage());
    //        }
    
    //    } else {
    //        return 'No standard Milestones found based on SubProject criteria';
    //    }
    //    return 'true';
    //}
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Creates Project Milestones based on SubProject Project Type and Products
Inputs: SubProject Id, Project Type, Product Id Set, Market
Returns: Map<Id, Project_Milestone__c>
History
09/12/14    Michael Lasala      Created
09/16/14    Michael Lasala      Added marketType parameter
09/16/14    Michael Lasala      Removed siteNames parameter
------------------------------------------------------------*/
    public static Map<Id, List<Project_Milestone__c>> createProjectMilestones(String subProjectId, String projectType,String marketType, List<Milestone_Definition__c> selectedMilestoneDefinitionList, String siteId )
    {        
        Map<Id, Project_Milestone__c> milestoneDefinitionProjectMap = new Map<Id, Project_Milestone__c>();
        
        //Retrieve Milestone Definitions that fit the SubProject and Product/s criteria
        List<Milestone_Definition__c> projectTypeProductMilestoneDefinitionList = new List<Milestone_Definition__c> ();
        if (selectedMilestoneDefinitionList != NULL && !selectedMilestoneDefinitionList.isEmpty())
        {
            projectTypeProductMilestoneDefinitionList = selectedMilestoneDefinitionList;
        }
        else
        {
            projectTypeProductMilestoneDefinitionList = retrieveProjectTypeProductMilestoneDefinitionList(projectType,  marketType, true);
        }      
       
        Set<Id> projectTypeProductMilestoneDefinitionSet = new Set<Id>();
        Map<Id, Project_Milestone__c> alreadyExistingMilestoneDefIdtoProjectMilestoneMap = new Map<Id, Project_Milestone__c>();
        //2015-10-01 Rey Austral - Change Map<Id, Project_Milestone__c> to Map<Id, List<Project_Milestone__c>> because the definition of create activity has been change
        //to handle insertion of same milestone definition but different milestone record and subproject
        Map<Id, List<Project_Milestone__c>> existingAndNewMilestoneDefinitionProjectMap = new Map<Id, List<Project_Milestone__c>>();
        if(!projectTypeProductMilestoneDefinitionList.isEmpty())
        {
            projectTypeProductMilestoneDefinitionSet = (new Map<Id,Milestone_Definition__c>(projectTypeProductMilestoneDefinitionList)).keyset();
            
            List<Project_Milestone__c> existingMilestoneList  = findExistingSubProjectRecsForMilestoneDefs(projectTypeProductMilestoneDefinitionSet, subProjectId, siteId);
            for (Project_Milestone__c miles : existingMilestoneList )
            {
                alreadyExistingMilestoneDefIdtoProjectMilestoneMap.put(miles.Milestone_Definition__c, miles);
            }
            
            //Instantiate a new Project_Milestone__c record for every Milestone_Definition__c result and map respective fields
            for(Milestone_Definition__c md: projectTypeProductMilestoneDefinitionList)
            {                
                if (alreadyExistingMilestoneDefIdtoProjectMilestoneMap.containsKey(md.id))
                {
                    Project_Milestone__c projectMilestone = alreadyExistingMilestoneDefIdtoProjectMilestoneMap.get(md.id);
                    List<Project_Milestone__c> projectMilestoneList = new List<Project_Milestone__c>();
                    projectMilestoneList.add(projectMilestone);
                    existingAndNewMilestoneDefinitionProjectMap.put(md.id, projectMilestoneList);
                }
                else
                {
                    List<SubProjectSite__c> siteList = buildSiteNames(subProjectId);
                    Project_Milestone__c projectMilestone = buildProjectMilestone(md, subProjectId, siteList, siteId);                  
                     //Put key and value to map which will be used later for the generation Project_Activity__c
                    milestoneDefinitionProjectMap.put(md.Id, projectMilestone);
                }               
            }
        }
        system.debug('milestoneDefinitionProjectMap  ' + milestoneDefinitionProjectMap);
        //Insert Project Milestones
        if(!milestoneDefinitionProjectMap.values().isEmpty())
        {
            try
            { 
                insert milestoneDefinitionProjectMap.values();
            } 
            catch (DmlException e)
            {
                System.debug('$$$ generate milestoneDefinitionProjectMap.values() DmlException: '+e);
            }
        }
        
        //Clear map then query newly created Project Milestone records
        //milestoneDefinitionProjectMap.clear();
        for (Project_Milestone__c milestone:  milestoneDefinitionProjectMap.values())
        {
            List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
            milestoneList.add(milestone);
            existingAndNewMilestoneDefinitionProjectMap.put(milestone.Milestone_Definition__c, milestoneList);
        }
        //for(Project_Milestone__c pm: [SELECT Id, Milestone_Definition__c FROM Project_Milestone__c WHERE SubProject__c =: subProjectId]){
        //     milestoneDefinitionProjectMap.put(pm.Milestone_Definition__c, pm);            
        //}
        
        return existingAndNewMilestoneDefinitionProjectMap;
    }
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Creates Project Activity of the Milestone
    Inputs: Map of Subroject, Map of Milestone with Milestone Definition id as the key
    Returns: String, return the error if fail
    History
    09/21/15    Rey Austral      Created
    10/01/15    Rey Austral      Change the milestoneDefinitionProjectMap type from Map<Id, Project_Milestone__c> to Map<Id, List<Project_Milestone__c>>
    ------------------------------------------------------------*/
    
    public static String createProjectActivity(Map<id,SubProject__c> subProjectMap, Map<Id, List<Project_Milestone__c>> milestoneDefinitionProjectMap )
    {
        String errorMessage = '';
        List<Activity_Definition__c> activityDefinitionList = IMP_Project_Utility.retrieveActivityDefinitionsBySet(milestoneDefinitionProjectMap.keySet());                    
        
        if(!activityDefinitionList.isEmpty() && !milestoneDefinitionProjectMap.keySet().isEmpty())
        {
            //Build Project Activity records
            List<Project_Activity__c> projectActivitiesToInsertList = new List<Project_Activity__c>();
            
            //Iterate through Activity Definition and instantiate a new Project_Activity__c record for each and map respective fields
            for(Activity_Definition__c ad: activityDefinitionList)
            {
                //2015-08-06 - Rey Austral - Update Non_RMS_Owned_Standard_Activities_Create__c
                //2015-10-01 - Rey Austral - Update to handle same milestone definition but different milestone record and subproject
                List<Project_Milestone__c> milestoneRecordList = milestoneDefinitionProjectMap.get(ad.Milestone_Definition__c);
                //2015-09-21 Rey Austral - for change request on RMS integration to always create all project activities for rms owned project milestone 
                //commenting out the setting of the boolean field value to indicate whether or not non-rms owned project activities have been created.
                //rms integration are now always create the non rms project activities for any rms owned project milestone.
                //milestoneRecord.Non_RMS_Owned_Standard_Activities_Create__c = true;
                for (Project_Milestone__c milestoneRecord : milestoneRecordList)
                {
                    Subproject__c subProject = subProjectMap.get(milestoneRecord.SubProject__c);
                    Project_Activity__c projectActivity = buildProjectActivity(ad, milestoneRecord.Id, subProject);                         
                    //Add Project Activity to list that will be inserted later
                    projectActivitiesToInsertList.add(projectActivity);
                }              
            }
            
            //Insert Project Activities
            if(!projectActivitiesToInsertList.isEmpty())
            {
                try
                {                                
                    insert projectActivitiesToInsertList;
                    //2015-08-06 Rey Austral - Add Update DML to update  Non_RMS_Owned_Standard_Activities_Create__c
                    //2015-09-21 Rey Austral  - Disable because this methos will also be called in the after insert of milestone trigger
                    //cannot update milestone in the after insert trigger
                    //Update milestoneDefinitionProjectMap.values();                                
                    
                    errorMessage = createProjectTask(projectActivitiesToInsertList);                    
                } 
                catch (DmlException e)
                {
                    if(ApexPages.currentPage()!=null)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));  
                    }
                    
                    System.debug('$$$ insert projectActivitiesToInsertList DmlException: ' + e);
                    errorMessage = e.getMessage();
                }
            }
        }
        else
        {
            errorMessage = IMP_String_Utility.NO_MILESTONES_FOUND_BASED_ON_CRITERIA;
        }
        return errorMessage;
    }

    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Calculate Date based on parameters
    Inputs: Offset Criteria, SubProject__c, Planned Date Offet
    Returns: Date
    History
    09/09/14    Michael Lasala      Created
    ------------------------------------------------------------*/
    public static Date getCalculatedDate(String offsetCriteria, SubProject__c subProjectVar, Integer plannedOffset){
        Date calculatedDate;
        
        if(subProjectVar.Rush__c || offsetCriteria == null || offsetCriteria == 'None'){
            
            return null;
            
        } else if(offsetCriteria == OFFSET_CRITERIA_ESTIMATED_INSTALL){
            
            if(subProjectVar.Estimated_Install_Date_EID__c != null){
                
                //Subtract date if offset criteria = estimated install date
                calculatedDate = subProjectVar.Estimated_Install_Date_EID__c.addDays(-(Integer.valueOf(+plannedOffset)));
            }
        } else if(offsetCriteria == OFFSET_CRITERIA_ROLL_CALL){
            
            if(subProjectVar.Contract_Roll_Called__c != null){
                
                //Add date if offset criteria = roll call date
                calculatedDate = subProjectVar.Contract_Roll_Called__c.addDays(plannedOffset);
            }
        }
        return calculatedDate;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Update Project Milestone Actual End Date
Inputs: Map of Project Milestone and Activity Actual End Date, Project Milestone Id set
Returns: Boolean
History
09/16/14    Michael Lasala      Created
09/17/14    Michael Lasala      Changed return to Boolean
11/07/14    Karl Simon          Changed return to a Map, and extended the processing to handle multiple milestones.
12/04/14    Samuel Oberes       Added milestoneToActivitycountMap to update actual end date of milestone that only has 1 project activity
------------------------------------------------------------*/
    /* 2015-8-14 Kimiko Roberto - Commented out method
    public static Map<Id, Boolean> updateMilestoneActualEndDate(Map<Id, Date> milestoneEndDateMap, Set<Id> milestoneIds){
        
        //Retrieve Milestones
        List<Project_Milestone__c> projectMilestoneList = retrieveMilestonesBySet(milestoneIds, QUERY_NAME_ID);
        
        //Retrieve Project Activities based Milestones above
        List<Project_Activity__c> projectActivityList = retrieveActivities(milestoneIds);
        Boolean isSuccess = true;
        
        //This map is used to support the for loop below to confirm milestone Ids to end date
        Map<Id, Boolean> projectMilestoneIdtoMilestoneEndDateUpdateSuccess = new Map<Id, Boolean>();
        
        //This list captures all of the terminal project activities
        List<Project_Activity__c> terminalProjectActivityList = new List<Project_Activity__c>();
        
        //This map captures all of the terminal project activities that should not be end dated, given non-terminal activities end dates
        //Ultimately, it's passed pack to the calling trigger to add an error to the project activities
        Map<Id, Boolean> terminalProjectActivityIdtoSuccessMap = new Map<Id, Boolean>();
        
        //This map is sent back to the caller of the method to support error handling to notify user when a project
        //activity terminal activity can't be end dated, since other non-terminal Project activities haven't yet been
        //end dated
        Map<Project_Activity__c, Boolean> projectActivitytoMilestoneEndDateUpdateSuccess = new Map<Project_Activity__c, Boolean>();
        
        // Stores the number of project activities per milestone
        Map<Id, Integer> milestoneToActivitycountMap = new Map<Id, Integer>();
        
        if(!projectActivityList.isEmpty()){
            
            //Loop through the project activities retrieved from the project utility class based upon matching milestone ids.
            //Process each to confirm if its project milestone parent should be end dated, and provide the caller a result to
            //support its error handling of terminal project activities that can not be end dated.
            for(Project_Activity__c pa: projectActivityList){
                
                // Counts how many project activity instances there is per milestone
                milestoneToActivitycountMap.put(
                    pa.Milestone__c, 
                    ( milestoneToActivitycountMap.get(pa.Milestone__c) == null ? 1 : milestoneToActivitycountMap.get(pa.Milestone__c) + 1 ) 
                );
                
                //Validate if all non Terminal Activities have Actual End Dates, else return error
                //The 'if' block confirms stamps a failed qualification value into the milestone to update if it finds a non-terminal
                //project activity with a null actual end Date
                if(!pa.Terminal_Activity__c && pa.Actual_End_Date__c == null){
                    isSuccess = false;
                    projectMilestoneIdtoMilestoneEndDateUpdateSuccess.put(pa.milestone__c, isSuccess);
                }
                
                //This 'else if' block stamps a successful qualification value into the milestones to update map if it finds a non-terminal
                //project activity with a non-null actual end date.
                else if (!pa.Terminal_Activity__c && pa.Actual_End_Date__c != null){
                    isSuccess = true;
                    Boolean mapContainsProjectMilestone = projectMilestoneIdtoMilestoneEndDateUpdateSuccess.containskey(pa.milestone__c);
                    if (!mapContainsProjectMilestone) {
                        projectMilestoneIdtoMilestoneEndDateUpdateSuccess.put(pa.milestone__c, isSuccess);
                    }
                    else {
                        //do nothing
                    }
                }
                
                //This 'else if' block catches the terminal activities
                else if (pa.Terminal_Activity__c) {
                    System.debug('$$$ About to add a terminal activity to the terminal activity list to evaluate.');
                    terminalProjectActivityList.add(pa);
                    System.debug('$$$ The terminal Project Activity List is now size:' + terminalProjectActivityList);
                }
                
            }
            
        }
        
        // Another iteration over the project activity list. 
        // The purpose of this loop is to create an entry in the projectMilestoneIdtoMilestoneEndDateUpdateSuccess map 
        //   for milestones that only has 1 project actvity. This activity is terminal and contains an actual end date.
        // Purpose: This is crucial for the 1-milestone-1-activity scenario so that the milestone's actual end date will get updated
        for (Project_Activity__c pa : projectActivityList) {
            if (milestoneToActivitycountMap.get(pa.Milestone__c) == 1 && pa.Terminal_Activity__c && pa.Actual_End_Date__c != null) {
                projectMilestoneIdtoMilestoneEndDateUpdateSuccess.put(pa.Milestone__c, true);
            }
        }
        
        if (!terminalProjectActivityList.isEmpty()){
            for(Project_Activity__c pa2: terminalProjectActivityList){
                Boolean mapContainsProjectMilestone2 = projectMilestoneIdtoMilestoneEndDateUpdateSuccess.containskey(pa2.milestone__c);
                
                if (mapContainsProjectMilestone2) {
                    System.debug('$$$ The size of projectMilestoneIdtoMilestoneEndDateUpdateSuccess is ' + projectMilestoneIdtoMilestoneEndDateUpdateSuccess.size());
                    Boolean isSuccess2 = projectMilestoneIdtoMilestoneEndDateUpdateSuccess.get(pa2.milestone__c);
                    // projectActivitytoMilestoneEndDateUpdateSuccess.put(pa2, isSuccess2);
                    
                    if (!isSuccess2) {
                        System.debug('$$$ Found a terminal activity that had a milestone id in the map that is marked as failed.');
                        terminalProjectActivityIdtoSuccessMap.put(pa2.Id,false);
                        System.debug('$$$ Just added a terminal project activity to the error map to return back.');
                        System.debug('$$$ The terminal Project Activity ERROR Map is now size:' + terminalProjectActivityIdtoSuccessMap.size());
                    }
                }
            }
        }
        
        if(!projectMilestoneIdtoMilestoneEndDateUpdateSuccess.isEmpty()){
            Set <Id> milestoneIdstoEvaluate = new Set <Id>();
            Set <Id> milestoneIdstoUpdate = new Set <Id>();
            
            milestoneIdstoEvaluate  = projectMilestoneIdtoMilestoneEndDateUpdateSuccess.keyset();          
            
            for (Id mId: milestoneIdstoEvaluate) {
                if (projectMilestoneIdtoMilestoneEndDateUpdateSuccess.get(mId)) {
                    milestoneIdstoUpdate.add(mId);
                }
            }
            
            
            List<Project_Milestone__c> projectMilestonestoUpdateList = retrieveMilestonesBySet(milestoneIdstoUpdate, QUERY_NAME_ID);
            
            for(Project_Milestone__c pm: projectMilestonestoUpdateList){
                
                //Set Project Milestone Actual end date = value from milestoneEndDateMap
                pm.Actual_End_Date__c = milestoneEndDateMap.get(pm.Id);
            }
            
            //Update Project Milestone records
            try{
                update projectMilestonestoUpdateList;
            } catch (DmlException e){
                System.debug('$$$ update projectMilestonestoUpdateList DmlException: '+e);
            }
        }
        
        System.debug('$$$ Right before returning it, the terminal Project Activity ERROR map is now size:' + terminalProjectActivityIdtoSuccessMap.size());
        return terminalProjectActivityIdtoSuccessMap;
    }*/
    
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Populate Project lookup based on SubProject's Project
    Inputs: List of SubProjectSite, List of SubProjectOpp, List of SubProject External Reference, List of SubProject External Related Entity, SubProject Id Set
    Returns: Void
    History
    09/18/14    Michael Lasala      Created
    10/01/14    Rey Austral         Added new Inputs
    ------------------------------------------------------------*/
    public static void updateProjectField(List<SubProjectSite__c> sitesList, List<SubProjectOpp__c> opportunityList, List<SubProject_External_Reference__c> externalList,
                                          List<SubProject_External_Related_Entity__c> externalRelatedList, Set<Id> subProjectIds){
                                              
                                              //Retrieve SubProjects to get Project Id
                                              List<SubProject__c> subProjectList = retrieveSubProjectsBySet(QUERY_NAME_ID, null, subProjectIds);
                                              
                                              //Identify which object is inserting then populate Project value
                                              
                                              if(sitesList != null){
                                                  for(SubProjectSite__c ss: sitesList){
                                                      for(SubProject__c s: subProjectList){
                                                          if(ss.SubProject__c == s.Id){
                                                              ss.Project__c = s.Project__c;
                                                          }
                                                      }
                                                  }
                                              } else if(opportunityList != null){        
                                                  for(SubProjectOpp__c so: opportunityList){
                                                      for(SubProject__c s: subProjectList){
                                                          if(so.SubProject__c == s.Id){
                                                              so.Project__c = s.Project__c;
                                                          }
                                                      }
                                                  }
                                              } else if(externalList != null){
                                                  for(SubProject_External_Reference__c ser: externalList){
                                                      for(SubProject__c s: subProjectList){
                                                          if(ser.SubProject__c == s.Id){
                                                              ser.Project__c = s.Project__c;
                                                          }
                                                      }
                                                  }
                                              } else if (externalRelatedList != null) {
                                                  for(SubProject_External_Related_Entity__c sere: externalRelatedList){
                                                      for(SubProject__c s: subProjectList){
                                                          if(sere.SubProject__c == s.Id){
                                                              sere.Project__c = s.Project__c;
                                                          }
                                                      }
                                                  }
                                              }
                                          }
    
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Validate related Project Milestone Status values
    Inputs: SubProject Ids
    Returns: Boolean
    History
    09/23/14    Michael Lasala      Created
    01/06/15    Samuel Oberes       Changed return value from Boolean to Map<SubprojectId, BooleanStatusIfChildMilestonesAreAllComplete>
    ------------------------------------------------------------*/
    public static Map<Id, Boolean> areAllMilestonesComplete(Set<Id> subProjectIds){
        
        // Key: subproject id | Value: Boolean indicator whether the subproject's milestones are all complete (true) or at least 1 is yet to be completed (false)
        Map<Id, Boolean> subProjectIdToMilestonesCompleteValueMap = new Map<Id, Boolean>();
        
        // Retrieve related Project Milestones based on SubProject Id set
        List<Project_Milestone__c> milestoneList = retrieveMilestonesBySet(subProjectIds, OBJECT_NAME_SUBPROJECT);
        
        if (!milestoneList.isEmpty()) {
            
            // Key: subproject id | Value: List of subproject's milestones
            Map<String, List<Project_Milestone__c>> subProjectToMilestoneMap = new Map<String, List<Project_Milestone__c>>();
            
            // Map values per SubProject Id
            for(Project_Milestone__c pm: milestoneList){
                if(subProjectToMilestoneMap.containsKey(pm.SubProject__c)){
                    subProjectToMilestoneMap.get(pm.SubProject__c).add(pm);
                } else {
                    List<Project_Milestone__c> tempList = new List<Project_Milestone__c>();
                    tempList.add(pm);
                    subProjectToMilestoneMap.put(pm.SubProject__c, tempList);
                }
            }
            
            for(String subprojectId : subProjectToMilestoneMap.keySet()){
                
                // here, we pre-populate the values to true. after all, it will eventually be populated with false later on if at least 1 milestone is not yet complete
                subProjectIdToMilestonesCompleteValueMap.put(subProjectId, true);
                
                for(Project_Milestone__c pm : subProjectToMilestoneMap.get(subprojectId)){
                    
                    //2015-Nov-02 Karl Simon - Extended checked to include 'Not Applicable'
                    // If at least Project Milestone Status != Complete or !=Not Applicable, return error
                    if((pm.Status__c != STATUS_COMPLETE) && (pm.Status__c != STATUS_NOT_APPLICABLE)){
                        subProjectIdToMilestonesCompleteValueMap.put(subProjectId, false);
                        break;
                    }
                }
            }
        }
        return subProjectIdToMilestonesCompleteValueMap;
    }
    
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Build concatenated string of Site Names
    Inputs: SubProject Id
    Returns: String
    History
    09/15/14    Michael Lasala      Created
    ------------------------------------------------------------*/
    public static List<SubProjectSite__c> buildSiteNames(String subProjectId){
        List<String> siteNames = new List<String>();
        Map<String,String> mapSite = new Map<String,String>();
        List<SubProjectSite__c> subProjectSiteList = [SELECT Account__r.Name FROM SubProjectSite__c WHERE SubProject__c =: subProjectId ];
        
        //for(SubProjectSite__c sps: subProjectSiteList){
        //    if (!mapSite.containsKey(sps.Account__r.Name)) {
        //        mapSite.put(sps.Account__r.Name, sps.Account__r.Name);
        //        siteNames.add(sps.Account__r.Name);
        //    }
        //}
        
        return subProjectSiteList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Build joined string to be used for query parameters (cater single/multi select picklist)
Inputs: List<String>
Returns: String
History
09/15/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static String buildProjectTypeString(List<String> stringList){
        
        String joinedString = '';
        
        for(String s: stringList){
            joinedString += s+';';
        }
        
        joinedString = joinedString.subString(0, joinedString.length()-1);
        
        return joinedString;
    }
    
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Build a set of Id based on Set<String>
    Inputs: Set<String>, List<sObject>
    Returns: Set<Id>
    History
    10/15/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static Set<Id> buildIdSet(Set<String> stringSet, List<sObject> objectList){
        
        Set<Id> idSet = new Set<Id>();
        
        //Convert Set<String>
        if(stringSet != null && !stringSet.isEmpty()){
            for(String str: stringSet){
                idSet.add(Id.valueOf(str));
            }
        }
        
        //Convert List<sObject>
        if(objectList != null && !objectList.isEmpty()){
            for(sObject s: objectList){
                idSet.add(s.Id);
            }
        }
        
        return idSet;
    }
    
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Build a set of Id based on the provided field
    Inputs: Set<String>, List<sObject>
    Returns: Set<Id>
    History
    07/17/15    Rey Austral      Created
    ------------------------------------------------------------*/
    public static Set<Id> buildIdSet( List<sObject> objectList, String fieldName){
        
        Set<Id> idSet = new Set<Id>();
        
        //Convert List<sObject>
        if(objectList != null && !objectList.isEmpty()){
            for(sObject s: objectList){
                Id customField = (Id)s.get(fieldName);
                idSet.add(customField);
            }
        }
        
        return idSet;
    }
    
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Map new Project Milestone record
    Inputs: Milestone Definition Id, SubProject Id, Concatenated string of Site Names
    Returns: Project_Milestone__c
    History
    09/15/14    Michael Lasala      Created
    ------------------------------------------------------------*/
    public static Project_Milestone__c buildProjectMilestone(Milestone_Definition__c milestoneDefinition, String subProjectId, List<SubProjectSite__c> siteList, String siteId)
    {
        Project_Milestone__c projectMilestone = new Project_Milestone__c();
        
        if(milestoneDefinition.Id != null)
        {
            projectMilestone.Milestone_Definition__c = milestoneDefinition.Id;
            projectMilestone.SubProject__c = subProjectId;
            
            if(milestoneDefinition.Description__c != null)
            {
                projectMilestone.Description__c = milestoneDefinition.Description__c;
            }
            if (siteList != null && siteList.size() == 1) 
            {
                projectMilestone.Site__c = siteList.get(0).Id;
            }
            
            if (siteId != NULL && siteId != '')
            {
                projectMilestone.Site__c =siteId;
                projectMilestone.RMS_External_Id__c = milestoneDefinition.id + '|' + siteId;
            }
            if (milestoneDefinition.Process_Step__c != null)
            {
                projectMilestone.Process_Step__c = milestoneDefinition.Process_Step__c;
            }
            
            if (milestoneDefinition.Sort_Sequence__c != null)
            {
                projectMilestone.Sort_Sequence__c = milestoneDefinition.Sort_Sequence__c;
            }
            projectMilestone.Standard__c = true;
        }
        return projectMilestone;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Map new Project Activity record
Inputs: Activity Definition Id, Project Milestone Id, SubProject Id, Standard Boolean
Returns: Project_Milestone__c
History
09/15/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static Project_Activity__c buildProjectActivity(Activity_Definition__c activityDefinition, String projectMilestoneId, SubProject__c subProject)
    {
        Project_Activity__c projectActivity = new Project_Activity__c();
        
        if(activityDefinition.Id != null)
        {
            projectActivity.Activity_Definition__c = activityDefinition.Id;
            projectActivity.Milestone__c = projectMilestoneId;
            
            if(activityDefinition.Description__c != null)
            {
                projectActivity.Description__c = activityDefinition.Description__c;
            }
            
            if(activityDefinition.Offset_Criteria__c != null && activityDefinition.Planned_Start_Date_Offset__c != null)
            {
                projectActivity.Planned_Start_Date__c = getCalculatedDate(activityDefinition.Offset_Criteria__c, 
                                                                          subProject, 
                                                                          Integer.valueOf(activityDefinition.Planned_Start_Date_Offset__c));
            }
            
            if(activityDefinition.Offset_Criteria__c != null && activityDefinition.Planned_End_Date_Offset__c != null)
            {
                projectActivity.Planned_End_Date__c = getCalculatedDate(activityDefinition.Offset_Criteria__c, 
                                                                        subProject, 
                                                                        Integer.valueOf(activityDefinition.Planned_End_Date_Offset__c));
            }
            
            //projectActivity.Terminal_Activity__c = activityDefinition.Terminal_Activity__c;
            
            if(activityDefinition.CDK_Assignee_Role__c != null)
            {
                projectActivity.CDK_Assignee_Role__c = activityDefinition.CDK_Assignee_Role__c;
            }
            
            if(activityDefinition.Sequence__c != null)
            {
                projectActivity.Sequence__c = activityDefinition.Sequence__c;
            }
            
            projectActivity.Standard__c = true;
        }
        return projectActivity;
    }
    
    //============================================================
    //              RECORD RETRIEVAL UTILITY METHODS
    //============================================================
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve SubProject record
Inputs: Record Id
Returns: SubProject__c
History
09/05/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static SubProject__c retrieveSubProject(Id recordId){
        return (SubProject__c) querySingleRecord(SObjectType.SubProject__c.FieldSets.SubProject_Commons.getFields(), OBJECT_NAME_SUBPROJECT, recordId, null);
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve Project Milestone record
Inputs: Record Id
Returns: Project_Milestone__c
History
09/12/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
  //  public static Project_Milestone__c retrieveProjectMilestone(Id recordId){
  //      return (Project_Milestone__c) querySingleRecord(SObjectType.Project_Milestone__c.FieldSets.Milestone_Commons.getFields(), OBJECT_NAME_PROJECT_MILESTONE, recordId, null);
  //  }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve Project record
Inputs: Record Id/Record Name
Returns: Project__c
History
10/11/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static Project__c retrieveProject(String recordId, String recordName){
        return (Project__c) querySingleRecord(SObjectType.Project__c.FieldSets.Project_Commons.getFields(), OBJECT_NAME_PROJECT, recordId, recordName);
    }*/
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve Account record
Inputs: Record Id
Returns: Account
History
10/14/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static Account retrieveAccount(String recordId){
        return (Account) querySingleRecord(SObjectType.Account.FieldSets.Account_Commons.getFields(), OBJECT_NAME_ACCOUNT, recordId, null);
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Milestone records based on SubProject Id
Inputs: SubProject Id
Returns: List<Project_Milestone__c>
History
09/05/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*  public static List<Project_Milestone__c> retrieveMilestones(Id subProjectId){
        List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add('Planned_Start_Date__c');
        orderFields.add('Planned_End_Date__c');
        
        for(sObject o: queryRelatedRecords(SObjectType.Project_Milestone__c.FieldSets.Milestone_Commons.getFields(), OBJECT_NAME_PROJECT_MILESTONE, OBJECT_NAME_SUBPROJECT, subProjectId, null, null, orderFields, true, 0)){
            milestoneList.add((Project_Milestone__c)o);
        }
        return milestoneList;
    }
    
  */  /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related SubProject records based on Id/Set
Inputs: Milestone Ids
Returns: List<SubProject__c>
History
09/18/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<SubProject__c> retrieveSubProjectsBySet(String parentField, String parentId, Set<Id> parentSetId){
        List<SubProject__c> subProjectList = new List<SubProject__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add(FIELD_NAME_CREATEDDATE);
        
        for(sObject o: queryRelatedRecords(SObjectType.SubProject__c.FieldSets.SubProject_Commons.getFields(), OBJECT_NAME_SUBPROJECT, parentField, parentId, parentSetId, null, orderFields, true, 0)){
            subProjectList.add((SubProject__c)o);
        }
        return subProjectList;
    }
    
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Retrieve related Milestone records based on Set
    Inputs: Milestone Ids, Parent Field
    Returns: List<Project_Milestone__c>
    History
    09/15/14    Michael Lasala      Created
    01/20/15    Samuel Oberes       Added FIELD_NAME_PLANNED_END_DATE
    05/28/15    Karl Simon          Updated the fields to add to the string driving (Order By) sorting; sort now incluldes 6 step process, planned end date, and sort sequence
    08/17/15    Samuel Oberes       Now ordered by FIELD_NAME_SITE_NAME
    ------------------------------------------------------------*/
    public static List<Project_Milestone__c> retrieveMilestonesBySet(Set<Id> milestonesIds, String parentField){
        List<Project_Milestone__c> milestoneList = new List<Project_Milestone__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        //orderFields.add(FIELD_NAME_PLANNED_START_DATE);
        //orderFields.add(FIELD_NAME_PLANNED_END_DATE);
        orderFields.add(FIELD_NAME_SITE_NAME);
        orderFields.add(FIELD_NAME_PROCESS_STEP);
        orderFields.add(FIELD_NAME_PLANNED_END_DATE);
        orderFields.add(FIELD_NAME_SORT_SEQUENCE);
        
        for(sObject o: queryRelatedRecords(SObjectType.Project_Milestone__c.FieldSets.Milestone_Commons.getFields(), OBJECT_NAME_PROJECT_MILESTONE, parentField, null, milestonesIds, null, orderFields, true, 0)){
            milestoneList.add((Project_Milestone__c)o);
        }
        return milestoneList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Project Activity records based on Milestone Id Set
Inputs: Milestone Id Set
Returns: List<Project_Activity__c>
History
09/05/14    Michael Lasala      Created
08/17/15    Samuel Oberes       changed milestoneIds and OBJECT_NAME_MILESTONE to activityIdsSet and 'Id' respectively, and ordered by FIELD_NAME_SITE_NAME
------------------------------------------------------------*/
    public static List<Project_Activity__c> retrieveActivities(Set<Id> activityIdsSet){
        List<Project_Activity__c> activityList = new List<Project_Activity__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add(FIELD_NAME_SITE_NAME);
        orderFields.add(FIELD_NAME_SEQUENCE);
        orderFields.add(FIELD_NAME_PLANNED_START_DATE);
        
        for(sObject o: queryRelatedRecords(SObjectType.Project_Activity__c.FieldSets.Activity_Commons.getFields(), OBJECT_NAME_PROJECT_ACTIVITY, 'Id', null, activityIdsSet, null, orderFields, true, 0)){
            activityList.add((Project_Activity__c)o);
        }
        return activityList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Project Activity records with PSR = true based on Milestone Id Set
Inputs: Milestone Id Set
Returns: List<Project_Activity__c>
History
10/07/14    Michael Lasala      Created
02/04/15    Samuel Oberes       In the OrderField parameter position, replaced FIELD_NAME_PLANNED_START_DATE with orderFields so that the projectActivityList of the generateContent method of IMP_StatusReportGeneration_Controller may use this
05/28/15    Karl Simon          Updated the fields to add to the string driving (Order By) sorting; sort now incluldes planned end date and sequence
------------------------------------------------------------*/
    public static List<Project_Activity__c> retrievePSRActivities(Set<Id> milestonesIds){
        List<Project_Activity__c> activityList = new List<Project_Activity__c>();
        
        // String orderFields = FIELD_NAME_SEQUENCE + ', ' + FIELD_NAME_PLANNED_START_DATE;
        String OrderFields = FIELD_NAME_PLANNED_END_DATE + ', ' + FIELD_NAME_SEQUENCE;
        
        for(sObject o: queryRelatedActiveRecords(SObjectType.Project_Activity__c.FieldSets.Activity_Commons.getFields(), 
                                                 OBJECT_NAME_PROJECT_ACTIVITY, 
                                                 OBJECT_NAME_MILESTONE, 
                                                 null, 
                                                 milestonesIds, 
                                                 orderFields, 
                                                 FIELD_NAME_DISPLAY_PSR)){
            activityList.add((Project_Activity__c)o);
        }
        return activityList;
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Retrieve related Project Task records with PSR = true based on Activity Ids Set
    Inputs:      Activity Ids Set
    Returns:     List<Project_Task__c>
    History
    08/11/15     Samuel Oberes       Created
    08/18/15     Samuel Oberes       Updated: replaced OBJECT_NAME_MILESTONE with OBJECT_NAME_MILESTONE_ID, and replaced parameter activityIdsSet to milestoneIds
    ------------------------------------------------------------*/
    public static List<Project_Task__c> retrievePSRTasks(Set<Id> milestonesIds)
    {
        List<Project_Task__c> taskList = new List<Project_Task__c>();
        
        String orderFields = FIELD_NAME_PLANNED_END_DATE + ', ' + FIELD_NAME_SEQUENCE;
        
        // SELECT Task_Commons FROM Project_Task__c WHERE SubProject_ID__c IN :milestonesIds AND Display_On_PSR__c = true ORDER BY orderFields
        for(sObject o: queryRelatedActiveRecords(SObjectType.Project_Task__c.FieldSets.Task_Commons.getFields(), 
                                                 OBJECT_NAME_PROJECT_TASK, 
                                                 OBJECT_NAME_MILESTONE_ID, 
                                                 null, 
                                                 milestonesIds, 
                                                 orderFields, 
                                                 FIELD_NAME_DISPLAY_PSR)){
            taskList.add((Project_Task__c)o);
        }
        return taskList;
    }
    
    /*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Retrieve related Activity Definition records based on Milestone Definition Id Set
Inputs: Milestone Definitions Id
Returns: List<Activity_Definition__c>
History
07/23/15    Rey Austral      Created
------------------------------------------------------------*/
    public static List<Activity_Definition__c> retrieveActivityDefinitionsBySet(Set<Id> milestonesIds){
        List<Activity_Definition__c> activityDefinitionList = new List<Activity_Definition__c>();
        for(sObject o: queryRelatedRecordsWithAndCriteria_3(SObjectType.Activity_Definition__c.FieldSets.Activity_Definition_Commons.getFields(), OBJECT_NAME_ACTIVITY_DEFINITION, OBJECT_NAME_MILESTONE_DEFINITION, milestonesIds, 'Count_of_Children_Non_RMS_Owned__c', OPERATOR_RELATIONAL_GREATER_THAN ,0, null)){
            activityDefinitionList.add((Activity_Definition__c)o);
        }
        return activityDefinitionList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Activity Definition records based on Milestone Definition Id
Inputs: Milestone Definition Id
Returns: List<Activity_Definition__c>
History
09/05/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Activity_Definition__c> retrieveActivityDefinitions(Id milestoneId){
        List<Activity_Definition__c> activityDefinitionList = new List<Activity_Definition__c>();
        for(sObject o: queryRelatedActiveRecords(SObjectType.Activity_Definition__c.FieldSets.Activity_Definition_Commons.getFields(), OBJECT_NAME_ACTIVITY_DEFINITION, OBJECT_NAME_MILESTONE_DEFINITION, milestoneId, null, FIELD_NAME_SEQUENCE, FIELD_NAME_ACTIVE)){
            activityDefinitionList.add((Activity_Definition__c)o);
        }
        return activityDefinitionList;
    }
  */  
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve all Dealership (Question_Category__c) records
Inputs: None
Returns: List<Question_Category__c>
History
10/10/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Question_Category__c> retrieveDealerships(){
        List<Question_Category__c> dealershipList = new List<Question_Category__c>();
        for(sObject o: queryRelatedActiveRecords(SObjectType.Question_Category__c.FieldSets.Dealership_Commons.getFields(), OBJECT_NAME_QUESTION_CATEGORY, null, null, null, FIELD_NAME_RECORD, FIELD_NAME_ACTIVE)){
            dealershipList.add((Question_Category__c)o);
        }
        return dealershipList;
    }
    
 */   /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve all Dealership (Question_Category__c) records with Questions
Inputs: None
Returns: List<Question_Category__c>
History
10/14/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Question_Category__c> retrieveDealershipsWithQuestions(){
        List<Question_Category__c> dealershipList = new List<Question_Category__c>();
        for(sObject o: queryRelatedActiveRecords(SObjectType.Question_Category__c.FieldSets.Dealership_Commons.getFields(), OBJECT_NAME_QUESTION_CATEGORY, null, null, null, FIELD_NAME_RECORD, FIELD_NAME_ACTIVE)){
            if(Integer.valueOf(o.get('Number_of_Questions__c')) > 0){
                dealershipList.add((Question_Category__c)o);    
            }
        }
        return dealershipList;
    }
  */  
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve all Solution records based on Dealership (Question_Category__c) Id
Inputs: Parent Id
Returns: List<Solution__c>
History
10/10/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Solution__c> retrieveSolutions(String dealershipId){ 
        List<Solution__c> solutionList = new List<Solution__c>();
        for(sObject o: queryRelatedActiveRecords(SObjectType.Solution__c.FieldSets.Solution_Commons.getFields(), OBJECT_NAME_SOLUTION, OBJECT_NAME_QUESTION_CATEGORY, dealershipId, null, FIELD_NAME_RECORD, FIELD_NAME_ACTIVE)){
            solutionList.add((Solution__c)o);
        }
        return solutionList;
    }
  */  
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve all Products records based on Parent Id Set
Inputs: Parent Id Set
Returns: List<Product__c>
History
10/10/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Product__c> retrieveProducts(String parentField, Set<Id> parentIdSet){ 
        List<Product__c> productList = new List<Product__c>();
        for(sObject o: queryRelatedActiveRecords(SObjectType.Product__c.FieldSets.Product_Commons.getFields(), OBJECT_NAME_PRODUCT, parentField, null, parentIdSet, FIELD_NAME_RECORD, FIELD_NAME_ACTIVE)){
            productList.add((Product__c)o);
        }
        return productList;
    }
 */   
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related SubProject Products based on SubProject Id
Inputs: SubProject Id
Returns: List<SubProject_Product__c>
History
10/10/14    Michael Lasala      Created
------------------------------------------------------------*/
    /* 2015-8-14 Kimiko Roberto - Commented out method
    public static List<SubProject_Product__c> retrieveSubProjectProduct(Id subProjectId){
        List<SubProject_Product__c> subProjectProductList = new List<SubProject_Product__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add('Product__r.Name');
        
        for(sObject o: queryRelatedRecords(SObjectType.SubProject_Product__c.FieldSets.SubProject_Product_Commons.getFields(), OBJECT_NAME_SUBPROJECT_PRODUCT, OBJECT_NAME_SUBPROJECT, subProjectId, null, null, orderFields, true, 0)){
            subProjectProductList.add((SubProject_Product__c)o);
        }
        return subProjectProductList;
    }*/
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related CDK Contact records based on Sub Project Id Set
Inputs: SubProject Id Set
Returns: List<SubProject_CDK_Contact__c>
History
10/01/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<SubProject_CDK_Contact__c> retrieveCDKContactsBySet(Set<Id> subProjectIds){
        List<SubProject_CDK_Contact__c> cdkContactList = new List<SubProject_CDK_Contact__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add(FIELD_NAME_CREATEDDATE);
        
        for(sObject o: queryRelatedRecords(SObjectType.SubProject_CDK_Contact__c.FieldSets.CDK_Contact_Commons.getFields(), OBJECT_NAME_SUBPROJECT_CDK_CONTACT, OBJECT_NAME_SUBPROJECT, null, subProjectIds, null, orderFields, true, 0)){
            cdkContactList.add((SubProject_CDK_Contact__c)o);
        }
        return cdkContactList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related CDK Contact records of based on Sub Project Id Set
Inputs: SubProject Id Set
Returns: List<SubProject_Client_Contact__c>
History
10/01/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<SubProject_Client_Contact__c> retrieveClientContactsBySet(Set<Id> subProjectIds){
        List<SubProject_Client_Contact__c> clientContactList = new List<SubProject_Client_Contact__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add(FIELD_NAME_CREATEDDATE);
        
        for(sObject o: queryRelatedRecords(SObjectType.SubProject_Client_Contact__c.FieldSets.Client_Contact_Commons.getFields(), OBJECT_NAME_SUBPROJECT_CLIENT_CONTACT, OBJECT_NAME_SUBPROJECT, null, subProjectIds, null, orderFields, true, 0)){
            clientContactList.add((SubProject_Client_Contact__c)o);
        }
        return clientContactList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related User records based on Id set
Inputs: User Id set
Returns: List<User>
History
10/13/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<User> retrieveUserBySet(Set<Id> userIdSet, List<String> userIdList){
        List<User> userList = new List<User>();
        for(sObject o: queryRelatedRecords(SObjectType.User.FieldSets.User_Commons.getFields(), OBJECT_NAME_USER, QUERY_NAME_ID, null, userIdSet, userIdList, null, true, 0)){
            userList.add((User)o);
        }
        return userList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related SubProject External Related Entity records based on SubProject and Entity Type
Inputs: SubProject Id, Entity Type criteria
Returns: List<SubProject_External_Related_Entity__c>
History
10/13/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<SubProject_External_Related_Entity__c> retrieveExternalRelatedEntity(Id subProjectId, String entityType){
        List<SubProject_External_Related_Entity__c> externalRelatedEntityList = new List<SubProject_External_Related_Entity__c>();
        for(sObject o: queryRelatedEntityRecords(SObjectType.SubProject_External_Related_Entity__c.FieldSets.External_Related_Entity_Commons.getFields(), OBJECT_NAME_SUBPROJECT_EXTERNAL_RELATED_ENTITY, OBJECT_NAME_SUBPROJECT, subProjectId, FIELD_NAME_ENTITY_TYPE, entityType)){
            externalRelatedEntityList.add((SubProject_External_Related_Entity__c)o);
        }
        return externalRelatedEntityList;
    }
 */   
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related SubProject External Reference records based on SubProject and Record Type Name
Inputs: SubProject Id, Record Type Name
Returns: List<SubProject_External_Reference__c>
History
10/13/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<SubProject_External_Reference__c> retrieveExternalReference(Id subProjectId, String recordTypeName){
        List<SubProject_External_Reference__c> externalReferenceList = new List<SubProject_External_Reference__c>();
        for(sObject o: queryRelatedEntityRecords(SObjectType.SubProject_External_Reference__c.FieldSets.External_Reference_Commons.getFields(), OBJECT_NAME_SUBPROJECT_EXTERNAL_REFERENCE, OBJECT_NAME_SUBPROJECT, subProjectId, FIELD_NAME_RECORD_TYPE_NAME, recordTypeName)){
            externalReferenceList.add((SubProject_External_Reference__c)o);
        }
        return externalReferenceList;
    }
  */  
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related SubProject Opp records based on SubProject Id
Inputs: SubProject Id
Returns: List<SubProjectOpp__c>
History
10/13/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<SubProjectOpp__c> retrieveSubProjectOpps(Id subProjectId){
        List<SubProjectOpp__c> externalReferenceList = new List<SubProjectOpp__c>();
        for(sObject o: queryRelatedRecords(SObjectType.SubProjectOpp__c.FieldSets.SubProject_Opp_Commons.getFields(), OBJECT_NAME_SUBPROJECT_OPP, OBJECT_NAME_SUBPROJECT, subProjectId, null, null, null, true, 0)){
            externalReferenceList.add((SubProjectOpp__c)o);
        }
        return externalReferenceList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Discovery Answer records based on Discovery Workbook Category Id
Inputs: Discovery Workbook Category Id
Returns: List<Answer__c>
History
10/14/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Answer__c> retrieveAnswers(Id discoveryWorkbookCategoryId){
        List<Answer__c> answerList = new List<Answer__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add(FIELD_NAME_LASTMODIFIEDDATE);
        
        for(sObject o: queryRelatedRecords(SObjectType.Answer__c.FieldSets.Answer_Commons.getFields(), OBJECT_NAME_ANSWER, OBJECT_NAME_DISCOVERY_WORKBOOK_CATEGORY, discoveryWorkbookCategoryId, null, null, orderFields, false, 1)){
            answerList.add((Answer__c)o);
        }
        return answerList;
    }
  */  
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Active Discovery Question records based on Question Category Id/List<Id>
Inputs: Question Category Id/List<Id>
Returns: List<Question__c>
History
10/14/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Question__c> retrieveActiveQuestions(Id questionCategoryId, List<Question_Category__c> questionCategoryList){
        List<Question__c> questionList = new List<Question__c>();
        
        Set<Id> questionCategoryIdSet = new Set<Id>();
        
        if(questionCategoryList != null && !questionCategoryList.isEmpty()){
            for(Question_Category__c qc: questionCategoryList){
                questionCategoryIdSet.add(qc.Id);
            }           
        }
        
        for(sObject o: queryRelatedActiveRecords(SObjectType.Question__c.FieldSets.Question_Commons.getFields(), OBJECT_NAME_QUESTION, OBJECT_NAME_QUESTION_CATEGORY, questionCategoryId, questionCategoryIdSet, FIELD_NAME_ORDER, FIELD_NAME_ACTIVE)){
            questionList.add((Question__c)o);
        }
        return questionList;
    }
  */  
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Discovery Workbook Interviewee records based on Discovery Workbook Category Id/Record Id set
Inputs: Discovery Workbook Category Id, Id List, Parent field name
Returns: List<Discovery_Workbook_Interviewee__c>
History
10/14/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Discovery_Workbook_Interviewee__c> retrieveWorkbookInterviewees(Id discoveryWorkbookCategoryId, List<Id> idList, String parentFieldName){
        List<Discovery_Workbook_Interviewee__c> workbookIntervieweeList = new List<Discovery_Workbook_Interviewee__c>();
        
        Set<Id> idSet = new Set<Id>();
        
        if(idList != null && !idList.isEmpty()){
            //Convert to Set<Id>
            idSet.addAll(idList);
        }
        
        for(sObject o: queryRelatedRecords(SObjectType.Discovery_Workbook_Interviewee__c.FieldSets.Interviewee_Commons.getFields(), OBJECT_NAME_DISCOVERY_WORKBOOK_INTERVIEWEE, parentFieldName, discoveryWorkbookCategoryId, idSet, null, null, true, 0)){
            workbookIntervieweeList.add((Discovery_Workbook_Interviewee__c)o);
        }
        return workbookIntervieweeList;
    }
 */   
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Discovery Workbook Interviewer records based on Discovery Workbook Category Id/Record Id set
Inputs: Discovery Workbook Category Id, Id List, Parent field name
Returns: List<Discovery_Workbook_Interviewer__c>
History
10/14/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Discovery_Workbook_Interviewer__c> retrieveWorkbookInterviewers(Id discoveryWorkbookCategoryId, List<Id> idList, String parentFieldName){
        List<Discovery_Workbook_Interviewer__c> workbookInterviewerList = new List<Discovery_Workbook_Interviewer__c>();
        
        Set<Id> idSet = new Set<Id>();
        
        if(idList != null && !idList.isEmpty()){
            //Convert to Set<Id>
            idSet.addAll(idList);
        }
        
        for(sObject o: queryRelatedRecords(SObjectType.Discovery_Workbook_Interviewer__c.FieldSets.Interviewer_Commons.getFields(), OBJECT_NAME_DISCOVERY_WORKBOOK_INTERVIEWER, parentFieldName, discoveryWorkbookCategoryId, idSet, null, null, true, 0)){
            workbookInterviewerList.add((Discovery_Workbook_Interviewer__c)o);
        }
        return workbookInterviewerList;
    }
*/    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Discovery Workbook Interviewee records based on Discovery Workbook Category Id and Interviewer Id
Inputs: Discovery Work Category Id, Filter 2 field name, Filter 2 Id
Returns: List<Discovery_Workbook_Interviewee__c>
History
10/14/14    Michael Lasala      Created
12/12/14    Samuel Oberes       Added parameter OPERATOR_RELATIONAL_EQUAL to determine equality between filter2FieldName and filter2Id
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
  /*  public static List<Discovery_Workbook_Interviewee__c> retrieveIntervieweesWithAndCriteria(Id discoveryWorkbookCategoryId, String filter2FieldName, Id filter2Id){
        List<Discovery_Workbook_Interviewee__c> workbookIntervieweeList = new List<Discovery_Workbook_Interviewee__c>();
        for(sObject o: queryRelatedRecordsWithAndCriteria(SObjectType.Discovery_Workbook_Interviewee__c.FieldSets.Interviewee_Commons.getFields(), OBJECT_NAME_DISCOVERY_WORKBOOK_INTERVIEWEE, 'Discovery_Workbook_Category__c', discoveryWorkbookCategoryId, filter2FieldName, OPERATOR_RELATIONAL_EQUAL, filter2Id, null)){
            workbookIntervieweeList.add((Discovery_Workbook_Interviewee__c)o);
        }
        return workbookIntervieweeList;
    }
 */   
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Discovery Workbook Interviewer records based on Discovery Workbook Category Id and Interviewer Id
Inputs: Discovery Work Category Id, Filter 2 field name, Filter 2 Id
Returns: List<Discovery_Workbook_Interviewer__c>
History
10/14/14    Michael Lasala      Created
12/12/14    Samuel Oberes       Added parameter OPERATOR_RELATIONAL_EQUAL to determine equality between filter2FieldName and filter2Id
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
  /*  public static List<Discovery_Workbook_Interviewer__c> retrieveInterviewersWithAndCriteria(Id discoveryWorkbookCategoryId, String filter2FieldName, Id filter2Id){
        List<Discovery_Workbook_Interviewer__c> workbookInterviewerList = new List<Discovery_Workbook_Interviewer__c>();
        for(sObject o: queryRelatedRecordsWithAndCriteria(SObjectType.Discovery_Workbook_Interviewer__c.FieldSets.Interviewer_Commons.getFields(), OBJECT_NAME_DISCOVERY_WORKBOOK_INTERVIEWER, 'Discovery_Workbook_Category__c', discoveryWorkbookCategoryId, filter2FieldName, OPERATOR_RELATIONAL_EQUAL, filter2Id, null)){
            workbookInterviewerList.add((Discovery_Workbook_Interviewer__c)o);
        }
        return workbookInterviewerList;
    }
  */  
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Discovery Question Products records based on Product Set Id and Subquery
Inputs: Product List Id, Subquery String
Returns: List<Discovery_Question_Product__c>
History
10/14/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<Discovery_Question_Product__c> retrieveQuestionProductBySet(Set<String> productIdSet, String subQuery){
        List<Discovery_Question_Product__c> questionProductList = new List<Discovery_Question_Product__c>();
        
        //Convert Set<String> to Set<Id>
        Set<Id> idSet = buildIdSet(productIdSet, null);
        
        for(sObject o: queryWithSubquery(SObjectType.Discovery_Question_Product__c.FieldSets.Question_Product_Commons.getFields(), OBJECT_NAME_DISCOVERY_QUESTION_PRODUCT, OBJECT_NAME_PRODUCT, null, idSet, subQuery, false, null)){
            questionProductList.add((Discovery_Question_Product__c)o);
        }
        return questionProductList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Solutions records along with its' Products based on Question Category Id
Inputs: Question Category Id, Subquery String
Returns: List<Solution__c>
History
10/14/14    Michael Lasala      Created
10/21/14    Michael Lasala      Added filter parameter
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
/*    public static List<Solution__c> retrieveSolutionsWithSubquery(Id questionCategoryId, String subQuery, String additionalFilter){
        List<Solution__c> solutionList = new List<Solution__c>();
        for(sObject o: queryWithSubquery(SObjectType.Solution__c.FieldSets.Solution_Commons.getFields(), OBJECT_NAME_SOLUTION, OBJECT_NAME_QUESTION_CATEGORY, questionCategoryId, null, subQuery, true, additionalFilter)){
            solutionList.add((Solution__c)o);
        }
        return solutionList;
    }
 */   
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Discovery Site Workbook records based on Project Id
Inputs: Project Id
Returns: List<Site_Workbook__c>
History
10/14/14    Michael Lasala      Created
11/26/14    Samuel Oberes       To avoid redundancy, main logic was relocated to retrieveSiteWorkbooks_MainLogic
------------------------------------------------------------*/
    public static List<Site_Workbook__c> retrieveSiteWorkbooks(String projectId){
        retrieveSiteWorkbook_projectId = projectId;
        List<Site_Workbook__c> workbooklistToReturn = IMP_Project_Utility.retrieveSiteWorkbooks_MainLogic();
        retrieveSiteWorkbook_projectId = null;
        return workbooklistToReturn;
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Retrieve related Discovery Site Workbook records based on a set of Project IDs
Inputs:      Set<Project-Id>
Returns:     List<Site_Workbook__c>
History
11/26/14     Samuel Oberes       Created
------------------------------------------------------------*/
    public static List<Site_Workbook__c> retrieveSiteWorkbooks(Set<Id> projectIds){
        retrieveSiteWorkbook_projectIds = projectIds;
        List<Site_Workbook__c> workbooklistToReturn = IMP_Project_Utility.retrieveSiteWorkbooks_MainLogic();
        retrieveSiteWorkbook_projectIds = null;
        return workbooklistToReturn;
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: The main logic of retrieveSiteWorkbooks, abstracted. This removes redundancy between the 2 overloaded methods.
Inputs:      None
Returns:     List<Site_Workbook__c>
History
11/26/14     Samuel Oberes       Created
------------------------------------------------------------*/
    private static List<Site_Workbook__c> retrieveSiteWorkbooks_MainLogic() {
        List<Site_Workbook__c> siteWorkbookList = new List<Site_Workbook__c>();
        
        String projectId = retrieveSiteWorkbook_projectId;
        Set<Id> projectIds = retrieveSiteWorkbook_projectIds;
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add(FIELD_NAME_CREATEDDATE);
        
        for(sObject o: queryRelatedRecords(SObjectType.Site_Workbook__c.FieldSets.Site_Workbook_Commons.getFields(), OBJECT_NAME_DISCOVERY_SITE_WORKBOOK, OBJECT_NAME_PROJECT, projectId, projectIds, null, orderFields, false, 0)){
            siteWorkbookList.add((Site_Workbook__c)o);
        }
        return siteWorkbookList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve Project record along with its' Site Workbooks based on record Id
Inputs: Project Id, Subquery String
Returns: List<Project__c>
History
10/14/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Project__c> retrieveProjectWithSubquery(Id projectId, String subQuery){
        List<Project__c> projectList = new List<Project__c>();
        for(sObject o: queryWithSubquery(SObjectType.Project__c.FieldSets.Project_Commons.getFields(), OBJECT_NAME_PROJECT, QUERY_NAME_ID, projectId, null, subQuery, true, null)){
            projectList.add((Project__c)o);
        }
        return projectList;
    }
  */  
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve Discovery Workbook Category records along with its' Answers based on Site Workbook Ids
Inputs: List of Site Workbook records, Subquery String
Returns: List<Discovery_Workbook_Category__c>
History
10/14/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<Discovery_Workbook_Category__c> retrieveWorkborkCategoryWithSubquery(List<Site_Workbook__c> siteWorkbookList, String subQuery){
        List<Discovery_Workbook_Category__c> workbookCategoryList = new List<Discovery_Workbook_Category__c>();
        
        if(!siteWorkbookList.isEmpty()){
            
            //Convert List<Site_Workbook__c> to Set<Id>
            Set<Id> siteWorkbookIdSet = buildIdSet(null, siteWorkbookList);
            
            for(sObject o: queryWithSubquery(SObjectType.Discovery_Workbook_Category__c.FieldSets.Site_Workbook_Category_Commons.getFields(), OBJECT_NAME_DISCOVERY_WORKBOOK_CATEGORY, 'Site_Workbook__c', null, siteWorkbookIdSet, subQuery, true, null)){
                workbookCategoryList.add((Discovery_Workbook_Category__c)o);
            }
        }
        return workbookCategoryList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve the Dealer Group Account from the CMF Info Object based upon a matching dealercmf number from Impact 
Inputs: DealerId, Filter 2 field name
Returns: List<CMF_Info__c>
History
10/14/14    Michael Lasala      Created
10/20/14    Michael Lasala      Removed filter for Main_CMF__c
12/12/14    Samuel Oberes       Added parameter OPERATOR_RELATIONAL_EQUAL to determine equality between filter2FieldName and mainCMFId
01/05/14    Kimiko Roberto      Changed mainCMFId parameter to be a list of string instead of a single string.
------------------------------------------------------------*/
    public static List<CMF_Info__c> retrieveCMFInfo(List<String> mainCMFId, String filter2FieldName){
        List<CMF_Info__c> cmfInfoList = new List<CMF_Info__c>();
        for(sObject o: queryRelatedRecordsWithAndCriteria_2(SObjectType.CMF_Info__c.FieldSets.CMF_Info_Commons.getFields(), OBJECT_NAME_CMF_INFO, 'Status__c', 'A', filter2FieldName, OPERATOR_RELATIONAL_IN, mainCMFId, null)){
            cmfInfoList.add((CMF_Info__c)o);
        }
        return cmfInfoList;
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Retrieve the project activities across subprojects
Inputs:  
Returns:     List<Project_Activity__c>
History
12/12/14     Samuel Oberes       Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<Project_Activity__c> retrieveProjectActivitiesAcrossSubprojects(Id cdkAssignee, IMP_Project_Utility.Enum_Operator_Relational statusRelation, String currentStatus, Map<Integer, Map<String, String>> orderBy){
        String statusIs;
        if (statusRelation == IMP_Project_Utility.Enum_Operator_Relational.EQUAL) {
            statusIs = OPERATOR_RELATIONAL_EQUAL;
        } else {
            statusIs = OPERATOR_RELATIONAL_NOT_EQUAL;
        }
        
        List<Project_Activity__c> projectActivityList = new List<Project_Activity__c>();
        for(sObject o: queryRelatedRecordsWithAndCriteria(SObjectType.Project_Activity__c.FieldSets.Activity_Commons.getFields(), 
                                                          OBJECT_NAME_PROJECT_ACTIVITY, 
                                                          'CDK_Assignee__c', cdkAssignee, 
                                                          'Status__c', statusIs, currentStatus,
                                                          orderBy)){
                                                              projectActivityList.add((Project_Activity__c)o);
                                                          }
        return projectActivityList;
    }
 */   
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Opportunity Quotes records based on Deal Id List
Inputs: Deal Id List
Returns: List<Opportunity_Quotes__c>
History
10/15/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<Opportunity_Quotes__c> retrieveOppQuotesBySet(List<String> dealIdList){
        List<Opportunity_Quotes__c> oppQuotesList = new List<Opportunity_Quotes__c>();
        for(sObject o: queryRelatedRecords(SObjectType.Opportunity_Quotes__c.FieldSets.Opportunity_Quotes_Commons.getFields(), OBJECT_NAME_OPPORTUNITY_QUOTES, 'Deal_ID__c', null, null, dealIdList, null, true, 0)){
            oppQuotesList.add((Opportunity_Quotes__c)o);
        }
        return oppQuotesList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related SubProject External Related Entity records based on SubProject Id set and OR criteria
Inputs: SubProject Ids, OR critiria Field API Name and Value map
Returns: List<SubProject_External_Related_Entity__c>
History
10/15/14    Michael Lasala      Created
12/24/14    Samuel Oberes       Extended functionality to accomodate set of project IDs
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
 /*   public static List<SubProject_External_Related_Entity__c> retrieveExternalRelatedEntityBySet(IMP_Project_Utility.Enum_RetrieveExternalRelatedEntityBySetsOf retrieveBy, Set<Id> setOfIdsToRetrieve, Map<String, List<String>> fieldValueMap){
        String RETRIEVE_BY_SETS_OF;
        if (retrieveBy == IMP_Project_Utility.Enum_RetrieveExternalRelatedEntityBySetsOf.PROJECTS) {
            RETRIEVE_BY_SETS_OF = OBJECT_NAME_PROJECT;
        } else if (retrieveBy == IMP_Project_Utility.Enum_RetrieveExternalRelatedEntityBySetsOf.SUBPROJECTS) {
            RETRIEVE_BY_SETS_OF = OBJECT_NAME_SUBPROJECT;
        }
        
        List<SubProject_External_Related_Entity__c> externalRelatedEntityList = new List<SubProject_External_Related_Entity__c>();
        for(sObject o: queryRelatedRecordsWithOrCriteria(SObjectType.SubProject_External_Related_Entity__c.FieldSets.External_Related_Entity_Commons.getFields(), OBJECT_NAME_SUBPROJECT_EXTERNAL_RELATED_ENTITY, RETRIEVE_BY_SETS_OF, setOfIdsToRetrieve, fieldValueMap)){
            externalRelatedEntityList.add((SubProject_External_Related_Entity__c)o);
        }
        return externalRelatedEntityList;
    }
   */ 
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related EntitySubscription records based on Parent Id/Set
Inputs: Parent Id/Set, SubProject list
Returns: List<EntitySubscription>
History
10/15/14    Michael Lasala      Created
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
  /*  public static List<EntitySubscription> retrieveEntitySubscription(Id parentId, Set<Id> parentIdSet, List<SubProject__c> subProjectList){
        List<EntitySubscription> entitySubscriptionList = new List<EntitySubscription>();
        
        //Build query string
        String query = 'SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId ';
        
        if(parentId != null){
            query += '=: parentId';
        }
        
        if(parentIdSet != null && !parentIdSet.isEmpty()){
            query += 'IN: parentIdSet';
        }
        
        if(subProjectList != null && !subProjectList.isEmpty()){
            query += 'IN: subProjectList';
        }
        
        try{
            for(sObject o: Database.query(query)){
                entitySubscriptionList.add((EntitySubscription)o);
            }
        } catch (QueryException e){
            System.debug(e.getMessage());
        }
        return entitySubscriptionList;
    }
   */ 
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Milestone Definition records based on Set
Inputs: Milestone Ids
Returns: List<Milestone_Definition__c>
History
09/15/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<Milestone_Definition__c> retrieveMilestonesDefinitionsBySet(Set<Id> milestonesIds){
        List<Milestone_Definition__c> milestoneDefinitionList = new List<Milestone_Definition__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add(FIELD_NAME_DESCRIPTION);
        
        for(sObject o: queryRelatedActiveRecords(SObjectType.Milestone_Definition__c.FieldSets.Milestone_Definition_Commons.getFields(), OBJECT_NAME_MILESTONE_DEFINITION, QUERY_NAME_ID, null, milestonesIds, FIELD_NAME_DESCRIPTION, FIELD_NAME_ACTIVE)){
            //for(sObject o: queryRelatedRecords(SObjectType.Milestone_Definition__c.FieldSets.Milestone_Definition_Commons.getFields(), OBJECT_NAME_MILESTONE_DEFINITION, QUERY_NAME_ID, null, milestonesIds, null, orderFields, true, 0)){
            milestoneDefinitionList.add((Milestone_Definition__c)o);
        }
        return milestoneDefinitionList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Milestone Definition Ids from Project Milestone Definition Product based on SubProject Market
Inputs: Market
Returns: Set<Id>
History
10/22/14    Michael Lasala      Created
09/21/15    Rey Austral         add Milestone_Definition__r.RMS_Activity_Code__c = NULL in the where condition to only select non rms definition
------------------------------------------------------------*/
    public static Set<Id> retrieveMilestoneDefinitionProductsIdSet(String market){
        Set<Id> projectMilestoneDefinitionProductIdSet = new Set<Id>();
        
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : SObjectType.Project_Milestone_Definition_Product__c.FieldSets.Milestone_Definition_Product_Commons.getFields()){
            query += f.getFieldPath() + ',';
        }
        
        query = query.subString(0, query.length() - 1); //trim last comma
        
        //Build FROM and WHERE clause
        query += ' FROM ' + OBJECT_NAME_PROJECT_MILESTONE_DEFINITION_PRODUCT + ' WHERE Milestone_Definition__r.Market__c INCLUDES (:market) AND Milestone_Definition__r.RMS_Activity_Code__c = NULL';
        
        try{
            for(sObject o: Database.query(query)){
                projectMilestoneDefinitionProductIdSet.add((Id)o.get(OBJECT_NAME_MILESTONE_DEFINITION));
            }
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
        }
        return projectMilestoneDefinitionProductIdSet;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Build Product Id set to be used for query parameters
Inputs: SubProject Id
Returns: Product Id set
History
09/15/14    Michael Lasala      Created
------------------------------------------------------------*/
    /* 2015-8-14 Kimiko Roberto - Commented out method
    public static Set<Id> retrieveProductIds(String subProjectId){
        List<SubProject_Product__c> subProjectProductList = new List<SubProject_Product__c>();
        Set<Id> productIds = new Set<Id>();
        
        subProjectProductList = [SELECT Product__c FROM SubProject_Product__c WHERE SubProject__c =: subProjectId];
        for(SubProject_Product__c sp: subProjectProductList){
            productIds.add(sp.Product__c);
        }
        return productIds;
    }*/
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve related Project Activity records of all related Milestones
Inputs: Project Type, Product Ids, Market
Returns: List<Milestone_Definition__c>
History
09/15/14    Michael Lasala      Created
09/16/14    Michael Lasala      Added market parameter
10/07/14    Samuel Oberes       Added ORDER BY clause to milestoneDefinitionList list's query (related to Defect 56)
------------------------------------------------------------*/
    public static List<Milestone_Definition__c> retrieveProjectTypeProductMilestoneDefinitionList(String projectType, String market, Boolean isCreation){
        Set<Id> productMarketIds = new Set<Id>();
        
        //if(isCreation != true){
        //for(Project_Milestone_Definition_Product__c pmdp: [SELECT Milestone_Definition__c 
        //                                                   FROM   Project_Milestone_Definition_Product__c 
        //                                                   WHERE  Milestone_Definition__r.Market__c INCLUDES (:market)]){
        
        //                                                       productMarketIds.add(pmdp.Milestone_Definition__c);
        //                                                   }
        //}
        
        List<Milestone_Definition__c> milestoneDefinitionList = new List<Milestone_Definition__c>();
        
        milestoneDefinitionList = [SELECT   Id, 
                                   Name,
                                   Description__c,
                                   Sort_Sequence__c,
                                   Process_Step__c
                                   FROM     Milestone_Definition__c 
                                   WHERE    Active__c = true
                                   AND      ((Project_Type__c INCLUDES (:projectType)
                                              AND        Market__c INCLUDES (:market))
                                             OR        Id IN: productMarketIds)
                                            AND Count_of_Children_Non_RMS_Owned__c > 0
                                   ORDER BY Description__c];
        
        return milestoneDefinitionList;
    }
    
    //============================================================
    //                   QUERY UTILITY METHODS
    //============================================================
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Common method to query a single record using field set and different parameters
Inputs: Field Set, Object API Name, Record Id/Name
Returns: sObject
History
09/05/14    Michael Lasala      Created
10/11/14    Michael Lasala      Added recordName parameter
------------------------------------------------------------*/
    public static sObject querySingleRecord(List<Schema.FieldSetMember> fieldSetMembers, String objectName, String recordId, String recordName){
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : fieldSetMembers){
            query += f.getFieldPath() + ',';
        }
        
        query = query.subString(0, query.length() - 1); //trim last comma
        
        //Build FROM and WHERE clause
        query += ' FROM ' + objectName + ' WHERE ';
        
        System.debug('$$$ objectName: '+objectName);
        
        //If record Id is present, assign as filter
        if(recordId != null){
            query += QUERY_NAME_ID+' =: recordId';
            System.debug('$$$ '+QUERY_NAME_ID+': '+recordId);
        }
        
        //If record Name is present, assign as filter
        if(recordName != null){
            query += FIELD_NAME_RECORD+' =: recordName';
            System.debug('$$$ '+FIELD_NAME_RECORD+': '+recordName);
        }
        System.debug('$$$ query: '+query);
        
        try{
            return Database.query(query);
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(objectName);
            return targetObject.newSObject();
        }
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Common method to query child records of a parent Id/Set using field set with sorting order and record limit
Inputs: Field Set, Object API Name, Parent Field Name, Parent Record Id, Parent Record Id set, String list, Order By Field List, ASC/DESC Boolean, Record Limit
Returns: List<sObject>
History
09/05/14    Michael Lasala      Created
10/10/14    Michael Lasala      Added parameter for parent Id set and order by fields
10/13/14    Michael Lasala      Added parameter for sort order and record limit 
------------------------------------------------------------*/
    public static List<sObject> queryRelatedRecords(List<Schema.FieldSetMember> fieldSetMembers, String objectName, String parentObjectFieldName, String parentRecordId, Set<Id> parentRecordIdSet, List<String> stringList, List<String> orderFieldList, Boolean isAsc, Integer recordLimit){
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : fieldSetMembers){
            query += f.getFieldPath() + ',';
        }
        
        query = query.subString(0, query.length() - 1); //trim last comma
        
        //Build FROM and WHERE clause
        query += ' FROM ' + objectName + ' WHERE ';
        
        System.debug('$$$ objectName: '+objectName);
        
        //Add filter if Parent Record Id is present
        if(parentRecordId != null){
            query += parentObjectFieldName + ' =: parentRecordId';
            System.debug('$$$ '+parentObjectFieldName+': '+parentRecordId);
        }
        
        if(parentRecordIdSet != null || stringList != null){
            
            //Add filter if Record Id Set is present
            if(parentRecordIdSet != null && !parentRecordIdSet.isEmpty()){
                query += parentObjectFieldName + ' IN: parentRecordIdSet';
                System.debug('$$$ '+parentObjectFieldName+' IN: ('+ String.join(new List<Id>(parentRecordIdSet), ',') + ')');
            }
            
            //Add filter if List string is present
            if(stringList != null && !stringList.isEmpty()){
                query += parentObjectFieldName + ' IN: stringList';
                System.debug('$$$ '+parentObjectFieldName+' IN: '+stringList);
            }
        }
        
        if(orderFieldList != null && !orderFieldList.isEmpty()){
            
            //Build Order By clause
            query += ' ORDER BY ';
            
            //Identify order if ASC/DESC
            String orderBy = '';
            if(isAsc){
                orderBy = 'ASC';
            } else{
                orderBy = 'DESC';
            }
            
            //Iterate over order field list and add to query
            for(String field: orderFieldList){
                query += field+' '+orderBy+' NULLS LAST,';
                System.debug('$$$ ORDER BY: '+field+' = '+orderBy);
            }
            
            query = query.subString(0, query.length() - 1); //trim last comma
        }
        
        //Add limit if parameter is present
        if(recordLimit > 0){
            query += ' LIMIT '+recordLimit;
            System.debug('$$$ LIMIT: '+recordLimit);
        }
        System.debug('$$$ query: '+query);
        
        try{
            return Database.query(query);
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new list of sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(objectName);
            List<sObject> targetObjectList = new List<sObject>();
            targetObjectList.add(targetObject.newSObject());
            return targetObjectList;
        }
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Common method to query child records of a parent Id/Set using field set with 2 AND clauses
Inputs: Field Set, Object API Name, Filter 1 Field Name, Filter 1 Id, Filter 2 Field Name, Filter 2 Id
Returns: List<sObject>
History
10/14/14    Michael Lasala      Created
12/12/14    Samuel Oberes       Added parameter relationOfField2ToRecordId2 to determine the operator (equal or not)
12/16/14    Samuel Oberes       Updated the order by approach
------------------------------------------------------------*/
    public static List<sObject> queryRelatedRecordsWithAndCriteria(List<Schema.FieldSetMember> fieldSetMembers, String objectName, String filterFieldName, String filterRecordId, String filter2FieldName, String relationOfField2ToRecordId2, String filter2RecordId, Map<Integer, Map<String, String>> orderBy){
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : fieldSetMembers){
            query += f.getFieldPath() + ',';
        }
        
        query = query.subString(0, query.length() - 1); //trim last comma
        
        //Construct Object source and parent field filter
        query += ' FROM ' + objectName;
        
        System.debug('$$$ objectName: '+objectName);
        
        //Add filter if Record Id is present
        if(filterRecordId != null){
            
            query += ' WHERE '+filterFieldName + ' =: filterRecordId';
            System.debug('$$$ filterFieldName: '+filterRecordId);
        }
        
        //Add filter 2 if Record Id is present
        if(filter2RecordId != null){
            
            if(filterRecordId != null){
                query += ' AND ';
            } else {
                query += ' WHERE ';
            }
            
            query += filter2FieldName + ' ' + relationOfField2ToRecordId2 + ' :filter2RecordId';
            System.debug('$$$ filter2FieldName: '+filter2RecordId);
        }
        
        if (orderBy != null) {
            query += ' ORDER BY ';
            for (Integer orderPositionToOrderFieldsMap : orderBy.keySet()) {
                Map<String, String> orderFieldsToOrderDirectionMap = orderBy.get(orderPositionToOrderFieldsMap);
                for (String orderFields : orderFieldsToOrderDirectionMap.keySet()) {
                    query += orderFields + ' ' + orderFieldsToOrderDirectionMap.get(orderFields) + ',';
                }
            }
            query = query.subString(0, query.length() - 1); //trim last comma
        }
        System.debug('$$$ query: '+query);
        
        try{
            return Database.query(query);
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new list of sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(objectName);
            List<sObject> targetObjectList = new List<sObject>();
            targetObjectList.add(targetObject.newSObject());
            return targetObjectList;
        }
    }
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: 
    Inputs: Field Set, Object API Name, Filter 1 Field Name, Filter 1 Id, Filter 2 Field Name, Filter 2 Id
    Returns: List<sObject>
    History
    07/23/15    Rey Austral      Created
    ------------------------------------------------------------*/
    public static List<sObject> queryRelatedRecordsWithAndCriteria_3(List<Schema.FieldSetMember> fieldSetMembers, String objectName, String filterFieldName, Set<Id> filterRecordId, String filter2FieldName, String relationOfField2ToRecordId2, Integer filter2ComparisionValue, Map<Integer, Map<String, String>> orderBy){
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : fieldSetMembers){
            query += f.getFieldPath() + ',';
        }
        
        query = query.subString(0, query.length() - 1); //trim last comma
        
        //Construct Object source and parent field filter
        query += ' FROM ' + objectName;
        
        System.debug('$$$ objectName: '+objectName);
        
        //Add filter if Record Id is present
        if(filterRecordId != null){
            
            query += ' WHERE '+filterFieldName + ' IN: filterRecordId';
            System.debug('$$$ filterFieldName: '+filterRecordId);
        }
        
        //Add filter 2 if Record Id is present
        if(filter2ComparisionValue != null){
            
            if(filterRecordId != null){
                query += ' AND ';
            } else {
                query += ' WHERE ';
            }
            
            query += filter2FieldName + ' ' + relationOfField2ToRecordId2 + ' :filter2ComparisionValue';
            System.debug('$$$ filter2ComparisionValue: '+filter2ComparisionValue);
        }
        
        if (orderBy != null) {
            query += ' ORDER BY ';
            for (Integer orderPositionToOrderFieldsMap : orderBy.keySet()) {
                Map<String, String> orderFieldsToOrderDirectionMap = orderBy.get(orderPositionToOrderFieldsMap);
                for (String orderFields : orderFieldsToOrderDirectionMap.keySet()) {
                    query += orderFields + ' ' + orderFieldsToOrderDirectionMap.get(orderFields) + ',';
                }
            }
            query = query.subString(0, query.length() - 1); //trim last comma
        }
        System.debug('$$$ query: '+query);
        
        try{
            return Database.query(query);
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new list of sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(objectName);
            List<sObject> targetObjectList = new List<sObject>();
            targetObjectList.add(targetObject.newSObject());
            return targetObjectList;
        }
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Common method to query Active records with or without a parent/parent Id set using field set and with single field sorting
Inputs: Field Set, Object API Name, Parent Field Name, Parent Id, Parent Id Set, Order By Field API Name, Active field Name
Returns: List<sObject>
History
09/05/14    Michael Lasala      Created
10/10/14    Michael Lasala      Modified method to accept no filter, parent Id filter and parent Id set filter
------------------------------------------------------------*/
    public static List<sObject> queryRelatedActiveRecords(List<Schema.FieldSetMember> fieldSetMembers, String objectName, String parentObjectFieldName, String parentRecordId, Set<Id> parentRecordIdSet, String OrderField, String activeField){
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : fieldSetMembers){
            query += f.getFieldPath() + ',';
        }
        
        query = query.subString(0, query.length() - 1); //trim last comma
        
        //Construct Object source
        query += ' FROM '+objectName+' WHERE ';
        
        System.debug('$$$ objectName: '+objectName);
        
        //Add filter if Parent Record Id is present
        if(parentRecordId != null){
            query += parentObjectFieldName + ' =: parentRecordId AND ';
            System.debug('$$$ '+parentObjectFieldName+': '+parentRecordId);
        }
        
        //Add filter if Record Id Set is present
        if(parentRecordIdSet != null && !parentRecordIdSet.isEmpty()){
            query += parentObjectFieldName + ' IN: parentRecordIdSet AND ';
            System.debug('$$$ '+parentObjectFieldName+': '+parentRecordIdSet);
        }
        
        //Add filter for Active records and sort based on parameter
        query += activeField+' = true ORDER BY '+OrderField+' ASC';
        System.debug('$$$ query: '+query);
        
        try{
            return Database.query(query);
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new list of sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(objectName);
            List<sObject> targetObjectList = new List<sObject>();
            targetObjectList.add(targetObject.newSObject());
            return targetObjectList;
        }
    }
    
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Common method to query child records of a parent using field set with record type
    Inputs: Field Set, Parent Field Name, Parent Ids, Record Type Id, Query filter
    Returns: List<sObject>
    History
    09/30/14    Michael Lasala      Created
    08/17/15    Samuel Oberes       Added sorting option
    ------------------------------------------------------------*/
    public static List<sObject> queryRelatedRecordsWithRecordType(List<Schema.FieldSetMember> fieldSetMembers, String parentField, Set<Id> parentRecordId, String recordTypeId, String additionalFilter, Map<String, String> sortMap)
    {
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : fieldSetMembers) {
            query += f.getFieldPath() + ',';
        }
        
        query = query.subString(0, query.length() - 1); //trim last comma
        
        //Build FROM, WHERE
        query += ' FROM ' + OBJECT_NAME_PROJECT_LOG + ' WHERE ' + parentField + ' IN: parentRecordId AND RecordTypeId =: recordTypeId AND '+additionalFilter+' = true ';

        String sortByString = ' ORDER BY '; // full order by clause
        String sortByDirection = ' '; // ASC/DESC
        for (String sortByThisField : sortMap.keySet())
        {
            sortByDirection = sortMap.get(sortByThisField);
            sortByString += sortByThisField + ' ' + sortByDirection + ' NULLS LAST, ';
        }
        sortByString += ' CreatedDate ASC ';

        //Build Order By clause
        query += sortByString;

        System.debug('$$$ Object: '+OBJECT_NAME_PROJECT_LOG);
        System.debug('$$$ '+parentField+' IN: '+parentRecordId);
        System.debug('$$$ RecordTypeId IN: '+recordTypeId);
        System.debug('$$$ RecordTypeId IN: '+recordTypeId);
        System.debug('$$$ additionalFilter: '+additionalFilter);
        
        try
        {

            System.debug('DBG: query [queryRelatedRecordsWithRecordType] >>> ' + query);
            return Database.query(query);

        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new list of sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(OBJECT_NAME_PROJECT_LOG);
            List<sObject> targetObjectList = new List<sObject>();
            targetObjectList.add(targetObject.newSObject());
            return targetObjectList;
        }
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Common method to query child records of a parent Id using field set with Entity Type filter
Inputs: Field Set, Object API Name, Parent Field Name, SubProject Id, Entity Type field, Entity Type filter
Returns: List<sObject>
History
10/13/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<sObject> queryRelatedEntityRecords(List<Schema.FieldSetMember> fieldSetMembers, String objectName, String parentObjectFieldName, String parentRecordId, String filterField, String filterCriteria){
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : fieldSetMembers){
            query += f.getFieldPath() + ',';
        }
        
        query = query.subString(0, query.length() - 1); //trim last comma
        
        //Construct Object source and parent field filter
        query += ' FROM ' + objectName + ' WHERE ';
        
        System.debug('$$$ objectName: '+objectName);
        
        //Add filter if Parent Record Id is present
        if(parentRecordId != null){
            query += parentObjectFieldName + ' =: parentRecordId';
            System.debug('$$$ '+parentObjectFieldName+': '+parentRecordId);
        }        
        
        //Add filter field and criteria (differs per condition)
        if(filterField != null && filterCriteria != null){
            query += ' AND '+filterField+' =: filterCriteria';
            System.debug('$$$ '+filterField+': '+filterCriteria);
        }
        System.debug('$$$ query: '+query);
        
        try{
            return Database.query(query);
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new list of sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(objectName);
            List<sObject> targetObjectList = new List<sObject>();
            targetObjectList.add(targetObject.newSObject());
            return targetObjectList;
        }
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Common method to construct query with subquery
Inputs: Field Set, Object API Name, Parent Field Name, Parent Record Id, Parent Record Id Set, Subquery string, Boolean if Subquery is field or filter
Returns: List<sObject>
History
10/14/14    Michael Lasala      Created
10/21/14    Michael Lasala      Added additionalFilter parameter
------------------------------------------------------------*/
    public static List<sObject> queryWithSubquery(List<Schema.FieldSetMember> fieldSetMembers, String objectName, String parentObjectFieldName, String parentRecordId, Set<Id> parentRecordIdSet, String subQuery, Boolean isField, String additionalFilter){
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : fieldSetMembers){
            query += f.getFieldPath() + ',';
        }
        
        //Add Subquery to field list if isField = true
        if(isField && subQuery != null){
            query += subQuery;
            System.debug('$$$ subQuery: '+subQuery);
            
        } else {
            query = query.subString(0, query.length() - 1); //trim last comma
        }
        
        //Construct Object source and parent field filter
        query += ' FROM ' + objectName + ' WHERE ';
        System.debug('$$$ objectName: '+objectName);
        
        if(additionalFilter != null){
            //Add additional filter if present
            query += additionalFilter+' AND ';
            System.debug('$$$ additionalFilter: '+additionalFilter);
        }
        
        if(isField && parentRecordId != null){
            //Add filter Parent Record Id Set if isField = true
            query += parentObjectFieldName + ' =: parentRecordId ORDER BY '+FIELD_NAME_RECORD;
            System.debug('$$$ '+parentObjectFieldName+': '+parentRecordId);
            
        } else if(isField && parentRecordIdSet != null && !parentRecordIdSet.isEmpty()){
            //Add filter Parent Record Id Set
            query += parentObjectFieldName + ' IN: parentRecordIdSet ORDER BY Question_Category__r.Name';
            System.debug('$$$ '+parentObjectFieldName+' IN: '+parentRecordIdSet);
        }
        
        if(!isField && subQuery == null){
            //Add filter Parent Record Id Set if isField = false and Subquery = null
            query += parentObjectFieldName + ' IN: parentRecordIdSet';
            System.debug('$$$ '+parentObjectFieldName+' IN: '+parentRecordIdSet);
            
        } else if(!isField && subQuery != null){
            //Add Subquery to filter if isField = false and Subquery is present
            query += parentObjectFieldName + ' IN '+subQuery;
            System.debug('$$$ '+parentObjectFieldName+' IN '+subQuery);
        }
        
        System.debug('$$$ query: '+query);
        
        try{
            return Database.query(query);
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new list of sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(objectName);
            List<sObject> targetObjectList = new List<sObject>();
            targetObjectList.add(targetObject.newSObject());
            return targetObjectList;
        }
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Common method to query child records of a parent Id/Set using field set with OR filter paramaters
Inputs: Field Set, Object API Name, Parent Field Name, Parent Record Id set, Map of field name and value list
Returns: List<sObject>
History
10/15/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<sObject> queryRelatedRecordsWithOrCriteria(List<Schema.FieldSetMember> fieldSetMembers, String objectName, String parentObjectFieldName, Set<Id> parentRecordIdSet, Map<String, List<String>> filterFieldCriteriaMap){
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : fieldSetMembers){
            query += f.getFieldPath() + ',';
        }
        
        query = query.subString(0, query.length() - 1); //trim last comma
        
        //Construct Object source and parent field filter
        query += ' FROM ' + objectName + ' WHERE ';
        System.debug('$$$ objectName: '+objectName);
        
        //Add filter if Record Id Set is present
        if(parentRecordIdSet != null && !parentRecordIdSet.isEmpty()){
            query += parentObjectFieldName + ' IN: parentRecordIdSet AND ';
            System.debug('$$$ '+parentObjectFieldName+' IN: '+parentRecordIdSet);
        }
        
        if(!filterFieldCriteriaMap.keySet().isEmpty()){
            //Open parenthesis
            query += '(';
            Integer counter = 0;
            
            //Iterate over Field Name API
            for(String field: filterFieldCriteriaMap.keySet()){
                
                //Iterate over Field Value
                for(String value: filterFieldCriteriaMap.get(field)){
                    
                    //Add Field Name API and corresponding value
                    query += field+' = \''+value+'\'';
                    System.debug('$$$ '+field+': '+value);
                    
                    //Add OR clause
                    if(counter < filterFieldCriteriaMap.keySet().size()){
                        query += ' OR ';    
                    }
                    
                    counter++;
                }
            }
            
            //Close parenthesis
            query += ')';
        }
        System.debug('$$$ query: '+query);
        
        try{
            return Database.query(query);
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new list of sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(objectName);
            List<sObject> targetObjectList = new List<sObject>();
            targetObjectList.add(targetObject.newSObject());
            return targetObjectList;
        }
    }
    
    //============================================================
    //          ACTIVITY DETAIL CAPTURE UTILITY METHODS
    //============================================================
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve External Entity Ids of related SubProject External Reference records from the SubProject Id set
Inputs: SubProject Ids, External Reference Record Type
Returns: Set<String>
History
09/23/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static Set<String> retrieveSubProjectExternalReferences(Set<Id> subProjectIds, String recordTypeName){
        Set<String> externalReferenceIds = new Set<String>();
        
        //Retrieve all custom setting records
        Map<String, IMP_ExternalReferenceRecordTypes__c> allExternalReferenceRecordTypes = IMP_ExternalReferenceRecordTypes__c.getAll();
        
        if(!allExternalReferenceRecordTypes.keySet().isEmpty()){
            
            //Build SOQL query
            String query = 'SELECT ';
            
            //Retrieve SubProject_External_Reference__c Record Types
            Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
            Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
            
            Set<Id> recordTypeIds = new Set<Id>();
            
            if(recordTypeName != ''){
                
                if(allExternalReferenceRecordTypes.get(recordTypeName) != null){
                    
                    //Add partner Id Field API Name to query
                    query += allExternalReferenceRecordTypes.get(recordTypeName).Partner_Id__c+',';
                }
                
            } else {
                
                //Add partner Id Field API Names to query
                for(String s: allExternalReferenceRecordTypes.keySet()){
                    query += allExternalReferenceRecordTypes.get(s).Partner_Id__c+',';
                }
            }
            
            if(!recordTypeInfo.keySet().isEmpty()){
                
                for(String nameFromRecordTypeInfo: recordTypeInfo.keySet()){
                    
                    if(recordTypeName != ''){
                        
                        //Get Record Type Id of parameter
                        if(recordTypeName == nameFromRecordTypeInfo){
                            recordTypeIds.add(recordTypeInfo.get(recordTypeName).getRecordTypeId());
                        }
                        
                    } else {
                        
                        //Get all Record Type Ids
                        recordTypeIds.add(recordTypeInfo.get(nameFromRecordTypeInfo).getRecordTypeId());
                    }
                }
                
                query += 'RecordTypeId, Record_Type_Name__c FROM '+OBJECT_NAME_SUBPROJECT_EXTERNAL_REFERENCE+' WHERE '+OBJECT_NAME_SUBPROJECT+' IN: subProjectIds AND '+FIELD_NAME_RECORDTYPEID+' IN: recordTypeIds';
                System.debug('$$$ subProjectIds >>> ' + subProjectIds);
                System.debug('$$$ recordTypeIds >>> ' + recordTypeIds);
                //Retrieve SubProject External Reference records
                List<SubProject_External_Reference__c> subProjectExternalReferenceList;
                
                try{
                    System.debug('$$$ query: >>> ' + query);
                    subProjectExternalReferenceList = Database.query(query);
                    System.debug('$$$ subProjectExternalReferenceList: '+subProjectExternalReferenceList);
                } catch (QueryException e){
                    System.debug('$$$ QueryException: '+e.getMessage());
                    
                    subProjectExternalReferenceList = new List<SubProject_External_Reference__c>();
                }
                
                if(!subProjectExternalReferenceList.isEmpty()){
                    for(SubProject_External_Reference__c er: subProjectExternalReferenceList){
                        for(String settingName: allExternalReferenceRecordTypes.keySet()){
                            
                            if(er.Record_Type_Name__c == settingName){
                                
                                //Add External Entity Id based on Record Type's partner Id field
                                externalReferenceIds.add(String.valueOf(er.get(allExternalReferenceRecordTypes.get(settingName).Partner_Id__c)));
                                
                                //Break loop if Record Type is specified and custom setting is retrieved
                                if(recordTypeName == settingName){
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return externalReferenceIds;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve active Project Activity Detail Mapping Rules
Inputs: External Reference Record Type Name, Active criteria
Returns: List<Project_Activity_Detail_Mapping_Rule__c>
History
09/23/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<Project_Activity_Detail_Mapping_Rule__c> projectActivityDetailsToCaptureFields(String recordTypeName, Boolean isActive){
        
        //Retrieve all custom setting records
        Map<String, IMP_ExternalReferenceRecordTypes__c> allExternalReferenceRecordTypes = IMP_ExternalReferenceRecordTypes__c.getAll();
        
        //Build SOQL query
        String query = 'SELECT ';
        
        if(!allExternalReferenceRecordTypes.keySet().isEmpty()){
            
            String queryFilter = '';
            
            for(String s: allExternalReferenceRecordTypes.keySet()){
                
                //Retrieve fields to be used for query and filtering of records
                //Add fields to query based on Custom Setting data and check for duplicate fields
                if(!query.contains(allExternalReferenceRecordTypes.get(s).Field_Map_API_Name__c)){
                    query += allExternalReferenceRecordTypes.get(s).Field_Map_API_Name__c+',';
                }
                
                if(!query.contains(allExternalReferenceRecordTypes.get(s).Target_Activity_Date_Type_API_Field_Name__c)){
                    query += allExternalReferenceRecordTypes.get(s).Target_Activity_Date_Type_API_Field_Name__c+',';
                }
                
                //Break loop if Record Type is specified and custom setting is retrieved
                if(recordTypeName == s){
                    
                    //Retrieve Record Type filter field API name if specified
                    queryFilter =  allExternalReferenceRecordTypes.get(recordTypeName).Record_Type_Map_API_Name__c+' =: recordTypeName AND ';
                    break;
                }
            }
            
            //Complete SOQL query and filtering of records
            query += FIELD_NAME_EXTERNAL_ENTITY_TYPE+', Id FROM '+OBJECT_NAME_ACTIVITY_DETAIL_MAPPING+' WHERE '+queryFilter+' Active__c =: isActive';
        }
        
        try{
            return Database.query(query);
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new list of sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(OBJECT_NAME_ACTIVITY_DETAIL_MAPPING);
            List<sObject> targetObjectList = new List<sObject>();
            targetObjectList.add(targetObject.newSObject());
            return targetObjectList;
        }
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Generate query string based on related Custom Setting's Source Object API Name
Inputs: External Reference Record Type Name, List of fields to query, SubProject External Reference Ids
Returns: String
History
09/23/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static String generateQueryString(String recordTypeName, List<String> queryFields, Set<String> subProjectExternalReferenceIds){
        
        //Retrieve custom setting record based on Record Type parameter
        IMP_ExternalReferenceRecordTypes__c externalReferenceRecordType = IMP_ExternalReferenceRecordTypes__c.getInstance(recordTypeName);
        
        String queryString = 'SELECT Id, '+String.join(queryFields, ',')+' FROM '+externalReferenceRecordType.Source_Object_API_Name__c+' WHERE Id IN: subProjectExternalReferenceIds';
        
        return queryString;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Generate query string list when no Record Type is specified
Inputs: Map with Record Type Name keys and List of fields to query, SubProject External Reference Ids
Returns: List<String>
History
09/25/14    Michael Lasala      Created
------------------------------------------------------------*/
    public static List<String> generateAllQueryStrings(Map<String, List<String>> queryFieldsMap, Set<String> subProjectExternalReferenceIds){
        List<String> queryList = new List<String>();
        
        //Retrieve all custom setting records
        Map<String, IMP_ExternalReferenceRecordTypes__c> allExternalReferenceRecordTypes = IMP_ExternalReferenceRecordTypes__c.getAll();
        
        if(!allExternalReferenceRecordTypes.keySet().isEmpty()){
            
            //Build SOQL query per custom setting record/record type
            for(String s: allExternalReferenceRecordTypes.keySet()){
                
                String queryString = 'SELECT Id, '+String.join(queryFieldsMap.get(s), ',')+' FROM '+allExternalReferenceRecordTypes.get(s).Source_Object_API_Name__c+' WHERE Id IN: subProjectExternalReferenceIds';
                queryList.add(queryString);
            }
        }
        
        return queryList;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Update Project Activity records based on map parameter which contains the External Entity record Id, Source field to get the data from and the actual data
Inputs: SubProject Ids, SubProject External Refernece Ids, Map of unique Target External Activity Name and Source field from External Entity record, Map of External Entity Record Id with a map of object field API name and date, and Record Type Name
        NOTE: externalReferenceIds' contents must be 15 characters only!
Returns: List<Project_Activity__c>
History
09/24/14    Michael Lasala      Created
10/07/14    Michael Lasala      Changed return to List<Project_Activity__c> which will be used for processing inside batch apex
03/31/15    Samuel Oberes       Replaced project activity references to project task
05/20/15    Samuel Oberes       Replaced External_System_ID__c with External_System_Id2__c
------------------------------------------------------------*/
    public static List<Project_Task__c> processActivityDetails(Set<Id> subProjectIds, Set<String> externalReferenceIds, Map<String, String> fieldMetaMap, Map<Id, Map<String, Date>> sourceIdToFieldValueMap, String recordTypeName)
    {
        //Retrieve Project Activity records based on SubProject Id set and SubProject External Reference Id set
        List<Project_Task__c> projectTasksToUpdate = [SELECT Id, 
                                                      SubProject_ID__c,
                                                      Actual_Start_Date__c, 
                                                      Actual_End_Date__c,
                                                      Actual_Time_Spent__c,
                                                      Description__c, 
                                                      External_Activity_Name__c,
                                                      Reason_Missed_Planned_End_Date__c,
                                                      Project_Activity__r.Milestone__r.External_System_Id2__c, 
                                                      Project_Activity__r.Milestone__r.External_System_Name__c,
                                                      Project_Activity__r.Milestone__r.Description__c, 
                                                      Project_Activity__r.Milestone__r.SubProject__c,
                                                      Project_Activity__r.Milestone__r.SubProject__r.Name, 
                                                      Project_Activity__r.Milestone__r.SubProject__r.Project_Manager__c 
                                                      FROM Project_Task__c
                                                      WHERE Project_Activity__r.Milestone__r.SubProject__c IN: subProjectIds
                                                      AND Project_Activity__r.Milestone__r.External_System_Id2__c IN: externalReferenceIds
                                                      AND External_Activity_Name__c !=null];
        List<Project_Task__c> projectTasksForUpdate = new List<Project_Task__c>();
        
        if(!projectTasksToUpdate.isEmpty())
        {
            String actualStartFieldName;
            String actualEndFieldName;
            
            Map<String, IMP_ExternalReferenceRecordTypes__c> allExternalReferenceRecordTypes = IMP_ExternalReferenceRecordTypes__c.getAll();
            
            String externalSystemId;
            
            for(Project_Task__c pt : projectTasksToUpdate)
            {
                externalSystemId = pt.Project_Activity__r.Milestone__r.External_System_Id2__c;
                
                //============================================================
                //       NO PROPER TESTING FOR MULTIPLE RECORD TYPES YET      
                //============================================================
                //if(recordTypeName != '')
                //{
                //    //Retrieve Date field API names from fieldMetaMap based on Record Type Name paramater, Project Activity's External_Activity_Name__c and Actual Start/End
                //    actualStartFieldName = fieldMetaMap.get(recordTypeName+'-'+pt.External_Activity_Name__c+'-'+DATE_TYPE_SUFFIX_START);
                //    actualEndFieldName = fieldMetaMap.get(recordTypeName+'-'+pt.External_Activity_Name__c+'-'+DATE_TYPE_SUFFIX_END);
                
                //    if(sourceIdToFieldValueMap.get(externalSystemId).get(actualStartFieldName) != null)
                //    {
                //        //Get actual value from External Entity record
                //        pt.Actual_Start_Date__c = sourceIdToFieldValueMap.get(externalSystemId).get(actualStartFieldName);
                //    }
                
                //    if(sourceIdToFieldValueMap.get(externalSystemId).get(actualEndFieldName) != null)
                //    {
                //        //Get actual value from External Entity record
                //        pt.Actual_End_Date__c = sourceIdToFieldValueMap.get(externalSystemId).get(actualEndFieldName);
                //    }
                
                //} 
                //else 
                //{
                //    //Iterate over custom setting keys to get map data
                //    for(String settingName: allExternalReferenceRecordTypes.keySet())
                //    {
                //String externalActivityActualStart = settingName+'-'+pt.External_Activity_Name__c+'-'+DATE_TYPE_SUFFIX_START;
                //String externalActivityActualEnd = settingName+'-'+pt.External_Activity_Name__c+'-'+DATE_TYPE_SUFFIX_END;
                //        if(fieldMetaMap.get(externalActivityActualStart) != null)
                //        {
                //            //Retrieve Date field API names from fieldMetaMap based on Record Type Name paramater, Project Activity's External_Activity_Name__c and Actual Start/End
                //            actualStartFieldName = fieldMetaMap.get(externalActivityActualStart);
                
                //            if(sourceIdToFieldValueMap.get(externalSystemId).get(actualStartFieldName) != null)
                //            {
                //                //Get actual value from External Entity record
                //                pt.Actual_Start_Date__c = sourceIdToFieldValueMap.get(externalSystemId).get(actualStartFieldName);
                //            }
                //        }
                
                //        if(fieldMetaMap.get(externalActivityActualEnd) != null)
                //        {
                //            actualEndFieldName = fieldMetaMap.get(externalActivityActualEnd);
                
                //            if(sourceIdToFieldValueMap.get(externalSystemId).get(actualEndFieldName) != null)
                //            {
                //                pt.Actual_End_Date__c = sourceIdToFieldValueMap.get(externalSystemId).get(actualEndFieldName);
                //            }
                //        }
                
                //    }
                //}
                
                //Iterate over custom setting keys to get map data
                for(String settingName : allExternalReferenceRecordTypes.keySet())
                {
                    String externalActivityActualStart = settingName + '-' + pt.External_Activity_Name__c + '-' + DATE_TYPE_SUFFIX_START;
                    String externalActivityActualEnd   = settingName + '-' + pt.External_Activity_Name__c + '-' + DATE_TYPE_SUFFIX_END;
                    
                    System.debug('$$$ start: ' + externalActivityActualStart);
                    System.debug('$$$ ID : '   + pt.id );
                    
                    if(fieldMetaMap.get(externalActivityActualStart) != null)
                    {
                        //Retrieve Date field API names from fieldMetaMap based on Record Type Name paramater, Project Activity's External_Activity_Name__c and Actual Start/End
                        actualStartFieldName = fieldMetaMap.get(externalActivityActualStart);
                        
                        if(sourceIdToFieldValueMap.get(externalSystemId).get(actualStartFieldName) != null)
                        {
                            //Get actual value from External Entity record
                            pt.Actual_Start_Date__c = sourceIdToFieldValueMap.get(externalSystemId).get(actualStartFieldName);
                        }
                    }
                    
                    System.debug('$$$ source value id : ' + externalSystemId);
                    System.debug('$$$ source value : ' + fieldMetaMap.get(externalActivityActualStart) + ' - ' + sourceIdToFieldValueMap.get(externalSystemId).get(actualStartFieldName));
                    System.debug('$$$ updated actual date : ' + pt.Actual_Start_Date__c);
                    System.debug('$$$ end: ' + externalActivityActualEnd);
                    
                    if(fieldMetaMap.get(externalActivityActualEnd) != null)
                    {
                        actualEndFieldName = fieldMetaMap.get(externalActivityActualEnd);
                        
                        if(sourceIdToFieldValueMap.get(externalSystemId).get(actualEndFieldName) != null)
                        {
                            pt.Actual_End_Date__c = sourceIdToFieldValueMap.get(externalSystemId).get(actualEndFieldName);
                        }
                    }
                    System.debug('$$$ updated actual end date : ' + pt.Actual_End_Date__c);
                    
                    //Break loop if Record Type is specified and custom setting is retrieved
                    if(settingName == recordTypeName)
                    {
                        break;
                    }
                }
                
                //Add to new list for update
                projectTasksForUpdate.add(pt);
            }
            
            System.debug('$$$ projectTasksForUpdate: ' + projectTasksForUpdate.size());
        }
        return projectTasksForUpdate;
    }
 // 02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere   
  /*  public static void postBatchFeedBack( Map<Id, Id>  subProjectPMMap, Map<Id, String> subProjectNameMap, Map<Id, Map<Id, String>> milestoneMap,Map<Id, String> laoMap, Map<Id, List<String>> milestoneActivityMap ) {
        if(!subProjectPMMap.keySet().isEmpty()){
            //For bulk posting of Chatter feeds
            List<ConnectApi.BatchInput> batchInputList = new List<ConnectApi.BatchInput>();
            
            String baseURL = System.Url.getSalesforceBaseURL().toExternalForm();
            System.debug('$$$ baseURL: '+baseURL);
            
            //Iterate over each SubProject
            for(Id subProjectId: subProjectPMMap.keySet()){
                
                //Instantiate ConnectApi.FeedItemInput for posting on Chatter
                ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                
                messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                
                //Assign SubProject Project Manager User Id for mention
                mentionSegmentInput.id = subProjectPMMap.get(subProjectId);
                messageBodyInput.messageSegments.add(mentionSegmentInput);
                System.debug('$$$ Project Manager: '+subProjectPMMap.get(subProjectId));
                
                //Construct plain text to be included in the post
                String chatterPostText = '';
                chatterPostText = ' Activity Detail Capture Job Failure in '+subProjectNameMap.get(subProjectId)+': '+baseURL+'/'+subProjectId+'\n';
                //chatterPostText = '\n\nActivity Detail Capture Job Failure:\n';
                
                //Add link to SubProject
                //ConnectApi.LinkSegmentInput linkSegment = new ConnectApi.LinkSegmentInput();
                //linkSegment.url = baseURL+'/'+subProjectId;
                //messageBodyInput.messageSegments.add(linkSegment);
                
                //Iterate over parent Project Milestones of failed Project Activities 
                for(Id milestoneId: milestoneMap.get(subProjectId).keySet()){
                    
                    //Add Description for identification
                    chatterPostText += '\n Milestone: '+milestoneMap.get(subProjectId).get(milestoneId)+'\n';
                    System.debug('$$$ Project Milestone: '+milestoneMap.get(subProjectId).get(milestoneId));
                    
                    //Add External Id
                    chatterPostText += 'External ID: '+laoMap.get(milestoneId)+'\n';
                    System.debug('$$$ External Id: '+laoMap.get(milestoneId));
                    
                    chatterPostText += '\n Project Activity:';
                    
                    //Count for number of Project Activities involved
                    Integer count = 0;
                    
                    //Iterate over failed Project Activities
                    for(String activityString: milestoneActivityMap.get(milestoneId)){
                        count++;
                        
                        //Add Description + error message
                        chatterPostText += '\n'+count+'. '+activityString;
                    }
                    System.debug('$$$: Activity: '+milestoneActivityMap.get(milestoneId));
                    
                    //Add line breaks if there are multiple Project Milestones
                    if(milestoneMap.get(subProjectId).keySet().size()>1){
                        chatterPostText += '\n';
                    }
                }
                System.debug('$$$: chatterPostText: '+chatterPostText);
                
                //Assign plain text value
                textSegmentInput.text = chatterPostText;
                messageBodyInput.messageSegments.add(textSegmentInput);
                
                feedItemInput.body = messageBodyInput;
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                
                //Assign ParentId
                feedItemInput.subjectId = subProjectId;
                
                //Used for bulk posting of ConnectApi.FeedItemInput
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                batchInputList.add(batchInput);
            }
            
            //Post Chatter feeds
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputList);
            System.debug('$$$ batchInputList: '+batchInputList.size());
        }
    }
    */
    /*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Returns the logged in User's permission on an Sobject based on inputs(String sObjectType, String permissionType).
History
11/11/14    Kimiko Roberto      Created
------------------------------------------------------------*/
    
    public static Boolean checkUserPermission(String sObjectType, String permissionType){
        List<PermissionSetAssignment> checkProfile = new List<PermissionSetAssignment>();
        if(permissionType != null && permissionType != ''){
            
            Id userId = UserInfo.getUserId();
            String queryPermSetAss = 'SELECT AssigneeId, Assignee.Name, PermissionSet.Id, PermissionSet.isOwnedByProfile, PermissionSet.Profile.Name, PermissionSet.Label '
                + 'FROM PermissionSetAssignment WHERE AssigneeId =: userId '
                + 'AND PermissionSetId IN (SELECT ParentId FROM ObjectPermissions WHERE SObjectType = ' + '\''+sObjectType+'\'' + ' AND ' + permissionType + ' = true)';
            System.debug('###' + queryPermSetAss);
            
            checkProfile = Database.query(queryPermSetAss);
            System.debug('###: ' + checkProfile);
        }
        
        
        if(checkProfile != null && !checkProfile.isEmpty()){
            return true;
        }
        else{
            return false;
        }
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Generic builder of select option lists
Inputs:      listOfOptions - list containing the options
sortBy - if true, then sort ASC
Returns:     List<SelectOption>
History
11/13/14     Samuel Oberes       Created
------------------------------------------------------------*/
    public static List<SelectOption> buildSelectOption(List<String> listOfOptions, Boolean sortBy) {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('', '--None--'));
        
        Integer listIndex = 1;
        if(!listOfOptions.isEmpty()){
            for(String item : listOfOptions){
                options.add(new SelectOption(String.valueOf(listIndex), item));
                listIndex++;
            }
        }
        if(sortBy) options.sort();
        return options;
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Generic builder of select option lists (1st overload version)
Inputs:      mapOfOptions - map containing the options
sortBy - if true, then sort ASC
Returns:     List<SelectOption>
History
11/13/14     Samuel Oberes       Created
12/23/14     Samuel Oberes       Added null key check
------------------------------------------------------------*/
    public static List<SelectOption> buildSelectOption(Map<String, String> mapOfOptions, Boolean sortBy) {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('', '--None--'));
        
        if(!mapOfOptions.isEmpty()){
            for(String key : mapOfOptions.keySet()){
                if (key != null){
                    options.add(new SelectOption(key, mapOfOptions.get(key)));
                }
            }
        }
        if(sortBy) options.sort();
        return options;
    }
    
    /*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Checks SubProject_External_Related_Entity__c. Returns true if there is a duplicate SubProject_External_Related_Entity__c found.
History
11/25/14    Kimiko Roberto      Created
------------------------------------------------------------*/
    public static Set<String> checkDuplicateExternalEntity(String entityType, Id subProjectId){
        
        Set<String> externalEntitySet = new Set<String>();
        List<SubProject_External_Related_Entity__c> checkEntity = [SELECT Name,
                                                                   Entity_Number__c,
                                                                   Entity_Type__c,
                                                                   SubProject__c 
                                                                   FROM SubProject_External_Related_Entity__c 
                                                                   WHERE Subproject__c = :subProjectId 
                                                                   AND Entity_Type__c = :entityType];
        if(checkEntity != null && !checkEntity.isEmpty())
        {
            for(SubProject_External_Related_Entity__c spere : checkEntity)
            {
                externalEntitySet.add(spere.Entity_Number__c);       
            }
        }
        
        
        
        return externalEntitySet;
        
    }
    
    /*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Gets all the existing subproject sites in a Project.
History
11/25/14    Kimiko Roberto      Created
12/30/14    Samuel Oberes       replaced 'allSites' with 'allSitesSet' in the null checking portion, and added a new null checking for the 'a' object       
------------------------------------------------------------*/
    public static List<SelectOption> getSites(Id projectId){
        Map<String, String> optionsMap = new Map<String, String>();
        optionsMap.put('', '--None--');
        
        List<SubProjectSite__c> allSites = [SELECT Id, Account__c, Account__r.Name, SubProject__c, Project__c FROM SubProjectSite__c WHERE Project__c = :projectId];
        //List<Site_Workbook__c> relatedSites = [SELECT Id, Site__r.Name FROM Site_Workbook__c WHERE Project__c = :project.Id];
        system.Debug('**allSites : '+allSites + '**selectedProject.Project__c' + projectId);
        Set<Account> allSitesSet = new Set<Account>();
        for(SubProjectSite__c sps: allSites){
            allSitesSet.add(sps.Account__r);
        }
        
        if(allSitesSet != null && !allSitesSet.isEmpty()){
            for(Account a : allSitesSet){
                if (a != null ) {                                       
                    optionsMap.put(a.Id, a.Name);
                }
            }
        }
        return buildSelectOption(optionsMap, false);
    }
    /*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Gets all the existing workbooks in a Project.
History
11/25/14    Kimiko Roberto      Created
------------------------------------------------------------*/
    public static List<SelectOption> getSources(Id projectId) {
        Map<String, String> optionsMap = new Map<String, String>();
        optionsMap.put('', '--None--');
        List<Site_Workbook__c> relatedSites = IMP_Project_Utility.retrieveSiteWorkbooks(projectId);
        //List<Site_Workbook__c> relatedSites = [SELECT Id, Site__r.Name FROM Site_Workbook__c WHERE Project__c = :project.Id];
        
        if(relatedSites != null && !relatedSites.isEmpty()){
            for(Site_Workbook__c sw: relatedSites){
                optionsMap.put(sw.Id, sw.Site__r.Name);
            }
        }
        return IMP_Project_Utility.buildSelectOption(optionsMap, false);
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Generic sObject wrapper
Inputs:      sObjectToWrap - the instance of sObject to be wrapped
Returns:     IMP_SalesforceObjectWrapper
History
12/02/14     Samuel Oberes       Created
02/24/15     Samuel Oberes       Added overriding method
------------------------------------------------------------*/
    public class IMP_SalesforceObjectWrapper {
        
        public SObject thisSObject { get; set; }
        public Boolean isSelected { get; set; }
        
        public IMP_SalesforceObjectWrapper(SObject sObjectToWrap) {
            if(sObjectToWrap != null) {
                thisSObject = sObjectToWrap;
            }
            this.isSelected = true;
        }
        
        public IMP_SalesforceObjectWrapper(SObject sObjectToWrap, Boolean isObjectSelected) {
            if(sObjectToWrap != null) {
                thisSObject = sObjectToWrap;
            }
            this.isSelected = isObjectSelected;
        }
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Removes null elements from a list
Inputs:      listOfStrings
Returns:     List<String>
History
12/05/14     Samuel Oberes    Created
------------------------------------------------------------*/
    public static List<String> removeNullElements(List<String> listOfStrings) {
        Integer i = 0;
        
        List<String> temporaryStringList = listOfStrings;
        while (i < temporaryStringList.size()) {
            if (temporaryStringList.get(i) == null || temporaryStringList.get(i) == '') {
                temporaryStringList.remove(i);
            } else {
                i++;
            }
        }
        
        return temporaryStringList;
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Parses a delimited string and returns a list of the broken up strings
Inputs:      delimitedString - a string containing characters/words/phrases separated by a delimiter. NOTE: The delimiter used must be uniform across the whole string
delimiter
removeNullElements - removes null elements resulting from splitting 2 adjacent delimiters
Returns:     List<String>
History
12/05/14     Samuel Oberes    Created
02/05/15     Samuel Oberes    Fixed issue on pipe delimiters
------------------------------------------------------------*/
    public static List<String> parseDelimitedString(String delimitedString, String delimiter, Boolean removeNullElements) {
        List<String> splitResultsList = new List<String>();
        if (!String.isBlank(delimitedString)) {
            splitResultsList = delimitedString.split((delimiter == '|' ? '\\' + delimiter : delimiter));
        }
        
        return (removeNullElements ? IMP_Project_Utility.removeNullElements(splitResultsList) : splitResultsList);
    }
    
    /*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Checks if the profile of the is in the list of bypassing profiles from the custom setting IMP_ProfilesToByPass.
History
12/5/14    Kimiko Roberto      Created
------------------------------------------------------------*/
    public static Boolean profileCanByPass(String profileKey, Id userProfileId){
        Boolean canByPass = false;
        // System.debug('Value of profilekey is ' + profileKey);
        // System.debug('Value of userProfileId is ' + userProfileId);
        IMP_ProfilesToByPass__c integrationProfile = IMP_ProfilesToByPass__c.getValues(profileKey);
        // System.debug('Value of integrationProfile.Profile__c is ' + integrationProfile.Profile__c);
        
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :userProfileId];
        
        // System.debug('Value of userProfile.Name is ' + userProfile.Name);
        
        if(integrationProfile!=null) {
            if (integrationProfile.Profile__c.contains(userProfile.Name)){
                canByPass = true;
            }
        }
        // System.debug('Value of canByPass that will be returned is ' + canByPass);
        return canByPass;   
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: gets the top parent account in the account hierarchy
Inputs:      childAccountIdsSet - the set of IDs to search the TPA for
Returns:     Map<Id, Id> - key == child account while value == top parent account
History
03/20/15     Samuel Oberes    Created
------------------------------------------------------------*/
    public static Map<Id, Id> getTopParentAccountId (Set<Id> childAccountIdsSet) 
    {
        
        TopParentAccountExtractor tpae = new TopParentAccountExtractor(childAccountIdsSet);
        return tpae.getChildToTPAMap();
        
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: A private class that extracts the top parent account
Inputs:      Constructor Parameter: Set<Id> childAccountIdsSet -> gets the set of IDs to search the TPA for, and uses it to populate the child-to-TPA map for later use.
History
03/20/15     Samuel Oberes    Created
------------------------------------------------------------*/
    private class TopParentAccountExtractor 
    {
        
        private Map<Id, Id> childToTPAMap = new Map<Id, Id>();
        
        private TopParentAccountExtractor(Set<Id> childAccountIdsSet) 
        {
            // instantiate the childToTPAMap -- the key will be the child id, while the value will be the parent id, 
            // but set the map value to null at this point just so it will be ready for later use.
            for (Id i : childAccountIdsSet) 
            {
                childToTPAMap.put(i, null);
            }
        }
        
        public Map<Id, Id> getChildToTPAMap() 
        {
            // this will contain the final childId-to-parentId mapping that will be returned to the calling code
            Map<Id, Id> mapToReturn = new Map<Id, Id>();
            
            // a temporary list that will hold all of the TPAEItems that has already found its TPA
            List<TopParentAccountExtractorItem> passingTPAEItemsList = new List<TopParentAccountExtractorItem>();
            
            // a temporary list that will hold all of the TPAEItems that hasn't found its TPA yet
            List<TopParentAccountExtractorItem> failingTPAEItemsList = new List<TopParentAccountExtractorItem>();
            
            // a childId-to-parentId map that contains the recently queried accounts. these accounts contain 5 parent fields, 
            // from parent to great-great-great-great grand parent.
            Map<Id, Account> accountsToScrutinizeMap = this.queryFiveImmediateTPAIds(childToTPAMap.keySet());
            
            // if the last grand parent still isn't null (it gives us a sense that there is no more grand parents if we reach 
            // a null grand parent), then the loop continues.
            while (accountsToScrutinizeMap.size() > 0) 
            {
                failingTPAEItemsList = new List<TopParentAccountExtractorItem>();
                for (Id childAccountId : accountsToScrutinizeMap.keySet()) 
                {
                    // a temporary data holder
                    TopParentAccountExtractorItem tpaei = new TopParentAccountExtractorItem();
                    
                    tpaei.childAccountId = childAccountId;
                    
                    tpaei.isCandidateForRecursion = false;
                    if (accountsToScrutinizeMap.get(childAccountId).Parent.Id == null) 
                    {
                        tpaei.parentAccountId = accountsToScrutinizeMap.get(childAccountId).Id;
                    } 
                    else if (accountsToScrutinizeMap.get(childAccountId).Parent.Parent.Id == null) 
                    {
                        tpaei.parentAccountId = accountsToScrutinizeMap.get(childAccountId).Parent.Id;
                    } 
                    else if (accountsToScrutinizeMap.get(childAccountId).Parent.Parent.Parent.Id == null) 
                    {
                        tpaei.parentAccountId = accountsToScrutinizeMap.get(childAccountId).Parent.Parent.Id;
                    } 
                    else if (accountsToScrutinizeMap.get(childAccountId).Parent.Parent.Parent.Parent.Id == null) 
                    {
                        tpaei.parentAccountId = accountsToScrutinizeMap.get(childAccountId).Parent.Parent.Parent.Id;
                    } 
                    else if (accountsToScrutinizeMap.get(childAccountId).Parent.Parent.Parent.Parent.Parent.Id == null) 
                    {
                        tpaei.parentAccountId = accountsToScrutinizeMap.get(childAccountId).Parent.Parent.Parent.Parent.Id;
                    } 
                    else 
                    {
                        tpaei.parentAccountId = accountsToScrutinizeMap.get(childAccountId).Parent.Parent.Parent.Parent.Parent.Id;
                        tpaei.isCandidateForRecursion = true;
                    }
                    
                    // If the data holder item's isCandidateForRecursion property is marked true, it means that
                    // this certain item hasn't reached it's TPA yet. This item will then be added to the list of items without TPA.
                    // Also, because of this mark, the loop and requerying will continue.
                    if (tpaei.isCandidateForRecursion) 
                    {
                        failingTPAEItemsList.add(tpaei);
                    } 
                    else 
                    {
                        passingTPAEItemsList.add(tpaei);
                    }
                }
                
                if (failingTPAEItemsList.isEmpty()) 
                {
                    accountsToScrutinizeMap.clear();
                } 
                else 
                {
                    accountsToScrutinizeMap = this.queryFiveImmediateTPAIds(failingTPAEItemsList);
                }
            }
            
            // If all items already found their TPA, populate the mapToReturn and return it back to the calling code
            for (TopParentAccountExtractorItem r : passingTPAEItemsList) 
            {
                mapToReturn.put(r.childAccountId, r.parentAccountId);
            }
            
            return mapToReturn;
        }
        
        private Map<Id, Account> queryFiveImmediateTPAIds(Set<Id> accountIdsSet) 
        {
            List<Account> accountsList = [SELECT Id, 
                                          Name, 
                                          Parent.Id, 
                                          Parent.Parent.Id, 
                                          Parent.Parent.Parent.Id, 
                                          Parent.Parent.Parent.Parent.Id,
                                          Parent.Parent.Parent.Parent.Parent.Id
                                          FROM Account
                                          WHERE Id IN :accountIdsSet];
            
            return new Map<Id, Account>(accountsList);
        }
        
        private Map<Id, Account> queryFiveImmediateTPAIds(List<TopParentAccountExtractorItem> topParentAccountExtractorItemList) 
        {
            Map<Id, Id> childIdToParentIdMap = new Map<Id, Id>();
            
            for (TopParentAccountExtractorItem r : topParentAccountExtractorItemList) 
            {
                childIdToParentIdMap.put(r.childAccountId, r.parentAccountId);
            }
            
            List<Account> accountsList = [SELECT Id, 
                                          Name, 
                                          Parent.Id, 
                                          Parent.Parent.Id, 
                                          Parent.Parent.Parent.Id, 
                                          Parent.Parent.Parent.Parent.Id,
                                          Parent.Parent.Parent.Parent.Parent.Id
                                          FROM Account
                                          WHERE Id IN :childIdToParentIdMap.values()];
            
            Map<Id, Account> queryResultsMap = new Map<Id, Account>(accountsList);
            Map<Id, Account> mapToReturn = new Map<Id, Account>();
            
            Id parentId;
            for (Id childId : childIdToParentIdMap.keySet()) 
            {
                parentId = childIdToParentIdMap.get(childId);
                if (queryResultsMap.keySet().contains(parentId)) 
                {
                    mapToReturn.put(childId, queryResultsMap.get(parentId));
                }
            }
            
            return mapToReturn;
        }
        
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: A private class that serves as temporary data holder for the TopParentAccountExtractor class
History
03/20/15     Samuel Oberes    Created
------------------------------------------------------------*/
    private class TopParentAccountExtractorItem 
    {
        public Id childAccountId { get; set; }
        public Id parentAccountId { get; set; }
        public Boolean isCandidateForRecursion { get; set; }
    }
    
    /*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Removes duplicate values from the list.
History
1/6/15    Kimiko Roberto      Created
------------------------------------------------------------*/
    public static List<String> removeDuplicatesFromList(List<String> listToDedupe){
        
        Set<String> myset = new Set<String>();
        List<String> dedupedList = new List<String>();
        for (String s : listToDedupe) {
            if(myset.add(s)){
                dedupedList.add(s);
            }
        }
        
        return dedupedList;
        
    }
    /*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: 
History
1/6/15    Kimiko Roberto      Created
------------------------------------------------------------*/
    public static List<sObject> queryRelatedRecordsWithAndCriteria_2(List<Schema.FieldSetMember> fieldSetMembers, String objectName, String filterFieldName, String filterRecordId, String filter2FieldName, String relationOfField2ToRecordId2, List<String> filter2RecordId, Map<Integer, Map<String, String>> orderBy){
        //Build query string
        String query = 'SELECT ';
        
        //Iterate through field set
        for(Schema.FieldSetMember f : fieldSetMembers){
            query += f.getFieldPath() + ',';
        }
        
        query = query.subString(0, query.length() - 1); //trim last comma
        
        //Construct Object source and parent field filter
        query += ' FROM ' + objectName;
        
        System.debug('$$$ objectName: '+objectName);
        
        //Add filter if Record Id is present
        if(filterRecordId != null){
            
            query += ' WHERE '+filterFieldName + ' =: filterRecordId';
            System.debug('$$$ filterFieldName: '+filterRecordId);
        }
        
        //Add filter 2 if Record Id is present
        if(filter2RecordId != null && !filter2RecordId.isEmpty()){
            
            if(filterRecordId != null){
                query += ' AND ';
            } else {
                query += ' WHERE ';
            }
            
            query += filter2FieldName + ' ' + relationOfField2ToRecordId2 + ' :filter2RecordId';
            System.debug('$$$ filter2FieldName: '+filter2RecordId);
        }
        
        if (orderBy != null) {
            query += ' ORDER BY ';
            for (Integer orderPositionToOrderFieldsMap : orderBy.keySet()) {
                Map<String, String> orderFieldsToOrderDirectionMap = orderBy.get(orderPositionToOrderFieldsMap);
                for (String orderFields : orderFieldsToOrderDirectionMap.keySet()) {
                    query += orderFields + ' ' + orderFieldsToOrderDirectionMap.get(orderFields) + ',';
                }
            }
            query = query.subString(0, query.length() - 1); //trim last comma
        }
        System.debug('$$$ query: '+query);
        
        try{
            return Database.query(query);
        } catch (QueryException e){
            System.debug('$$$ QueryException: '+e.getMessage());
            
            //Return new list of sObject
            Schema.SObjectType targetObject = Schema.getGlobalDescribe().get(objectName);
            List<sObject> targetObjectList = new List<sObject>();
            targetObjectList.add(targetObject.newSObject());
            return targetObjectList;
        }
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Cancels out the identical elements between two sets, and returns a set of the combined unique elements
Inputs:      set1 - set being compared to
set2 - set to compare against
Returns:     Set<String>
History
02/06/15     Samuel Oberes    Created
------------------------------------------------------------*/
    public static Set<String> getUniqueElementsBetweenTwoSets(Set<String> set1, Set<String> set2) {
        Set<String> result = set1.clone();
        result.removeAll(set2);
        set2.removeAll(set1);
        
        result.addAll(set2);
        
        return result;
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Gets the unique elements of set1 after being compared against set2
Inputs:      set1 - set being compared to
set2 - set to compare against
Returns:     Set<String>
History
02/06/15     Samuel Oberes    Created
------------------------------------------------------------*/
    public static Set<String> getUniqueElementsOfSetOne(Set<String> set1, Set<String> set2) {
        Set<String> result = set1.clone();
        result.removeAll(set2);
        return result;
    }
    /*------------------------------------------------------------
    Author:      Kimiko Roberto
    Company:     Cloud Sherpas
    Description: 
    Inputs:      
    Returns:     
    History
    02/12/15     Kimiko Roberto    Created
    08/17/15     Samuel Oberes     Now filtering by project task ids, and ordered by FIELD_NAME_SITE_NAME
    ------------------------------------------------------------*/
    public static List<Project_Task__c> retrieveTasks(Set<Id> taskIdsSet){
        List<Project_Task__c> taskList = new List<Project_Task__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add(FIELD_NAME_SITE_NAME);
        orderFields.add(FIELD_NAME_SEQUENCE);
        orderFields.add(FIELD_NAME_PLANNED_START_DATE);
        
        // SELECT Task_Commons FROM Project_Task__c WHERE Milestone_ID__c IN :milestoneIds ORDER BY FIELD_NAME_SEQUENCE, FIELD_NAME_PLANNED_START_DATE
        for(sObject o: queryRelatedRecords(SObjectType.Project_Task__c.FieldSets.Task_Commons.getFields(), OBJECT_NAME_PROJECT_TASK, 'Id', null, taskIdsSet, null, orderFields, true, 0)){
            taskList.add((Project_Task__c)o);
        }
        return taskList;
    }

    /*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: 
Inputs:      
Returns:     
History
02/12/15     Kimiko Roberto    Created
------------------------------------------------------------*/
    public static List<Project_Activity__c> retrieveActivities_2(Set<Id> milestonesIds){
        List<Project_Activity__c> activityList = new List<Project_Activity__c>();
        
        //Sort order of records
        List<String> orderFields = new List<String>();
        orderFields.add(FIELD_NAME_SEQUENCE);
        orderFields.add(FIELD_NAME_PLANNED_START_DATE);
        
        for(sObject o: queryRelatedRecords(SObjectType.Project_Activity__c.FieldSets.Activity_Commons.getFields(), OBJECT_NAME_PROJECT_ACTIVITY, QUERY_NAME_ID, null, milestonesIds, null, orderFields, true, 0)){
            activityList.add((Project_Activity__c)o);
        }
        return activityList;
    }
    
    /*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: 
Inputs:      
Returns:     
History
02/12/15     Kimiko Roberto    Created
------------------------------------------------------------*/
    /* 2015-8-14 Kimiko Roberto - Commented out method
    public static Map<Id, Boolean> updateMilestoneActualEndDate_2(Map<Id, Date> endDateMap, Set<Id> parentIds,sObjectType sObj){
        
        system.Debug('**parentIds'+parentIds);
        List<sObject> sObjectList = new List<sObject>();
        //Retrieve Project Activities based Milestones above
        if(sObj == Project_Activity__c.sobjecttype){
            sObjectList = retrieveActivities(parentIds);
        }
        else if(sObj == Project_Task__c.sobjecttype){
            sObjectList = retrieveTasks(parentIds);
        }
        
        Boolean isSuccess = true;
        
        //This map is used to support the for loop below to confirm milestone Ids to end date
        Map<Id, Boolean> idsToEndDateMap = new Map<Id, Boolean>();
        
        //This list captures all of the terminal project activities
        List<sObject> terminalActivityTaskList = new List<sObject>();
        
        //This map captures all of the terminal project activities that should not be end dated, given non-terminal activities end dates
        //Ultimately, it's passed pack to the calling trigger to add an error to the project activities
        Map<Id, Boolean> terminalActivityTaskIdtoSuccessMap = new Map<Id, Boolean>();
        
        //This map is sent back to the caller of the method to support error handling to notify user when a project
        //activity terminal activity can't be end dated, since other non-terminal Project activities haven't yet been
        //end dated
        Map<sObject, Boolean> sObjectEndDateUpdateSuccess = new Map<sObject, Boolean>();
        
        // Stores the number of project activities per milestone
        Map<Id, Integer> childObjectCountMap = new Map<Id, Integer>();
        system.Debug('**sObjectList'+sObjectList);
        if(!sObjectList.isEmpty()){
            
            //Loop through the project activities retrieved from the project utility class based upon matching milestone ids.
            //Process each to confirm if its project milestone parent should be end dated, and provide the caller a result to
            //support its error handling of terminal project activities that can not be end dated.
            for(sObject pa: sObjectList){
                
                // Counts how many project activity instances there is per milestone
                if(sObj == Project_Activity__c.sobjecttype){
                    childObjectCountMap.put(
                        (Id)pa.get('Milestone__c'), 
                        ( childObjectCountMap.get((Id)pa.get('Milestone__c')) == null ? 1 : childObjectCountMap.get((Id)pa.get('Milestone__c')) + 1 ) 
                    );
                }
                else if(sObj == Project_Task__c.sobjecttype){
                    childObjectCountMap.put(
                        (Id)pa.get('Project_Activity__c'), 
                        ( childObjectCountMap.get((Id)pa.get('Project_Activity__c')) == null ? 1 : childObjectCountMap.get((Id)pa.get('Project_Activity__c')) + 1 ) 
                    );
                }
                
                //Validate if all non Terminal Activities have Actual End Dates, else return error
                //The 'if' block confirms stamps a failed qualification value into the milestone to update if it finds a non-terminal
                //project activity with a null actual end Date
                if(sObj == Project_Activity__c.sobjecttype)
                {
                    if(!(Boolean)pa.get('Terminal_Activity__c') && (Date)pa.get('Actual_End_Date__c') == null){
                        isSuccess = false;
                        idsToEndDateMap.put((Id)pa.get('milestone__c'), isSuccess);
                        
                    }
                    //This 'else if' block stamps a successful qualification value into the milestones to update map if it finds a non-terminal
                    //project activity with a non-null actual end date.
                    else if (!(Boolean)pa.get('Terminal_Activity__c') && (Date)pa.get('Actual_End_Date__c') != null){
                        isSuccess = true;
                        Boolean mapContainsParentObject;
                        mapContainsParentObject = idsToEndDateMap.containskey((Id)pa.get('milestone__c'));
                        
                        
                        if (!mapContainsParentObject) {
                            idsToEndDateMap.put((Id)pa.get('milestone__c'), isSuccess);
                        }
                        else {
                            //do nothing
                        }
                    }
                    //This 'else if' block catches the terminal activities
                    else if ((Boolean)pa.get('Terminal_Activity__c')) {
                        System.debug('$$$ About to add a terminal activity to the terminal activity list to evaluate.');
                        terminalActivityTaskList.add(pa);
                        System.debug('$$$ The terminal Project Activity List is now size:' + terminalActivityTaskList);
                    }
                }
                else if(sObj == Project_Task__c.sobjecttype)
                {
                    if(!(Boolean)pa.get('Terminal_Task__c') && (Date)pa.get('Actual_End_Date__c') == null){
                        isSuccess = false;
                        idsToEndDateMap.put((Id)pa.get('Project_Activity__c'), isSuccess);  
                    }
                    //This 'else if' block stamps a successful qualification value into the milestones to update map if it finds a non-terminal
                    //project activity with a non-null actual end date.
                    else if (!(Boolean)pa.get('Terminal_Task__c') && (Date)pa.get('Actual_End_Date__c') != null){
                        isSuccess = true;
                        Boolean mapContainsParentObject;
                        mapContainsParentObject = idsToEndDateMap.containskey((Id)pa.get('Project_Activity__c'));
                        
                        
                        if (!mapContainsParentObject) {
                            
                            idsToEndDateMap.put((Id)pa.get('Project_Activity__c'), isSuccess);  
                        }
                        else {
                            //do nothing
                        }
                    }
                    //This 'else if' block catches the terminal activities
                    else if ((Boolean)pa.get('Terminal_Task__c')) {
                        System.debug('$$$ About to add a terminal activity to the terminal activity list to evaluate.');
                        terminalActivityTaskList.add(pa);
                        System.debug('$$$ The terminal Project Activity List is now size:' + terminalActivityTaskList);
                    }
                }         
            }
            
        }
        
        // Another iteration over the project activity list. 
        // The purpose of this loop is to create an entry in the idsToEndDateMap map 
        //   for milestones that only has 1 project actvity. This activity is terminal and contains an actual end date.
        // Purpose: This is crucial for the 1-milestone-1-activity scenario so that the milestone's actual end date will get updated
        for (sObject pa : sObjectList) {
            if(sObj == Project_Activity__c.sobjecttype){
                if (childObjectCountMap.get((Id)pa.get('Milestone__c')) == 1 && (Boolean)pa.get('Terminal_Activity__c') && (Date)pa.get('Actual_End_Date__c') != null) {
                    idsToEndDateMap.put((Id)pa.get('Milestone__c'), true);
                }
            }
            else if(sObj == Project_Task__c.sobjecttype){
                if (childObjectCountMap.get((Id)pa.get('Project_Activity__c')) == 1 && (Boolean)pa.get('Terminal_Task__c') && (Date)pa.get('Actual_End_Date__c') != null) {
                    idsToEndDateMap.put((Id)pa.get('Project_Activity__c'), true);
                }
            }
            
        }
        
        if (!terminalActivityTaskList.isEmpty()){
            for(sObject pa2: terminalActivityTaskList){
                Boolean mapContainsParentObject2;
                if(sObj == Project_Activity__c.sobjecttype){
                    mapContainsParentObject2 = idsToEndDateMap.containskey((Id)pa2.get('milestone__c'));
                }
                else if(sObj == Project_Task__c.sobjecttype){
                    mapContainsParentObject2 = idsToEndDateMap.containskey((Id)pa2.get('Project_Activity__c'));
                }
                
                
                if (mapContainsParentObject2) {
                    System.debug('$$$ The size of idsToEndDateMap is ' + idsToEndDateMap.size());
                    Boolean isSuccess2;
                    if(sObj == Project_Activity__c.sobjecttype){
                        isSuccess2 = idsToEndDateMap.get((Id)pa2.get('milestone__c'));
                    }
                    else if(sObj == Project_Task__c.sobjecttype){
                        isSuccess2 = idsToEndDateMap.get((Id)pa2.get('Project_Activity__c'));
                    }
                    
                    // sObjectEndDateUpdateSuccess.put(pa2, isSuccess2);
                    
                    if (!isSuccess2) {
                        System.debug('$$$ Found a terminal activity that had a milestone id in the map that is marked as failed.');
                        terminalActivityTaskIdtoSuccessMap.put(pa2.Id,false);
                        System.debug('$$$ Just added a terminal project activity to the error map to return back.');
                        System.debug('$$$ The terminal Project Activity ERROR Map is now size:' + terminalActivityTaskIdtoSuccessMap.size());
                    }
                }
            }
        }
        
        if(!idsToEndDateMap.isEmpty()){
            Set <Id> parentIdstoEvaluate = new Set <Id>();
            Set <Id> parentIdstoUpdate = new Set <Id>();
            
            parentIdstoEvaluate  = idsToEndDateMap.keyset();          
            
            for (Id mId: parentIdstoEvaluate) {
                if (idsToEndDateMap.get(mId)) {
                    parentIdstoUpdate.add(mId);
                }
            }
            List<sObject> parentObjectToUpdateList = new List<sObject>();
            
            if(sObj == Project_Activity__c.sobjecttype){
                parentObjectToUpdateList = retrieveMilestonesBySet(parentIdstoUpdate, QUERY_NAME_ID);
            }
            else if(sObj == Project_Task__c.sobjecttype){
                parentObjectToUpdateList = retrieveActivities_2(parentIdstoUpdate);
            }
            
            
            
            for(sObject pm: parentObjectToUpdateList){
                
                //Set Project Milestone Actual end date = value from endDateMap
                pm.put('Actual_End_Date__c',endDateMap.get(String.valueOf(pm.get('Id'))));
                
                //Update Project Milestone records
                try{
                    update parentObjectToUpdateList;
                } catch (DmlException e){
                    System.debug('$$$ update parentObjectToUpdateList DmlException: '+e);
                }
            }
            
            
        }
        System.debug('$$$ Right before returning it, the terminal Project Activity ERROR map is now size:' + terminalActivityTaskIdtoSuccessMap.size());
        return terminalActivityTaskIdtoSuccessMap;
        
    }*/
    
    public static Project_Task__c cloneProjectTaskField(Project_Task__c sourceFields) {
        //this will clone the value of the specific field that is define in the field set
        Project_Task__c cloneTask = new Project_Task__c();
        for(Schema.FieldSetMember f : SObjectType.Project_Task__c.FieldSets.ProjectTask_to_clone_fields.getFields()) {
            cloneTask.put(f.getFieldPath(), sourceFields.get( f.getFieldPath() ) );
        }
        
        return cloneTask;
    }
    
    /*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Creation of Project task based on the project task definition content
Inputs: 
Returns: 
History
03/17/15    Rey Austral      Created
------------------------------------------------------------*/
    public static String createProjectTask(List<Project_Activity__c> projectActivities) 
    {
        String errorMessage = '';
        List<Project_Task__c> projectTaskToInsert = new List<Project_Task__c>();
        Set<Id> activityIds = new Set<Id>();
        Map<Id,List<String>> activityMap = new Map<Id,List<String>>();
        Map<Id,Project_Activity__c> projectActivityMap = new Map<Id,Project_Activity__c>(projectActivities);
        for (Project_Activity__c activity : projectActivities)    
        {
            activityIds.add(activity.Activity_Definition__c);
            if (activityMap.containsKey(activity.Activity_Definition__c))
            {
                List<String> idList = activityMap.get(activity.Activity_Definition__c);
                idList.add(activity.Id);
            }
            else
            {
                List<String> idList = new List<String>();
                idList.add(activity.Id);
                activityMap.put(activity.Activity_Definition__c, idList);
            }
        }
        
        List<Task_Definition__c> taskDefinitionList = retrieveTaskDefinitionsBySet(activityIds);
        system.debug(taskDefinitionList);
        for(Task_Definition__c td: taskDefinitionList)
        {            
            for(String actId : activityMap.get(td.Activity_Definition__c))            
            {
                Project_Task__c projectTask = buildProjectTask(td, actId,  projectActivityMap);
            
                //Add Project Activity to list that will be inserted later
                projectTaskToInsert.add(projectTask);
            }    
        }
        
        if(!projectTaskToInsert.isEmpty())
        {
            try
            {
                insert projectTaskToInsert;
            }
            catch( exception ex)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, ex.getMessage()));                
                system.debug('$$ createProjectTask: ' + ex.getMessage());
                errorMessage = ex.getMessage();
            }            
        }
        return errorMessage;
    }
    
    /*------------------------------------------------------------
Author: Rey Austral
Company: Retrieve of task based on the activity definition id
Description: 
Inputs: 
Returns: 
History
03/17/15    Rey Austral      Created
------------------------------------------------------------*/
    public static List<Task_Definition__c> retrieveTaskDefinitionsBySet(Set<Id> activitytIds){
        List<Task_Definition__c> tskDefinitionList = new List<Task_Definition__c>();
        for(sObject o: IMP_Project_Utility.queryRelatedActiveRecords(SObjectType.Task_Definition__c.FieldSets.Task_Definition_Commons.getFields(), OBJECT_NAME_TASK_DEFINITION, 'Activity_Definition__c', null, activitytIds, FIELD_NAME_RECORD, FIELD_NAME_ACTIVE)){
            tskDefinitionList.add((Task_Definition__c)o);
        }
        return tskDefinitionList;
    }
    
    /*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Population of task value 
Inputs: 
Returns: 
History
03/17/15    Rey Austral      Created
07/21/15    Samuel Oberes    Changed Expected_Duration__c to Expected_Time_Spent__c
------------------------------------------------------------*/
    public static Project_Task__c buildProjectTask(Task_Definition__c taskDefinition, String projectActivityId, Map<Id,Project_Activity__c> projectActivityMap)
    {
        Project_Task__c projectTask = new Project_Task__c();
        
        if(taskDefinition.Id != null)
        {
            projectTask.Task_Definition__c = taskDefinition.Id;
            projectTask.Project_Activity__c = projectActivityId;
            projectTask.Standard__c = true;
            projectTask.Expected_Time_Spent__c = taskDefinition.Expected_Time_Spent__c;
            //projectTask.Terminal_Task__c  = taskDefinition.Terminal_Task__c;
            
            if(taskDefinition.Description__c != null)
            {
                projectTask.Description__c = taskDefinition.Description__c;
            }
            if(taskDefinition.Sequence__c != null)
            {
                projectTask.Sequence__c = taskDefinition.Sequence__c;
            }
            
            //Populate the task value from the project activity record
            if (projectActivityMap.containsKey(projectActivityId)) 
            {
                Project_Activity__c projectAct = projectActivityMap.get(projectActivityId);
                
                if (projectAct.Planned_Start_Date__c != null)
                {
                    projectTask.Planned_Start_Date__c = projectAct.Planned_Start_Date__c;
                }
                
                if (projectAct.Planned_End_Date__c != null) 
                {
                    projectTask.Planned_End_Date__c = projectAct.Planned_End_Date__c;
                }
                
                if (projectAct.CDK_Assignee__c != null)
                {
                    projectTask.CDK_Assignee__c = projectAct.CDK_Assignee__c;
                }
                
                if (projectAct.Client_Assignee__c != null) 
                {
                    projectTask.Client_Assignee__c = projectAct.Client_Assignee__c;
                }
                
                if (projectAct.CDK_Assignee_Role__c != null) 
                {
                    projectTask.CDK_Assignee_Role__c = projectAct.CDK_Assignee_Role__c;
                }
                
            }
        }
        return projectTask;
    }
    
    
    /*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Processes the subproject Id to collect all CDK users from milestones up to tasks.
Inputs:      
Returns:     
History
03/24/15     Kimiko Roberto    Created
03/31/15     Kimiko Roberto    Updated to accept sets for PSR
------------------------------------------------------------*/
    public static List<CDKClientContactsWrapper> combineCDKContacts(Set<Id> subProjectIdSet)
    {
        Set<SubProject_CDK_Contact__c> uniqueCDKContactSet = new Set<SubProject_CDK_Contact__c>();
        List<User> combinedUniqueCDKContactsList = new List<User>();
        List<CDKClientContactsWrapper> cdkContactWrapper = new List<CDKClientContactsWrapper>();
        List<SubProject_CDK_Contact__c> subProjectCDKContactsList = new List<SubProject_CDK_Contact__c>();
        List<Project_Activity__c> projectActivityCDKContactsList = new List<Project_Activity__c>();
        List<Project_Task__c> projectTaskCDKContactsList = new List<Project_Task__c>();
        Set<Id> compiledUniqueCDKContactIds = new Set<Id>();
        Map<Id,String> projectRoleMap = new Map<Id,String>();
        
        
        
        //get all the CDK users from the SubProject_CDK_Contact__c object
        subProjectCDKContactsList = retrieveCDKContactsBySet(subProjectIdSet);
        
        //get all the CDK users from the Project_Activity__c object
        projectActivityCDKContactsList = getProjectActivityCDKClientContacts(subProjectIdSet, projectActivityCDKContactsList);
        
        //get all the CDK users from the Project_Task__c object
        projectTaskCDKContactsList = getProjectTaskCDKClientContacts(subProjectIdSet, projectTaskCDKContactsList);
        
        
        //add the userids to the set from the recently collected CDK users
        // and get the users role and add it to the projectRoleMap
        for(SubProject_CDK_Contact__c cdkCont : subProjectCDKContactsList)
        {
            compiledUniqueCDKContactIds.add(cdkCont.CDK_Contact__c);
            projectRoleMap.put(cdkCont.CDK_Contact__c, cdkCont.Role__c);
        }
        
        
        for(Project_Activity__c cdkContAct : projectActivityCDKContactsList)
        {
            compiledUniqueCDKContactIds.add(cdkContAct.CDK_Assignee__c);
        }
        
        
        for(Project_Task__c cdkContTask : projectTaskCDKContactsList)
        {
            compiledUniqueCDKContactIds.add(cdkContTask.CDK_Assignee__c);
        }
        
        
        //get the unique set of the CDK users
        combinedUniqueCDKContactsList = [SELECT Id, Name, CompanyName, Title, Phone, Email, MobilePhone FROM User WHERE Id IN : compiledUniqueCDKContactIds];
        
        //add the unique set of Users to the wrapper List
        for(User cdkContact : combinedUniqueCDKContactsList)
        {
            CDKClientContactsWrapper newCDKContact = new CDKClientContactsWrapper();
            newCDKContact.clientName = cdkContact.Name;
            newCDKContact.companyName = cdkContact.CompanyName;
            newCDKContact.clientTitle = cdkContact.Title;
            newCDKContact.clientPhone = cdkContact.Phone;
            newCDKContact.clientEmail = cdkContact.Email;
            newCDKContact.clientMobile = cdkContact.MobilePhone;
            
            //if the contact is from the SubProject_CDK_Contact__c object get the User's role from the projectRoleMap
            if(projectRoleMap.containsKey(cdkContact.Id))
            {
                newCDKContact.projectRole = projectRoleMap.get(cdkContact.Id);
            }
            
            cdkContactWrapper.add(newCDKContact);
            
        }
        
        //return the list of the unique Users
        return cdkContactWrapper;
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Processes the subproject Id to collect all CDK users or Client contacts from milestones up to tasks.
Inputs:      subProjectIdSet -> set of subproject Ids
combineCdkContacts -> when set to true, the method's behavior and attributes will be CDK Contacts inclined, otherwise, it will be Client Contacts inclined
Returns:     Map<Id, List<CDKClientContactsWrapper>> -> a map of subprojects, whose values are lists of CDKClientContactsWrapper
History
03/24/15     Kimiko Roberto    Created
03/31/15     Kimiko Roberto    Updated to accept sets for PSR
04/08/15     Samuel Oberes     Refactored and combined both cdk contacts and and client contacts
------------------------------------------------------------*/
    public static Map<Id, List<CDKClientContactsWrapper>> combineCDKContactsOrClientsBySubProject(Set<Id> subProjectIdSet, Boolean combineCdkContacts)
    {
        Set<Id> subProjectIdSet_clone = subProjectIdSet.clone();
        Map<Id, SObject> combinedUniqueContactsMap = new Map<Id, SObject>();
        Map<Id, List<CDKClientContactsWrapper>> subProjectToContactsWrapperListMap = new Map<Id, List<CDKClientContactsWrapper>>();
        List<SObject> contactsSobjectList;
        List<SObject> projectActivitiesSobjectList = new List<SObject>();
        List<SObject> projectTasksSobjectList = new List<SObject>();
        Set<Id> compiledUniqueCDKContactIds = new Set<Id>();
        Map<Id, IMP_Project_Utility.CDKClientContactsWrapper> nonGenericAttributesMap = new Map<Id, IMP_Project_Utility.CDKClientContactsWrapper>();
        Map<Id, Set<Id>> subprojectToCdkContactSetMap = new Map<Id, Set<Id>>();
        Id subprojectId;
        Id cdkContact;
        String CONTACT_FIELD;
        String ASSIGNEE_FIELD;
        String ROLE_FIELD = 'Role__c';
        String CDK_OR_CLIENT_SUBPROJECT_FIELD = 'SubProject_ID__c';
        String CLIENT_NAME_FIELD = 'Name';
        String COMPANY_NAME_FIELD;
        String TITLE_FIELD = 'Title';
        String PHONE_FIELD = 'Phone';
        String EMAIL_FIELD = 'Email';
        String MOBILE_PHONE_FIELD = 'MobilePhone';
        String ID_FIELD = 'Id';
        String NOTES_FIELD = 'Notes__c';
        String SELECT_CLAUSE;
        String FROM_CLAUSE;
        String WHERE_CLAUSE = ' WHERE Id IN : compiledUniqueCDKContactIds ';
        String soqlQuery;
        
        if (combineCdkContacts)
        {
            // get all the CDK users from the SubProject_CDK_Contact__c object
            contactsSobjectList = retrieveCDKContactsBySet(subProjectIdSet_clone);
            CONTACT_FIELD = 'CDK_Contact__c';
            ASSIGNEE_FIELD = 'CDK_Assignee__c';
            COMPANY_NAME_FIELD = 'CompanyName';
            FROM_CLAUSE = ' FROM User ';
        }
        else
        {
            // get all the client contacts from the SubProject_Client_Contact__c object
            contactsSobjectList = retrieveClientContactsBySet(subProjectIdSet_clone);
            CONTACT_FIELD = 'Client_Contact__c';
            ASSIGNEE_FIELD = 'Client_Assignee__c';
            COMPANY_NAME_FIELD = 'Account_Name_Text__c';
            FROM_CLAUSE = ' FROM Contact ';
        }
        
        // build the query string
        SELECT_CLAUSE = 'SELECT ' + ID_FIELD + ', ' + CLIENT_NAME_FIELD + ', ' + COMPANY_NAME_FIELD + ', ' + TITLE_FIELD + ', ' + PHONE_FIELD + ', ' + EMAIL_FIELD + ', ' + MOBILE_PHONE_FIELD + ' ';
        soqlQuery = SELECT_CLAUSE + FROM_CLAUSE + WHERE_CLAUSE;
        
        //get all the CDK users from the Project_Activity__c object
        projectActivitiesSobjectList = getProjectActivityCDKClientContacts(subProjectIdSet_clone, projectActivitiesSobjectList);
        
        //get all the CDK users from the Project_Task__c object
        projectTasksSobjectList = getProjectTaskCDKClientContacts(subProjectIdSet_clone, projectTasksSobjectList);
        
        // add the userids to the set from the recently collected CDK users
        // and get the role and notes and add it to the nonGenericAttributesMap
        for(SObject contact : contactsSobjectList)
        {
            if (contact.get(CONTACT_FIELD) != null)
            {
                cdkContact = (Id)contact.get(CONTACT_FIELD);
                compiledUniqueCDKContactIds.add(cdkContact);
                
                IMP_Project_Utility.CDKClientContactsWrapper contactWrapper = new IMP_Project_Utility.CDKClientContactsWrapper();
                contactWrapper.projectRole = (String)contact.get(ROLE_FIELD);
                contactWrapper.notes       = (String)contact.get(NOTES_FIELD);
                nonGenericAttributesMap.put(cdkContact, contactWrapper);
                
                subprojectId = (Id)contact.get('SubProject__c');
                subProjectIdSet_clone.remove(subprojectId);
                
                if (subprojectToCdkContactSetMap.keySet().contains(subprojectId)) 
                {
                    subprojectToCdkContactSetMap.get(subprojectId).add(cdkContact);
                }
                else
                {
                    subprojectToCdkContactSetMap.put(subprojectId, new Set<Id>{ cdkContact });
                }
            }
        }
        
        for(SObject activity : projectActivitiesSobjectList)
        {
            if (activity.get(ASSIGNEE_FIELD) != null)
            {
                cdkContact = (Id)activity.get(ASSIGNEE_FIELD);
                compiledUniqueCDKContactIds.add(cdkContact);
                
                subprojectId = (Id)activity.get(CDK_OR_CLIENT_SUBPROJECT_FIELD);
                subProjectIdSet_clone.remove(subprojectId);
                
                if (subprojectToCdkContactSetMap.keySet().contains(subprojectId)) 
                {
                    subprojectToCdkContactSetMap.get(subprojectId).add(cdkContact);
                }
                else
                {
                    subprojectToCdkContactSetMap.put(subprojectId, new Set<Id>{ cdkContact });
                }
            }
        }
        
        for(SObject task : projectTasksSobjectList)
        {
            if (task.get(ASSIGNEE_FIELD) != null)
            {
                cdkContact = (Id)task.get(ASSIGNEE_FIELD);
                compiledUniqueCDKContactIds.add(cdkContact);
                
                subprojectId = (Id)task.get(CDK_OR_CLIENT_SUBPROJECT_FIELD);
                subProjectIdSet_clone.remove(subprojectId);
                
                if (subprojectToCdkContactSetMap.keySet().contains(subprojectId)) 
                {
                    subprojectToCdkContactSetMap.get(subprojectId).add(cdkContact);
                }
                else
                {
                    subprojectToCdkContactSetMap.put(subprojectId, new Set<Id>{ cdkContact });
                }
            }
        }
        
        // populate the map with SP Ids where values are blanks
        for (Id spId : subProjectIdSet_clone)
        {
            subprojectToCdkContactSetMap.put(spId, new Set<Id>());
        }
        
        // get the unique set of the users/contacts
        combinedUniqueContactsMap = new Map<Id, SObject>(Database.query(soqlQuery));
        
        // add the unique set of users/contacts to the wrapper List.
        // loop across all subproject ids
        for (Id spId : subprojectToCdkContactSetMap.keySet()) 
        {
            if (subprojectToCdkContactSetMap.get(spId).size() > 0)
            {
                // loop across all user ids per subproject
                for (Id contactId : subprojectToCdkContactSetMap.get(spId))
                {
                    CDKClientContactsWrapper newCDKContact = new CDKClientContactsWrapper();
                    SObject obj = combinedUniqueContactsMap.get(contactId);
                    newCDKContact.clientName   = (String)obj.get(CLIENT_NAME_FIELD);
                    newCDKContact.companyName  = (String)obj.get(COMPANY_NAME_FIELD);
                    newCDKContact.clientTitle  = (String)obj.get(TITLE_FIELD);
                    newCDKContact.clientPhone  = (String)obj.get(PHONE_FIELD);
                    newCDKContact.clientEmail  = (String)obj.get(EMAIL_FIELD);
                    newCDKContact.clientMobile = (String)obj.get(MOBILE_PHONE_FIELD);
                    
                    // if the contact is from the SubProject_CDK_Contact__c or SubProject_Client_Contact__c object, get the user/contact's role from the nonGenericAttributesMap
                    if(nonGenericAttributesMap.containsKey((Id)obj.get(ID_FIELD)))
                    {
                        newCDKContact.projectRole = nonGenericAttributesMap.get((Id)obj.get(ID_FIELD)).projectRole;
                        newCDKContact.notes       = nonGenericAttributesMap.get((Id)obj.get(ID_FIELD)).notes;
                    }
                    
                    if (subProjectToContactsWrapperListMap.keySet().contains(spId)) 
                    {
                        subProjectToContactsWrapperListMap.get(spId).add(newCDKContact);
                    }
                    else
                    {
                        subProjectToContactsWrapperListMap.put(spId, new List<CDKClientContactsWrapper>{ newCDKContact });
                    }
                }
            }
            else
            {
                subProjectToContactsWrapperListMap.put(spId, new List<CDKClientContactsWrapper>());
            }
        }
        
        // return the list of the unique Users
        return subProjectToContactsWrapperListMap;
    }
    
    /*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Processes the subproject Id to collect all client contacts from milestones up to tasks
Inputs:      
Returns:     
History
03/24/15     Kimiko Roberto    Created
03/31/15     Kimiko Roberto    Updated to accept sets for PSR
02/16/16    Venkata Shrivol     Commented this method out as it is not referenced anywhere
------------------------------------------------------------*/
  /*  public static List<CDKClientContactsWrapper> combineClientContacts(Set<Id> subProjectIdSet)
    {
        Set<SubProject_Client_Contact__c> uniqueClientContactSet = new Set<SubProject_Client_Contact__c>();
        List<Contact> combinedUniqueClientContactsList = new List<Contact>();
        List<CDKClientContactsWrapper> clientContactWrapper = new List<CDKClientContactsWrapper>();
        List<SubProject_Client_Contact__c> subProjectClientContactsList = new List<SubProject_Client_Contact__c>();
        List<Project_Activity__c> projectActivityClientContactsList = new List<Project_Activity__c>();
        List<Project_Task__c> projectTaskClientContactsList = new List<Project_Task__c>();
        Set<Id> compiledUniqueClientContactIds = new Set<Id>();
        Map<Id,String> projectRoleMap = new Map<Id,String>();
        
        //get all the client contacts from the SubProject_Client_Contact__c object
        subProjectClientContactsList = retrieveClientContactsBySet(subProjectIdSet);
        
        //get all the client contacts from the Project_Activity__c object
        projectActivityClientContactsList = getProjectActivityCDKClientContacts(subProjectIdSet, projectActivityClientContactsList);
        
        //get all the client contacts from the Project_Task__c object
        projectTaskClientContactsList = getProjectTaskCDKClientContacts(subProjectIdSet, projectTaskClientContactsList);
        
        //add the userids to the set from the recently collected CDK users
        // and get the users role and add it to the projectRoleMap
        for(SubProject_Client_Contact__c cdkCont : subProjectClientContactsList)
        {
            compiledUniqueClientContactIds.add(cdkCont.Client_Contact__c);
            projectRoleMap.put(cdkCont.Client_Contact__c, cdkCont.Role__c);    
        }
        
        
        for(Project_Activity__c cdkContAct : projectActivityClientContactsList)
        {
            compiledUniqueClientContactIds.add(cdkContAct.Client_Assignee__c);
        }
        
        
        for(Project_Task__c cdkContTask : projectTaskClientContactsList)
        {
            compiledUniqueClientContactIds.add(cdkContTask.Client_Assignee__c);
        }
        
        //get the unique set of the client contacts
        combinedUniqueClientContactsList = [SELECT Id, Name, Account_Name_Text__c, Title, Phone, Email, MobilePhone FROM Contact WHERE Id IN : compiledUniqueClientContactIds];
        
        //add the unique set of contacts to the wrapper List
        for(Contact clientContact : combinedUniqueClientContactsList)
        {
            CDKClientContactsWrapper newClientContact = new CDKClientContactsWrapper();
            newClientContact.clientName = clientContact.Name;
            newClientContact.companyName = clientContact.Account_Name_Text__c;
            newClientContact.clientTitle = clientContact.Title;
            newClientContact.clientPhone = clientContact.Phone;
            newClientContact.clientEmail = clientContact.Email;
            newClientContact.clientMobile = clientContact.MobilePhone;
            
            //if the contact is from the SubProject_Client_Contact__c object get the User's role from the projectRoleMap
            if(projectRoleMap.containsKey(clientContact.Id))
            {
                newClientContact.projectRole = projectRoleMap.get(clientContact.Id);
            }
            
            clientContactWrapper.add(newClientContact);
            
        }
        
        //return the list of the unique Users
        return clientContactWrapper;
    }
    */
    /*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Wrapper class that will contain the virtual list of the collected unique CDK Client contacts.
Inputs:      
Returns:     
History
03/24/15     Kimiko Roberto    Created
------------------------------------------------------------*/    
    global class CDKClientContactsWrapper
    {
        public String clientName {get;set;}
        public String companyName {get;set;}
        public String projectRole {get;set;}
        public String clientTitle {get;set;}
        public String clientPhone {get;set;}
        public String clientEmail {get;set;}
        public String clientMobile {get; set;}
        public String notes {get; set;}
    }
    
    
    /*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Collects a list of SubProject_CDK_Contact__c from a given subproject Id.
Inputs:      
Returns:     
History
03/24/15     Kimiko Roberto    Created
------------------------------------------------------------*/ 
    /*
public static List<SubProject_CDK_Contact__c> getSubProjectCDKContacts(Id subProjectId)
{
List<SubProject_CDK_Contact__c> subProjectCDKContactsList = new List<SubProject_CDK_Contact__c>();

if(subProjectCDKContactsList != null && !subProjectCDKContactsList.isEmpty())
{
return subProjectCDKContactsList;
}
else
{
subProjectCDKContactsList = queryRelatedRecords(SObjectType.SubProject_CDK_Contact__c.FieldSets.CDK_Contact_Commons.getFields(),
'SubProject_CDK_Contact__c','SubProject__c',subProjectId,null,null,null,true,0);
}

return subProjectCDKContactsList;

}
*/
    
    /*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Collects a list of CDK or Client Contacts from a Project Activity under a subproject from a given subproject Id.
Inputs:      
Returns:     
History
03/24/15     Kimiko Roberto    Created
03/31/15     Kimiko Roberto    Updated to accept sets for PSR
------------------------------------------------------------*/ 
    public static List<Project_Activity__c> getProjectActivityCDKClientContacts(Set<Id> subProjectIdSet, List<Project_Activity__c> projectActivityCDKContactsList)
    {
        
        
        if(projectActivityCDKContactsList != null && !projectActivityCDKContactsList.isEmpty())
        {
            return projectActivityCDKContactsList;
        }
        else
        {
            projectActivityCDKContactsList = queryRelatedRecords(SObjectType.Project_Activity__c.FieldSets.Activity_Commons.getFields(),
                                                                 'Project_Activity__c','Milestone__r.SubProject__r.Id',null,subProjectIdSet,null,null,true,0);
        }
        
        return projectActivityCDKContactsList;
        
    }
    
    /*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Collects a list of CDK or Client Contacts from a Project Task under a subproject from a given subproject Id.
Inputs:      
Returns:     
History
03/24/15     Kimiko Roberto    Created
03/31/15     Kimiko Roberto    Updated to accept sets for PSR
------------------------------------------------------------*/ 
    public static List<Project_Task__c> getProjectTaskCDKClientContacts(Set<Id> subProjectIdSet, List<Project_Task__c> projectTaskCDKContactsList)
    {
        
        
        if(projectTaskCDKContactsList != null && !projectTaskCDKContactsList.isEmpty())
        {
            return projectTaskCDKContactsList;
        }
        else
        {
            projectTaskCDKContactsList = queryRelatedRecords(SObjectType.Project_Task__c.FieldSets.Task_Commons.getFields(),
                                                             'Project_Task__c', 'Project_Activity__r.Milestone__r.SubProject__r.Id', null, subProjectIdSet, null, null, true, 0);
        }
        
        return projectTaskCDKContactsList;
        
    }
    
    
    /*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Collects a list of SubProject_Client_Contact__c from a given subproject Id.
Inputs:      
Returns:     
History
03/24/15     Kimiko Roberto    Created
------------------------------------------------------------*/ 
    /*
public static List<SubProject_Client_Contact__c> getSubProjectClientContacts(Id subProjectId)
{
List<SubProject_Client_Contact__c> subProjectClientContactsList = new List<SubProject_Client_Contact__c>();

if(subProjectClientContactsList != null && !subProjectClientContactsList.isEmpty())
{
return subProjectClientContactsList;
}
else
{
subProjectClientContactsList = queryRelatedRecords(SObjectType.SubProject_Client_Contact__c.FieldSets.Client_Contact_Commons.getFields(),
'SubProject_Client_Contact__c','SubProject__c',subProjectId,null,null,null,true,0);
}

return subProjectClientContactsList;

}
*/
    
    
    
    /*------------------------------------------------------------
Author:      Jerick Laurio
Company:     Cloud Sherpas
Description: A method that creates a SOQL query string based on the field set and sobject setup on custom setting
Inputs:      - Schema.FieldSet - fieldSetName -> an object of type Schema.Fieldset that contains the fieldnames to be used for the SOQL select statement
- String - objectAPIName -> the name of the object where the fieldset resides
Returns:     String
History:
03/16/15     Jerick Laurio    Created
03/25/15     Samuel Oberes    Relocated this code from IMP_FollowedRecords_Controller
------------------------------------------------------------*/
    public static String createSOQLSelect(Schema.FieldSet fieldSetName, String objectAPIName)
    {
        System.debug('\n\n#####[createSOQLSelect] objectAPIName='+objectAPIName+'#####\n\n');
        System.debug('\n\n#####[createSOQLSelect] fieldSetName='+fieldSetName+'#####\n\n');
        List<Schema.FieldSetMember> fieldSetMemberList = fieldSetName.getFields();
        String soqlSelectQueryString = 'SELECT Id';
        for (Schema.FieldSetMember fsetMember : fieldSetMemberList)
        {
            if (fsetMember.getFieldPath() != 'Id')
            {
                soqlSelectQueryString += ', ' + fsetMember.getFieldPath();
            }
        }
        soqlSelectQueryString += ' FROM ' + objectAPIName;
        return soqlSelectQueryString;
    }
    
    public static void assignIntegerFieldValue(String fieldName, SObject objectToUpdate, Integer value)
    {
        try
        {
            objectToUpdate.put(fieldName, value);
        } 
        catch (Exception ex)
        {
            objectToUpdate.addError(ex.getMessage());
        }
    }
    /*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: 
Inputs:      
Returns:     
History
02/12/15     Kimiko Roberto    Created
04/07/15     Kimiko Roberto    Updated name and comments
------------------------------------------------------------*/
    /* 2015-8-14 Kimiko Roberto - Commented out method
    public static Map<Id, Boolean> updateParentActualEndDate(Map<Id, Date> endDateMap, Set<Id> parentIds,sObjectType sObj){
        
        system.Debug('**parentIds'+parentIds);
        List<sObject> sObjectList = new List<sObject>();
        //Retrieve Parent Ids above
        if(sObj == Project_Activity__c.sobjecttype){
            sObjectList = retrieveActivities(parentIds);
        }
        else if(sObj == Project_Task__c.sobjecttype){
            sObjectList = retrieveTasks(parentIds);
        }
        
        Boolean isSuccess = true;
        
        //This map is used to support the for loop below to confirm parent Ids to end date
        Map<Id, Boolean> idsToEndDateMap = new Map<Id, Boolean>();
        
        //This list captures all of the terminal child records
        List<sObject> terminalActivityTaskList = new List<sObject>();
        
        //This map captures all of the terminal child records that should not be end dated, given non-terminal child record's end dates
        //Ultimately, it's passed pack to the calling trigger to add an error to the project activities
        Map<Id, Boolean> terminalActivityTaskIdtoSuccessMap = new Map<Id, Boolean>();
        
        //This map is sent back to the caller of the method to support error handling to notify user when a project
        //terminal child records can't be end dated, since other non-terminal child records haven't yet been
        //end dated
        Map<sObject, Boolean> sObjectEndDateUpdateSuccess = new Map<sObject, Boolean>();
        
        // Stores the number of child records per parent
        Map<Id, Integer> childObjectCountMap = new Map<Id, Integer>();
        system.Debug('**sObjectList'+sObjectList);
        
        if(!sObjectList.isEmpty()){
            
            //Loop through the child records retrieved from the project utility class based upon matching parent ids.
            //Process each to confirm if its parent should be end dated, and provide the caller a result to
            //support its error handling of terminal child records that can not be end dated.
            for(sObject pa: sObjectList)
            {
                // Counts how many child records instances there is per parent
                if(sObj == Project_Activity__c.sobjecttype)
                {
                    childObjectCountMap.put(
                        (Id)pa.get('Milestone__c'), 
                        ( childObjectCountMap.get((Id)pa.get('Milestone__c')) == null ? 1 : childObjectCountMap.get((Id)pa.get('Milestone__c')) + 1 ) 
                    );
                }
                else if(sObj == Project_Task__c.sobjecttype)
                {
                    childObjectCountMap.put(
                        (Id)pa.get('Project_Activity__c'), 
                        ( childObjectCountMap.get((Id)pa.get('Project_Activity__c')) == null ? 1 : childObjectCountMap.get((Id)pa.get('Project_Activity__c')) + 1 ) 
                    );
                }
                
                //Validate if all non Terminal child records have Actual End Dates, else return error
                //The 'if' block confirms stamps a failed qualification value into the parent to update if it finds a non-terminal
                //child record with a null actual end Date
                if(sObj == Project_Activity__c.sobjecttype)
                {
                    if(!(Boolean)pa.get('Terminal_Activity__c') && (Date)pa.get('Actual_End_Date__c') == null)
                    {
                        isSuccess = false;
                        idsToEndDateMap.put((Id)pa.get('milestone__c'), isSuccess);
                        
                    }
                    //This 'else if' block stamps a successful qualification value into the parent to update map if it finds a non-terminal
                    //child record with a non-null actual end date.
                    else if (!(Boolean)pa.get('Terminal_Activity__c') && (Date)pa.get('Actual_End_Date__c') != null)
                    {
                        isSuccess = true;
                        Boolean mapContainsParentObject;
                        mapContainsParentObject = idsToEndDateMap.containskey((Id)pa.get('milestone__c'));
                        
                        if (!mapContainsParentObject) 
                        {
                            idsToEndDateMap.put((Id)pa.get('milestone__c'), isSuccess);
                        }
                        else 
                        {
                            //do nothing
                        }
                    }
                    //This 'else if' block catches the terminal child records
                    else if ((Boolean)pa.get('Terminal_Activity__c')) 
                    {
                        System.debug('$$$ About to add a terminal activity to the terminal activity list to evaluate.');
                        terminalActivityTaskList.add(pa);
                        System.debug('$$$ The terminal Project Activity List is now size:' + terminalActivityTaskList);
                    }
                }
                else if(sObj == Project_Task__c.sobjecttype)
                {
                    if(!(Boolean)pa.get('Terminal_Task__c') && (Date)pa.get('Actual_End_Date__c') == null)
                    {
                        isSuccess = false;
                        idsToEndDateMap.put((Id)pa.get('Project_Activity__c'), isSuccess);  
                    }
                    //This 'else if' block stamps a successful qualification value into the parent to update map if it finds a non-terminal
                    //child records with a non-null actual end date.
                    else if (!(Boolean)pa.get('Terminal_Task__c') && (Date)pa.get('Actual_End_Date__c') != null)
                    {
                        isSuccess = true;
                        Boolean mapContainsParentObject;
                        mapContainsParentObject = idsToEndDateMap.containskey((Id)pa.get('Project_Activity__c'));
                        
                        if (!mapContainsParentObject)
                        {
                            idsToEndDateMap.put((Id)pa.get('Project_Activity__c'), isSuccess);  
                        }
                        else 
                        {
                            //do nothing
                        }
                    }
                    //This 'else if' block catches the terminal child records
                    else if ((Boolean)pa.get('Terminal_Task__c')) 
                    {
                        System.debug('$$$ About to add a terminal activity to the terminal activity list to evaluate.');
                        terminalActivityTaskList.add(pa);
                        System.debug('$$$ The terminal Project Activity List is now size:' + terminalActivityTaskList);
                    }
                }
            }
        }
        
        // Another iteration over the child record list. 
        // The purpose of this loop is to create an entry in the idsToEndDateMap map 
        //   for parentids that only has 1 child record. This child record is terminal and contains an actual end date.
        // Purpose: This is crucial for the 1-parent-1-child record scenario so that the parent's actual end date will get updated
        for (sObject pa : sObjectList) {
            if(sObj == Project_Activity__c.sobjecttype){
                if (childObjectCountMap.get((Id)pa.get('Milestone__c')) == 1 && (Boolean)pa.get('Terminal_Activity__c') && (Date)pa.get('Actual_End_Date__c') != null) {
                    idsToEndDateMap.put((Id)pa.get('Milestone__c'), true);
                }
            }
            else if(sObj == Project_Task__c.sobjecttype){
                if (childObjectCountMap.get((Id)pa.get('Project_Activity__c')) == 1 && (Boolean)pa.get('Terminal_Task__c') && (Date)pa.get('Actual_End_Date__c') != null) {
                    idsToEndDateMap.put((Id)pa.get('Project_Activity__c'), true);
                }
            }
            
        }
        
        if (!terminalActivityTaskList.isEmpty()){
            for(sObject pa2: terminalActivityTaskList){
                Boolean mapContainsParentObject2;
                if(sObj == Project_Activity__c.sobjecttype)
                {
                    mapContainsParentObject2 = idsToEndDateMap.containskey((Id)pa2.get('milestone__c'));
                }
                else if (sObj == Project_Task__c.sobjecttype)
                {
                    mapContainsParentObject2 = idsToEndDateMap.containskey((Id)pa2.get('Project_Activity__c'));
                }
                
                if (mapContainsParentObject2) {
                    System.debug('$$$ The size of idsToEndDateMap is ' + idsToEndDateMap.size());
                    Boolean isSuccess2;
                    if(sObj == Project_Activity__c.sobjecttype)
                    {
                        isSuccess2 = idsToEndDateMap.get((Id)pa2.get('milestone__c'));
                    }
                    else if(sObj == Project_Task__c.sobjecttype){
                        isSuccess2 = idsToEndDateMap.get((Id)pa2.get('Project_Activity__c'));
                    }
                    
                    // sObjectEndDateUpdateSuccess.put(pa2, isSuccess2);
                    if (!isSuccess2) {
                        System.debug('$$$ Found a terminal activity that had a milestone id in the map that is marked as failed.');
                        terminalActivityTaskIdtoSuccessMap.put(pa2.Id,false);
                        System.debug('$$$ Just added a terminal project activity to the error map to return back.');
                        System.debug('$$$ The terminal Project Activity ERROR Map is now size:' + terminalActivityTaskIdtoSuccessMap.size());
                    }
                }
            }
        }
        
        if(!idsToEndDateMap.isEmpty())
        {
            Set <Id> parentIdstoEvaluate = new Set <Id>();
            Set <Id> parentIdstoUpdate = new Set <Id>();
            
            parentIdstoEvaluate  = idsToEndDateMap.keyset();
            
            for (Id mId: parentIdstoEvaluate) {
                if (idsToEndDateMap.get(mId)) {
                    parentIdstoUpdate.add(mId);
                }
            }
            List<sObject> parentObjectToUpdateList = new List<sObject>();
            
            if(sObj == Project_Activity__c.sobjecttype)
            {
                parentObjectToUpdateList = retrieveMilestonesBySet(parentIdstoUpdate, QUERY_NAME_ID);
            }
            else if(sObj == Project_Task__c.sobjecttype)
            {
                parentObjectToUpdateList = retrieveActivities_2(parentIdstoUpdate);
            }
            
            for(sObject pm: parentObjectToUpdateList)
            {
                //Set Project Milestone Actual end date = value from endDateMap
                pm.put('Actual_End_Date__c',endDateMap.get(String.valueOf(pm.get('Id'))));
                
                //Update parent records
                try 
                {
                    update parentObjectToUpdateList;
                } 
                catch (DmlException e)
                {
                    System.debug('$$$ update parentObjectToUpdateList DmlException: '+e);
                }
            }
        }
        
        System.debug('$$$ Right before returning it, the terminal Project Activity ERROR map is now size:' + terminalActivityTaskIdtoSuccessMap.size());
        return terminalActivityTaskIdtoSuccessMap;
        
    } */
    
    public static String getOrderColumns(List<Schema.FieldSetMember> fieldSetMembers,Boolean appendOrderBy)
    {
        String orderColumns = '';
        for(Schema.FieldSetMember f : fieldSetMembers){
            orderColumns += f.getFieldPath() + ',';
        }
        if (orderColumns != '' && appendOrderBy)
        {
            orderColumns = 'Order by ' + orderColumns.subString(0, orderColumns.length() - 1); 
        }
        
        return orderColumns;
    }
    /*------------------------------------------------------------
          Author: Kimiko Roberto
          Company: Cloud Sherpas
          Description: Checks if the user has the PermissionSet assigned based on Permission Sets in the custom setting IMP_ProfilesToByPass__c.
          History
          5/21/15    Kimiko Roberto      Created
    ------------------------------------------------------------*/
    public static Boolean permissionSetCanByPass(String byPassKey, Id userId){
        Boolean canByPass = false;
        // System.debug('Value of byPassKey is ' + byPassKey);
        // System.debug('Value of userId is ' + userId);
        IMP_ProfilesToByPass__c byPassDetails = IMP_ProfilesToByPass__c.getValues(byPassKey);
        // System.debug('Value of byPassDetails.Permission_Set__c is ' + byPassDetails.Permission_Set__c);
    
        List<PermissionSetAssignment> permAssignDetails = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId];
        Set<Id> permSetIdSet = new Set<Id>();
        List<PermissionSet> permissionSetDetials = new List<PermissionSet>();
        
        if(byPassDetails != null)
        {
            if(permAssignDetails != null && !permAssignDetails.isEmpty())
            {
                for(PermissionSetAssignment psa : permAssignDetails)
                {
                    permSetIdSet.add(psa.PermissionSetId);
                }
                
                if(permSetIdSet != null && !permSetIdSet.isEmpty())
                {
                    permissionSetDetials = [SELECT Id, Name FROM PermissionSet WHERE Id IN :permSetIdSet];
                    
                    if(permissionSetDetials != null && !permissionSetDetials.isEmpty())
                    {
                        for(PermissionSet ps : permissionSetDetials)
                        {
                            if(byPassDetails.Permission_Set__c.Contains(ps.Name))
                            {
                                canByPass = true;
                            }
                        }
                    }
                }
            }
        }

        // System.debug('Value of permissionSetDetials.Name is ' + permissionSetDetials.Name);

        // System.debug('Value of canByPass that will be returned is ' + canByPass);
        return canByPass;   
    }
/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Checks if the profile of the is in the list of bypassing profiles from the custom setting IMP_ProfilesToByPass.
History
5/29/15    Kimiko Roberto      Created
------------------------------------------------------------*/
    public static Map<Id, Boolean> profileCanByPass_2(){
    
        Map<Id, Boolean> profileMap = new Map<Id, Boolean>();
        Map<String, IMP_ProfilesToByPass__c> integrationProfilesMap = IMP_ProfilesToByPass__c.getAll();
        List<String> keyNames = new List<String>();
        List<String> profileNamesList = new List<String>();
        Set<String> profileNameSet = new Set<String>();
        keyNames.addAll(integrationProfilesMap.keySet());
        
        for(String keyName : keyNames)
        {
            String profileName = integrationProfilesMap.get(keyName).Profile__c;
            List<String> splitStringList = new List<String>();
            if(profileName != null && profileName != '')
            {
                splitStringList = profileName.split(',');
            }
            for(String pName : splitStringList)
            {
                profileNameSet.add(pName);
            }
        }
        
        if(!profileNameSet.isEmpty())
        {   
            profileNamesList.addAll(profileNameSet);
        }
        
        List<Profile> userProfileList = [SELECT Id, Name FROM Profile WHERE Name IN :profileNamesList];
        
        // System.debug('Value of userProfile.Name is ' + userProfile.Name);
        if(userProfileList != null && !userProfileList.isEmpty())
        {
            for(Profile p : userProfileList)
            {
                profileMap.put(p.Id,true);
            }
        }
        return profileMap;
    }
    /*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Checks if the user has the PermissionSet assigned based on Permission Sets in the custom setting IMP_ProfilesToByPass__c.
History
5/29/15    Kimiko Roberto      Created
------------------------------------------------------------*/
    public static Map<Id, Boolean> permissionSetCanByPass_2(){
    
        Map<Id, Boolean> assigneeIdMap = new Map<Id, Boolean>();
        Map<String, IMP_ProfilesToByPass__c> byPassDetailsMap = IMP_ProfilesToByPass__c.getAll();
        List<String> keyNames = new List<String>();
        List<String> permissionNamesList = new List<String>();
        Set<String> permissionNamesSet = new Set<String>();
        keyNames.addAll(byPassDetailsMap.keySet());
        
        for(String keyName : keyNames)
        {
            String permissionName = byPassDetailsMap.get(keyName).Permission_Set__c;
            List<String> splitStringList = new List<String>();
            if(permissionName != null && permissionName != '')
            {
                splitStringList = permissionName.split(',');
            } 
            for(String pName : splitStringList)
            {
                permissionNamesSet.add(pName);
            }
        }
        
        if(!permissionNamesSet.isEmpty())
        {   
            permissionNamesList.addAll(permissionNamesSet);
        }
        List<PermissionSet> permissionSetDetialsList = [SELECT Id FROM PermissionSet WHERE Name IN :permissionNamesList];
        List<PermissionSetAssignment> permAssignDetailsList = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId IN: permissionSetDetialsList];
        
        // System.debug('Value of userProfile.Name is ' + userProfile.Name);
        if(permAssignDetailsList != null && !permAssignDetailsList.isEmpty())
        {
            for(PermissionSetAssignment p : permAssignDetailsList)
            {
                assigneeIdMap.put(p.AssigneeId,true);
            }
        }
        return assigneeIdMap;
    }
    /*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Checks if the user has the PermissionSet/Profile assigned based in the custom setting IMP_ProfilesToByPass__c.
History
6/02/15    Kimiko Roberto      Created
------------------------------------------------------------*/
    public static Map<Id, Boolean> userCanByPass(sObjectType sObj){
    
        Map<Id, Boolean> byPassValuesMap = new Map<Id, Boolean>();
        Map<String, IMP_ProfilesToByPass__c> byPassDetailsMap = IMP_ProfilesToByPass__c.getAll();
        List<String> keyNames = new List<String>();
        List<String> profileOrPermissionNamesList = new List<String>();
        Set<String> profileOrPermissionNameSet = new Set<String>();
        keyNames.addAll(byPassDetailsMap.keySet());
        Boolean isSobjectProfile = false;
        
        if(sObj == Profile.sObjectType)
        {
            isSobjectProfile = true;
        }
        
        
        for(String keyName : keyNames)
        {
            String profileOrPermissionName;
            if(isSobjectProfile)
            {
                profileOrPermissionName = byPassDetailsMap.get(keyName).Profile__c;
            }
            else if(!isSobjectProfile)
            {
                profileOrPermissionName = byPassDetailsMap.get(keyName).Permission_Set__c;
            }
            
            List<String> splitStringList = new List<String>();
            if(profileOrPermissionName != null && profileOrPermissionName != '')
            {
                splitStringList = profileOrPermissionName.split(',');
            }
            for(String pName : splitStringList)
            {
                profileOrPermissionNameSet.add(pName);
            }
        }
        
        if(!profileOrPermissionNameSet.isEmpty())
        {   
            profileOrPermissionNamesList.addAll(profileOrPermissionNameSet);
        }
        List<sObject> userProfileOrPermissionList = new List<sObject>();
        
        if(isSobjectProfile)
        {
            userProfileOrPermissionList = [SELECT Id, Name FROM Profile WHERE Name IN :profileOrPermissionNamesList];
        }
        else if(!isSobjectProfile)
        {
            List<PermissionSet> permissionSetDetialsList = [SELECT Id FROM PermissionSet WHERE Name IN :profileOrPermissionNamesList];
            userProfileOrPermissionList = [SELECT Id, AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE PermissionSetId IN: permissionSetDetialsList];
        }
        
        
        
        // System.debug('Value of userProfile.Name is ' + userProfile.Name);
        if(userProfileOrPermissionList != null && !userProfileOrPermissionList.isEmpty())
        {
            for(sObject p : userProfileOrPermissionList)
            {
                if(isSobjectProfile)
                {
                    byPassValuesMap.put(p.Id,true);
                }
                else if(!isSobjectProfile)
                {
                    byPassValuesMap.put((Id)p.get('AssigneeId'),true);
                }
                
            }
        }
        return byPassValuesMap;
    }
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Count the number of site that is associated in the milestone record
    History
    07/22/2015    Rey Austral      Created
    ------------------------------------------------------------*/    
    public static Map<Id,AggregateResult> countSiteReferenceInMilestone(Set<Id> siteIdSet)
    {
        Map<Id,AggregateResult> siteInMilestoneMap = new Map<id,AggregateResult>([SELECT site__c Id, COUNT(Id) numberOfSite FROM Project_Milestone__c WHERE site__c IN: siteIdSet GROUP BY site__c]); 
        return siteInMilestoneMap;
    }
    
     /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Count the number of account and subproject that is associated in the discovery record
    History
    07/22/2015    Rey Austral      Created
    ------------------------------------------------------------*/  
    public static List<AggregateResult> countSiteReferenceInDiscovery(Set<Id> accountIdSet, Set<Id> subProjectId)
    {
        List<AggregateResult> siteInDiscoveryList = [SELECT SubProject__c, site__c, COUNT(Id) numberOfDiscovery FROM Site_Workbook__c WHERE site__c IN: accountIdSet and SubProject__c IN: subProjectId GROUP BY site__c, SubProject__c]; 
        return siteInDiscoveryList;
    }
    
     /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Check if the Subproject is reference in a discovery record
    History
    08/06/2015    Rey Austral      Created
    ------------------------------------------------------------*/    
    public static Boolean isSiteReferenceInDiscovery(List<AggregateResult> siteInDiscoveryList, String accountId, String subprojectId)
    {
        Boolean result = false;
        if (!siteInDiscoveryList.isEmpty())
        {
            for(AggregateResult agg: siteInDiscoveryList)
            {
                if ((String)agg.get('SubProject__c')== subprojectId && (String)agg.get('site__c') == accountId)
                {
                    Integer countSiteInDiscovery = (Integer)agg.get('numberOfDiscovery');
                    if (countSiteInDiscovery > 0)
                    {
                        result = true;
                    }
                    break;
                }                
            }
        }
        return result;
        
    }   
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Get records that is already added in the Milestone Object 
    History
    08/06/2015    Rey Austral      Created
    ------------------------------------------------------------*/    
    public static List<Project_Milestone__c> findExistingSubProjectRecsForMilestoneDefs(Set<Id> projectTypeProductMilestoneDefinitionSet, String subProjectId, string siteId  )
    {
        List<Project_Milestone__c> resultList = new List<Project_Milestone__c>();
        if (siteId != null && siteId != '')
        {
            resultList = [Select Id,Milestone_Definition__c, RMS_Owned_flag__c,Non_RMS_Owned_Standard_Activities_Create__c from Project_Milestone__c
                          where Subproject__c =: subProjectId and Milestone_Definition__c IN: projectTypeProductMilestoneDefinitionSet and Site__c =: siteId 
                                ];
        }
        else
        {
             resultList = [Select Id,Milestone_Definition__c from Project_Milestone__c where Subproject__c =: subProjectId and Milestone_Definition__c IN: projectTypeProductMilestoneDefinitionSet  and RMS_Owned_flag__c = true];
        }
        return resultList;
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Check if the fields in the task has been change when the user update the record
    History
    08/06/2015    Rey Austral      Created
    ------------------------------------------------------------*/    
    public static Boolean checkTaskFieldIfChange(Project_Task__c newTask, Project_Task__c oldTask)
    {
        Boolean result = false;
        //get the field name in the field set
        for(Schema.FieldSetMember f : SObjectType.Project_Task__c.FieldSets.Task_Prevent_Edit.getFields())
        {
            //compare the new field to the old field
            if(newTask.get( f.getFieldPath() ) != oldTask.get( f.getFieldPath() ) )
            {
                result = true;
            }
        }
        return result;
    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Generic wrapper for milestone, activity, and task. To be used by PSR.
    History
    08/17/15      Samuel Oberes    Created
    ------------------------------------------------------------*/  
    //public class PSRMilestoneTabDetails
    //{
    //    public String id { get; set; }

    //    // SubProject Description
    //    public String subProjectName { get; set; }

    //    // Subproject Site
    //    public String siteName { get; set; }

    //    // As of 8/12/15, this is one of the ff: Milestone, Activity, Task
    //    //public String recordType 
    //    //{ 
    //    //    get; 
    //    //    set
    //    //    {
    //    //        String lowerCaseVal = value.toLowerCase();
    //    //        if (lowerCaseVal != 'milestone' && 
    //    //            lowerCaseVal != 'activity' &&
    //    //            lowerCaseVal != 'task')
    //    //        {
    //    //            throw new PSRMilestoneTabDetailsException('Invalid record type \'' + recordType + '\'.');
    //    //        }
    //    //        else
    //    //        {
    //    //            recordType = value;
    //    //        }
    //    //    }
    //    //}

    //    // Description__c of either Milestone, Activity, Task, etc.
    //    public String recordDescription { get; set; }
    //    public Date plannedStartDate { get; set; }
    //    public Date plannedEndDate { get; set; }
    //    public Date actualStartDate { get; set; }
    //    public Date actualEndDate { get; set; }
    //    public String status { get; set; }
    //    public String comments { get; set; }
    //    public String cDKAssigneeName { get; set; }
    //    public String cDKAssigneeRole { get; set; }
    //    public String clientAssigneeName { get; set; }
    //    public Map<Id, IMP_Project_Utility.PSRMilestoneTabDetails> childrenMap 
    //    { 
    //        get
    //        {
    //            if (childrenMap == null)
    //            {
    //                childrenMap = new Map<Id, IMP_Project_Utility.PSRMilestoneTabDetails>();
    //            }
    //            return childrenMap;
    //        } 
    //        set; 
    //    }
    //}

    //public class PSRMilestoneTabDetailsException extends Exception {}
}