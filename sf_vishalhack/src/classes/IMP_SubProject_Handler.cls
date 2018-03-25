//2016-02-25- anirudh.singh@cdk.com- Created this handler class for the Trigger IMP_SubProject to bring it up to standards as per Request RQ-06018.
//2016-05-18 -venkata.shrivol@cdk.com  - Changed the confidential field to Confidentiality Status -RQ-05471
//2016-05-12 -venkata.shrivol@cdk.com -Commented Project__c reference to the code RQ-08305
//2017-04-06 - vishal.bandari@cdk.com - comment out code to allow Subproject Close with Milestone Open - RQ-08906
public class IMP_SubProject_Handler
{
   public static void processSubProjectsBeforeUpdate(Map<Id, SubProject__c> newSubProjectsMap, Map<Id, SubProject__c> oldSubProjectsMap)
    {
        system.debug('Start processSubProjectsBeforeUpdate---->');
        
        updateProjectLogRecords(newSubProjectsMap, oldSubProjectsMap);
        
        system.debug('End processSubProjectsBeforeUpdate---->');
    }
    
    public static void processSubProjectsAfterInsert(List<SubProject__c> newSubProjectsList, Map<Id, SubProject__c> oldSubProjectsMap)
    {
        system.debug('Start processSubProjectsAfterInsert---->');
        
        updateRollCallDate(newSubProjectsList, oldSubProjectsMap);
        
        system.debug('End processSubProjectsAfterInsert---->');
    }
    
    public static void processSubProjectsAfterUpdate(Map<Id, SubProject__c> newSubProjectsMap, Map<Id, SubProject__c> oldSubProjectsMap)
    {
        system.debug('Start processSubProjectsAfterUpdate---->');
        
        updateRollCallDate(newSubProjectsMap.values(), oldSubProjectsMap);
        updateFormOrders(newSubProjectsMap, oldSubProjectsMap);
        
       shareConfidentialSubProjects(newSubProjectsMap.values(), oldSubProjectsMap);
        system.debug('End processSubProjectsAfterUpdate---->');
    }
    
    private static void updateProjectLogRecords(Map<Id, SubProject__c> newSubProjectsMap, Map<Id, SubProject__c> oldSubProjectsMap)
    {
        system.debug('Start updateProjectLogRecords---->');
        
        //This Map holds the SubProject Ids and Records to be used to query Project Logs.
        Map<Id, SubProject__c> subProjectsToQueryMap=new Map<Id, SubProject__c>();
        
        //This Map holds the SubProject Ids and Records to be used to update activities and tasks for CDK Assignee value from SubProject record.
        Map<Id, SubProject__c> subProjectsToUpdateCDKAssigneeMap=new Map<Id, SubProject__c>();
        
        //This Set holds the filtered SubProject Ids.
        //Id will be added to this Set only if (1) SubProject_Status__c changed from 'some value' to 'new value' or (2) SubProject_Status__c's new value=='Closed'.
        Set<Id> subProjectIds=new Set<Id>();
        
        //2016-03-02- anirudh.singh@cdk.com- Changed the List to Set, as it is holding Ids and there should be no duplicate Ids.
        //This Set holds the Project Ids.
        //Set<Id> projectIds=new Set<Id>();
        
        //This String holds the value of the Old Status of the SubProject.
        String oldStatus;
        
        //This String holds the value of the New Status of the SubProject.
        String newStatus;
        
        //Iterate over the list of the new SubProjects.
        for(SubProject__c subProjectRecord: newSubProjectsMap.values())
        {
            //This variable holds the value of the old SubProject Record.
            SubProject__c oldSubProjectRecord=oldSubProjectsMap.get(subProjectRecord.Id);
            
            //If the old Status was Null, then NULL is assigned to oldStatus, else the value of the field is assigned.
            oldStatus=(oldSubProjectRecord.SubProject_Status__c==null ? 'NULL' : oldSubProjectRecord.SubProject_Status__c);
            
            //If new Status is Null, then NULL is assigned to newStatus, else the value of the field is assigned.
            newStatus=(subProjectRecord.SubProject_Status__c==null ? 'NULL' : subProjectRecord.SubProject_Status__c);
            
            //If the old statuc and new status are different and new status is Closed.
            //Then, SubProject Id is added to the subProjectIds Set.
            if(oldStatus!=newStatus && newStatus==IMP_Project_Utility.STATUS_CLOSED)
            {
                subProjectIds.add(subProjectRecord.Id);
            }
            
            //Project Id is added to the projectIds set.
            //projectIds.add(subProjectRecord.Project__c);
            
            //2015-12-22- venkata.shrivol@cdk.com
            //SubProject Id and Record is added to the subProjectsToQueryMap if the Confidential checkbox value on the new and the old record is different.
            if(subProjectRecord.Confidentiality_Status__c!=oldSubProjectRecord.Confidentiality_Status__c)
            {
                subProjectsToQueryMap.put(subProjectRecord.Id, subProjectRecord);
            }
            
            //SubProject Id and Record is added to the subProjectsToUpdateCDKAssigneeMap, 
            //if Training_Implementation_Client_Mgr__c value for the new record and the old record is different, or 
            //if the Project_Manager__c value for the new record and the old record is different.
            if(subProjectRecord.Training_Implementation_Client_Mgr__c!=oldSubProjectRecord.Training_Implementation_Client_Mgr__c 
               || subProjectRecord.Project_Manager__c!=oldSubProjectRecord.Project_Manager__c)
            {
                subProjectsToUpdateCDKAssigneeMap.put(subProjectRecord.Id, subProjectRecord);
            }
        }
        
        //04-06-2017 - vishal.bandari@cdk.com - comment out code to allow Subproject Close with Milestone Open - RQ-08906
        //Return error if at least 1 related Project Milestone status!=Complete.
        /*if(!subProjectIds.isEmpty())
        {
            //Retrieve all related Project Milestones to SubProject
            //Validate if related Project Milestones' status==Complete
            //This Map will contain subProject Ids (as the key) and a boolean (as the value) telling if they're already complete or not.
            Map<Id, Boolean> subProjectIdToMilestonesCompleteValueMap=IMP_Project_Utility.areAllMilestonesComplete(subProjectIds);
            
            for(Id subProjectId: subProjectIdToMilestonesCompleteValueMap.keySet())
            {
                if(subProjectIdToMilestonesCompleteValueMap.get(subProjectId)==false)
                {
                    //Return error if at least 1 related Project Milestone status!=Complete.
                    newSubProjectsMap.get(subProjectId).addError('All Milestone Statuses should be Complete before SubProject Status can be set to Complete.');
                }
            }
        }*/
        
        //checks if the main site field changed; if a change is detected we're going to reassign the dealer group field
        //check also if the project field has been changed; if change and the new assign project is already closed, return an error
        //Map<Id, Project__c> projectMap=new Map<Id, Project__c>([SELECT Id, Name, Project_Status__c FROM Project__c WHERE Id IN :projectIds]);
       //2016-12-05 -venkata.shrivol@cdk.com -commented this code RQ-08305
       /* for(SubProject__c subProjectRecord: newSubProjectsMap.values())
        {
            //check if the project field has been changed.
            if(subProjectRecord.Project__c!=oldSubProjectsMap.get(subProjectRecord.Id).Project__c)
            {
                //check if the new assign project is not closed, if yes return an error.
                if(IMP_Project_Utility.STATUS_CLOSED.equals(projectMap.get(subProjectRecord.Project__c).Project_Status__c))
                {
                    subProjectRecord.Project__c.addError('You cannot change the Project value to a project with a closed status.');
                }
            }
        }*/
        
        //Update the child Project log Records.
        List<Project_Log__c> projLogsToUpdateList=new List<Project_Log__c>();
        
        if(subProjectsToQueryMap.size()>0)
        {
            for(Project_Log__c projectLogRecord: [
                SELECT Id, Sub_Project_Action_Items__c, Sub_Project_Change_Request__c,
                SubProject_Confidential__c, Sub_Project_Lessons_Learned__c, SubProject_Confidentiality_Status__c,
                Sub_Project_Issue__c, Sub_Project_Risk__c
                FROM Project_Log__c 
                WHERE Sub_Project_Action_Items__c IN :subProjectsToQueryMap.keySet() 
                OR
                Sub_Project_Change_Request__c IN :subProjectsToQueryMap.keySet() 
                OR
                Sub_Project_Issue__c IN :subProjectsToQueryMap.keySet() 
                OR
                Sub_Project_Lessons_Learned__c IN :subProjectsToQueryMap.keySet() 
                OR
                Sub_Project_Risk__c IN :subProjectsToQueryMap.keySet() 
            ])
            {
                SubProject__c thisSubProject=
                    subProjectsToQueryMap.get(projectLogRecord.Sub_Project_Action_Items__c)!=null ? subProjectsToQueryMap.get(projectLogRecord.Sub_Project_Action_Items__c): 
                subProjectsToQueryMap.get(projectLogRecord.Sub_Project_Change_Request__c)!=null ? subProjectsToQueryMap.get(projectLogRecord.Sub_Project_Change_Request__c) :
                subProjectsToQueryMap.get(projectLogRecord.Sub_Project_Lessons_Learned__c)!=null ? subProjectsToQueryMap.get(projectLogRecord.Sub_Project_Lessons_Learned__c) :
                subProjectsToQueryMap.get(projectLogRecord.Sub_Project_Risk__c)!=null ? subProjectsToQueryMap.get(projectLogRecord.Sub_Project_Risk__c) :
                subProjectsToQueryMap.get(projectLogRecord.Sub_Project_Issue__c)!=null ? subProjectsToQueryMap.get(projectLogRecord.Sub_Project_Issue__c) :
                null;
                
                //Boolean confidentialFieldValue=thisSubProject!=null ? thisSubProject.Confidential__c: false;
                
                if(thisSubProject.Confidentiality_Status__c !=projectLogRecord.SubProject_Confidentiality_Status__c)
                {
                    projectLogRecord.SubProject_Confidentiality_Status__c=thisSubProject.Confidentiality_Status__c;
                    projLogsToUpdateList.add(projectLogRecord);
                }
            }
            
            try
            {
                update projLogsToUpdateList;    
            }
            catch(Exception ex)
            {
                system.debug('Exception---->'+ex);
            }
        }
        
        //2016-01-05- Update CDK Assignee on Activities and Tasks from SubProject Update.
        if(!subProjectsToUpdateCDKAssigneeMap.isEmpty())
        {
            IMP_UpdCDKAssigneeOnTaskActivity_Handler.updateTasksAndActivities(subProjectsToUpdateCDKAssigneeMap);
        }
        
        system.debug('End updateProjectLogRecords---->');
    }
    
    private static void updateRollCallDate(List<SubProject__c> newSubProjectsList, Map<Id, SubProject__c> oldSubProjectsMap)
    {
        system.debug('Start updateRollCallDate---->');
        
        //Set<Id> projectIds=new Set<Id>();
        
        //get projet id to be used to set users as followers
        /*for(SubProject__c subProjectRecord: newSubProjectsList)
        {
            projectIds.add(subProjectRecord.Project__c);
        }*/
        
        //Venkata - Update Roll Called date of Deal State from Contract_RollCalled of Sub_Project.
       String subProjectDealId='';
        Map<String, Date> dealIdAndContractRollCalledMap=new Map<String, Date>();
        
        //2016-03-03- anirudh.singh@cdk.com- Commented the below variable and declared it inside the Else block of the FOR Loop, 
        //- as it was only used inside ELSE Block and the scope should be in that only.
        //Date contractRollCalledOldValue=null;
        
        for(SubProject__c subProjectRecord: newSubProjectsList)
        {
            //For after insert, old Map will be Null.
            if(oldSubProjectsMap==Null)
            {
                if(subProjectRecord.Contract_Roll_Called__c!=null && subProjectRecord.Deal_Id__c!=null)
                {
                    subProjectDealId=subProjectRecord.Deal_Id__c;
                    
                    if(subProjectDealId.contains(';'))
                    {
                        for(String str: subProjectDealId.split(';'))
                        {
                            dealIdAndContractRollCalledMap.put(str, subProjectRecord.Contract_Roll_Called__c);
                        }
                    }
                    else 
                    {
                        dealIdAndContractRollCalledMap.put(subProjectRecord.Deal_Id__c, subProjectRecord.Contract_Roll_Called__c);
                    }
                }
            }
            else
            {
                Date contractRollCalledOldValue=oldSubProjectsMap.get(subProjectRecord.id).Contract_Roll_Called__c;
                
                if(subProjectRecord.Contract_Roll_Called__c!=contractRollCalledOldValue && subProjectRecord.Deal_Id__c!=null)
                {
                    subProjectDealId=subProjectRecord.Deal_Id__c;
                    
                    if(subProjectDealId.contains(';'))
                    {
                        for(String str: subProjectDealId.split(';'))
                        {
                            dealIdAndContractRollCalledMap.put(str, subProjectRecord.Contract_Roll_Called__c);
                        }
                    }
                    else 
                    {
                        dealIdAndContractRollCalledMap.put(subProjectRecord.Deal_Id__c, subProjectRecord.Contract_Roll_Called__c);
                    }
                }
            }
        }
        
        if(!dealIdAndContractRollCalledMap.isEmpty())
        {
            IMP_updateDealStateRollCallDate_Handler.updateRollCallDate(dealIdAndContractRollCalledMap);
        }
        
        system.debug('End updateRollCallDate---->');
    }
    
    private static void updateFormOrders(Map<Id, SubProject__c> newSubProjectsMap, Map<Id, SubProject__c> oldSubProjectsMap)
    {
        system.debug('Start updateFormOrders---->');
        
       /* Map<Id, SubProject__c> filteredSubProjectMap=new Map<Id, SubProject__c>();
        //Set<Id> subProjectIds=new Set<Id>();
        
        for(SubProject__c subProjectRecord: newSubProjectsMap.values())
        {
            SubProject__c oldsubPrj=oldSubProjectsMap.get(subProjectRecord.Id);
            
            //check if the project field has been changed
            if(subProjectRecord.Project__c!=oldsubPrj.Project__c)
            {
                filteredSubProjectMap.put(subProjectRecord.Id, subProjectRecord);
            }
            
            //if(subProjectRecord.Confidential__c && subProjectRecord.Confidential__c!= oldsubPrj.Confidential__c)
            //{
            //  subProjectIds.add(subProjectRecord.Id);
            //}
        }
        
        if(!filteredSubProjectMap.isEmpty())
        {
            IMP_ReParentingSubProject_Helper.executeReParent(filteredSubProjectMap, oldSubProjectsMap);
        }*/
        
        //added by vishal.bandari@cdk.com on 15 July 2015- update fields in Related FormsOrder Object
        IMP_UpdateFormsOrder_Handler.updateFormOrders(newSubProjectsMap, oldSubProjectsMap);
        
        //if(!subProjectIds.isEmpty())
        //{
        //  IMP_SubProjectApexSharing_Handler.getRequiredRecsFromSubProject(subProjectIds, null, true); 
        //}
        
       system.debug('End updateFormOrders---->');
    }
    
    private static void shareConfidentialSubProjects(list<SubProject__c> newSubProjects, map<Id, SubProject__C> oldmap)
    {
        set<Id> sharingSubProjectIds = new set<Id>();
        set<Id> deletingSharedSubProjectIds = new set<Id>();
        set<Id> ownerIds = new set<Id>();
        boolean profilesToByPass = IMP_Project_Utility.profileCanByPass('SubProject_Sharing',UserInfo.getProfileId());
        for(SubProject__c subPrj:newSubProjects)
        {
            SubProject__c oldSubPrj = oldmap.get(subPrj.Id);
            if( subPrj.Confidentiality_Status__c != oldSubPrj.Confidentiality_Status__c  )
            {
                if(subPrj.Confidentiality_Status__c == 'Restricted')
                {
                    sharingSubProjectIds.add(subPrj.Id);
                }
                else if(oldSubPrj.Confidentiality_Status__c == 'Restricted')
                {
                    deletingSharedSubProjectIds.add(subPrj.Id);
                }
                ownerIds.add(subPrj.OwnerId);
             }
        }
        
        //For Sharing the records
            if(!sharingSubProjectIds.isEmpty())
            {
                IMP_SubProjectApexSharing_Handler.getRequiredRecsFromSubProject(sharingSubProjectIds, null, ownerIds, true);
            }
            
            //For Deleting the shared records
            if(!deletingSharedSubProjectIds.isEmpty())
            {
                set<Id> userIdOrGroupIdsToDeleteShare = IMP_SubProjectApexSharing_Handler.getCDKContactUserIdsFromSubProject(deletingSharedSubProjectIds, ownerIds);
                if(userIdOrGroupIdsToDeleteShare!=null && !userIdOrGroupIdsToDeleteShare.isEmpty())
                {
                    IMP_SubProjectApexSharing_Handler.deleteManuallySharedRecsThroughApex(deletingSharedSubProjectIds,userIdOrGroupIdsToDeleteShare,'SubProject__Share' );
                    /*set<ID> ProjectLogIDs = IMP_SubProjectApexSharing_Handler.getProjectLogRecordsFromSubProject(deletingSharedSubProjectIds);
                    if(ProjectLogIDs!=null && !ProjectLogIDs.isEmpty())
                    {
                        IMP_SubProjectApexSharing_Handler.deleteManuallySharedRecsThroughApex(deletingSharedSubProjectIds,userIdOrGroupIdsToDeleteShare,'Project_Log__Share' ); 
                    }*/
                }
                
                
            }
    }
}