/*----------------------------------------------------------------------
 * RQ-06982
 * Unknown - created this class  
 * Description: Trigger on Launch Object
 * ---------------------------MODIFICATIONS-----------------------------
 * 2016-05-19 - lalitha.adduru@cdk.com - added logic to populate contact relationship when account or contact is updated -  RQ-06982 
 * 2016-06-28 - vijay.manimaran@cdk.com - added isInsert to the condition. 
 * 2016-06-28 - vijay.manimaran@cdk.com code formatted and added Header comments.
  ------------------------------------------------------------------------*/

trigger ALL_Launch on Launch__c(before insert, after insert, before update, after update)
{
	list<Launch__c> IntegrationUserDuckedList = ALL_TriggerToggle_Handler.ProfileFilter(trigger.new, 'Launch__c');

	if (!IntegrationUserDuckedList.isEmpty())
	{
		if (Trigger.isAfter && (ALL_CheckRecursive.runCodeBlockOnce('runOnlyOnceToavoidDuplicateCases') || Test.isRunningTest()))
		{
			DS_Launch_Handler.processLaunch2CaseLogic();
		}

		if (Trigger.isBefore && (ALL_CheckRecursive.runCodeBlockOnce('runOnlyOnceToUpdateLaunch') || Test.isRunningTest()))
		{
			if (Trigger.isUpdate || Trigger.IsInsert)
			{
				//2016-05-19 - lalitha.adduru@cdk.com - RQ-06982
				//2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
				Map<String, String> contactToCRMap = new Map<String, String> ();
				contactToCRMap.put('Contact__c', 'Contact_Name_Relationship__c');
				contactToCRMap.put('Inventory_Contact_Name__c', 'Inventory_Contact_Name_Relationship__c'); //2016-06-09 Vijay added 
				ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Account__c', null, contactToCRMap);
			}
			DS_Launch_Handler.CB_LaunchUpdateEmails();
		}
	}
}