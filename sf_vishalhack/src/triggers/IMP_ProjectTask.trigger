/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Consolidated Project Task triggers
Test Class:
History
02/04/2015    Kimiko Roberto    Created
03/14/2015    Kimiko Roberto    Updated trigger structure to have proper filters for calling methods
04/02/2015    Samuel Oberes     Added custom setting usage for bypassing the validation of past actual end dates in the BEFORE-INSERT and UPDATE context
04/14/2015    Samuel Oberes     Changed way on how to check equality for Users_Excluded_from_Business_Rules__c field
04/15/2015    Kimiko Roberto    Rearranged logic to process rollups first before ending terminal tasks/activities
05/06/2015    Samuel Oberes     Added invocation of error whenever a completed task is attempted to be deleted
05/12/2015    Samuel Oberes     Added Project_ID__c and SubProject_ID__c for the query in the AFTER INSERT and UPDATE context
05/19/2015    Kimiko Roberto    Added IMP_NotApplicableStatus_Handler to isBefore's insert and update to blank out Planned dates and actual days spent if not applicable reason has value.
05/21/2015    Kimiko Roberto    Added bypass mechanism to expected time spent
06/10/2015    Rey Austral       Added merge function for the rollup
06/11/2015    Rey Austral       Add the merge function for the rollup in the is after delete
06/17/2015    Rey Austral       Remove IMP_PostFeedToAsignee_Handler
06/19/2015    Rey Austral       Add roll down function
07/21/2015    Samuel Oberes     Added definition values logic stamping in the BEFORE INSERT DML context
08/07/2015    Karl Simon        Added Access_to_PM_Maintenance permission set to IMP_ProfilestoByPass entry for 'ByPass_Complete_Task_Edit' entry, and updated code below to check permission sets.
08/14/2015     Karl Simon          Corrected the else block for processing RMS-Owned inserts when no Definition Id exists
08/17/2015    Venkata Shrivol   Modified the before-update trigger to ensure the call to the custom setting IMP_ProfilesCanByPass is outside the FOR loop of the iteration of updated records.
08/27/2015    Rey Austral       Add roll down for CDK Assignee role
09/24/2015    Karl Simon        Corrected the call to the IMP_NotApplicableStatus_Handler to only pass in identified candidates - not all records in the trigger.
09/30/2015    Karl Simon        Expanded to define separate error messages while attempting to delete an RMS-Owned task, based upon whether the task is already marked NA, or otherwise driven by the presence of a non-null Actual Time Spent value
10/05/2015  Rey Austral         Remove the validation in adding task to rollup in the isAfter delete
10/19/2015    Karl Simon        Added logic to force a logical rollup during isAfter|isInsert and isAfter|isUpdate when the Force Rollup field Boolean value is set to true.
03/24/2016  ragashalini.koka@cdk.com   Added rollup functionality for planned start date, planned end date and rollup on CDKAssignee after update,insert and deletion of tasks
                                       Added parameter to IMP_BuildActivityRollups_Handler.mergeRollup to pass fieldAPI Name
03/28/2016 ragashalini.koka@cdk.com    Added the recursive check on Trigger
04/14/2016   Venkata Shrivol    commented the IMP_RMSActions_Handler class as we no longer need that class functionality
09/16/2016   Venkata Shrivol	added a small condition in AfterUpdate Context; added extra roll-ups code in beforeDelete context.
12/14/2016   Venkata Shrivol	commented the project object reference RQ-08305
------------------------------------------------------------*/
trigger IMP_ProjectTask on Project_Task__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
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
            /*
            //Removed
            if (!currentUserIsExcludedFromRules) 
            {
            //Checks if Actual End Dates are set to the past
            
            IMP_ActualEndDatesValidationHandler.checkPastActualEndDates(Trigger.New, null);       
            
            }
            */
                        //reset date and actual days spent to blank when not applicable reason has value
                        /*
            for(Project_Task__c pt : Trigger.New)
            {
            if(pt.Reason__c != null)
            { 
            IMP_NotApplicableStatus_Handler.blankPlannedDatesActualDaysSpent(Trigger.New);
            }
            }
            */
            
            // 2015-07-21: relocated by Sam
            //           : relocated to the for loop below
            //for(Project_Task__c pt: Trigger.New)
            //{               
                
            //    if (pt.Project_Activity_CDK_Assignee__c != null && pt.CDK_Assignee__c == null)
            //    {   
            //        pt.CDK_Assignee__c = pt.Project_Activity_CDK_Assignee__c;                  
            //    }
                
            //    if (pt.Project_Activity_Client_Assignee__c != null && pt.Client_Assignee__c == null)
            //    {
            //        pt.Client_Assignee__c = pt.Project_Activity_Client_Assignee__c;
            //    }
            //}

            /* 
             * -----------------------------------------------------------------------
             * 2015-07-21: added by Sam
             * -----------------------------------------------------------------------
             */

            // list of RMS related tasks that will later on get stamped
            List<Project_Task__c> rmsRelatedTasksList = new List<Project_Task__c>();

            // set of task definition ids of all the RMS related tasks
            Set<Id> rmsRelatedTaskDefinitionIdsSet = new Set<Id>();

            // use the dfr and dsr approach in order to mitigate chances of hardcoded api name errors. at least in this approach, the compiler will already know if there is something misspelled even before code execution begins.
            Schema.DescribeFieldResult dfr = Project_Task__c.Task_Definition__c.getDescribe();
            Schema.DescribeSObjectResult describedDefinitionSObject = dfr.getReferenceTo().get(0).getDescribe();

            for (Project_Task__c pt : Trigger.new) 
            {
                if (pt.RMS_Owned_Flag__c != null && pt.RMS_Owned_Flag__c == true)
                {
                    if (pt.Task_Definition__c != null) 
                    {
                        rmsRelatedTasksList.add(pt);
                        rmsRelatedTaskDefinitionIdsSet.add(pt.Task_Definition__c);
                    }
                    else
                    {
                        // [Simon, Karl 08-14-2014] else, do nothing
                        // String[] arguments = new String[] { pt.Description__c };
                        // System.debug(String.format(IMP_String_Utility.MISSING_TASK_DEFINITION_WITHARG, arguments));
                    }
                }

                // relocated code
                if (pt.Project_Activity_CDK_Assignee__c != null && pt.CDK_Assignee__c == null)
                {   
                    pt.CDK_Assignee__c = pt.Project_Activity_CDK_Assignee__c;                  
                }
                
                if (pt.Project_Activity_Client_Assignee__c != null && pt.Client_Assignee__c == null)
                {
                    pt.Client_Assignee__c = pt.Project_Activity_Client_Assignee__c;
                }
                //2015-08-27 Rey Austral - roll down cdk assignee role when the parent activity has value in assignee role while the task has no value
                if (pt.Project_Activity_Assignee_Role__c != null && pt.CDK_Assignee_Role__c == null)
                {
                    pt.CDK_Assignee_Role__c = pt.Project_Activity_Assignee_Role__c;
                }
            }

            //2016-04-14  -venkata.shrivol@cdk.com  -commented this method out
            //IMP_RMSActions_Handler.stampFieldsWithDefinitionValues(describedDefinitionSObject, rmsRelatedTaskDefinitionIdsSet, rmsRelatedTasksList);

            /*
             * -----------------------------------------------------------------------
             * end
             * -----------------------------------------------------------------------
             */
        } 
        else if(Trigger.isUpdate)
        {
            /*
            //Removed
            if (!currentUserIsExcludedFromRules) 
            {
            //Checks if Actual End Dates are set to the past
            
            IMP_ActualEndDatesValidationHandler.checkPastActualEndDates(Trigger.New, Trigger.OldMap);
            
            }
            */
                        //determines if a user can bypass updating expected time spent or not
                        /*
            Boolean cannotUpdateExpectedTimeSpent = false;
            system.Debug('***profile: '+IMP_Project_Utility.profileCanByPass('Expected_Time_Spent__c', UserInfo.getProfileId()));
            system.Debug('***permset: '+IMP_Project_Utility.permissionSetCanByPass('Expected_Time_Spent__c', UserInfo.getUserId()));             
            if(!IMP_Project_Utility.profileCanByPass('Expected_Time_Spent__c', UserInfo.getProfileId()) && !IMP_Project_Utility.permissionSetCanByPass('Expected_Time_Spent__c', UserInfo.getUserId()))
            {
            cannotUpdateExpectedTimeSpent = true;
            }
            */
            // 08/17/15- Venkata Shrivol - Added below two boolean values to bring the profileCanByPass and permissionSetCanByPass methods outside loop
            
            boolean profileCanByPassInTrigger = false;
            boolean permissionSetCanByPassInTrigger = false;
            profileCanByPassInTrigger = IMP_Project_Utility.profileCanByPass('ByPass_Complete_Task_Edit', UserInfo.getProfileId());
            permissionSetCanByPassInTrigger = IMP_Project_Utility.permissionSetCanByPass('ByPass_Complete_Task_Edit', UserInfo.getUserId());
            
            Map<Id, Boolean> profilesToBypassTaskCompleteMap = IMP_Project_Utility.profileCanByPass_2();
            Map<Id,Boolean> profileCanBypassMap = IMP_Project_Utility.userCanByPass(Profile.sObjectType);
            Map<Id,Boolean> permissionCanBypassMap = IMP_Project_Utility.userCanByPass(PermissionSetAssignment.sObjectType);
            system.Debug('**Profiles: ' + profileCanBypassMap);
            system.Debug('**userprofile: ' + UserInfo.getProfileId());
            system.Debug('**permission: ' + permissionCanBypassMap);
            system.Debug('**userId: ' + UserInfo.getUserId());
            IMP_IncrementActivityOrMilestone_Handler.IncrementCounterField(Trigger.oldMap, Trigger.New);
            
            //Clone if the task is complete and has fail migration status
            List<Project_Task__c> taskToCloneList = new List<Project_Task__c>();
            for(Project_Task__c pt: Trigger.newMap.values())
            {
                if (Trigger.oldMap.containsKey(pt.id)) 
                {
                    Project_Task__c ptOld = Trigger.oldMap.get(pt.id);
                    // 08/07/2015 Karl Simon  Added Access_to_PM_Maintenance permission set to IMP_ProfilestoByPass entry for 'ByPass_Complete_Task_Edit' entry, and updated code below to check permission sets.
                    if (ptOld.Status__c == IMP_Project_Utility.STATUS_COMPLETE && currentUserIsExcludedFromRules == false && !profileCanByPassInTrigger && !permissionSetCanByPassInTrigger
                       && IMP_Project_Utility.checkTaskFieldIfChange(pt,ptOld) == true)
                    {
                        pt.addError(IMP_String_Utility.NO_BYPASS_TOUPDATE_TASK);   
                    }
                    else
                    {
                        //7-15-2015 Rey Austral - De-Commission clone AI#298
                        //validate the old value, so that the clone will not trigger every time the user change something that is not the migration status
                        /*
                        if (ptOld.Status__c != IMP_Project_Utility.STATUS_COMPLETE || (ptOld.Migration_Status__c == 'Success' || ptOld.Migration_Status__c == 'Task Not Performed'))
                        {
                            //validate if the new value is accepted for clonning
                            if (pt.Status__c == IMP_Project_Utility.STATUS_COMPLETE &&  !(pt.Migration_Status__c == 'Success' || pt.Migration_Status__c == 'Task Not Performed') && pt.Migration_Status__c != null
                                && pt.Was_Cloned_to_New_Migration_Task__c == false) 
                            {    
                                try 
                                {
                                    //add the clone record in the list
                                    taskToCloneList.add(IMP_Project_Utility.cloneProjectTaskField(pt));
                                    //change the value of this field to mark the old record have already been cloned and will not be clone again, even if the migration status has been change
                                    pt.Was_Cloned_to_New_Migration_Task__c = true;                                    
                                } 
                                catch(Exception ex) 
                                {
                                    pt.addError('Error in cloning the task : ' + ex.getMessage());
                                }
                                
                            } 
                        }
                        */
                        // Action tracker #166, reset date when not applicable reason has value
                        // 09/24/15- Karl Simon - Corrected the call to the IMP_NotApplicableStatus_Handler to only pass in identified candidates - not all records in the trigger.
                        if (ptOld.Reason__c == null && pt.Reason__c != null) 
                        {
                            List<Project_Task__c> naList = new List<Project_Task__c>();
                            naList.add(pt);
                            IMP_NotApplicableStatus_Handler.blankPlannedDatesActualDaysSpent(naList);
                        }
                        
                        // Expected Days Spent is a field that should only be editable during the creation of a Project Task
                        // it should not be allowed to be updated
                        if(ptOld.Expected_Time_Spent__c != pt.Expected_Time_Spent__c)
                        {
                            if(profileCanBypassMap.get(UserInfo.getProfileId()) == null && permissionCanBypassMap.get(UserInfo.getUserId()) == null)
                            {
                                pt.Expected_Time_Spent__c = ptOld.Expected_Time_Spent__c;
                            }
                            
                        }
                        
                    }
                    
                    
                }
                
            }
            //7-15-2015 Rey Austral - De-Commission clone AI#298
            /*
            if (!taskToCloneList.isEmpty()) 
            {
                try 
                {
                    insert taskToCloneList;
                }
                catch (Exception ex) 
                {
                    System.debug('$$$ Insert Task to Clone Exception: '+ ex);
                }
                
            }
           */  
        } 
        else if(Trigger.isDelete)
        {
            
            /*for removal
            IMP_ProjectActivityContacts_Handler_2.beforeDeleteValuesPT = [SELECT Id, CDK_Assignee__c, Client_Assignee__c, Project_Activity__r.Milestone__r.Subproject__c
            FROM Project_Task__c 
            WHERE Id IN :Trigger.Old];
            
            system.debug('**IMP_ProjectActivityContacts_Handler_2.beforeDeleteValuesPT: '+IMP_ProjectActivityContacts_Handler_2.beforeDeleteValuesPT);                              
            */
            //2015-09-02 Rey Austral - Check if the user has permission to delete the rms record
            boolean profileCanByPassRMSInTrigger = false;
            profileCanByPassRMSInTrigger = IMP_Project_Utility.profileCanByPass('ByPass_RMS_Record_Delete', UserInfo.getProfileId());
            for(Project_Task__c taskToDelete : Trigger.oldMap.values())
            {    
                //2015-09-02 Rey Austral - Add function to prevent deleting RMS owned Task when the user profile is not authorize
                //2015-09-30 Karl Simon - Expanded to define separate error messages, depending upon the presence of a non-null Total Actual Time Spent value
                if (taskToDelete.RMS_Owned_Flag__c == true && profileCanByPassRMSInTrigger == false )
                {
                    if (taskToDelete.Status_Not_Applicable__c == true)
                    {
                        String[] arguments = new String[] { taskToDelete.Description__c };
                        taskToDelete.addError(String.format(IMP_String_Utility.NO_BYPASS_TODELETE_RMSTASK_NOTAPPLICABLE, arguments));
                    }
                    else if (taskToDelete.Actual_Time_Spent__c !=null)
                    {
                        String[] arguments = new String[] { taskToDelete.Description__c };
                        taskToDelete.addError(String.format(IMP_String_Utility.NO_BYPASS_TODELETE_RMSTASK_ACTUALDAYSAPPLIED, arguments));
                    }
                    else
                    {
                        String[] arguments = new String[] { taskToDelete.Description__c };
                        taskToDelete.addError(String.format(IMP_String_Utility.NO_BYPASS_TODELETE_RMSTASK, arguments));
                    }
                }
                //10-14-2015 Kimiko Roberto -  Added filter to remove Cast Iron user from bypassing deletion of completed tasks
                else if ((taskToDelete.Status__c == IMP_Project_Utility.STATUS_COMPLETE && currentUserIsExcludedFromRules == false) || 
                         (taskToDelete.Status__c == IMP_Project_Utility.STATUS_COMPLETE && currentUserIsExcludedFromRules == true && UserInfo.getName() == 'Cast Iron Integration'))
                {
                    String[] arguments = new String[] { taskToDelete.Description__c };                                                  
                    taskToDelete.addError(String.format(IMP_String_Utility.NO_BYPASS_TODELETE_TASK, arguments));
                   
                }
            }
        }
        
    } 
    else if (Trigger.isAfter) 
    {
        
        List<Project_Task__c> expectedDurationRollupsList = new List<Project_Task__c>();
        List<Project_Task__c> activityRollupsList = new List<Project_Task__c>();
        Set<Id> activityIdSet = new Set<Id>(); 
        List<SObject> activityCDKAssigneeList = new List<Sobject>();
        //IMP_ProjectActivityContacts_Handler_2.createOrUpdateContacts(Trigger.oldMap, Trigger.old, Trigger.New, Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Project_Task__c.SObjectType);
        
        // ------------------------------------------------------------------------------------------------------------------------
        // ------------------------------------------------------------------------------------------------------------------------
        /*
        Map<Id, Date> activityActualEndDateMap = new Map<Id, Date>();
        Set<Id> activityToEndSet = new Set<Id>();
        
        if(Trigger.isInsert || Trigger.isUpdate)
        {
        
        for(Project_Task__c pt: Trigger.New)
        {
        
        //Only process records for Terminal Activity = true and Actual End Date != null
        if(pt.Terminal_Task__c && pt.Actual_End_Date__c != null)
        {
        
        //Put key and values to map to be used for handler
        activityActualEndDateMap.put(pt.Project_Activity__c, pt.Actual_End_Date__c);
        
        //Add Project Milestone Id to be used for query
        activityToEndSet.add(pt.Project_Activity__c);
        }
        }
        system.Debug('**activityActualEndDateMap'+activityActualEndDateMap);
        }
        */
        
        
        if(Trigger.isInsert)
        {
            
            //collect the newly assigned users from the project activity
            List<Project_Task__c> prjTaskList = [SELECT Id,
                                                /* Description__c,
                                                 Planned_Start_Date__c,
                                                 Planned_End_Date__c,*/
                                                 SubProject_ID__c
                                                 /*Project_ID__c,
                                                 CDK_Assignee__c,
                                                 CDK_Assignee__r.Name,
                                                 Status__c,
                                                 NotifyWhenComplete__c,
                                                 Project_Activity__r.Description__c,
                                                 Project_Activity__r.Milestone__r.Description__c,
                                                 Project_Activity__c,
                                                 Project_Activity__r.Milestone__c*/
                                                 FROM Project_Task__c
                                                 WHERE CDK_Assignee__c != null
                                                 AND Id IN : Trigger.New];
            Set<Id> subprj = new Set<Id>();
            //get the Subproject id from the project activity to be able to set them as followers
            for(Project_Task__c prj : prjTaskList)
            {
                subprj.add(prj.SubProject_ID__c);
            }
            
            
            //post a feed to the asignee and add him as a follower to the project and subproject if still not following
            //disable post feed function UAT-272 - Rey Austral
            //if(prjTaskList != null && !prjTaskList.isEmpty())
           // {
           //     IMP_PostFeedToAsignee_Handler.postToChatterFeed(prjTaskList, null, subprj );
            //}
            
            for(Project_Task__c prjTask : Trigger.New)
            {
               
                if((prjTask.Expected_Time_Spent__c != null && prjTask.Expected_Time_Spent__c != 0) || 
                   (prjTask.Actual_Time_Spent__c != null && prjTask.Actual_Time_Spent__c != 0) || 
                   (prjTask.Actual_Start_Date__c != null)    ||
                   (prjTask.Actual_End_Date__c != null) ||
                   (prjTask.Force_Rollup__c == true) ||
                   (prjTask.Planned_Start_Date__c != null) ||
                   (prjTask.Planned_End_Date__c != null) ||
                   (prjTask.CDK_Assignee__c != null))
                {
                    activityRollupsList.add(prjTask);
                }   
                
                if(prjTask.Expected_Time_Spent__c != null && prjTask.Expected_Time_Spent__c != 0)
                {
                    expectedDurationRollupsList.add(prjTask);
                }
                
                if(prjTask.CDK_Assignee__c != null) {
                    activityIdSet.add(prjTask.Project_Activity__c);
                }
            }
            
            List<sObject> activityToUpdateList = new List<sObject>();
            List<sObject> activityExpectedDurationList = new List<sObject>();
            if(activityRollupsList  != null && !activityRollupsList.isEmpty())
            {
                //IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList);    
                activityToUpdateList = IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList);    
                Map<Id, sObject> activityToUpdateMap = new Map<id, sObject>(activityToUpdateList);
                for(sObject pActivity : activityRollupsList)
                {
                     Id activityId = (Id)pActivity.get('Project_Activity__c');
                     if (activityToUpdateMap.containsKey(activityId))
                     {                        
                        sObject actToUpdate = activityToUpdateMap.get( activityId );
                        if (actToUpdate.get('Total_Tasks__c') == null)
                        {   
                            actToUpdate.put('Actual_Start_Date__c',null);
                            actToUpdate.put('Actual_End_Date__c',null);
                            actToUpdate.put('Total_Actual_Time_Spent__c',0);
                            actToUpdate.put('Total_Expected_Time_Spent__c',0);                            
                            actToUpdate.put('Total_Tasks__c',0);
                        }
                     }
                }
            }
            
            if(expectedDurationRollupsList != null && !expectedDurationRollupsList.isEmpty())
            {    
                //IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
                activityExpectedDurationList = IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
            }
            
            if(activityIdSet.size() > 0) {
                activityCDKAssigneeList = IMP_BuildActivityRollups_Handler.createCDKAssgineeRollUp(activityIdSet);
            }

            
            List<sObject> activityToUpdateFinalList = new List<sObject>();
            if(activityToUpdateList  != null && !activityToUpdateList.isEmpty() && activityExpectedDurationList != null && !activityExpectedDurationList.isEmpty())
            {
                activityToUpdateFinalList =  IMP_BuildActivityRollups_Handler.mergeRollup(activityToUpdateList,activityExpectedDurationList,'Expected_Remaining_Duration__c');
            } 
            else if (activityToUpdateList  != null && !activityToUpdateList.isEmpty())
            {
                activityToUpdateFinalList = activityToUpdateList;
            }
            else if(activityExpectedDurationList != null && !activityExpectedDurationList.isEmpty())
            {
                activityToUpdateFinalList = activityExpectedDurationList;
            }
            
            if(activityCDKAssigneeList.size() > 0) {
                activityToUpdateFinalList =  IMP_BuildActivityRollups_Handler.mergeRollup(activityToUpdateFinalList,activityCDKAssigneeList,'CDK_Assignee__c'); 
            }

            
            if (activityToUpdateFinalList != null && !activityToUpdateFinalList.isEmpty())
            {
                update activityToUpdateFinalList;
            }
            
            
            /*
            if(!activityToEndSet.isEmpty())
            {
            System.debug('$$$ activityToEndSet: '+activityToEndSet);
            
            //Process terminal activities mistakenly end dated, due to 1 or more non-terminal activity siblings existing with no end date
            Map<Id, Boolean> terminalProjectTaskIdtoSuccessMap = IMP_Project_Utility.updateParentActualEndDate(activityActualEndDateMap, activityToEndSet, Project_Task__c.SObjectType);
            
            Boolean projTaskinMap = false;
            
            System.debug('$$$ The size of terminalProjectTaskIdtoSuccessMap is ' + terminalProjectTaskIdtoSuccessMap.size());
            if(terminalProjectTaskIdtoSuccessMap.size() > 0){
            for(Project_Task__c pt: Trigger.new){
            projTaskinMap = terminalProjectTaskIdtoSuccessMap.containskey(pt.Id);
            if (projTaskinMap) {
            pt.addError('Terminal task can not be end-dated, if an Activity has 1 or more non-terminal tasks which have not yet been end-dated.');
            }
            }
            }
            }
            */
            /*
        for(Project_Task__c prjTask : Trigger.New)
        {
        if((prjTask.Expected_Time_Spent__c != null && prjTask.Expected_Time_Spent__c != 0) || 
        (prjTask.Actual_Time_Spent__c != null && prjTask.Actual_Time_Spent__c != 0) || 
        (prjTask.Actual_Start_Date__c != null))
        {
        activityRollupsList.add(prjTask);
        }   
        
        if(prjTask.Expected_Time_Spent__c != null && prjTask.Expected_Time_Spent__c != 0)
        {
        expectedDurationRollupsList.add(prjTask);
        }
        }
        
        if(activityRollupsList  != null && !activityRollupsList.isEmpty())
        {
        IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList);    
        }
        
        if(expectedDurationRollupsList != null && !expectedDurationRollupsList.isEmpty())
        {    
        IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
        }
        */
        }
        else if(Trigger.isUpdate)
        {
            
            //collect the newly assigned users from the project activity
            List<Project_Task__c> prjTask = [SELECT Id,
                                             Description__c,
                                             Planned_Start_Date__c,
                                             Planned_End_Date__c,
                                             SubProject_ID__c,
                                             //Project_ID__c,
                                             CDK_Assignee__c,
                                             CDK_Assignee__r.Name,
                                             Status__c,
                                             NotifyWhenComplete__c,
                                             Project_Activity__r.Description__c,
                                             Project_Activity__r.CDK_Assignee__c,
                                             Project_Activity__r.Milestone__r.Description__c,
                                             Project_Activity__c,
                                             Project_Activity__r.Milestone__c
                                             FROM Project_Task__c
                                             WHERE CDK_Assignee__c != null
                                             AND Id IN : Trigger.New];
            
            Set<Id> subprj = new Set<Id>();
            //get the Subproject id from the project activity to be able to set them as followers
            for(Project_Task__c prj : prjTask)
            {
                //subprj.add(prj.SubProject_ID__c);
                 Project_Task__c oldPrjTask = Trigger.OldMap.get(prj.Id);
                
                //system.debug('prj.CDK_Assignee__c'+prj.CDK_Assignee__c);
                //system.debug('oldPrjTask.CDK_Assignee__c'+oldPrjTask.CDK_Assignee__c);
                //system.debug('prj.Project_Activity__r.CDK_Assignee__c'+prj.Project_Activity__r.CDK_Assignee__c);
                if( (prj.CDK_Assignee__c != oldPrjTask.CDK_Assignee__c) || (prj.CDK_Assignee__c!=prj.Project_Activity__r.CDK_Assignee__c)) 
                { 
                   activityIdSet.add(prj.Project_Activity__c);
                }
            }
            
            for(Project_Task__c newPrjTask : Trigger.New)
            {
                //2016-09-06 -venkata.shrivol@cdk.com -added OR condition in the last 'AND' condition below
                
                Project_Task__c oldPrjTask = Trigger.OldMap.get(newPrjTask.Id);
                if((newPrjTask.Expected_Time_Spent__c != oldPrjTask.Expected_Time_Spent__c) ||
                   (newPrjTask.Actual_Time_Spent__c != oldPrjTask.Actual_Time_Spent__c) || 
                   (newPrjTask.Planned_End_Date__c != oldPrjTask.Planned_End_Date__c) ||
                   (newPrjTask.Actual_Start_Date__c != oldPrjTask.Actual_Start_Date__c) ||
                   (newPrjTask.Planned_Start_Date__c != oldPrjTask.Planned_Start_Date__c) ||
                   (newPrjTask.Actual_End_Date__c != oldPrjTask.Actual_End_Date__c)    ||
                   (newPrjTask.Force_Rollup__c == true) ||
                   (newPrjTask.Status__c != oldPrjTask.Status__c) 
                   && ( newPrjTask.Status__c != 'Assigned' || oldPrjTask.Status__c != 'Unassigned' )  
                  )
                {
                    activityRollupsList.add(newPrjTask);
                }   
                
                if(newPrjTask.Expected_Time_Spent__c != oldPrjTask.Expected_Time_Spent__c    || 
                   newPrjTask.Status__c != oldPrjTask.Status__c && newPrjTask.Status__c != 'Assigned')
                {
                    expectedDurationRollupsList.add(newPrjTask);
                }
            }
            /*
            if(activityRollupsList  != null && !activityRollupsList.isEmpty())
            {
            IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList);    
            }
            
            if(expectedDurationRollupsList != null && !expectedDurationRollupsList.isEmpty())
            {    
            IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
            }
            */
            
            List<sObject> activityToUpdateList = new List<sObject>();
            List<sObject> activityExpectedDurationList = new List<sObject>();
           
            if(activityRollupsList  != null && !activityRollupsList.isEmpty())
            {
                //IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList);    
                activityToUpdateList = IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList);    
                
                Map<Id, sObject> activityToUpdateMap = new Map<id, sObject>(activityToUpdateList);
                for(sObject pActivity : activityRollupsList)
                {
                     Id activityId = (Id)pActivity.get('Project_Activity__c');
                     if (activityToUpdateMap.containsKey(activityId))
                     { 
                         
                        sObject actToUpdate = activityToUpdateMap.get( activityId );
                         
                        if (actToUpdate.get('Total_Tasks__c') == null)
                        {   
                            system.debug('--Yes Sir--->');
                            actToUpdate.put('Actual_Start_Date__c',null);
                            actToUpdate.put('Actual_End_Date__c',null);
                            actToUpdate.put('Total_Actual_Time_Spent__c',0);
                            actToUpdate.put('Total_Expected_Time_Spent__c',0);    
                            actToUpdate.put('Total_Tasks__c',0);
                        }
                     }
                }
            }
            
            if(expectedDurationRollupsList != null && !expectedDurationRollupsList.isEmpty())
            {    
                //IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
                activityExpectedDurationList = IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
            }
            
            if(activityIdSet.size() > 0) {
                activityCDKAssigneeList = IMP_BuildActivityRollups_Handler.createCDKAssgineeRollUp(activityIdSet);
            }
            
            List<sObject> activityToUpdateFinalList = new List<sObject>();
            if(activityToUpdateList  != null && !activityToUpdateList.isEmpty() && activityExpectedDurationList != null && !activityExpectedDurationList.isEmpty())
            {
                activityToUpdateFinalList =  IMP_BuildActivityRollups_Handler.mergeRollup(activityToUpdateList,activityExpectedDurationList,'Expected_Remaining_Duration__c');                
            } 
            else if (activityToUpdateList  != null && !activityToUpdateList.isEmpty())
            {
                activityToUpdateFinalList = activityToUpdateList;               
            }
            else if(activityExpectedDurationList != null && !activityExpectedDurationList.isEmpty())
            {
                activityToUpdateFinalList = activityExpectedDurationList;              
            }
            
            if(activityCDKAssigneeList.size() > 0) {
                activityToUpdateFinalList =  IMP_BuildActivityRollups_Handler.mergeRollup(activityToUpdateFinalList,activityCDKAssigneeList,'CDK_Assignee__c'); 
            }
           // system.debug('activityToUpdateFinalList------'+activityToUpdateFinalList);
            
            if (activityToUpdateFinalList != null && !activityToUpdateFinalList.isEmpty())
            {
                update activityToUpdateFinalList;
            }
            /*
            if(!activityToEndSet.isEmpty())
            {
            System.debug('$$$ activityToEndSet: '+activityToEndSet);
            
            //Process terminal activities mistakenly end dated, due to 1 or more non-terminal activity siblings existing with no end date
            Map<Id, Boolean> terminalProjectTaskIdtoSuccessMap = IMP_Project_Utility.updateParentActualEndDate(activityActualEndDateMap, activityToEndSet, Project_Task__c.SObjectType);
            
            Boolean projTaskinMap = false;
            
            System.debug('$$$ The size of terminalProjectTaskIdtoSuccessMap is ' + terminalProjectTaskIdtoSuccessMap.size());
            if(terminalProjectTaskIdtoSuccessMap.size() > 0)
            {
            for(Project_Task__c pt: Trigger.new)
            {
            projTaskinMap = terminalProjectTaskIdtoSuccessMap.containskey(pt.Id);
            if (projTaskinMap)
            {
            pt.addError('Terminal task can not be end-dated, if an Activity has 1 or more non-terminal tasks which have not yet been end-dated.');
            }
            }
            }
            }
            */
            
            //post a feed to the asignee and add him as a follower to the project and subproject if still not following
            //disable post feed function UAT-272 - Rey Austral
            //if(prjTask != null && !prjTask.isEmpty())
            //{
            //    IMP_PostFeedToAsignee_Handler.postToChatterFeed(prjTask , Trigger.OldMap, subprj );
            //}
            
            
            
        }
        else if(Trigger.isDelete)
        {
            
            for(Project_Task__c prjTask : Trigger.Old)
            {
                 //10-05-15 Rey Austral         Remove the validation in adding task to rollup 
                 /*
                if((prjTask.Expected_Time_Spent__c != null && prjTask.Expected_Time_Spent__c != 0) || 
                   (prjTask.Actual_Time_Spent__c != null && prjTask.Actual_Time_Spent__c != 0) || 
                   (prjTask.Actual_Start_Date__c != null)    || 
                   (prjTask.Actual_End_Date__c != null))
                {*/
                    activityRollupsList.add(prjTask);
                //}   
                
                if(prjTask.Expected_Time_Spent__c != null && prjTask.Expected_Time_Spent__c != 0)
                {
                    expectedDurationRollupsList.add(prjTask);
                }  
                
                if(prjTask.CDK_Assignee__c != null) {
                    activityIdSet.add(prjTask.Project_Activity__c);
                }
            }
            
            List<sObject> activityToUpdateList = new List<sObject>();
            List<sObject> activityExpectedDurationList = new List<sObject>();
            if(activityRollupsList  != null && !activityRollupsList.isEmpty())
            {
                //IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList);    
                activityToUpdateList = IMP_BuildActivityRollups_Handler.createActivityRollups(activityRollupsList); 
                
                //2016-09-06 -venkata.shrivol@cdk.com -added below logic to handle the roll-ups when there are no tasks
                
                Map<Id, sObject> activityToUpdateMap = new Map<id, sObject>(activityToUpdateList);
                for(sObject pActivity : activityRollupsList)
                {
                    Id activityId = (Id)pActivity.get('Project_Activity__c');
                    if (activityToUpdateMap.containsKey(activityId))
                    { 
                        
                        sObject actToUpdate = activityToUpdateMap.get( activityId );
                        
                        if (actToUpdate.get('Total_Tasks__c') == null)
                        {   
                            
                            actToUpdate.put('Actual_Start_Date__c',null);
                            actToUpdate.put('Actual_End_Date__c',null);
                            actToUpdate.put('Total_Actual_Time_Spent__c',0);
                            actToUpdate.put('Total_Expected_Time_Spent__c',0);    
                            actToUpdate.put('Total_Tasks__c',0);
                        }
                    }
                }
            }
            
            if(expectedDurationRollupsList != null && !expectedDurationRollupsList.isEmpty())
            {    
                //IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
                activityExpectedDurationList = IMP_BuildActivityRollups_Handler.createExpectedDurationRollup(expectedDurationRollupsList);
            }
            
            if(activityIdSet.size() > 0) {
                activityCDKAssigneeList = IMP_BuildActivityRollups_Handler.createCDKAssgineeRollUp(activityIdSet);
            }

            
            List<sObject> activityToUpdateFinalList = new List<sObject>();
            if(activityToUpdateList  != null && !activityToUpdateList.isEmpty() && activityExpectedDurationList != null && !activityExpectedDurationList.isEmpty())
            {
                activityToUpdateFinalList =  IMP_BuildActivityRollups_Handler.mergeRollup(activityToUpdateList,activityExpectedDurationList,'Expected_Remaining_Duration__c');                
            } 
            else if (activityToUpdateList  != null && !activityToUpdateList.isEmpty())
            {
                activityToUpdateFinalList = activityToUpdateList;               
            }
            else if(activityExpectedDurationList != null && !activityExpectedDurationList.isEmpty())
            {
                activityToUpdateFinalList = activityExpectedDurationList;              
            }
            
            if(activityCDKAssigneeList.size() > 0) {
                activityToUpdateFinalList =  IMP_BuildActivityRollups_Handler.mergeRollup(activityToUpdateFinalList,activityCDKAssigneeList,'CDK_Assignee__c'); 
            }

            
            if (activityToUpdateFinalList != null && !activityToUpdateFinalList.isEmpty())
            {
                update activityToUpdateFinalList;
            }
        } 
    }
}