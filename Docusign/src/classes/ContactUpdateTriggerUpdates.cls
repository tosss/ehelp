/**
*	@onUpdateCheckStatusAndUpdateRelatedValues takes new and old trigger values and keeps No_Longer_There__c and Status__c in sync.
*	@Author		: Jeremy Mooer
*	@Date		: 18 Oct 2011
*/
public with sharing class ContactUpdateTriggerUpdates {
	
	
	
	public static void onUpdateCheckStatusAndUpdateRelatedValues(Map<Id,Contact> oldContactMap, List<Contact> newList)
	{
		
		for(Contact newContact : newList)
		{
			Contact oldContact = oldContactMap.get(newContact.Id) ;
			
			if(oldContact != null)
			{
				if( newContact.Status__c == 'Inactive' && oldContact.Status__c != 'Inactive' ) {
					newContact.No_Longer_There__c = true;
				}
				
				if( newContact.Status__c == 'Active' && oldContact.Status__c != 'Active' ) {
					newContact.No_Longer_There__c = false;
				}
				
				if( newContact.No_Longer_There__c == true && oldContact.No_Longer_There__c != true ) {
					newContact.Status__c = 'Inactive';
				}
				
				if( newContact.No_Longer_There__c == false && oldContact.No_Longer_There__c != false ) {
					newContact.Status__c = 'Active';
				}
			}
			
		}
		
	}
	
	
}