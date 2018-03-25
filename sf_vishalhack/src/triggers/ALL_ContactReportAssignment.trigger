/*----------------------------------------------------------------------
  * RQ-06982
  * 2016-05-25 lalitha.adduru@cdk.com - created this trigger for RQ-06982
  * Description: Trigger to populate Contact Relationship Lookup on insert and on update(only when account or contact is changed)
  * ---------------------------MODIFICATIONS-----------------------------
  * 2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
  * 2016-06-28 - vijay.manimaran@cdk.com modified "IF" condition adding IsInsert
  ------------------------------------------------------------------------*/

trigger ALL_ContactReportAssignment on Contact_Report_Assignment__c(before insert, before update)
{
	if (Trigger.isBefore && (Trigger.IsInsert || Trigger.isUpdate))
	{
		Map<String, String> contactToCRMap = new Map<String, String> ();
		contactToCRMap.put('Contact__c', 'Contact_Relationship__c');
		ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Account__c', null, contactToCRMap);
	}
}