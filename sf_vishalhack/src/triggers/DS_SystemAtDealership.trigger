trigger DS_SystemAtDealership on System_at_Dealership__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	DS_SystemAtDealership_Handler.ExecuteTrigger();//Trigger.old,Trigger.oldMap,Trigger.new,Trigger.newMap);
}