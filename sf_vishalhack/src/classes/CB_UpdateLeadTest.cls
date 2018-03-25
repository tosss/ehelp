//2017-03-31 - lalitha.adduru@cdk.com - commented this class as it's moved to ALL_Lead_test - RQ-06389
@IsTest
private class CB_UpdateLeadTest
{
    /*static testMethod void SaveLeadAndOpportunity()
    {
        User u = DS_TestObjects.NewUser_Inserted();
        Account acc = DS_TestObjects.NewAccount_Inserted();
        Contact newContact = DS_TestObjects.NewContact_Inserted();
        Campaign camp = DS_TestObjects.NewCampaign_Inserted();
        Contact_Relationship__c newCR = DS_TestObjects.newContactRelationship();
        newCR.Account__c = acc.Id;
        newCR.Contact__c = newContact.Id;
        insert newCR;
        
        // for IsProduct
        IS_Product__c IsProduct = new IS_Product__c();
        IsProduct.IsActive__c = true;
        insert IsProduct;
        
        // for Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Oppor2';
        opp.AccountId = acc.Id;
        opp.ADP_Opportunity_Owner__c = u.id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Plan';
        insert opp; 
        
        // for Lead
        Lead l = new Lead();
        l.LastName = 'testname';
        l.Current_Account__c = acc.id;
        l.Contact__c = newContact.Id;
        l.Company = 'ADP';
        l.Product_Interest__c = 'Dealix';
        l.Is_Product__c = IsProduct.id;
        l.Status = 'Rep Attempted Contact';
        l.LeadSource = 'Email';
        insert l;
        
        // test CB_UpdateOpportunity
        opp.CampaignId = camp.Id;
        opp.From_Lead__c = l.id;
        update opp;
        
        // reset test
        /*CB_Opportunity_Handler.AlreadyProcessedLead = new Set<Id>(); // clear out already processed
        CB_UpdateLeadHandler.AlreadyProcessedOpp = new Set<Id>(); // clear out already processed
        opp.From_Lead__c = null;
        opp.CampaignId = null;
        l.Opportunity__c = null;
        l.ADP_Campaign__c = null;
        update opp;
        update l;
        
        // test CB_UpdateLead
        system.debug('Updating Lead');
        l.ADP_Campaign__c = camp.Id;
        l.Opportunity__c = opp.Id;
        update l;
    }*/
}