// rq-05034 combine all previous contact triggers into one. put all handlers into one as well!
// 2015-08-27 - brian.cook@cdk.com, bill.thurow@cdk.com
trigger All_Contact on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger.isbefore) {
        if(Trigger.isInsert) {
            All_Contact_Handler.beforeInsert(Trigger.new);
        } else if(Trigger.isUpdate) {
            All_Contact_Handler.beforeUpdate(Trigger.new,/*Trigger.newMap,*/ Trigger.oldMap);
        } else if(Trigger.isDelete) {
            All_Contact_Handler.beforeDelete_DS(Trigger.old,Trigger.oldMap);
        }
    } 
    else if(Trigger.isafter) {
        if(Trigger.isInsert) {
            All_Contact_Handler.afterInsert(Trigger.new,Trigger.newMap);
        } else if(Trigger.isUpdate) {
            All_Contact_Handler.afterUpdate(Trigger.new,/*Trigger.newMap,Trigger.old,*/Trigger.oldMap);
        } else if(Trigger.isDelete) {
            // not used
        } else if(Trigger.isUndelete) {
            // not used
        }
    }   
}