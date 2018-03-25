/*------------------------------------------------------------
Author:      Michael Lasala
Company:     Cloud Sherpas
Description: Consolidated Project Milestone triggers
Test Class:
History
10/20/14     Michael Lasala      Created
11/06/14     Samuel Oberes       Refactored: Removed IMP_IncrementMilestoneCounter_Handler.IncrementCounterField from the BEFORE UPDATE context because the same method is 
                                 being called against the same Project Milestone object in the same context, but on a different trigger (IMP_IncrementMilestoneDelayedCounterField)
11/13/14     Samuel Oberes       Added IMP_IncrementActivityOrMilestone_Handler.IncrementCounterField in the before update context, relocating from the now inactive, soon to be deleted, IMP_IncrementMilestoneDelayedCounterField
04/01/15     Rey Austral         Set expected remaining duration to 0 if status is complete
05/06/15     Samuel Oberes       1) Added business rules exclusion logic 
                                 2) Added invocation of error whenever a completed milestone is attempted to be deleted
07/21/15     Samuel Oberes       Added definition values logic stamping in the BEFORE INSERT DML context
08/14/15     Karl Simon          Corrected the else block for processing RMS-Owned inserts when no Definition Id exists
09/21/15     Rey Austral         Add function to automatically create non-rms activity and task when a RMS Milestone is created
09/30/15     Karl Simon          Expanded to define separate error messages when attempting to delete an RMS-Owned milestone, depending upon the presence of a non-null Total Actual Time Spent value
------------------------------------------------------------*/
trigger IMP_ProjectMilestone on Project_Milestone__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
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
             * -----------------------------------------------------------------------
             * 2015-07-21: added by Sam
             * -----------------------------------------------------------------------
             */

            // list of RMS related milestones that will later on get stamped
            List<Project_Milestone__c> rmsRelatedMilestonesList = new List<Project_Milestone__c>();

            // set of milestone definition ids of all the RMS related milestones
            Set<Id> rmsRelatedMilstoneDefinitionIdsSet = new Set<Id>();

            // use the dfr and dsr approach in order to mitigate chances of hardcoded api name errors. at least in this approach, the compiler will already know if there is something misspelled even before code execution begins.
            Schema.DescribeFieldResult dfr = Project_Milestone__c.Milestone_Definition__c.getDescribe();
            Schema.DescribeSObjectResult describedDefinitionSObject = dfr.getReferenceTo().get(0).getDescribe();

            for (Project_Milestone__c pm : Trigger.new) 
            {
                if (pm.RMS_Owned_Flag__c != null && pm.RMS_Owned_Flag__c == true)
                {
                    if (pm.Milestone_Definition__c != null) 
                    {
                        rmsRelatedMilestonesList.add(pm);
                        rmsRelatedMilstoneDefinitionIdsSet.add(pm.Milestone_Definition__c);
                    }
                    else
                    {
                        // [Simon, Karl 08-14-2014] else, do nothing
                        // String[] arguments = new String[] { pm.Description__c };
                        // System.debug(String.format(IMP_String_Utility.MISSING_MILESTONE_DEFINITION_WITHARG, arguments));
                    }
                }
            }

            IMP_RMSActions_Handler.stampFieldsWithDefinitionValues(describedDefinitionSObject, rmsRelatedMilstoneDefinitionIdsSet, rmsRelatedMilestonesList);

            /*
             * -----------------------------------------------------------------------
             * end
             * -----------------------------------------------------------------------
             */
        } 
        else if(Trigger.isUpdate)
        {
            
            IMP_IncrementActivityOrMilestone_Handler.IncrementCounterField(Trigger.oldMap, Trigger.New);
            //Iterate the new and old value 
            for(Project_Milestone__c pm: Trigger.newMap.values())
            {
                if (Trigger.oldMap.containsKey(pm.id)) 
                {
                    Project_Milestone__c pmOld = Trigger.oldMap.get(pm.id);
                    
                    //check if the status has been change from different value to complete
                    if (pmOld.Status__c != IMP_Project_Utility.STATUS_COMPLETE && pm.Status__c ==  IMP_Project_Utility.STATUS_COMPLETE)
                    {                       
                       IMP_Project_Utility.assignIntegerFieldValue('Expected_Remaining_Duration__c',pm,0);                       
                    }
                }
            }
            
        } 
        else if(Trigger.isDelete)
        {            
            //2015-09-02 Rey Austral - Check if the user has permission to delete the rms record
            boolean profileCanByPassRMSInTrigger = false;
            profileCanByPassRMSInTrigger = IMP_Project_Utility.profileCanByPass('ByPass_RMS_Record_Delete', UserInfo.getProfileId());
            for(Project_Milestone__c milestoneToDelete : Trigger.oldMap.values())
            {   
                //2015-09-02 Rey Austral - Add function to prevent deleting RMS owned Milestone when the user profile is not authorize
                //2015-09-30 Karl Simon - Expanded to define separate error messages, depending upon the presence of a non-null Total Actual Time Spent value
                if (milestoneToDelete.RMS_Owned_Flag__c == true && profileCanByPassRMSInTrigger == false )
                {
                    if (milestoneToDelete.Total_Actual_Time_Spent__c !=null)
                    {
                        String[] arguments = new String[] { milestoneToDelete.Description__c };
                        milestoneToDelete.addError(String.format(IMP_String_Utility.NO_BYPASS_TODELETE_RMSMILESTONE_ACTUALDAYSAPPLIED, arguments));
                    }
                    else
                    {
                        String[] arguments = new String[] { milestoneToDelete.Description__c };
                        milestoneToDelete.addError(String.format(IMP_String_Utility.NO_BYPASS_TODELETE_RMSMILESTONE, arguments));
                    }
                }
                //10-14-2015 Kimiko Roberto -  Added filter to remove Cast Iron user from bypassing deletion of completed milestones
                else if ((milestoneToDelete.Status__c == IMP_Project_Utility.STATUS_COMPLETE && currentUserIsExcludedFromRules == false) || (milestoneToDelete.Status__c == IMP_Project_Utility.STATUS_COMPLETE && currentUserIsExcludedFromRules == true  && UserInfo.getName() == 'Cast Iron Integration'))
                {
                    String[] arguments = new String[] { milestoneToDelete.Description__c };
                    milestoneToDelete.addError(String.format(IMP_String_Utility.NO_BYPASS_TODELETE_MILESTONE, arguments));
                }
            }
        }
        
    } 
    else if (Trigger.isAfter) 
    {
        
        if(Trigger.isInsert)
        {
            //2015-09-21 Rey Austral - Add function to automatically add non-rms activty and task when a RMS Milestone is created in Salesforce
            Map<id,List<Project_Milestone__c>> milestoneDefinitionProjectMap = new Map<Id,List<Project_Milestone__c>>();
            Set<Id> subprojectIdSet = new Set<Id>();
            //build the parameter to be used in createProjectActivity method
            for(Project_Milestone__c milestone : trigger.new)
            {
                if (milestone.RMS_Owned_Flag__c == true )
                {
                    //2015-10-01 Rey Austral - handle multiple milestones record that has same milestone definition but different subproject
                    if (milestoneDefinitionProjectMap.containsKey(milestone.Milestone_Definition__c))
                    {
                        List<Project_Milestone__c> milesList = milestoneDefinitionProjectMap.get(milestone.Milestone_Definition__c);
                        milesList.add(milestone);
                    }
                    else
                    {
                        List<Project_Milestone__c> milesList = new  List<Project_Milestone__c>();
                        milesList.add(milestone);
                        milestoneDefinitionProjectMap.put(milestone.Milestone_Definition__c,milesList);
                    }
                   
                    subprojectIdSet.add(milestone.SubProject__c);
                }
            }
            if (!milestoneDefinitionProjectMap.keySet().isEmpty())
            {   
               
                //Map<Id,Subproject__c> subrojectMap = new Map<Id,Subproject__c>([Select id, Rush__c, Estimated_Install_Date_EID__c, Contract_Roll_Called__c from Subproject__c where id in: subprojectIdSet]);                
                //get the subproject record of all the milestone
                Map<Id,Subproject__c> subrojectMap = new Map<Id,Subproject__c>(  IMP_Project_Utility.retrieveSubProjectsBySet(IMP_Project_Utility.QUERY_NAME_ID, null, subprojectIdSet) );
                IMP_Project_Utility.createProjectActivity(subrojectMap,milestoneDefinitionProjectMap);                              
            }
        } 
        else if(Trigger.isUpdate)
        {
            
        } 
        else if(Trigger.isDelete)
        {
            
        } 
        else if(Trigger.isUndelete)
        {
            
        }
        
    }
}