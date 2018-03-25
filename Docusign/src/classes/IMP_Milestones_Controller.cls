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
public class IMP_Milestones_Controller 
{
    public Id objectId { get; set; }         
    public Boolean hasPermission { get; set; }
    public Boolean hasAddPermission { get; set; }
    public Decimal milestoneSizeToEdit { get; set; }
    public List<MilestoneWrapper> milestoneContentList { get; set; }
    
    //Phase 2 Rel 1 begin
    public IMP_Milestones_Controller ()
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
        hasAddPermission = true;
        //Check if the user has Create/Add Permission
        if(!IMP_Project_Utility.checkUserPermission('Project_Activity__c', 'PermissionsCreate'))
        {
            hasAddPermission = false;
        }
        
        CustomSettings__c cs = CustomSettings__c.getInstance();
        milestoneSizeToEdit = 4;
        if (cs.Max_Milestone_Threshold__c != null) 
        {
            milestoneSizeToEdit = cs.Max_Milestone_Threshold__c;
        }      
        
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
        //Retrieve related milestones 
        List<Project_Milestone__c> projectMList =  [SELECT Actual_End_Date_Final__c , Actual_Start_Date__c, Comments__c, Risk_Gauge_Color__c, Account__c ,
                                                    External_System_Name__c, Description__c, Planned_End_Date__c, Planned_Start_Date__c, 
                                                    Site__c, Status__c, Id, External_System_ID__c,Standard__c,
                                                    (SELECT Activity_Definition__c,Actual_End_Date_Final__c ,Actual_Start_Date__c,CDK_Assignee__c, External_ID__c,
                                                     CDK_Assignee_Role__c,Client_Assignee__c,Department__c,Description__c,Display_on_PSR__c, Risk_Gauge_Color__c,
                                                     Planned_End_Date__c,Planned_Start_Date__c,Status__c,Terminal_Activity__c,Comments__c,Standard__c  FROM Project_Activities__r Order by Sequence__c NULLS LAST, Planned_Start_Date__c NULLS LAST) 
                                                    FROM Project_Milestone__c where SubProject__c =: objectId  Order by Planned_Start_Date__c NULLS LAST, Planned_End_Date__c NULLS LAST];
        
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
                    
                    
                    //populate the task and add in the activity
                    if (completeTaskMap.containsKey(act.id))
                    {  
                        aWrap.projectTask = completeTaskMap.get(act.id);
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
                    if (act.expandTask == true) 
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
            //search if the expand is already been check
            if (expandIdMap.containsKey(miles.Id)) 
            {
                mWrapper.expandActivity = true;
            }
            
            //it needs to be in a list of string
            mWrapper.projectActivity = new List<ActivityWrapper>();
          
            //populate the activity and add in the milestone
            if (miles.Project_Activities__r != null) 
            {
                for(Project_Activity__c act :  miles.Project_Activities__r) 
                {
                    ActivityWrapper aWrap = new ActivityWrapper();  
                    aWrap.activity  = act;
                    
                    //search if the expand is already been check
                    if (expandIdMap.containsKey(act.Id)) 
                    {
                        aWrap.expandTask = true;
                    }
                    
                   //populate the task and add in the activity
                    if (completeTaskMap.containsKey(act.id))
                    {  
                        aWrap.projectTask = completeTaskMap.get(act.id);
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
        resetWrapperDataOnly( retrieveMilestoneRecords() );
    }
    
    public class MilestoneWrapper
    {
        public Project_Milestone__c projectMilestone { get; set; }  
        public List<ActivityWrapper> projectActivity { get; set; }
        public Boolean expandActivity { get; set; }
    }
    
    public class ActivityWrapper
    {
        public Project_Activity__c activity { get; set; }
        public List<Project_Task__c> projectTask { get; set; }
        public Boolean expandTask { get; set; }
    }
}