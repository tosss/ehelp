trigger DS_CampaignMemStatusDefault on Campaign_Member_Status__c (before insert, before update, after update) {
	
	List <String> campaignList= new List<String>();
	List <String> campaignUpdateList= new List<String>();
	
	List <String> campaignStatusUpdateList= new List<String>();
	List <Campaign_Account_Members__c> CAMUpdateList= new List<Campaign_Account_Members__c>();
	
	Map <String,String> CAMStatusMap = new Map <String,String>();
	
	Map <Id,Id> campaignDefaultMap = new Map <Id,Id>();
	Integer index=0;
	for (Campaign_Member_Status__c cam : Trigger.new){
		if(cam.Default_Status__c==true){
			campaignList.add(cam.Campaign__c);
		}
		if(Trigger.isUpdate && Trigger.isAfter){
			if(Trigger.old[index].Name!=Trigger.new[index].Name){
				campaignUpdateList.add(cam.Campaign__c);
				campaignStatusUpdateList.add(Trigger.old[index].Name);
				CAMStatusMap.put(cam.Campaign__c+Trigger.old[index].Name,Trigger.new[index].Name);
			}
		}
		index++;	
	}
	if(campaignList.size()>0){
		for(Campaign_Member_Status__c singleCam : [Select c.Id,c.Campaign__c, c.Default_Status__c From Campaign_Member_Status__c c where Campaign__c in :campaignList and Default_Status__c=true]){
			campaignDefaultMap.put(singleCam.Campaign__c,singleCam.Id);
		}
	}
	
	
	for (Campaign_Member_Status__c cam : Trigger.new){
		if(cam.Default_Status__c==true){
			
			if(campaignDefaultMap.get(cam.Campaign__c)!=null && campaignDefaultMap.get(cam.Campaign__c)!=cam.Id)
			{
				cam.addError('Only one status may be the default for this campaign.  Another status has been identified as the default.');
			}
		}
	}
	
	if(Trigger.isUpdate && Trigger.isAfter && campaignUpdateList.size()>0)
	{
		for(Campaign_Account_Members__c singleCam : [Select c.Id, c.Campaign__c, c.Campaign_Member_Status__c From Campaign_Account_Members__c c where Campaign__c in :campaignUpdateList and Campaign_Member_Status__c in :campaignStatusUpdateList]){
			Campaign_Account_Members__c newCam=new Campaign_Account_Members__c(id=singleCam.Id);
			newCam.Campaign_Member_Status__c=CAMStatusMap.get(singleCam.Campaign__c+singleCam.Campaign_Member_Status__c);
			CAMUpdateList.add(newCam);
		}
		if(CAMUpdateList.size()>0)
			update CAMUpdateList;
	}
}