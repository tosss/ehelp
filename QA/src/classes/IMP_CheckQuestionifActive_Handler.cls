/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: Checks Question's Active field so we can set the value of the related
             Discovery_Question_Product's Active_Flag_for_Rollup__c field
Test Class:
History
10/21/14    Kimiko Roberto      Created
------------------------------------------------------------*/
public class IMP_CheckQuestionifActive_Handler{
    
    public static void checkActiveField(List<Question__c> questionList, Map<Id, Question__c> oldQuestionMap){
        List<Question__c> questionsToBeProcessed = new List<Question__c>();
        //get the updated questions to check if the active field changed; this and the product will determine the Active_Flag_for_Rollup__c value
        for(Question__c question : questionList){
            Question__c oldQuestion = oldQuestionMap.get(question.Id);
            //retrieve all questions where active field is not equal to it's old value;
            //this list will be used to get the product and set up Active_Flag_for_Rollup__c value
            if(question.Active__c != oldQuestion.Active__c){
                questionsToBeProcessed.add(question);
            }
        }
        if(!questionsToBeProcessed.isEmpty()){
            //get all the related Discovery_Question_Product__c from the updated questions so we can change the Active_Flag_for_Rollup__c value
            List<Discovery_Question_Product__c> dqpList = [SELECT Id,
                                                           Question__c,
                                                           Question__r.Active__c,
                                                           Product__c,
                                                           Product__r.Active__c,
                                                           Active_Flag_for_Rollup__c
                                                           FROM Discovery_Question_Product__c
                                                           WHERE Question__c IN: questionsToBeProcessed];
            if(!dqpList.isEmpty()){
                //we will iterate to the list of related Discovery_Question_Product__c to detrermine the value of 
                //the Active_Flag_for_Rollup__c depending if the question and product is active or not.
                for(Discovery_Question_Product__c dqp : dqpList){
                    if(dqp.Product__r.Active__c && dqp.Question__r.Active__c){
                        dqp.Active_Flag_for_Rollup__c = true;
                    }
                    else{
                        dqp.Active_Flag_for_Rollup__c = false;
                    }            
                }
                //update the changes made to the Discovery_Question_Product__c
                update dqpList;
            }
            
        }
        
        
    }
}