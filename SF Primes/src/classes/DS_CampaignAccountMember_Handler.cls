//RQ-05035 
//2015-10-13 - lakshmi.addanki@cdk.com - Created new Trigger Handler*/
public with sharing  class DS_CampaignAccountMember_Handler {
    
    public static void executeTrigger(){
        if(!Trigger.isExecuting)
        {
            system.debug('Trigger code called from outside of trigger.');
        }
        if (Trigger.isBefore)
        {
            if (Trigger.isInsert){           
                createCompositeIDValidateAndSetCampaignStatusBeforeInsert(Trigger.new);
                
            }       
            if (Trigger.isUpdate){           
                validateAndSetCampaignStatusBeforeUpdate(Trigger.new, Trigger.old);
                
            } 
            
        }
        
    }
    
    // Set the composite ID
    // Check the member status = null or 'none' Add those Cams to the list of MemberstoProcess & Capaign id 's to List
    //Get the CMS for the Campaign id's whose defaultstatus flag is true into  a list and put it in a map
    // Now loop through MemberstoProcess list and set the  status value to name of the default CMS.
    //
    
    
    public static void createCompositeIDValidateAndSetCampaignStatusBeforeInsert(List<Campaign_Account_Members__c> newList) 
    {      
        System.debug('DS_CampaignAccountMember_Handler:createCompositeIDValidateAndSetCampaignStatusBeforeInsert');              
        for(Campaign_Account_Members__c cam : NewList)
        {
            cam.Composite_Id__c = cam.Campaign__c + '' + cam.Account__c;
            System.debug('cam.Composite_Id__c' + cam.Composite_Id__c);  
        }
        
        validateAndSetCampaignStatus(newList,null);
    }
    
    public static void validateAndSetCampaignStatusBeforeUpdate(List<Campaign_Account_Members__c> newList ,List<Campaign_Account_Members__c>  oldList) 
    {      
        System.debug('DS_CampaignAccountMember_Handler:validateAndSetCampaignStatusBeforeUpdate');
        validateAndSetCampaignStatus(newList,oldList);
        
    }
    
    
    public static void validateAndSetCampaignStatus(List<Campaign_Account_Members__c> newList ,List<Campaign_Account_Members__c>  oldList) 
    {    
        System.debug('DS_CampaignAccountMember_Handler:validateAndSetCampaignStatus start');               
        set<Id> CampaignIds = new set<Id>(); // a set of Campaigns to get the Statuses for
        List<Campaign_Member_Status__c> defaultStatuses = new List<Campaign_Member_Status__c>();
        List<Campaign_Account_Members__c> MembersToProcess = new List<Campaign_Account_Members__c>(); // a list of records to process
        
        for(Campaign_Account_Members__c cam : newList)
        {
            System.debug('cam.Campaign_Member_Status__c' + cam.Campaign_Member_Status__c); 
            if(cam.Campaign_Member_Status__c == null || cam.Campaign_Member_Status__c.trim().equals('--None--') )
            {
                MembersToProcess.add(cam); // add it to the list of records to process
                CampaignIds.add(cam.Campaign__c); // add the Campaign to the list of Campaigns to get the Status for
            }
        } 
        
        if(MembersToProcess.size() > 0 && CampaignIds.size() > 0)
        {
            defaultStatuses = [
                Select Id, Name, // get only the default statuses for the relevant Campaigns  
                Default_Status__c, Campaign__c, Indicates_Response__c, Cobalt_Consolidation_ID__c, CreatedDate, CreatedById 
                From Campaign_Member_Status__c 
                Where Campaign__c 
                IN :CampaignIds
                AND Default_Status__c = true
            ];
        }
        
        Map<Id, Campaign_Member_Status__c> defStatusMap = new Map<Id, Campaign_Member_Status__c>();
        for (Campaign_Member_Status__c c : defaultStatuses) {
            defStatusMap.put(c.Campaign__c, c);
        }
        
        // for each Campaign Account Member to process
        //select the default status campaign account member
        // if the member existsOA
        // set the Campaign Account Member Status field to the default value 
        for(Campaign_Account_Members__c cam : MembersToProcess)
        {	
            Campaign_Member_Status__c defStatusMember = defStatusMap.get(cam.Campaign__c);
            if(defStatusMember != null) { 
                cam.Campaign_Member_Status__c = defStatusMember.Name; 
            }       
            
        }   
        System.debug('DS_CampaignAccountMember_Handler:validateAndSetCampaignStatus end');   
        
    }
    
}