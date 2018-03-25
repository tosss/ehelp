//RQ-05035 
//2015-10-13 - lakshmi.addanki@cdk.com - Created new trigger Handler
//
public class DS_CampaignMemberStatus_Handler {
    
    public static void executeTrigger(){
        
        if(!Trigger.isExecuting){
            system.debug('Trigger called from outside of trigger.');
        }
        if (Trigger.isBefore)
        {
            if (Trigger.isInsert){           
                validateStatusBeforeInsert(Trigger.new);
            }
            if (Trigger.isUpdate){           
                validateStatusBeforeUpdate(Trigger.new,Trigger.oldMap);
            }
        }
        if (Trigger.isAfter){ 
            if (Trigger.isUpdate){            
                cascadeNameUpdatesToCAMAfterUpdate(Trigger.new, Trigger.oldMap);
            }     
        }
    }
    // Loop through all the Campaign Member Status objects 
    // check if the inserted records have default status true and add them to a list
    // select the default status members for these campaigns
    // check if the default member already exists.
    // if exists return error
    //
    public static void validateStatusBeforeInsert(List<Campaign_Member_Status__c> newList) {      
        System.debug('DS_CampaignMemStatusTriggerHandler:validateStatusBeforeInsert');   
        validateDefaultStatus(newList);
    }
    
    //Loop through all the Campaign Member Status objects 
    // check if the updated records have default status true and add them to a list
    // select the default status members for these campaigns
    // check if the default member already exists.
    //if exists return error
    //
    public static void validateStatusBeforeUpdate(List<Campaign_Member_Status__c> newList,Map<Id,sObject>  oldMap) {      
        System.debug('DS_CampaignMemStatusTriggerHandler:validateStatusBeforeUpdate');   
        validateDefaultStatus(newList);
    }
    
    //If the Campaign Member Status Name is changed
    //All the Campaign Account Members with old Name are updated to the new Value
    //Add to list all Campaign Id's, and Statusus of the CMS members in the trigger  new list
    //Create a Map with key as campaign and old name , value new name 
    //
    public static void cascadeNameUpdatesToCAMAfterUpdate(List<Campaign_Member_Status__c> newList ,Map<Id,sObject>  oldMap) 
    {  
        System.debug('DS_CampaignMemStatusTrigger_Handler:cascadeNameUpdatesToCAMAfterUpdate');  
        Set <Id> campaignUpdateIds= new Set<Id>();
        List <String> campaignStatusUpdateList= new List<String>();
        List <Campaign_Account_Members__c> CAMUpdateList= new List<Campaign_Account_Members__c>();
        
        Map <String,String> CAMStatusMap = new Map <String,String>();
        
        for (Campaign_Member_Status__c cam : newList)
        {
            Campaign_Member_Status__c camOld =(Campaign_Member_Status__c)oldMap.get(cam.Id);
            if(camOld != null && cam.Name != camOld.Name)
            {
                campaignUpdateIds.add(cam.Campaign__c);
                campaignStatusUpdateList.add(camOld.Name);
                CAMStatusMap.put(cam.Campaign__c+camOld.Name,cam.Name);
            }
            
        }
        
        
        if(campaignUpdateIds.size()>0)
        {
            for(Campaign_Account_Members__c updateRequiredCam : [
                Select c.Id, c.Campaign__c, c.Campaign_Member_Status__c 
                From Campaign_Account_Members__c c 
                where Campaign__c in :campaignUpdateIds 
                and Campaign_Member_Status__c in :campaignStatusUpdateList
            ])
                
            {
                Campaign_Account_Members__c newCam=new Campaign_Account_Members__c(id=updateRequiredCam.Id);
                newCam.Campaign_Member_Status__c=CAMStatusMap.get(updateRequiredCam.Campaign__c+updateRequiredCam.Campaign_Member_Status__c);
                CAMUpdateList.add(newCam);
            }
            if(CAMUpdateList.size()>0)
            {
                update CAMUpdateList;
            }
        }
        
    }
    
    private static void validateDefaultStatus(List<Campaign_Member_Status__c> newList){
         System.debug('DS_CampaignMemStatusTrigger_Handler:validateDefaultStatus');  
        Set <Id> campaignDefaultIds= new Set<Id>();
        Map <Id,Id> campaignDefaultMap = new Map <Id,Id>();     
        for (Campaign_Member_Status__c cam : newList){
            if(cam.Default_Status__c==true){
                campaignDefaultIds.add(cam.Campaign__c);
            }
        }
        
        if(campaignDefaultIds.size()>0)
        {
            for(Campaign_Member_Status__c singleCam : [
                Select c.Id,c.Campaign__c, c.Default_Status__c 
                from Campaign_Member_Status__c c 
                where Campaign__c in :campaignDefaultIds 
                and Default_Status__c=true
            ])
            {
                campaignDefaultMap.put(singleCam.Campaign__c,singleCam.Id);
                System.debug('campaignDefaultMap ' + singleCam.Campaign__c + ':' + singleCam.Id ); 
            }
        }
        for (Campaign_Member_Status__c cam : newList)
        {
            if(cam.Default_Status__c)            
            {
                System.debug('cam ' + cam.Id ); 
                if(campaignDefaultMap.get(cam.Campaign__c)!=null && campaignDefaultMap.get(cam.Campaign__c)!=cam.Id)
                {
                    System.debug('match found error'); 
                    cam.addError('Only one status may be the default for this campaign.  Another status has been identified as the default.');
                }
            }
        }
    }
}