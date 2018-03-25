/*------------------------------------------------------------
Author: Rey Austral
Company: Cloud Sherpas
Description: Rolldown value from Activity to Task
Test Class:
History
06/19/15	Rey Austral			Created
------------------------------------------------------------*/
public class IMP_CascadetoChild_Handler {
    public static void cascadeAssignee(Map<Id,Project_Activity__c> activityListMap)
    {
        List<Project_Task__c> taskList = [Select Id, CDK_Assignee__c,Project_Activity__c,Client_Assignee__c from Project_Task__c where Project_Activity__c IN: activityListMap.keySet() and Status__c != 'Not Applicable'];
        system.debug(taskList);
        for (Project_Task__c tsk : taskList)
        {
            if (activityListMap.containsKey(tsk.Project_Activity__c))
            { 
                Project_Activity__c act = activityListMap.get(tsk.Project_Activity__c);
                if (tsk.CDK_Assignee__c == null)
                {
                    system.debug('tsk.CDK_Assignee__c == null');
                    tsk.CDK_Assignee__c = act.CDK_Assignee__c;
                }                
                
                if (tsk.Client_Assignee__c == null)
                {
                    system.debug('tsk.Client_Assignee__c');
                    tsk.Client_Assignee__c = act.Client_Assignee__c;
                }
            }          
        }
        
        try
        {
            update taskList;
        }
        catch(Exception ex)
        {
            System.debug('$$IMP_CascadetoChild_Handler ' + ex.getMessage());
        }
    }
}