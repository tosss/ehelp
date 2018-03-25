/*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Creates rollups for Project Activity
Inputs:      
Returns:     
History
02/19/15     Kimiko Roberto    Created
03/24/2016   ragashalini.koka@cdk.com  Added planned start date and planned end date to rollup
                                       Modified mergeRollup method to accept the changes done on any field
                                       Added createCDKAssgineeRollUp method to rollup changes on CDKAssginee
------------------------------------------------------------*/
public class IMP_BuildActivityRollups_Handler
{
    public static List<sObject> createActivityRollups(List<Project_Task__c> projectTaskList)
    {    
        List<sObject> parentList = new List<sObject>();
        
        //create and LREngine context assigning the child object and the parent object that will have the rollup values
        //add filters that will help determine rollup values
        ALL_LREngine.Context ctx = new ALL_LREngine.Context(Project_Activity__c.SobjectType, // parent object
                                                            Project_Task__c.SobjectType,  // child object
                                                            Schema.SObjectType.Project_Task__c.fields.Project_Activity__c,    // relationship field name
                                                            'Status__c != \'Not Applicable\''    //filter
                                                           ); 
        
        //assign the field that will get the rollup value, field that will be rolled up and rollup operation to be done.                                
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Activity__c.fields.Total_Expected_Time_Spent__c,
                Schema.SObjectType.Project_Task__c.fields.Expected_Time_Spent__c,
                ALL_LREngine.RollupOperation.Sum 
            ));                                         
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Activity__c.fields.Total_Actual_Time_Spent__c,
                Schema.SObjectType.Project_Task__c.fields.Actual_Time_Spent__c,
                ALL_LREngine.RollupOperation.Sum 
            ));   
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Activity__c.fields.Actual_Start_Date__c,
                Schema.SObjectType.Project_Task__c.fields.Actual_Start_Date__c,
                ALL_LREngine.RollupOperation.Min 
            ));  
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Activity__c.fields.Actual_End_Date__c,
                Schema.SObjectType.Project_Task__c.fields.Actual_End_Date__c,
                ALL_LREngine.RollupOperation.Max 
            ));
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Activity__c.fields.Total_Tasks_Closed__c,
                Schema.SObjectType.Project_Task__c.fields.isStatusComplete__c,
                ALL_LREngine.RollupOperation.Sum 
            ));
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Activity__c.fields.Total_Tasks__c,
                Schema.SObjectType.Project_Task__c.fields.isActive__c,
                ALL_LREngine.RollupOperation.Sum 
            )); 
        
        ctx.add(new ALL_LREngine.RollupSummaryField(
            Schema.SObjectType.Project_Activity__c.fields.Planned_Start_Date__c,
            Schema.SObjectType.Project_Task__c.fields.Planned_Start_Date__c,
            ALL_LREngine.RollupOperation.Min
        ));
        ctx.add(new ALL_LREngine.RollupSummaryField(
            Schema.SObjectType.Project_Activity__c.fields.Planned_End_Date__c,
            Schema.SObjectType.Project_Task__c.fields.Planned_End_Date__c,
            All_LREngine.RollupOperation.Max
        ));
        
        
        
        //get the list of parent records and rollup values to be stamped on parent record
        if(projectTaskList != null && !projectTaskList.isEmpty())
        {
            //get the list of parent records and rollup values to be stamped on parent record
            parentList = ALL_LREngine.rollUp(ctx, projectTaskList);            
        }  
        return parentList;
        
    }
    
    public static List<sObject> createExpectedDurationRollup(List<Project_Task__c> projectTaskList)
    {
        
        List<sObject> parentList2 = new List<sObject>();
        
        //create and LREngine context assigning the child object and the parent object that will have the rollup values
        //add filters that will help determine rollup values
        ALL_LREngine.Context ctx = new ALL_LREngine.Context(Project_Activity__c.SobjectType, // parent object
                                                            Project_Task__c.SobjectType,  // child object
                                                            Schema.SObjectType.Project_Task__c.fields.Project_Activity__c,   // relationship field name
                                                            //'Status__c != \'Complete\''
                                                            'Status__c != \'Not Applicable\' AND Status__c != \'Complete\''    //filter
                                                           );
        
        //assign the field that will get the rollup value, field that will be rolled up and rollup operation to be done.    
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Activity__c.fields.Expected_Remaining_Duration__c,
                Schema.SObjectType.Project_Task__c.fields.Expected_Time_Spent__c,
                ALL_LREngine.RollupOperation.Sum 
            ));  
        
        if(projectTaskList != null && !projectTaskList.isEmpty())
        {
            System.debug('createExpectedDurationRollup projectTaskList :' + projectTaskList);
            //get the list of parent records and rollup values to be stamped on parent record
            parentList2 = ALL_LREngine.rollUp(ctx, projectTaskList);     
            system.debug('parentList $$ : ' + parentList2);
        }
        return parentList2;
    }  
    
    //finds the task which is updated recently with CDK Assignee value for given set of activitites and rollsup the CDKAssignee
    public static List<SObject> createCDKAssgineeRollUp(Set<Id> projectActivityIdSet) {
        List<SObject> activityList = new List<SObject>();
        
        if(projectActivityIdSet.size() > 0) {
            
            activityList = [
                SELECT Id, CDK_Assignee__c,
                (
                    SELECT CDK_Assignee__c 
                    FROM Project_Tasks__r 
                    WHERE CDK_Assignee__c != NULL 
                    ORDER BY LastModifiedDate desc LIMIT 1
                )
                FROM Project_Activity__c 
                WHERE Id IN :projectActivityIdSet
            ];
            
            for(SObject activity : activityList ) {
                for(SObject prjTask : activity.getSObjects('Project_Tasks__r')) {
                    activity.put('CDK_Assignee__c', prjTask.get('CDK_Assignee__c'));
                }
            }
            
        }
        
        return activityList;
    }
    
    public static List<sObject> mergeRollup(List<sObject> activityRollupList, List<sObject> newactivityRollupList,String fieldAPIName) {
        //Map<Id, sObject> activityMap = new Map<id, sObject>(activityRollupList);
        Map<Id, sObject> newactivityRollupMap = new Map<id, sObject>(newactivityRollupList);
        system.debug('newactivityRollupList : ' + newactivityRollupList);
        List<sObject> mergeList = new List<sObject>();
        for (sObject act : activityRollupList)
        {
            Id activityId = (Id)act.get('Id');
            if (newactivityRollupMap.containsKey(activityId))
            {                
                sObject activityUpdatedExptected = newactivityRollupMap.get( activityId );
                system.debug('activityUpdatedExptected : ' + activityUpdatedExptected);
                act.put(fieldAPIName,activityUpdatedExptected.get(fieldAPIName) );                
                newactivityRollupMap.remove(activityId);
                system.debug('newactivityRollupMap :' + newactivityRollupMap);
            }           
            
            mergeList.add(act);
        }
        
        if (newactivityRollupMap != null && !newactivityRollupMap.isEmpty())
        {
            mergeList.addAll(newactivityRollupMap.values());
        }
        
        system.debug('mergeList  : ' + mergeList);
        return mergeList;
    }
}