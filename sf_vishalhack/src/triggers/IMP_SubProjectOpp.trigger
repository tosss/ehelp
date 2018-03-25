/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: Consolidated SubProjectOpp triggers
Test Class:
History
10/20/14    Michael Lasala      Created
12/15/16    Venkata Shrivol		commented the project object reference RQ-08305
-----------------------------------------------------------*/
trigger IMP_SubProjectOpp on SubProjectOpp__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	if (Trigger.isBefore) {
		
		if(Trigger.isInsert){
			
			Set<Id> subProjectIds = new Set<Id>();
            List<SubProjectOpp__c> opportunitiesToUpdate = new List<SubProjectOpp__c>();
            
            for(SubProjectOpp__c spo: Trigger.new){
                if(spo.SubProject__c != null){
                    opportunitiesToUpdate.add(spo);
                    
                    //Add SubProject Id to set to be used for query in handler
                    subProjectIds.add(spo.SubProject__c);
                }
            }
            
            //Process records
            /*if(!opportunitiesToUpdate.isEmpty()){
                
                //Update Project value on SubProject Opportunity based on SubProject's Project
                IMP_Project_Utility.updateProjectField(null, opportunitiesToUpdate, null, null, subProjectIds);
            }*/
            
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