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
12/22/15     Venkata Shrivol     Added logic to update child project log records with confidential field in BEFORE UPDATE context.
01/05/16     Venkata Shrivol     RQ-05996, Added IMP_UpdCDKAssigneeOnTaskActivty_Handler to update cdk assignee changes 
------------------------------------------------------------*/
//2016-02-25- anirudh.singh@cdk.com- Modified the Trigger to bring it up to standards as per Request RQ-06018.
//2016-05-02- venkata.shrivol@cdk.com -commented out all_CheckRecursive before calling the trigger contexts. 
trigger IMP_SubProject on SubProject__c(before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
    if(Trigger.isBefore)
    {
        //if((ALL_CheckRecursive.runCodeBlockOnce('SubProject_BeforeUpdate') || test.isRunningTest()) && Trigger.isUpdate) 
        if(Trigger.isUpdate)
        {
            IMP_SubProject_Handler.processSubProjectsBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
    else if(Trigger.isAfter)
    {
        //if((ALL_CheckRecursive.runCodeBlockOnce('SubProject_AfterInsert') || test.isRunningTest()) && Trigger.isInsert)
        if(Trigger.isInsert)
        {
            IMP_SubProject_Handler.processSubProjectsAfterInsert(Trigger.New, Trigger.oldMap);
        }
       // else if((ALL_CheckRecursive.runCodeBlockOnce('SubProject_AfterUpdate') || test.isRunningTest()) && Trigger.isUpdate)
       else if(Trigger.isUpdate)
        {
            IMP_SubProject_Handler.processSubProjectsAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}