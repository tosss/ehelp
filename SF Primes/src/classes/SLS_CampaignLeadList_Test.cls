@IsTest
public class SLS_CampaignLeadList_Test 
{
 	@testSetup
    public static void testsetup()
    {
        Account accObj = DS_TestObjects.NewAccount_Inserted();
        Contact conObj = DS_TestObjects.NewContact();
        conObj.AccountId = accObj.Id;
        insert conObj;
        Systems__c sysObj  = new Systems__c();
        sysObj.SLXVendor_ID__c = 'Vendor Id';
        sysObj.type__C = 'DMS';
        sysObj.SLXSystem_ID__c = 'randomn';
        insert sysObj;
        System_at_Dealership__c sdObj = new System_at_Dealership__c();
        sdObj.System_Type__c = 'DMS';
        sdObj.Account__c = accObj.Id;
        sdObj.Vendor__c = sysObj.Id;
        insert sdObj;
        Account_Team__c at = new Account_Team__c();
        at.Team_Role__C = 'Forecasting - Inside Sales Rep';
        at.Account__C = accObj.Id;
        at.Team_Member__c = UserInfo.getUserId();
        insert at;
        Campaign camObj = DS_TestObjects.NewCampaign();
        insert camObj;
        List<Lead> leads = new List<Lead>();
        for(Integer i=0;i<3;i++)
        {
            Lead leadObj = DS_TestObjects.NewLead();
            leadObj.Current_Account__C = accObj.Id;
            leadObj.Contact__c = conObj.Id;
            leads.add(leadObj);
        }
        insert leads;     
        Task tskObj = DS_TestObjects.NewTask();
        tskObj.WhoId = leads[0].Id;
        insert tskObj;
        Event evntObj = new Event();
        evntObj.WhoId = leads[0].Id;
        evntObj.DurationInMinutes = 15;
        evntObj.ActivityDateTime = DateTime.now();
        insert evntObj;
    }
    public static testmethod void test1()
    {
        Account accObj = [SELECT id FROM Account LIMIT 1];
        Contact conObj = [SELECT id FROM Contact LIMIT 1];
        Campaign camObj = [SELECT id FROM Campaign LIMIT 1];
        Lead leadObj = [SELECT id FROM Lead LIMIT 1];
        SLS_CampaignLeadList_Controller.getLeadStatus();
        SLS_CampaignLeadList_Controller.getVendorSystem(accObj.Id);
        SLS_CampaignLeadList_Controller.getAccountDetails(accObj.Id);
        SLS_CampaignLeadList_Controller.getISR(accObj.Id);
        SLS_CampaignLeadList_Controller.getCurrentUser();
        SLS_CampaignLeadList_Controller.getContactDetails(conObj.Id);
        SLS_CampaignLeadList_Controller.getLeads(String.ValueOf(camObj.Id), new List<String>{'Not Yet Contacted By Rep'}, '',  1, 3);
        SLS_CampaignLeadList_Controller.getRecordsCount(String.ValueOf(camObj.Id), new List<String>{'Not Yet Contacted By Rep'},'');
        SLS_CampaignLeadList_Controller.getOpenActivities(accObj.Id, leadObj.Id, '');
        SLS_CampaignLeadList_Controller.getActivityHistory(accObj.Id, leadObj.Id, '');
        SLS_CampaignLeadList_Controller.updateStatus(String.ValueOf(camObj.Id), new List<String>{'Not Yet Contacted By Rep'}, '',new  List<String>{String.ValueOf(leadObj.Id)},'Contacted', 1, 3);
        
        SLS_CampaignLeadList_Controller.convertLeadToOpportunity(String.ValueOf(camObj.Id), new List<String>{'Not Yet Contacted By Rep'}, '',String.ValueOf(leadObj.Id), 1, 3);
    }
    
}