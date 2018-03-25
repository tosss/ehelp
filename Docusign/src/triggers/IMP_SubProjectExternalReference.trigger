/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Consolidated SubProject External Reference triggers
Test Class:
History
10/20/14    Michael Lasala      Created
------------------------------------------------------------*/
trigger IMP_SubProjectExternalReference on SubProject_External_Reference__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if (Trigger.isBefore) {
        
        if(Trigger.isInsert){
            
            //update the project field via trigger in the backend, rather than allowing the user to manually select the value of the project field while creating a new Project External Reference
            Set<Id> subProjectIds = new Set<Id>();
            List<SubProject_External_Reference__c> subprojectExternalToUpdate = new List<SubProject_External_Reference__c>();
            
            for(SubProject_External_Reference__c ser: Trigger.new){
                if(ser.SubProject__c != null){
                    subprojectExternalToUpdate.add(ser);
                    
                    //Add SubProject Id to set to be used for query in handler
                    subProjectIds.add(ser.SubProject__c);
                }
            }
            
            //Process records
            if(!subprojectExternalToUpdate.isEmpty()){
                //Update Project value on SubProject External Reference based on SubProject's Project
                IMP_Project_Utility.updateProjectField(null, null,subprojectExternalToUpdate,null, subProjectIds);
            }
            
        } else if(Trigger.isUpdate){
            
        } else if(Trigger.isDelete){
            
        }
        
    } else if (Trigger.isAfter) {
        
        if(Trigger.isInsert){
            
        } else if(Trigger.isUpdate){
            
        } else if(Trigger.isDelete){
            
        } else if(Trigger.isUndelete){
            
        }
        
    }
}