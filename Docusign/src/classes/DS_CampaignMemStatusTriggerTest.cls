public class DS_CampaignMemStatusTriggerTest {

	testMethod static void TriggerTest(){
		
		Campaign newCamp = new Campaign();
		newCamp.Name='Test Campaign';
		insert newCamp;
		
		Account acct = new Account(Name='Test');
		insert acct;
		
		Account acct2 = new Account(Name='Test2');
		insert acct2;
		
		Campaign_Member_Status__c status1= new Campaign_Member_Status__c(Campaign__c=newCamp.Id,Name='Status1',Default_Status__c=true);
		insert status1;
		
		try{
			Campaign_Member_Status__c status2a= new Campaign_Member_Status__c(Campaign__c=newCamp.Id,Name='Status2',Default_Status__c=true);
			insert status2a;
		} 
		catch(exception e)
		{
		}
		
		Campaign_Member_Status__c status2b= new Campaign_Member_Status__c(Campaign__c=newCamp.Id,Name='Status2',Default_Status__c=false);
		insert status2b;
		
		Campaign_Account_Members__c CAM1= new Campaign_Account_Members__c(Account__c=acct.Id, Campaign__c=newCamp.Id,Campaign_Member_Status__c=status1.Name);
		insert CAM1;
		
		Campaign_Account_Members__c CAM2= new Campaign_Account_Members__c(Account__c=acct2.Id, Campaign__c=newCamp.Id,Campaign_Member_Status__c=status1.Name);
		insert CAM2;
		
		Campaign_Member_Status__c status1b= new Campaign_Member_Status__c(Id=status1.Id, Campaign__c=newCamp.Id,Name='Status1b',Default_Status__c=true);
		update status1b;
	}
}