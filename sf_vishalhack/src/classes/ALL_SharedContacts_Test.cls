//2017-04-10 ragashalini.koka@cdk.com - Added changeRecordTypeId method to improve the code coverage
@IsTest
public class ALL_SharedContacts_Test {
	@Testsetup
	public static void setupData()
	{
		Account account = DS_TestObjects.NewAccount_Inserted();
		Contact contact = DS_TestObjects.NewContact_Inserted();
		contact.AccountId = account.Id;
		update contact;
		ALL_SharedContact_Helper.InsertContact(contact, 'CEO', Null, '');

	}

	public static testmethod void testSharedContacts()
	{
		Account account = [select id, name from Account limit 1];
		Contact contact = [select id, firstname, lastname, Email, AccountId from Contact limit 1];

		Contact_Relationship__c contactRelationship = new Contact_Relationship__c();
		contactRelationship.Role__c = 'Accountant';
		contactRelationship.Account__c = account.Id;

		ApexPages.StandardController standardController = new ApexPages.StandardController(contactRelationship);
		ALL_SharedContacts_Controller controller = new ALL_SharedContacts_Controller(standardController);
		controller.getRecordTypes();
		controller.recordType = [Select Id From RecordType Where Name = :'Internal HR Contact' Limit 1].Id;
		controller.ContactRelationship = contactRelationship;
		controller.CurrentContact.FirstName = contact.FirstName;
		controller.CurrentContact.LastName = contact.LastName;
		controller.CurrentContact.Email = contact.Email;
		controller.CurrentContact.AccountId = account.Id;
		controller.duplicateCheck();
		controller.editPage();
		controller.cancel();
		controller.ContactRelationship.Account__c = account.Id;
		controller.CreateContactRelationship();

	}

	public static testmethod void testSharedContactsWithPageParams()
	{
		Account account = [select id, name from Account limit 1];
		Contact contact = [select id, firstname, lastname, Email, AccountId from Contact limit 1];

		Contact_Relationship__c contactRelationship = new Contact_Relationship__c();
		contactRelationship.Role__c = 'Accountant';
		contactRelationship.Account__c = account.Id;

		Contact_Relationship__c cr = [select Id, Account__c from Contact_Relationship__c limit 1];
		Apexpages.currentpage().getparameters().put('accountId', account.Id);
		Apexpages.currentpage().getparameters().put('CRId', cr.Id);

		ApexPages.StandardController standardController = new ApexPages.StandardController(contactRelationship);
		ALL_SharedContacts_Controller controller = new ALL_SharedContacts_Controller(standardController);
		controller.getRecordTypes();
		controller.recordType = [Select Id From RecordType Where Name = :'Internal HR Contact' Limit 1].Id;
		controller.ContactRelationship = contactRelationship;
		controller.CurrentContact.FirstName = contact.FirstName;
		controller.CurrentContact.LastName = contact.LastName;
		controller.CurrentContact.Email = contact.Email;
		controller.CurrentContact.AccountId = account.Id;
		controller.duplicateCheck();
		controller.editPage();
		controller.cancel();
		controller.ContactRelationship.Account__c = account.Id;
		controller.CreateContactRelationship();
	}

	public static testmethod void testSharedContactsForCancel()
	{
		Account account = [select id, name from Account limit 1];
		Contact contact = [select id, firstname, lastname, Email, AccountId from Contact limit 1];

		Contact_Relationship__c contactRelationship = new Contact_Relationship__c();
		contactRelationship.Role__c = 'Accountant';
		contactRelationship.Account__c = account.Id;

		Contact_Relationship__c cr = [select Id, Account__c from Contact_Relationship__c limit 1];
		Apexpages.currentpage().getparameters().put('accountId', account.Id);
		Apexpages.currentpage().getparameters().put('CRId', cr.Id);
		Apexpages.currentpage().getparameters().put('isCancel','true');		
		ApexPages.StandardController standardController = new ApexPages.StandardController(contactRelationship);
		ALL_SharedContacts_Controller controller = new ALL_SharedContacts_Controller(standardController);
		controller.getRecordTypes();
		controller.recordType = [Select Id From RecordType Where Name = :'Internal HR Contact' Limit 1].Id;
		controller.ContactRelationship = contactRelationship;
		controller.CurrentContact.FirstName = contact.FirstName;
		controller.CurrentContact.LastName = contact.LastName;
		controller.CurrentContact.Email = contact.Email;
		controller.CurrentContact.AccountId = account.Id;
		controller.duplicateCheck();		
	}
    
    private static testmethod void changeRecordTypeId() 
    {
        Test.startTest();
        Account account = [select id, name from Account limit 1];
		Contact contact = [select id, firstname, lastname, Email, AccountId from Contact limit 1];
        String recordTypeCDKOEMId = [Select Id FROM RecordType Where Name = 'CDK OEM/Brand' And SobjectType = 'Contact' LIMIT 1].Id;
		
        Contact_Relationship__c contactRelationship = new Contact_Relationship__c();
		contactRelationship.Role__c = 'Accountant';
		contactRelationship.Account__c = account.Id;

		Contact_Relationship__c cr = [select Id, Account__c from Contact_Relationship__c limit 1];
		Apexpages.currentpage().getparameters().put('accountId', account.Id);
		Apexpages.currentpage().getparameters().put('CRId', cr.Id);
		Apexpages.currentpage().getparameters().put('recordId', recordTypeCDKOEMId);
        
		ApexPages.StandardController standardController = new ApexPages.StandardController(contactRelationship);
		ALL_SharedContacts_Controller controller = new ALL_SharedContacts_Controller(standardController);
        Test.stopTest();
        
    }
}