trigger DS_CreateCompositeIDforCampaignAccountMember on Campaign_Account_Members__c (before insert, before update) {
    
    if(Trigger.isInsert && Trigger.isBefore) {
	    for(Campaign_Account_Members__c cam : Trigger.new) {
			cam.Composite_Id__c = cam.Campaign__c + '' + cam.Account__c;
	    }
    }
    
    // 2012-02-29 MK - added before insert/update (2nd block)
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isBefore) {
    	List<Id> CampaignIds = new List<Id>(); // a list of Campaigns to get the Statuses for
    	List<Campaign_Member_Status__c> Statuses = new List<Campaign_Member_Status__c>();
    	List<Campaign_Account_Members__c> MembersToProcess = new List<Campaign_Account_Members__c>(); // a list of records to process
    	
    	// for all Campaign Account Members being inserted or updated
    	// if the Campaign Member Status for the record is null or none
    	for(Campaign_Account_Members__c cam : Trigger.new) {
    		if(cam.Campaign_Member_Status__c == null || cam.Campaign_Member_Status__c == '--None--') {
    			MembersToProcess.add(cam); // add it to the list of records to process
    			CampaignIds.add(cam.Campaign__c); // add the Campaign to the list of Campaigns to get the Status for
    		} 
		} // end Campaign Account Member loop
    	
    	// if there is more than one Campaign Account Member to process (and more than one CampaignId)
    	if(MembersToProcess.size() > 0 && CampaignIds.size() > 0) {
	    	Statuses = [Select Id, Name, // get only the statuses for the relevant Campaigns  
	    			Default_Status__c, Campaign__c, Indicates_Response__c, Cobalt_Consolidation_ID__c, CreatedDate, CreatedById 
	    		From Campaign_Member_Status__c Where Campaign__c IN :CampaignIds];
    	}
    	
    	// for each Campaign Account Member to process
    	for(Campaign_Account_Members__c cam : MembersToProcess) {
    		for(Campaign_Member_Status__c status : Statuses) { // find the Campaign Member Statuses for the Campaign
    			if(cam.Campaign__c == status.Campaign__c) {
    				if(status.Default_Status__c == true) { // if the Status is the default
    					cam.Campaign_Member_Status__c = status.Name; // set the Campaign Account Member Status field to the default 
    				}
    			}
    		} // end Status loop
    	} // end Campaign Account Member loop
    }
}