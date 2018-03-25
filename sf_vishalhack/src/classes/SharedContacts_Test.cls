@IsTest
public class SharedContacts_Test {
    /* 2016-06-30 matt.keefe@cdk.com - moved to ALL_SharedContacts_Test
    @Testsetup
    public static void setupData()
    {
        Account account = DS_TestObjects.NewAccount_Inserted();
        Contact contact = DS_TestObjects.NewContact_Inserted();
        contact.AccountId = account.Id;   
        update contact;
        //Contact_Relationship__c contactRelationship = new Contact_Relationship__c();
        //contactRelationship.Account__c = account.Id;
        //contactRelationship.Contact__c = contact.Id;
        //contactRelationship.Status__c = 'Active';
        //contactRelationship.Role__c = 'Accountant';
        //insert contactRelationship;
    }
    
    public static testmethod void testSharedContacts()
    {               
        Account account = [select id,name from Account limit 1];
        Contact contact = [select id,firstname,lastname,Email,AccountId from Contact limit 1];                
        
        Contact_Relationship__c contactRelationship = new Contact_Relationship__c(); 
        contactRelationship.Role__c = 'Accountant';
        contactRelationship.Account__c = account.Id;
        
        ApexPages.StandardController standardController = new ApexPages.StandardController(contactRelationship);        
        SharedContacts_Controller controller = new SharedContacts_Controller(standardController);   
        controller.getRecordTypes();
        controller.recordType = [Select Id From RecordType Where Name =:'Internal HR Contact' Limit 1].Id;
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
    */
}