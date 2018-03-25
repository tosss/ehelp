trigger DS_SQTNSA on SQT_NSA__c (before insert, before update, after insert, after update, after delete) 
{
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete))
    {
        list<SQT_NSA__c> childRecords = trigger.new == null ? trigger.old : trigger.new;
        
        ALL_GenericRollup_Helper.genericCountRollUp(
            childRecords, 'Deal_State__c', 'SQT_NSA__r','Deal_State__c', 
            'Count_of_Shared_System_Addendum__c', 'NSA_ATTRIBUTES__c = \'Shared System Addendum\'');
    }
}