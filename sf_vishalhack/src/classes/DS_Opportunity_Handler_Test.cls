@IsTest
public class DS_Opportunity_Handler_Test 
{
    @testsetup static void setupTestData() {
       
       
        list<User> users = new list<User>();
        
        users.add(DS_TestObjects.NewUser());
        users.add(DS_TestObjects.NewUser());
        users[0].ProfileId = [SELECT Id from Profile Where Name Like '%Baseline%' LIMIT 1].Id;
        users[1].ProfileId = users[0].ProfileId;
        insert users;
        
         CustomSettings__c cs = new CustomSettings__c();
        cs.DS_SalesTeamTrigger_On__c = true;
        cs.Users_To_Exclude_CPQ_Approval__c = users[0].FirstName + ' ' + users[0].LastName ;
        insert cs; 
        
        Site_Type__c site = new Site_Type__c();
        site.Name = 'Group';
        site.Group_Flag__c = true;
        site.Active__c = true;
        insert site;
        
        //2017-04-21 ragashalini.koka@cdk.com - Added PartyID__c field for Account
        Account acct = new Account(Name='Test Acct 1');
        acct.Site_Type__c = site.Id;
        acct.PartyID__c = String.valueOf(Math.round(Math.random()*1000));
        insert acct;
       
        System.debug('test' + [select id,Dealer_Group_Name2__c from account where id=:acct.Id]);
        
        
        
        Account_Team__c atc1 = new Account_Team__c(
            Account__c = acct.Id, 
            Team_Member__c = users[0].Id, 
            Team_Role__c = 'Forecasting - Alliance Unhook', 
            Account_Access__c = 'Read Only', 
            Opportunity_Access__c = 'Read Only', 
            Case_Access__c = 'Read Only'
        ); insert atc1;
        
        Account_Team__c atc2 = new Account_Team__c(
            Account__c = acct.Id, 
            Team_Member__c = users[1].Id, 
            Team_Role__c = 'Forecasting - Alliance Upgrade', 
            Account_Access__c = 'Read Only', 
            Opportunity_Access__c = 'Read Only', 
            Case_Access__c = 'Read Only'
        ); insert atc2;
        
        Systems__c sys = DS_TestObjects.NewCRMSystem();
        insert sys;
        
        System_at_Dealership__c sat = new System_at_Dealership__c(
            Account__c = acct.Id, 
            Vendor__c = sys.Id, 
            System_Type__c = 'DMS'
        ); insert sat;
        
        String today = String.valueOf(DateTime.now().format('dd/MM/YYYY'));
        today = today.replaceAll('/','-');
        
        CMF_Info__c cmfRecord = DS_TestObjects.NewCMFInfo();
        cmfRecord.Account__c = acct.Id;
        cmfRecord.SLS_Baseline_CMF_Number__c = '1234';
        cmfRecord.Ship_CMF__c = '1234';
        cmfRecord.Status__c = 'A';
        cmfRecord.CMF_Replaced__c = 'Test';
        cmfRecord.SLS_Ownership_Change_Type__c = 'Test';
        insert cmfRecord;
        
        Map<Id,CMF_Info__c> CMFInfoMap = new Map<Id,CMF_Info__c>([
            SELECT Id, SLS_Baseline_CMF_Number__c, Ship_CMF__c, Account__c, CMF_Replaced__c 
            FROM CMF_Info__c 
            WHERE Status__c = 'A' AND CMF_Replaced__c != null AND 
            ((NOT SLS_Ownership_Change_Type__c LIKE '%Shared System%') OR SLS_Ownership_Change_Type__c = null)
            AND Account__c = :acct.Id
        ]);
	
        System.debug('CMF Info Map Test :' + CMFInfoMap);
        
    }
    public static testmethod void testUpdateOpp()
    {
      
        Account acct = [SELECT Id FROM Account LIMIT 1];
        User usr = [SELECT Id FROM User ORDER By CreatedDate desc LIMIT 1];
        System_at_Dealership__c sat = [SELECT Id FROM System_at_Dealership__c LIMIT 1];
        test.startTest();
         Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity 1', 
            AccountId = acct.Id, 
            DMS_Platform__c = 'Web 2k', 
            Type = 'Unhook', 
            CloseDate = Date.today(), 
            StageName = 'Plan', 
            ADP_Opportunity_Owner__c = usr.Id,
            CPQ_Data_Consent_Changes__c = acct.Id+'$,$1/06/2015$,$10/6/2016$,$Yes$,$FRONT OFFICE EDGE DATA CONSENT###'+
            acct.Id+'$,$1/06/2015$,$10/6/2016$,$Modified$,$MENU DATA CONSENT###',
            SLS_Buyer_Account__c = acct.Id
        ); insert testOpp;
        List<Opportunity_Location__c> oppLocationList = [select  Id, Site__r.Dealer_Group_Name2__c, Opportunity__r.SLS_Buyer_Account__r.Dealer_Group_Name2__c, Opportunity__r.AccountId 
                                                         from opportunity_location__c where opportunity__c=:testOpp.Id and RecordType.Name='Site'];
        //System.debug('opportunity locations :' + oppLocationList[0].Site__r.Dealer_Group_Name2__c + '----' + oppLocationList[0].Opportunity__r.SLS_Buyer_Account__r.Dealer_Group_Name2__c );
        testOpp.DMS_Platform__c = 'Web 1k';
        update testOpp;
        
        testOpp.DMS_Platform__c = 'Web 2k';
        update testOpp;
        
        delete sat;
        
        testOpp.DMS_Platform__c = 'Web 1k';
        update testOpp;
        test.stopTest();
        
    }
}