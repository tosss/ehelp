@IsTest
public class DS_UpdateCampaignAccountMember_Test {
    
    //Toggle enable/disable debug logs
    private static final boolean GENERATE_DEBUG_LOGS = true;
    //TestMethod control variables
    private static final boolean RUN_ALL = true;
    private static final boolean RUN_UPDATE_CAMPAIGN_ACC_MEMBER = true;
    
    @testSetup
    public static void loadData()
    {
        Account acct1 = new Account(Name='TestAccount');
        insert acct1;
        
        Campaign campaignObj1 = new Campaign(Name='Campaign1'
                                             ,Campaign_Source__c='Retail Solutions'
                                             ,StartDate=Date.today()
                                             ,EndDate=Date.today()
                                             ,IsActive=true
                                            );
        insert campaignObj1;
        
        Campaign_Member_Status__c NewCampaignMemberStatus = new Campaign_Member_Status__c();
        NewCampaignMemberStatus.Campaign__c = campaignObj1.Id;
        NewCampaignMemberStatus.Name = 'Member Status 1';
        insert NewCampaignMemberStatus;
        
        Campaign_Account_Members__c NewCampaignAccountMember1 = new Campaign_Account_Members__c();
        NewCampaignAccountMember1.Account__c = acct1.id;
        NewCampaignAccountMember1.Campaign_Member_Status__c = 'Member Status 1';
        NewCampaignAccountMember1.Campaign__c = campaignObj1.Id;
        insert NewCampaignAccountMember1;
        
        Campaign campaignObj2 = new Campaign(Name='Campaign2'
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
        insert NewCampaignAccountMember2;
        
    }
    
    public static testMethod void testUpdateCampaignAccMember()
    {
        if(RUN_ALL || RUN_UPDATE_CAMPAIGN_ACC_MEMBER )
        {
            setHeaderLogs('Testing Update campaign account member method');
            User currentUser = [select id from User where id=:UserInfo.getUserId()];
            System.runAs(currentUser)
            {
                Test.startTest();
                Account accoutObj = [select id from Account where name='TestAccount' limit 1] ;
                Campaign campaignObj1 = [select id from Campaign where Name='Campaign1'];
                Opportunity newOpportunity = new Opportunity(Name='TestOpportunity'
                                                             ,ADP_Opportunity_Owner__c=UserInfo.getUserId()
                                                             ,CloseDate=Date.today()
                                                             ,StageName='Plan'
                                                             ,Type='Add-on'
                                                             ,AccountId = accoutObj.Id
                                                             ,CampaignId = campaignObj1.ID 
                                                            );
                insert newOpportunity;
                
                Lead NewLead = new Lead(LastName='TEST Lead Last Name'
                                        ,Current_Account__c = accoutObj.Id
                                        ,FirstName='TEST Lead First Name'
                                        ,Company='TEST Company'
                                        ,LeadSource='API'
                                        ,Status='Rep Attempted Contact'
                                        ,ADP_Campaign__c = campaignObj1.ID                                
                                       );
                insert NewLead;
                
                Campaign_Account_Members__c camAccMemberObj1 = [select opportunityId__c,leadId__c,campaign__c from Campaign_Account_Members__c where campaign__c=:campaignObj1.Id limit 1];
                String expectedOppID =newOpportunity.Id;
                String actualOppID = camAccMemberObj1.opportunityId__c;
                String expectedLeadId =NewLead.Id;
                String actualeadID = camAccMemberObj1.leadId__c;
                System.assertEquals(expectedOppID, actualOppID);
                System.assertEquals(expectedLeadId, actualeadID);
                
                Campaign campaignObj2 = [select id from Campaign where Name='Campaign2'];
                newOpportunity.CampaignId = campaignObj2.Id;
                NewLead.ADP_Campaign__c = campaignObj2.Id;
                upsert newOpportunity;
                upsert NewLead;
                
                camAccMemberObj1 = [select opportunityId__c,leadID__c,campaign__c from Campaign_Account_Members__c where campaign__c=:campaignObj1.Id limit 1];
                Campaign_Account_Members__c camAccMemberObj2 = [select opportunityId__c,leadID__C,campaign__c from Campaign_Account_Members__c where campaign__c=:campaignObj2.Id limit 1];
                expectedOppID =newOpportunity.Id;
                actualOppID = camAccMemberObj2.opportunityId__c;
                expectedLeadId =NewLead.Id;
                actualeadID = camAccMemberObj2.leadId__c;
                System.assertEquals(expectedOppID, actualOppID);
                System.assertEquals(expectedLeadId, actualeadID);
                System.assertNotEquals(camAccMemberObj1.OpportunityID__c, newOpportunity.Id);
                System.assertNotEquals(camAccMemberObj1.leadID__c, NewLead.Id);
                
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