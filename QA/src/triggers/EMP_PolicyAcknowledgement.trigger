//Author: Anirudh Singh
//Dated: 24th September, 2015
//Description: This trigger is for Policy Acknowledgement object.
trigger EMP_PolicyAcknowledgement on EMP_Policy__c(after insert, after update, after delete)
{
    if(Trigger.isDelete)
    {
        EMP_PolicyAcknowledgement_Helper.updateRecords(Trigger.Old);
    }
    else
    {
        EMP_PolicyAcknowledgement_Helper.updateRecords(Trigger.New);
    }
}