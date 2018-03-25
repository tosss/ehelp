/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Controller for IMP_MilestoneEdit Page
Test Class: IMP_MilestoneEdit_Controller_Test
History
04/10/15     Rey Austral      Created
------------------------------------------------------------*/
public class IMP_MilestoneEdit_Controller 
{    
    public Id objectId { get; set; }  
    public Map<String,String> externalIdMap { get; set; }
    public String milestoneId { get; set; }
    public String activityId { get; set; }
    public String activityExternalId { get; set; }
    public String activityIndex { get; set; }
    public String taskIndex { get; set; }
    public Boolean hasPermission { get; set; }
    public Boolean hasAddPermission { get; set; }
    public Boolean hasTaskAddPermission { get; set; }
    public Boolean hasBusinessAccess { get; set; }
    public Boolean hasError { get; set; }
    public List<MilestoneWrapper> milestoneContentList { get; set; }
    public List<SelectOption> siteOptionsList { get; set; }
    public List<SelectOption> exIdList { get; set; }   
    //Phase 2 Rel 1 begin
    public IMP_MilestoneEdit_Controller ()
    {
        try 
        {
            objectId = ApexPages.currentPage().getParameters().get('id');
        } 
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, IMP_String_Utility.NO_ASSOCIATE_SUBPROJECT_RECORD )); 
        }
        hasPermission = true;
        hasAddPermission = true;
        hasTaskAddPermission = true;
        //Check if the user has Edit Permission
        if(!IMP_Project_Utility.checkUserPermission('Project_Milestone__c', 'PermissionsEdit'))
        {
            hasPermission = false;
        }
        
        //Check if the user has Edit Permission
        if(!IMP_Project_Utility.checkUserPermission('Project_Activity__c', 'PermissionsEdit'))
        {
            hasPermission = false;
        }
        
        //Check if the user has Create/Add Permission
        if(!IMP_Project_Utility.checkUserPermission('Project_Activity__c', 'PermissionsCreate'))
        {
            hasAddPermission = false;
        }
        
        //Check if the user has Create/Add Permission
        if(!IMP_Project_Utility.checkUserPermission('Project_Task__c', 'PermissionsCreate'))
        {
            hasTaskAddPermission = false;
        }
       
        CustomSettings__c cs = CustomSettings__c.getInstance();
        hasBusinessAccess = false;
        
        //Check if the user can bypass business rule
        if (cs.Users_Excluded_from_Business_Rules__c != null) 
        {
            if (cs.Users_Excluded_from_Business_Rules__c.contains(UserInfo.getName()))
            {
                hasBusinessAccess = true;
            }
        }
        
        externalIdMap = new Map<String,String>();
              
        milestoneId = '';
        activityIndex = '';
        
        //retrieve external reference 
        ExternalIds();
        
        //retrieve site for the subproject
        siteValueOption();
        
        //Retrieve Milestones , Project Activies and Project Task
        resetWrapperDataAndExtensionField( retrieveMilestoneRecords() );
    }
    //Phase 2 Rel 1 end
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Retrieve the record in the database
    Inputs: 
    Returns: List<Project_Milestone__c>
    History
    10/30/14    Rey Austral      Created
    12/24/14    Rey Austral      Remove the population in the wrapper
    ------------------------------------------------------------*/
    public List<Project_Milestone__c> retrieveMilestoneRecords ()
    {
        List<String> milestonesId = ApexPages.currentPage().getParameters().get('mId').Split(',');
        //Retrieve related milestones
        List<Project_Milestone__c> projectMList =  [SELECT Actual_End_Date_Final__c, Actual_Start_Date__c, Comments__c, Risk_Gauge_Color__c, Account__c ,
                                                    External_System_Name__c, Description__c, Planned_End_Date__c, Planned_Start_Date__c, 
                                                    Site__c, Status__c, Id, External_System_New_Id__c,External_System_ID__c ,Standard__c,
                                                    (SELECT Activity_Definition__c,Actual_End_Date_Final__c,Actual_Start_Date__c,CDK_Assignee__c, External_ID__c,
                                                     CDK_Assignee_Role__c,Client_Assignee__c,Department__c,Description__c,Display_on_PSR__c, Risk_Gauge_Color__c,
                                                     Planned_End_Date__c,Planned_Start_Date__c,Status__c,Terminal_Activity__c,Comments__c,Standard__c  FROM Project_Activities__r Order by Sequence__c NULLS LAST, Planned_Start_Date__c NULLS LAST) 
                                                    FROM Project_Milestone__c where SubProject__c =: objectId and Id in: milestonesId  Order by Planned_Start_Date__c NULLS LAST, Planned_End_Date__c NULLS LAST];
        
        return projectMList;
    }
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Retrieve task record and create a map to link the activity
    Inputs: 
    Returns: 
    History   
    02/03/14    Rey Austral      Created
    ------------------------------------------------------------*/
    public Map<Id, List<Project_Task__c>> retrieveTaskRecords() 
    {
        //for unknown reason the objectId is becoming 18 char id, need to get only 15 char id
         Map<Id, List<Project_Task__c>> completeTaskMap = new Map<Id, List<Project_Task__c>>();
        if (objectId != null)
        {
            String subId = objectId;        
            subId =  subId.substring(0,15);
            
            Map<Id,Project_Activity__c> activityMap = new Map<Id,Project_Activity__c>([Select Id from Project_Activity__c where SubProject_ID__c =: subId ]);
            
            List<Project_Task__c> taskList =[SELECT Project_Activity__c,Task_Definition__c,Actual_End_Date__c,Actual_Start_Date__c,CDK_Assignee__c, External_ID__c, Expected_Time_Spent__c,
                                             CDK_Assignee_Role__c,Client_Assignee__c,Description__c,Display_on_PSR__c, Actual_Time_Spent__c, Reason__c,  Migration_Status__c, Reason_Missed_Planned_End_Date__c ,
                                             Planned_End_Date__c,Planned_Start_Date__c,Status__c,Terminal_Task__c ,Comments__c,Standard__c  FROM Project_Task__c where Project_Activity__c in : activityMap.keyset()  Order by Sequence__c NULLS LAST, Planned_Start_Date__c NULLS LAST ];
           
            //link the activity and the project task
            for (Project_Task__c tsk : taskList) 
            {
                if(completeTaskMap.containsKey(tsk.Project_Activity__c))
                {
                    //add the task in the existing activity
                    //this automatically update the value in the completeTaskMap no need to re update the map
                    List<Project_Task__c> tskList = completeTaskMap.get(tsk.Project_Activity__c);
                    tskList.add(tsk);
                } 
                else
                {
                    List<Project_Task__c> tskList = new List<Project_Task__c>();
                    tskList.add(tsk);
                    completeTaskMap.put(tsk.Project_Activity__c, tskList);
                }
            }
        }
        return completeTaskMap;
    }    
    //Phase 2 Rel 1 end
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: populate the data and reseting all the extension field
    Inputs: List<Project_Milestone__c>
    Returns: 
    History
    12/24/14    Rey Austral      Created
    02/03/14    Rey Austral      Add task
    ------------------------------------------------------------*/
    public void resetWrapperDataAndExtensionField(List<Project_Milestone__c> projectMilestones)
    {
        Map<Id, List<Project_Task__c>> completeTaskMap = retrieveTaskRecords();
        
        //populate the record in wrapper
        milestoneContentList = new List<MilestoneWrapper>();
        for (Project_Milestone__c miles : projectMilestones) 
        {
            MilestoneWrapper mWrapper = new MilestoneWrapper();
            mWrapper.projectMilestone = miles;
            mWrapper.toDelete = false;
            mWrapper.isEdited = false;          
            mWrapper.expandActivity = false;
            mWrapper.hasError = false;
            mWrapper.canAddNewActivity = true;
            if (mWrapper.projectMilestone.Status__c == IMP_Project_Utility.STATUS_COMPLETE && !hasBusinessAccess)
            {
                mWrapper.canAddNewActivity = false;
            }
            //site have a different way to highlight in the field
            //it needs to be in a list of string
            mWrapper.projectActivity = new List<ActivityWrapper>();
            
            //populate the activity and add in the milestone
            if (miles.Project_Activities__r != null) 
            {
                for(Project_Activity__c act :  miles.Project_Activities__r) 
                {
                    ActivityWrapper aWrap = new ActivityWrapper();
                    aWrap.activity  = act;
                    aWrap.toDelete = false;
                    aWrap.isEdited = false;        
                    aWrap.hasError = false;
                    aWrap.isNew  = false;
                    aWrap.isTaskHasNewNonStandard = false;
                    aWrap.expandActivity = false;
                    aWrap.canAddNewTask = true;
                    if (aWrap.activity.Status__c == IMP_Project_Utility.STATUS_COMPLETE && !hasBusinessAccess)
                    {
                        aWrap.canAddNewTask = false;
                    }
                    //populate the task and add in the activity
                    if (completeTaskMap.containsKey(act.id))
                    {
                        List<Project_Task__c> taskList = completeTaskMap.get(act.id);
                        aWrap.projectTask = new List<TaskWrapper>();
                        for (Project_Task__c t : taskList)
                        {
                            TaskWrapper tWrap = new TaskWrapper();
                            tWrap.task  = t;
                            tWrap.toDelete = false;
                            tWrap.isEdited = false;        
                            tWrap.hasError = false;
                            tWrap.isNew  = false;
                            aWrap.projectTask.add(tWrap);
                        }
                    }
                    
                    mWrapper.projectActivity.add(aWrap);
                }
            }
            milestoneContentList.add(mWrapper);            
        }        
    }
    //Phase 2 Rel 1 end
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: re - populate the record in the milestone but retain the expand and checkbox value
    Inputs: List<Project_Milestone__c>
    Returns: 
    History
    12/24/14    Rey Austral      Created
    02/03/14    Rey Austral      Add task
    ------------------------------------------------------------*/
    public void resetWrapperDataOnly(List<Project_Milestone__c> projectMilestonesList)
    { 
        Map<Id, List<Project_Task__c>> mapCompleteTask = retrieveTaskRecords();
        
        //get first the expandActivity  preserve the expand after refresh
        Map<Id,Id> expandIdMap = new Map<Id,Id>();
        
        for (MilestoneWrapper miles : milestoneContentList) 
        {   
            if (miles.expandActivity == true) 
            {
                expandIdMap.put(miles.projectMilestone.Id,miles.projectMilestone.Id);
            }
            
            //get the expand for the activity
            if (miles.projectActivity != null)
            {
                List<ActivityWrapper> activityList = miles.projectActivity;
                for (ActivityWrapper act : activityList)
                { 
                    if (act.expandActivity == true) 
                    {
                        expandIdMap.put(act.activity.Id,act.activity.Id);
                    }                
                }      
            }
        }        
        
        //populate the record in wrapper
        milestoneContentList = new List<MilestoneWrapper>();
        for (Project_Milestone__c miles : projectMilestonesList) 
        {
            MilestoneWrapper mWrapper = new MilestoneWrapper();   
            mWrapper.projectMilestone = miles;
            mWrapper.isEdited = false;      
            mWrapper.hasError = false;
            
            //search if the expand is already been check
            if (expandIdMap.containsKey(miles.Id)) 
            {
                mWrapper.expandActivity = true;
            }
            
            mWrapper.canAddNewActivity = true;
            if (mWrapper.projectMilestone.Status__c == IMP_Project_Utility.STATUS_COMPLETE && !hasBusinessAccess)
            {
                mWrapper.canAddNewActivity = false;
            }
            
            //site have a different way to highlight in the field
            //it needs to be in a list of string
            mWrapper.projectActivity = new List<ActivityWrapper>();
          
            //populate the activity and add in the milestone
            if (miles.Project_Activities__r != null) 
            {
                for(Project_Activity__c act :  miles.Project_Activities__r) 
                {
                    ActivityWrapper aWrap = new ActivityWrapper();  
                    aWrap.activity  = act;
                    aWrap.isEdited = false;  
                    aWrap.hasError = false;
                    aWrap.isTaskHasNewNonStandard = false;
                    
                    aWrap.canAddNewTask = true;
                    if (aWrap.activity.Status__c == IMP_Project_Utility.STATUS_COMPLETE && !hasBusinessAccess)
                    {
                        aWrap.canAddNewTask = false;
                    }
                     //search if the expand is already been check
                    if (expandIdMap.containsKey(act.Id)) 
                    {
                        aWrap.expandActivity = true;
                    }
                    if (mapCompleteTask.containsKey(act.id))
                    {
                        //get all the task related to the activity and add in the activity wrapper
                        List<Project_Task__c> taskList = mapCompleteTask.get(act.id);
                        aWrap.projectTask = new List<TaskWrapper>();
                        for (Project_Task__c t : taskList)
                        {
                            TaskWrapper tWrap = new TaskWrapper();
                            tWrap.task  = t;
                            tWrap.toDelete = false;
                            tWrap.isEdited = false;        
                            tWrap.hasError = false;
                            tWrap.isNew  = false;
                            aWrap.projectTask.add(tWrap);
                        }
                    }
                    mWrapper.projectActivity.add(aWrap);
                }
            }
            milestoneContentList.add(mWrapper);            
        }        
    }
    //Phase 2 Rel 1 end
  
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: save and reset only the extension field not the whole record
    Inputs: 
    Returns: 
    History
    12/24/14    Rey Austral      Created
    ------------------------------------------------------------*/  
    public void inlineSave() 
    {
        ApexPages.getMessages().clear();  
        if (updateMilestone() == false) 
        {
            List<Project_Milestone__c> projectMList = retrieveMilestoneRecords();
            if (!projectMList.isEmpty()) 
            {
                resetWrapperDataOnly(projectMList);      
            }            
        }
    }
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Save the records the go back to view mode
    Inputs: 
    Returns: 
    History
    12/24/14    Rey Austral      Created
------------------------------------------------------------*/  
    public void saveAndClose() 
    {
        ApexPages.getMessages().clear();  
        updateMilestone();
    }
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Retrieve related Sites to SubProject
    Inputs: None
    Returns: List<SelectOption>
    History
    09/15/14      Michael Lasala      Created
    03/24/15      Rey Austral         Change building the option value from string to object
    ------------------------------------------------------------*/
    public void siteValueOption()
    {
        Map<String, String> optionsMap = new Map<String, String>();
        optionsMap.put('', '--None--');
        
        //Retrieve Sites related to SubProject in string format
        List<SubProjectSite__c> siteNamesList = IMP_Project_Utility.buildSiteNames(objectId);
        
        if(siteNamesList != null)
        {
            siteNamesList.sort();
            for(SubProjectSite__c s: siteNamesList)
            {
                optionsMap.put(s.Id, s.Account__r.Name);
            }
        }
        siteOptionsList = IMP_Project_Utility.buildSelectOption(optionsMap, false);
    }
    //Phase 2 Rel 1 end
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Creation of external reference multi picklist values in edit mode
    Inputs: 
    Returns: 
    History
    10/30/14    Rey Austral      Created
    ------------------------------------------------------------*/
    public void ExternalIds()
    {
        Map<String, String> optionsMap = new Map<String, String>();
        optionsMap.put('', '--None--');
        
        //Retrieve all records of Custom Setting
        Map<String, IMP_ExternalReferenceRecordTypes__c> externalReferencesSettings = IMP_ExternalReferenceRecordTypes__c.getAll();
        
        String query = 'SELECT ';
        
        if(!externalReferencesSettings.keySet().isEmpty())
        {
            List<String> externalReferenceRecordTypeNames = new List<String>();
            
            //Iterate over custom setting to get External Reference Partner Id and Record Type Name
            for(IMP_ExternalReferenceRecordTypes__c rt: externalReferencesSettings.values())
            {
                query += rt.Partner_Id__c+',';
                externalReferenceRecordTypeNames.add(rt.Name);
            }
            
            //Retrieve Record Type data
            Schema.DescribeSObjectResult resSchema = SubProject_External_Reference__c.sObjectType.getDescribe();
            Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName();
            
            Set<Id> recordTypeIds = new Set<Id>();
            Map<Id, String> recordTypeMap = new Map<Id, String>();
            
            if(!externalReferenceRecordTypeNames.isEmpty())
            {
                for(String nameFromList: externalReferenceRecordTypeNames)
                {
                    for(String nameFromRecordTypeInfo: recordTypeInfo.keySet())
                    {
                        if(nameFromList == nameFromRecordTypeInfo)
                        {
                            //Add Record Type Id to set to be used as a filter in retrieving SubProject External Reference records
                            recordTypeIds.add(recordTypeInfo.get(nameFromList).getRecordTypeId());
                            
                            //Put Record Type Id as key and Name as value to be used for retrieving matching Id Field API Name for SubProject External Reference record
                            recordTypeMap.put(recordTypeInfo.get(nameFromList).getRecordTypeId(), nameFromList);
                        }
                    }
                }
                
                //Build SOQL query
                query += 'RecordTypeId, External_Entity_Name__c FROM '+IMP_Project_Utility.OBJECT_NAME_SUBPROJECT_EXTERNAL_REFERENCE+' WHERE '+IMP_Project_Utility.OBJECT_NAME_SUBPROJECT+' =: objectId  AND '+IMP_Project_Utility.FIELD_NAME_RECORDTYPEID+' IN: recordTypeIds';
             
                //Retrieve SubProject External Reference records
                List<SubProject_External_Reference__c> subProjectExternalReferenceList = Database.query(query);
                
                if(!subProjectExternalReferenceList.isEmpty())
                {
                    for(SubProject_External_Reference__c er: subProjectExternalReferenceList)
                    {   
                        //Get matching Id field of record's Record Type from Custom Setting
                        String matchingIdField = IMP_ExternalReferenceRecordTypes__c.getInstance(recordTypeMap.get(er.RecordTypeId)).Partner_Id__c;
                        
                        //Get value of matching Id field from record
                        optionsMap.put(String.valueOf(er.get(matchingIdField)), String.valueOf(er.External_Entity_Name__c));
                        externalIdMap.put(String.valueOf(er.get(matchingIdField)), String.valueOf(er.External_Entity_Name__c));
                    }
                }
            }
        }
        
        exIdList = IMP_Project_Utility.buildSelectOption(optionsMap, false);
    }    
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Updating all the change record in edit mode
    Inputs: 
    Returns: 
    History
    11/3/14     Rey Austral      Created
    02/3/15     Rey Austral      Add task
    ------------------------------------------------------------*/
    public Boolean updateMilestone() 
    {       
        ApexPages.getMessages().clear();
        List<Project_Milestone__c> toUpdateMilestoneList =  new  List<Project_Milestone__c>();
        List<Project_Activity__c> toUpdateActivityList = new List<Project_Activity__c>();
        List<Project_Task__c> toUpdateTaskList = new List<Project_Task__c>();
        hasError = false;
        
        //iterate the wrapper and store the id of the milestone and activity with isEdited = true
        //required to process only the records that the user update and not all record
        for (MilestoneWrapper miles : milestoneContentList) 
        {                 
            List<ActivityWrapper> currentActivityList = miles.projectActivity;
            
            //reset the error to remove the highlight 
            miles.hasError = false;            
            
            if (miles.isEdited == true) 
            {                
                toUpdateMilestoneList.add(miles.projectMilestone);
            }
            
            for(ActivityWrapper act : currentActivityList) 
            {
                act.hasError = false;
                
                //add the activity in the list if isEdited = true
                if (act.isEdited == true) 
                {   
                    act.activity.Milestone__r = new Project_Milestone__c();
                    act.activity.Milestone__r.Description__c =  miles.projectMilestone.Description__c;
                    act.activity.Milestone__r.Id = miles.projectMilestone.Id;                       
                    toUpdateActivityList.add(act.activity);
                }
                
                //add the task in the list if the project task is not null and is edited = true
                if (act.projectTask != null) 
                {
                    List<TaskWrapper> taskList = act.projectTask;                    
                    
                    for(TaskWrapper task : taskList )
                    {
                        task.hasError = false;
                        
                        //only add task that has been change
                        if (task.isEdited == true) 
                        {                                             
                            toUpdateTaskList.add(task.task);
                        }
                    }
                    
                }
            }            
        }
        
        //execute the dml operation, 
        Map<Id,Id> errorIdsMap = new Map<Id,Id>();
        if (!toUpdateMilestoneList.isEmpty())
        {
            try
            {
                List<Database.SaveResult> dsrsMilestoneList = Database.Update(toUpdateMilestoneList, false);
                Integer ctrMiles = 0;
                
                //get all the id of the error milestone and activity to be used in hightlighting the row
                for(Database.SaveResult dsrM : dsrsMilestoneList)
                {            
                    //Iterate over failure records
                    if(!dsrM.isSuccess())
                    {                
                        Project_Milestone__c miles = toUpdateMilestoneList[ctrMiles];  
                        String[] arguments = new String[] { miles.Description__c, dsrM.getErrors()[0].getMessage()  };
                            
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_MILESTONE_ERROR, arguments) );
                        ApexPages.addMessage(errMsg);
                        hasError = true;  
                        errorIdsMap.put(miles.Id, miles.Id);
                    }
                    ctrMiles++;
                }  
            }
            catch(Exception ex)
            {
                hasError = true;
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage() );
                ApexPages.addMessage(errMsg);
            }
        }
        
        //Upsert Activity Record
        Map<String,TaskActivityWrapper> ExternalActIdMap = new Map<String,TaskActivityWrapper>();
        if (!toUpdateActivityList.isEmpty())
        {
            try
            {
                List<Database.UpsertResult> dursActivityList = Database.Upsert(toUpdateActivityList, false);
                Integer ctr = 0;
                
                for(Database.UpsertResult dsr : dursActivityList)
                {            
                    //Iterate over failure records
                    Project_Activity__c act = toUpdateActivityList[ctr]; 
                    if(!dsr.isSuccess())
                    { 
                        String[] arguments = new String[] { act.Milestone__r.Description__c, act.Description__c ,  dsr.getErrors()[0].getMessage() };
                            
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_ACTIVITY_ERROR, arguments) );
                        ApexPages.addMessage(errMsg);
                        hasError = true;
                        errorIdsMap.put(act.Id, act.Id);
                    }
                    
                    //this will update the project activity field for the new non-standard task
                    //external id field store the temporary id that will link the activity and the non-standard task
                    if (act.External_ID__c != null && act.External_ID__c != '') 
                    {
                        TaskActivityWrapper taskActBridgeMap = new TaskActivityWrapper();
                        taskActBridgeMap.ActivityId = act.Id;
                        taskActBridgeMap.isSuccess = dsr.isSuccess();
                        ExternalActIdMap.put(act.External_ID__c, taskActBridgeMap);
                    }
                    ctr++;
                } 
            }
            catch(Exception ex)
            {
                hasError = true;
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage() );
                ApexPages.addMessage(errMsg);
            }
        }
        
        //update the project activity in the list
        List<Project_Task__c> toUpdateLatestTaskList = changeToUpdateTaskList(ExternalActIdMap, toUpdateTaskList);
        if (!toUpdateLatestTaskList.isEmpty())
        {
            try
            {
                List<Database.UpsertResult> dsrsTaskList = Database.Upsert(toUpdateTaskList, false);  
                Integer ctr = 0;
                for(Database.UpsertResult dsr : dsrsTaskList)
                {            
                    //Iterate over failure records
                    if(!dsr.isSuccess())
                    {                
                        Project_Task__c tsk = toUpdateLatestTaskList[ctr]; 
                        String[] arguments = new String[] { tsk.Description__c, dsr.getErrors()[0].getMessage()  };
                            
                            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_TASK_ERROR, arguments) );
                        ApexPages.addMessage(errMsg);
                        hasError = true;
                        errorIdsMap.put(tsk.Id, tsk.Id);
                    }
                    ctr++;
                }
            }
            catch(Exception ex)
            {
                hasError = true;
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage() );
                ApexPages.addMessage(errMsg);
            }            
        }
        
        if (!errorIdsMap.isEmpty())
        {
            //this will update hasError in the wrapper to highlight the row and expand it 
            addErrorInUpdate(errorIdsMap);
        }
        return hasError;
    }
    //Phase 2 Rel 1 end
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Update new non-standard task activity field
    Inputs: 
    Returns: 
    History
    02/03/15    Rey Austral      Created
    ------------------------------------------------------------*/
    public List<Project_Task__c> changeToUpdateTaskList(Map<String,TaskActivityWrapper> bridgeMap, List<Project_Task__c> toUpdateTasklist)
    {
        //find if there are records that is a new non-standard task
        //update the project activity field for the non-standard task
        List<Project_Task__c> updateList = new List<Project_Task__c>();
        if (!toUpdateTasklist.isEmpty())
        {
            for (Project_Task__c p : toUpdateTasklist) 
            {
                if (p.External_ID__c != null && p.External_ID__c != '')
                {
                    //get the activity id in the map by using the external id
                    if ( bridgeMap.containsKey(p.External_ID__c)) 
                    {
                        TaskActivityWrapper t =  bridgeMap.get(p.External_ID__c);
                        
                        //only add the task in the list if the activity is successfully inserted
                        if (t.isSuccess) 
                        {
                            p.Project_Activity__c = t.ActivityId;
                            updateList.add(p);
                        }
                    }
                    else
                    {
                        updateList.add(p);
                    }
                }
                else 
                {
                    updateList.add(p);
                }
            }
        }
        
        return updateList;
    }
    //Phase 2 Rel 1 end
  
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: updating the wrapper with error records and refresh milestone record
    Inputs: 
    Returns: 
    History
    12/2/14     Rey Austral      Created
    12/08/14    Samuel Oberes    Added @TestVisible annotation to allow test methods to access this private method
    02/03/15    Rey Austral      Add task
    04/02/15    Rey Austral      Add condition to reset isTaskHasNew
    ------------------------------------------------------------*/
    @TestVisible private void addErrorInUpdate(Map<Id,Id> errorIdMap)
    {
        //this will update the hasError to highlight the row using css
        //this also expand the activity if the activity has one or more error
        if (!errorIdMap.isEmpty())
        {
            List<Project_Milestone__c> projectMList = retrieveMilestoneRecords();
            Map<Id, List<Project_Task__c>> completeTaskMap = retrieveTaskRecords();
            Map<Id,Project_Milestone__c> milestoneMap = new Map<Id, Project_Milestone__c>(projectMList);
            for (MilestoneWrapper miles : milestoneContentList) 
            {  
                Project_Milestone__c milestone = milestoneMap.get(miles.projectMilestone.Id);
                miles.projectMilestone = milestone;
                if (errorIdMap.containsKey(miles.projectMilestone.Id))
                {
                    miles.hasError =true;
                }
                else
                {
                    miles.isEdited = false;
                }
                
                Map<Id,Project_Activity__c> ActivityMap = new Map<Id, Project_Activity__c>(milestone.Project_Activities__r);
                List<ActivityWrapper> activityList = miles.projectActivity;
                for (ActivityWrapper act : activityList)
                {
                    Project_Activity__c  activity = new Project_Activity__c();
                    if (errorIdMap.containsKey(act.activity.Id))
                    {                       
                        act.hasError = true;
                        miles.expandActivity = true;
                    } 
                    else 
                    {
                        //if the record have no error then update the record to get the latest status and dates
                        activity = ActivityMap.get(act.activity.Id);
                        act.activity = activity;
                      
                        if(act.isNew == true)
                        {
                            //convert the x to checkbox for non-standard activity that has been save successfully
                            act.isNew = false;
                            act.isEdited = false;
                        }
                        else 
                        {
                            act.isEdited = false;
                        }
                    }
                    Boolean checkIfTaskHasError = false;
                    if (act.projectTask != null) 
                    { 
                        List<TaskWrapper> taskList = act.projectTask;
                        Map<Id,Project_Task__c> updatedTaskMap =  new Map<Id,Project_Task__c>();
                        if (completeTaskMap.containsKey(act.activity.Id))
                        {
                            updatedTaskMap = new Map<Id,Project_Task__c>(completeTaskMap.get(act.activity.Id));
                        }
                        
                        for (TaskWrapper task : taskList)
                        {
                            if (errorIdMap.containsKey(task.task.Id))
                            {                       
                                task.hasError = true;
                                miles.expandActivity = true;
                                checkIfTaskHasError = true;
                            }
                            else 
                            {
                                //if the record have no error then update the record to get the latest status and dates
                                if (updatedTaskMap.containsKey(task.task.Id)) 
                                {
                                    Project_Task__c  updatedTask =updatedTaskMap.get(task.task.Id);
                                    task.task = updatedTask;
                                }                                
                                if(task.isNew == true)
                                {
                                     //convert the x to checkbox for non-standard task that has been save successfully
                                    task.isNew = false;
                                    task.isEdited = false;                                    
                                }
                                else 
                                {
                                    task.isEdited = false;
                                }
                            }
                        }
                    }
                    //this will reset the isTaskHasNewNonStandard to hide the expected time spent column, if all task have no error
                    if (checkIfTaskHasError == false && act.isTaskHasNewNonStandard == true)
                    {
                        act.isTaskHasNewNonStandard = false;
                    }
                }           
            }
        }
    } 
    //Phase 2 Rel 1 end
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Delete Milestones and related Project Activities
    Inputs: 
    Returns: 
    History
    11/3/14    Rey Austral      Created
    02/3/15    Rey Austral      Add task
    ------------------------------------------------------------*/
    public void deleteMilestone()
    {
        ApexPages.getMessages().clear();
        List<Project_Milestone__c> toDeleteMilestoneList =  new  List<Project_Milestone__c>();
        List<Project_Activity__c> toDeleteActivityList = new List<Project_Activity__c>();
        List<Project_Task__c> toDeleteTaskList = new List<Project_Task__c>();
        if(!IMP_Project_Utility.checkUserPermission('Project_Milestone__c','PermissionsDelete'))
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, IMP_String_Utility.NO_PERMISSION_TO_DELETE_MILESTONES));          
        } 
        else 
        {   
            Map<Id,Id> mapActivityToExpand = new Map<Id,Id>();
            Boolean hasErrors = false;
            Map<Id,Id> errorIdsMap = new Map<Id,Id>();
            for (MilestoneWrapper miles : milestoneContentList) 
            {
                miles.hasError = false;
                
                //if milestone record is to be deleted, all activity related to that milestone will also be deleted 
                //even if the user did not select the activty                
                if (miles.toDelete == true) 
                {
                    toDeleteMilestoneList.add(miles.projectMilestone);
                    List<ActivityWrapper> activityList = miles.projectActivity;
                    for(ActivityWrapper act : activityList) 
                    { 
                        toDeleteActivityList.add(act.activity);
                        if ( act.projectTask != null) 
                        {
                            List<TaskWrapper> taskList = act.projectTask;
                            for (TaskWrapper tsk : taskList)
                            {                            
                                toDeleteTaskList.add(tsk.Task);                            
                            }
                        }
                    }
                }
                else
                {
                    List<ActivityWrapper> activityList = miles.projectActivity;                    
                    
                    Boolean hasActivityToDelete = false;
                    for(ActivityWrapper act : activityList) 
                    {                
                        if (act.toDelete == true) 
                        {
                            //store the id that will be deleted to a container
                            act.activity.Milestone__r = new Project_Milestone__c();
                            act.activity.Milestone__r.Description__c =  miles.projectMilestone.Description__c;
                            act.activity.Milestone__r.Id = miles.projectMilestone.Id;
                            toDeleteActivityList.add(act.activity);
                            
                            if (act.projectTask != null) 
                            {
                                List<TaskWrapper> taskList = act.projectTask;
                                for (TaskWrapper tsk : taskList)
                                {
                                    toDeleteTaskList.add(tsk.Task);
                                }
                            }
                            
                            hasActivityToDelete = true;
                        }
                        else 
                        {
                            //there are specific condition to be consider when deleting an task
                            //please check the method for more details
                            if (act.projectTask != null) 
                            {
                                List<TaskWrapper> taskList = act.projectTask;
                                
                                for (TaskWrapper tsk : taskList)
                                {
                                    if (tsk.toDelete == true) 
                                    {
                                        toDeleteTaskList.add(tsk.Task);
                                    }
                                }
                                
                            }
                        }
                    }
                    
                    //this is used to expand the activity of the milestone which have a deleted record
                    if (hasActivityToDelete == true)
                    {
                        mapActivityToExpand.put(miles.projectMilestone.Id, miles.projectMilestone.Id);
                    }                    
                }
            }
            
            //Deletion of Task Record
            if (!toDeleteTaskList.isEmpty())
            {
                Try
                {                 
                    List<Database.DeleteResult> dsrsTaskList = Database.Delete(toDeleteTaskList, false); 
                    Integer ctr = 0;
                    for(Database.DeleteResult dsr : dsrsTaskList)
                    {            
                        //Iterate over failure records
                        if(!dsr.isSuccess())
                        {
                            Project_Task__c tsk = toDeleteTaskList[ctr];
                            String[] arguments = new String[] { tsk.Description__c, dsr.getErrors()[0].getMessage() };
                                
                            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_TASK_ERROR, arguments) );
                            ApexPages.addMessage(errMsg);
                            errorIdsMap.put(tsk.Id, tsk.Id);
                            hasErrors = true;
                        }
                        ctr++;
                    }
                }
                catch (Exception ex)
                {
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage() );
                    ApexPages.addMessage(errMsg);
                    hasErrors = true;
                }
                
            }
            
            //Deletion of Activity Record
            if (!toDeleteActivityList.isEmpty())
            {
                try
                {                   
                    List<Database.DeleteResult> dsrsActivityList = Database.Delete(toDeleteActivityList, false);
                    Integer ctr = 0;
                    for(Database.DeleteResult dsr : dsrsActivityList)
                    {            
                        //Iterate over failure records
                        if(!dsr.isSuccess())
                        {
                            Project_Activity__c act = toDeleteActivityList[ctr];
                            String[] arguments = new String[] { act.Milestone__r.Description__c, act.Description__c ,  dsr.getErrors()[0].getMessage() };
                                
                            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_ACTIVITY_ERROR, arguments) );
                            ApexPages.addMessage(errMsg);
                            errorIdsMap.put(act.Id, act.Id);
                            hasErrors = true;
                        }
                        ctr++;
                    }
                }
                catch (Exception ex)
                {                    
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage() );
                    ApexPages.addMessage(errMsg);
                    hasErrors = true;
                }
                
            }
            
            //Deletion of Milestone Record
            if (!toDeleteMilestoneList.isEmpty())
            {
                try
                {                   
                    List<Database.DeleteResult> dsrsMilestoneList = Database.Delete(toDeleteMilestoneList, false);               
                    Integer ctrMiles = 0;
                    
                    for(Database.DeleteResult dsrM : dsrsMilestoneList)
                    {            
                        //Iterate over failure records
                        if(!dsrM.isSuccess())
                        { 
                            Project_Milestone__c miles = toDeleteMilestoneList[ctrMiles];   
                            String[] arguments = new String[] { miles.Description__c, dsrM.getErrors()[0].getMessage() };
                                
                            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_MILESTONE_ERROR, arguments) );
                            ApexPages.addMessage(errMsg);
                            errorIdsMap.put(miles.Id, miles.Id);
                            hasErrors = true;
                        }
                        ctrMiles++;
                    }
                }
                catch (Exception ex)
                {
                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage() );
                    ApexPages.addMessage(errMsg);
                    hasErrors = true;
                }
                
            }
            
            if (hasErrors == true)
            {
                //highlight row for the milestone and activty with error in deletion
                addErrorInTheWrapper(errorIdsMap);
            } 
            else
            {
                //refresh the record to remove the deleted record in the screen, and expand the activty for the affected milestone
                List<Project_Milestone__c> projectM = retrieveMilestoneRecords();
                resetWrapperDataOnly(projectM);
            }
        }
    }
    //Phase 2 Rel 1 end   

    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: updating the wrapper with error records
    Inputs: 
    Returns: 
    History
    12/2/14    Rey Austral      Created
    12/08/14   Samuel Oberes    Added @TestVisible annotation to allow test methods to access this private method
    02/03/15   Rey Austral      Add task
    04/15/15   Rey Austral      Add function to remove successful deleted record in the wrapper
    ------------------------------------------------------------*/
    @TestVisible private void addErrorInTheWrapper(Map<Id,Id> errorIdMap)
    {
        //this will update the hasError to highlight the row using css
        //this also expand the activity if the activity has one or more error
        if (!errorIdMap.isEmpty())        
        {
            List<Integer> milestoneToRemoveFromEditPageList = new List<Integer>();
            Integer cntMiles = 0;
            for (MilestoneWrapper miles : milestoneContentList) 
            {   
                if (errorIdMap.containsKey(miles.projectMilestone.Id))
                {
                    miles.hasError =true;
                }
                else if(miles.toDelete == true)
                {
                    //store the index of the record that has been successfully deleted in the database
                    miles.toDelete = false;
                    milestoneToRemoveFromEditPageList.add(cntMiles);
                }
                else
                {
                    //Only process the activity when there are no milestone selected
                    List<Integer> activityToRemoveFromEditPageList = new List<Integer>();
                    List<ActivityWrapper> activityList = miles.projectActivity;
                    Integer cntAct = 0;
                    for (ActivityWrapper act : activityList)
                    {
                        if (errorIdMap.containsKey(act.activity.Id))
                        {                       
                            act.hasError = true;
                            miles.expandActivity = true;
                        }
                        else if(act.toDelete == true)
                        {
                            //store the index of the record that has been successfully deleted in the database
                            act.toDelete = false;
                            activityToRemoveFromEditPageList.add(cntAct);                      
                        }
                        else 
                        {
                            //Only process the task when there are no activity selected
                            if (act.projectTask != null) 
                            { 
                                List<Integer> taskToRemoveFromEditPageList = new List<Integer>();
                                List<TaskWrapper> taskList = act.projectTask;
                                Integer cntTask =0;
                                for (TaskWrapper task : taskList)
                                {
                                    if (errorIdMap.containsKey(task.task.Id))
                                    {                       
                                        task.hasError = true;
                                        miles.expandActivity = true;
                                    }
                                    else if(task.toDelete == true)
                                    {
                                        //store the index of the record that has been successfully deleted in the database
                                        task.toDelete = false;
                                        taskToRemoveFromEditPageList.add(cntTask);
                                    }
                                    
                                    cntTask++;
                                }
                                
                                if (taskToRemoveFromEditPageList.size() > 0)
                                {
                                    //iterate the list to remove the deleted task record in the task wrapper class
                                    taskToRemoveFromEditPageList.sort();
                                    for (Integer indexTask = taskToRemoveFromEditPageList.size() -1; indexTask >= 0; indexTask-- )
                                    {
                                        taskList.remove( taskToRemoveFromEditPageList[indexTask] );
                                    }
                                }
                            }
                        }
                        cntAct++;
                        
                    }
                    if (activityToRemoveFromEditPageList.size() > 0)
                    {
                        //iterate the list to remove the deleted activity record in the activity wrapper class
                        activityToRemoveFromEditPageList.sort();
                        for (Integer indexAct = activityToRemoveFromEditPageList.size() -1; indexAct >= 0; indexAct-- )
                        {
                           activityList.remove( activityToRemoveFromEditPageList[indexAct] ); 
                        }                      
                    }
                }
                cntMiles++;
            }
            if (milestoneToRemoveFromEditPageList.size() > 0)
            {
                //iterate the list to remove the deleted milestone record in the milestone wrapper class\
                milestoneToRemoveFromEditPageList.sort();
                for (Integer indexMiles = milestoneToRemoveFromEditPageList.size() -1; indexMiles >= 0; indexMiles-- )
                {
                    milestoneContentList.remove( milestoneToRemoveFromEditPageList[indexMiles] ); 
                }               
            }
        }
    }
    //Phase 2 Rel 1 end
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Create a new non-standard activity
    Inputs: 
    Returns: 
    History
    12/5/14     Rey Austral     Created
    02/03/15    Rey Austral     Add task and logic to link  the task with the activity
    04/02/15    Rey Austral     Add  isTaskHasNew
    ------------------------------------------------------------*/
    public void createNewActivity() 
    {       
        for(MilestoneWrapper mWrap : milestoneContentList)
        {
            if (mWrap.projectMilestone.Id == milestoneId)
            {
                //create a blank record and add in the wrapper
                ActivityWrapper aWrap = new ActivityWrapper();
                
                Datetime currDateTime = Datetime.now();
                String externalDateTime = currDateTime.format('MMddyyhhmmss');
                
                //external id is used to connect the activity and task since only saving in the databse will generate the id
                String externalId = mWrap.projectMilestone.Id + externalDateTime + UserInfo.getUserId();
                Project_Activity__c projectActivity = new Project_Activity__c(Milestone__c = mWrap.projectMilestone.Id, External_ID__c  = externalId);
                aWrap.activity = projectActivity;
                
                //isNew is used to determine if the page will show a checkbox or a x(remove) button for each record
                aWrap.isNew = true;
                aWrap.isEdited = true;
                aWrap.isTaskHasNewNonStandard = true;
                aWrap.canAddNewTask = true;   
                
                TaskWrapper tWrap = new TaskWrapper();
                Project_Task__c projectTask = new Project_Task__c(External_ID__c  = externalId);
                tWrap.Task = projectTask;
                tWrap.isNew = true;
                tWrap.isEdited  =true;
                
                //automatically create a task
                aWrap.projectTask = new List<TaskWrapper>();
                aWrap.projectTask.add(tWrap);
                aWrap.expandActivity = true;
                
                // Karl adding the following exception handling to resolve the index out of bounds issue when a
                // Project Milestone has no existing child Project Activities, and, the user attempts to create a new
                // Project Activity under it.
                if (mWrap.projectActivity.size() > 0)
                {
                    mWrap.projectActivity.add(0,aWrap);
                }
                else
                {
                    mWrap.projectActivity.add(aWrap);
                }
                /* if (mWrap.projectActivity != null)
                {
                    mWrap.projectActivity.add(0,aWrap);
                }
                else
                {
                    mWrap.projectActivity = new List<ActivityWrapper>();
                    mWrap.projectActivity.add(aWrap);
                } */
                
                mWrap.expandActivity = true;                
                break;
            }
        }
    }
    //Phase 2 Rel 1 end
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Adding of non-standard task
    Inputs: 
    Returns: 
    History
    02/03/15    Rey Austral      Created
    04/02/15    Rey Austral      Add isTaskHasNewNonStandard 
    ------------------------------------------------------------*/
    public void createNewTask() 
    {
        for(MilestoneWrapper mWrap : milestoneContentList)
        {
            if (mWrap.projectMilestone.Id == milestoneId)
            {
                List<ActivityWrapper> aWrapList = mWrap.projectActivity;
                for (ActivityWrapper a: aWrapList)
                {
                    //normal creation of non-standard task                    
                    if (activityId != null && activityId != '') 
                    {
                        //this section is used when the activity is already in the database and have salesforce id
                        if (a.activity.Id == activityId) 
                        {
                            TaskWrapper tWrap = new TaskWrapper();
                            Project_Task__c projectTask = new Project_Task__c();
                            projectTask.Project_Activity__c = a.activity.Id;
                            tWrap.Task = projectTask;
                            
                            //isNew is used to determine in the page if it will display a checkbox or an x
                            tWrap.isNew = true;
                            tWrap.isEdited  =true;
                            
                            if (a.projectTask!=null && a.projectTask.size()>0) 
                            {
                                 a.projectTask.add(0,tWrap);
                            } 
                            else 
                            {
                                a.projectTask = new List<TaskWrapper>();
                                a.projectTask.add(tWrap);
                            }
                            
                            a.isTaskHasNewNonStandard = true;
                            a.expandActivity = true;
                            mWrap.expandActivity = true;                
                            break;
                        }
                    }
                    else
                    {     
                        //this section is used when the activity is a newly created and have no salesforce id
                        if (a.activity.External_ID__c == activityExternalId) 
                        {
                            TaskWrapper tWrap = new TaskWrapper();
                            Project_Task__c projectTask = new Project_Task__c(External_ID__c  = activityExternalId);
                            projectTask.Project_Activity__c = a.activity.Id;
                            tWrap.Task = projectTask;
                            tWrap.isNew = true;
                            tWrap.isEdited  =true;
                            
                            if (a.projectTask.size() > 0)
                            {
                                a.projectTask.add(0,tWrap);
                            }
                            else
                            {
                                a.projectTask.add(tWrap);
                            }
                            
                            a.expandActivity = true;
                            a.isTaskHasNewNonStandard = true;
                            
                            mWrap.expandActivity = true;                
                            break;
                        }
                    }
                }
            }
        }
    }
    //Phase 2 Rel 1 end
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Deletion a new non-standard activity
    Inputs: 
    Returns: 
    History
    12/5/14    Rey Austral      Created
    ------------------------------------------------------------*/
    public void deleteNewActivity() 
    {
        //delete the specific activity that was created as a new non standard activity
        for(MilestoneWrapper mWrap : milestoneContentList)
        {
            if (mWrap.projectMilestone.Id == milestoneId)
            {
                Integer index = Integer.valueOf(activityIndex);
                mWrap.projectActivity.remove(index);
                mWrap.expandActivity = true;
                break;
            }
        }
    }
    //Phase 2 Rel 1 begin
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Deletion a new non-standard task
    Inputs: 
    Returns: 
    History
    02/03/15    Rey Austral      Created
    04/02/15    Rey Austral      Add condition to reset isTaskHasNew
    ------------------------------------------------------------*/
    public void deleteNewTask() 
    {
        for(MilestoneWrapper mWrap : milestoneContentList)
        {
            if (mWrap.projectMilestone.Id == milestoneId)
            {
                List<ActivityWrapper> aWrapList = mWrap.projectActivity;                
                for (ActivityWrapper a: aWrapList)
                {
                    //check if the parent of the task has a salesforce id 
                    if (activityId != null && activityId != '') 
                    {
                        if (a.activity.Id == activityId) 
                        {
                            Integer index = Integer.valueOf(taskIndex);
                            a.projectTask.remove(index);
                            a.expandActivity = true;                        
                            mWrap.expandActivity = true;    
                            //check if there are still isNew = true in the task list, 
                            //this will determinie if the expected time spent column should be hidden in the ui
                            if ( checkIfHasNewTask( a.projectTask ) == false )
                            {
                                a.isTaskHasNewNonStandard = false;
                            }
                            break;
                        }
                    } 
                    else 
                    {
                        if (a.activity.External_ID__c == activityExternalId) 
                        {
                            Integer index = Integer.valueOf(taskIndex);
                            a.projectTask.remove(index);
                            a.expandActivity = true;                        
                            mWrap.expandActivity = true;   
                            
                            //check if there are still isNew = true in the task list, 
                            //this will determinie if the expected time spent column should be hidden in the ui
                            if ( checkIfHasNewTask( a.projectTask ) == false )
                            {
                                a.isTaskHasNewNonStandard = false;
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
    //Phase 2 Rel 1 end
    //Phase 2 Rel 1 Start
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Find if there are isNew = true in the Task Wrapper List
    Inputs: List<TaskWrapper>
    Returns: Boolean
    History
    04/02/15    Rey Austral      Created
    ------------------------------------------------------------*/
    public Boolean checkIfHasNewTask(List<TaskWrapper> taskList)
    {
        Boolean result = false;
        if (taskList != null)
        {
            for (TaskWrapper tsk : taskList)
            {
               if (tsk.isNew)
               {
                   result = true;
                   break;
               }
            }
        }
        return result;
    }
    //Phase 2 Rel 1 end
    
    public class MilestoneWrapper
    {
        public Project_Milestone__c projectMilestone { get; set; }  
        public List<ActivityWrapper> projectActivity { get; set; }
        public List<String> siteSelected { get; set; }
        public Boolean toDelete { get; set; }
        public Boolean isEdited { get; set; }
        public Boolean hasError { get; set; }
        public Boolean expandActivity { get; set; }
        public Boolean canAddNewActivity { get; set; }
    }
    
    public class ActivityWrapper
    {
        public Project_Activity__c activity { get; set; }
        public List<TaskWrapper> projectTask { get; set; }
        public Boolean toDelete { get; set; }
        public Boolean isEdited { get; set; }
        public Boolean hasError { get; set; }
        public Boolean isNew { get; set; }
        public Boolean isTaskHasNewNonStandard { get; set; }
        public Boolean expandActivity { get; set; }
        public Boolean canAddNewTask { get; set; }
    } 
    
    public class TaskWrapper
    {
        public Project_Task__c task { get; set; }
        public Boolean toDelete { get; set; }
        public Boolean isEdited { get; set; }
        public Boolean hasError { get; set; }
        public Boolean isNew { get; set; }
    }
    
    public class TaskActivityWrapper
    {
        public Id ActivityId { get; set; }
        public Boolean isSuccess { get; set; }       
    }  
    
}