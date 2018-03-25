/*----------------------------------------------------------------------
 * RQ-06982
 * 17 August 2010  Matt.Keefe@cdk.com - created  
 * Description: Trigger on LaserArtworkOrder Object
  Added functionality : Trigger to populate Contact Relationship Lookup on insert and on update(only when account or contact is changed)
 * ---------------------------MODIFICATIONS-----------------------------
 * 2015-07-17  Vishal Bandari   - RQ-04982: Added code block to perform updations on Forms_Order__c Object after updater 
 * 2016-06-28 - vijay.manimaran@cdk.com modified "IF" condition adding IsInsert
 * 2016-06-28 - vijay.manimaran@cdk.com Added the comments  header.
  ------------------------------------------------------------------------*/
trigger ALL_LaserArtworkOrder on Laser_Artwork_Order__c(before insert, before update, after insert, after update)
{
	Map<Id, Laser_Artwork_Order__c> NewOrders = Trigger.newMap;
	Map<Id, Laser_Artwork_Order__c> OldOrders = Trigger.oldMap;

	//2016-05-13 lalitha.adduru@cdk.com - to make profile exceptions for the methods to run( taken from DS_UpdateLead) - RQ-06909
	list<Laser_Artwork_Order__c> IntegrationUserBypassList = ALL_TriggerToggle_Handler.ProfileFilter(trigger.new, 'Laser_Artwork_Order__c');

	if (!IntegrationUserBypassList.isEmpty())
	{
		if (Trigger.isBefore)
		{
			// set LAO fields based on Status (Time Tracking)
			if (All_CheckRecursive.runCodeBlockOnce('DS_LAO_SetFieldsBasedOnStatus_Before') || test.isRunningTest())
			{
				DS_LAO_SetFieldsBasedOnStatus.Before(Trigger.new, Trigger.Old);
			}
			if (All_CheckRecursive.runCodeBlockOnce('ApprovalProcess.SetOwnerFieldMethod') || test.isRunningTest())
			{
				DS_LAO_ApprovalProcess.SetOwnerFieldMethod(Trigger.new, Trigger.OldMap);
			}
			//17 July 2015: Vishal Bandari added code to perform Key_Rep__c changes on related Forms_Collections__c Object        
			if (All_CheckRecursive.runCodeBlockOnce('ALL_UpdateFormOrders_Handler') || test.isRunningTest())
			{
				ALL_UpdateFormOrders_Handler.updateFormsOrderChanged(Trigger.new);
			}
		}
		// trigger for firing approval process
		if (Trigger.isAfter)
		{
			map<Id, Profile> Profiles = new map<Id, Profile> ([select Id, Name from Profile]);

      Profile CurrentUserProfile = Profiles.get(UserInfo.getProfileId());
      String UserProfileName = CurrentUserProfile != null ? CurrentUserProfile.Name : '';

			// set LAO fields based on Status (Time Tracking), separate logic for after trigger
			if (All_CheckRecursive.runCodeBlockOnce('DS_LAO_SetFieldsBasedOnStatus_After') || test.isRunningTest())
			{
				DS_LAO_SetFieldsBasedOnStatus.After(Trigger.new);
			}


			if (All_CheckRecursive.runCodeBlockOnce('ALL_LaserArtworkOrder_isAfter') || test.isRunningTest())
			{
				DS_LAO_ApprovalProcess.ApprovalProcessMethod(Trigger.newMap, Trigger.oldMap);
			}


			DS_LAO_ApprovalProcess.CreateQualitySnapShots(Trigger.new, trigger.oldMap);
		}
	}


	//Vijay added the below conditon to populate the Contact relationship field on Forms order. 		
	if (Trigger.isBefore && (Trigger.IsInsert || Trigger.isUpdate))
	{
		Map<String, String> contactToCRMap = new Map<String, String> ();
		contactToCRMap.put('Contact__c', 'Contact_Relationship__c');
        
        set<Id> CMFIds = new set<Id>();
        for(Laser_Artwork_Order__c LAO : Trigger.New)
        {
            CMFIds.add(LAO.Ship_CMF_Info__c);
        }
        
        map<Id, CMF_Info__c> CMFS = new map<Id, CMF_Info__c>([
            select Id, Account__c 
            from CMF_Info__c
            where Id IN : CMFIds
        ]);
        
        for(Laser_Artwork_Order__c LAO : Trigger.New)
        {
            CMF_Info__c CurrentCMF = CMFS.get(LAO.Ship_CMF_Info__c);
            
            if(CurrentCMF != null) 
            {
                LAO.putSObject('Ship_CMF_Info__r', CurrentCMF);
            }
        }
        
		Map<Id, Id> mapParentVal = new Map<Id, Id> ();
		for (Laser_Artwork_Order__c LaserArtworkOrder : Trigger.New) {
			mapParentVal.put(LaserArtworkOrder.Ship_CMF_Info__c, LaserArtworkOrder.Ship_CMF_Info__r.Account__c);
		}

		if (!IntegrationUserBypassList.isEmpty())
		{
			ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Ship_CMF_Info__r.Account__c', mapParentVal, contactToCRMap);
		}
	}
	//Vijay code ends here 
}