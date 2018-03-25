//2016-12-26 - ragashalini.koka@cdk.com - RQ-08369 -  Created this trigger
//2016-01-31 - vishal.bandari@cdk.com   - RQ-07865 - Added afterInsert , afterUpdate and afterDelete logic

trigger ALL_Top5 on Top_5__c (before insert, before update, after insert,after update,after delete) {
    
    if(Trigger.isBefore) {
        
        if(Trigger.isInsert ) {
            ALL_Top5_Handler.updateManagerFields(Trigger.old, Trigger.new, Trigger.isInsert);
        }
        
        if(Trigger.isUpdate) {
            ALL_Top5_Handler.updateManagerFields(Trigger.old, Trigger.new, Trigger.isInsert);
            //ALL_Top5_Handler.storeOldStatusValue(Trigger.old, Trigger.new);
            ALL_Top5_Handler.restoreStatus(Trigger.oldMap, Trigger.newMap);
        }
    }
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            ALL_Top5_Handler.afterInsert(Trigger.New);
            ALL_Top5_Handler.submitForApproval(Trigger.old, Trigger.new , Trigger.isInsert);
        }
        else if(Trigger.isUpdate)
        {
            ALL_Top5_Handler.afterUpdate(Trigger.New,Trigger.oldMap);
            ALL_Top5_Handler.submitForApproval(Trigger.old, Trigger.new, Trigger.isInsert);
        }
        else if(Trigger.isDelete)
        {
            ALL_Top5_Handler.afterDelete(Trigger.Old);
        } 
    }
}