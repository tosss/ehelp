public class DS_CampaignMemberControllerTest {
	 testMethod static void campControlTest(){
		Campaign c = new Campaign(Name='NCTEST');
	  	insert c;
	  	Account acct = new Account(Name='ACCTTEST');
	  	insert acct;
	  	
		System.currentPageReference().getParameters().put('campaignId', c.Id);
		System.currentPageReference().getParameters().put('accountId', acct.Id);		
		
		DS_CampaignMemberController cmc = new DS_CampaignMemberController();
		cmc.campAcctMem.Account__c=acct.Id;
		cmc.getItems(); 
		cmc.getCountries();
		cmc.setCountries('countries'); 
		cmc.getCampAcctMem();
		try{
			cmc.save();
		}catch(Exception e){}
		cmc.saveAndNew();
		cmc.cancel();
	 }
}