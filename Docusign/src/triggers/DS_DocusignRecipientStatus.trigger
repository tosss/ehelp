/*
04/28/2015 Venkata Shrivol -Added Trigger.old for After Update 
*/

trigger DS_DocusignRecipientStatus on dsfs__DocuSign_Recipient_Status__c (after insert, after update) 
{
    if(Trigger.isAfter)
    {
    	list<Id> RecipientStatusIdsToProcess = new list<Id>();
    	if(Trigger.isInsert)
    	{
    		RecipientStatusIdsToProcess 
            = DS_DocusignRecipientStatus_Handler.FilterIdsToProcessAfterInsert(Trigger.New);
    	}
    	if(Trigger.isUpdate)
    	{
    		RecipientStatusIdsToProcess 
            = DS_DocusignRecipientStatus_Handler.FilterIdsToProcessAfterUpdate(Trigger.New, Trigger.oldMap);
    	}
        
        list<dsfs__DocuSign_Recipient_Status__c> QueriedRecipientStatuses 
            = DS_DocusignRecipientStatus_Handler.QueryRecipientStatuses(RecipientStatusIdsToProcess);
        
        DS_DocusignRecipientStatus_Handler.UpdateDealStates(QueriedRecipientStatuses);
        
    }
}