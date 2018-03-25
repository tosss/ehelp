/*------------------------------------------------------------
  Author: Rey Austral
  Company: Cloud Sherpas
  Description: Controller for IMP_Milestone Component
  Test Class:
  History
  10/30/14     Rey Austral      Created
  11/03/14     Rey Austral      Add Update and Delete Function
  12/05/14     Rey Austral      Add Non-standard activity function
  12/24/14     Rey Austral      Add field update
  02/03/15     Rey Austral      Add task
  04/09/15     Rey Austral      Remove the edit function
  ------------------------------------------------------------*/
public class IMP_Milestone_Controller_2015
{
    public Id objectId { get; set; }
    public Boolean hasPermission { get; set; }
    public Boolean hasAddPermission { get; set; }
    public Boolean hasDeletePermission { get; set; }
    public Decimal milestoneSizeToEdit { get; set; }
    public List<MilestoneWrapper> milestoneContentList { get; set; }
    public Boolean toDisplay { get; set; }
    //Phase 2 Rel 1 begin
    public IMP_Milestone_Controller_2015()
    {
        try
        {
            objectId = ApexPages.currentPage().getParameters().get('id');
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, IMP_String_Utility.NO_ASSOCIATE_SUBPROJECT_RECORD));
        }
        hasPermission = true;

        //Check if the user has Edit Permission
        if (!IMP_Project_Utility.checkUserPermission('Project_Milestone__c', 'PermissionsEdit'))
        {
            hasPermission = false;
        }

        //Check if the user has Edit Permission
        if (!IMP_Project_Utility.checkUserPermission('Project_Activity__c', 'PermissionsEdit'))
        {
            hasPermission = false;
        }
        hasAddPermission = true;
        //Check if the user has Create/Add Permission
        if (!IMP_Project_Utility.checkUserPermission('Project_Activity__c', 'PermissionsCreate'))
        {
            hasAddPermission = false;
        }

        hasDeletePermission = true;
        if (!IMP_Project_Utility.checkUserPermission('Project_Task__c', 'PermissionsDelete') ||
            !IMP_Project_Utility.checkUserPermission('Project_Activity__c', 'PermissionsDelete') ||
            !IMP_Project_Utility.checkUserPermission('Project_Milestone__c', 'PermissionsDelete'))
        {
            hasDeletePermission = false;
        }

        CustomSettings__c cs = CustomSettings__c.getInstance();
        milestoneSizeToEdit = 4;
        if (cs.Max_Milestone_Threshold__c != null)
        {
            milestoneSizeToEdit = cs.Max_Milestone_Threshold__c;
        }

        //Retrieve Milestones , Project Activies and Project Task
        resetWrapperDataAndExtensionField(retrieveMilestoneRecords());
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
    public List<Project_Milestone__c> retrieveMilestoneRecords()
    {
        //Retrieve related milestones 
        String milestoneOrderQuery = IMP_Project_Utility.getOrderColumns(SObjectType.Project_Milestone__c.FieldSets.Milestone_Sort_Commons.getFields(), true);
        String activityOrderQuery = IMP_Project_Utility.getOrderColumns(SObjectType.Project_Activity__c.FieldSets.Activity_Sort_Commons.getFields(), true);

        String query = 'SELECT Actual_End_Date__c, Actual_End_Date_Final__c,Actual_Start_Date__c, Comments__c, Risk_Gauge_Color__c, Account__c ,' +
        'Process_Step__c,External_System_Name__c, Description__c, Planned_End_Date__c, Planned_Start_Date__c, ' +
        'Site__c, Status__c, Id, External_System_ID__c,Standard__c,Sort_Sequence__c,' +
        '(SELECT Activity_Definition__c,Actual_End_Date__c,Actual_End_Date_Final__c,Actual_Start_Date__c,CDK_Assignee__c, External_ID__c,' +
        'CDK_Assignee_Role__c,Client_Assignee__c,Department__c,Description__c,Display_on_PSR__c, Risk_Gauge_Color__c,' +
        'Planned_End_Date__c,Planned_Start_Date__c,Status__c,Comments__c,Standard__c,Sequence__c  FROM Project_Activities__r ' + activityOrderQuery + ') ' +
        'FROM Project_Milestone__c where SubProject__c =: objectId  ' + milestoneOrderQuery;

        return Database.query(query);
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
        Map<Id, List<Project_Task__c>> completeTaskMap = new Map<Id, List<Project_Task__c>> ();
        if (objectId != null)
        {
            String subId = objectId;
            subId = subId.substring(0, 15);

            Map<Id, Project_Activity__c> activityMap = new Map<Id, Project_Activity__c> ([Select Id from Project_Activity__c where SubProject_ID__c = :subId]);
            Set<Id> activityIds = activityMap.keySet();

            String taskOrderQuery = IMP_Project_Utility.getOrderColumns(SObjectType.Project_Task__c.FieldSets.Task_Sort_Commons.getFields(), true);

            String query = 'SELECT Project_Activity__c,Task_Definition__c,Actual_End_Date__c,Actual_Start_Date__c,CDK_Assignee__c, External_ID__c, Expected_Time_Spent__c,' +
            'CDK_Assignee_Role__c,Client_Assignee__c,Description__c,Display_on_PSR__c, Actual_Time_Spent__c, Reason__c,  Migration_Status__c, Reason_Missed_Planned_End_Date__c ,' +
            'Planned_End_Date__c,Planned_Start_Date__c,Status__c,Comments__c,Standard__c,Sequence__c  FROM Project_Task__c where Project_Activity__c in : activityIds ' + taskOrderQuery;

            List<Project_Task__c> taskList = Database.query(query);

            //link the activity and the project task
            for (Project_Task__c tsk : taskList)
            {
                if (completeTaskMap.containsKey(tsk.Project_Activity__c))
                {
                    //add the task in the existing activity
                    //this automatically update the value in the completeTaskMap no need to re update the map
                    List<Project_Task__c> tskList = completeTaskMap.get(tsk.Project_Activity__c);
                    tskList.add(tsk);
                }
                else
                {
                    List<Project_Task__c> tskList = new List<Project_Task__c> ();
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
        milestoneContentList = new List<MilestoneWrapper> ();
        for (Project_Milestone__c miles : projectMilestones)
        {
            MilestoneWrapper mWrapper = new MilestoneWrapper();
            mWrapper.projectMilestone = miles;
            //site have a different way to highlight in the field
            //it needs to be in a list of string
            mWrapper.projectActivity = new List<ActivityWrapper> ();

            //populate the activity and add in the milestone
            if (miles.Project_Activities__r != null)
            {
                for (Project_Activity__c act : miles.Project_Activities__r)
                {
                    ActivityWrapper aWrap = new ActivityWrapper();
                    aWrap.activity = act;


                    //populate the task and add in the activity
                    if (completeTaskMap.containsKey(act.id))
                    {
                        List<Project_Task__c> taskList = completeTaskMap.get(act.id);
                        aWrap.projectTask = new List<TaskWrapper> ();
                        for (Project_Task__c t : taskList)
                        {
                            TaskWrapper tWrap = new TaskWrapper();
                            tWrap.task = t;
                            tWrap.toDelete = false;
                            tWrap.hasError = false;
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
        Map<Id, List<Project_Task__c>> completeTaskMap = retrieveTaskRecords();

        //get first the expandActivity  preserve the expand after refresh
        Map<Id, Id> expandIdMap = new Map<Id, Id> ();

        for (MilestoneWrapper miles : milestoneContentList)
        {
            if (miles.expandActivity == true)
            {
                expandIdMap.put(miles.projectMilestone.Id, miles.projectMilestone.Id);
            }

            //get the expand for the activity
            if (miles.projectActivity != null)
            {
                List<ActivityWrapper> activityList = miles.projectActivity;
                for (ActivityWrapper act : activityList)
                {
                    if (act.expandTask == true)
                    {
                        expandIdMap.put(act.activity.Id, act.activity.Id);
                    }
                }
            }
        }

        //populate the record in wrapper
        milestoneContentList = new List<MilestoneWrapper> ();
        for (Project_Milestone__c miles : projectMilestonesList)
        {
            MilestoneWrapper mWrapper = new MilestoneWrapper();
            mWrapper.projectMilestone = miles;
            //search if the expand is already been check
            if (expandIdMap.containsKey(miles.Id))
            {
                mWrapper.expandActivity = true;
            }

            //it needs to be in a list of string
            mWrapper.projectActivity = new List<ActivityWrapper> ();

            //populate the activity and add in the milestone
            if (miles.Project_Activities__r != null)
            {
                for (Project_Activity__c act : miles.Project_Activities__r)
                {
                    ActivityWrapper aWrap = new ActivityWrapper();
                    aWrap.activity = act;

                    //search if the expand is already been check
                    if (expandIdMap.containsKey(act.Id))
                    {
                        aWrap.expandTask = true;
                    }

                    //populate the task and add in the activity
                    if (completeTaskMap.containsKey(act.id))
                    {
                        List<Project_Task__c> taskList = completeTaskMap.get(act.id);
                        aWrap.projectTask = new List<TaskWrapper> ();
                        for (Project_Task__c t : taskList)
                        {
                            TaskWrapper tWrap = new TaskWrapper();
                            tWrap.task = t;
                            tWrap.toDelete = false;
                            tWrap.hasError = false;
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
      Description: Make the view mode change to Edit mode
      Inputs: 
      Returns: 
      History
      10/30/14    Rey Austral      Created
      ------------------------------------------------------------*/
    public void refresh()
    {
        ApexPages.getMessages().clear();
        resetWrapperDataOnly(retrieveMilestoneRecords());
    }
    //5-20-2015 Rey Austral Added Delete Function 
    public void deleteMilestone()
    {
        ApexPages.getMessages().clear();
        List<Project_Milestone__c> toDeleteMilestoneList = new List<Project_Milestone__c> ();
        List<Project_Activity__c> toDeleteActivityList = new List<Project_Activity__c> ();
        List<Project_Task__c> toDeleteTaskList = new List<Project_Task__c> ();


        Map<Id, Id> mapActivityToExpand = new Map<Id, Id> ();
        Boolean hasErrors = false;
        Map<Id, Id> errorIdsMap = new Map<Id, Id> ();
        Map<Id, Id> toDeleteAllIdMap = new Map<Id, Id> ();

        for (MilestoneWrapper miles : milestoneContentList)
        {
            miles.hasError = false;

            //if milestone record is to be deleted, all activity related to that milestone will also be deleted 
            //even if the user did not select the activty                
            if (miles.toDelete == true)
            {
                toDeleteMilestoneList.add(miles.projectMilestone);
                toDeleteAllIdMap.put(miles.projectMilestone.Id, miles.projectMilestone.id);
                List<ActivityWrapper> activityList = miles.projectActivity;
                for (ActivityWrapper act : activityList)
                {
                    toDeleteActivityList.add(act.activity);
                    toDeleteAllIdMap.put(act.activity.Id, act.activity.id);
                    if (act.projectTask != null)
                    {
                        List<TaskWrapper> taskList = act.projectTask;
                        for (TaskWrapper tsk : taskList)
                        {
                            toDeleteTaskList.add(tsk.Task);
                            toDeleteAllIdMap.put(tsk.Task.Id, tsk.Task.id);
                        }
                    }
                }
            }
            else
            {
                List<ActivityWrapper> activityList = miles.projectActivity;

                //there are specific condition to be consider when deleting an activity
                //please check the method for more details
                if (checkIfValidForDeletion(activityList, miles.projectMilestone.Description__c) == true)
                {

                    Boolean hasActivityToDelete = false;
                    for (ActivityWrapper act : activityList)
                    {
                        act.hasError = false;
                        if (act.toDelete == true)
                        {
                            //store the id that will be deleted to a container
                            act.activity.Milestone__r = new Project_Milestone__c();
                            act.activity.Milestone__r.Description__c = miles.projectMilestone.Description__c;
                            act.activity.Milestone__r.Id = miles.projectMilestone.Id;
                            toDeleteActivityList.add(act.activity);
                            toDeleteAllIdMap.put(act.activity.Id, act.activity.id);
                            if (act.projectTask != null)
                            {
                                List<TaskWrapper> taskList = act.projectTask;
                                for (TaskWrapper tsk : taskList)
                                {
                                    toDeleteTaskList.add(tsk.Task);
                                    toDeleteAllIdMap.put(tsk.Task.Id, tsk.Task.id);
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
                                if (checkIfValidForDeletion(taskList, miles.projectMilestone.Description__c, act.activity.Description__c) == true)
                                {
                                    for (TaskWrapper tsk : taskList)
                                    {
                                        tsk.hasError = false;
                                        if (tsk.toDelete == true)
                                        {
                                            toDeleteTaskList.add(tsk.Task);
                                            toDeleteAllIdMap.put(tsk.Task.Id, tsk.Task.id);
                                        }
                                    }
                                }
                                else
                                {
                                    act.hasError = true;
                                    act.expandTask = true;
                                    hasErrors = true;
                                    errorIdsMap.put(act.activity.Id, act.activity.Id);
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
                else
                {
                    //this will highlight the row and expand the activity
                    miles.hasError = true;
                    miles.expandActivity = true;
                    hasErrors = true;
                    errorIdsMap.put(miles.projectMilestone.Id, miles.projectMilestone.Id);
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
                for (Database.DeleteResult dsr : dsrsTaskList)
                {
                    //Iterate over failure records
                    if (!dsr.isSuccess())
                    {
                        Project_Task__c tsk = toDeleteTaskList[ctr];

                        if (!checkDuplicateTriggerError(tsk.Description__c))
                        {
                            String[] arguments = new String[] { tsk.Description__c, dsr.getErrors() [0].getMessage() };
                            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_TASK_ERROR, arguments));
                            ApexPages.addMessage(errMsg);
                        }
                        errorIdsMap.put(tsk.Id, tsk.Id);
                        hasErrors = true;
                    }
                    ctr++;
                }
            }
            catch(Exception ex)
            {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
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
                for (Database.DeleteResult dsr : dsrsActivityList)
                {
                    //Iterate over failure records
                    if (!dsr.isSuccess())
                    {
                        Project_Activity__c act = toDeleteActivityList[ctr];
                        if (!checkDuplicateTriggerError(act.Description__c))
                        {
                            String[] arguments = new String[] { act.Description__c, dsr.getErrors() [0].getMessage() };

                            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_ACTIVITY_ERROR, arguments));
                            ApexPages.addMessage(errMsg);
                        }

                        errorIdsMap.put(act.Id, act.Id);
                        hasErrors = true;
                    }
                    ctr++;
                }
            }
            catch(Exception ex)
            {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
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

                for (Database.DeleteResult dsrM : dsrsMilestoneList)
                {
                    //Iterate over failure records
                    if (!dsrM.isSuccess())
                    {
                        Project_Milestone__c miles = toDeleteMilestoneList[ctrMiles];

                        if (!checkDuplicateTriggerError(miles.Description__c))
                        {
                            String[] arguments = new String[] { miles.Description__c, dsrM.getErrors() [0].getMessage() };

                            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_MILESTONE_ERROR, arguments));
                            ApexPages.addMessage(errMsg);
                        }

                        errorIdsMap.put(miles.Id, miles.Id);
                        hasErrors = true;
                    }
                    ctrMiles++;
                }
            }
            catch(Exception ex)
            {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
                ApexPages.addMessage(errMsg);
                hasErrors = true;
            }

        }

        if (hasErrors == true)
        {
            //highlight row for the milestone and activty with error in deletion
            addErrorInTheWrapper(errorIdsMap, toDeleteAllIdMap);
        }
        else if (hasErrors == false)
        {
            //refresh the record to remove the deleted record in the screen, and expand the activty for the affected milestone
            List<Project_Milestone__c> projectM = retrieveMilestoneRecords();
            resetWrapperDataOnly(projectM);
        }

    }
    //5-20-2015 Rey Austral Added Delete Function 
    @TestVisible private void addErrorInTheWrapper(Map<Id, Id> errorIdMap, Map<Id, Id> toDeleteAllIdMap)
    {
        //this will update the hasError to highlight the row using css
        //this also expand the activity if the activity has one or more error
        if (!errorIdMap.isEmpty())
        {
            List<Integer> milestoneToRemoveFromEditPageList = new List<Integer> ();
            Integer cntMiles = 0;
            for (MilestoneWrapper miles : milestoneContentList)
            {
                if (errorIdMap.containsKey(miles.projectMilestone.Id))
                {
                    miles.hasError = true;
                }
                else if (toDeleteAllIdMap.containsKey(miles.projectMilestone.Id))
                {
                    //store the index of the record that has been successfully deleted in the database
                    miles.toDelete = false;
                    milestoneToRemoveFromEditPageList.add(cntMiles);
                }


                List<Integer> activityToRemoveFromEditPageList = new List<Integer> ();
                List<ActivityWrapper> activityList = miles.projectActivity;
                Integer cntAct = 0;
                for (ActivityWrapper act : activityList)
                {
                    if (errorIdMap.containsKey(act.activity.Id))
                    {
                        act.hasError = true;
                        miles.expandActivity = true;
                    }
                    else if (toDeleteAllIdMap.containsKey(act.activity.Id))
                    {
                        //store the index of the record that has been successfully deleted in the database
                        act.toDelete = false;
                        activityToRemoveFromEditPageList.add(cntAct);
                    }

                    //Only process the task when there are no activity selected
                    if (act.projectTask != null)
                    {
                        List<Integer> taskToRemoveFromEditPageList = new List<Integer> ();
                        List<TaskWrapper> taskList = act.projectTask;
                        Integer cntTask = 0;
                        for (TaskWrapper task : taskList)
                        {

                            if (errorIdMap.containsKey(task.task.Id))
                            {
                                task.hasError = true;
                                miles.expandActivity = true;
                            }
                            else if (toDeleteAllIdMap.containsKey(task.task.Id))
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
                            for (Integer indexTask = taskToRemoveFromEditPageList.size() - 1; indexTask >= 0; indexTask--)
                            {
                                taskList.remove(taskToRemoveFromEditPageList[indexTask]);
                            }
                        }
                    }

                    cntAct++;

                }
                if (activityToRemoveFromEditPageList.size() > 0)
                {
                    //iterate the list to remove the deleted activity record in the activity wrapper class
                    activityToRemoveFromEditPageList.sort();
                    for (Integer indexAct = activityToRemoveFromEditPageList.size() - 1; indexAct >= 0; indexAct--)
                    {
                        activityList.remove(activityToRemoveFromEditPageList[indexAct]);
                    }
                }

                cntMiles++;
            }
            if (milestoneToRemoveFromEditPageList.size() > 0)
            {
                //iterate the list to remove the deleted milestone record in the milestone wrapper class\
                milestoneToRemoveFromEditPageList.sort();
                for (Integer indexMiles = milestoneToRemoveFromEditPageList.size() - 1; indexMiles >= 0; indexMiles--)
                {
                    milestoneContentList.remove(milestoneToRemoveFromEditPageList[indexMiles]);
                }
            }
        }
    }

    @TestVisible private Boolean checkIfValidForDeletion(List<ActivityWrapper> activityList, String MilestoneDescription)
    {
        Boolean result = true;
        Integer ctr = 0;
        Boolean haveTerminal = false;
        for (ActivityWrapper act : activityList)
        {
            //count the number of record that will be deleted
            if (act.toDelete == true)
            {
                ctr++;
            }

        }

        String[] arguments = new String[] { MilestoneDescription };
        if (activityList.size() == ctr)
        {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DELETE_TERMINAL_ACTIVITY, arguments));
            ApexPages.addMessage(errMsg);
            result = false;
        }

        return result;
    }

    @TestVisible private Boolean checkIfValidForDeletion(List<TaskWrapper> taskList, String MilestoneDescription, String ActivityDescription)
    {
        Boolean result = true;
        Integer ctr = 0;
        Boolean haveTerminal = false;

        for (TaskWrapper tsk : taskList)
        {
            //count the number of record that will be deleted
            if (tsk.toDelete == true)
            {
                ctr++;
            }
        }

        String[] arguments = new String[] { MilestoneDescription, ActivityDescription };
        if (taskList.size() == ctr)
        {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DELETE_TERMINAL_TASK, arguments));
            ApexPages.addMessage(errMsg);
            result = false;
        }

        return result;
    }

    public Boolean checkDuplicateTriggerError(String description)
    {
        Boolean result = false;
        List<Apexpages.Message> errorMessagesList = ApexPages.getMessages();

        if (errorMessagesList != null)
        {
            for (Apexpages.Message msg : errorMessagesList)
            {
                String[] arguments = new String[] { description };
                String errMilestone = String.format(IMP_String_Utility.NO_BYPASS_TODELETE_ACTIVITY, arguments);
                String errActivity = String.format(IMP_String_Utility.NO_BYPASS_TODELETE_MILESTONE, arguments);
                String errTask = String.format(IMP_String_Utility.NO_BYPASS_TODELETE_TASK, arguments);

                if (msg.getDetail() == errMilestone ||
                    msg.getDetail() == errActivity ||
                    msg.getDetail() == errTask)
                {
                    result = true;
                }
            }
        }
        return result;
    }
    //2015-8-3 Rey Austral - This method is used to highlight the error in the list
    public void updateAllDisplayPSR()
    {
        ApexPages.getMessages().clear();
        List<Project_Milestone__c> toUpdateMilestoneList = new List<Project_Milestone__c> ();
        List<Project_Activity__c> toUpdateActivityList = new List<Project_Activity__c> ();
        List<Project_Task__c> toUpdateTaskList = new List<Project_Task__c> ();
        Boolean hasError = false;
        //Update all Display_on_PSR__c field in Milestone,Activity And Task Record
        //Iterate all the milestone in the wrapper class
        for (MilestoneWrapper miles : milestoneContentList)
        {
            miles.hasError = false;
            //Update Display_on_PSR__c based on the button that the user click
            miles.projectMilestone.Display_on_PSR__c = toDisplay;
            //add the milestone record in the list to update
            toUpdateMilestoneList.add(miles.projectMilestone);
            //get the activity in the currrent milestone
            List<ActivityWrapper> activityList = miles.projectActivity;
            for (ActivityWrapper act : activityList)
            {
                //Update Display_on_PSR__c based on the button that the user click
                act.activity.Display_on_PSR__c = toDisplay;
                //add the activity record in the list to update
                toUpdateActivityList.add(act.activity);
                if (act.projectTask != null)
                {
                    //get the task in the currrent activity
                    List<TaskWrapper> taskList = act.projectTask;
                    for (TaskWrapper tsk : taskList)
                    {
                        tsk.Task.Display_on_PSR__c = toDisplay;
                        toUpdateTaskList.add(tsk.Task);
                    }
                }
            }
        }
        Map<Id, Id> errorIdsMap = new Map<Id, Id> ();
        if (!toUpdateMilestoneList.isEmpty())
        {
            List<Database.SaveResult> dsrsMilestoneList = Database.Update(toUpdateMilestoneList, false);
            Integer ctrMiles = 0;

            //get all the id of the error milestone and activity to be used in hightlighting the row
            for (Database.SaveResult dsrM : dsrsMilestoneList)
            {
                //Iterate over failure records
                if (!dsrM.isSuccess())
                {
                    Project_Milestone__c miles = toUpdateMilestoneList[ctrMiles];
                    String[] arguments = new String[] { miles.Description__c, dsrM.getErrors() [0].getMessage() };

                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_MILESTONE_ERROR, arguments));
                    ApexPages.addMessage(errMsg);
                    hasError = true;
                    errorIdsMap.put(miles.Id, miles.Id);
                }
                ctrMiles++;
            }

        }
        if (!toUpdateActivityList.isEmpty())
        {
            List<Database.UpsertResult> dursActivityList = Database.Upsert(toUpdateActivityList, false);
            Integer ctr = 0;

            for (Database.UpsertResult dsr : dursActivityList)
            {
                //Iterate over failure records
                Project_Activity__c act = toUpdateActivityList[ctr];
                if (!dsr.isSuccess())
                {
                    String[] arguments = new String[] { act.Milestone__r.Description__c, act.Description__c, dsr.getErrors() [0].getMessage() };

                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_ACTIVITY_ERROR, arguments));
                    ApexPages.addMessage(errMsg);
                    hasError = true;
                    errorIdsMap.put(act.Id, act.Id);
                }

                ctr++;
            }
        }
        if (!toUpdateTaskList.isEmpty())
        {
            List<Database.UpsertResult> dsrsTaskList = Database.Upsert(toUpdateTaskList, false);
            Integer ctr = 0;
            for (Database.UpsertResult dsr : dsrsTaskList)
            {
                //Iterate over failure records
                if (!dsr.isSuccess())
                {
                    Project_Task__c tsk = toUpdateTaskList[ctr];
                    String[] arguments = new String[] { tsk.Description__c, dsr.getErrors() [0].getMessage() };

                    ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, String.format(IMP_String_Utility.DML_TASK_ERROR, arguments));
                    ApexPages.addMessage(errMsg);
                    hasError = true;
                    errorIdsMap.put(tsk.Id, tsk.Id);
                }
                ctr++;
            }
        }

        if (!errorIdsMap.isEmpty())
        {
            //this will update hasError in the wrapper to highlight the row and expand it 
            addErrorInUpdate(errorIdsMap);
        }
    }
    //2015-8-3 Rey Austral - This method is used to highlight the error in the list
    @TestVisible private void addErrorInUpdate(Map<Id, Id> errorIdMap)
    {
        //this will update the hasError to highlight the row using css
        //this also expand the activity if the activity has one or more error
        if (!errorIdMap.isEmpty())
        {
            for (MilestoneWrapper miles : milestoneContentList)
            {
                if (errorIdMap.containsKey(miles.projectMilestone.Id))
                {
                    miles.hasError = true;
                }
                List<ActivityWrapper> activityList = miles.projectActivity;
                for (ActivityWrapper act : activityList)
                {
                    if (errorIdMap.containsKey(act.activity.Id))
                    {
                        act.hasError = true;
                        miles.expandActivity = true;
                    }

                    if (act.projectTask != null)
                    {
                        List<TaskWrapper> taskList = act.projectTask;
                        for (TaskWrapper task : taskList)
                        {
                            if (errorIdMap.containsKey(task.task.Id))
                            {
                                task.hasError = true;
                                miles.expandActivity = true;
                                act.expandTask = true;
                            }
                        }
                    }
                }
            }
        }
    }

    public class MilestoneWrapper
    {
        public Project_Milestone__c projectMilestone { get; set; }
        public List<ActivityWrapper> projectActivity { get; set; }
        public Boolean expandActivity { get; set; }
        public Boolean toDelete { get; set; }
        public Boolean hasError { get; set; }
    }

    public class ActivityWrapper
    {
        public Project_Activity__c activity { get; set; }
        public List<TaskWrapper> projectTask { get; set; }
        public Boolean toDelete { get; set; }
        public Boolean expandTask { get; set; }
        public Boolean hasError { get; set; }
    }

    public class TaskWrapper
    {
        public Project_Task__c task { get; set; }
        public Boolean toDelete { get; set; }
        public Boolean hasError { get; set; }
    }
}