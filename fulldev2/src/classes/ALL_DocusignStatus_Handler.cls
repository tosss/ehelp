/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Updates Docusign_Envelope_Id on Opportunity
Created on:    9 October 2015.
Code Coverage: 100%
------------------------------------------------------------
History
9 October 2015    Vishal Bandari      RQ-05276: Created
------------------------------------------------------------*/
public class ALL_DocusignStatus_Handler 
{
    public static void updateOpporunity(Map<id,dsfs__DocuSign_Status__c> docusignStatusMapParam, Boolean isInsert, Boolean isUpdate)
    {
        try
        {
            //Fetch newly insert dsfs__DocuSign_Status__c records
            Map<id, dsfs__DocuSign_Status__c> docusignStatusMap;
            
            if(isInsert)
            {
                docusignStatusMap = new map<Id, dsfs__DocuSign_Status__c>([
                    SELECT Id, Deal_State__r.Opportunity__c, dsfs__DocuSign_Envelope_ID__c 
                    FROM dsfs__DocuSign_Status__c 
                    WHERE ID IN: docusignStatusMapParam.keySet()
                ]);
            }
            else if(isUpdate)
            {
                docusignStatusMap = new map<Id, dsfs__DocuSign_Status__c>([
                    SELECT Id, Deal_State__r.Opportunity__c, dsfs__DocuSign_Envelope_ID__c 
                    FROM dsfs__DocuSign_Status__c 
                    WHERE ID IN: docusignStatusMapParam.keySet() 
                    AND dsfs__Envelope_Status__c = 'Voided'
                ]);
            }
            
            if(docusignStatusMap.size() > 0)
            {          
                
                //Map to relate opporunity Id to its Docusign_Envelope Id
                Map<Id, String> OpportunityToDocusignEnvelopeMap = new Map<Id, String>();
                
                for(dsfs__DocuSign_Status__c docusignStatusNewObj : docusignStatusMap.values())
                {
                    dsfs__DocuSign_Status__c docusignStatus = docusignStatusMap.get(docusignStatusNewObj.Id);
                    docusignStatus.dsfs__Envelope_Status__c = 
                        OpportunityToDocusignEnvelopeMap.put(docusignStatus.Deal_State__r.Opportunity__c , docusignStatus.dsfs__DocuSign_Envelope_ID__c);
                }
                
                if(OpportunityToDocusignEnvelopeMap.size()>0)
                {
                    //Required Deal State records Ids of newly inserts Docusign Status Record
                    
                    Set<String> requiredDealStateIdsSet = new Set<String>();
                    
                    for(dsfs__DocuSign_Status__c docusignStatusNewObj : docusignStatusMap.values())
                    {
                        if(docusignStatusNewObj.Deal_State__c!=null)
                        {
                            String ids = String.valueof(docusignStatusNewObj.Deal_State__c).substring(0,15);
                            requiredDealStateIdsSet.add(ids);
                        }
                    }  
                    
                    //Fetch Required Opportunites
                    
                    List<Opportunity> opportunityList = [
                        SELECT ID, DS_SLS_DocuSign_Envelope_ID__c
                        FROM Opportunity 
                        WHERE Deal_State_Id__c IN :requiredDealStateIdsSet
                    ];    
                    
                    //Update Opportunity DS_SLS_DocuSign_Envelope_ID__c
                    
                    for(Opportunity oppObj : opportunityList)
                    {
                        String docusignenvelopeId = OpportunityToDocusignEnvelopeMap.get(oppObj.Id);
                        
                        if(isInsert)
                        {
                            oppObj.DS_SLS_DocuSign_Envelope_ID__c = docusignenvelopeId;
                        }
                        else
                        {
                            oppObj.DS_SLS_DocuSign_Envelope_ID__c = null;
                        }
                    }  
                    update opportunityList;  
                }  
            }  
        }
        catch(Exception e)
        {
            System.debug('Exception : '+e.getMessage()+' at '+e.getLineNumber());
        }
    }
}