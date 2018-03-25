/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas       
Description: Class handling the incrementation of Counter field of the ff: objects:
             1) Project_Activity__c
             2) Project_Milestone__c

             USE THIS CLASS ONLY ON TRIGGERS FOR THE ABOVE MENTIONED OBJECTS!
Calling Trg: IMP_ProjectActivity
             IMP_ProjectMilestone
Test Class:  IMP_IncrementActivityCounter_Test
			 IMP_IncrementMilestoneCounter_Test
History:
11/06/14     Samuel Oberes      Created
11/13/14	 Samuel Oberes		Renamed from IMP_IncrementActOrMstone_Handler to IMP_IncrementActivityOrMilestone_Handler
------------------------------------------------------------*/
public class IMP_IncrementActivityOrMilestone_Handler {
    public static void IncrementCounterField(Map<Id, SObject> oldSobjectMap, List<SObject> newSobjectList) {
        //iterate through all the Project Activity/Project Milestone records and increment the value of Planned_Start_Dt_Delayed_Count__c and/or Planned_End_Dt_Delayed_Count__c by 1
        //if the condition are met (e.g. the date was delayed beyond the previous value)
        for (SObject activityOrMilestone : newSobjectList) {

            //get the activity/milestone value before the update
            SObject oldActivityOrMilestone = oldSobjectMap.get((Id)activityOrMilestone.get('Id'));
            Date oldStartDate = Date.valueOf(oldActivityOrMilestone.get('Planned_Start_Date__c'));
            Date newStartDate = Date.valueOf(activityOrMilestone.get('Planned_Start_Date__c'));
            Date oldEndDate   = Date.valueOf(oldActivityOrMilestone.get('Planned_End_Date__c'));
            Date newEndDate   = Date.valueOf(activityOrMilestone.get('Planned_End_Date__c'));

            if(newStartDate > oldStartDate) {
                //initialize the value to 0 if the field is null to avoid error
                if(Integer.valueOf(activityOrMilestone.get('Planned_Start_Dt_Delayed_Count__c')) == null) {
                    activityOrMilestone.put('Planned_Start_Dt_Delayed_Count__c', 0);
                }

                //increment the value of Planned_Start_Dt_Delayed_Count__c by 1
                activityOrMilestone.put('Planned_Start_Dt_Delayed_Count__c', Integer.valueOf(activityOrMilestone.get('Planned_Start_Dt_Delayed_Count__c')) + 1);
            }

            if(newEndDate > oldEndDate) {
                //initialize the value to 0 if the field is null to avoid error
                if(Integer.valueOf(activityOrMilestone.get('Planned_End_Dt_Delayed_Count__c')) == null) {
                    activityOrMilestone.put('Planned_End_Dt_Delayed_Count__c', 0);
                }

                //increment the value of Planned_End_Dt_Delayed_Count__c by 1
                activityOrMilestone.put('Planned_End_Dt_Delayed_Count__c', Integer.valueOf(activityOrMilestone.get('Planned_End_Dt_Delayed_Count__c')) + 1);
            }
        }
    }
}