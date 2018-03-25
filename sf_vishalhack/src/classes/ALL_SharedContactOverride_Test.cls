@IsTest
public class ALL_SharedContactOverride_Test {
  @Testsetup
    public static void setupData()
    {
        Account account = DS_TestObjects.NewAccount_Inserted();
        Contact contact = DS_TestObjects.NewContact_Inserted();
        contact.AccountId = account.Id;   
        update contact;
        /*Contact_Relationship__c contactRelationship = new Contact_Relationship__c();
        contactRelationship.Account__c = account.Id;
        contactRelationship.Contact__c = contact.Id;
        contactRelationship.Status__c = 'Active';
        contactRelationship.Role__c = 'Accountant';
        insert contactRelationship;*/
        
    }
    
    public static testmethod void testSharedContacts()
    {               
        Account account = [select id,name from Account limit 1];
        Contact contact = [select id,firstname,lastname,Email,AccountId from Contact limit 1];         
        ApexPages.StandardController standardController = new ApexPages.StandardController(contact);        
        ALL_SharedContactOverride_Controller controller = new ALL_SharedContactOverride_Controller(standardController); 
        Test.setCurrentPageReference(new PageReference('Page.ShareContactOverride'));
        System.currentPageReference().getParameters().put('id', contact.Id);
        System.currentPageReference().getParameters().put('retURL', '003');
        System.currentPageReference().getParameters().put('recordId', account.Id);        
        controller.RedirectPage();
        System.currentPageReference().getParameters().put('id', null);
        System.currentPageReference().getParameters().put('retURL', null);
        controller.RedirectPage();
        
    }
}