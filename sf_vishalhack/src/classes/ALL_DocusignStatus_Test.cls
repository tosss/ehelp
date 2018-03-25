/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Unit Test for ALL_DocusignStatus_Handler
Created on:    9 October 2015.
Code Coverage: 100% 
------------------------------------------------------------
History
9 October 2015    Vishal Bandari      RQ-05276: Created
------------------------------------------------------------*/
@IsTest
public class ALL_DocusignStatus_Test {
    
    //To Create Sample Opportunity and Deal_State__c
    
	@testSetup
    public static void setupData()
    {     
        //Insert Sample Opportunity
        
        Opportunity opportunityObj = DS_TestObjects.NewOpportunity_Inserted();
     
        //Insert Sample Deal_State__c
        
        Deal_State__c dealStateObj = new Deal_State__c();
        dealStateObj.Opportunity__c = opportunityObj.Id;
        dealStateObj.Deal_Status__c = 'New Deal Arrived';
        dealStateObj.Quantity_of_Sites__c = 12;
        dealStateObj.Any_Other_Sites_Involved_With_Request__c = 'Site1';
        dealStateObj.Description_of_Need__c = 'Sample';
        dealStateObj.Cash_Credit__c = 'Cash';
        dealStateObj.Contract_Needed_By_Date__c = Date.today();
        insert dealStateObj;
    }
    
    //To test for update on Opportunity record
    
    public static testmethod void validate()
    {
        //Insert Sample dsfs__DocuSign_Status__c
        
        dsfs__DocuSign_Status__c docusignStatusObj = new dsfs__DocuSign_Status__c();
        String envelopId = String.valueof(Math.random());
        docusignStatusObj.dsfs__DocuSign_Envelope_ID__c = envelopId;
        
        Deal_State__c dealStateObj = [
            SELECT id,Opportunity__c 
            FROM deal_state__c
        ][0];
        
        
        docusignStatusObj.Deal_State__c = dealStateObj.Id;
        insert docusignStatusObj;
        
        //Test if Opportunity Object DocuSign_Envelope_ID__c field is Updated
        
        Opportunity opportunityObj = [
            SELECT id, DS_SLS_DocuSign_Envelope_ID__c 
            FROM Opportunity 
            WHERE id =: dealStateObj.Opportunity__c
        ];
        
        System.assertEquals(envelopId, opportunityObj.DS_SLS_DocuSign_Envelope_ID__c, 'Envelope Id is not updated');
        
        //Testing Voided the Envelope
        docusignStatusObj.dsfs__Envelope_Status__c = 'Voided';
        update docusignStatusObj;
        
        //Test if Opportunity Object DS_SLS_DocuSign_Envelope_ID__c field is Updated
        
        opportunityObj = [
            SELECT id, DS_SLS_DocuSign_Envelope_ID__c 
            FROM Opportunity 
            WHERE id =: dealStateObj.Opportunity__c
        ];
        
        System.assertEquals(null, opportunityObj.DS_SLS_DocuSign_Envelope_ID__c, 'Envelope Id is not updated when voided');
    }
    
    //To perform negitive Test
    
    public static testmethod void negitiveTest()
    {        
        ALL_DocusignStatus_Handler.updateOpporunity(null,false,false);
    }
}