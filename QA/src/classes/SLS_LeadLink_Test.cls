//2016-03-16- anirudh.singh@cdk.com- Created this class for SLS_LeadLink_Controller for Request RQ-06471 NADA Leads Process - Work My Leads.
@isTest
public class SLS_LeadLink_Test
{
    @TestSetup
    private static void setupData()
    {
        Account accountRecord=DS_TestObjects.NewAccount();
        insert accountRecord;
        
        Lead leadRecord=DS_TestObjects.NewLead();
        leadRecord.Current_Account__c=accountRecord.Id;
        insert leadRecord;
        
        Contact contactRecord=DS_TestObjects.NewContact();
        contactRecord.FirstName=leadRecord.FirstName;
        contactRecord.LastName=leadRecord.LastName;
        contactRecord.AccountId=accountRecord.Id;
        contactRecord.No_Longer_There__c=false;
        insert contactRecord;
        
        List<SLS_LeadLinkCriteria__c> leadLinkCriteriasList=new List<SLS_LeadLinkCriteria__c>();
        leadLinkCriteriasList.add(new SLS_LeadLinkCriteria__c(Group__c=1, Name='City (1)', Lead_Field__c='City', Contact_Field__c='Account.BillingCity', Active__c=true));
        leadLinkCriteriasList.add(new SLS_LeadLinkCriteria__c(Group__c=1, Name='First Name (1)', Lead_Field__c='FirstName', Contact_Field__c='FirstName', Active__c=true));
        leadLinkCriteriasList.add(new SLS_LeadLinkCriteria__c(Group__c=1, Name='Last Name (1)', Lead_Field__c='LastName', Contact_Field__c='LastName', Active__c=true));
        leadLinkCriteriasList.add(new SLS_LeadLinkCriteria__c(Group__c=1, Name='Account Name / Company (1)', Lead_Field__c='Company', Contact_Field__c='Account.Name', Active__c=true));
        leadLinkCriteriasList.add(new SLS_LeadLinkCriteria__c(Group__c=2, Name='Account Name / Company (2)', Lead_Field__c='Company', Contact_Field__c='Account.Name', Active__c=true));
        leadLinkCriteriasList.add(new SLS_LeadLinkCriteria__c(Group__c=2, Name='Last Name (2)', Lead_Field__c='LastName', Contact_Field__c='LastName', Active__c=true, Regex_Modifier__c='^(.*)$', Regex_Replacement__c='$1\\*'));
        insert leadLinkCriteriasList;
    }
    
    private static testMethod void fetchLeadAndLeadMatchesTestOne()
    {
        Lead leadRecord=[SELECT Id, FirstName, LastName, Email FROM Lead];
        Contact contactRecord=[SELECT Id, FirstName, LastName, Email FROM Contact];
        
        List<Id> fixedSearchResults=new List<Id>();
        fixedSearchResults.add(contactRecord.Id);
        Test.setFixedSearchResults(fixedSearchResults);
        
        test.startTest();
        SLS_LeadLink_Controller.LeadAndLeadMatchesWrapper wrapperRecord=SLS_LeadLink_Controller.fetchLeadAndLeadMatches(leadRecord.Id);
        
        system.assertEquals(leadRecord.Id, wrapperRecord.leadRecord.Id);
        system.assertEquals(1, wrapperRecord.leadMatchesList.size());
        test.stopTest();
    }
    
    private static testMethod void fetchLeadAndLeadMatchesTestTwo()
    {
        Lead leadRecord=[SELECT Id FROM Lead];
        List<SLS_LeadLinkCriteria__c> leadLinkCriteriasList=SLS_LeadLinkCriteria__c.getAll().values();
        delete leadLinkCriteriasList;
        
        test.startTest();
        SLS_LeadLink_Controller.LeadAndLeadMatchesWrapper wrapperRecord=SLS_LeadLink_Controller.fetchLeadAndLeadMatches(leadRecord.Id);
        
        system.assertEquals(leadRecord.Id, wrapperRecord.leadRecord.Id);
        system.assertEquals(0, wrapperRecord.leadMatchesList.size());
        test.stopTest();
    }
    
    private static testMethod void fetchLeadAndLeadMatchesTestThree()
    {
        test.startTest();
        SLS_LeadLink_Controller.LeadAndLeadMatchesWrapper wrapperRecord=SLS_LeadLink_Controller.fetchLeadAndLeadMatches(Null);
        
        system.assertEquals(Null, wrapperRecord);
        test.stopTest();
    }
    
    private static testMethod void linkLeadAndRedirectTestOne()
    {
        Lead leadRecord=[SELECT Id, FirstName, LastName, Email FROM Lead];
        Contact contactRecord=[SELECT Id, FirstName, LastName, Email FROM Contact];
        
        Lead_Match__c leadMatchRecord=new Lead_Match__c();
        leadMatchRecord.Lead__c=leadRecord.Id;
        leadMatchRecord.Contact__c=contactRecord.Id;
        insert leadMatchRecord;
        
        test.startTest();
        String result=SLS_LeadLink_Controller.linkLeadAndRedirect(leadMatchRecord.Id, leadRecord.Id);
        
        system.assertEquals('Link Success', result);
        test.stopTest();
    }
    
    private static testMethod void linkLeadAndRedirectTestTwo()
    {
        Lead leadRecord=[SELECT Id, FirstName, LastName, Email FROM Lead];
        Contact contactRecord=[SELECT Id, FirstName, LastName, Email FROM Contact];
        
        Lead_Match__c leadMatchRecord=new Lead_Match__c();
        leadMatchRecord.Lead__c=leadRecord.Id;
        leadMatchRecord.Contact__c=contactRecord.Id;
        insert leadMatchRecord;
        
        test.startTest();
        String result=SLS_LeadLink_Controller.linkLeadAndRedirect(leadRecord.Id, leadRecord.Id);
        
        system.assertEquals('List has no rows for assignment to SObject', result);
        test.stopTest();
    }
    
    private static testMethod void linkLeadAndRedirectTestThree()
    {
        test.startTest();
        String result=SLS_LeadLink_Controller.linkLeadAndRedirect(Null, Null);
        
        system.assertEquals('List has no rows for assignment to SObject', result);
        test.stopTest();
    }
    
    private static testMethod void matchSelectedAccountRecordTestOne()
    {
        Account accountRecord=[SELECT Id FROM Account];
        Lead leadRecord=[SELECT Id, FirstName, LastName, Email FROM Lead];
        
        test.startTest();
        String result=SLS_LeadLink_Controller.matchSelectedAccountRecord(accountRecord.Id, leadRecord.Id);
        
        system.assertEquals('Link Success', result);
        test.stopTest();
    }
    
    private static testMethod void matchSelectedAccountRecordTestTwo()
    {
        Account accountRecord=[SELECT Id FROM Account];
        Lead leadRecord=[SELECT Id, FirstName, LastName, Email FROM Lead];
        
        test.startTest();
        String result=SLS_LeadLink_Controller.matchSelectedAccountRecord(leadRecord.Id, leadRecord.Id);
        
        system.assert(result.containsIgnoreCase('Account ID: id value of incorrect type'));
        test.stopTest();
    }
    
    private static testMethod void matchSelectedAccountRecordTestThree()
    {
        test.startTest();
        String result=SLS_LeadLink_Controller.matchSelectedAccountRecord(Null, Null);
        
        system.assertEquals('List has no rows for assignment to SObject', result);
        test.stopTest();
    }
    
    private static testMethod void matchSelectedContactRecordTestOne()
    {
        Lead leadRecord=[SELECT Id, FirstName, LastName, Email FROM Lead];
        Contact contactRecord=[SELECT Id, FirstName, LastName, Email FROM Contact];
        
        test.startTest();
        String result=SLS_LeadLink_Controller.matchSelectedContactRecord(contactRecord.Id, leadRecord.Id);
        
        system.assertEquals('Link Success', result);
        test.stopTest();
    }
    
    private static testMethod void matchSelectedContactRecordTestTwo()
    {
        Lead leadRecord=[SELECT Id, FirstName, LastName, Email FROM Lead];
        Contact contactRecord=[SELECT Id, FirstName, LastName, Email FROM Contact];
        
        test.startTest();
        String result=SLS_LeadLink_Controller.matchSelectedContactRecord(leadRecord.Id, leadRecord.Id);
        
        system.assertEquals('List has no rows for assignment to SObject', result);
        test.stopTest();
    }
    
    private static testMethod void matchSelectedContactRecordTestThree()
    {
        test.startTest();
        String result=SLS_LeadLink_Controller.matchSelectedContactRecord(Null, Null);
        
        system.assertEquals('List has no rows for assignment to SObject', result);
        test.stopTest();
    }
}