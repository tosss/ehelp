// 2016-03-31   vishal.bandari@cdk.com           RQ-06471: to open page from Work My leads Page with lead Details
@IsTest
public class DS_ActivityOpportunityController_Test 
{
    testMethod static void ActivityOpportunityController()
    {
        Campaign c = new Campaign(Name='NCTEST'); insert c;
        Account acct = new Account(Name='ACCTTEST'); insert acct;
        Contact contact = new Contact(Department__c='Dealership Wide', Title__c='Manager', FirstName='John', LastName='Test', AccountId=acct.Id, Role__c='Test Role'); insert contact; // 9/29
        Campaign_Account_Members__c cam = new Campaign_Account_Members__c(Campaign__c=c.Id, Account__c=acct.Id, Campaign_Member_Status__c='Progress'); insert cam; // 9/30
        Campaign_Member_Status__c cms = new Campaign_Member_Status__c(Campaign__c=c.Id, Name='Test Status'); insert cms;
        
       
        PageReference p = Page.activityOpportunity;
        p.getParameters().put('campaignId', c.Id);
        p.getParameters().put('accountId', acct.Id);
        p.getParameters().put('contactId', contact.Id);
        p.getParameters().put('retURL', '/home/home.jsp');
        Test.setCurrentPage(p);
        
        //Test.startTest();
        
        DS_ActivityOpportunityController act = new DS_ActivityOpportunityController();
       
        act.getLinkTime();
        act.getRecTypeName();
        act.getStartTime();
        act.setStartTime('11:00 AM');
        act.getEndTime();
        act.setEndTime('12:30 AM');
        act.getItems();
        act.getCampaignMemberStatus();
        act.setCampaignMemberStatus('test');
        act.getAcct();
        act.getCampAcctMem();
        act.getReminderTime();
        act.setReminderTime('test');
        act.flipSwitch();
        act.getReminderTimes();
        act.getContact();
        act.getTask();
        act.getFollowUpEvent();
        
        // added 3/10/2015 SivaP
        act.getProfileVFSettings();
        act.getRenderCobalt();
        act.getRenderDS();       
        act.getShowBlock();        
        act.getRecTypeTaskName();
        
        PageReference pSave = act.save();
        PageReference pCancel = act.cancel();
        
        try{ act.modifyEvent(); }
        catch(Exception e) { system.debug(e); }   
        
        Test.startTest();
        act.saveAndCreateOpt();
        act.saveAndCreateLead();        
        Test.stopTest();      
    }
    
    testMethod static void test2()
    {       
        Campaign c = new Campaign(Name='NCTEST'); insert c;
        Account acct = new Account(Name='ACCTTEST'); insert acct;
        Contact contact = new Contact(Department__c='Dealership Wide', Title__c='Manager', FirstName='John', LastName='Test', AccountId=acct.Id, Role__c='Test Role'); insert contact; // 9/29
        Campaign_Account_Members__c cam = new Campaign_Account_Members__c(Campaign__c=c.Id, Account__c=acct.Id, Campaign_Member_Status__c='Progress'); insert cam; // 9/30
        Campaign_Member_Status__c cms = new Campaign_Member_Status__c(Campaign__c=c.Id, Name='Test Status'); insert cms;
        
         //added 3/10/2015 SivaP
        string ProfileName = [Select Id, Name From Profile Where Id = :userInfo.getProfileId() limit 1].Name;
        
        //2015-05-04 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting
        //Campaign_Mgmt_VF_Page_Assignment__c cmAssign = new Campaign_Mgmt_VF_Page_Assignment__c();
        Campaign_Mgmt_VF_Page_Assign__c cmAssign = new Campaign_Mgmt_VF_Page_Assign__c();
        cmAssign.Name = 'Test Mapping ID 000001';
        cmAssign.Campaign_VF_Layout__c = 'inside sales'; 
        cmAssign.Profile_Name__c = ProfileName;
        cmAssign.Show_Log_a_Call__c = false;
        insert cmAssign;
       
        PageReference p = Page.activityOpportunity;
        p.getParameters().put('campaignId', c.Id);
        p.getParameters().put('accountId', acct.Id);
        p.getParameters().put('contactId', contact.Id);
        p.getParameters().put('retURL', '/home/home.jsp');
        Test.setCurrentPage(p);
        
        //Test.startTest();
        
        DS_ActivityOpportunityController act = new DS_ActivityOpportunityController();        
       
        act.getLinkTime();
        act.getRecTypeName();
        act.getStartTime();
        act.setStartTime('12:00 PM');
        act.getEndTime();
        act.setEndTime('12:30 PM');
        act.getItems();
        act.getCampaignMemberStatus();
        act.setCampaignMemberStatus('test');
        act.getAcct();
        act.getCampAcctMem();
        act.getReminderTime();
        act.setReminderTime('test');
        act.flipSwitch();
        act.getReminderTimes();
        act.getContact();
        act.getTask();
        act.getFollowUpEvent();
        
        // added 3/10/2015 SivaP
        act.getProfileVFSettings();
        act.getRenderCobalt();
        act.getRenderDS();       
        act.getShowBlock();        
        act.getRecTypeTaskName();
        
        PageReference pSave = act.save();
        PageReference pCancel = act.cancel();
        
        try{ act.modifyEvent(); }
        catch(Exception e) { system.debug(e); }   
        
        act.showBlock = true;
        Test.startTest();
        act.saveAndCreateOpt();
        act.saveAndCreateLead();        
        Test.stopTest(); 
    }
    
    
    //2016-03-31   vishal.bandari@cdk.com           RQ-06471: to open page from Work My leads Page with lead Details
    testMethod static void test3()
    {
        Campaign c = new Campaign(Name='NCTEST'); insert c;
        Account acct = new Account(Name='ACCTTEST'); insert acct;
        Contact contact = new Contact(Department__c='Dealership Wide', Title__c='Manager', FirstName='John', LastName='Test', AccountId=acct.Id, Role__c='Test Role'); insert contact; // 9/29
        Campaign_Account_Members__c cam = new Campaign_Account_Members__c(Campaign__c=c.Id, Account__c=acct.Id, Campaign_Member_Status__c='Progress'); insert cam; // 9/30
        Campaign_Member_Status__c cms = new Campaign_Member_Status__c(Campaign__c=c.Id, Name='Test Status'); insert cms;
        
        Lead leadObj = DS_TestObjects.NewLead();
        leadObj.current_Account__c = acct.Id;
        leadObj.Contact__c = contact.Id;
        insert leadObj;
       
        PageReference p = Page.activityOpportunity;
        p.getParameters().put('campaignId', c.Id);
        p.getParameters().put('accountId', acct.Id);
        p.getParameters().put('contactId', contact.Id);
        p.getParameters().put('leadId', leadObj.Id);
        p.getParameters().put('retURL', '/home/home.jsp');
        Test.setCurrentPage(p);
        
        //Test.startTest();
        
        DS_ActivityOpportunityController act = new DS_ActivityOpportunityController();
       
        act.getLinkTime();
        act.getRecTypeName();
        act.getStartTime();
        act.setStartTime('11:00 AM');
        act.getEndTime();
        act.setEndTime('12:30 AM');
        act.getItems();
        act.getAcct();
        act.getReminderTime();
        act.setReminderTime('test');
        act.flipSwitch();
        act.getReminderTimes();
        act.getContact();
        act.getTask();
        act.getFollowUpEvent();
        
        act.getProfileVFSettings();
        act.getRenderCobalt();
        act.getRenderDS();       
        act.getShowBlock();        
        act.getRecTypeTaskName();
        
        PageReference pSave = act.save();
        PageReference pCancel = act.cancel();
        
        try{ act.modifyEvent(); }
        catch(Exception e) { system.debug(e); }     
    }
}