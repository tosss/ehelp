/*------------------------------------------------------------
Author:      Kimiko Roberto
Company:     Cloud Sherpas
Description: Creates rollups for Project Milestones
Inputs:      
Returns:     
History
02/19/15     Kimiko Roberto    Created
10/19/15     Karl Simon        In the createMilestoneRollups  method, added a sum rollup for Total Tasks from Project Activity to Project Milestone.
------------------------------------------------------------*/
public class IMP_BuildMilestoneRollups_Handler
{
    
    public static List<sObject> createMilestoneRollups(List<Project_Activity__c> projectActivityList)
    {
        
        List<sObject> parentList = new List<sObject>();
        
        //create and LREngine context assigning the child object and the parent object that will have the rollup values
        //add filters that will help determine rollup values
        ALL_LREngine.Context ctx = new ALL_LREngine.Context(Project_Milestone__c.SobjectType, // parent object
                                                            Project_Activity__c.SobjectType,  // child object
                                                            Schema.SObjectType.Project_Activity__c.fields.Milestone__c,    // relationship field name
                                                            'Status__c != \'Not Applicable\'' //filter
                                                           ); 
        
        //assign the field that will get the rollup value, field that will be rolled up and rollup operation to be done.                                   
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Milestone__c.fields.Total_Expected_Time_Spent__c,
                Schema.SObjectType.Project_Activity__c.fields.Total_Expected_Time_Spent__c,
                ALL_LREngine.RollupOperation.Sum 
            ));                                         
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Milestone__c.fields.Total_Actual_Time_Spent__c,
                Schema.SObjectType.Project_Activity__c.fields.Total_Actual_Time_Spent__c,
                ALL_LREngine.RollupOperation.Sum 
            ));   
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Milestone__c.fields.Total_Activities_Closed__c,
                Schema.SObjectType.Project_Activity__c.fields.isStatusComplete__c,
                ALL_LREngine.RollupOperation.Sum 
            ));   
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Milestone__c.fields.Actual_Start_Date__c,
                Schema.SObjectType.Project_Activity__c.fields.Actual_Start_Date__c,
                ALL_LREngine.RollupOperation.Min 
            ));    
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Milestone__c.fields.Planned_Start_Date__c,
                Schema.SObjectType.Project_Activity__c.fields.Planned_Start_Date__c,
                ALL_LREngine.RollupOperation.Min 
            ));    
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Milestone__c.fields.Planned_End_Date__c,
                Schema.SObjectType.Project_Activity__c.fields.Planned_End_Date__c,
                ALL_LREngine.RollupOperation.Max 
            ));    
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Milestone__c.fields.Total_Activities__c,
                Schema.SObjectType.Project_Activity__c.fields.isActive__c,
                ALL_LREngine.RollupOperation.Sum 
            ));
        
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Milestone__c.fields.Total_Tasks__c,
                Schema.SObjectType.Project_Activity__c.fields.Total_Tasks__c,
                ALL_LREngine.RollupOperation.Sum 
            ));
        
        
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Milestone__c.fields.Actual_End_Date__c,
                Schema.SObjectType.Project_Activity__c.fields.Actual_End_Date_Final__c,
                ALL_LREngine.RollupOperation.Max 
            ));
        
        
        
        if(projectActivityList != null && !projectActivityList.isEmpty())
        {
            //get the list of parent records and rollup values to be stamped on parent record
            parentList = ALL_LREngine.rollUp(ctx, projectActivityList);
            
            system.debug('parent');
        }   
        return parentList;
    }
    
    public static List<sObject> createExpectedDurationRollup(List<Project_Activity__c> projectActivityList)
    {
        
        List<sObject> parentList = new List<sObject>();
        
        //create and LREngine context assigning the child object and the parent object that will have the rollup values
        //add filters that will help determine rollup values 
        ALL_LREngine.Context ctx = new ALL_LREngine.Context(Project_Milestone__c.SobjectType, // parent object
                                                            Project_Activity__c.SobjectType,  // child object
                                                            Schema.SObjectType.Project_Activity__c.fields.Milestone__c, // relationship field name
                                                            'Status__c != \'Complete\' AND Status__c != \'Not Applicable\''
                                                           ); 
        
        //assign the field that will get the rollup value, field that will be rolled up and rollup operation to be done.                                
        ctx.add(
            new ALL_LREngine.RollupSummaryField(
                Schema.SObjectType.Project_Milestone__c.fields.Expected_Remaining_Duration__c,
                Schema.SObjectType.Project_Activity__c.fields.Expected_Remaining_Duration__c,
                ALL_LREngine.RollupOperation.Sum 
            ));  
        
        
        
        if(projectActivityList != null && !projectActivityList.isEmpty())
        {
            //get the list of parent records and rollup values to be stamped on parent record
            parentList = ALL_LREngine.rollUp(ctx, projectActivityList);             
        }                                    
        return parentList;
    }
    
    public static List<sObject> mergeRollup(List<sObject> milestoneRollupList, List<sObject> expectedDurationList) {
        //Map<Id, sObject> milestoneMap = new Map<id, sObject>(milestoneRollupList);
        Map<Id, sObject> expectedDurationMap = new Map<id, sObject>(expectedDurationList);
        
        List<sObject> mergeList = new List<sObject>();
        for (sObject miles : milestoneRollupList)
        {
            Id milestoneId = (Id)miles.get('Id');
            if (expectedDurationMap.containsKey(milestoneId))
            {                
                sObject milestoneUpdatedExptected = expectedDurationMap.get( milestoneId );
                system.debug('milestone milestoneUpdatedExptected : ' + milestoneUpdatedExptected);
                miles.put('Expected_Remaining_Duration__c',milestoneUpdatedExptected.get('Expected_Remaining_Duration__c') );                
                expectedDurationMap.remove(milestoneId);
                system.debug('milestone expectedDurationMap :' + expectedDurationMap);
            }           
            
            mergeList.add(miles);
        }
        
        if (expectedDurationMap != null && !expectedDurationMap.isEmpty())
        {
            mergeList.addAll(expectedDurationMap.values());
        }
        
        system.debug('milestone mergeList  : ' + mergeList);
        
        return mergeList;
    }
}