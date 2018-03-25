// 2016-02-10 endiem@endiem.com - RQ-05509 - Whenever EPC/PSC/Proecss Coach on Consulting Project record is filled/modified, holding the email of 
//Resource in corresponding email fields on Consulting Project to send emails
trigger TRV_ConsultingProject on Traver_Project__c (Before Insert, Before Update) {
    
    TRV_ConsultingProject_Handler objHandler = new TRV_ConsultingProject_Handler();
    
    if(Trigger.isInsert) {
        
        //Updates EPC/PSC/Process Coach email fields if these values are not null
        objHandler.onBeforeInsert(Trigger.New);
    }
    
    if(Trigger.isUpdate) {
        
        //Updates EPC/PSC/Process Coach email fields if these values are modified
        objHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    }
}