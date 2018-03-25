@IsTest
public class CB_AccountDealerGroupProfile_Test
{
	public static Site_Type__c SiteType;
	public static Account ParentAccount;
	public static Account ChildAccount;
	
	public static void init()
	{
		SiteType = new Site_Type__c(Name='Test Site Type',Corporation_Flag__c=true);
        insert SiteType;
        
        ParentAccount = DS_TestObjects.newAccount(); 
        ParentAccount.Site_Type__c = SiteType.Id;
        insert ParentAccount;
        
        ChildAccount = DS_TestObjects.newAccount(); 
        ChildAccount.ParentId = ParentAccount.Id;
        ChildAccount.Corporation__c = ParentAccount.Id;
        insert ChildAccount;
	}
	
    public static testmethod void TestController()
    {
		init();
        ALL_Profile_Access_Settings__c profileSettings = new ALL_Profile_Access_Settings__c();
        profileSettings.Dealer_Group_Profile__c = true;
        
        upsert profileSettings;
        
        PageReference pg = Page.CB_DealerGroupProfile;
        Test.setCurrentPage(pg);
        Test.startTest();
        
        CB_AccountDealerGroupProfile DealerGroupProfileController = new CB_AccountDealerGroupProfile();
        
        // test with no parameters
        DealerGroupProfileController.Init();
        
        // test with an Invalid Type
        ApexPages.currentPage().getParameters().put('oid',childaccount.Id);
        ApexPages.currentPage().getParameters().put('otype','InvalidType');
        Test.setCurrentPage(pg);
        
        DealerGroupProfileController.Init();
        
        // test with a Valid Type, but an Invalid Profile
        ApexPages.currentPage().getParameters().put('oid',childaccount.Id);
        ApexPages.currentPage().getParameters().put('otype','Account');
        Test.setCurrentPage(pg);
        
        DealerGroupProfileController.Init();
        
        // test with an Valid Profile
        Dealer_Group_Profile_Settings__c ObjectTypes = new Dealer_Group_Profile_Settings__c(Name='Account',Account_Field__c='Id',sObjectType__c='Account');
        insert ObjectTypes;
        
        ApexPages.currentPage().getParameters().put('oid',childaccount.Id);
        ApexPages.currentPage().getParameters().put('otype','Account');
        Test.setCurrentPage(pg);
        
        DealerGroupProfileController.Init();
        
        // test Create Dealer Group Profile method with an invalid TopAccount
        Account Temp = DealerGroupProfileController.TopAccount;
        DealerGroupProfileController.TopAccount = null;
        DealerGroupProfileController.CreateDealerGroupProfile();
        
        // test Create Dealer Group Profile method with an Valid TopAccount
        DealerGroupProfileController.TopAccount = Temp;
        DealerGroupProfileController.CreateDealerGroupProfile();
        
        // test with a Dealer Group Profile created
        Dealer_Group_Profile__c DealerGroupProfile = new Dealer_Group_Profile__c(Dealer_Group__c=ParentAccount.Id);
        insert DealerGroupProfile;
        
        DealerGroupProfileController.Init();
        
        Test.stopTest();
    }
    
    public static testmethod void TestTrigger()
    {
    	init();
    	
    	Dealer_Group_Profile__c DealerGroupProfile0 = new Dealer_Group_Profile__c(Dealer_Group__c=ParentAccount.Id);
    	insert DealerGroupProfile0; delete DealerGroupProfile0;
    	
    	List<Dealer_Group_Profile__c> DealerGroupProfileList = new List<Dealer_Group_Profile__c>();
    	Dealer_Group_Profile__c DealerGroupProfile1 = new Dealer_Group_Profile__c(Dealer_Group__c=ParentAccount.Id);
    	Dealer_Group_Profile__c DealerGroupProfile2 = new Dealer_Group_Profile__c(Dealer_Group__c=ParentAccount.Id);
    	DealerGroupProfileList.add(DealerGroupProfile1); DealerGroupProfileList.add(DealerGroupProfile2);
    	try { insert DealerGroupProfileList; } catch (Exception e) { }
    }
}