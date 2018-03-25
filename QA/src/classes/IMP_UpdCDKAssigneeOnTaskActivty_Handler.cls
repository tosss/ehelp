/*--------------------------------------------------------------
//RQ-05996 Update CDK assignee on Tasks and Activities from SubProject

//2015-01-05  -venkata.shrivol@cdk.com  -Created 
----------------------------------------------------------------*/
//2016-03-11- anirudh.singh@cdk.com- Commented this class due to naming standards issue.
//2016-03-11- anirudh.singh@cdk.com- Created a new class with the name IMP_UpdCDKAssigneeOnTaskActivity_Handler. To be deleted after deployment.
public with sharing class IMP_UpdCDKAssigneeOnTaskActivty_Handler 
{
    /*public static void updateTasksAndActivities(map<Id, SubProject__c> inputSubProjMap)
    {
        list<Project_Task__c> tasksToUpdate = new list<Project_Task__c>();
        map<Id, Project_Activity__c> activitiesToUpdateMap = new map<Id, Project_Activity__c>();
        for(Project_Task__c ptask: [
            select CDK_Assignee_Role__c,CDK_Assignee__c,SubProject_ID__c,
            Project_Activity__c, Project_Activity__r.CDK_Assignee__c 
            from Project_Task__c 
            where Project_Activity__r.Milestone__r.SubProject__c IN : inputSubProjMap.keySet()
            and CDK_Assignee_Role__c IN ('Utilization & Training Project Manager', 'Training & Implementation Client Manager')
            and Status__c != 'Complete'
            ])
        {
            
             Project_Activity__c pactivity = new Project_Activity__c(Id=ptask.Project_Activity__c, CDK_Assignee_Role__c=ptask.CDK_Assignee_Role__c);
             if(ptask.CDK_Assignee_Role__c =='Utilization & Training Project Manager')
             {
                ptask.CDK_Assignee__c = inputSubProjMap.get(ptask.SubProject_ID__c).Project_Manager__c;
                tasksToUpdate.add(ptask);
                //This null check is to avoid the new activities that will prevent an exception at below update call.
                if(pactivity.Id!=null && !activitiesToUpdateMap.containsKey(pactivity.Id))
                {
                    pactivity.CDK_Assignee__c = inputSubProjMap.get(ptask.SubProject_ID__c).Project_Manager__c;
                    activitiesToUpdateMap.put(pactivity.Id, pactivity);
                }
             }
             else
             {
                ptask.CDK_Assignee__c = inputSubProjMap.get(ptask.SubProject_ID__c).Training_Implementation_Client_Mgr__c;
                tasksToUpdate.add(ptask);
                if(pactivity.Id!=null && !activitiesToUpdateMap.containsKey(pactivity.Id))
                {
                    pactivity.CDK_Assignee__c = inputSubProjMap.get(ptask.SubProject_ID__c).Training_Implementation_Client_Mgr__c;
                    activitiesToUpdateMap.put(pactivity.Id, pactivity);
                }
             }
        }
        
        try{
            //activities to update first
            update activitiesToUpdateMap.values();
            
            //tasks to update first
            update tasksToUpdate;  
        }
        catch(Exception ex){
            system.debug('----Exception----'+ex);
        }   
    }*/
}