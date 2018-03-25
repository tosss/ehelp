@IsTest
public class DS_Opportunity_Handler_Test 
{
	public static testmethod void testUpdateOpp()
    {
        CustomSettings__c cs = new CustomSettings__c();
        cs.DS_SalesTeamTrigger_On__c = true;
        insert cs; 
        
        profile p = [Select Id, Name From Profile Limit 1];
        list<User> users = new list<User>();
        
        users.add(DS_TestObjects.NewUser_Inserted());
        users.add(DS_TestObjects.NewSecondUser_Inserted());
        
		Account acct = new Account(Name='Test Acct 1');
		insert acct;
		
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
		
		Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity 1', 
            AccountId = acct.Id, 
            DMS_Platform__c = 'Web 2k', 
            Type = 'Unhook', 
            CloseDate = Date.today(), 
            StageName = 'Plan', 
            ADP_Opportunity_Owner__c = users[0].Id
        ); insert testOpp;
		
		testOpp.DMS_Platform__c = 'Web 1k';
		update testOpp;
		
		testOpp.DMS_Platform__c = 'Web 2k';
		update testOpp;
		
		delete sat;
		
		testOpp.DMS_Platform__c = 'Web 1k';
		update testOpp;
	}
}