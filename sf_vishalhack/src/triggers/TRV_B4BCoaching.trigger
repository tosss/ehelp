/* 2015-12-8 endiem@endiem.com - RQ-05509 - On insert/update we do following operation based on status field update or Completed By or No Of days field 
                      for different Record Type is updated and Visit Start date:
                      1. To create Event if Status is Confirmed
                      2. To Delete the Event if Status is Cancelled or Pushed
                      3. If Status is Completed and Record Type is Process Coach Visit then will send an Email to Contact
*/
trigger TRV_B4BCoaching on Traver_Coaching__c (after update, after insert, before insert, before update) {
    
    TRV_B4BCoaching_Handler objHandler = new TRV_B4BCoaching_Handler();
    
    if(Trigger.isAfter) {
        
        if(Trigger.isUpdate) {
            
            objHandler.onAfterUpdate(Trigger.newMap, trigger.oldMap);
        }
        else if(Trigger.isInsert) {
            
            objHandler.onAfterInsert(Trigger.new);
        }
    }
    
    if(Trigger.isBefore) {
        
        if(Trigger.isInsert) {
            
            objHandler.onBeforeInsert(Trigger.new);
        }
        else if(Trigger.isUpdate) {
            
            objHandler.onBeforeUpdate(Trigger.newMap, trigger.oldMap);
        }
    }
}