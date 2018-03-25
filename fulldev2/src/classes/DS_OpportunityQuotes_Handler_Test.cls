@isTest
public class DS_OpportunityQuotes_Handler_Test {
   
    public static testmethod void DealStateUpdateTest(){
        
        // insert a opportunity
        opportunity opp = DS_TestObjects.NewOpportunity_Inserted();
        Account a = DS_TestObjects.NewAccount_Inserted();
        List<Docusign_Deal_State_Fields__c> DocusignDealStateFields = DS_OpportunityQuotes_Handler_Test.GenerateDocusignDealStateFields();
        
        
        // insert a deal state
        Deal_State__c ds = new Deal_State__c();
        ds.Opportunity__c = opp.Id;
        ds.SQT_Deal_ID__c = 'ADP'; // has to be same as the Opportunity quote Deal ID
        
        insert ds;
        
        // insert a docusign status
        dsfs__DocuSign_Status__c docusign = new dsfs__DocuSign_Status__c();
        docusign.Deal_State__c = ds.Id;
        docusign.dsfs__Envelope_Status__c = 'Going';
        
        insert docusign;
        
        // insert a new Opportunity quote
        Opportunity_quotes__c oq = new Opportunity_quotes__c();
        oq.Opportunity__c = opp.Id;
        oq.Deal_ID__c = 'ADP'; // has to be same as the Deal State SQT Deal ID
        oq.Account__c = a.Id;
        insert oq;
    }
    
    public static testmethod List<Docusign_Deal_State_Fields__c> GenerateDocusignDealStateFields()
    {
        List<Docusign_Deal_State_Fields__c> DocusignDealStateFields = new List<Docusign_Deal_State_Fields__c>();
        
        DocusignDealStateFields.add(
            new Docusign_Deal_State_Fields__c(
                Name = 'CLIENT DATA EXCHANGE PRODUCTS', 
                Deal_State_Field__c = 'CLIENT_DATA_EXCHANGE_PRODUCTS__C', 
                Opportunity_Quote_Field__c = 'CLIENT_DATA_EXCHANGE_PRODUCTS__C'
            )
        );
        
        insert DocusignDealStateFields;
        return DocusignDealStateFields;
    }
}