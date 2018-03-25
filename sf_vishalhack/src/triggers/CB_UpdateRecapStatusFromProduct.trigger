/*---------------------------------------------------------------------------
 * Description: This trigger fires on Recap_product__c object.
 * ---------------------------MODIFICATIONS-----------------------------
 * 2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
 * 2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user (even if trigger toggle is on ) while running trigger code - RQ-06909
 * 2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
 * 2016-05-19 - lalitha.adduru@cdk.com - added logic to populate contact relationship when account or contact is updated -  RQ-06982
 * 2016-06-28 - vijay.manimaran@cdk.com modified "IF" condition adding IsInsert
 * 2016-06-28 - vijay.manimaran@cdk.com code formatted and added Header comments.
  --------------------------------------------------------------------------*/

trigger CB_UpdateRecapStatusFromProduct on Recap_Product__c(before insert, before update, after insert, after update)
{

	list<Recap_Product__c> newRecapProductList = ALL_TriggerToggle_Handler.ProfileFilter(trigger.new, 'Recap_Product__c');
	if (Trigger.isBefore && Trigger.isInsert)
	{
		Set<Id> RecapIds = new Set<Id> ();
		for (Recap_Product__c RecapProduct : newRecapProductList) { if (RecapProduct.Recap__c != null) { RecapIds.add(RecapProduct.Recap__c); } }

		Map<Id, Recap__c> Recaps = new Map<Id, Recap__c> ([
		                                                  Select Id, Name, Account__c, (Select Id, Name, Recap__c, RecordTypeId, RecordType.Name From Recap_Products__r)
		                                                  From Recap__c
		                                                  Where Id IN :RecapIds
		                                                  ]);

		//List<Recap_Product__c> Test = New List<Recap_Product__c>();
		//Test = [Select Id, Name, Recap__c, RecordTypeId, RecordType.Name, Recap__r.Product__c From Recap_Product__c Where Recap__c IN :RecapIds];
		//System.debug('test.RecordType.Name---'+test[0].RecordType.Name);
		//System.debug('Test.Recap__c---'+test[0].Recap__c);
		//System.debug('RecapIds---'+RecapIds);
		//System.debug('Test---'+Test);
		//System.debug('Recaps---'+Recaps);
		//Map<String, String> RecapIdRecapProdNameMap = new Map<String, String>();
		//for(Recap_Product__c rp: Test){RecapIdRecapProdNameMap.put(rp.RecordTypeId, rp.RecordType.Name);} 
		//System.debug('RecapIdRecapProdNameMap---'+RecapIdRecapProdNameMap);

		for (Recap_Product__c RecapProduct : newRecapProductList) {
			if (RecapProduct.Recap__c != null) {
				Recap__c CurrentRecap = Recaps.get(RecapProduct.Recap__c);
				if (CurrentRecap != null && CurrentRecap.Account__c != null) { RecapProduct.Recap_Account__c = CurrentRecap.Account__c; }
			}
		}

		CB_Recap.CheckDuplicateRecapProducts(Recaps, newRecapProductList);
	}

	//2016-05-19 - lalitha.adduru@cdk.com - RQ-06982
	//2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)

	if (Trigger.isBefore && (Trigger.IsInsert || Trigger.isUpdate))
	{
		Map<String, String> contactToCRMap = new Map<String, String> ();
		contactToCRMap.put('DMS_Admin_Contact_Name__c', 'DMS_Admin_Contact_Name_Relationship__c');
		contactToCRMap.put('Domain_Contact__c', 'Domain_Contact_Relationship__c');
		contactToCRMap.put('Inventory_Contact__c', 'Inventory_Contact_Relationship__c');
		contactToCRMap.put('Product_Primary_Contact__c', 'Product_Primary_Contact_Relationship__c');
		contactToCRMap.put('GM_DP_Contact_Name__c', 'GM_DP_Contact_Name_Relationship__c');
		contactToCRMap.put('Sales_Manager_Contact_Name__c', 'Sales_Manager_Contact_Name_Relationship__c');
		contactToCRMap.put('Service_Manager_Contact_Name__c', 'Service_Mgr_Contact_Name_Relationship__c');
		contactToCRMap.put('LMA_President_Name__c', 'LMA_President_Relationship__c');
		contactToCRMap.put('USIM_Contact_Name__c', 'USIM_Contact_Relationship__c');
		contactToCRMap.put('Agency_720_Contact_Name__c', 'Agency_720_Contact_Name_Relationship__c');

		system.debug('contactToCRMap***********' + contactToCRMap);
		ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Recap_Account__c', null, contactToCRMap);
	}

	if (Trigger.isAfter)
	{
		CB_Recap.InvokeRecapStatusUpdate(newRecapProductList, 'Recap__c');
	}
}