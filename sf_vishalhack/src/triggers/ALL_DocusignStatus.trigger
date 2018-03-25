/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Updates Docusign_Envelope_Id on Opportunity
Created on:    24 September 2015.
Code Coverage: 100%
------------------------------------------------------------
History
24 September 2015    Vishal Bandari      RQ-05276: Created
------------------------------------------------------------*/
trigger ALL_DocusignStatus on dsfs__DocuSign_Status__c (before insert, before update, after insert, after update, before delete) 
{
    if(Trigger.IsInsert || Trigger.IsUpdate )
    {
        if(Trigger.IsAfter)
        {    
            ALL_DocusignStatus_Handler.updateOpporunity(Trigger.newMap, Trigger.IsInsert, Trigger.IsUpdate);        
        }
        
        if(Trigger.IsBefore)
        {
            ALL_DocusignStatus_Handler.updateEnvelopeField(Trigger.new);
        }
    }
}