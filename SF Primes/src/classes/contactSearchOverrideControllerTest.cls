@isTest
private class contactSearchOverrideControllerTest {

    public static testMethod void testController() {
    	List<Contact> cc = new List<Contact>();
    	
    	Account a = new Account(Name = 'test account');
    	insert a;
    	
        Contact c1 = new Contact(FirstName = 'test', LastName = 'last', Email = 'test1@test.com', AccountId = a.Id, Role__c='Test Role'); // 9/30
        cc.add(c1);
        
        Contact c2 = new Contact(FirstName = 'test', LastName = 'first', Email = 'test2@test.com', AccountId = a.Id, Role__c='Test Role');// 9/29
        cc.add(c2);
        
        insert cc;
        
        PageReference pageRef = Page.contactSearchOverride;
		Test.setCurrentPage(pageRef);
		List<Id> tempIds = new List<Id>();
		tempIds.add(c1.Id);
		Test.setFixedSearchResults(tempIds);
		test.startTest();
		contactSearchOverrideController csoc = new contactSearchOverrideController(new ApexPages.StandardController(c1));
		csoc.contactResultsList = new List<Contact>();
		csoc.fName = '';
		csoc.lName = '';
		csoc.email = '';
		
		csoc.searchExisting();
		csoc.newContact();
		
		csoc.email = 'test2@test.com';
		csoc.searchExisting();
		
		csoc.fName = 'a';
		csoc.lName = 'b';
		csoc.email = 'c';
		csoc.searchExisting();
		
		test.stopTest();
		
		system.assertEquals(1, csoc.contactResultsList.size());
    }
}