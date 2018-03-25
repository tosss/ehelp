//2015-01-05- venkata.shrivol@cdk.com- Created class IMP_UpdCDKAssigneeOnTaskActivty_Handler For RQ-05996 Update CDK assignee on Tasks and Activities from SubProject.
//2016-03-03- anirudh.singh@cdk.com- Created this class as the earlier class IMP_UpdCDKAssigneeOnTaskActivty_Handler was not following naming standards.
//2016-03-03- anirudh.singh@cdk.com- Modified this class for Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
public class IMP_UpdCDKAssigneeOnTaskActivity_Handler
{
    public static void updateTasksAndActivities(Map<Id, SubProject__c> subProjectMap)
    {
        system.debug('Start updateTasksAndActivities---->');
        
        List<Project_Task__c> projectTasksList=new List<Project_Task__c>();
        Map<Id, Project_Activity__c> projectActivitiesMap=new Map<Id, Project_Activity__c>();
        
        for(Project_Task__c projectTaskRecord: [
            SELECT CDK_Assignee_Role__c, Description__c, CDK_Assignee__c, SubProject_ID__c,
            Project_Activity__c, Project_Activity__r.CDK_Assignee__c 
            FROM Project_Task__c 
            WHERE Project_Activity__r.Milestone__r.SubProject__c IN : subProjectMap.keySet()
            AND CDK_Assignee_Role__c IN ('Utilization & Training Project Manager', 'Training & Implementation Client Manager')
            AND Status__c != 'Complete'
            AND RMS_Owned_Flag__c=false 
            AND Project_Activity__r.RMS_Owned_Flag__c=false
        ])
        {
            system.debug('projectTaskRecord---->'+projectTaskRecord);
            Project_Activity__c projectActivityRecord=new Project_Activity__c(Id=projectTaskRecord.Project_Activity__c, CDK_Assignee_Role__c=projectTaskRecord.CDK_Assignee_Role__c);
            
            if(projectTaskRecord.CDK_Assignee_Role__c =='Utilization & Training Project Manager')
            {
                projectTaskRecord.CDK_Assignee__c=subProjectMap.get(projectTaskRecord.SubProject_ID__c).Project_Manager__c;
                projectTasksList.add(projectTaskRecord);
                
                //This null check is to avoid the new activities that will prevent an exception at below update call.
                if(projectActivityRecord.Id!=null && !projectActivitiesMap.containsKey(projectActivityRecord.Id))
                {
                    projectActivityRecord.CDK_Assignee__c=subProjectMap.get(projectTaskRecord.SubProject_ID__c).Project_Manager__c;
                    projectActivitiesMap.put(projectActivityRecord.Id, projectActivityRecord);
                }
            }
            else
            {
                projectTaskRecord.CDK_Assignee__c=subProjectMap.get(projectTaskRecord.SubProject_ID__c).Training_Implementation_Client_Mgr__c;
                projectTasksList.add(projectTaskRecord);
                
                if(projectActivityRecord.Id!=null && !projectActivitiesMap.containsKey(projectActivityRecord.Id))
                {
                    projectActivityRecord.CDK_Assignee__c=subProjectMap.get(projectTaskRecord.SubProject_ID__c).Training_Implementation_Client_Mgr__c;
                    projectActivitiesMap.put(projectActivityRecord.Id, projectActivityRecord);
                }
            }
        }
        
        try
        {
            update projectActivitiesMap.values();
            
            update projectTasksList;  
        }
        catch(Exception ex)
        {
            system.debug('Exception---->'+ex);
        }
        
        system.debug('End updateTasksAndActivities---->');
    }
}