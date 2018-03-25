/*---------------------------------------------------------------------------
 * Description: This trigger fires on Recap__c object. This object is related to Recap_product__c and 
   Recap_webid__c objects. When Certain fields on these objects are updated, the trigger assists in 
   changing the 'status' field in the Recap__c object to appropriate value depending on the fields 
   updated in the three above mentioned objects.
 * ---------------------------MODIFICATIONS-----------------------------
 * 2016-05-19 - lalitha.adduru@cdk.com - added logic to populate contact relationship when account or contact is updated -  RQ-06982
 * 2016-06-28 - vijay.manimaran@cdk.com modified "IF" condition adding IsInsert
 * 2016-06-28 - vijay.manimaran@cdk.com code formatted and added Header comments.
  --------------------------------------------------------------------------*/

trigger CB_UpdateRecapStatus on Recap__c(before Insert, before Update)
{
	// query all of the recordtypes into a map, get recordtype name (record does not necessarily have it)
	RecordType GlobalRecordType = [Select Id, Name, sObjectType From RecordType Where sObjectType = 'Recap__c' And Name like '%global%' limit 1];

	List<Recap__c> RecapsToProcess = new List<Recap__c> ();
	System.debug('GlobalRecordType---' + GlobalRecordType);
	if (GlobalRecordType != null)
	{
		for (Recap__c Recap : Trigger.New) {
			if (Recap.RecordTypeId == GlobalRecordType.Id) { RecapsToProcess.add(Recap); }
		}
		System.debug('RecapsToProcess---' + RecapsToProcess);
	}

	//2016-05-19 - lalitha.adduru@cdk.com - RQ-06982
	//2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
	if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
	{
		Map<String, String> contactToCRMap = new Map<String, String> ();
		contactToCRMap.put('Alternate_Contact__c', 'Alternate_Contact_Relationship__c');
		contactToCRMap.put('Domain_Contact__c', 'Domain_Contact_Relationship__c');
		contactToCRMap.put('Internet_Manager__c', 'Internet_Manager_Relationship__c');
		contactToCRMap.put('Inventory_Contact__c', 'Inventory_Contact_Relationship__c');
		contactToCRMap.put('Media_Tracker_Contact__c', 'Media_Tracker_Contact_Relationship__c');
		contactToCRMap.put('Primary_Contact__c', 'Primary_Order_Contact_Relationship__c');
		ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Account__c', null, contactToCRMap);
	}
	// update Accounts on Recap Products, if the Recap Account has changed
	// 2014-02-19 MK - this causes a DML recursion error that cannot be fixed using a variable; commented out
	//CB_Recap.UpdateAccountsOnRecapProducts(Trigger.NewMap, Trigger.OldMap);

	// call the class method to process the Recap status fields
	CB_Recap.RecapBeforeInsertTriggerHandler(RecapsToProcess);
}