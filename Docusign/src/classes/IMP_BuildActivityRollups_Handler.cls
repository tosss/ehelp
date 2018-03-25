/*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Creates rollups for Project Activity
Inputs:      
Returns:     
History
02/19/15     Kimiko Roberto    Created
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
    
    public static List<sObject> mergeRollup(List<sObject> activityRollupList, List<sObject> expectedDurationList) {
        //Map<Id, sObject> activityMap = new Map<id, sObject>(activityRollupList);
        Map<Id, sObject> expectedDurationMap = new Map<id, sObject>(expectedDurationList);
        system.debug('expectedDurationList : ' + expectedDurationList);
        List<sObject> mergeList = new List<sObject>();
        for (sObject act : activityRollupList)
        {
            Id activityId = (Id)act.get('Id');
            if (expectedDurationMap.containsKey(activityId))
            {                
                sObject activityUpdatedExptected = expectedDurationMap.get( activityId );
                system.debug('activityUpdatedExptected : ' + activityUpdatedExptected);
                act.put('Expected_Remaining_Duration__c',activityUpdatedExptected.get('Expected_Remaining_Duration__c') );                
                expectedDurationMap.remove(activityId);
                system.debug('expectedDurationMap :' + expectedDurationMap);
            }           
            
            mergeList.add(act);
        }
        
        if (expectedDurationMap != null && !expectedDurationMap.isEmpty())
        {
            mergeList.addAll(expectedDurationMap.values());
        }
        
        system.debug('mergeList  : ' + mergeList);
        return mergeList;
    }
}