//2017-01-30 - lalitha.adduru@cdk.com - creaed this test class to test the logic of ALL_Lead_Handler - RQ-06389
@isTest
public class ALL_Lead_Test 
{
    @TestSetup
    public static void testSetup()
    {
        GlobalSettings__c gs=new GlobalSettings__c(
            Lead_Owner_Mgrs_Mgr_Roles_to_Exclude__c='Fake Role' // in other words, do not exclude
        ); 
        insert gs;
        
        Trigger_Toggle_Profile__c ttp = new Trigger_Toggle_Profile__c(
            Name = 'Lead Trigger Profile for Current User', 
            On__c = true,
            Code_Reference__c = 'Lead',
            sobject__C = 'Lead',
            Profile_Id__c = UserInfo.getProfileId()
        );
        insert ttp;
        
        Trigger_Toggle__c tt =new Trigger_Toggle__c(
            Name = 'Lead Trigger Profile for Current User', 
            On__c = true,
            Code_Reference__c = 'Lead',
            sobject__C = 'Lead'
        );
        insert tt;
        
        User NewLeadOwner=DS_TestObjects.NewUser();
        NewLeadOwner.UserRoleId=[Select Id, RollupDescription From UserRole Where RollupDescription='Data Librarian'].Id;
        system.runas(DS_TestObjects.CurrentUser()) 
        { 
            insert NewLeadOwner; 
        } 
        
        Account TestAccount=DS_TestObjects.NewAccount();
        TestAccount.Key_Rep__c = UserInfo.getuserId();
        insert TestAccount;
        
        Account_Team__c accountTeam = new Account_Team__C();
        accountTeam.Account__c = testAccount.Id;
        accountTeam.Team_Member__c = NewLeadOwner.Id;
        accountTeam.Team_Role__c = 'Forecasting - Inside Sales - ASR';
        insert accountTeam;
        
        
        Contact TestContact=DS_TestObjects.NewContact();
        TestContact.AccountId=TestAccount.Id; 
        //TestContact.Phone='(847) 555-0001'; // test phone number updating
        TestContact.MobilePhone='(847) 555-0002'; // test phone number updating
        //TestContact.Role__c=; // 9/29
        
         //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        TestContact.RecordType = [select id from recordtype where name = 'Customer Contact' and sObjectType='Contact'][0];
        //2016-06-16- vishal.bandari@cdk.com - added logic to invoke ALL_SharedContact_Helper.insertContact to update Contact
        ALL_SharedContact_Helper.insertContact(TestContact,'Test Role',null,null);
        
        Campaign camp = DS_TestObjects.NewCampaign_Inserted();
        
        // for Opportunity
        Opportunity opp = new Opportunity();
        opp.Name = 'Oppor2';
        opp.AccountId = TestAccount.Id;
        opp.ADP_Opportunity_Owner__c = newLeadOwner.id;
        opp.CloseDate = Date.Today();
        opp.StageName = 'Plan';
        insert opp;
        
        // for IsProduct
        IS_Product__c IsProduct = new IS_Product__c();
        IsProduct.IsActive__c = true;
        insert IsProduct;
        
        List<Lead> leadList = new List<Lead>();
        // for Lead
        Lead l = new Lead();
        l.LastName = 'testname';
        l.Current_Account__c = TestAccount.id;
        l.Contact__c = TestContact.Id;
        l.Company = 'ADP';
        l.Product_Interest__c = 'Dealix';
        l.Is_Product__c = IsProduct.id;
        l.Status = 'Rep Attempted Contact';
        l.LeadSource = 'Email';
        leadList.add(l);
        
        Lead TestLead=DS_TestObjects.NewLead();
        TestLead.Current_Account__c=TestContact.AccountId;
        TestLead.Contact__c=TestContact.Id;
        TestLead.LeadSource='Trade Show - NADA';
        TestLead.ADP_Campaign__c = camp.Id;
        leadList.add(TestLead);
        
        Lead TestLeadTwo=DS_TestObjects.NewLead();
        Account TestAccountTwo = DS_TestObjects.NewAccount_Inserted();
        
        Account_Team__c accountTeamTwo = new Account_Team__C();
        accountTeamTwo.Account__c = TestAccountTwo.Id;
        accountTeamTwo.Team_Member__c = NewLeadOwner.Id;
        accountTeamTwo.Team_Role__c = 'Forecasting - Inside Sales - ASR';
        insert accountTeamTwo;
        
        Contact TestContactTwo = DS_TestObjects.NewContact();
        TestContactTwo.AccountId = TestAccountTwo.Id;
        TestLeadTwo.Current_Account__c=TestContactTwo.AccountId ;
        TestLeadTwo.LeadSource='Trade Show - NADA';
        TestLeadTwo.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Lead', 'Marketing Lead');
        leadList.add(TestLeadTwo);
        
        insert leadList;
    }
    
    public static testmethod void testFetchPardotNonPardotLeadsMap()
    {
        Test.startTest();
        Map<Id,Lead> leadMap = new Map<Id,Lead>([
            SELECT id, Current_Account__c, Contact__c, LeadSource, RecordTypeId, Status, ConvertedContactId, OwnerId
            FROM Lead
        ]);
        
        List<Opportunity> opportunityList = [
            SELECT Id 
            FROM Opportunity
        ];
        
        List<User> userList = [
            SELECT Id
            FROM User
        ];
        
        ALL_Lead_Handler handlerRef = new ALL_Lead_Handler();
        handlerRef.fetchPardotNonPardotLeadsMap(leadMap.values());
        handlerRef.insertRequiredContactRelationships(leadMap.values());
        handlerRef.ContactPhoneSync(null, leadMap.values());
        handlerRef.createLeadShare(leadMap.values());
        Map<id,Lead> oldMap = new Map<Id,Lead>();
        for(Lead lead : leadMap.values())
        {
            oldMap.put(lead.Id, lead.clone(false,true));
        }

        for(Lead lead : leadMap.values())
        {
            lead.OwnerId = userList[0].Id;
            lead.Opportunity__c = opportunityList[0].Id;
        }
        handlerRef.checkCancelWorkflows(leadMap.values());
        handlerRef.UpdateOwnerDetails(OldMap, leadMap.values());
        handlerRef.updateVendorInstallDate(leadMap.values());
        handlerRef.UpdateOpportunity(leadMap, OldMap);
        Test.stopTest();
        
    }

}