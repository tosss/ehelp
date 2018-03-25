/*------------------------------------------------------------
Author:      Michael Lasala
Company:     Cloud Sherpas
Description: Consolidated SubProject triggers
Test Class:
History
10/20/14     Michael Lasala      Created
10/22/14     Kimiko Roberto      Added IMP_DealerGroup_Handler
11/06/14     Samuel Oberes       Refactored:
                                 1) changed spelling of prjId to prjIds, but eventually removed it. Reason -> see #2
                                 2) replaced updateSubProjectFollower with setUsersAsFollower, but eventually removed its instance in the AFTER INSERT/UPDATE context because it is just a 
                                 duplicate (original found in this trigger >> IMP_SetUsersAsFollower)
11/11/14     Kimiko Roberto      Added IMP_AddSubProjectSite_Handler 
11/14/14     Samuel Oberes       Added IMP_SetUsersAsFollower_Handler.setUsersAsFollower in the after insert/update context, relocating from the now inactive, soon to be deleted, IMP_SetUsersAsFollower
11/17/14     Rey Austral         Added reparenting logic of subproject to a new project in the After Update context.
11/26/14     Kimiko Roberto      Added IMP_CMFManualPopulation_Handler.addCmfToSubprojExtRelatedEntity at after insert.
12/12/14     Kimiko Roberto      Added null checker and length checker for IMP_CMFManualPopulation_Handler at isUpdate and isInsert during isAfter
12/23/14     Samuel Oberes       Decommissioned After Insert/Update logic to generate a Subproject External Related Entity for the CMF__c, including the call to IMP_CMFManualPopulation_Handler
                                 Decommissioned After Insert/Update logic to generate a Subproject Site for an inserted/updated Main_Site__c (which is a field that will be eliminated during Phase 1 R3).
                                 Decommissioned Before Insert/Update logic to generate and stamp a Dealer_Group__c value on the Subproject record.  The Dealer_Group__c field will be eliminated during Phase 1 R3.
01/06/15     Samuel Oberes       1) In BEFORE-UPDATE context, added logic to check if SubProject_Status__c's value changed from 'some value' to 'closed' before proceeding.
                                 2) Applied the new implementation of IMP_Project_Utility.areAllMilestonesComplete, wherein 'incomplete milestone' error tagging is now per subproject, compared to before, 
                                    where it's a sweeping 'false' if 1 milestone among all subprojects was found incomplete.

02/06/15     Venkata Shrivol     Added IMP_updateDealStateRollCallDate_Handler
15/07/15     Vishal bandari      Added IMP_UpdateFormsOrder_Handler to update related formsOrder Fields
12/22/15     Venkata Shrivol	 Added logic to update child project log records with confidential field in BEFORE UPDATE context.
01/05/16     Venkata Shrivol	 RQ-05996, Added IMP_UpdCDKAssigneeOnTaskActivty_Handler to update cdk assignee changes 
------------------------------------------------------------*/
trigger IMP_SubProject on SubProject__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if (Trigger.isBefore) {

        if(Trigger.isInsert){
            
            // -------------------------------------------------------------
            // 12/23/14
            ////gets the top most parent of the main site and assigns it to the Dealer Group field
            //IMP_DealerGroup_Handler.assignDealerGroupCMFSP(Trigger.New);
            // -------------------------------------------------------------
            
        }
        
        else if(Trigger.isUpdate)
        {
			map<Id, SubProject__c> subProjectIdsToQuery = new map<Id, SubProject__c>();
			map<Id, SubProject__c> cdkAssigneeUpdateMap = new map<Id, SubProject__c>();
            Set<Id> subProjectIdsSet = new Set<Id>();
            List<Id> projectIdsList = new List<Id>();
            String oldStatus;
            String newStatus;
            for(SubProject__c newSubProject : Trigger.New)
            {
                // Only process records if:
                //   1) SubProject_Status__c changed from 'some value' to 'new value'
                //   2) SubProject_Status__c's new value == 'Closed'
                oldStatus = (Trigger.oldMap.get(newSubProject.Id).SubProject_Status__c == null ? 'NULL' : Trigger.oldMap.get(newSubProject.Id).SubProject_Status__c);
                newStatus = (newSubProject.SubProject_Status__c == null ? 'NULL' : newSubProject.SubProject_Status__c);
                if(oldStatus != newStatus && 
                   newStatus == IMP_Project_Utility.STATUS_CLOSED){

                    subProjectIdsSet.add(newSubProject.Id);
                }
                projectIdsList.add(newSubProject.Project__c);
                
                // 12/22/15 - venkata.shrivol@cdk.com 
                SubProject__c oldSub = Trigger.oldMap.get(newSubProject.Id);
            	if(newSubProject.Confidential__c != oldSub.Confidential__c)
            	{
            		subProjectIdsToQuery.put(newSubProject.Id, newSubProject);
            	}
            	if(newSubProject.Training_Implementation_Client_Mgr__c != oldSub.Training_Implementation_Client_Mgr__c 
            		|| newSubProject.Project_Manager__c != oldSub.Project_Manager__c)
            	{
            		cdkAssigneeUpdateMap.put(newSubProject.Id, newSubProject);
            	}
            	
            }
			
            if(!subProjectIdsSet.isEmpty()){
                // Retrieve all related Project Milestones to SubProject
                // Validate if related Project Milestones' status == Complete

                // This map will contain subProject Ids (as the key) and a boolean (as the value) telling if they're already complete or not.
                Map<Id, Boolean> subProjectIdToMilestonesCompleteValueMap = IMP_Project_Utility.areAllMilestonesComplete(subProjectIdsSet);

                for (Id subProjectId : subProjectIdToMilestonesCompleteValueMap.keySet()) {
                    if (subProjectIdToMilestonesCompleteValueMap.get(subProjectId) == false) {

                        //Return error if at least 1 related Project Milestone status != Complete
                        Trigger.newMap.get(subProjectId).addError('All Milestone Statuses should be Complete before SubProject Status can be set to Complete.');
                    }
                }
            }
            
            ////checks if the main site field changed; if a change is detected we're going to reassign the dealer group field
            ////check also if the project field has been changed; if change and the new assign project is already closed , return an error
            //List<SubProject__c> updatedSubProjectList = new List<SubProject__c>();
            Map<Id,Project__c> mapProject = new Map<Id, Project__c>([Select Id,Name,Project_Status__c from Project__c where Id in :projectIdsList]);
            for(SubProject__c subproject : Trigger.New){
                SubProject__c oldsubPrj = Trigger.oldMap.get(subproject.Id);
                //if(subproject.Main_Site__c != oldsubPrj.Main_Site__c && subproject.Main_Site__c != null){
                //    updatedSubProjectList.add(subproject);
                //}
                
                //check if the project field has been changed
                if(subproject.Project__c != oldsubPrj.Project__c)
                {                    
                    //check if the new assign project is not closed, if yes return an error
                    Project__c proj = mapProject.get(subproject.Project__c);
                    if (IMP_Project_Utility.STATUS_CLOSED.equals(proj.Project_Status__c)) {
                        subproject.Project__c.addError('You cannot change the Project value to a project with a closed status.');
                    }
                }
            }
            // -------------------------------------------------------------
            // 12/23/14
            //if(!updatedSubProjectList.isEmpty())
            //{
            //    //gets the top most parent of the main site and assigns it to the Dealer Group field
            //    IMP_DealerGroup_Handler.assignDealerGroupCMFSP(updatedSubProjectList);
                
            //}
            // -------------------------------------------------------------
            
            
            // ------Trigger to update the child Project log Records----START--------/
            list<Project_Log__c> projLogsToUpdate = new list<Project_Log__c>();
            if(subProjectIdsToQuery.size()>0)
            {
            	for(Project_Log__c prjLog:[
	            	select Id, Sub_Project_Action_Items__c, Sub_Project_Change_Request__c,
	            	SubProject_Confidential__c, Sub_Project_Lessons_Learned__c,
	            	Sub_Project_Issue__c, Sub_Project_Risk__c
	            	from Project_Log__c 
	            	where Sub_Project_Action_Items__c IN:subProjectIdsToQuery.keySet() 
	            	or
	            	Sub_Project_Change_Request__c IN:subProjectIdsToQuery.keySet() 
	            	or
	            	Sub_Project_Issue__c IN:subProjectIdsToQuery.keySet() 
	            	or
	            	Sub_Project_Lessons_Learned__c IN:subProjectIdsToQuery.keySet() 
	            	or
	            	Sub_Project_Risk__c IN:subProjectIdsToQuery.keySet() 
            	  ])
	            {
	            	SubProject__c thisSubProject = 
	            	subProjectIdsToQuery.get(prjLog.Sub_Project_Action_Items__c)!=null ? subProjectIdsToQuery.get(prjLog.Sub_Project_Action_Items__c) : 
	            	subProjectIdsToQuery.get(prjLog.Sub_Project_Change_Request__c)!=null ? subProjectIdsToQuery.get(prjLog.Sub_Project_Change_Request__c) :
	            	subProjectIdsToQuery.get(prjLog.Sub_Project_Lessons_Learned__c)!=null ? subProjectIdsToQuery.get(prjLog.Sub_Project_Lessons_Learned__c) :
	            	subProjectIdsToQuery.get(prjLog.Sub_Project_Risk__c)!=null ? subProjectIdsToQuery.get(prjLog.Sub_Project_Risk__c) :
	            	subProjectIdsToQuery.get(prjLog.Sub_Project_Issue__c)!=null ? subProjectIdsToQuery.get(prjLog.Sub_Project_Issue__c) :
	            	null;
	            	boolean confValue = thisSubProject!=null ? thisSubProject.Confidential__c : false;
	            	if(confValue!=prjLog.SubProject_Confidential__c)
	            	{
	            	 	prjLog.SubProject_Confidential__c = confValue;
	            	 	projLogsToUpdate.add(prjLog);
	            	}
	            	 					
	            }
	            try{
	            	update projLogsToUpdate;	
	            }
	            catch(Exception ex){
	            	system.debug('----Exception----'+ex);
	            }
	            
            }
            // ------Trigger to update the child Project log Records----End--------//
            
            //--01/05/16---Update CDK Assignee on Activities and Tasks from SubProject Update---START---/
            if(!cdkAssigneeUpdateMap.isEmpty())
            {
            	IMP_UpdCDKAssigneeOnTaskActivty_Handler.updateTasksAndActivities(cdkAssigneeUpdateMap);
            }
            //--01/05/16---Update CDK Assignee on Activities and Tasks from SubProject Update----END--//
        }
        
        else if(Trigger.isDelete){
            
        }
        
    }
    
    else if (Trigger.isAfter) {
        
        if(Trigger.isInsert || Trigger.isUpdate){
            Set<Id>prjIds = new Set<Id>();
            
            //get projet id to be used to set users as followers
            for(SubProject__c subPrj : Trigger.New){
                prjIds.add(subPrj.Project__c);
            }
            
            //add Project Manager, Training Implementation Client Mgr and HW Specialist PFW if there is assigned and if still not following the project or subproject
            //IMP_SetUsersAsFollower_Handler.setUsersAsFollower(Trigger.New, Trigger.oldMap, prjIds, Trigger.isInsert, Trigger.isUpdate);
        	
        	/* Venkata - Update Roll Called date of Deal State from Contract_RollCalled of Sub_Project -START */
            String tempString = '';
            Date oldValue = null;
            Map<String, Date> subProjectMap =  new Map<String, Date>();
            for(SubProject__c subProject : Trigger.new)
            {
            	if(Trigger.isInsert)
            	{
            		if(subProject.Contract_Roll_Called__c!= null && subProject.Deal_Id__c!= null)
            		{
            			tempString = subProject.Deal_Id__c;
            			if(tempString.contains(';'))
            			{
            				for(String str: tempString.split(';'))
            				{
            					subProjectMap.put(str, subProject.Contract_Roll_Called__c);
            				}
            			}
            			else 
            			{
            				subProjectMap.put(subProject.Deal_Id__c, subProject.Contract_Roll_Called__c);
            			}
	            		
	            	}
            	}
            	else
            	{
            		oldValue = Trigger.oldMap.get(subProject.id).Contract_Roll_Called__c;
            	
	            	if(subProject.Contract_Roll_Called__c != oldValue && subProject.Deal_Id__c!= null)
	            	{
	            		tempString = subProject.Deal_Id__c;
            			if(tempString.contains(';'))
            			{
            				for(String str: tempString.split(';'))
            				{
            					subProjectMap.put(str, subProject.Contract_Roll_Called__c);
            				}
            			}
            			else 
            			{
            				subProjectMap.put(subProject.Deal_Id__c, subProject.Contract_Roll_Called__c);
            			}
	            	}
            	}
            }
            system.debug('---Roll Called Date Map of SubProject------'+subProjectMap);
            
            if(!subProjectMap.isEmpty()){
            	IMP_updateDealStateRollCallDate_Handler.updateRollCallDate(subProjectMap);
            }
            
            /* Update Roll Called date of Deal State from Contract_RollCalled of Sub_Project -END */
        }
        
        if(Trigger.isInsert)
        {
        	
            // -------------------------------------------------------------
            // 12/23/14
            ////creates a new SubProjectSite__c according to the subproject's Main_Site__c(Account).
            //IMP_AddSubProjectSite_Handler.addSubProjectSite(Trigger.New);
            
            ////Populates the SubProject_External_Related_Entity__c with values from the SubProject__c whenever CMF__c changed
            //List<SubProject__c> updatedSubProjectListCMF = new List<SubProject__c>();
            //for(SubProject__c subproject : Trigger.New){
            
            //    if(subproject.CMF__c != null && subproject.CMF__c.length() > 12){
            //        subproject.CMF__c.addError('CMF max length can not be greater than 12.');
            //    }
            //    else if(subproject.CMF__c != null){
            //        updatedSubProjectListCMF.add(subproject);
            //    }
            //}
            //IMP_CMFManualPopulation_Handler.addCmfToSubprojExtRelatedEntity(null, updatedSubProjectListCMF);
            // -------------------------------------------------------------
        }
        
        else if(Trigger.isUpdate)
        {
        	//set<Id> subProjectIds = new set<Id>();
            ////check if the subproject's main site is changed and not null; if changed and is not null we are going to create a new SubProjectSite__c according to the subproject's Main_Site__c(Account).
            //List<SubProject__c> updatedSubProjectList = new List<SubProject__c>();
            Map<Id,SubProject__c> changeParentList = new Map<Id,SubProject__c>();
            for(SubProject__c subproject : Trigger.New)
            {
                SubProject__c oldsubPrj = Trigger.oldMap.get(subproject.Id);
                
                //if(subproject.Main_Site__c != oldsubPrj.Main_Site__c && subproject.Main_Site__c != null){
                //    updatedSubProjectList.add(subproject);
                //}
                
                //check if the project field has been changed
                if(subproject.Project__c != oldsubPrj.Project__c){
                    changeParentList.put(subproject.id,subproject);
                }
                
             /*   if(subproject.Confidential__c && subproject.Confidential__c!= oldsubPrj.Confidential__c)
                {
                	subProjectIds.add(subproject.Id);
                }*/
            }
            // -------------------------------------------------------------
            // 12/23/14
            //if(!updatedSubProjectList.isEmpty())
            //{
            //    //after identifying that Main_Site__c has changed we will create a new SubProjectSite__c according to the subproject's Main_Site__c(Account).
            //    IMP_AddSubProjectSite_Handler.addSubProjectSite(updatedSubProjectList);
                
            //}
            // -------------------------------------------------------------
            if (!changeParentList.isEmpty()) {
                IMP_ReParentingSubProject_Helper.executeReParent(changeParentList, Trigger.oldMap);
            }
            // -------------------------------------------------------------
            // 12/23/14
            //List<SubProject__c> updatedSubProjectListCMF = new List<SubProject__c>();
            //for(SubProject__c subproject : Trigger.New){
            //    SubProject__c oldsubPrj = Trigger.oldMap.get(subproject.Id);
                
            //    if(subproject.CMF__c != oldsubPrj.CMF__c && subproject.CMF__c != null && subproject.CMF__c.length() < 13){
            //        updatedSubProjectListCMF.add(subproject);
            //    }
            //    else if(subproject.CMF__c != null && subproject.CMF__c.length() > 12){
            //        subproject.CMF__c.addError('CMF max length can not be greater than 12.');
            //    }
            //}
            //// captures subprojects with updated CMFs and adds them to the SubProject_External_Related_Entity__c 
            //IMP_CMFManualPopulation_Handler.addCmfToSubprojExtRelatedEntity(Trigger.oldMap, updatedSubProjectListCMF);
            // -------------------------------------------------------------
           
          //added by vishal.bandari@cdk.com on 15 July 2015- update fields in Related FormsOrder Object
          IMP_UpdateFormsOrder_Handler.updateFormOrders(Trigger.NewMap,Trigger.oldMap);
          
          /*if(!subProjectIds.isEmpty())
          {
          		IMP_SubProjectApexSharing_Handler.getRequiredRecsFromSubProject(subProjectIds, null, true);	
          }*/
        }
        
        else if(Trigger.isDelete){
            
        }
        
        else if(Trigger.isUndelete){
            
        }
        
    }
}