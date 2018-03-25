/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Trigger for dsfs__DocuSign_Envelope__c Object
Created on:    19 February 2016.
Test Class:    ALL_DocusignEnvelope_Test
Code Coverage: 100%
------------------------------------------------------------
History
2016-02-19    vishal.bandari@cdk.com              RQ-06032: Created
------------------------------------------------------------*/
trigger ALL_DocusignEnvelope on dsfs__DocuSign_Envelope__c (
    before insert, before update, before delete, 
    after insert, after update, after delete, after undelete) 
{
    
    if(Trigger.isbefore) 
    {
        if(Trigger.isInsert && ALL_CheckRecursive.runCodeBlockOnce('dsfs__DocuSign_Envelope__c_BeforeInsert')) 
        {
            // description of beforeInsert logic
            ALL_DocusignEnvelope_Handler.beforeInsert(Trigger.new);
        } 
       /* 
        else if(Trigger.isUpdate && ALL_CheckRecursive.runCodeBlockOnce('dsfs__DocuSign_Envelope__c_BeforeUpdate')) {
            // description of beforeUpdate logic
            ALL_DocusignEnvelope_Handler.beforeUpdate(Trigger.new,Trigger.oldMap);
        } 
        else if(Trigger.isDelete && ALL_CheckRecursive.runCodeBlockOnce('dsfs__DocuSign_Envelope__c_BeforeDelete')) {
            // description of beforeDelete logic
            ALL_DocusignEnvelope_Handler.beforeDelete(Trigger.old,Trigger.oldMap);
        }
		*/
    } 
    else if(Trigger.isAfter) 
    {
        /*
        if(Trigger.isInsert && ALL_CheckRecursive.runCodeBlockOnce('dsfs__DocuSign_Envelope__c_AfterInsert')) {
            // description of afterInsert logic
            ALL_DocusignEnvelope_Handler.afterInsert(Trigger.new);
        } 
        else if(Trigger.isUpdate && ALL_CheckRecursive.runCodeBlockOnce('dsfs__DocuSign_Envelope__c_AfterUpdate')) {
            // description of afterUpdate logic
            ALL_DocusignEnvelope_Handler.afterUpdate(Trigger.new,Trigger.oldMap);
        } 
        else if(Trigger.isDelete && ALL_CheckRecursive.runCodeBlockOnce('dsfs__DocuSign_Envelope__c_AfterDelete')) {
            // description of afterDelete logic
            ALL_DocusignEnvelope_Handler.afterDelete(Trigger.old,Trigger.oldMap);
        } 
        else if(Trigger.isUndelete && ALL_CheckRecursive.runCodeBlockOnce('dsfs__DocuSign_Envelope__c_AfterUndelete')) {
            // description of afterUndelete logic
            ALL_DocusignEnvelope_Handler.afterUndelete(Trigger.new,Trigger.newMap);
        }
		*/
    }
}