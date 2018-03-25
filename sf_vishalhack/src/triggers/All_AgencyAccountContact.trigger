/*----------------------------------------------------------------------
 * RQ-06982
 * 2016-06-08 -vijay.manimaran@cdk.com - created  
 * Description: Trigger to populate Contact Relationship Lookup on insert and on update(only when account or contact is changed)
 * ---------------------------MODIFICATIONS-----------------------------
 * 2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
 * 2016-06-28 - vijay.manimaran@cdk.com modified "IF" condition adding IsInsert
  ------------------------------------------------------------------------*/
trigger All_AgencyAccountContact on Agency_Account_Contact__c(after insert, after update, before insert, before update) {

	if (Trigger.isBefore && (Trigger.IsInsert || Trigger.isUpdate))
	{
		//2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
		Map<String, String> contactToCRMap = new Map<String, String> ();
		contactToCRMap.put('Contact__c', 'Contact_Role_Contact_Relationship__c');
		ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Agency_Account__c', null, contactToCRMap);
	}
}