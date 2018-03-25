/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Handler for ALL_DocusignEnvelope Trigger
Created on:    19 February 2016.
Test Class:    ALL_DocusignEnvelope_Test
Code Coverage: 100%
------------------------------------------------------------
History
2016-02-19    vishal.bandari@cdk.com              RQ-06032: Created
------------------------------------------------------------*/
global with sharing class ALL_DocusignEnvelope_Handler 
{
    public static void beforeInsert(List<dsfs__DocuSign_Envelope__c> newDocusignEnvelopes) 
    {
        try
        {
            // 2016-02-19 vishal.bandari@cdk.com - Change Expiration Date for Non-Digital Envelopes to 45 days(RQ-06032)
            Set<Id> dealStateIds = new Set<Id>();
            
            for(dsfs__DocuSign_Envelope__c newEnvelope : newDocusignEnvelopes)
            {
                if(newEnvelope.dsfs__Source_Object__c instanceOf Id)
                {
                	dealStateIds.add(newEnvelope.dsfs__Source_Object__c);   
                }
                newEnvelope.dsfs__Days_before_Envelope_is_Expired_Voided__c = 30;
            }
            
            Map<Id, Deal_State__c> dealStateMap = new Map<Id, Deal_State__c>([
                SELECT Id, Opportunity__r.RecordType.Name 
                FROM Deal_State__c 
                WHERE Id IN: dealStateIds 
                AND Opportunity__r.RecordType.Name = 'Pipeline' 
            ]);
            
            if(dealStateMap != NULL && dealStateMap.size() > 0 )
             {
                for(dsfs__DocuSign_Envelope__c newEnvelope : newDocusignEnvelopes)
                {
                    Id dealStateId = Id.valueOf(newEnvelope.dsfs__Source_Object__c);
                    
                    if(dealStateMap.keySet().contains(dealStateId))
                    {
                        newEnvelope.dsfs__Days_before_Envelope_is_Expired_Voided__c = 45;
                    }
                }
            }
        }
        catch(Exception e)
        {
            System.debug('Exception: ' + e.getMessage() + ' at ' + e.getLineNumber());
        }
    }
    /*
public static void beforeUpdate(List<dsfs__DocuSign_Envelope__c> newSObjects, Map<Id, dsfs__DocuSign_Envelope__c> oldSObjectsById) {  }
public static void beforeDelete(List<dsfs__DocuSign_Envelope__c> oldSObjects, Map<Id, dsfs__DocuSign_Envelope__c> oldSObjectsById) {  }
public static void afterInsert(List<dsfs__DocuSign_Envelope__c> newSObjects) {  }
public static void afterUpdate(List<dsfs__DocuSign_Envelope__c> newSObjects, Map<Id, dsfs__DocuSign_Envelope__c> oldSObjectsById) {  }
public static void afterDelete(List<dsfs__DocuSign_Envelope__c> oldSObjects, Map<Id, dsfs__DocuSign_Envelope__c> oldSObjectsById) {  }
public static void afterUndelete(List<dsfs__DocuSign_Envelope__c> newSObjects, Map<Id, dsfs__DocuSign_Envelope__c> oldSObjectsById) {  }
*/
}