/*
*	@test for ContactUpdateTriggerUpdates.
*	@Author		: Jeremy Mooer
*	@Date		: 21 Oct 2011
*/

@isTest
private class ContactUpdateTriggerUpdatesTest {
	
	
	
	//no bulkification test necessary.
	static testMethod void onUpdateCheckStatusAndUpdateRelatedValuesTest() 
	{
    	Account accountTest = new Account(Name = 'AccountTest') ;
    	insert accountTest ;
    	
        Contact contactInactiveStatus 	= new Contact(AccountId=accountTest.Id, Status__c='Inactive', No_Longer_There__c=true, FirstName='Test', LastName='Test', Email='email@email.com', Role__c='Test Role') ; // 9/29
        Contact contactAtiveStatus 		= new Contact(AccountId=accountTest.Id, Status__c='Active', No_Longer_There__c=false, FirstName='Test', LastName='Test2', Email='email2@email.com', Role__c='Test Role') ; // 9/29
        Contact contactNoLongerThere 	= new Contact(AccountId=accountTest.Id, Status__c='Inactive', No_Longer_There__c=true, FirstName='Test', LastName='Test3', Email='email3@email.com', Role__c='Test Role') ; // 9/29
        Contact contactNotNoLongerThere	= new Contact(AccountId=accountTest.Id, Status__c='Active', No_Longer_There__c=false, FirstName='Test', LastName='Test4', Email='email4@email.com', Role__c='Test Role') ; // 9/29
        
        Contact[] contactsToInsertAndUpdate = new Contact[]{contactInactiveStatus, contactAtiveStatus, contactNoLongerThere, contactNotNoLongerThere} ; 
        insert contactsToInsertAndUpdate;
        
        Set<String> idSet = new Set<String>{contactInactiveStatus.Id, contactAtiveStatus.Id, contactNoLongerThere.Id, contactNotNoLongerThere.Id} ;
		
		contactInactiveStatus.Status__c = 'Active';
		contactAtiveStatus.Status__c = 'Inactive';
		contactNoLongerThere.No_Longer_There__c = false;
		contactNotNoLongerThere.No_Longer_There__c = true;
		
		
		test.startTest();
		update contactsToInsertAndUpdate;
		test.stopTest();
		
		for(Contact contactUpdated : [select id, Status__c, No_Longer_There__c from Contact where id in :idSet]) {
			if(contactUpdated.No_Longer_There__c == false) {
				system.assertEquals('Active', contactUpdated.Status__c);
			}
			else if(contactUpdated.No_Longer_There__c == true) {
				system.assertEquals('Inactive', contactUpdated.Status__c);
			}
		}
		
		
	}
	
	
}