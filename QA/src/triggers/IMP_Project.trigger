/*------------------------------------------------------------
Author: Karl Simon
Company: Cloud Sherpas       
Description:  Creating Project checklists for new project
Test Class: IMP_ProjectChecklistCreate_Test
History
09/10/14    Karl Simon        Created
10/22/14    Kimiko Roberto    Added IMP_DealerGroup_Handler
11/26/14    Samuel Oberes     Added IMP_ProjectButtonActions_Handler.removeAssociatedRecords at the BEFORE-DELETE context
12/23/14    Samuel Oberes     Commented out codes as suggested in Action Item 62
11/03/15    Venkata Shrivol   Commented out the IMP_ProjectChecklistCreate_Handler reference in the code
------------------------------------------------------------*/
trigger IMP_Project on Project__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger.isBefore){
    
        if (Trigger.isInsert){
            // -------------------------------------------------------------
            // 12/23/14
            // Codes within this block is commented out because "we will NO LONGER check against top level parents of added sites against the dealer group top level nor check for a changed Main_Site__c value" (refer to Action Item 58)
            //
            //gets the top most parent of the main site and assigns it to the Dealer Group field
            //IMP_DealerGroup_Handler.assignDealerGroupCMF(Trigger.New);
            // -------------------------------------------------------------
        } else if(Trigger.isUpdate){
            // -------------------------------------------------------------
            // 12/23/14
            // Codes within this block is commented out because "we will NO LONGER check against top level parents of added sites against the dealer group top level nor check for a changed Main_Site__c value" (refer to Action Item 58)
            //
            //checks if the main site field changed; if a change is detected we're going to reassign the dealer group field
            //List<Project__c> updatedProjectList = new List<Project__c>();
            //for(Project__c project : Trigger.New){
            //    Project__c oldPrj = Trigger.oldMap.get(project.Id);
            //    if(project.Main_Site__c != oldPrj.Main_Site__c && project.Main_Site__c != null){
            //        updatedProjectList.add(project);
            //    }
            //}
            //if(!updatedProjectList.isEmpty()){
            //    //gets the top most parent of the main site and assigns it to the Dealer Group field
            //    IMP_DealerGroup_Handler.assignDealerGroupCMF(updatedProjectList);
            //}
            // -------------------------------------------------------------
        } else if (Trigger.isDelete) {
            IMP_ProjectButtonActions_Handler.removeAssociatedRecords(Trigger.Old);

        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            //IMP_ProjectChecklistCreate_Handler.createChecklist(Trigger.New);
        }
    }
}