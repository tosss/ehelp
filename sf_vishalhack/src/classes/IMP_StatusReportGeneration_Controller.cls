/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Responsible for showing the Project Status Report. This is just a simple window that shows a list of subprojects and markets -- options that will determine the content of the report
Test Class: IMP_StatusReportGeneration_Test
History
09/30/14    Michael Lasala      Created
10/01/14    Michael Lasala      Added retrieveCDKContactsBySet and retrieveClientContactsBySet
10/06/14    Michael Lasala      Added buildMapValues
10/07/14    Michael Lasala      Added buildMapBoolean
10/08/14    Rey Austral         Change filename
10/11/14    Samuel Oberes       Added xlsHeader
10/16/14    Samuel Oberes       Added CleanseSubprojectName
10/29/14    Samuel Oberes       Removed selectedMarketSetting
Added subprojectMarkets
Removed getMarkets
12/02/14    Samuel Oberes       Removed subProjectWrapper class. Used IMP_Project_Utility.IMP_SalesforceObjectWrapper instead
04/07/15    Samuel Oberes       (Venkata added this text here by referring at the method that has been written to find the recent changes easily.
Apologies.)
04/14/15    Venkata Shrivol     Renamed CleanseSubprojectName to CleanseStringName so it can be used by other fields rather than
SubProject name like fileName
08/11/15    Samuel Oberes       Added activityTaskMap. To be used for including tasks in the project milestones tab.
08/28/15    Venkata Shrivol     Changed Utitlites method reference to ALL_UtilitiesData in removeCharacter method.
02/16/17    Vishal Bandari      Changed Controller of the class to handle urls with any number of subproject Ids.
------------------------------------------------------------*/
global with sharing class IMP_StatusReportGeneration_Controller{
    
    public final static String PROJECT_LOG_RECORDTYPE_ISSUE = 'Issue';
    public final static String PROJECT_LOG_RECORDTYPE_RISK = 'Risk';
    public final static String PROJECT_LOG_RECORDTYPE_CHANGE_REQUEST = 'Change Request';
    public final static String ADDITIONAL_FILTER_ISSUE = 'Client_Issue_Owner__c';
    public final static String ADDITIONAL_FILTER_RISK = 'Client_Assignee__c';
    public final static String ADDITIONAL_FILTER_CHANGE_REQUEST = 'Client_Approver__c';
    public final static String ADDITIONAL_FILTER_PSR = 'PSR__c';
    public final static String PARENT_FIELD_ISSUE = 'Sub_Project_Issue__c';
    public final static String PARENT_FIELD_RISK = 'Sub_Project_Risk__c';
    public final static String PARENT_FIELD_CHANGE_REQUEST = 'Sub_Project_Change_Request__c';
    
    //Generate Status popup variables
    public List<IMP_Project_Utility.IMP_SalesforceObjectWrapper> subProjectWrapperList {get;set;}
    public String selectedMarket {get;set;}
    
    //Generate Status Report variables
    public String fileName {get;set;}
    public List<SubProject__c> subProjectList {get;set;}
    public Map<Id, Map<Boolean, List<Project_Activity__c>>> milestoneActivityMap 
    {
        get 
        {
            if(milestoneActivityMap == null) 
            {
                milestoneActivityMap = new Map<Id, Map<Boolean, List<Project_Activity__c>>>();
            }
            return milestoneActivityMap;
        }
        set;
    }
    
    public Map<Id, Map<Boolean, List<Project_Task__c>>> activityTaskMap
    {
        get 
        {
            if(activityTaskMap == null) 
            {
                activityTaskMap = new Map<Id, Map<Boolean, List<Project_Task__c>>>();
            }
            return activityTaskMap;
        }
        set;
    }
    
    // milestone ID to IMP_Project_Utility.PSRMilestoneTabDetails map
    //public Map<Id, IMP_Project_Utility.PSRMilestoneTabDetails> psrMilestoneTabRecordsMap 
    //{
    //    get 
    //    {
    //        if(psrMilestoneTabRecordsMap == null) 
    //        {
    //            psrMilestoneTabRecordsMap = new Map<Id, IMP_Project_Utility.PSRMilestoneTabDetails>();
    //        }
    //        return psrMilestoneTabRecordsMap;
    //    }
    //    set;
    //}
    public Map<Id, Map<Boolean, List<Project_Milestone__c>>> subProjectMilestoneMap {get;set;}
    public Map<Id, Map<Boolean, List<SubProjectSite__c>>> subProjectSiteMap {get;set;}
    public Map<Id, Map<Boolean, List<Project_Log__c>>> subProjectIssueMap {get;set;}
    public Map<Id, Map<Boolean, List<Project_Log__c>>> subProjectRiskMap {get;set;}
    public Map<Id, Map<Boolean, List<Project_Log__c>>> subProjectChangeRequestMap {get;set;}
    public Map<Id, Map<Boolean, List<IMP_Project_Utility.CDKClientContactsWrapper>>> subProjectClientContactMap {get;set;}
    public Map<Id, Map<Boolean, List<IMP_Project_Utility.CDKClientContactsWrapper>>> subProjectCDKContactMap {get;set;}
    public String PrintView {get;set;}
    public Integer count { get; set; }
    
    public Map<Id, String> subprojectNames {
        get {
            if(subprojectNames == null) {
                subprojectNames = new Map<Id, String>();
            }
            return subprojectNames;
        }
        set;
    }
    public Map<Id, String> subprojectMarkets { 
        get {
            if(subprojectMarkets == null) {
                subprojectMarkets = new Map<Id, String>();
            }
            return subprojectMarkets;
        }
        set; 
    }
    public Map<Id, String> subProjectToProjectAdvocatesMap {
        get {
            if (subProjectToProjectAdvocatesMap == null) {
                subProjectToProjectAdvocatesMap = new Map<Id, String>();
            }
            return subProjectToProjectAdvocatesMap;
        } 
        set;
    }
    
    // Excel output header
    public String xlsHeader {
        get{
            String strHeader = '';
            strHeader += '<?xml version="1.0"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
    }
    
    /*------------------------------------------------------------
Author:  Samuel Oberes 
Company: Cloud Sherpas
Description: Replaces invalid characters for an Excel Worksheet name with an underscore.
Inputs: subProjectName
Returns: String
History
10/16/14    Samuel Oberes       Created
12/01/14    Samuel Oberes       Replaced previous manual implementation with a combination of regex and custom settings
04/14/15    Venkata Shrivol     Changed the functionName and passed as the required values in method as Parameters
to make it more genereic
------------------------------------------------------------*/
    private String CleanseStringName(String textString, String regExpression, String replacementString) {
        //String unwantedCharsRegex = regExpression;
        Pattern myPattern         = Pattern.compile(regExpression);
        Matcher myMatcher         = myPattern.matcher(textString);
        
        return myMatcher.replaceAll(replacementString);
    }
    
    public IMP_StatusReportGeneration_Controller(){
        
        //For Generate Status popup
        //Retrieve Project Id
        Id projectId = ApexPages.currentPage().getParameters().get('id');
        
        if(projectId != null && projectId != ''){
            
            subProjectWrapperList = new List<IMP_Project_Utility.IMP_SalesforceObjectWrapper>();
            
            //Retrieve All SubProjects based on Project Id
            //for(SubProject__c s: IMP_Project_Utility.retrieveSubProjectsBySet(IMP_Project_Utility.OBJECT_NAME_PROJECT, projectId, null)){
            list<Subproject__C> subprojectList = new list<Subproject__C>{IMP_Project_Utility.retrieveSubProject(projectId)};
                for(SubProject__c s:subprojectList){
                    //Add SubProjects to wrapper list
                    subProjectWrapperList.add(new IMP_Project_Utility.IMP_SalesforceObjectWrapper(s));
                }
            
            if(subProjectWrapperList.isEmpty()){
                
                //Return error indicating that there are no SubProject records for the given Project
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, 'No related SubProjects found')); 
            }
        }
        
        //For Generate Status Report
        //Retrieve SubProject Id/s selected from popup
        
        //02/16/17    Vishal Bandari      Changed Controller of the class to handle urls with any number of subproject Ids.
        String subProjectId = ApexPages.currentPage().getParameters().get('subProjectIds');
        
        if(subProjectId != null) { 
            //Split SubProject Id/s
            List<String> subProjectIdList = subProjectId.split('\\|');
            
            Set<Id> subProjectIdSet = new Set<Id>();
            
            for(String s: subProjectIdList){
                
                //Add each Id to set which will be used for querying SubProject records
                subProjectIdSet.add(s);
            }
            
            //Generate Status Report content
            generateContent(subProjectIdSet);
            subProjectWrapperList = new List<IMP_Project_Utility.IMP_SalesforceObjectWrapper>();
            
            //Retrieve All SubProjects based on Project Id
            //for(SubProject__c s: IMP_Project_Utility.retrieveSubProjectsBySet(IMP_Project_Utility.OBJECT_NAME_PROJECT, projectId, null)){
            list<Subproject__C> subprojectList = IMP_Project_Utility.retrieveSubProjects((List<Id>)subProjectId.split('\\|'));
            for(SubProject__c s:subprojectList){
                //Add SubProjects to wrapper list
                subProjectWrapperList.add(new IMP_Project_Utility.IMP_SalesforceObjectWrapper(s));
            }
            generateReport();
            count = 0;
        }
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Validate popup fields and redirect to IMP_StatusReportContent which will generate the content of the actual report
Inputs: None
Returns: PageReference
History
09/30/14    Michael Lasala      Created
------------------------------------------------------------*/
    public PageReference generateReport(){
        
        Set<Id> subProjectIds = new Set<Id>();
        
        if(!subProjectWrapperList.isEmpty()){
            
            for(IMP_Project_Utility.IMP_SalesforceObjectWrapper wrap: subProjectWrapperList){
                
                //Add Id/s of selected SubProject records
                if(wrap.isSelected){
                    subProjectIds.add((Id)wrap.thisSObject.get('Id'));
                }
            }
            
            
            if(subProjectIds.isEmpty()){
                
                //Validate if a SubProject record is selected
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, 'At least 1 SubProject should be selected')); 
                
            } else {
                
                String subProjectIdString = '';
                
                //Construct string which will contain all SubProject Id/s selected
                for(Id s: subProjectIds){
                    subProjectIdString += s+',';
                }
                
                //Remove last comma
                subProjectIdString = subProjectIdString.subString(0, subProjectIdString.length()-1);
                
                //Redirect to IMP_StatusReportContentExcel page which will initiate the download of the Excel file
                PageReference pageRef = Page.IMP_StatusReportContentExcel;
                
                //Put parameters to URL
                pageRef.getParameters().put('subProjectIds', subProjectIdString);
                pageRef.getParameters().put('market', selectedMarket);
                pageRef.setRedirect(true);
                //System.assertEquals(false,true,pageRef);
                return pageRef;
            }
        }
        
        
        return null;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Generate Status Report content
Inputs: SubProject Ids, Selected Market custom setting record
Returns: Void
History
09/30/14    Michael Lasala      Created
01/14/15    Samuel Oberes       Prefixed a running counter to the worksheet names to keep it unique
01/16/15    Samuel Oberes       Excluded Client_Contact__r.Name that are null
01/20/15    Samuel Oberes       Replaced 'IMP_Project_Utility.retrievePSRActivities(milestoneIds)' with 'IMP_Project_Utility.retrieveActivities(milestoneIds)' to utilize the sorting functionality of the former.
02/04/15    Samuel Oberes       Reverted 'IMP_Project_Utility.retrieveActivities(milestoneIds)' back to 'IMP_Project_Utility.retrievePSRActivities(milestoneIds)'. I tweaked the latter's implementation to sort better.
08/17/15    Samuel Oberes       Replaced Region__c with SubProject_Region__c
Added task as new level for psr milestones tab, as well as new sorting and new column (site name)
------------------------------------------------------------*/
    public void generateContent(Set<Id> subProjectIdsSet) { //, IMP_Market__c marketSetting
        
        //Retrieve SubProjects records
        //Used for displaying SubProject information and repeating of other maps' values
        subProjectList = IMP_Project_Utility.retrieveSubProjectsBySet(IMP_Project_Utility.QUERY_NAME_ID, null, subProjectIdsSet);
        System.debug('$$$ subProjectList: '+subProjectList);
        
        if(!subProjectList.isEmpty()){
            
            // We are populating 2 maps below:
            // 1) subprojectNames   - will contain sub project names, barring illegal characters, which will used for worksheet names
            // 2) subprojectMarkets - will contain sub project market depending on the region, which will be used for the PSR header
            
            Integer counter = 0;
            for (SubProject__c sp : subProjectList) {
                counter ++;
                
                // [1]
                IMP_RegularExpressions__c excelWorkSheetRegEx = IMP_RegularExpressions__c.getInstance('ExcelWorksheetNameValidCharacters');
                if(excelWorkSheetRegEx!=null){
                    subprojectNames.put(sp.Id, counter + '-' + CleanseStringName(sp.SubProject_Name__c, excelWorkSheetRegEx.Pattern__c, excelWorkSheetRegEx.ReplacementString__c));
                }
                // [2]
                IMP_Market__c impMarket = IMP_Market__c.getInstance(sp.SubProject_Region__c);
                String marketName;
                if(impMarket != null) {
                    if(impMarket.Market__c != null) {
                        marketName = impMarket.Market__c;
                    } else {
                        marketName = 'MARKET FOR THIS REGION IS NOT SUPPLIED';
                    }
                } else {
                    marketName = 'SUB-PROJECT\'S REGION IS NOT AVAILABLE';
                }
                subprojectMarkets.put(sp.Id, marketName);
            }
            String projectNo='';
            //Used for generating file name of MS Word document
            IMP_RegularExpressions__c excelFileRegEx = IMP_RegularExpressions__c.getInstance('ExcelSheetFileName');
            if(excelFileRegEx!=null){
                //2016-12-13 -venkata.shrivol@cdk.com -changed project name to subproject name
                projectNo = CleanseStringName(subProjectList.get(0).Subproject_Name__c, excelFileRegEx.Pattern__c, excelFileRegEx.ReplacementString__c);
            }
            
            
            fileName = projectNo+' - PSR - ' + Datetime.now().format('MMddyyyy');
            
            // PROJECT MILESTONES TAB START -------------------------------------------------
            
            //Retrieve related Project Milestones based on SubProject Id set
            List<Project_Milestone__c> milestoneList = IMP_Project_Utility.retrieveMilestonesBySet(subProjectIdsSet, IMP_Project_Utility.OBJECT_NAME_SUBPROJECT);
            System.debug('$$$ milestoneList: '+milestoneList.size());
            
            if(!milestoneList.isEmpty())
            {
                Set<Id> milestoneIds = new Set<Id>();
                
                for(Project_Milestone__c pm : milestoneList){
                    
                    //Add Project Milestone Ids to set to be used for querying Project Activity records
                    milestoneIds.add(pm.Id);
                }
                
                System.debug('DBG: milestoneIds >>> ' + milestoneIds);
                
                //Retrieve Project Activity records based on retrieved Project Milestone records
                List<Project_Activity__c> projectActivityList = IMP_Project_Utility.retrievePSRActivities(milestoneIds);
                System.debug('DBG: projectActivityList >>>  ' + projectActivityList);
                
                //Retrieve Project Task records based on retrieved Project Milestone records
                List<Project_Task__c> projectTasksMap = IMP_Project_Utility.retrievePSRTasks(milestoneIds);
                System.debug('DBG: projectTasksMap >>> ' + projectTasksMap);
                
                if(!projectActivityList.isEmpty() || !projectTasksMap.isEmpty())
                {
                    // ----------------------------------------------------
                    // ACTIVITY RELATED
                    
                    //Used for displaying child Project Activity records for each Project Milestone
                    
                    Set<Id> milestonePSRIdsSet = new Set<Id>();
                    Set<Id> activityPSRIdsSet = new Set<Id>();
                    Set<Id> taskPSRIdsSet = new Set<Id>();
                    
                    for(Project_Activity__c pa : projectActivityList){
                        milestonePSRIdsSet.add(pa.Milestone__c);
                        activityPSRIdsSet.add(pa.Id);
                    }
                    
                    // ----------------------------------------------------
                    // TASK RELATED
                    
                    // Used for displaying child Project Task records for each Project Activity
                    
                    for (Project_Task__c pt : projectTasksMap)
                    {
                        milestonePSRIdsSet.add(pt.Milestone_Id__c);
                        activityPSRIdsSet.add(pt.Project_Activity__c);
                        taskPSRIdsSet.add(pt.Id);
                    }
                    
                    // ----------------------------------------------------
                    
                    //Re-query Project Milestone records with Project Activities Display_on_PSR__c = true
                    List<Project_Milestone__c> milestonePSRList = IMP_Project_Utility.retrieveMilestonesBySet(milestonePSRIdsSet, 'Id');
                    System.debug('DBG milestonePSRList: ' + milestonePSRList.size());
                    
                    //Build map values to be used in map within a map
                    Map<Id, List<Project_Milestone__c>> subProjectIdToMilestonesListMap = buildMapValues(subProjectIdsSet, milestonePSRList, 'SubProject__c');
                    //Used for displaying child Project Milestone records for each SubProject
                    subProjectMilestoneMap = buildMapBoolean(subProjectIdToMilestonesListMap);
                    System.debug('DBG: subProjectMilestoneMap >>> ' + subProjectMilestoneMap);
                    
                    
                    
                    //Re-query Project Activity records with Project Tasks Display_on_PSR__c = true
                    List<Project_Activity__c> activitiesList = IMP_Project_Utility.retrieveActivities(activityPSRIdsSet);
                    System.debug('DBG: activitiesList >>> ' + activitiesList);
                    
                    //Build map values to be used in map within a map
                    Map<Id, List<Project_Activity__c>> milestoneIdToActivitiesListMap = buildMapValues(milestonePSRIdsSet, activitiesList, 'Milestone__c');
                    //Used for displaying child Project Activity records for each Milestone
                    milestoneActivityMap = buildMapBoolean(milestoneIdToActivitiesListMap);
                    System.debug('DBG: milestoneActivityMap >>> ' + milestoneActivityMap);
                    
                    
                    
                    //Re-query Project Task records with Project Tasks Display_on_PSR__c = true
                    List<Project_Task__c> tasksList = IMP_Project_Utility.retrieveTasks(taskPSRIdsSet);
                    System.debug('DBG: tasksList >>> ' + tasksList);
                    
                    //Build map values to be used in map within a map
                    Map<Id, List<Project_Task__c>> activityIdToTasksListMap = buildMapValues(activityPSRIdsSet, tasksList, 'Project_Activity__c');
                    //Used for displaying child Project Task records for each Activity
                    activityTaskMap = buildMapBoolean(activityIdToTasksListMap);
                    System.debug('DBG: activityTaskMap >>> ' + activityTaskMap);
                }
                
            }
            
            // PROJECT MILESTONES TAB END -------------------------------------------------
            
            
            
            //System.debug('DBG: subProjectIdsSet >>> ' + subProjectIdsSet);
            
            //            // used by SubProject_ID__c because this field is a string and cannot interpret 18 digit IDs
            //            Set<String> fifteenDigitIdsSet = new Set<String>();
            //            for (Id i : subProjectIdsSet)
            //            {
            //                fifteenDigitIdsSet.add(String.valueOf(i).subString(0, 15));
            //            }
            //System.debug('DBG: fifteenDigitIdsSet >>> ' + fifteenDigitIdsSet);
            
            //            List<Project_Milestone__c> projectMilestonesList = [SELECT Id, 
            //                                                                       Site__r.Account__r.Name,
            //                                                                       SubProject_Name__c,
            //                                                                       Description__c,
            //                                                                       Planned_Start_Date__c,
            //                                                                       Planned_End_Date__c,
            //                                                                       Actual_Start_Date__c,
            //                                                                       Actual_End_Date__c,
            //                                                                       Status__c,
            //                                                                       Comments__c,
            //                                                                       Display_on_PSR__c 
            //                                                                  FROM Project_Milestone__c 
            //                                                                 WHERE Display_On_PSR__c = true 
            //                                                                   AND SubProject__c IN :fifteenDigitIdsSet
            //                                                              ORDER BY Process_Step__c,
            //                                                                       Sort_Sequence__c,
            //                                                                       Name,
            //                                                                       Site__r.Account__r.Name];
            //System.debug('DBG: projectMilestonesList >>> ' + projectMilestonesList);
            
            //            //todo: consider site sorting
            //            List<Project_Activity__c> projectActivitiesList  = [SELECT Id, 
            //                                                                       Site__c,
            //                                                                       SubProject_Name__c,
            //                                                                       Description__c,
            //                                                                       Planned_Start_Date__c,
            //                                                                       Planned_End_Date__c,
            //                                                                       Actual_Start_Date__c,
            //                                                                       Actual_End_Date__c,
            //                                                                       Status__c,
            //                                                                       Comments__c,
            //                                                                       Display_on_PSR__c,
            //                                                                       CDK_Assignee__r.Name,
            //                                                                       CDK_Assignee_Role__c,
            //                                                                       Client_Assignee__r.Name,
            //                                                                       Milestone__c, 
            //                                                                       SubProject_ID__c,
            
            //                                                                       Milestone__r.Id, 
            //                                                                       Milestone__r.Site__r.Account__r.Name,
            //                                                                       Milestone__r.Description__c,
            //                                                                       Milestone__r.Planned_Start_Date__c,
            //                                                                       Milestone__r.Planned_End_Date__c,
            //                                                                       Milestone__r.Actual_Start_Date__c,
            //                                                                       Milestone__r.Actual_End_Date__c,
            //                                                                       Milestone__r.Status__c,
            //                                                                       Milestone__r.Comments__c,
            //                                                                       Milestone__r.Display_on_PSR__c
            
            //                                                                  FROM Project_Activity__c 
            //                                                                 WHERE Display_On_PSR__c = true 
            //                                                                   AND SubProject_ID__c IN :fifteenDigitIdsSet
            //                                                              ORDER BY Sequence__c,
            //                                                                       Name];
            //System.debug('DBG: projectActivitiesList >>> ' + projectActivitiesList);
            
            //            //todo: consider site sorting
            //            List<Project_Task__c> projectTasksList           = [SELECT Id, 
            //                                                                       Site__c,
            //                                                                       SubProject_Name__c,
            //                                                                       Description__c,
            //                                                                       Planned_Start_Date__c,
            //                                                                       Planned_End_Date__c,
            //                                                                       Actual_Start_Date__c,
            //                                                                       Actual_End_Date__c,
            //                                                                       Status__c,
            //                                                                       Comments__c,
            //                                                                       Display_on_PSR__c,
            //                                                                       CDK_Assignee__r.Name,
            //                                                                       CDK_Assignee_Role__c,
            //                                                                       Client_Assignee__r.Name,
            //                                                                       Project_Activity__c,
            //                                                                       SubProject_ID__c,
            
            //                                                                       Project_Activity__r.Id, 
            //                                                                       Project_Activity__r.Site__c,
            //                                                                       Project_Activity__r.Description__c,
            //                                                                       Project_Activity__r.Planned_Start_Date__c,
            //                                                                       Project_Activity__r.Planned_End_Date__c,
            //                                                                       Project_Activity__r.Actual_Start_Date__c,
            //                                                                       Project_Activity__r.Actual_End_Date__c,
            //                                                                       Project_Activity__r.Status__c,
            //                                                                       Project_Activity__r.Comments__c,
            //                                                                       Project_Activity__r.Display_on_PSR__c,
            //                                                                       Project_Activity__r.CDK_Assignee__r.Name,
            //                                                                       Project_Activity__r.CDK_Assignee_Role__c,
            //                                                                       Project_Activity__r.Client_Assignee__r.Name,
            //                                                                       Project_Activity__r.Milestone__c, 
            //                                                                       Project_Activity__r.SubProject_ID__c,
            
            //                                                                       Project_Activity__r.Milestone__r.Id, 
            //                                                                       Project_Activity__r.Milestone__r.Site__r.Account__r.Name,
            //                                                                       Project_Activity__r.Milestone__r.Description__c,
            //                                                                       Project_Activity__r.Milestone__r.Planned_Start_Date__c,
            //                                                                       Project_Activity__r.Milestone__r.Planned_End_Date__c,
            //                                                                       Project_Activity__r.Milestone__r.Actual_Start_Date__c,
            //                                                                       Project_Activity__r.Milestone__r.Actual_End_Date__c,
            //                                                                       Project_Activity__r.Milestone__r.Status__c,
            //                                                                       Project_Activity__r.Milestone__r.Comments__c,
            //                                                                       Project_Activity__r.Milestone__r.Display_on_PSR__c
            //                                                                  FROM Project_Task__c 
            //                                                                 WHERE Display_On_PSR__c = true 
            //                                                                   AND SubProject_ID__c IN :fifteenDigitIdsSet
            //                                                              ORDER BY Sequence__c,
            //                                                                       Name];
            //System.debug('DBG: projectTasksList >>> ' + projectTasksList);
            
            //            try
            //            {
            //                Set<Id> createdMilestoneIdsSet = new Set<Id>();
            //                Set<Id> createdActivityIdsSet = new Set<Id>();
            
            //                //loop around tasks
            //                for (Project_Task__c task : projectTasksList)
            //                {
            //                    /*
            //                        TASK:
            
            //                        build task gwrap
            //                        if task's milestoneId EXISTS in createdMilestoneIdsSet
            //                            if task's activity id exist in createdActivityIdsSet
            //                                use task's milestoneId to call milestone in psrMilestoneTabRecordsMap
            //                                use task's activityId to call activity under called milestone in psrMilestoneTabRecordsMap
            //                                add self to called activity's children
            //                            else
            //                                build activity gwrap
            //                                add activityId to createdActivityIdsSet
            //                                add self to created activity gwrap's children map
            //                                add activity gwrap to milestone gwrap's children map
            //                        else
            //                            build activity gwrap
            //                            add activityId to createdActivityIdsSet
            //                            add self to created activity gwrap's children map
            //                            build milestone gwrap
            //                            add milestoneId to createdMilestoneIdsSet
            //                            add activity gwrap to milestone gwrap's children map
            //                            add milestone gwrap to psrMilestoneTabRecordsMap
            //                    */
            //                    IMP_Project_Utility.PSRMilestoneTabDetails taskWrapper = buildmilestoneActivityTaskWrapper(task.Id, 
            //                                                                                                               task.SubProject_Name__c, 
            //                                                                                                               task.Site__c, 
            //                                                                                                               task.Description__c, 
            //                                                                                                               task.Planned_Start_Date__c, 
            //                                                                                                               task.Planned_End_Date__c, 
            //                                                                                                               task.Actual_Start_Date__c, 
            //                                                                                                               task.Actual_End_Date__c, 
            //                                                                                                               task.Status__c, 
            //                                                                                                               task.Comments__c, 
            //                                                                                                               task.CDK_Assignee__r.Name, 
            //                                                                                                               task.CDK_Assignee_Role__c, 
            //                                                                                                               task.Client_Assignee__r.Name, 
            //                                                                                                               null);
            //                    if (createdMilestoneIdsSet.contains(task.Project_Activity__r.Milestone__r.Id))
            //                    {
            //                        if (createdActivityIdsSet.contains(task.Project_Activity__r.Id))
            //                        {
            //                            IMP_Project_Utility.PSRMilestoneTabDetails tmpMilestoneWrapper = psrMilestoneTabRecordsMap.get(task.Project_Activity__r.Milestone__r.Id);
            //                            IMP_Project_Utility.PSRMilestoneTabDetails tmpActivityWrapper  = tmpMilestoneWrapper.childrenMap.get(task.Project_Activity__r.Id);
            //                            tmpActivityWrapper.childrenMap.put(task.Id, taskWrapper);
            //                        }
            //                        else
            //                        {
            //                            IMP_Project_Utility.PSRMilestoneTabDetails tmpActivityWrapper = buildmilestoneActivityTaskWrapper(task.Project_Activity__r.Id, 
            //                                                                                                                              task.SubProject_Name__c, 
            //                                                                                                                              task.Project_Activity__r.Site__c, 
            //                                                                                                                              task.Project_Activity__r.Description__c, 
            //                                                                                                                              task.Project_Activity__r.Planned_Start_Date__c, 
            //                                                                                                                              task.Project_Activity__r.Planned_End_Date__c, 
            //                                                                                                                              task.Project_Activity__r.Actual_Start_Date__c, 
            //                                                                                                                              task.Project_Activity__r.Actual_End_Date__c, 
            //                                                                                                                              task.Project_Activity__r.Status__c, 
            //                                                                                                                              task.Project_Activity__r.Comments__c, 
            //                                                                                                                              task.Project_Activity__r.CDK_Assignee__r.Name, 
            //                                                                                                                              task.Project_Activity__r.CDK_Assignee_Role__c, 
            //                                                                                                                              task.Project_Activity__r.Client_Assignee__r.Name, 
            //                                                                                                                              null);
            //                            createdActivityIdsSet.add(task.Project_Activity__r.Id);
            //                            tmpActivityWrapper.childrenMap.put(task.Id, taskWrapper);
            
            //                            IMP_Project_Utility.PSRMilestoneTabDetails tmpMilestoneWrapper = psrMilestoneTabRecordsMap.get(task.Project_Activity__r.Milestone__r.Id);
            //                            tmpMilestoneWrapper.childrenMap.put(task.Project_Activity__r.Id, tmpActivityWrapper);
            //                        }
            //                    }
            //                    else
            //                    {
            //                        IMP_Project_Utility.PSRMilestoneTabDetails tmpActivityWrapper = buildmilestoneActivityTaskWrapper(task.Project_Activity__r.Id, 
            //                                                                                                                          task.SubProject_Name__c, 
            //                                                                                                                          task.Project_Activity__r.Site__c, 
            //                                                                                                                          task.Project_Activity__r.Description__c, 
            //                                                                                                                          task.Project_Activity__r.Planned_Start_Date__c, 
            //                                                                                                                          task.Project_Activity__r.Planned_End_Date__c, 
            //                                                                                                                          task.Project_Activity__r.Actual_Start_Date__c, 
            //                                                                                                                          task.Project_Activity__r.Actual_End_Date__c, 
            //                                                                                                                          task.Project_Activity__r.Status__c, 
            //                                                                                                                          task.Project_Activity__r.Comments__c, 
            //                                                                                                                          task.Project_Activity__r.CDK_Assignee__r.Name, 
            //                                                                                                                          task.Project_Activity__r.CDK_Assignee_Role__c, 
            //                                                                                                                          task.Project_Activity__r.Client_Assignee__r.Name, 
            //                                                                                                                          null);
            //                        createdActivityIdsSet.add(task.Project_Activity__r.Id);
            //                        tmpActivityWrapper.childrenMap.put(task.Id, taskWrapper);
            
            //                        IMP_Project_Utility.PSRMilestoneTabDetails tmpMilestoneWrapper = buildmilestoneActivityTaskWrapper(task.Project_Activity__r.Milestone__r.Id, 
            //                                                                                                                           task.SubProject_Name__c, 
            //                                                                                                                           task.Project_Activity__r.Milestone__r.Site__r.Account__r.Name, 
            //                                                                                                                           task.Project_Activity__r.Milestone__r.Description__c, 
            //                                                                                                                           task.Project_Activity__r.Milestone__r.Planned_Start_Date__c, 
            //                                                                                                                           task.Project_Activity__r.Milestone__r.Planned_End_Date__c, 
            //                                                                                                                           task.Project_Activity__r.Milestone__r.Actual_Start_Date__c, 
            //                                                                                                                           task.Project_Activity__r.Milestone__r.Actual_End_Date__c, 
            //                                                                                                                           task.Project_Activity__r.Milestone__r.Status__c, 
            //                                                                                                                           task.Project_Activity__r.Milestone__r.Comments__c, 
            //                                                                                                                           '', 
            //                                                                                                                           '', 
            //                                                                                                                           '', 
            //                                                                                                                           null);
            //                        createdMilestoneIdsSet.add(task.Project_Activity__r.Milestone__r.Id);
            //                        tmpMilestoneWrapper.childrenMap.put(task.Project_Activity__r.Id, tmpActivityWrapper);
            //                        psrMilestoneTabRecordsMap.put(task.Project_Activity__r.Milestone__r.Id, tmpMilestoneWrapper);
            //                    }
            //                }
            
            
            //                //loop around activities
            //                for (Project_Activity__c activity : projectActivitiesList)
            //                {
            //                    /*
            //                        ACTIVITY:
            
            //                        if activity's milestoneId EXISTS in createdMilestoneIdsSet
            //                            if self's id DOESN'T EXIST in createdActivityIdsSet
            //                                build activity gwrap
            //                                add activityId to createdActivityIdsSet
            //                                add self to milestone gwrap's children map
            //                            else
            //                                do nothing
            //                        else
            //                            build activity gwrap
            //                            add activityId to createdActivityIdsSet
            //                            build milestone gwrap
            //                            add milestoneId to createdMilestoneIdsSet
            //                            add self to milestone gwrap's children map
            //                            add milestone gwrap to psrMilestoneTabRecordsMap
            //                    */
            //                    if (createdMilestoneIdsSet.contains(activity.Milestone__r.Id))
            //                    {
            //                        if (!createdActivityIdsSet.contains(activity.Id))
            //                        {
            //                            IMP_Project_Utility.PSRMilestoneTabDetails tmpActivityWrapper = buildmilestoneActivityTaskWrapper(activity.Id, 
            //                                                                                                                              activity.SubProject_Name__c, 
            //                                                                                                                              activity.Site__c, 
            //                                                                                                                              activity.Description__c, 
            //                                                                                                                              activity.Planned_Start_Date__c, 
            //                                                                                                                              activity.Planned_End_Date__c, 
            //                                                                                                                              activity.Actual_Start_Date__c, 
            //                                                                                                                              activity.Actual_End_Date__c, 
            //                                                                                                                              activity.Status__c, 
            //                                                                                                                              activity.Comments__c, 
            //                                                                                                                              activity.CDK_Assignee__r.Name, 
            //                                                                                                                              activity.CDK_Assignee_Role__c, 
            //                                                                                                                              activity.Client_Assignee__r.Name, 
            //                                                                                                                              null);
            //                            createdActivityIdsSet.add(activity.Id);
            
            //                            IMP_Project_Utility.PSRMilestoneTabDetails tmpMilestoneWrapper = psrMilestoneTabRecordsMap.get(activity.Milestone__r.Id);
            //                            tmpMilestoneWrapper.childrenMap.put(activity.Id, tmpActivityWrapper);
            //                        }
            //                    }
            //                    else
            //                    {
            //                        IMP_Project_Utility.PSRMilestoneTabDetails tmpActivityWrapper = buildmilestoneActivityTaskWrapper(activity.Id, 
            //                                                                                                                          activity.SubProject_Name__c, 
            //                                                                                                                          activity.Site__c, 
            //                                                                                                                          activity.Description__c, 
            //                                                                                                                          activity.Planned_Start_Date__c, 
            //                                                                                                                          activity.Planned_End_Date__c, 
            //                                                                                                                          activity.Actual_Start_Date__c, 
            //                                                                                                                          activity.Actual_End_Date__c, 
            //                                                                                                                          activity.Status__c, 
            //                                                                                                                          activity.Comments__c, 
            //                                                                                                                          activity.CDK_Assignee__r.Name, 
            //                                                                                                                          activity.CDK_Assignee_Role__c, 
            //                                                                                                                          activity.Client_Assignee__r.Name, 
            //                                                                                                                          null);
            //                        createdActivityIdsSet.add(activity.Id);
            
            //                        IMP_Project_Utility.PSRMilestoneTabDetails tmpMilestoneWrapper = buildmilestoneActivityTaskWrapper(activity.Milestone__r.Id, 
            //                                                                                                                           activity.SubProject_Name__c, 
            //                                                                                                                           activity.Milestone__r.Site__r.Account__r.Name, 
            //                                                                                                                           activity.Milestone__r.Description__c, 
            //                                                                                                                           activity.Milestone__r.Planned_Start_Date__c, 
            //                                                                                                                           activity.Milestone__r.Planned_End_Date__c, 
            //                                                                                                                           activity.Milestone__r.Actual_Start_Date__c, 
            //                                                                                                                           activity.Milestone__r.Actual_End_Date__c, 
            //                                                                                                                           activity.Milestone__r.Status__c, 
            //                                                                                                                           activity.Milestone__r.Comments__c, 
            //                                                                                                                           '', 
            //                                                                                                                           '', 
            //                                                                                                                           '', 
            //                                                                                                                           null);
            //                        createdMilestoneIdsSet.add(activity.Milestone__r.Id);
            //                        tmpMilestoneWrapper.childrenMap.put(activity.Id, tmpActivityWrapper);
            //                        psrMilestoneTabRecordsMap.put(activity.Milestone__r.Id, tmpMilestoneWrapper);
            //                    }
            //                }
            
            //                //loop around milestones
            //                for (Project_Milestone__c milestone : projectMilestonesList)
            //                {
            //                    /*
            //                        MILESTONE:
            
            //                        if self's id DOESN'T EXIST in createdMilestoneIdsSet
            //                            build milestone gwrap
            //                            add milestoneId to createdMilestoneIdsSet
            //                            add self to psrMilestoneTabRecordsMap
            //                        else
            //                            do nothing
            //                    */
            //                    if (!createdMilestoneIdsSet.contains(milestone.Id))
            //                    {
            //                        IMP_Project_Utility.PSRMilestoneTabDetails tmpMilestoneWrapper = buildmilestoneActivityTaskWrapper(milestone.Id, 
            //                                                                                                                           milestone.SubProject_Name__c, 
            //                                                                                                                           milestone.Site__r.Account__r.Name, 
            //                                                                                                                           milestone.Description__c, 
            //                                                                                                                           milestone.Planned_Start_Date__c, 
            //                                                                                                                           milestone.Planned_End_Date__c, 
            //                                                                                                                           milestone.Actual_Start_Date__c, 
            //                                                                                                                           milestone.Actual_End_Date__c, 
            //                                                                                                                           milestone.Status__c, 
            //                                                                                                                           milestone.Comments__c, 
            //                                                                                                                           '', 
            //                                                                                                                           '', 
            //                                                                                                                           '', 
            //                                                                                                                           null);
            //                        createdMilestoneIdsSet.add(milestone.Id);
            //                        psrMilestoneTabRecordsMap.put(milestone.Id, tmpMilestoneWrapper);
            //                    }
            //                }
            
            //            }
            //            catch (Exception e)
            //            {
            //System.debug('DBG: e >>> ' + e);
            //            }
            
            
            
            
            
            
            // Retrieve SubProject Site records based on SubProject Id set
            List<SubProjectSite__c> siteList = retrieveSubProjectSitesAcrossSubprojects(subProjectIdsSet);
            System.debug('$$$ siteList: ' + siteList.size());
            
            // Build map values to be used in map within a map
            Map<Id, List<SubProjectSite__c>> siteMap = buildMapValues(subProjectIdsSet, siteList, IMP_Project_Utility.OBJECT_NAME_SUBPROJECT);
            //Used for displaying Issue Project Log records for each SubProject
            subProjectSiteMap = buildMapBoolean(siteMap);
            
            
            
            //Retrieve Project_Log__c Record Types
            Schema.DescribeSObjectResult resSchema = Project_Log__c.sObjectType.getDescribe();
            Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
            
            //Retrieve Record Type Ids of Record Types which will be used for the report
            Id recordTypeIdIssue = recordTypeInfo.get(PROJECT_LOG_RECORDTYPE_ISSUE).getRecordTypeId();
            Id recordTypeIdRisk = recordTypeInfo.get(PROJECT_LOG_RECORDTYPE_RISK).getRecordTypeId();
            Id recordTypeIdChangeRequest = recordTypeInfo.get(PROJECT_LOG_RECORDTYPE_CHANGE_REQUEST).getRecordTypeId();
            
            //Retrieve Issue Project Log records based on SubProject Id set
            List<Project_Log__c> issueList = retrieveProjectLogList(SObjectType.Project_Log__c.FieldSets.Issue_Commons.getFields(), PARENT_FIELD_ISSUE, subProjectIdsSet, recordTypeIdIssue, ADDITIONAL_FILTER_PSR);
            System.debug('DBG: issueList >>> ' + issueList);
            
            issueList = removeCharacter(SObjectType.Project_Log__c.FieldSets.Issue_Commons.getFields(), issueList);
            
            //Build map values to be used in map within a map
            Map<Id, List<Project_Log__c>> issueMap = buildMapValues(subProjectIdsSet, issueList, PARENT_FIELD_ISSUE);
            //Used for displaying Issue Project Log records for each SubProject
            subProjectIssueMap = buildMapBoolean(issueMap);
            System.debug('DBG: subProjectIssueMap >>> ' + subProjectIssueMap);
            
            //Retrieve Risk Project Log records based on SubProject Id set
            List<Project_Log__c> riskList = retrieveProjectLogList(SObjectType.Project_Log__c.FieldSets.Risk_Commons.getFields(), PARENT_FIELD_RISK, subProjectIdsSet, recordTypeIdRisk, ADDITIONAL_FILTER_PSR);
            System.debug('DBG: riskList >>> ' + riskList);
            
            riskList = removeCharacter(SObjectType.Project_Log__c.FieldSets.Risk_Commons.getFields(), riskList);
            
            Map<Id, List<Project_Log__c>> riskMap = buildMapValues(subProjectIdsSet, riskList, PARENT_FIELD_RISK);
            //Used for displaying Issue Project Log records for each SubProject
            subProjectRiskMap = buildMapBoolean(riskMap);
            System.debug('DBG: subProjectRiskMap >>> ' + subProjectRiskMap);
            
            //Retrieve Change Request Project Log records based on SubProject Id set
            List<Project_Log__c> changeRequestList = retrieveProjectLogList(SObjectType.Project_Log__c.FieldSets.Change_Request_Commons.getFields(), PARENT_FIELD_CHANGE_REQUEST, subProjectIdsSet, recordTypeIdChangeRequest, ADDITIONAL_FILTER_PSR);
            System.debug('DBG: changeRequestList >>> ' + changeRequestList);
            
            changeRequestList = removeCharacter(SObjectType.Project_Log__c.FieldSets.Change_Request_Commons.getFields(), changeRequestList);
            
            //Build map values to be used in map within a map
            Map<Id, List<Project_Log__c>> changeRequestMap = buildMapValues(subProjectIdsSet, changeRequestList, PARENT_FIELD_CHANGE_REQUEST);
            //Used for displaying Issue Project Log records for each SubProject
            subProjectChangeRequestMap = buildMapBoolean(changeRequestMap);
            System.debug('DBG: subProjectChangeRequestMap >>> ' + subProjectChangeRequestMap);
            
            // ---------------------------------------------------
            // BELOW CODE ALREADY OBSOLETE, LEFT FOR REFERENCE
            
            ////Retrieve SubProject CDK Contact records based on SubProject Id set
            //List<SubProject_CDK_Contact__c> cdkContactList = IMP_Project_Utility.retrieveCDKContactsBySet(subProjectIdsSet);
            //System.debug('$$$ cdkContactList: '+cdkContactList.size());
            
            ////Build map values to be used in map within a map
            //Map<Id, List<SubProject_CDK_Contact__c>> cdkContactMap = buildMapValues(subProjectIdsSet, cdkContactList, IMP_Project_Utility.OBJECT_NAME_SUBPROJECT);
            ////Used for displaying SubProject CDK Contact records for each SubProject
            //subProjectCDKContactMap = buildMapBoolean(cdkContactMap);
            // ---------------------------------------------------
            
            Map<Id, List<IMP_Project_Utility.CDKClientContactsWrapper>> cdkContactMap = IMP_Project_Utility.combineCDKContactsOrClientsBySubProject(subProjectIdsSet, true);
            subProjectCDKContactMap = buildMapBoolean(cdkContactMap);
            
            // ---------------------------------------------------
            // BELOW CODE ALREADY OBSOLETE, LEFT FOR REFERENCE
            
            ////Retrieve SubProject Client Contact records based on SubProject Id set
            //List<SubProject_Client_Contact__c> clientContactList = IMP_Project_Utility.retrieveClientContactsBySet(subProjectIdsSet);
            //System.debug('$$$ clientContactList: '+clientContactList);
            
            ////Build map values to be used in map within a map
            //Map<Id, List<SubProject_Client_Contact__c>> clientContactMap = buildMapValues(subProjectIdsSet, clientContactList, IMP_Project_Utility.OBJECT_NAME_SUBPROJECT);
            ////Used for displaying SubProject Client Contact records for each SubProject
            //subProjectClientContactMap = buildMapBoolean(clientContactMap);
            // ---------------------------------------------------
            
            Map<Id, List<IMP_Project_Utility.CDKClientContactsWrapper>> clientContactMap = IMP_Project_Utility.combineCDKContactsOrClientsBySubProject(subProjectIdsSet, false);
            subProjectClientContactMap = buildMapBoolean(clientContactMap);
            
            List<IMP_Project_Utility.CDKClientContactsWrapper> clientContactList;
            for (Id subProjectId : subProjectClientContactMap.keySet()) {
                for (Boolean isVisibleInReport : subProjectClientContactMap.get(subProjectId).keySet()) {
                    if (isVisibleInReport) {
                        
                        clientContactList = (List<IMP_Project_Utility.CDKClientContactsWrapper>)subProjectClientContactMap.get(subProjectId).get(isVisibleInReport);
                        
                        Set<String> tempSet = new Set<String>();
                        for (IMP_Project_Utility.CDKClientContactsWrapper contact : clientContactList) {
                            if (contact.projectRole == 'Project Advocate') {
                                if (contact.clientName != null) {
                                    tempSet.add(contact.clientName);
                                }
                            }
                        }
                        subProjectToProjectAdvocatesMap.put(subProjectId, String.join(new List<String>( tempSet ), ','));
                    } else {
                        subProjectToProjectAdvocatesMap.put(subProjectId, '');
                    }
                }
            }
        }
    }
    
    //private IMP_Project_Utility.PSRMilestoneTabDetails buildmilestoneActivityTaskWrapper(String id, 
    //                                                                                     String subProjectName, 
    //                                                                                     String siteName, 
    //                                                                                     String description, 
    //                                                                                     Date plannedStartDate,
    //                                                                                     Date plannedEndDate,
    //                                                                                     Date actualStartDate,
    //                                                                                     Date actualEndDate,
    //                                                                                     String status,
    //                                                                                     String comments,
    //                                                                                     String cdkAssigneeName,
    //                                                                                     String cdkAssigneeRole,
    //                                                                                     String clientAssigneeName,
    //                                                                                     Map<Id, IMP_Project_Utility.PSRMilestoneTabDetails> childrenMap)
    //{
    //    IMP_Project_Utility.PSRMilestoneTabDetails psrMilestoneTabFields = new IMP_Project_Utility.PSRMilestoneTabDetails();
    //    psrMilestoneTabFields.id                 = id;
    //    psrMilestoneTabFields.subProjectName     = subProjectName;
    //    psrMilestoneTabFields.siteName           = siteName;
    //    //psrMilestoneTabFields.recordType         = type;
    //    psrMilestoneTabFields.recordDescription  = description;
    //    psrMilestoneTabFields.plannedStartDate   = plannedStartDate;
    //    psrMilestoneTabFields.plannedEndDate     = plannedEndDate;
    //    psrMilestoneTabFields.actualStartDate    = actualStartDate;
    //    psrMilestoneTabFields.actualEndDate      = actualEndDate;
    //    psrMilestoneTabFields.status             = status;
    //    psrMilestoneTabFields.comments           = comments;
    //    psrMilestoneTabFields.cdkAssigneeName    = cdkAssigneeName;
    //    psrMilestoneTabFields.cdkAssigneeRole    = cdkAssigneeRole;
    //    psrMilestoneTabFields.clientAssigneeName = clientAssigneeName;
    //    psrMilestoneTabFields.childrenMap        = childrenMap;
    
    //    return psrMilestoneTabFields;
    //}
    
    /*------------------------------------------------------------
Author: Venkata Shrivol
Company: CDK Global
Description: Filters the "<" symbol in the data of Project_log__c records
Inputs: Project Log field set, project_log list 
Returns: list<Project_Log__c>
History
04/10/14    Venkata Shrivol      Created
------------------------------------------------------------*/
    
    public static list<Project_Log__c> removeCharacter(List<Schema.FieldSetMember> fieldSetList, list<Project_Log__c> projectLogList){
        
        string field = '';
        string temp = '';
        for(Project_Log__c prj: projectLogList)
        {
            for(Schema.FieldSetMember fSet : fieldSetList)
            { //SObjectType.Project_Log__c.FieldSets.Risk_Commons.getFields())
                field= fSet.getFieldPath();
                //fieldType = fSet.getType();
                try
                {
                    
                    //system.debug('--------Field-----------'+field);
                    //system.debug('----FieldType-----'+fSet.getType());
                    if(fSet.getType() == Schema.DisplayType.REFERENCE || field.contains('.')){
                        temp = String.valueOf(ALL_UtilitiesData.GetDataFromNestedFields(field, prj));
                    }else{ 
                        if(fSet.getType() == Schema.DisplayType.DATETIME){
                            Datetime dt = (Datetime)prj.get(field);
                            temp = dt.format();
                        }else if(fSet.getType() == Schema.DisplayType.DATE){
                            Date dt = (Date) prj.get(field);
                            temp = dt.format();
                        }else{
                            temp = String.valueOf(prj.get(field));
                        }                                   
                    }
                    
                    if((temp!=null && temp!= '') && temp.contains('<'))
                    {
                        system.debug('----Original------'+temp);
                        pattern p = pattern.compile('<');
                        matcher mymatch = p.matcher(temp);
                        if(field.contains('.')){
                            system.debug('-------Converted----------'+ALL_UtilitiesData.PutDataInNestedFields(field,prj,mymatch.replaceAll('<'+' ')));
                        }
                        else{
                            system.debug('-------Converted----------'+prj.put(field, mymatch.replaceAll('<'+' ')));
                        }
                        
                        /*fvalue = temp.replace('<','< ');
temp = fvalue; 
system.debug('-------Converted----------'+temp);*/
                    }           
                    //system.debug('-----FieldValues----'+prj.get(field));
                    //Pass the value to a function which finds the matching "<" and replaces with "< "
                }
                catch(exception ex){
                    system.debug('--Exception----'+ex);
                }
            }
        }
        return projectLogList;
    }
    
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Bulds a map where the key is the SubprojectID and the value is a list of the contents for a certain section of the report (e.g. Milestones, Issues, Risks, etc.)
Inputs: SubProject Ids, sObject list, sObject key field value for map
Returns: Map<Id, List<sObject>>
History
10/06/14      Michael Lasala      Created
------------------------------------------------------------*/
    public Map<Id, List<sObject>> buildMapValues(Set<Id> subProjectIds, List<sObject> objectList, String keyField){
        Map<Id, List<sObject>> objectMap = new Map<Id, List<sObject>>();
        
        //Iterate through SubProject Ids and add a new list to avoid key not found in map
        for(Id i: subProjectIds){
            List<sObject> tempList = new List<sObject>();
            objectMap.put(i, tempList);
        }
        
        if(!objectList.isEmpty()){
            for(sObject o: objectList){
                
                //Add sObject record to map using the key field paramter (differs on each object)
                if(objectMap.containsKey((Id) o.get(keyField))){
                    objectMap.get((Id) o.get(keyField)).add(o);
                }
            }
        }
        return objectMap;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Build map with values of a boolean for rendering display of records and the actual list of records
Inputs: Map<Id, List<sObject>>
Returns: Map<Id, Map<Boolean, List<sObject>>>
History
10/07/14      Michael Lasala      Created
------------------------------------------------------------*/
    public Map<Id, Map<Boolean, List<sObject>>> buildMapBoolean(Map<Id, List<sObject>> objectMap){
        Map<Id, Map<Boolean, List<sObject>>> objectBooleanMap = new Map<Id, Map<Boolean, List<sObject>>>();
        
        //Iterate through SubProject Ids
        for(Id i: objectMap.keySet()){
            Map<Boolean, List<sObject>> tempMap = new Map<Boolean, List<sObject>>();
            
            //Check if map paramater has values
            if(objectMap.get(i).size()>0){
                System.debug('DBG: buildMapBoolean: objectMap.get(i) >>> ' + objectMap.get(i));
                //Set boolean to true for display on document
                tempMap.put(true, objectMap.get(i));
            } else {
                System.debug('DBG: buildMapBoolean: NULL >>> ');
                //Set boolean to false to not display on document
                tempMap.put(false, null);
            }
            
            //Put SubProject Id with related boolean, list map
            objectBooleanMap.put(i, tempMap);
        }
        return objectBooleanMap;
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: An overload of buildMapBoolean. Accepts a different parameter.
Inputs:      Map<Id, List<IMP_Project_Utility.CDKClientContactsWrapper>>
Returns:     Map<Id, Map<Boolean, List<IMP_Project_Utility.CDKClientContactsWrapper>>>
History
04/07/15     Samuel Oberes       Created
------------------------------------------------------------*/
    public Map<Id, Map<Boolean, List<IMP_Project_Utility.CDKClientContactsWrapper>>> buildMapBoolean(Map<Id, List<IMP_Project_Utility.CDKClientContactsWrapper>> objectMap){
        Map<Id, Map<Boolean, List<IMP_Project_Utility.CDKClientContactsWrapper>>> objectBooleanMap = new Map<Id, Map<Boolean, List<IMP_Project_Utility.CDKClientContactsWrapper>>>();
        
        //Iterate through SubProject Ids
        for(Id i : objectMap.keySet()){
            Map<Boolean, List<IMP_Project_Utility.CDKClientContactsWrapper>> tempMap = new Map<Boolean, List<IMP_Project_Utility.CDKClientContactsWrapper>>();
            
            //Check if map paramater has values
            if(objectMap.get(i).size()>0){
                
                //Set boolean to true for display on document
                tempMap.put(true, objectMap.get(i));
            } else {
                
                //Set boolean to false to not display on document
                tempMap.put(false, null);
            }
            
            //Put SubProject Id with related boolean, list map
            objectBooleanMap.put(i, tempMap);
        }
        return objectBooleanMap;
    }
    
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Retrieve Project Log children of loaded Sub Project record
Inputs: Project Log field set, Parent Id, SubProject Ids, Record Type Id, Query filter
Returns: List<Project_Activity__c>
History
09/30/14    Michael Lasala      Created
08/17/15    Samuel Oberes       Added sorting option
------------------------------------------------------------*/
    public static List<Project_Log__c> retrieveProjectLogList(List<Schema.FieldSetMember> fieldSet, String parentField, Set<Id> subProjectId, Id recordTypeId, String additionalFilter) {
        List<Project_Log__c> projectLogs = new List<Project_Log__c>();
        
        Map<String, String> sortMap = new Map<String, String> { 'Site__r.Name' => 'ASC' };
            
            for(sObject o: IMP_Project_Utility.queryRelatedRecordsWithRecordType(fieldSet, parentField, subProjectId, recordTypeId, additionalFilter, sortMap)) {
                projectLogs.add((Project_Log__c)o);
            }
        return projectLogs;
    }
    
    /*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Retrieve the subProject sites across subprojects
Inputs:  
Returns:     List<SubProjectSite__c>
History
01/06/15     Samuel Oberes       Created
------------------------------------------------------------*/
    public static List<SubProjectSite__c> retrieveSubProjectSitesAcrossSubprojects(Set<Id> subProjectIdsSet){
        
        // Sort order of records
        List<String> orderFields = new List<String> { 'Name' };
            
            List<SubProjectSite__c> subProjectSiteList = new List<SubProjectSite__c>();
        
        // queryRelatedRecords(List<Schema.FieldSetMember>,                                                String objectName,                               String parentObjectFieldName,               String parentRecordId, Set<Id> parentRecordIdSet, List<String> stringList, List<String> orderFieldList, Boolean isAsc, Integer recordLimit){
        for(sObject o: IMP_Project_Utility.queryRelatedRecords(SObjectType.SubProjectSite__c.FieldSets.SubProject_Site_Common.getFields(), IMP_Project_Utility.OBJECT_NAME_SUBPROJECT_SITE, IMP_Project_Utility.OBJECT_NAME_SUBPROJECT, null,                  subProjectIdsSet,          null,                    orderFields,                 true,          0)){
            subProjectSiteList.add((SubProjectSite__c)o);
        }
        
        return subProjectSiteList;
    }
}