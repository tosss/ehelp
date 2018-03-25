/*----------------------------------------------------------------------
 * RQ-06982
 * 2016-06-18 -vijay.manimaran@cdk.com - created  
 * Description: Trigger to populate Contact Relationship Lookup on insert and on update(only when account or contact is changed)
 * ---------------------------MODIFICATIONS-----------------------------
 * 2016-06-28 - vijay.manimaran@cdk.com modified "IF" condition adding IsInsert
 * 2016-07-05 - vijay.manimaran@cdk.com modified the complete logic from line 16 - 50, to add functionality for update and insert
 * 2016-07-11 - vijay.manimaran@cdk.com modified removed before update event.

  ------------------------------------------------------------------------*/

trigger ALL_OpportunityInfluencer on Opportunity_Influencers__c(Before insert) {

	if (Trigger.isBefore && (Trigger.IsInsert || Trigger.isUpdate))
	{
		Map<String, String> contactToCRMap = new Map<String, String> ();
		contactToCRMap.put('Contact__c', 'Contact_Relationship__c');

		set<Id> OppIds = new set<Id> ();
		for (Opportunity_Influencers__c OPPINF : Trigger.New)
		{
			OppIds.add(OPPINF.Opportunity__c);
		}

		map<Id, Opportunity> Opp = new map<Id, Opportunity> ([
		                                                     select Id, AccountId
		                                                     from Opportunity
		                                                     where Id IN :OppIds
		                                                     ]);


		for (Opportunity_Influencers__c OPPINF : Trigger.New)
		{
			Opportunity CurrentOpp = Opp.get(OPPINF.Opportunity__c);

			if (CurrentOpp != null)
			{
				OPPINF.putSObject('Opportunity__r', CurrentOpp);
			}
		}

		Map<Id, Id> mapParentVal = new Map<Id, Id> ();
		for (Opportunity_Influencers__c OpportunityInfluencer : Trigger.New)
		{
			mapParentVal.put(OpportunityInfluencer.Opportunity__c, OpportunityInfluencer.Opportunity__r.AccountId);
		}
		list<Opportunity_Influencers__c> IntegrationUserBypassList = ALL_TriggerToggle_Handler.ProfileFilter(trigger.new, 'Opportunity_Influencers__c');
		system.debug('IntegrationUserBypassList' + IntegrationUserBypassList.size());
		if (!IntegrationUserBypassList.isEmpty())
		{
			ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Opportunity__r.AccountId', mapParentVal, contactToCRMap);
		}
	}
}