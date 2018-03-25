@isTest
public class DSCB_CampaignManagerControllerTest
{
    // -- Test methods
    
    public static testmethod void CampaginManagerInitializationTest()
    {
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
    }
    
    public static testmethod void SearchCampaignsTest()
    {
        DS_TestObjects.NewCampaign_Inserted();
        DSCB_CampaignManagerController.SearchCampaigns('test');
        DSCB_CampaignManagerController.SearchCampaigns('');
    }
    
    public static testmethod void FindCampaignAccountMembersTest()
    {
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
            ,null);
    }
    
    public static testmethod void GetAllAccountMemberStatusesTest()
    {
        Campaign_Member_Status__c NewCampaignMemberStatus = DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetAllAccountMemberStatuses(NewCampaignMemberStatus.Campaign__c);
    }
    
    //2nd Dec, 2014: Added by Anirudh
    public static testmethod void GetAllRegionsTest()
    {
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetAllRegions(NewCampaignMemberStatus.Campaign__c);
    }
    
    //2nd Dec, 2014: Added by Anirudh
    public static testmethod void GetAllKeyDOSTest()
    {
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetAllKeyDOS(NewCampaignMemberStatus.Campaign__c);
    }
    
    //16th Dec, 2014: Added by Vishal Bandari
    public static testmethod void GetAllKeyREPTest()
    {
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetAllKeyREP(NewCampaignMemberStatus.Campaign__c);
    }
    
    //16th Dec, 2014: Added by Vishal Bandari
    public static testmethod void GetAllTSMTest()
    {
        Campaign_Member_Status__c NewCampaignMemberStatus=DS_TestObjects.NewCampaignMemberStatus_Inserted();
        DSCB_CampaignManagerController.GetAllTSM(NewCampaignMemberStatus.Campaign__c);
    }
    
    public static testmethod void UpdateAccountMemberStatusTest()
    {
        Campaign_Account_Members__c NewCampaignAccountMember = null;
        
        DSCB_CampaignManagerController.UpdateAccountMemberStatus(null,null);
        DSCB_CampaignManagerController.UpdateAccountMemberStatus(new List<String>(),null);
        
        NewCampaignAccountMember = new Campaign_Account_Members__c();
        NewCampaignAccountMember.Account__c = DS_TestObjects.NewAccount_Inserted().Id;
        NewCampaignAccountMember.Campaign_Member_Status__c = 'Not Contacted Yet';
        insert NewCampaignAccountMember;
        
        List<String> IdsToUpdate = new List<String>(); IdsToUpdate.add(NewCampaignAccountMember.Id);
        
        DSCB_CampaignManagerController.UpdateAccountMemberStatus(IdsToUpdate,'Test');
        
        NewCampaignAccountMember 
            = DS_TestObjects.NewCampaignAccountMember_WithSystemAtDealership_Inserted();
        
        IdsToUpdate = new List<String>(); IdsToUpdate.add(NewCampaignAccountMember.Id);
        
        DSCB_CampaignManagerController.UpdateAccountMemberStatus(IdsToUpdate,'Test');
        
        Campaign_Member_Status__c NewCampaignMemberStatus = new Campaign_Member_Status__c();
        NewCampaignMemberStatus.Campaign__c = NewCampaignAccountMember.Campaign__c;
        NewCampaignMemberStatus.Name = 'Not Contacted Yet';
        insert NewCampaignMemberStatus;
        
        DSCB_CampaignManagerController.UpdateAccountMemberStatus(IdsToUpdate,NewCampaignMemberStatus.Name);
    }
    
    public static testmethod void FindContactsTest()
    {
        // test find contacts bad data case
        DSCB_CampaignManagerController.FindContacts(
            new String[]{'abcdefghijklmnopqrstuvwxyz'},
            new String[]{'abcdefghijklmnopqrstuvwxyz'}
        );
        
        // get a valid list of contact roles for testing
        List<String> AllContactRoles = DSCB_CampaignManagerController.getContactRoles();
        
        // get a campaign account member for testing
        Campaign_Account_Members__c NewCampaignAccountMember 
            = DS_TestObjects.NewCampaignAccountMember_WithSystemAtDealership_Inserted();
        
        // find contacts for the campaign account member
        DSCB_CampaignManagerController.FindContacts(
            new String[]{NewCampaignAccountMember.Id},
            (AllContactRoles.IsEmpty()?null:new String[]{AllContactRoles[0]})
        );
    }
    
    public static testmethod void AddContactTest()
    {
        //AddContact(String FirstName, String LastName, String CampaignAccountMemberId, String Role, String Email, String Phone)
        
        DSCB_CampaignManagerController.AddContact(null,null,null,null,null,null);
        
        // get a campaign account member for testing
        Campaign_Account_Members__c NewCampaignAccountMember 
            = DS_TestObjects.NewCampaignAccountMember_WithSystemAtDealership_Inserted();
        
        // get a valid list of contact roles for testing
        List<String> AllContactRoles = DSCB_CampaignManagerController.getContactRoles();
        
        // Test with a valid CampaignAccountMember ID
        DSCB_CampaignManagerController.AddContact('Test 1','Test 1',NewCampaignAccountMember.Id,AllContactRoles[0],'test123456@adp.com','0000000000');
        
        // Test with an invalid CampaignAccountMember ID
        DSCB_CampaignManagerController.AddContact('Test 1','Test 1','abcdefghijklmnopqrstuvwxyz',AllContactRoles[0],'test123456@adp.com','0000000000');
        
        // Test with a valid Account ID
        DSCB_CampaignManagerController.AddContact('Test 1','Test 1',NewCampaignAccountMember.Account__c,AllContactRoles[0],'test123456@adp.com','0000000000');
        
        // Test with a duplicate contact
        DSCB_CampaignManagerController.AddContact('Test 1','Test 1',NewCampaignAccountMember.Account__c,AllContactRoles[0],'test123456@adp.com','0000000000');
    }
    
    public static testmethod void FindActivitiesTest()
    {
        //FindActivities(List<String> CampaignAccountMemberIds, String RequestType, Boolean MyActivities, Boolean ActivitiesSince)
        
        // get a campaign account member for testing
        Campaign_Account_Members__c NewCampaignAccountMember 
            = DS_TestObjects.NewCampaignAccountMember_WithTaskAndEvent_Inserted();
        
        DSCB_CampaignManagerController.FindActivities(new String[]{},'open',true,true);
        DSCB_CampaignManagerController.FindActivities(new String[]{NewCampaignAccountMember.Id},'open',true,true);
    }
    
    public static testmethod void SendEmailsTest()
    {
        // running as admin should get all templates
        EmailTemplate TestTemplate = DS_TestObjects.NewEmailTemplate_Inserted();
        if(TestTemplate.Id == null) { TestTemplate = [Select Id, Name From EmailTemplate Where Folder.Type = 'Email' Limit 1]; }
        
        List<Contact> TestContacts = new List<Contact>();
        List<String> TestContactIds = new List<String>();
        
        // get some test contacts to work with
        TestContacts.add(DS_TestObjects.NewContact_Inserted());
        TestContacts.add(DS_TestObjects.NewContact_Inserted());
        
        for(Contact c : TestContacts) { c.Email = 'matt.keefe@adp.com'; c.Role__c = 'Test Role'; TestContactIds.add(c.Id); }
        update TestContacts; // 9/29
        
        // test the failure case
        DSCB_CampaignManagerController.SendEmails(null,TestContactIds);
        
        // try sending an e-mail
        DSCB_CampaignManagerController.SendEmails(TestTemplate.Id,TestContactIds);
    }
    
    public static testmethod void GetEmailTemplatesTest()
    {
        // running as admin should get all templates
        List<EmailTemplate> Templates = DSCB_CampaignManagerController.getEmailTemplates();
    }
    
    // -- Test this class
    
    public static testmethod void Test()
    {
        DSCB_CampaignManagerControllerTest CMTest = new DSCB_CampaignManagerControllerTest();
    }
}