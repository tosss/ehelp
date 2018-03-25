/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Responsible for showing and editing the milestones for a certain sub project
Test Class: IMP_MilestonePopupExtension_Test
History
09/11/14    Michael Lasala      Created
09/15/14    Michael Lasala      Added getSites method, validateProjectActivities method, deleteNonStandardActivity method
09/16/14    Michael Lasala      Added concatenateSites method, Added logic for Non-Standard Milestone, Changed logic for addNonStandardActivity method
09/16/14    Michael Lasala      Changed logic for deleteNonStandardActivity method
09/24/14    Michael Lasala      Added getExternalIds method
10/08/14    Samuel Oberes       Added cancelWindow method
10/09/14    Michael Lasala      Changed Project_Activity__c list to wrapper class to accommodate error highlight on error
11/20/14    Samuel Oberes       Applied usage of IMP_Project_Utility.buildSelectOption
02/10/15    Rey Austral         Change the creation of activity to include task, remove edit function
03/24/15    Rey Austral         Remove concatenateSites
------------------------------------------------------------*/
public with sharing class IMP_MilestonePopup_Extension
{ 
    public SubProject__c subProject  { get; set; }
    public Project_Milestone__c projectMilestone { get; set; }     
    public String subProjectId;
    public Boolean isValid { get; set; }   
    public List<ActivityWrapper> projectActivityList { get; set; }
    public String activityExternalId { get; set; }
    public String activityIndex { get; set; }
    public String taskIndex { get; set; }
    //Phase 2 Rel 1
    public IMP_MilestonePopup_Extension(ApexPages.StandardController stdController)
    {
        projectMilestone = (Project_Milestone__c)stdController.getRecord();       
        projectActivityList = new List<ActivityWrapper>();
        //Get parameters for page rendering of selected components
        //Get SubProject__c record Id
        subProjectId = ApexPages.currentPage().getParameters().get('subProjectId'); 
        
        projectMilestone.SubProject__c = subProjectId;
        
        if(subProjectId != null)
        {
            //Retrieve SubProject
            subProject = IMP_Project_Utility.retrieveSubProject(subProjectId);
        }
    }
    //Phase 2 Rel 1
    //Phase 2 Rel 1
    /*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Insert Project Milestone record if new and upsert Project Activities
Inputs: None
Returns: Void
History
09/11/14      Michael Lasala      Created
09/17/14      Michael Lasala      Added deletion of selected Project Activities
10/02/14      Rey Austral         Add External System Name
02/10/15      Rey Austral         Change the saving process to include the task
------------------------------------------------------------*/
    public void saveRecords()
    {
        ApexPages.getMessages().clear();  
        isValid = false;
        Savepoint sp = Database.setSavepoint();
        try
        {
            //Build Site Name string
            List<Project_Activity__c> toUpdateActivityList = new List<Project_Activity__c>();
            List<Project_Task__c> toUpdateTaskList = new List<Project_Task__c>();
            Map<Integer,Integer> errorIdsMap = new Map<Integer,Integer>();
            Boolean hasError = false;   
            
            if (checkValidToSave(projectActivityList))
            {                
                //insert first the milestone to get the id to be used in the activity record
                try
                {
                    //clone the object to remove the previous id , this will handle the error if the rollback fires                    
                    upsert projectMilestone; 
                }
                catch (Exception ex)
                {
                    hasError = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, ex.getMessage()));
                }
                if(projectMilestone.Id != null)
                {
                    for(ActivityWrapper act : projectActivityList) 
                    {
                        //clone to remove the id that has been generated but because of the rollback it needs to be remove
                        act.activity = act.activity.clone();
                        //update the milestone field with the newly inserted milestone id
                        act.hasError = false;
                        
                        //create another clone to be able to update the milestone field,
                        //if we are not going to clone there will be an error if rollback happen
                        Project_Activity__c cloneAct = act.activity.clone();
                        cloneAct.milestone__c = projectMilestone.Id;
                        
                        //add the activty to the list
                        toUpdateActivityList.add(cloneAct);
                        
                        //iterate the task to update some fields
                        for(TaskWrapper tsk : act.projectTask) 
                        {
                            //clone to remove the id that has been generated but because of the rollback it needs to be remove
                            tsk.Task = tsk.Task.clone();
                            
                            //roll down the value of activity to task if the task field is empty
                            if (act.activity.Planned_Start_Date__c != null && tsk.Task.Planned_Start_Date__c == null) 
                            {
                                tsk.Task.Planned_Start_Date__c = act.activity.Planned_Start_Date__c ;
                            }
                            if (act.activity.Planned_End_Date__c != null && tsk.Task.Planned_End_Date__c == null) 
                            {
                                tsk.Task.Planned_End_Date__c = act.activity.Planned_End_Date__c ;
                            }
                            if (act.activity.CDK_Assignee__c != null && tsk.Task.CDK_Assignee__c == null)
                            {
                                tsk.Task.CDK_Assignee__c = act.activity.CDK_Assignee__c ;
                            }
                            if (act.activity.Client_Assignee__c != null && tsk.Task.Client_Assignee__c == null) 
                            {
                                tsk.Task.Client_Assignee__c = act.activity.Client_Assignee__c ;
                            }
                            if (act.activity.CDK_Assignee_Role__c != null && tsk.Task.CDK_Assignee_Role__c == null)
                            {
                                tsk.Task.CDK_Assignee_Role__c = act.activity.CDK_Assignee_Role__c ;
                            }
                            tsk.hasError = false;
                            toUpdateTaskList.add(tsk.Task);
                        }
                    }
                    
                    //insert activit first in the database to get the latest id to be used in the task
                    Map<String,TaskActivityWrapper> ExternalActIdMap = new Map<String,TaskActivityWrapper>();
                    if (!toUpdateActivityList.isEmpty())
                    {
                        List<Database.SaveResult> dsrsList = Database.Insert(toUpdateActivityList, false);
                        Integer ctr = 0;
                        
                        for(Database.SaveResult dsr : dsrsList)
                        {   
                            //Iterate over failure records
                            Project_Activity__c act = toUpdateActivityList[ctr]; 
                            if(!dsr.isSuccess())
                            {
                                String[] arguments = new String[] {  act.Description__c , dsr.getErrors()[0].getMessage() };
                                    
                                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error,  String.format(IMP_String_Utility.DML_ACTIVITY_ERROR_POPUP, arguments) );
                                ApexPages.addMessage(errMsg);
                                hasError = true;
                                errorIdsMap.put(ctr,ctr);
                            }
                            
                            //populate the wrapper class with the newly created activity id
                            //this will be used to update the task
                            //external id is used as a temporary id to link the activity and task
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
                    
                    //update the task activity field before inserting in the database
                    List<Project_Task__c> toUpdateTaskListList = changeToUpdateTaskList(ExternalActIdMap, toUpdateTaskList);
                    if (!toUpdateTaskList.isEmpty())
                    {
                        List<Database.UpsertResult> dsrsTaskList = Database.Upsert(toUpdateTaskListList, false);  
                        Integer ctr = 0;
                        for(Database.UpsertResult dsr : dsrsTaskList)
                        {   
                            //Iterate over failure records
                            if(!dsr.isSuccess())
                            {                
                                Project_Task__c tsk = toUpdateTaskListList[ctr];   
                                String[] arguments = new String[] { tsk.Description__c, dsr.getErrors()[0].getMessage() };
                                    
                                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_TASK_ERROR, arguments) );
                                ApexPages.addMessage(errMsg);
                                hasError = true;                                
                            }
                            ctr++;
                        }
                    }
                    
                    if (hasError)
                    {
                        //this will update hasError in the wrapper to highlight the row and expand it
                        //addErrorInTheWrapper(errorIdsMap);
                        addErrorInInsert(errorIdsMap);
                        Database.rollback(sp);
                        projectMilestone.Id = null;
                    } 
                    else 
                    {
                        isValid = true;
                    }
                }
            }
        } 
        catch (DmlException e)
        {
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
            System.debug('$$$ upsert projectMilestone DmlException: '+e);
        }
    }
    //Phase 2 Rel 1
    //Phase 2 Rel 1
    /*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Update the project activity field of the task
Inputs: TaskActivityWrapper, list of task to update
Returns: List<Project_Task__c>
History
02/10/15      Rey Austral      Created
------------------------------------------------------------*/
    public List<Project_Task__c> changeToUpdateTaskList(Map<String,TaskActivityWrapper> bridgeMap, List<Project_Task__c> toUpdateTaskListlist)
    {
        List<Project_Task__c> updateList = new List<Project_Task__c>();
        
        //iterate the task
        if (!toUpdateTaskListlist.isEmpty())
        {
            for (Project_Task__c p : toUpdateTaskListlist) 
            {
                if (p.External_ID__c != null && p.External_ID__c != '')
                {
                    //get the activity id in the map by using the external id
                    if (bridgeMap.containsKey(p.External_ID__c)) 
                    {
                        TaskActivityWrapper t =  bridgeMap.get(p.External_ID__c);
                        
                        //only add the task in the list if the activity is successfully inserted
                        if (t.isSuccess) 
                        {
                            p.Project_Activity__c = t.ActivityId;
                            updateList.add(p);
                        }
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
    //Phase 2 Rel 1
    //Phase 2 Rel 1
    /*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Highlight the row with an error 
Inputs: list of id with error
Returns: 
History
02/10/15      Rey Austral      Created
------------------------------------------------------------*/
    @TestVisible private void addErrorInInsert(Map<Integer,Integer> errorIdMap)
    {
        //this will update the hasError to highlight the row using css
        //this also expand the activity if the activity has one or more error
        
        Integer activityIndex = 0;
        for (ActivityWrapper act : projectActivityList)
        {
            if (errorIdMap.containsKey(activityIndex))
            {                       
                act.hasError = true;                    
            }
            else
            {
                act.hasError = false;
            }
            activityIndex++;
            for(TaskWrapper tsk : act.projectTask) 
            {
                if (tsk.task.Id == null && act.hasError == false)
                {                       
                    tsk.hasError = true;                    
                }
                else
                {
                    tsk.hasError = false;
                }
            }
        }           
        
    } 
    
    //Phase 2 Rel 1
    /*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Create a new non standard activity and task
Inputs: 
Returns: 
History
02/10/15      Rey Austral      Created
------------------------------------------------------------*/
    public void createNewActivity() 
    {     
        //create a blank record and add in the wrapper
        ActivityWrapper aWrap = new ActivityWrapper();
        
        Datetime currDateTime = Datetime.now();
        //create a temporary id to bridge the activity with the task
        String externalDateTime = currDateTime.format('MMddyyhhmmss');
        String externalId = projectMilestone.Id + externalDateTime + UserInfo.getUserId();
        Project_Activity__c projectActivity = new Project_Activity__c(Milestone__c = projectMilestone.Id, External_ID__c  = externalId);
        aWrap.activity = projectActivity;
        
        //automatically create one task if a new activity is created
        TaskWrapper tWrap = new TaskWrapper();
        Project_Task__c projectTask = new Project_Task__c(External_ID__c  = externalId);
        tWrap.Task = projectTask;
        
        //add the new activity in the main wrapper class
        aWrap.projectTask = new List<TaskWrapper>();
        aWrap.projectTask.add(tWrap);
        projectActivityList.add(aWrap);
        
    }
    //Phase 2 Rel 1
    //Phase 2 Rel 1
    /*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Create a new non standard task only
Inputs: 
Returns: 
History
02/10/15      Rey Austral      Created
------------------------------------------------------------*/
    public void createNewTask() 
    {
        for (ActivityWrapper a: projectActivityList)
        {   
            //find the activity that the new task will be assign
            if (a.activity.External_ID__c == activityExternalId) 
            {
                TaskWrapper tWrap = new TaskWrapper();
                
                //use the external id then add in the main wrapper
                Project_Task__c projectTask = new Project_Task__c(External_ID__c  = activityExternalId);
                projectTask.Project_Activity__c = a.activity.Id;
                tWrap.Task = projectTask;
                
                if (a.projectTask != null && a.projectTask.size() > 0)
                {
                    a.projectTask.add(0,tWrap);
                }
                else
                {
                    a.projectTask.add(tWrap);
                }
                
                break;
            }
        }
        
    }
    //Phase 2 Rel 1
    /*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: delete the specific activity that was created as a new non standard activity
Inputs: 
Returns: 
History
02/10/15      Rey Austral      Created
------------------------------------------------------------*/
    public void deleteNewActivity() 
    {
        Integer index = Integer.valueOf(activityIndex);
        projectActivityList.remove(index);
    }
    
    //Phase 2 Rel 1
    /*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: delete the specific task that was created as a new non standard task
Inputs: 
Returns: 
History
02/10/15      Rey Austral      Created
------------------------------------------------------------*/    
    public void deleteNewTask() 
    {
        for (ActivityWrapper a: projectActivityList)
        {
            //find the activity first 
            if (a.activity.External_ID__c == activityExternalId) 
            {
                //delete the task in the list by using the index
                Integer index = Integer.valueOf(taskIndex);
                a.projectTask.remove(index);
                break;
            }
        }
    }
    //Phase 2 Rel 1
    
    public Boolean checkValidToSave(List<ActivityWrapper> activityList) 
    {
        Boolean result = true;
        if (activityList != null && !activityList.isEmpty())
        {
            for(ActivityWrapper act : activityList)
            {
                if (act.projectTask == null || act.projectTask.isEmpty())
                {
                    String[] arguments = new String[] { act.activity.Description__c };
                        
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.NO_TASK_POPUP, arguments) );
                    ApexPages.addMessage(errMsg);
                    act.hasError = true;
                    result = false;
                }
            }
        }
        else
        {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, IMP_String_Utility.MILESTONE_AT_LEAST_ONE_ACTIVITY );
            ApexPages.addMessage(errMsg);
            result = false;
        }
        return result;
    }
    
    public class ActivityWrapper
    {
        public Project_Activity__c activity { get; set; }
        public List<TaskWrapper> projectTask { get; set; }      
        public Boolean hasError { get; set; }
    } 
    
    public class TaskWrapper
    {
        public Project_Task__c task { get; set; }        
        public Boolean hasError { get; set; }       
    }
    
    public class TaskActivityWrapper
    {
        public Id ActivityId { get; set; }
        public Boolean isSuccess { get; set; }
    }
}