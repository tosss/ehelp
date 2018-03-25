//2015-10-14 Hemanth Created
//2015-10-27 Hemanth Removed code that calls trigger once again as runCodeBlock variable is made private.
//2015-10-27 Hemanth - Split into separate method for checking Update functionality
@IsTest
public class DS_UpdateCampaignAccountMember_Test {
    
    //Toggle enable/disable debug logs
    private static final boolean GENERATE_DEBUG_LOGS = true;
    
    //TestMethod control variables
    private static final boolean RUN_ALL = true;
    private static final boolean RUN_UPDATE_CAMPAIGN_ACC_MEMBER_INSERT = true;
    private static final boolean RUN_UPDATE_CAMPAIGN_ACC_MEMBER_UPDATE = true;
    
    @testSetup
    public static void loadData()
    {
        Account acct1 = new Account(Name='TestAccount');
        insert acct1;
        
        Campaign campaignObj1 = new Campaign(
            Name='Campaign1'
            ,Campaign_Source__c='Retail Solutions'
            ,StartDate=Date.today()
            ,EndDate=Date.today()
            ,IsActive=true
        );
        insert campaignObj1;
        
        Lead NewLead = new Lead(
            LastName='TEST Lead Last Name'
            ,Current_Account__c = acct1.Id
            ,FirstName='TEST Lead First Name'
            ,Company='TEST Company'
            ,LeadSource='API'
            ,Status='Rep Attempted Contact'
            ,ADP_Campaign__c = campaignObj1.ID                                
        );
        insert NewLead;
        
        Campaign_Member_Status__c NewCampaignMemberStatus = new Campaign_Member_Status__c();
        NewCampaignMemberStatus.Campaign__c = campaignObj1.Id;
        NewCampaignMemberStatus.Name = 'Member Status 1';
        insert NewCampaignMemberStatus;
        
        Campaign_Account_Members__c NewCampaignAccountMember1 = new Campaign_Account_Members__c();
        NewCampaignAccountMember1.Account__c = acct1.id;
        NewCampaignAccountMember1.Campaign_Member_Status__c = 'Member Status 1';
        NewCampaignAccountMember1.Campaign__c = campaignObj1.Id;
        NewCampaignAccountMember1.leadId__c = NewLead.ID;
        insert NewCampaignAccountMember1;
        
        Campaign campaignObj2 = new Campaign(
            Name='Campaign2'
            ,Campaign_Source__c='Retail Solutions'
            ,StartDate=Date.today()
            ,EndDate=Date.today()
            ,IsActive=true
        );
        insert campaignObj2;
        
        Campaign_Member_Status__c NewCampaignMemberStatus2 = new Campaign_Member_Status__c();
        NewCampaignMemberStatus2.Campaign__c = campaignObj2.Id;
        NewCampaignMemberStatus2.Name = 'Member Status 1';
        insert NewCampaignMemberStatus2;
        
        Campaign_Account_Members__c NewCampaignAccountMember2 = new Campaign_Account_Members__c();
        NewCampaignAccountMember2.Account__c = acct1.id;
        NewCampaignAccountMember2.Campaign__c = campaignObj2.Id;
        NewCampaignAccountMember2.Campaign_Member_Status__c = 'Member Status 1';
        NewCampaignAccountMember2.leadId__c = NewLead.ID;
        insert NewCampaignAccountMember2;
        
               
        Opportunity newOpportunity = new Opportunity(
            Name='TestOpportunity'
            ,ADP_Opportunity_Owner__c=UserInfo.getUserId()
            ,CloseDate=Date.today()
            ,StageName='Plan'
            ,Type='Add-on'
            ,AccountId = acct1.Id
            ,CampaignId = campaignObj1.ID 
        );
        insert newOpportunity;
    }
    
    public static testMethod void testUpdateCampaignAccMemberInsert()
    {
        if(RUN_ALL || RUN_UPDATE_CAMPAIGN_ACC_MEMBER_INSERT)
        {
            setHeaderLogs('Testing Update campaign account member method');
            
            User currentUser = [select id from User where id=:UserInfo.getUserId()];
            
            System.runAs(currentUser)
            {
                Test.startTest();
                Account accoutObj = [select id from Account where name='TestAccount' limit 1] ;
                Campaign campaignObj1 = [select id from Campaign where Name='Campaign1'];
               
                Opportunity newOpportunity =[select id from Opportunity where AccountId=:accoutObj.id];
                Lead NewLead = [select id from Lead where Current_Account__c=:accoutObj.Id];
                
                Campaign_Account_Members__c camAccMemberObj1 = [
                    select opportunityId__c,leadId__c,campaign__c,Campaign_Member_Status__c 
                    from Campaign_Account_Members__c 
                    where campaign__c=:campaignObj1.Id limit 1
                ];
                
                String expectedOppID = newOpportunity.Id;
                String actualOppID = camAccMemberObj1.opportunityId__c;
                String expectedLeadId = NewLead.Id;
                String actualeadID = camAccMemberObj1.leadId__c;
                String expCampAccMemStatus = 'Converted to Opportunity';
                String actCampAccMemStatus = camAccMemberObj1.Campaign_Member_Status__c;
                
                system.debug(expectedLeadId);
                system.debug(actualeadID);
                
                System.assertEquals(expectedOppID, actualOppID);
                System.assertEquals(expectedLeadId, actualeadID);
                System.assertEquals(expCampAccMemStatus, actCampAccMemStatus);
                
                Test.stopTest();
            }   
        }
    }
    
    public static testMethod void testUpdateCampaignAccountMemberUpdate()
    {
        
        if(RUN_ALL || RUN_UPDATE_CAMPAIGN_ACC_MEMBER_UPDATE )
        {
            setHeaderLogs('Testing Update campaign account member method');
            User currentUser = [select id from User where id=:UserInfo.getUserId()];
            System.runAs(currentUser)
            {
                Test.startTest();   
                Account accoutObj = [select id from Account where name='TestAccount' limit 1] ;
                Campaign campaignObj1 = [select id from Campaign where Name='Campaign1'];
                
                Opportunity newOpportunity =[select id,CampaignId from Opportunity where AccountId=:accoutObj.id];
                Lead NewLead = [select id,ADP_Campaign__c from Lead where Current_Account__c=:accoutObj.Id];
                
                Campaign campaignObj2 = [select id from Campaign where Name='Campaign2'];
                newOpportunity.CampaignId = campaignObj2.Id;
                NewLead.ADP_Campaign__c = campaignObj2.Id;
                update newOpportunity;
                update NewLead;
                
                Campaign_Account_Members__c camAccMemberObj1 = [
                    select opportunityId__c,leadID__c,campaign__c 
                    from Campaign_Account_Members__c 
                    where campaign__c=:campaignObj1.Id limit 1
                ];
                
                Campaign_Account_Members__c camAccMemberObj2 = [
                    select opportunityId__c,leadID__C,campaign__c 
                    from Campaign_Account_Members__c 
                    where campaign__c=:campaignObj2.Id limit 1
                ];
                
                String expectedOppID =newOpportunity.Id;
                String actualOppID = camAccMemberObj2.opportunityId__c;
                String expectedLeadId =NewLead.Id;
                String actualeadID = camAccMemberObj2.leadId__c;
                
                System.assertEquals(expectedOppID, actualOppID);
                System.assertEquals(expectedLeadId, actualeadID);
                System.assertNotEquals(camAccMemberObj1.OpportunityID__c, newOpportunity.Id);
                               
                Test.stopTest();
            }
        }
    }
    
            
    private static void setHeaderLogs(String txt)
    {
        if(GENERATE_DEBUG_LOGS)
        {
            //Genereate debug logs
            System.debug('**********************************');
            System.debug('***** '+txt);
            System.debug('**********************************');  
        }
        
    }
}