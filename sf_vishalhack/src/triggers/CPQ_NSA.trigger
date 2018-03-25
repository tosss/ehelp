//2016-11-10 ragashalini.koka@cdk.com  Created the trigger for RQ-08164
//2016-11-22 ragashalini.koka@cdk.com added code to update term dates for RQ-08233

trigger CPQ_NSA on NSA__c (before insert, before update, after insert, after update) {

    if(Trigger.isBefore ) {
        
        if(Trigger.isInsert || Trigger.isUpdate) {
          
           CPQ_NSA_Handler.setMainNSA(Trigger.old, Trigger.new, Trigger.isInsert); 
           CPQ_NSA_Handler.updateTermDates(Trigger.old, Trigger.new, Trigger.isInsert);
        
        } 
    }
    
    if(Trigger.isAfter) { 
        
        if(Trigger.isInsert || Trigger.isUpdate) {
            
             CPQ_NSA_Handler.setNSAOnAccount(Trigger.old, Trigger.New, Trigger.isInsert); 
          
        }
        
      
    }
    
}