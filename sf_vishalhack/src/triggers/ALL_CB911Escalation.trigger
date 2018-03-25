/*----------------------------------------------------------------------
 * RQ-06982
 * 2016-06-06 vijay.manimaran@cdk.com Created   
 * Description: Trigger on CB_911_Escalation__c Object
                Added functionality : Trigger to populate Contact Relationship Lookup on insert and on update(only when account or contact is changed)
 * ---------------------------MODIFICATIONS-----------------------------
 * 2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
 * 2016-06-28 - vijay.manimaran@cdk.com modified "IF" condition adding IsInsert
 * 2016-06-28 - vijay.manimaran@cdk.com Added the comments  header.
  ------------------------------------------------------------------------*/
trigger ALL_CB911Escalation on CB_911_Escalation__c(after insert, after update, before insert, before update) {

    if(Trigger.isBefore && (Trigger.isUpdate|| Trigger.isInsert)){
		Map<String, String> contactToCRMap = new Map<String, String> ();
		contactToCRMap.put('Dealer_Contact_Name__c', 'Contact_Relationship__c');
		ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Account__c', null, contactToCRMap);
	}
}