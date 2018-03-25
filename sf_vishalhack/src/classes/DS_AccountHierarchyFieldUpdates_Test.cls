//2017-03-15  ragashalini.koka@cdk.com - commented District__c references for RQ-08732
@isTest
public class DS_AccountHierarchyFieldUpdates_Test 
{
    static testmethod void TestForAccountHierarchyProcessList()
    {        
        // insert Account hierarchy profileIds
        List<Account_Hierarchy_Rolldown__c> AHP = new List<Account_Hierarchy_Rolldown__c>();
        AHP.add(new Account_Hierarchy_Rolldown__c(
            Name = '1', Field_Name__c = 'Digital_Services_CAM__c', Profile_Id__c = userInfo.getProfileId(), 
            Update_WebID_Field__c  = 'Client_Account_Manager__c'));
        AHP.add(new Account_Hierarchy_Rolldown__c(
            Name = '2', Field_Name__c = 'Website', Profile_Id__c = userInfo.getProfileId()));
        insert AHP;
        
        site_type__c st = new site_type__c();
        st.Group_Flag__c = true;
        st.Name = 'group';
        insert st; 
        
        Account newAccount = DS_TestObjects.NewAccount();
        newAccount.Site_Type__c = st.Id;
        newAccount.Status__c = 'active';       
        newAccount.Account_Number__c = '123456';
        insert newAccount;
        
        Account newChildAccount = DS_TestObjects.NewAccount();
        newChildAccount.ParentId = newAccount.Id;
        newChildAccount.group__c = newAccount.Id;
        newChildAccount.Status__c = 'active';
        newChildAccount.Account_Number__c = '1234567';
        insert newChildAccount;
        
        WebId__c newWebId = new WebId__c();
        newWebId.Account__c = newChildAccount.Id;
        insert newWebId;
        
        newAccount.Website = 'www.adp.com';
        update newAccount;
        
        newAccount.website = 'www.google.com';
        update newAccount;
        
        newAccount.Digital_Services_CAM__c = userInfo.getUserId();
        update newAccount; 
        
        newChildAccount.ParentId = null;
        newChildAccount.group__c = null;
        update newChildAccount;
    } 
    static testMethod void unitTest()
    {
        Site_Type__c st1 = DS_TestObjects.NewSiteType();
        st1.Name = 'Corporation';
        st1.Active__c = true;
        st1.Corporation_Flag__c = true;
        st1.District_Flag__c = true;
        st1.Group_Flag__c = true;
        
        Site_Type__c st2 = DS_TestObjects.NewSiteType();
        st2.Name = 'Group';
        st2.Active__c = true;
        //st2.Corporation_Flag__c = true;
        //st2.District_Flag__c = true;
        st2.Group_Flag__c = true;
        
        Site_Type__c st3 = DS_TestObjects.NewSiteType();
        st3.Name = 'District';
        st3.Active__c = true;
        //st3.Corporation_Flag__c = true;
        st3.District_Flag__c = true;
        //st3.Group_Flag__c = true;
        
        insert new list<Site_Type__c>{ st1, st2, st3 };
        
        Account CorpAccount = DS_TestObjects.NewAccount();
        CorpAccount.Site_Type__c = st1.Id;
        CorpAccount.BillingCountry = 'USA';        
        insert CorpAccount;
        
        Account CorpAccount2 = DS_TestObjects.NewAccount();
        CorpAccount2.Site_Type__c = st1.Id;
        CorpAccount2.BillingCountry = 'USA';        
        insert CorpAccount2;
        
        Account Group2 = DS_TestObjects.NewAccount();
        Group2.Site_Type__c = st2.Id; 
        Group2.BillingCountry = 'USA';
        insert Group2;       
        
        
        Account District = DS_TestObjects.NewAccount();
        District.Site_Type__c = st3.Id;
        District.BillingCountry = 'USA';
        insert District;
        
        Account District2 = DS_TestObjects.NewAccount();
        District2.Site_Type__c = st3.Id;
        District2.BillingCountry = 'USA';
        update District;
        
        Account GroupAccount = DS_TestObjects.NewAccount();
        GroupAccount.ParentId = CorpAccount.Id;
        GroupAccount.Site_Type__c = st2.Id; 
        GroupAccount.BillingCountry = 'USA';
        Insert GroupAccount;
        
        Account ChildAccount = DS_TestObjects.NewAccount();
        ChildAccount.ParentId = GroupAccount.Id;
        ChildAccount.Site_Type__c = st1.Id;
        ChildAccount.Corporation__c = CorpAccount.Id;
        ChildAccount.Group__c =  GroupAccount.Id;
      //  ChildAccount.District__c = District.Id;
        ChildAccount.BillingCountry = 'USA';        
        Insert ChildAccount;
        
        ChildAccount.Account_Number__c = '247828';
        update ChildAccount;

        
        Account ChildOfChild = DS_TestObjects.NewAccount();
        ChildOfChild.ParentId = ChildAccount.Id;
        ChildOfChild.BillingCountry = 'USA';
        Insert ChildOfChild;        
        
        ChildAccount.ParentId = CorpAccount2.Id;
        ChildAccount.Corporation__c = CorpAccount2.Id;
        ChildAccount.Group__c =  Group2.Id;
       // ChildAccount.District__c = District.Id;
        ChildAccount.BillingCountry = 'USA';        
        Update ChildAccount;
        
    }
}