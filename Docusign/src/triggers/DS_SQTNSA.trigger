trigger DS_SQTNSA on SQT_NSA__c (before insert, before update, after insert, after update, after delete) 
{
    /*if((Trigger.isBefore && (Trigger.isInsert || Trigger.IsUpdate)) || (Trigger.isAfter && Trigger.isDelete))
    {
        DS_SQTNSA_Handler.RollUpCountofSQTNSA(Trigger.new, Trigger.OldMap); 
    }*/
}