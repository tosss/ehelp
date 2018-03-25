/*----------------------------------------------------------------------
 * RQ-07014
 * 2016-05-19 lalitha.adduru@cdk.com - created this class  
 * Description: Helper class for Triggers related to sharedcontacts project.
 * ---------------------------MODIFICATIONS-----------------------------
 * 2015-10-13 Hemanth - added recursive check on DS_UpdateCampaignAccountMember_Handler 
 * 2015-10-27 Hemanth - Added Test.isRunning check to access blocked code from test class
 * 2016-04-25 - lalitha.adduru@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
 * 2016-04-25 - lalitha.adduru@cdk.com - modified to skip integration user while running trigger code - RQ-06909 
 * 2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
 * 2016-06-28 - vijay.manimaran@cdk.com - modified the code, beforeinsert line 19
 * 2016-06-28 - vijay.manimaran@cdk.com code formatted and added Header comments.
 * 2017-01-30 - lalitha.adduru@cdk.com - modified existing code to improvise and fit it to the coding standards - RQ-06389
  ------------------------------------------------------------------------*/

trigger ALL_Lead on Lead(before insert, before update, after insert, after update)
{
	list<Lead> newLeadList = ALL_TriggerToggle_Handler.ProfileFilter(trigger.new, 'Lead');

	if (Trigger.isAfter)
	{
        ALL_Lead_Handler handlerReference = new ALL_Lead_Handler();
        Map<String,Set<Lead>> pardotNonPardotLeadsMap = handlerReference.fetchPardotNonPardotLeadsMap(Trigger.New);
        
		if (ALL_CheckRecursive.runCodeBlockOnce('runOnce_1@Lead'))
		{
			DS_UpdateCampaignAccountMember_Handler.updateCampaignAccountMember(Trigger.Old, newLeadList);
		}
        
        if(Trigger.isUpdate)
        {
            handlerReference.insertRequiredContactRelationships(Trigger.New);
            
            //2016-03-11 lalitha.adduru@cdk.com - Send leadsNotFromPardot instead of trigger.New - RQ-06431
            if(pardotNonPardotLeadsMap.get('NotPardot')!=null)
            {
                handlerReference.createLeadShare(new List<Lead>(pardotNonPardotLeadsMap.get('NotPardot')));
            }
        }
	}

    if (Trigger.isBefore)
    {
        ALL_Lead_Handler handlerReference = new ALL_Lead_Handler();
        Map<String,Set<Lead>> pardotNonPardotLeadsMap = handlerReference.fetchPardotNonPardotLeadsMap(Trigger.New);
        
        if(Trigger.isInsert)
        {
            if(pardotNonPardotLeadsMap.get('NotPardot') != null)
            {
                handlerReference.ContactPhoneSync(trigger.OldMap, new List<Lead>(pardotNonPardotLeadsMap.get('NotPardot')));
            	handlerReference.updateVendorInstallDate(new List<Lead>(pardotNonPardotLeadsMap.get('NotPardot')));
            }
            
            if(pardotNonPardotLeadsMap.get('pardot') != null)
            {
                set<String> leadOwnerSet = new set<String>();
                
                for(Lead lead : pardotNonPardotLeadsMap.get('pardot'))
                {
                    leadOwnerSet.add(lead.OwnerId);
                }
                
                handlerReference.updateOwners(new List<Lead>(pardotNonPardotLeadsMap.get('pardot')), leadOwnerSet);               
            }
        }
        
        if(Trigger.isUpdate)
        {
            handlerReference.UpdateOwnerDetails(trigger.OldMap, newLeadList);
        }
        
        if(Trigger.isUpdate || Trigger.isInsert)
        {
            //2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
            //2016-06-09 vijay.manimaran@cdk.com - updated the Account field - "Current_Account__c" 
            Map<String, String> contactToCRMap = new Map<String, String> ();
            contactToCRMap.put('Contact__c', 'Contact_Relationship__c');
            ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Current_Account__c', null, contactToCRMap);
            handlerReference.UpdateOpportunity(Trigger.NewMap, Trigger.oldMap); // from CB_UpdateLead
            handlerReference.checkCancelWorkflows(newLeadList);
        }
    }


}