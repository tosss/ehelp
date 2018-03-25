/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Test Class for ALL_DocusignEnvelope_Handler and ALL_DocusignEnvelope Trigger
Created on:    19 February 2016.
Code Coverage: 100%
------------------------------------------------------------
History
2016-02-19    vishal.bandari@cdk.com              RQ-06032: Created
------------------------------------------------------------*/
@IsTest
public class ALL_DocusignEnvelope_Test 
{
	@testsetup
    static void setUpData()
    {
        List<Opportunity> opportnityList = new List<Opportunity>();
        //Inserting Sample Opportunity Object
        Opportunity opportunityObject1 = DS_TestObjects.NewOpportunity();
        opportunityObject1.RecordTypeId = Utilities.getRecordTypeIdOfAnySObject('Opportunity','Pipeline');
        opportnityList.add(opportunityObject1);
        
        //Inserting Sample Opportunity Object
        Opportunity opportunityObject2 = DS_TestObjects.NewOpportunity();
        opportunityObject2.RecordTypeId = Utilities.getRecordTypeIdOfAnySObject('Opportunity','BZ Migration');
        opportnityList.add(opportunityObject2);
        
        insert opportnityList;
        
        List<Deal_State__c> dealStateList = new List<Deal_State__c>();
        //Inserting Sample Deal_State__c Object
        Deal_State__c dealStateObject1 = new Deal_State__c();
        dealStateObject1.Opportunity__c = opportunityObject1.Id;
        dealStateList.add(dealStateObject1);
        
        //Inserting Sample Deal_State__c Object
        Deal_State__c dealStateObject2= new Deal_State__c();
        dealStateObject2.Opportunity__c = opportunityObject2.Id;
        dealStateList.add(dealStateObject2);
        
        insert dealStateList;
        
        List<dsfs__DocuSign_Envelope__c> envelopeList = new List<dsfs__DocuSign_Envelope__c>();
        
        //Inserting Sample dsfs__DocuSign_Envelope__c Object
        dsfs__DocuSign_Envelope__c envelopeObject1 = new dsfs__DocuSign_Envelope__c(dsfs__Source_Object__c = dealStateObject1.Id);
        envelopeList.add(envelopeObject1);
        
        //Inserting Sample dsfs__DocuSign_Envelope__c Object
        dsfs__DocuSign_Envelope__c envelopeObject2 = new dsfs__DocuSign_Envelope__c(dsfs__Source_Object__c = dealStateObject2.Id);
        envelopeList.add(envelopeObject2);
        
        insert envelopeList;
    }
    
    static testmethod void testInsert()
    {
        dsfs__DocuSign_Envelope__c envelopeObject = [
            SELECT Id, dsfs__Days_before_Envelope_is_Expired_Voided__c 
            FROM dsfs__DocuSign_Envelope__c
            ORDER BY Name ASC
            LIMIT 1
        ];
        
        // 2016-02-19 vishal.bandari@cdk.com - Test Expiration Date for Digital Envelopes to be 45 days(RQ-06032)
        System.assertEquals(45, envelopeObject.dsfs__Days_before_Envelope_is_Expired_Voided__c,'Envelope Expiration Date not Updated');
    }
    
    static testmethod void negativeTest()
    {
         dsfs__DocuSign_Envelope__c envelopeObject = [
            SELECT Id, dsfs__Days_before_Envelope_is_Expired_Voided__c 
            FROM dsfs__DocuSign_Envelope__c
            ORDER BY Name DESC
            LIMIT 1
        ];
        
        // 2016-02-19 vishal.bandari@cdk.com - Test Expiration Date for Non-Digital Envelopes to be 30 days(RQ-06032)
        System.assertEquals(30, envelopeObject.dsfs__Days_before_Envelope_is_Expired_Voided__c,'Envelope Expiration Date not Updated');
        
        // 2016-02-19 vishal.bandari@cdk.com - Executing catch block in ALL_DocusignEnvelope_Handler.beforeInsert method
        ALL_DocusignEnvelope_Handler.beforeInsert(NULL);
    }
}