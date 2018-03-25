/*------------------------------------------------------------
Author:      Michael Lasala
Company:     Cloud Sherpas
Description: Consolidated Project Milestone triggers
Test Class:
History
10/20/14     Michael Lasala      Created
11/06/14     Samuel Oberes       Refactored: Removed IMP_IncrementMilestoneCounter_Handler.IncrementCounterField from the BEFORE UPDATE context because the same method is 
being called against the same Project Milestone object in the same context, but on a different trigger (IMP_IncrementMilestoneDelayedCounterField)
11/13/14    Samuel Oberes        Added IMP_IncrementActivityOrMilestone_Handler.IncrementCounterField in the before update context, relocating from the now inactive, soon to be deleted, IMP_IncrementMilestoneDelayedCounterField
04/01/15    Rey Austral          Set expected remaining duration to 0 if status is complete
05/06/15    Samuel Oberes       1) Added business rules exclusion logic 
                                2) Added invocation of error whenever a completed milestone is attempted to be deleted
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
            for(Project_Milestone__c milestoneToDelete : Trigger.oldMap.values())
            {
                if (milestoneToDelete.Status__c == IMP_Project_Utility.STATUS_COMPLETE && currentUserIsExcludedFromRules == false)
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