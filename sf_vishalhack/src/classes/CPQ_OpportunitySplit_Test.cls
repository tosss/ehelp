//2016-09-30 - vishal.bandari@cdk.com - RQ-07843:created the class
@IsTest
public class CPQ_OpportunitySplit_Test 
{
    @testsetup
    public static void setupData()
    {
        Account accObj1 = DS_TestObjects.NewAccount_Inserted();
        Opportunity oppObj1 = DS_TestObjects.NewOpportunity();
        oppObj1.AccountId = accObj1.Id;
        insert oppObj1;
        
        User usrObj = DS_TestObjects.NewUser();
        usrObj.Title = 'DSM User';
        insert usrObj;
        
        Account accObj2 = DS_TestObjects.NewAccount();
        accObj2.Designated_DSM__c = usrObj.Id;
        insert accObj2;
        
        Opportunity oppObj2 = DS_TestObjects.NewOpportunity();
        oppObj2.AccountId = accObj2.Id;
        oppObj2.ADP_Opportunity_Owner__c = usrObj.Id;
        insert oppObj2;
    }
    
    public static testmethod void test1()
    {
        try
        {
            delete [Select Id from Opportunity_Split__c];
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('Cannot delete the record as it is the only Opportunity Split record under Opportunity Location'));
        }
    }
    
    public static testmethod void test2()
    {
        test.startTest();
        Account acc = DS_TestObjects.NewAccount_Inserted();
        Opportunity opp = DS_TestObjects.NewOpportunity();
        opp.AccountId = acc.Id;
        insert opp;
        
        Opportunity_Split__c splitObj = new Opportunity_Split__c();
        splitObj.Site__c = acc.Id;
        splitObj.Opportunity_Location__c = [Select Id from Opportunity_Location__c Where Site__c =: acc.Id AND Opportunity__c =:opp.Id Limit 1 ].Id;
        splitObj.Opportunity__c = opp.Id;
        splitObj.Sales_Rep__c = DS_TestObjects.NewUser_Inserted().Id;
        splitObj.Channel__c = 'Baseline';
        splitObj.NewQ__c = 100;
        try
        {
            insert splitObj;
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('NewQ Percent for Opportunity and Site is exceeding 100% for the Baseline channel !!!'));
        }
        
        test.stopTest();
    }
    
    
    public static testmethod void test3()
    {
        test.startTest();
        Account accObj = DS_TestObjects.NewAccount_Inserted();
        Opportunity oppObj = DS_TestObjects.NewOpportunity();
        oppObj.AccountId = accObj.Id;
        insert oppObj;
        List<Opportunity_Location__c> oppLocList = [Select Id from Opportunity_Location__c WHERE Site__c =: accObj.Id];
        delete oppLocList;
        
        try
        {
            Opportunity_Split__c oppSplit = new Opportunity_Split__c();
            oppSplit.Site__c = accObj.Id;
            insert oppSplit;
        }
        catch(Exception e)
        {
            System.assert(e.getMessage().contains('You cannot create an Opportunity Split record if there does not exist an Opportunity Location (Site) record for that Site.'));
        }
        
        test.stopTest();
    }
    
    public static testmethod void test4()
    {
        test.startTest();
        
        User testUser = DS_TestObjects.NewUser();
        testUser.ProfileId = [Select id from Profile Where Name Like '%Inside Sales%' Limit 1].Id;
        testUser.Title = 'DSM test';
        insert testUser;
        
        Account accObj = DS_TestObjects.NewAccount();
        accObj.Designated_DSM__c = testUser.Id;
        insert accObj;
        
        AccountShare share = new AccountShare();
        share.AccountId = accObj.Id;
        share.UserOrGroupId = testUser.Id;
        share.AccountAccessLevel = 'Edit';
        share.OpportunityAccessLevel = 'Edit';
        share.CaseAccessLevel = 'Edit';
        insert share;
        
        System.runAs(testUser)
        {
            Opportunity oppObj = DS_TestObjects.NewOpportunity();
            oppObj.AccountId = accObj.Id;
            oppObj.ADP_Opportunity_Owner__c = testUser.Id;
            insert oppObj;
            
            Account accObj2 = DS_TestObjects.NewAccount_Inserted();
            Opportunity_Location__c oppLoc = new Opportunity_Location__c();
            oppLoc.RecordtypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Site');
            oppLoc.Site__c = accObj2.Id;
            oppLoc.Opportunity__c = oppObj.Id;
            insert oppLoc;
            
            List<Opportunity_Split__c> oppSplit = [Select NewQ__c, Channel__c, Sales_Rep__r.Name from Opportunity_Split__c Order By CreatedDate desc];
            
            System.assert(oppSplit[0].Channel__c == 'Digital Solutions' && oppSplit[0].NewQ__c == 100 && oppSplit[0].Sales_Rep__c == testUser.Id);
            
            
        }
        test.stopTest();
    }
    
    public static testmethod void test5()
    {
        test.startTest();
        
        User testUser = DS_TestObjects.NewUser();
        testUser.ProfileId = [Select id from Profile Where Name Like '%Inside Sales%' Limit 1].Id;
        insert testUser;
        
        Account accObj = DS_TestObjects.NewAccount();
        accObj.Digital_Advertising_Specialist__c = testUser.Id;
        insert accObj;
        
        AccountShare share = new AccountShare();
        share.AccountId = accObj.Id;
        share.UserOrGroupId = testUser.Id;
        share.AccountAccessLevel = 'Edit';
        share.OpportunityAccessLevel = 'Edit';
        share.CaseAccessLevel = 'Edit';
        insert share;
        
        System.runAs(testUser)
        {
            
            Opportunity oppObj = DS_TestObjects.NewOpportunity();
            oppObj.AccountId = accObj.Id;
            oppObj.ADP_Opportunity_Owner__c = testUser.Id;
            insert oppObj;
            
            Account accObj2 = DS_TestObjects.NewAccount_Inserted();
            Opportunity_Location__c oppLoc = new Opportunity_Location__c();
            oppLoc.RecordtypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Site');
            oppLoc.Site__c = accObj2.Id;
            oppLoc.Opportunity__c = oppObj.Id;
            insert oppLoc;
            
            List<Opportunity_Split__c> oppSplit = [Select Id, NewQ__c, Channel__c,Sales_Rep__c from Opportunity_Split__c Order by CreatedDate desc];
            System.assert(oppSplit[0].Channel__c == 'Baseline' && oppSplit[0].NewQ__c == 100 && oppSplit[0].Sales_Rep__c == testUser.Id);
        }
        test.stopTest();
    }
    
    
    public static testmethod void test6()
    {
        test.startTest();
        
        User testUser = DS_TestObjects.NewUser();
        testUser.ProfileId = [Select id from Profile Where Name Like '%Inside Sales%' Limit 1].Id;
        testUser.Forecasting_Channel__c = 'Sample';
        insert testUser;
        
        Account accObj = DS_TestObjects.NewAccount();
        insert accObj;
        
        AccountShare share = new AccountShare();
        share.AccountId = accObj.Id;
        share.UserOrGroupId = testUser.Id;
        share.AccountAccessLevel = 'Edit';
        share.OpportunityAccessLevel = 'Edit';
        share.CaseAccessLevel = 'Edit';
        insert share;
        
        System.runAs(testUser)
        {
            Opportunity oppObj = DS_TestObjects.NewOpportunity();
            oppObj.AccountId = accObj.Id;
            oppObj.ADP_Opportunity_Owner__c = testUser.Id;
            insert oppObj;
            
            Account accObj2 = DS_TestObjects.NewAccount_Inserted();
            Opportunity_Location__c oppLoc = new Opportunity_Location__c();
            oppLoc.RecordtypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Site');
            oppLoc.Site__c = accObj2.Id;
            oppLoc.Opportunity__c = oppObj.Id;
            insert oppLoc;
            List<Opportunity_Split__c> oppSplit = [Select Id, NewQ__c, Channel__c,Sales_Rep__c from Opportunity_Split__c Order By CreatedDate desc];
            
            System.assert(oppSplit[0].Channel__c == 'Baseline' && oppSplit[0].NewQ__c == 100 && oppSplit[0].Sales_Rep__c == testUser.Id);
        }
        test.stopTest();
    }
    
    public static testmethod void test7()
    {
        test.startTest();
        User testUser = DS_TestObjects.NewUser();
        Id InsideSalesProfileId = [Select id from Profile Where Name Like '%Inside Sales%' Limit 1].Id;
        testUser.ProfileId = InsideSalesProfileId;
        testUser.Title = 'ARM';
        insert testUser;
        
        User testUser2 = DS_TestObjects.NewUser();
        testUser2.ProfileId = InsideSalesProfileId;
        testUser2.Title = 'ASE';
        insert testUser2;
        
        UserShare userShare = new UserShare();
        userShare.RowCause = 'Manual';
        userShare.UserAccessLevel = 'Edit';
        userShare.UserId = testUser.Id;
        userShare.UserOrGroupId = testUser2.Id;
        insert userShare;
        
        Account accObj = DS_TestObjects.NewAccount();
        accObj.Key_Rep__c = testUser2.Id;
        insert accObj;
        
        Account_Team__c accountTeam = new Account_Team__c();
        accountTeam.Account__c = accObj.Id;
        accountTeam.Team_Member__c = testUser.Id;
        accountTeam.Team_Role__c = 'Digital Advisor';
        accountTeam.Opportunity_Access__c = 'Edit';
        accountTeam.Case_Access__c = 'Edit';
        insert accountTeam;
        
        Account accObj2 = DS_TestObjects.NewAccount();
        accObj2.Key_Rep__c = testUser2.Id;
        insert accObj2;
        
        accountTeam = new Account_Team__c();
        accountTeam.Account__c = accObj2.Id;
        accountTeam.Team_Member__c = testUser.Id;
        accountTeam.Team_Role__c = 'Digital Advisor';
        accountTeam.Opportunity_Access__c = 'Edit';
        accountTeam.Case_Access__c = 'Edit';
        insert accountTeam;
        
        System.runAs(testUser)
        {
            Opportunity oppObj = DS_TestObjects.NewOpportunity();
            oppObj.AccountId = accObj.Id;
            oppObj.ADP_Opportunity_Owner__c = testUser2.Id;
            insert oppObj;
            
            List<Opportunity_Split__c> oppSplit = [Select Id, NewQ__c, Channel__c,Sales_Rep__c from Opportunity_Split__c Order By CreatedDate desc];
            //System.debug(oppSplit[0].Channel__c+' '+oppSplit[0].NewQ__c+' '+oppSplit[0].Sales_Rep__c);
            System.assert(oppSplit[0].Channel__c == 'Baseline' && oppSplit[0].NewQ__c == 100 && oppSplit[0].Sales_Rep__c == testUser2.Id);
        }
        test.stopTest();
    }
}