//2015-11-27 : vishal.bandari@cdk.com - RQ-05289:changed SendEmailsTest method to add contact record type
//2015-11-27 : vishal.bandari@cdk.com - changed email ids from adp to cdk
//2016-05-24- anirudh.singh@cdk.com- Modified for request RQ-06970 Campaign Manager changes for Shared Contacts.
//2016-11-11 - ragashalini.koka@cdk.com - Added test methods for RQ-06196 and RQ-08155
//2016-11-17 - ragashalini.koka@cdk.com - added test methods for RQ-08192
@isTest
public class DSCB_CampaignManagerControllerTest
{
    // -- Test methods
    
    public static testmethod void CampaginManagerInitializationTest()
    {
        system.debug('CampaginManagerInitializationTest start -->');
        // test constructor
        DSCB_CampaignManagerController CM = new DSCB_CampaignManagerController();
        
        // test static variables
        String EmptyListItemTest = DSCB_CampaignManagerController.EMPTY_LIST_ITEM;
        Set<String> TaskOpenStatusesTest = DSCB_CampaignManagerController.TASK_OPEN_STATUSES;
        
        // test global/complex variables
        DSCB_CampaignManagerController.CampaignAccountMember CAM 
            = new DSCB_CampaignManagerController.CampaignAccountMember();
        CAM.CampaignAccountMemberId = 'TEST';
        CAM.AccountName = 'CDK Global';
        CAM.CampaignAccountMemberStatus = 'Test';
        CAM.AccountMemberStatus = 'Test';
        CAM.SiteType = 'Test';
        CAM.City = 'Hoffman Estates';
        CAM.State = 'IL';
        CAM.VendorSystem = 'Test';
        CAM.BoxOnsite = false; 
        CAM.Age = '1';
        CAM.SoldDMSVendorSystem = 'Test';
        CAM.SoldDMSInstallDate = Date.Today();
        CAM.DoNotSolicit = false;
        CAM.ActivityHistories = new List<ActivityHistory>();
        CAM.OpenActivities = new List<ActivityHistory>();
        
        DSCB_CampaignManagerController.RemoteActionResponse RAR 
            = new DSCB_CampaignManagerController.RemoteActionResponse();
        RAR.Success = true;
        RAR.Message = 'Test';
        RAR.Objects = new List<sObject>();
        
        // test visualforce variables
        String CampaignAccountMemberIdTest = CM.CampaignAccountMemberId;
        CampaignAccountMemberIdTest = CM.getCampaignAccountMemberId();
        CM.setCampaignAccountMemberId('Test');
        Boolean GetCurrentUserIsInsideSales = CM.getProfileIsInsideSales();
        
        DS_TestObjects.NewCampaignMgmtVFPageAssignment_InsideSales_Inserted();
        
        User GetCurrentUserInfo = DSCB_CampaignManagerController.GetCurrentUserInfo();
        Boolean CurrentUserIsInsideSales = DSCB_CampaignManagerController.isInsideSales();
        system.debug('CampaginManagerInitializationTest end -->');
    }
    
    public static testmethod void SearchCampaignsTest()
    {
        system.debug('SearchCampaignsTest start -->');
        DS_TestObjects.NewCampaign_Inserted();
        DSCB_CampaignManagerController.SearchCampaigns('test');
        DSCB_CampaignManagerController.SearchCampaigns('');
        system.debug('SearchCampaignsTest end-->');
    }
    
    public static testmethod void FindCampaignAccountMembersTest()
    {
        system.debug('FindCampaignAccountMembersTest start -->');
        DS_TestObjects.NewCampaignMgmtVFPageAssignment_InsideSales_Inserted();
        
        Campaign_Account_Members__c NewCampaignAccountMember 
            = DS_TestObjects.NewCampaignAccountMember_WithSystemAtDealership_Inserted();
        
        DSCB_CampaignManagerController.FindCampaignAccountMembers(NewCampaignAccountMember.Campaign__c
            ,DSCB_CampaignManagerController.EMPTY_LIST_ITEM
            ,DSCB_CampaignManagerController.EMPTY_LIST_ITEM
            ,DSCB_CampaignManagerController.EMPTY_LIST_ITEM
            ,DSCB_CampaignManagerController.EMPTY_LIST_ITEM
            ,DSCB_CampaignManagerController.EMPTY_LIST_ITEM
            ,null
            ,null
            ,null
            ,null
            ,null);
        system.debug('FindCampaignAccountMembersTest end -->');
    }
    
    public static testmethod void GetAllAccountMemberStatusesTest()
    {
        system.debug('GetAllAccountMemberStatusesTest start -- >');
        Campaign_Member_Status__c NewCampaignMemberStatus = DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetAllAccountMemberStatuses(NewCampaignMemberStatus.Campaign__c);
        system.debug('GetAllAccountMemberStatusesTest end -- >');
    }
    
    //2nd Dec, 2014: Added by Anirudh
    public static testmethod void GetAllRegionsTest()
    {
        system.debug('GetAllRegionsTest start -->');
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetAllRegions(NewCampaignMemberStatus.Campaign__c);
        system.debug('GetAllRegionsTest end -->');
    }
    
    //2nd Dec, 2014: Added by Anirudh
    public static testmethod void GetAllKeyDOSTest()
    {
        system.debug('GetAllKeyDOSTest start -->');
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetAllKeyDOS(NewCampaignMemberStatus.Campaign__c);
        system.debug('GetAllKeyDOSTest end -->');
    }
    
    //16th Dec, 2014: Added by Vishal Bandari
    public static testmethod void GetAllKeyREPTest()
    {
        system.debug('GetAllKeyREPTest start -->');
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetAllKeyREP(NewCampaignMemberStatus.Campaign__c);
        system.debug('GetAllKeyREPTest end -->');
    }
    
    //16th Dec, 2014: Added by Vishal Bandari
    public static testmethod void GetAllTSMTest()
    {
        system.debug('GetAllTSMTest start -->');
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetAllTSM(NewCampaignMemberStatus.Campaign__c);
        system.debug('GetAllTSMTest end -->');
    }
    
    public static testmethod void UpdateAccountMemberStatusTest()
    {
        system.debug('UpdateAccountMemberStatusTest start --->');
        Campaign_Account_Members__c NewCampaignAccountMember = null;
        
        DSCB_CampaignManagerController.UpdateAccountMemberStatus(null,null, null);
        DSCB_CampaignManagerController.UpdateAccountMemberStatus(new List<String>(),null, null);
        
        NewCampaignAccountMember = new Campaign_Account_Members__c();
        NewCampaignAccountMember.Account__c = DS_TestObjects.NewAccount_Inserted().Id;
        NewCampaignAccountMember.Campaign_Member_Status__c = 'Not Contacted Yet';
        insert NewCampaignAccountMember;
        
        List<String> IdsToUpdate = new List<String>(); IdsToUpdate.add(NewCampaignAccountMember.Id);
        
        DSCB_CampaignManagerController.UpdateAccountMemberStatus(IdsToUpdate,'Test','PureCars');
        
        NewCampaignAccountMember 
            = DS_TestObjects.NewCampaignAccountMember_WithSystemAtDealership_Inserted();
        
        IdsToUpdate = new List<String>(); IdsToUpdate.add(NewCampaignAccountMember.Id);
        
        DSCB_CampaignManagerController.UpdateAccountMemberStatus(IdsToUpdate,'Test', 'C4 Analytics');
        
        Campaign_Member_Status__c NewCampaignMemberStatus = new Campaign_Member_Status__c();
        NewCampaignMemberStatus.Campaign__c = NewCampaignAccountMember.Campaign__c;
        NewCampaignMemberStatus.Name = 'Not Contacted Yet';
        insert NewCampaignMemberStatus;
        
        DSCB_CampaignManagerController.UpdateAccountMemberStatus(IdsToUpdate,NewCampaignMemberStatus.Name, 'Dealer.com');
        system.debug('UpdateAccountMemberStatusTest end --->');
    }
    
    public static testmethod void FindContactsTest()
    {
        system.debug('FindContactsTest start -->');
        // test find contacts bad data case
        DSCB_CampaignManagerController.FindContacts(
            new String[]{'abcdefghijklmnopqrstuvwxyz'},
            new String[]{'abcdefghijklmnopqrstuvwxyz'}
        );
        
        //2016-05-24- anirudh.singh@cdk.com- Modified getContactRoles to getContactRelationshipRoles for request RQ-06970.
        //2016-05-24- anirudh.singh@cdk.com- Modified AllContactRoles to AllContactRelationshipRoles for request RQ-06970.
        // get a valid list of contact roles for testing
        List<String> AllContactRelationshipRoles = DSCB_CampaignManagerController.getContactRelationshipRoles();
        
        // get a campaign account member for testing
        Campaign_Account_Members__c NewCampaignAccountMember 
            = DS_TestObjects.NewCampaignAccountMember_WithSystemAtDealership_Inserted();
        
        // find contacts for the campaign account member
        DSCB_CampaignManagerController.FindContacts(
            new String[]{NewCampaignAccountMember.Id},
            (AllContactRelationshipRoles.IsEmpty()?null:new String[]{AllContactRelationshipRoles[0]})
        );
        system.debug('FindContactsTest end -->');
    }
    
  /*  public static testmethod void AddContactTest()
    {
        //AddContact(String FirstName, String LastName, String CampaignAccountMemberId, String Role, String Email, String Phone)
        
        //DSCB_CampaignManagerController.AddContact(null,null,null,null,null,null);
        
        // get a campaign account member for testing
        Campaign_Account_Members__c NewCampaignAccountMember 
            = DS_TestObjects.NewCampaignAccountMember_WithSystemAtDealership_Inserted();
        
        //2016-05-24- anirudh.singh@cdk.com- Modified getContactRoles to getContactRelationshipRoles for request RQ-06970.
        //2016-05-24- anirudh.singh@cdk.com- Modified AllContactRoles to AllContactRelationshipRoles for request RQ-06970.
        // get a valid list of contact roles for testing
        List<String> AllContactRelationshipRoles = DSCB_CampaignManagerController.getContactRelationshipRoles();
        
        // Test with a valid CampaignAccountMember ID
        DSCB_CampaignManagerController.AddContact('Test 1','Test 1',NewCampaignAccountMember.Id,AllContactRelationshipRoles[0],'test123456@cdk.com','0000000000');
        
        // Test with an invalid CampaignAccountMember ID
        DSCB_CampaignManagerController.AddContact('Test 1','Test 1','abcdefghijklmnopqrstuvwxyz',AllContactRelationshipRoles[0],'test123456@cdk.com','0000000000');
        
        // Test with a valid Account ID
        DSCB_CampaignManagerController.AddContact('Test 1','Test 1',NewCampaignAccountMember.Account__c,AllContactRelationshipRoles[0],'test123456@cdk.com','0000000000');
        
        // Test with a duplicate contact
        DSCB_CampaignManagerController.AddContact('Test 1','Test 1',NewCampaignAccountMember.Account__c,AllContactRelationshipRoles[0],'test123456@cdk.com','0000000000');
    }
    */
    public static testmethod void FindActivitiesTest()
    {
        system.debug('FindActivitiesTest start -->');
        //FindActivities(List<String> CampaignAccountMemberIds, String RequestType, Boolean MyActivities, Boolean ActivitiesSince)
        
        // get a campaign account member for testing
        Campaign_Account_Members__c NewCampaignAccountMember 
            = DS_TestObjects.NewCampaignAccountMember_WithTaskAndEvent_Inserted();
        
        DSCB_CampaignManagerController.FindActivities(new String[]{},'open',true,true);
        DSCB_CampaignManagerController.FindActivities(new String[]{NewCampaignAccountMember.Id},'open',true,true);
        system.debug('FindActivitiesTest end -->');
    }
    
    public static testmethod void SendEmailsTest()
    {
        system.debug('SendEmailsTest start -->');
        // running as admin should get all templates
        EmailTemplate TestTemplate = DS_TestObjects.NewEmailTemplate_Inserted();
        if(TestTemplate.Id == null) { TestTemplate = [Select Id, Name From EmailTemplate Where Folder.Type = 'Email' Limit 1]; }
        
        List<Contact> TestContacts = new List<Contact>();
        List<String> TestContactIds = new List<String>();
        
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        Id rt  = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        // get some test contacts to work with
        Contact c1 =DS_TestObjects.NewContact();
        c1.RecordTypeId = rt;
        insert c1;
        Contact c2 =DS_TestObjects.NewContact();
        c2.RecordTypeId = rt;
        insert c2;
        TestContacts.add(c1);
        TestContacts.add(c2);
        
        for(Contact c : TestContacts) { c.Email = 'matt.keefe@cdk.com'; c.Role__c = 'Test Role'; TestContactIds.add(c.Id); }
        update TestContacts; // 9/29
        
        // test the failure case
        DSCB_CampaignManagerController.SendEmails(null,TestContactIds);
        
        // try sending an e-mail
        DSCB_CampaignManagerController.SendEmails(TestTemplate.Id,TestContactIds);
        system.debug('SendEmailsTest end -->');
    }
    
    public static testmethod void GetEmailTemplatesTest()
    {
        system.debug('GetEmailTemplatesTest start -->');
        // running as admin should get all templates
        List<EmailTemplate> Templates = DSCB_CampaignManagerController.getEmailTemplates();
        system.debug('GetEmailTemplatesTest end -->');
        
    }
	
	//2016-10-10 - lalitha.iitm@gmail.com - added - RQ07092    
    public static testmethod void getCompetitorsPicklistTest()
    {
        DSCB_CampaignManagerController.getCompetitorsPicklist();
    }
    
    //2016-11-11 - ragashalini.koka@cdk.com - Added for RQ-06196
    private static testmethod void GetDSMDOS()
    {
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetDSMDOS(NewCampaignMemberStatus.Campaign__c);
    }
    
     
    //2016-11-11 - ragashalini.koka@cdk.com - Added for RQ-08155
    private static testmethod void GetDSM()
    {
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetDSM(NewCampaignMemberStatus.Campaign__c);
    }
    
    //2016-11-17 - ragashalini.koka@cdk.com - Added for RQ-08192
    private static testmethod void GetDAA()
    {
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetDAA(NewCampaignMemberStatus.Campaign__c);
    }
    
    // -- Test this class
    
    public static testmethod void Test()
    {
        system.debug('Test start -->');
        DSCB_CampaignManagerControllerTest CMTest = new DSCB_CampaignManagerControllerTest();
        system.debug('Test end -->');
    }
}