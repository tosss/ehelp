/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Consolidated Project Activity triggers
Test Class:
History
10/20/14    Michael Lasala      Created
10/28/14    Samuel Oberes       Added IMP_ProjectActivityContacts_Handler.beforeDeleteValues and IMP_ProjectActivityContacts_Handler.createOrUpdateContacts
11/06/14    Samuel Oberes       Refactored: Removed IMP_IncrementActivityCounter_Handler.IncrementCounterField from the BEFORE UPDATE context because the same method is 
being called against the same Project Activity object in the same context, but on a different trigger (IMP_IncrementActivityDelayedCounterField)
11/13/14    Samuel Oberes       Added IMP_IncrementActivityOrMilestone_Handler.IncrementCounterField in the before update context, relocating from the now inactive, soon to be deleted, IMP_IncrementActivityDelayedCounterField
03/13/15    Kimiko Roberto      Updated trigger structure to have proper filters for calling methods
04/01/15    Rey Austral          Set expected remaining duration to 0 if status is complete
04/15/15    Kimiko Roberto      Rearranged logic to process rollups first before ending terminal tasks/activities
05/06/15    Samuel Oberes       1) Added business rules exclusion logic 
2) Added invocation of error whenever a completed activity is attempted to be deleted
05/12/15    Samuel Oberes       Added Project_ID__c and SubProject_ID__c for the query in the AFTER INSERT and UPDATE context
05/13/15    Kimiko Robert       Added filters for programmatic rollup's if block filters
06/10/15	Rey Austral			Added merge function for the rollup
06/11/15	Rey Austral			Add the merge function for the rollup in the is after delete
06/17/15	Rey Austral			Remove IMP_PostFeedToAsignee_Handler
06/19/15	Rey Austral			Add roll down function
------------------------------------------------------------*/
trigger IMP_ProjectActivity on Project_Activity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    
    if (Trigger.isBefore) 
    {
        CustomSettings__c cs = CustomSettings__c.getInstance();
        Boolean currentUserIsExcludedFromRules = false;
        
        if (cs.Users_Excluded_from_Business_Rules__c != null) 
        {
            if (cs.Users_Excluded_from_Business_Rules__c.contains(UserInfo.getName()))
            {
                currentUserIsExcludedFromRules = true;
            }
        }
        
        if(Trigger.isInsert)
        {
            
        } 
        else if(Trigger.isUpdate)
        {
           Map<Id,Project_Activity__c> projectActivitiesNowWithAssigneeMap = new Map<Id,Project_Activity__c>();
            // IMP_IncrementActivityOrMilestone_Handler.IncrementCounterField(Trigger.oldMap, Trigger.New);
            //Iterate the new and old value 
            for(Project_Activity__c pa: Trigger.newMap.values())
            {
                if (Trigger.oldMap.containsKey(pa.id)) 
                {
                    Project_Activity__c paOld = Trigger.oldMap.get(pa.id);
                    
                    //check if the status has been change from different value to complete
                    if (paOld.Status__c != IMP_Project_Utility.STATUS_COMPLETE && pa.Status__c ==  IMP_Project_Utility.STATUS_COMPLETE)
                    {                      
                        IMP_Project_Utility.assignIntegerFieldValue('Expected_Remaining_Duration__c',pa,0);         
                    }
                    
                    //06-19-2015 roll down function
                    if ( (paOld.CDK_Assignee__c == null && pa.CDK_Assignee__c != null) || (paOld.Client_Assignee__c == null && pa.Client_Assignee__c != null) )
                    {
                        system.debug('test here');
                        projectActivitiesNowWithAssigneeMap.put(pa.id, pa);
                    }
                }
            }
            //06-19-2015 roll down function for cdk Assignee
            system.debug('projectActivitiesNowWithCDKAssigneeMap ' + projectActivitiesNowWithAssigneeMap);
            if (projectActivitiesNowWithAssigneeMap != null && !projectActivitiesNowWithAssigneeMap.isEmpty())
            {
                IMP_CascadetoChild_Handler.cascadeAssignee(projectActivitiesNowWithAssigneeMap);
            }
            
        } 
        else if(Trigger.isDelete)
        {
            
            
            /*commented to test generic handler IMP_ProjectActivityContacts_Handler_2
            IMP_ProjectActivityContacts_Handler.beforeDeleteValues = [SELECT Id, CDK_Assignee__c, Client_Assignee__c, Milestone__r.Subproject__c
            FROM Project_Activity__c 
            WHERE Id IN :Trigger.Old];
            */
                        //for removal
                        /*
            IMP_ProjectActivityContacts_Handler_2.beforeDeleteValues = [SELECT Id, CDK_Assignee__c, Client_Assignee__c, Milestone__r.Subproject__c
            FROM Project_Activity__c 
            WHERE Id IN :Trigger.Old];
            
            */
            
            for(Project_Activity__c activityToDelete : Trigger.oldMap.values())
            {
                if (activityToDelete.Status__c == IMP_Project_Utility.STATUS_COMPLETE && currentUserIsExcludedFromRules == false)
                {
                    String[] arguments = new String[] { activityToDelete.Description__c };                                                  
                    activityToDelete.addError(String.format(IMP_String_Utility.NO_BYPASS_TODELETE_ACTIVITY, arguments));
                }
            }
            
        }
        
    }
    else if (Trigger.isAfter) 
    {
        //List<Project_Activity__c> objects = new List<Project_Activity__c>();
        List<Project_Activity__c> expectedDurationRollupsList = new List<Project_Activity__c>();
        List<Project_Activity__c> milestoneRollupsList = new List<Project_Activity__c>();
        
        /*commented to test generic handler IMP_ProjectActivityContacts_Handler_2
        IMP_ProjectActivityContacts_Handler.createOrUpdateContacts(Trigger.oldMap, Trigger.old, Trigger.New, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete);
        */
                /*for removal 
        IMP_ProjectActivityContacts_Handler_2.createOrUpdateContacts(Trigger.oldMap, Trigger.old, Trigger.New, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Project_Activity__c.SObjectType);
        */
                // ------------------------------------------------------------------------------------------------------------------------
                // ------------------------------------------------------------------------------------------------------------------------
                /*
        Map<Id, Date> milestoneActualEndDateMap = new Map<Id, Date>();
        Set<Id> milestonesToEndSet = new Set<Id>();
        
        if(Trigger.isInsert || Trigger.isUpdate)
        {
        
        for(Project_Activity__c pa: Trigger.New)
        {
        
        //Only process records for Terminal Activity = true and Actual End Date != null
        if(pa.Terminal_Activity__c && pa.Actual_End_Date__c != null)
        {
        
        //Put key and values to map to be used for handler
        milestoneActualEndDateMap.put(pa.Milestone__c, pa.Actual_End_Date__c);
        
        //Add Project Milestone Id to be used for query
        milestonesToEndSet.add(pa.Milestone__c);
        }
        }
        }
        */
        
        if(Trigger.isInsert)
        {
            //collect the newly assigned users from the project activity
            List<Project_Activity__c> prjActList = [SELECT Id,
                                                    Description__c,
                                                    Planned_Start_Date__c,
                                                    Planned_End_Date__c,
                                                    SubProject_ID__c,
                                                    Project_ID__c,
                                                    CDK_Assignee__c,
                                                    CDK_Assignee__r.Name
                                                    FROM Project_Activity__c
                                                    WHERE CDK_Assignee__c != null
                                                    AND Id IN : Trigger.New];
            Set<Id> subprj = new Set<Id>();
            //get the Subproject id from the project activity to be able to set them as followers
            for(Project_Activity__c prj : prjActList)
            {
                subprj.add(prj.SubProject_ID__c);
            }
            
            //post a feed to the asignee and add him as a follower to the project and subproject if still not following
            //disable post feed function UAT-272 - Rey Austral
            //if(prjActList != null && !prjActList.isEmpty())
            //{
            //    IMP_PostFeedToAsignee_Handler.postToChatterFeed(prjActList , null, subprj );
            //}
            
            
            for(Project_Activity__c prjAct : Trigger.New)
            {
                if((prjAct.Total_Expected_Time_Spent__c != null && prjAct.Total_Expected_Time_Spent__c != 0) || 
                   (prjAct.Total_Actual_Time_Spent__c != null && prjAct.Total_Actual_Time_Spent__c != 0)     ||
                   (prjAct.Actual_Start_Date__c != null)    || 
                   (prjAct.Planned_Start_Date__c!=null)     ||
                   (prjAct.Planned_End_Date__c!=null)      ||
                   (prjAct.Actual_End_Date__c != null))
                {
                    milestoneRollupsList.add(prjAct);
                }
                
                if(prjAct.Expected_Remaining_Duration__c != null && prjAct.Expected_Remaining_Duration__c != 0)
                {
                    expectedDurationRollupsList.add(prjAct);
                }
            }
   
            List<sObject> milestoneToUpdateList = new List<sObject>();
            List<sObject> milestoneExpectedDurationList = new List<sObject>();
            if(milestoneRollupsList  != null && !milestoneRollupsList.isEmpty())
            {
                //IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList);    
                milestoneToUpdateList = IMP_BuildMilestoneRollups_Handler.createMilestoneRollups(milestoneRollupsList);    
            }
            
            if(expectedDurationRollupsList != null && !expectedDurationRollupsList.isEmpty())
            {    
                //IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
                milestoneExpectedDurationList = IMP_BuildMilestoneRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
            }
            
            List<sObject> milestoneToUpdateFinalList = new List<sObject>();
            if(milestoneToUpdateList  != null && !milestoneToUpdateList.isEmpty() && milestoneExpectedDurationList != null && !milestoneExpectedDurationList.isEmpty())
            {
                milestoneToUpdateFinalList =  IMP_BuildMilestoneRollups_Handler.mergeRollup(milestoneToUpdateList,milestoneExpectedDurationList);               
            } 
            else if (milestoneToUpdateList  != null && !milestoneToUpdateList.isEmpty())
            {
                milestoneToUpdateFinalList = milestoneToUpdateList;                
            }
            else if(milestoneExpectedDurationList != null && !milestoneExpectedDurationList.isEmpty())
            {
                milestoneToUpdateFinalList = milestoneExpectedDurationList;               
            }
            
            if (milestoneToUpdateFinalList != null && !milestoneToUpdateFinalList.isEmpty())
            {
                update milestoneToUpdateFinalList;
            }
            
            /*
            if(!milestonesToEndSet.isEmpty())
            {
            System.debug('$$$ milestonesToEndSet: '+milestonesToEndSet);
            
            //Process terminal activities mistakenly end dated, due to 1 or more non-terminal activity siblings existing with no end date
            //IMP_Project_Utility.updateMilestoneActualEndDate(milestoneActualEndDateMap, milestonesToEndSet);
            Map<Id, Boolean> terminalProjectActivityIdtoSuccessMap = IMP_Project_Utility.updateParentActualEndDate(milestoneActualEndDateMap, milestonesToEndSet, Project_Activity__c.sobjecttype);
            
            Boolean projActinMap = false;
            
            System.debug('$$$ The size of terminalProjectActivityIdtoSuccessMap is ' + terminalProjectActivityIdtoSuccessMap.size());
            if(terminalProjectActivityIdtoSuccessMap.size() > 0)
            {
            for(Project_Activity__c pa: Trigger.new)
            {
            projActinMap = terminalProjectActivityIdtoSuccessMap.containskey(pa.Id);
            if (projActinMap)
            {
            pa.addError('Terminal activity can not be end-dated, if a Milestone has 1 or more non-terminal activities which have not yet been end-dated.');
            }
            }
            }
            }
            */
            
            
            IMP_CreateEventForAssignee_Helper.createOrUpdateAssigneeEvent(Trigger.newMap, Trigger.oldMap, Trigger.New);
            
        } 
        else if(Trigger.isUpdate)
        {
            
            //collect the newly assigned users from the project activity
            List<Project_Activity__c> prjAct = [SELECT Id,
                                                Description__c,
                                                Planned_Start_Date__c,
                                                Planned_End_Date__c,
                                                SubProject_ID__c,
                                                Project_ID__c,
                                                CDK_Assignee__c,
                                                CDK_Assignee__r.Name
                                                FROM Project_Activity__c
                                                WHERE CDK_Assignee__c != null
                                                AND Id IN : Trigger.New];
            Set<Id> subprj = new Set<Id>();
            //get the Subproject id from the project activity to be able to set them as followers
            for(Project_Activity__c prj : prjAct)
            {
                subprj.add(prj.SubProject_ID__c);
            }
            
            for(Project_Activity__c newPrjAct : Trigger.New)
            {
                Project_Activity__c oldPrjAct = Trigger.oldMap.get(newPrjAct.Id);
                
                if((oldPrjAct.Total_Expected_Time_Spent__c != newPrjAct.Total_Expected_Time_Spent__c) ||
                   (oldPrjAct.Total_Actual_Time_Spent__c != newPrjAct.Total_Actual_Time_Spent__c) ||
                   (oldPrjAct.Status__c != newPrjAct.Status__c)    ||
                   (oldPrjAct.Actual_Start_Date__c != newPrjAct.Actual_Start_Date__c)    ||
                   (oldPrjAct.Planned_Start_Date__c != newPrjAct.Planned_Start_Date__c)    ||
                   (oldPrjAct.Planned_End_Date__c != newPrjAct.Planned_End_Date__c)    ||
                   (oldPrjAct.Actual_End_Date__c != newPrjAct.Actual_End_Date__c))
                {
                    milestoneRollupsList.add(newPrjAct);
                }
                
                if(oldPrjAct.Expected_Remaining_Duration__c != newPrjAct.Expected_Remaining_Duration__c    ||
                   oldPrjAct.Status__c != newPrjAct.Status__c)
                {
                    expectedDurationRollupsList.add(newPrjAct);
                }
            }
   
            List<sObject> milestoneToUpdateList = new List<sObject>();
            List<sObject> milestoneExpectedDurationList = new List<sObject>();
            if(milestoneRollupsList  != null && !milestoneRollupsList.isEmpty())
            {
                //IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList);    
                milestoneToUpdateList = IMP_BuildMilestoneRollups_Handler.createMilestoneRollups(milestoneRollupsList);    
            }
            
            if(expectedDurationRollupsList != null && !expectedDurationRollupsList.isEmpty())
            {    
                //IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
                milestoneExpectedDurationList = IMP_BuildMilestoneRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
            }
            
            List<sObject> milestoneToUpdateFinalList = new List<sObject>();
            
            if(milestoneToUpdateList  != null && !milestoneToUpdateList.isEmpty() && milestoneExpectedDurationList != null && !milestoneExpectedDurationList.isEmpty())
            {
                milestoneToUpdateFinalList =  IMP_BuildMilestoneRollups_Handler.mergeRollup(milestoneToUpdateList,milestoneExpectedDurationList);               
            } 
            else if (milestoneToUpdateList  != null && !milestoneToUpdateList.isEmpty())
            {
                milestoneToUpdateFinalList = milestoneToUpdateList;              
            }
            else if(milestoneExpectedDurationList != null && !milestoneExpectedDurationList.isEmpty())
            {
                milestoneToUpdateFinalList = milestoneExpectedDurationList;               
            }
            
            if (milestoneToUpdateFinalList != null && !milestoneToUpdateFinalList.isEmpty())
            {
                update milestoneToUpdateFinalList;
            }
            /*
            if(!milestonesToEndSet.isEmpty())
            {
            System.debug('$$$ milestonesToEndSet: '+milestonesToEndSet);
            
            //Process terminal activities mistakenly end dated, due to 1 or more non-terminal activity siblings existing with no end date
            //IMP_Project_Utility.updateMilestoneActualEndDate(milestoneActualEndDateMap, milestonesToEndSet);
            Map<Id, Boolean> terminalProjectActivityIdtoSuccessMap = IMP_Project_Utility.updateParentActualEndDate(milestoneActualEndDateMap, milestonesToEndSet, Project_Activity__c.sobjecttype);
            
            Boolean projActinMap = false;
            
            System.debug('$$$ The size of terminalProjectActivityIdtoSuccessMap is ' + terminalProjectActivityIdtoSuccessMap.size());
            if(terminalProjectActivityIdtoSuccessMap.size() > 0)
            {
            for(Project_Activity__c pa: Trigger.new)
            {
            projActinMap = terminalProjectActivityIdtoSuccessMap.containskey(pa.Id);
            if (projActinMap)
            {
            pa.addError('Terminal activity can not be end-dated, if a Milestone has 1 or more non-terminal activities which have not yet been end-dated.');
            }
            }
            }
            }
            */
            
            //post a feed to the asignee and add him as a follower to the project and subproject if still not following
            //disable post feed function UAT-272 - Rey Austral
            //if(prjAct != null && !prjAct.isEmpty())
            //{
            //    IMP_PostFeedToAsignee_Handler.postToChatterFeed(prjAct , Trigger.OldMap, subprj );
            //}
            
            
            IMP_CreateEventForAssignee_Helper.createOrUpdateAssigneeEvent(Trigger.newMap, Trigger.oldMap, Trigger.New);
            //filter for rollups
            
        } 
        else if(Trigger.isDelete)
        {
            for(Project_Activity__c prjAct : Trigger.Old)
            {
                if((prjAct.Total_Expected_Time_Spent__c != null && prjAct.Total_Expected_Time_Spent__c != 0) ||
                   (prjAct.Total_Actual_Time_Spent__c != null && prjAct.Total_Actual_Time_Spent__c != 0)    ||
                   (prjAct.Actual_Start_Date__c!=null)    ||
                   (prjAct.Planned_Start_Date__c!=null)    ||
                   (prjAct.Planned_End_Date__c!=null)    ||
                   (prjAct.Actual_End_Date__c!=null))
                {
                    milestoneRollupsList.add(prjAct);
                }
                
                if(prjAct.Expected_Remaining_Duration__c != null && prjAct.Expected_Remaining_Duration__c != 0)
                {
                    expectedDurationRollupsList.add(prjAct);
                }
            }
            
            List<sObject> milestoneToUpdateList = new List<sObject>();
            List<sObject> milestoneExpectedDurationList = new List<sObject>();
            if(milestoneRollupsList  != null && !milestoneRollupsList.isEmpty())
            {
                //IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList);    
                milestoneToUpdateList = IMP_BuildMilestoneRollups_Handler.createMilestoneRollups(milestoneRollupsList);    
            }
            
            if(expectedDurationRollupsList != null && !expectedDurationRollupsList.isEmpty())
            {    
                //IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
                milestoneExpectedDurationList = IMP_BuildMilestoneRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
            }
            
            List<sObject> milestoneToUpdateFinalList = new List<sObject>();
            
            if(milestoneToUpdateList  != null && !milestoneToUpdateList.isEmpty() && milestoneExpectedDurationList != null && !milestoneExpectedDurationList.isEmpty())
            {
                milestoneToUpdateFinalList =  IMP_BuildMilestoneRollups_Handler.mergeRollup(milestoneToUpdateList,milestoneExpectedDurationList);               
            } 
            else if (milestoneToUpdateList  != null && !milestoneToUpdateList.isEmpty())
            {
                milestoneToUpdateFinalList = milestoneToUpdateList;              
            }
            else if(milestoneExpectedDurationList != null && !milestoneExpectedDurationList.isEmpty())
            {
                milestoneToUpdateFinalList = milestoneExpectedDurationList;               
            }
            
            if (milestoneToUpdateFinalList != null && !milestoneToUpdateFinalList.isEmpty())
            {
                update milestoneToUpdateFinalList;
            }
            
        } 
        else if(Trigger.isUndelete)
        {
            
        }
        
    }   
}