/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: -Checks if the Active field changes then mirrors it's value to the 
              related Discovery Question Product Active_Flag_for_Rollup__c checkbox.
Test Class:
History
10/21/14    Kimiko Roberto      Created
------------------------------------------------------------*/
trigger IMP_Question on Question__c (after update) {
    
    if(Trigger.isAfter){
        
        if(Trigger.isUpdate){
            //get the new value of the active field and compare it to it's old value if it changed, then mirror its value to the 
            //related Discovery Question Product Active_Flag_for_Rollup__c
            IMP_CheckQuestionifActive_Handler.checkActiveField(Trigger.New, Trigger.oldMap);
        }
    }
}