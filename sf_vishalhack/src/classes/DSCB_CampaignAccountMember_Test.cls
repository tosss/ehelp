@isTest
public class DSCB_CampaignAccountMember_Test {
    static testMethod void campaignAccountMemberEdit() {
        PageReference pageRef = Page.DSCB_CampaignAccountMember_Custom;
        Test.setCurrentPage(pageRef);
        Account account = new Account();
        account.RecordTypeId = [SELECT id from RecordType where Name='ADPDS Customer' LIMIT 1].Id;
        account.Name='TestAccount';
        upsert account;
        
        Campaign campaign = new Campaign();
        campaign.Name = 'TestCampaign';
        campaign.StartDate = Date.today();
        campaign.EndDate = Date.today();
        campaign.Campaign_Source__c = 'CDP';
        upsert campaign;
        
        Campaign_Account_Members__c campaignAccountMember = new Campaign_Account_Members__c();
        campaignAccountMember.Campaign__c= campaign.Id;
        campaignAccountMember.Account__c=account.Id;
        campaignAccountMember.Campaign_Member_Status__c='TEST';
        upsert campaignAccountMember;
        
        pageRef.getParameters().put('id',campaignAccountMember.Id);
        pageRef.getParameters().put('retURL','000'+campaignAccountMember.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(campaignAccountMember);
        DSCB_CampaignAccountMember_Extension extension = new DSCB_CampaignAccountMember_Extension(sc);
        //Testing if its Create Page
        System.assertEquals(false, extension.getIsCreateMode());
        
        //Testing if its Edit Page
        System.assertEquals(true, extension.getIsEditMode());
        
        //Checking Status equals --None-- when there are no status available
        System.assertEquals(extension.getRelatedCampaignMemberStatus().size(),1);
       
        extension.save();
        extension.saveAndNew();
        
        
        
    }
    
    static testMethod void campaignAccountMemberCreate() {
        PageReference pageRef = Page.DSCB_CampaignAccountMember_Custom;
        Test.setCurrentPage(pageRef);
        Account account = new Account();
        account.RecordTypeId = [SELECT id from RecordType where Name='ADPDS Customer' LIMIT 1].Id;
        account.Name='TestAccount';
        upsert account;
        
        Campaign campaign = new Campaign();
        campaign.Name = 'TestCampaign';
        campaign.StartDate = Date.today();
        campaign.EndDate = Date.today();
        campaign.Campaign_Source__c = 'CDP';
        upsert campaign;
        
        Campaign_Account_Members__c campaignAccountMember = new Campaign_Account_Members__c();
        campaignAccountMember.Campaign__c= campaign.Id;
        campaignAccountMember.Account__c=account.Id;
        campaignAccountMember.Campaign_Member_Status__c='TEST';
        upsert campaignAccountMember;
        
        List<Campaign_Member_Status__c> campaignMemberStatusList = new List<Campaign_Member_Status__c>();
        Campaign_Member_Status__c campaignMemberStatus = new Campaign_Member_status__c();
        campaignMemberStatus.Campaign__c = campaign.Id;
        campaignMemberStatus.Name = 'TestStatus1';
        campaignMemberStatusList.add(campaignMemberStatus);
        campaignMemberStatus = new Campaign_Member_status__c();
        campaignMemberStatus.Campaign__c = campaign.Id;
        campaignMemberStatus.Name = 'TestStatus2';
        campaignMemberStatus.Default_Status__c = true;
        campaignMemberStatusList.add(campaignMemberStatus);
        upsert campaignMemberStatusList;
        
        pageRef.getParameters().put('retURL','0'+campaign.Id);
        ApexPages.StandardController sc = new ApexPages.standardController(campaignAccountMember);
        DSCB_CampaignAccountMember_Extension extension = new DSCB_CampaignAccountMember_Extension(sc);
        //Testing if its Create Page
        System.assertEquals(true, extension.getIsCreateMode());
        
        //Testing if its Edit Page
        System.assertEquals(false, extension.getIsEditMode());
        
        //Checking Status equals the list inserted above
        System.assertEquals(extension.getRelatedCampaignMemberStatus().size(),campaignMemberStatusList.size());
        
        extension.save();
        extension.saveAndNew();
        
        
    }
}