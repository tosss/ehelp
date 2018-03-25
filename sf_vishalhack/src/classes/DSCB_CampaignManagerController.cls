// 2012-01-13 matt.keefe@cdk.com Created
// 2015-10-21 matt.keefe@cdk.com (RQ-05289) Update - added recordtype for contact (ln 617)
//2016-05-03- anirudh.singh@cdk.com- Modified for request RQ-06970 Campaign Manager changes for Shared Contacts.
//2016-06-13 -venkata.shrivol@cdk.com -commented addContact method RQ-06986
//2016-10-10 - lalitha.iitm@gmail.com - modified method to update a campaign account member with competitor__c field and get all picklist values of Competitor__c field - RQ-07902
//2016-11-09 - vishal.bandari@cdk.com - Increased the Limit to 4000 from 2000 in SOQL - RQ-08154
//2016-11-09 - ragashalini.koka@cdk.com - added functionality to filter Campaign Account Members by DSM and DSM DOS for RQ-08155 and RQ-06196
//2016-11-15 - ragashalini.koka@cdk.com - added functionality for RQ-08192\
//2017-03-13 - ragashalini.koka@cdk.com - commented the Technology_Solutions_Manager references for RQ-08732
//2017-06-22- lalitha.adduru@cdk.com- Added 'Send Engage Email' button functionality - RQ-09359

global with sharing class DSCB_CampaignManagerController
{
    global List<SelectOption> competitors {get; set;} // added by lalitha.adduru@cdk.com - RQ-07902
    // -- constructor
    public DSCB_CampaignManagerController()
    {
    }
    
    @RemoteAction
    public static PageReference sendEngageEmailToContacts(List<String> objectIds)
    {
        List<pi__EngageCampaignRecipient__c> recipients = new List<pi__EngageCampaignRecipient__c>();
        pi__EngageCampaignRecipient__c recipient = null;
        for(String objectIdString : objectIds)
        {
            Id objectId = (Id)objectIdString;
            if(objectId.getsObjectType().getDescribe().getName().equals('Contact'))
            {
                recipient = new pi__EngageCampaignRecipient__c();
                recipient.pi__UserId__c = UserInfo.getUserId();
                recipient.pi__ContactId__c = objectId;
                recipient.pi__Status__c = 'queued';
                recipients.add(recipient);
            }
        }
        insert recipients; 
        String returnURL = getRedirectUrl();
        return new PageReference('/apex/pi__MicroCampaignCustom?pi_redirect='+returnURL).setRedirect(true);
    }
    
    private static String getRedirectUrl() {
        Schema.DescribeSObjectResult r =
            Contact.sObjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        return EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() +'/'+ keyPrefix + '/o', 'UTF-8');
    }


    
    // added by lalitha.adduru@cdk.com - RQ-07902
    @RemoteAction
    global static List<String> getCompetitorsPicklist()
    {
        system.debug('pickList option --> start');
        List<String> pickListOptions = new List<String>();
        Schema.DescribeFieldResult statusFieldDescription = Campaign_Account_Members__c.Competitor__c.getDescribe();
        for(Schema.pickListEntry option : statusFieldDescription.picklistvalues)
        {
            pickListOptions.add(option.getValue());
        }
        system.debug('pickList option --> '+pickListOptions);
        return pickListOptions;
        
    }
    
    // -- static variables
    public static String EMPTY_LIST_ITEM = '--None--';
    public static Set<String> TASK_OPEN_STATUSES = new Set<String>{'Not Started', 'In Progress', 'Waiting on someone else', 'Deferred','Consult Date Proposed','Consult Date Confirmed' };
        
    // -- complex variables (subclasses)
        
    // container for Campaign Account Member because it spans multiple objects
    global class CampaignAccountMember
    {
        global String CampaignAccountMemberId {get; set;} 
        global String CampaignAccountId {get; set;} 
        global String GroupName {get; set;}
        global String AccountName {get; set;}
        global String CampaignAccountMemberStatus {get; set;}
        global String AccountMemberStatus {get; set;}
        global String SiteType {get; set;}
        global String City {get; set;}
        global String State {get; set;}
        global String DesignatedDSM {get; set;}
        global String KeyRep {get; set;}
        global String VendorSystem {get; set;}
        global Boolean BoxOnsite {get; set;}
        global String Age {get; set;}
        global String SoldDMSVendorSystem {get; set;}
        global Date SoldDMSInstallDate {get; set;}
        global Boolean DoNotSolicit {get; set;}
        global List<ActivityHistory> ActivityHistories {get; set;}
        global List<ActivityHistory> OpenActivities {get; set;}
        global String Region {get; set;}    //12th Nov, 2014: Added by Anirudh.
        global String KeyDOS {get; set;}    //12th Nov, 2014: Added by Anirudh.
        global String KeyDOS_Id {get; set;}    //14th Nov, 2014: Added by Vishal
        global String DSMDOS {get; set;}    //Lalitha
        global String KeyREP_Id {get; set;}    //20th Nov, 2014: Added by Anirudh.
        global String DSM_Id {get; set;}    //20th Nov, 2014: Added by Anirudh.
        global String RegionsSelected {get; set;}    //20th Nov, 2014: Added by Anirudh.
        global String KeyDOSSelected {get; set;}    //21st Nov, 2014: Added by Anirudh.
        global String KeyREPSelected {get; set;}    //16th Dec, 2014 : Added by Vishal Bandari.
        global String TSMSelected {get; set;}       //16th Dec, 2014 : Added by Vishal Bandari.
        global String DigitalAdvertisingSpecialist {get; set;}
        global String DigitalAdvertisingSpecialistId {get; set;}
            
    }
    
    
    // container for Remote Action Responses
    global class RemoteActionResponse
    {
        global Boolean Success {get;set;}
        global String Message {get;set;}
        global List<sObject> Objects {get;set;}
    }
    
    // -- Remote Action methods accessed by JavaScript
    //Sanjay
    @RemoteAction global static String GetCampaignName(ID campaignId)
    {
        Campaign campaignObject =  [select name from Campaign where id=:campaignId LIMIT 1];
        return campaignObject.name;
    }
    
    @RemoteAction global static User GetCurrentUserInfo()
    {
        return new User(
            ID=UserInfo.getUserId(),
            FirstName=UserInfo.getFirstName(),
            LastName=UserInfo.getLastName(),
            UserName=UserInfo.getUserName()
        );
    }
    
    @RemoteAction
    global static Boolean isInsideSales()
    {
        Boolean result = false;
        //2015-05-04 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting
        List<Campaign_Mgmt_VF_Page_Assign__c> CampaignMgmtVFPageAssigmnment = GetCampaignMgmtVFPageAssigmnment(true);
        //List<Campaign_Mgmt_VF_Page_Assignment__c> CampaignMgmtVFPageAssigmnment = GetCampaignMgmtVFPageAssigmnment(true);
        
        if(!CampaignMgmtVFPageAssigmnment.IsEmpty())
        {
            if(CampaignMgmtVFPageAssigmnment != null && CampaignMgmtVFPageAssigmnment.size() > 0) 
            {
                result = true;
            }
        }
        return result;
    }
    
    //2015-05-04 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting (Return Type)
    @RemoteAction
    //global static List<Campaign_Mgmt_VF_Page_Assignment__c> GetCampaignMgmtVFPageAssigmnment(Boolean FilterInsideSales)
    global static List<Campaign_Mgmt_VF_Page_Assign__c> GetCampaignMgmtVFPageAssigmnment(Boolean FilterInsideSales)
    {
        system.debug(UserInfo.getProfileId());
        
        Profile p = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId() LIMIT 1];
        
        //2015-05-04 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting
        //List<Campaign_Mgmt_VF_Page_Assignment__c> CampaignMgmtVFPageAssigmnment = Database.query(
        List<Campaign_Mgmt_VF_Page_Assign__c> CampaignMgmtVFPageAssigmnment = Database.query(
            ' SELECT Id, Profile_Name__c, Campaign_VF_Layout__c, Filter_by_Account_Team__c '
            + ' FROM Campaign_Mgmt_VF_Page_Assign__c '
            + ' WHERE Profile_Name__c = \''+p.Name+'\' '
            + ((FilterInsideSales)?' AND Campaign_VF_Layout__c = \'Inside Sales\' ':'')
        );
        //+ ' FROM Campaign_Mgmt_VF_Page_Assignment__c '
        
        return CampaignMgmtVFPageAssigmnment;
    }
    
    @RemoteAction
    global static List<Campaign> SearchCampaigns (String CampaignSearchTerm)
    {
        List<sObject> SearchList = null;
        
        if(CampaignSearchTerm != null)
        {
            if(CampaignSearchTerm.length() > 0)
            { 
                List<List<sObject>> SoslSearchList = [FIND :CampaignSearchTerm RETURNING Campaign (Id, Name Where IsActive = true And Status = 'In Progress' Order By Name)];
                
                if(SoslSearchList != null)
                {
                    SearchList = (SoslSearchList[0] != null ? SoslSearchList[0] : null); 
                }
            }
            else
            {
                SearchList = [Select Id, Name From Campaign Where IsActive = true And Status = 'In Progress' Order By Name];
            }
        }
        
        return SearchList;
    }
    
    @RemoteAction
    global static List<CampaignAccountMember> FindCampaignAccountMembers (
        String CampaignId, String AccountState, String KeyDOSSelected, String KeyREPSelected, String TSMSelected,
        String AccountStartsWith, List<String> AccountMemberStatus, List<String> RegionsSelected, String DSMSelected, String DSMDOSSelected, String DASSelected)
    {
       
        Map<Id,CampaignAccountMember> FullCampaignAccountMembers = new Map<Id,CampaignAccountMember>(); // by Account Id (in map)
        
        if(AccountState == EMPTY_LIST_ITEM)
        {
            AccountState = null;
        }
        
        if(KeyDOSSelected== EMPTY_LIST_ITEM)  //21st Nov, 2014: Added by Anirudh.
        {
            KeyDOSSelected= null;
        }
        
        if(KeyREPSelected== EMPTY_LIST_ITEM)  //16th Dec, 2014 : Added by Vishal Bandari.
        {
            KeyREPSelected= null;
        }
        
        if(TSMSelected== EMPTY_LIST_ITEM)  //16th Dec, 2014 : Added by Vishal Bandari.
        {
            TSMSelected= null;
        }
        
        if(AccountStartsWith == EMPTY_LIST_ITEM)
        {
            AccountStartsWith = null;
        }
        
        if(DSMSelected == EMPTY_LIST_ITEM) 
        {
            DSMSelected = null;
        }
        
        if(DSMDOSSelected == EMPTY_LIST_ITEM) 
        {
            DSMDOSSelected = null;
        }
        if(DASSelected == EMPTY_LIST_ITEM) 
        {
            DASSelected = null;
        }
	        
        
        //2015-05-04 hemanth.kesapragada@cdk.com RQ-04227 Changed custom object to custom setting       
        // check if only the Accounts for which the current User is a member of the Account Team should be returned.
        //List<Campaign_Mgmt_VF_Page_Assignment__c> CampaignMgmtVFPageAssigmnment = GetCampaignMgmtVFPageAssigmnment(false);
        List<Campaign_Mgmt_VF_Page_Assign__c> CampaignMgmtVFPageAssigmnment = GetCampaignMgmtVFPageAssigmnment(false);
        
        Boolean FilterByAccountTeam = false;
        
        if(!CampaignMgmtVFPageAssigmnment.IsEmpty()) 
        { 
            if(CampaignMgmtVFPageAssigmnment[0].Filter_by_Account_Team__c) 
            {
                FilterByAccountTeam = true; 
            } 
        }
        
        Set<ID> UniqueAccountIds = new Set<ID>();
        
        if(FilterByAccountTeam) 
        { 
            List<Account_Team__c> AccountTeams = new List<Account_Team__c>();
            AccountTeams = [Select Id, Account__c From Account_Team__c Where Team_Member__c = :UserInfo.getUserId()]; 
            
            for(Account_Team__c AccountTeam : AccountTeams) 
            { 
                UniqueAccountIds.add(AccountTeam.Account__c); 
            }
        }
        
        // end check Account Team
        
        // get Campaign Account Members
        // 20th Nov, 2014: Additional filters for KeyDOSSelected and RegionsSelected added by Anirudh, 
        // 2nd Dec, 2014: TSMStartsWith added by Anirudh
        // 16th Dec, 2014 : KeyREPSelected and TSMSelected added by Vishal Bandari.
        // 27th Jan, 2016: Removed Out of Business and Duplicate filters as there are some digital campaign account members as OOB/Duplicate that DSMs need access to by Dave Hanson
        // 21st Nov, 2016:  vishal.bandari@cdk.com - Increased the Limit to 4000 from 2000 in SOQL - RQ-08154
        // 2017-03-13 - commented the Technology_Solutions_Manager__c references
        List<Campaign_Account_Members__c> CampaignAccountMembers = Database.query(
            + ' Select Id, Name, Account__c, Campaign__c, '
            + ' Account__r.Name, Campaign_Member_Status__c, Account__r.Site_Type__r.Name, '
            + ' Account__r.BillingCity, Account__r.BillingState,Account__r.Dealer_Group_Name2__c, Account__r.Do_Not_Solicit__c, '
            + ' Account__r.Key_Rep__c, Account__r.Key_Rep__r.Name, '
            + ' Account__r.DSM_DOS__c, '
            + ' Account__r.Designated_DSM__c, Account__r.Designated_DSM__r.Name, Account__r.Region__c, Account__r.Key_DOS__r.Name, Account__r.Key_DOS__r.Id,'// Account__r.Technology_Solutions_Manager__r.Name,' //12th Nov, 2014: Anirudh added Account__r.Region__c, Account__r.Key_DOS__c and 14th Nov, 2014:Vishal added Account__r.Key_DOS__r.Id.
            + ' Account__r.Key_Rep__r.Id, Account__r.Designated_DSM__r.Id,' //20th Nov, 2014: Anirudh added Account__r.Key_Rep__c.Id, Account__r.Designated_DSM__r.Id, 2nd Dec, 2014: Account__r.Technology_Solutions_Manager__r.Name added by Anirudh
            + ' Account__r.Digital_Advertising_Specialist__c,Account__r.Digital_Advertising_Specialist__r.Id, Account__r.Digital_Advertising_Specialist__r.Name '
            + ' From Campaign_Account_Members__c '
            + ' Where Campaign__c = :CampaignId ' 
            // + ' And Account__r.Out_of_Business__c != true' // Feb 26, 2015 Khan :  RQ-04052 change it to look for checkboxes 
            // + ' And Account__r.Duplicate__c != true' // Feb 26, 2015 Khan :  RQ-04052 change it to look for checkboxes 
            + ((AccountState != null && AccountState != '' && AccountState != EMPTY_LIST_ITEM)?' And Account__r.BillingState = :AccountState ':'')
            + ((KeyDOSSelected != null && KeyDOSSelected != '' && KeyDOSSelected != EMPTY_LIST_ITEM)?' And Account__r.Key_DOS__r.Name = :KeyDOSSelected ':'')
            + ((KeyREPSelected != null && KeyREPSelected != '' && KeyREPSelected != EMPTY_LIST_ITEM)?' And Account__r.Key_REP__r.Name = :KeyREPSelected ':'')
           // + ((TSMSelected != null && TSMSelected != '' && TSMSelected != EMPTY_LIST_ITEM)?' And Account__r.Technology_Solutions_Manager__r.Name = :TSMSelected ':'')
            + ((AccountStartsWith != null && AccountStartsWith != '')?' And Account__r.Name like \''+AccountStartsWith+'%\' ':'')
            + ((AccountMemberStatus != null)?' And Campaign_Member_Status__c IN :AccountMemberStatus ':'')
            + ((RegionsSelected!= null)?' And Account__r.Region__c IN :RegionsSelected ':'')
            + ((FilterByAccountTeam && !UniqueAccountIds.IsEmpty())?' And Account__c IN :UniqueAccountIds ':'')
            + ((DSMSelected != null && DSMSelected != '' && DSMSelected != EMPTY_LIST_ITEM)?' And Account__r.Designated_DSM__r.Name = :DSMSelected ':'')
            + ((DSMDOSSelected != null && DSMDOSSelected != '' && DSMDOSSelected != EMPTY_LIST_ITEM)?' And Account__r.DSM_DOS__c = :DSMDOSSelected ':'')
            + ((DASSelected != null && DASSelected != '' && DASSelected != EMPTY_LIST_ITEM)?' And Account__r.Digital_Advertising_Specialist__r.Name = :DASSelected ':'')
            + ' Order BY Account__r.Name ASC '
            + ' LIMIT 4000 '
        );    
        
        // Map Campaign Account Members for getting later
        for(Campaign_Account_Members__c CAMember : CampaignAccountMembers) 
        { 
            CampaignAccountMember NewFullCAMember = new CampaignAccountMember();
            
            NewFullCAMember.CampaignAccountMemberId = CAMember.Id;
            NewFullCAMember.CampaignAccountId = CAMember.Account__c;
            NewFullCAMember.AccountName = CAMember.Account__r.Name;
            NewFullCAMember.GroupName = CAMember.Account__r.Dealer_Group_Name2__c;
            NewFullCAMember.CampaignAccountMemberStatus = CAMember.Campaign_Member_Status__c;
            NewFullCAMember.SiteType = CAMember.Account__r.Site_Type__r.Name;
            NewFullCAMember.City = CAMember.Account__r.BillingCity;
            NewFullCAMember.State = CAMember.Account__r.BillingState;
            NewFullCAMember.DesignatedDSM = (CAMember.Account__r.Designated_DSM__c != null ? CAMember.Account__r.Designated_DSM__r.Name : '');
            NewFullCAMember.KeyRep = (CAMember.Account__r.Key_Rep__c != null ? CAMember.Account__r.Key_Rep__r.Name : '');
            NewFullCAMember.DoNotSolicit = CAMember.Account__r.Do_Not_Solicit__c ;
            NewFullCAMember.Region = CAMember.Account__r.Region__c;    //12th Nov, 2014: Added by Anirudh.
            NewFullCAMember.KeyDOS = CAMember.Account__r.Key_DOS__r.Name;     //12th Nov, 2014: Added by Anirudh.
            NewFullCAMember.KeyDOS_Id = CAMember.Account__r.Key_DOS__r.Id;       //14th Nov, 2014: Added by Vishal
            NewFullCAMember.KeyREP = CAMember.Account__r.Key_REP__r.Name;
            NewFullCAMember.KeyREP_Id = CAMember.Account__r.Key_Rep__r.Id; 
            NewFullCAMember.DSMDOS = CAMember.Account__r.DSM_DOS__c;     //Lalitha
            NewFullCAMember.DSM_Id = CAMember.Account__r.Designated_DSM__r.Id;       //20th Nov, 2014: Added by Anirudh.
            //NewFullCAMember.TSMSelected = CAMember.Account__r.Technology_Solutions_Manager__r.Name;
            NewFullCAMember.DigitalAdvertisingSpecialist =
                CAMember.Account__r.Digital_Advertising_Specialist__c != null ? CAMember.Account__r.Digital_Advertising_Specialist__r.Name : '';
            NewFullCAMember.DigitalAdvertisingSpecialistId = CAMember.Account__r.Digital_Advertising_Specialist__r.Id;
              
           
            FullCampaignAccountMembers.put(CAMember.Account__c,NewFullCAMember); 
        }
        
        // get Systems
        List<System_at_Dealership__c> AccountSystems = [
            Select Account__c, System_Type__c, Vendor__c, Sold_DMS_Vendor__c, Sold_Date__c, 
            Vendor__r.Name, Box_Onsite__c, Age__c, Sold_DMS_Vendor__r.Name, Install_Date__c, Sold_DMS_Estimated_Install_Date__c 
            From System_at_Dealership__c
            Where System_Type__c = 'DMS'
            And Account__c IN :FullCampaignAccountMembers.keySet()
        ];
        
        // add System data to Campaign Account Members map
        for(System_at_Dealership__c AccountSystem : AccountSystems) 
        {
            CampaignAccountMember FullCAMember = FullCampaignAccountMembers.get(AccountSystem.Account__c);
            
            FullCAMember.VendorSystem = AccountSystem.Vendor__r.Name;
            FullCAMember.BoxOnsite = AccountSystem.Box_Onsite__c;
            FullCAMember.Age = String.valueOf(AccountSystem.Age__c);
            FullCAMember.SoldDMSVendorSystem = AccountSystem.Sold_DMS_Vendor__r.Name; 
            FullCAMember.SoldDMSInstallDate = AccountSystem.Install_Date__c;
        }
        
        // return complete Campaign Account Members data
        return FullCampaignAccountMembers.values();
        
    }
    
    @RemoteAction
    global static List<String> GetAllAccountMemberStatuses(String CampaignId) 
    {
        List<String> options = new List<String>();
        
        List<Campaign_Member_Status__c> campaignsMemberStatuses = [SELECT Name, Campaign__c FROM Campaign_Member_Status__c WHERE Campaign__c = :CampaignId ORDER BY Name];
        
        Set<String> uniqueStatuses = new Set<String>();
        
        for(Campaign_Member_Status__c status : campaignsMemberStatuses)
        {
            uniqueStatuses.add(status.name); 
        }
        
        List<String> statuses = new List<String>();
        statuses.addAll(uniqueStatuses);
        statuses.sort();
        
        for(String status : statuses) 
        {
            options.add(status);
        }
        
        return options;
    }
    
    //20th Nov, 2014: Added by Anirudh.
    @RemoteAction
    global static List<String> GetAllRegions(String CampaignId) 
    {
        List<String> options = new List<String>();
        
        List<Campaign_Account_Members__c> regionsList= [SELECT Account__r.Region__c FROM Campaign_Account_Members__c WHERE Campaign__c = :CampaignId ORDER BY Account__r.Region__c];
        
        Set<String> uniqueRegions=new Set<String>();
        
        for(Campaign_Account_Members__c region: regionsList)
        {
            uniqueRegions.add(region.Account__r.Region__c); 
        } 
        
        List<String> allRegions= new List<String>();
        allRegions.addAll(uniqueRegions);
        allRegions.sort();
        
        for(String region: allRegions) 
        {
            options.add(region);
        }
        
        return options;
    }
    
    //20th Nov, 2014: Added by Anirudh.
    @RemoteAction
    global static List<String> GetAllKeyDOS(String CampaignId) 
    {
        List<String> options = new List<String>();
        
        List<Campaign_Account_Members__c> keyDOSList= [SELECT Account__r.Key_DOS__r.Name FROM Campaign_Account_Members__c WHERE Campaign__c = :CampaignId ORDER BY Account__r.Key_DOS__r.Name];
        
        Set<String> uniqueKeyDOS=new Set<String>();
        
        for(Campaign_Account_Members__c keyDOS: keyDOSList)
        {
            uniqueKeyDOS.add(keyDOS.Account__r.Key_DOS__r.Name); 
        } 
        
        List<String> allKeyDOS= new List<String>();
        allKeyDOS.addAll(uniqueKeyDOS);
        allKeyDOS.sort();
        
        for(String keyDOS: allKeyDOS) 
        {
            options.add(keyDOS);
        }
        
        return options;
    }
    
    
    //16th Dec, 2014 : Added by Vishal Bandari.
    //2017-03-13 - ragashalini.koka@cdk.com - commented the method for RQ-08732
    @RemoteAction
    global static List<String> GetAllTSM(String CampaignId) 
    {
        List<String> options = new List<String>();
        
       /* List<Campaign_Account_Members__c> TSMList= [SELECT Account__r.Technology_Solutions_Manager__r.Name FROM Campaign_Account_Members__c WHERE Campaign__c = :CampaignId ORDER BY Account__r.Technology_Solutions_Manager__r.Name];
        
        Set<String> uniqueTSM=new Set<String>();
        
        for(Campaign_Account_Members__c TSM: TSMList)
        {
            uniqueTSM.add(TSM.Account__r.Technology_Solutions_Manager__r.Name); 
        } 
        
        List<String> allTSM= new List<String>();
        allTSM.addAll(uniqueTSM);
        allTSM.sort();
        
        for(String TSM: allTSM) 
        {
            options.add(TSM);
        }*/
        
        return options;
    }
    
    
    //16th Dec, 2014 : Added by Vishal Bandari.
    @RemoteAction
    global static List<String> GetAllKeyREP(String CampaignId) 
    {
        List<String> options = new List<String>();
        
        List<Campaign_Account_Members__c> keyREPList= [SELECT Account__r.Key_REP__r.Name FROM Campaign_Account_Members__c WHERE Campaign__c = :CampaignId ORDER BY Account__r.Key_REP__r.Name];
        
        Set<String> uniqueKeyREP=new Set<String>();
        
        for(Campaign_Account_Members__c keyREP: keyREPList)
        {
            uniqueKeyREP.add(keyREP.Account__r.Key_REP__r.Name); 
        } 
        
        List<String> allKeyREP= new List<String>();
        allKeyREP.addAll(uniqueKeyREP);
        allKeyREP.sort();
        
        for(String keyREP: allKeyREP) 
        {
            options.add(keyREP);
        }
        
        return options;
    }
    
    //2016-11-09 ragashalini.koka@cdk.com - Gives the list of DSMs on the Campaign Account Members
    @RemoteAction
    global static List<String> GetDSM(String CampaignId)
    {
        List<String> options = new List<String>();
        List<Campaign_Account_Members__c> DSMList= [
            										   SELECT Account__r.Designated_DSM__r.Name 
                                                       FROM Campaign_Account_Members__c 
                                                       WHERE Campaign__c = :CampaignId ORDER BY Account__r.Designated_DSM__r.Name
        										   ];
        Set<String> uniqueDSM=new Set<String>();
        
        for(Campaign_Account_Members__c keyDOS: DSMList)
        {
            uniqueDSM.add(keyDOS.Account__r.Designated_DSM__r.Name); 
        } 
        
        options.addAll(uniqueDSM);
        options.sort();
       
        return options;
    }
    
    //2016-11-10 ragashalini.koka@cdk.com - Gives the list of DSM DOS on the Campaign Account Members
    @RemoteAction
    global static List<String> GetDSMDOS(String CampaignId)
    {
        List<String> options = new List<String>();
        List<Campaign_Account_Members__c> DSMDOSList= [
            										   SELECT Account__r.DSM_DOS__c
                                                       FROM Campaign_Account_Members__c 
                                                       WHERE Campaign__c = :CampaignId ORDER BY Account__r.DSM_DOS__c
        										   ];
        Set<String> uniqueDSMDOS=new Set<String>();
        
        for(Campaign_Account_Members__c keyDOS: DSMDOSList)
        {
            uniqueDSMDOS.add(keyDOS.Account__r.DSM_DOS__c); 
        } 
        
        options.addAll(uniqueDSMDOS);
        options.sort();
       
        return options;
    }
    
      @RemoteAction
    global static List<String> GetDAA(String CampaignId)
    {
        List<String> options = new List<String>();
        List<Campaign_Account_Members__c> DASList= [
            										   SELECT Account__r.Digital_Advertising_Specialist__r.Name
                                                       FROM Campaign_Account_Members__c 
                                                       WHERE Campaign__c = :CampaignId ORDER BY Account__r.Digital_Advertising_Specialist__r.Name
        										   ];
        Set<String> uniqueDAS=new Set<String>();
        
        for(Campaign_Account_Members__c keyDOS: DASList)
        {
            uniqueDAS.add(keyDOS.Account__r.Digital_Advertising_Specialist__r.Name); 
        } 
        
        options.addAll(uniqueDAS);
        options.sort();
       
        return options;
    }
    
    
    // 2016-10-14 - lalitha.adduru@cdk.com  - added one more parameter Competitor - RQ-07902
    @RemoteAction
    global static RemoteActionResponse UpdateAccountMemberStatus(List<String> IdsToUpdate, String Status, String competitor)
    {
        system.debug('competitor ----- > '+ competitor);
        RemoteActionResponse Response = new RemoteActionResponse();
        Response.Success = false;
        Response.Message = 'Failed to update Account Member Status for the Campaign Account Members provided.';
        
        if(IdsToUpdate == null?true:IdsToUpdate.IsEmpty()) 
        { 
            Response.Message = 'One or more Campaign Account Member Ids '
                + 'must be selected (or provided) to update the Campaign Member Status.'; 
            return Response; 
        }
        
        Set<Campaign_Account_Members__c> UniqueCampaignAccountMembers = new Set<Campaign_Account_Members__c>();
        
        // get Campaign Account Members
        List<Campaign_Account_Members__c> CampaignAccountMembers = [ 
            Select Id, Campaign__c, Campaign_Member_Status__c, Competitor__c
            From Campaign_Account_Members__c
            Where Id IN :IdsToUpdate];
        
        if(!CampaignAccountMembers.IsEmpty())
        {
            Boolean StatusInOptions = false;
            
            if(CampaignAccountMembers[0].Campaign__c == null) 
            {
                Response.Message = 'The Campaign related to one of the Campaign Account '
                    + 'Members selected is not valid. '; 
                return Response; 
            }
            
            if(Status == null || Status == '' || Status == DSCB_CampaignManagerController.EMPTY_LIST_ITEM) 
            { 
                StatusInOptions = true; 
            }
            else
            {
                List<String> StatusOptions = DSCB_CampaignManagerController.GetAllAccountMemberStatuses(CampaignAccountMembers[0].Campaign__c);
                
                for(String StatusOption : StatusOptions) 
                { 
                    if(Status.toLowerCase().trim() == StatusOption.toLowerCase().trim()) 
                    { 
                        StatusInOptions = true; 
                    }
                }
            }
            
            if(!StatusInOptions) 
            { 
                Response.Message = 'The Campaign Member Status provided is not a valid option for the selected Campaign. '; 
                return Response; 
            }
            
            for(Campaign_Account_Members__c cam : CampaignAccountMembers) 
            { 
                cam.Campaign_Member_Status__c = (Status == '' ? null : Status);
                if(Status == 'Not Interested - Competition')
                {
                    cam.Competitor__c = competitor;
                }
                
                UniqueCampaignAccountMembers.add(
                    new Campaign_Account_Members__c(Id=cam.Id, Campaign_Member_Status__c = (Status == '' ? null : Status), competitor__c = (competitor == '' ? null : competitor))); 
            }
            
            try
            {
                List<Campaign_Account_Members__c> CampaignAccountMembersToUpdate = new List<Campaign_Account_Members__c>();
                CampaignAccountMembersToUpdate.addAll(UniqueCampaignAccountMembers);
                update CampaignAccountMembersToUpdate;
                Response.Message = 'Success';
                Response.Success = true;
            }
            catch(Exception ex)
            {
                Response.Message = ex.getMessage();
                Response.Success = false;
            }
        }
        
        return Response;
    }
    
    //2016-05-03- anirudh.singh@cdk.com- Modified this method for request RQ-06970.
    @RemoteAction
    global static List<Contact_Relationship__c> FindContacts(List<String> CampaignAccountMemberIds, List<String> contactRelationshipRoles)
    {
        system.debug('Start FindContacts---->');
        
        //2016-05-20- anirudh.singh@cdk.com- Added the below method for request RQ-06970.
        List<Campaign_Account_Members__c> CampaignAccountMembers=fetchCampaignAccountMembersList(CampaignAccountMemberIds);
        
        //Check if the CampaignAccountMembers List is not empty.
        if(!CampaignAccountMembers.IsEmpty())
        {
            Set<Id> UniqueAccountIds=new Set<Id>();
            for(Campaign_Account_Members__c cam: CampaignAccountMembers) 
            { 
                UniqueAccountIds.add(cam.Account__c); 
            }
            
            //2016-05-20- anirudh.singh@cdk.com- Added the below method for request RQ-06970.
            List<Contact_Relationship__c> contactRelationshipsList=fetchContactRelationshipRecords(UniqueAccountIds, contactRelationshipRoles);
            
            //2016-05-03- anirudh.singh@cdk.com- Commented the below code.
            //String query = 'Select Id, Name, Email, Phone, Role__c, Do_Not_Solicit__c, Account.Name, AccountId '
            //    + 'From Contact Where Status__c = \'Active\' ';
            
            //2016-05-03- anirudh.singh@cdk.com- Commented the below IF Block for RQ-06970 Campaign Manager changes for Shared Contacts.
            //if(!UniqueAccountIds.IsEmpty())
            //{
            //    query += 'And AccountId IN (';
            //    for(String AccountId : UniqueAccountIds)
            //    {
            //        query += '\'' + AccountId + '\'' + ',';
            //    }    
            //    query = query.substring(0,query.lastIndexOf(','));
            //    query += ') ';
            //}
            
            //2016-05-18- anirudh.singh@cdk.com- Commented the below IF Block for RQ-06970 Campaign Manager changes for Shared Contacts.
            //if(!contactRelationshipRoles.IsEmpty())
            //{
            //    query += 'And (';
            //    for(String Role : contactRelationshipRoles)
            //    {
            //       query += 'Role__c includes(\''+Role+'\') OR ';
            //    }
            //    query = query.substring(0,query.lastIndexOf('OR '));
            //    query += ') ';
            //}
            
            //query += ' Order By Name Limit 500 ';
            
            //List<Contact> Contacts = database.query(query);
            system.debug('End FindContacts---->'+contactRelationshipsList);
            return contactRelationshipsList;
        }
        
        system.debug('End FindContacts---->');
        return null;
    }
    
    //2016-05-18- anirudh.singh@cdk.com- Created this new method for RQ-06970.
    //Removed the fields Name, Campaign__c, Account__r.Name, Campaign_Member_Status__c, 
    //Account__r.BillingCity, Account__r.BillingState, Account__r.Do_Not_Solicit__c from the earlier query as they are not used.
    private static List<Campaign_Account_Members__c> fetchCampaignAccountMembersList(List<String> CampaignAccountMemberIds)
    {
        system.debug('Start fetchCampaignAccountMembersList---->');
        List<Campaign_Account_Members__c> campaignAccountMembersList=new List<Campaign_Account_Members__c>();
        campaignAccountMembersList=[ 
            Select Id, Account__c 
            From Campaign_Account_Members__c
            Where Id IN :CampaignAccountMemberIds
            //And IsActive = true
        ];
        
        system.debug('End fetchCampaignAccountMembersList---->');
        return campaignAccountMembersList;
    }
    
    //2016-05-18- anirudh.singh@cdk.com- Created this new method for RQ-06970.
    private static List<Contact_Relationship__c> fetchContactRelationshipRecords(Set<Id> accountIds, List<String> contactRelationshipRoles)
    {
        system.debug('Start fetchContactRecords---->');
        String queryString='SELECT Id, Contact__c, Contact__r.Name, Account__c, Account__r.Name,'
            +' Contact__r.Email, Phone__c, Role__c, Contact__r.Do_Not_Solicit__c'
            +' FROM Contact_Relationship__c WHERE Status__c=\'Active\'';
        
        if(!accountIds.isEmpty())
        {
            queryString+=' AND Account__c IN (';
            queryString+='\''+String.join(new List<Id>(accountIds), '\',\'')+'\')';
        }
        
        if(!contactRelationshipRoles.isEmpty())
        {
            queryString+=' And Role__c INCLUDES (';
            queryString+='\''+String.join(contactRelationshipRoles, '\',\'')+'\')';
        }
        
        queryString+=' Order By Name LIMIT 500';
        system.debug('queryString---->'+queryString);
        
        system.debug('End fetchContactRecords---->');
        return database.query(queryString);
    }
    
    //2016-06-13 -venkata.shrivol@cdk.com -commented this method as this was referenced in ALL_NewContactDialog_Controller
   /* @RemoteAction
    global static RemoteActionResponse AddContact(String FirstName, String LastName, String CampaignAccountMemberId, String Role, String Email, String Phone)
    {
        RemoteActionResponse Response = new RemoteActionResponse();
        Response.Success = false;
        
        if(LastName == null || LastName == ''
           //|| FirstName == null || FirstName == '' 
           || CampaignAccountMemberId == null || CampaignAccountMemberId == ''
           || Role == null || Role == '')
        {
            Response.Message = 'Last Name, Account, and Role are required. ';
            return Response;
        }
        
        String AccountId = null;
        
        system.debug(CampaignAccountMemberId);
        
        if(!CampaignAccountMemberId.startsWith('001'))
        { 
            List<Campaign_Account_Members__c> CAMs = [
                Select Id, Name, Account__c 
                From Campaign_Account_Members__c 
                Where Id = :CampaignAccountMemberId
            ];
            
            system.debug(CAMs);
            if(!CAMs.IsEmpty()) 
            {
                AccountId = CAMs[0].Account__c; 
            } 
        }
        else
        {
            ID AccountIdValidation = null;
            
            try 
            { 
                AccountIdValidation = CampaignAccountMemberId; 
                AccountId = CampaignAccountMemberId; 
            } 
            catch(Exception ex) 
            {
                system.debug(ex);
            }
        }
        
        if(AccountId == null)
        {
            Response.Message = 'The Account selected does not have a valid ID. ';
            return Response;
        }
        
        // 2015-10-21 matt.keefe@cdk.com (RQ-05289) - added recordtype for contact
        Id ContactRecordTypeId = null;
        try
        {
            ContactRecordTypeId = 
                ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        }
        catch(Exception ex) 
        { 
            list<RecordType> ContactRecordTypes = [
                Select Id 
                From RecordType 
                Where sObjectType = 'Contact' 
                and DeveloperName like '%Customer%' 
                limit 1
            ];
            
            if(ContactRecordTypes != null && !ContactRecordTypes.isEmpty())
            {
                ContactRecordTypeId = ContactRecordTypes.get(0).Id;
            }
        }
        
        try
        {
            Contact c = new Contact();
            c.FirstName = FirstName;
            c.LastName = LastName;
            c.AccountId = AccountId;
            c.Role__c = Role;
            c.Email = Email;
            c.Phone = Phone;
            // 2015-10-21 matt.keefe@cdk.com (RQ-05289) - added recordtype for contact
            if(ContactRecordTypeId != null) { c.RecordTypeId = ContactRecordTypeId; }
            
            //2016-05-05- anirudh.singh@cdk.com- Commented the below line and invoking insertContactAndRelation of the ALL_SharedContact_Helper.
            insert c;
            //ALL_SharedContact_Helper.insertContactAndRelation(c);
            
            Response.Success = true;
            Response.Message = 'Success';
        }
        catch(Exception ex)
        {
            Response.Message = ex.getMessage(); 
        }
        
        return Response;
    }*/
    
    @RemoteAction
    global static RemoteActionResponse FindActivities(List<String> CampaignAccountMemberIds, String RequestType, Boolean MyActivities, Boolean ActivitiesSince)
    {
        system.debug(CampaignAccountMemberIds);
        system.debug(RequestType);
        
        RemoteActionResponse Response = new RemoteActionResponse();
        Response.Success = false;
        Response.Message = 'An unknown error occurred while finding activities for the selected Campaign Account Members.';
        
        if(CampaignAccountMemberIds.IsEmpty())
        {
            Response.Message = 'Please select at least one Campaign Account Member.';
            return Response;
        }
        
        Set<String> AccountIdSet = new Set<String>();
        Set<DateTime> CampaignDateSet = new Set<DateTime>();
        
        List<Campaign_Account_Members__c> CAMembers = [
            Select Id, Account__c, Campaign__c, Campaign__r.CreatedDate From Campaign_Account_Members__c Where Id IN :CampaignAccountMemberIds
        ];
        
        for(Campaign_Account_Members__c CAMember : CAMembers) 
        { 
            AccountIdSet.add(CAMember.Account__c); 
            CampaignDateSet.add(CAMember.Campaign__r.CreatedDate); 
        }
        
        List<String> AccountIds = new List<String>(); AccountIds.addAll(AccountIdSet);
        List<DateTime> CampaignDates = new List<DateTime>(); CampaignDates.addAll(CampaignDateSet); 
        Date MostRecentCampaignDate = null;
        
        if(!CampaignDates.IsEmpty()) 
        { 
            CampaignDates.sort(); 
            MostRecentCampaignDate = CampaignDates[CampaignDates.size()-1].date(); 
        } // -1 because starts at 0
        
        List<Account> AccountsWithActivities;
        String UserId = UserInfo.getUserId();
        
        List<sObject> AllHistories = new List<sObject>();
        
        DateTime now = DateTime.now();
        
        List<sObject> AccountEvents = Database.query(
            'SELECT Id, AccountId, Account.Name, Subject, ActivityDate, Type, '
            + 'Owner.Name, Owner.Id, What.Name, WhatId, WhoId, Who.Name, LastModifiedDate FROM Event WHERE AccountId IN :AccountIds '
            + (ActivitiesSince?' AND (CreatedDate > :MostRecentCampaignDate OR CreatedDate = null) ':'')
            + (MyActivities?' AND CreatedById = \''+UserId+'\' ':'')
            + ((RequestType == 'open')?' AND EndDateTime > :now ':' AND EndDateTime <= :now ')
            + ' LIMIT 500 ' 
        );
        
        List<sObject> AccountTasks = Database.query(
            'SELECT Id, AccountId, Account.Name, Priority, Status, Subject, ActivityDate, Type, '
            + 'Owner.Name, Owner.Id, What.Name, WhatId, WhoId, Who.Name, LastModifiedDate FROM Task WHERE AccountId IN :AccountIds '
            + (ActivitiesSince?' AND (CreatedDate > :MostRecentCampaignDate OR CreatedDate = null) ':'')
            + (MyActivities?' AND CreatedById = \''+UserId+'\' ':'')
            + ((RequestType == 'open')?' AND Status IN :TASK_OPEN_STATUSES ':' AND (NOT Status IN :TASK_OPEN_STATUSES) ')
            + ' LIMIT 500 ' 
        );
        
        AllHistories.addAll(AccountEvents);
        AllHistories.addAll(AccountTasks);
        
        Response.Success = true;
        Response.Objects = AllHistories;
        Response.Message = AllHistories.size() + ' Activity(ies) found for the selected Accounts.';
        
        return Response;
    }
    
    @RemoteAction   
    global static RemoteActionResponse SendEmails(String EmailTemplateId, List<String> ToEmailIds) 
    {
        RemoteActionResponse Response = new RemoteActionResponse();
        Response.Success = false;
        
        List<Id> toCampaigns = new List<Id>();
        
        if (EmailTemplateId != null) 
        {
            List<EmailTemplate> Templates = [
                Select Id, Name, IsActive, Folder.Name 
                From EmailTemplate 
                Where IsActive = true // is active is labeled Available for Use 
                And Id = :EmailTemplateId
                ORDER BY Folder.Name, Name
            ];
            
            if (ToEmailIds.size() > 1) 
            {
                try
                {
                    Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
                    mail.setTemplateId(EmailTemplateId);
                    mail.setTargetObjectIds(ToEmailIds);
                    
                    Messaging.sendEmail(new Messaging.Email[]{mail}, false);
                    
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info, 'E-mail sent to campaign members.');
                    ApexPages.addMessage(myMsg);
                    
                    Response.Success = true;
                }
                catch(Exception ex)
                {
                    Response.Message = ex.getMessage();
                } 
            }
        }
        else
        {
            Response.Message = 'Invalid E-mail Template selected.';
        }
        
        return Response;
    }
    
    // -- Visualforce Variables and Methods
    
    public String CampaignAccountMemberId;
    public String getCampaignAccountMemberId() { return CampaignAccountMemberId; }
    public void setCampaignAccountMemberId(String value) { CampaignAccountMemberId = value; }
    
    public Boolean getProfileIsInsideSales()
    {
        //return Schema.sObjectType.Campaign_Account_Members__c.fields.Campaign_Member_Status__c.isUpdateable();       
        return isInsideSales();
    }
    
    //2016-05-20- anirudh.singh@cdk.com- Changed the method name from ContactRoles to ContactRelationshipRoles.
    @RemoteAction 
    global static List<String> getContactRelationshipRoles()
    {
        List<String> options = new List<String>(); 
        Schema.DescribeFieldResult fieldResult=Contact_Relationship__c.Role__c.getDescribe();
        
        for(Schema.PicklistEntry entry : fieldResult.getPicklistValues()) 
        {
            options.add(entry.getValue()); 
        }
        
        return options;
    }
    
    @RemoteAction
    global static List<EmailTemplate> getEmailTemplates()
    {
        System.debug(UserInfo.getUserName());
        
        // select the Folders first, because only the Templates 
        //   the current User has access to should be displayed
        Set<ID> FolderIds = new Set<ID>();
        List<Folder> Folders = [Select Id, Name From Folder Where Type = 'Email'];
        
        for(Folder F : Folders) 
        {
            FolderIds.add(F.Id); 
        } 
        
        // get the Templates that are in the Folders queried
        List<EmailTemplate> Templates = [
            Select Id, Name, IsActive, Folder.Name 
            From EmailTemplate 
            Where IsActive = true // is active is labeled Available for Use 
            And Folder.Id IN :FolderIds
            ORDER BY Folder.Name, Name
        ]; 
        
        if(Templates == null) 
        {
            Templates = new List<EmailTemplate>(); 
        }
        
        return Templates;
    }
}