public class DS_CampaignMemberController {
	public Campaign_Account_Members__c campAcctMem;
	public String countries;
	public String campaignId;
	public String accountId;
	public String id;
	public List<SelectOption> options=new List<SelectOption>(); 
	
	/*public PageReference test(){ 
		System.debug('COUNTRIES' + countries);
		return null; 
	} */

	public List<SelectOption>getItems(){ 
		Campaign_Member_Status__c[] listOfOptions = [select Name, Default_Status__c from Campaign_Member_Status__c where Campaign__c=:campaignId];
		options.add(new SelectOption('','--None--'));
		Integer sz = listOfOptions.size()-1;
		
		for(Integer i=sz; i>=0; i--){
			if(listOfOptions[i].Default_Status__c==true){
				countries = listOfOptions[i].Name;	
			}
			options.add(new SelectOption(listOfOptions[i].Name,listOfOptions[i].Name)); 
		}
		return options; 
	} 
	public String getCountries(){ 
		System.debug('Countries: '+countries);
		return countries; 
	} 
	public void setCountries(String countries){ 
		this.countries=countries; 
	} 
	
	public DS_CampaignMemberController(){
		campaignId = System.currentPageReference().getParameters().get('campaignId');
		accountId = System.currentPageReference().getParameters().get('accountId');
		id = System.currentPageReference().getParameters().get('id');
		System.debug('CAMPAIGN ID: '+campaignId);
		System.debug('MEMBER ID: '+id);
		
		if(id!=null && id!=''){
			campAcctMem = [select Id, Campaign_Member_Status__c, Account__c, Campaign__c from Campaign_Account_Members__c where Id=:id];
			campAcctMem.Account__c = accountId;
			countries=campAcctMem.Campaign_Member_Status__c;
		}
		else{
			campAcctMem = new Campaign_Account_Members__c(Campaign__c=campaignId);
		}
	}
	
	public Campaign_Account_Members__c getCampAcctMem(){
		return campAcctMem;
	}
	public PageReference save(){
		campAcctMem.Campaign_Member_Status__c=countries;
		upsert campAcctMem;
		
		PageReference pr = new PageReference('/'+campAcctMem.Id);

		return pr;
	}
	public PageReference saveAndNew(){
		campAcctMem.Campaign_Member_Status__c=countries;
		upsert campAcctMem;
		
		PageReference pr = new PageReference('/apex/CampaignAccountMember?campaignId='+campaignId);
		pr.setRedirect(true);
		
		return pr;
	}
	public PageReference cancel(){
		PageReference pr = new PageReference('/'+campaignId);
		
		return pr;
	}
}