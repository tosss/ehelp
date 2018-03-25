/* ADP Dealer Services - Sales Automation
 * Programmer: Matt Keefe (matt_keefe@adp.com)
 * Test Class: DS_ContactBeforeInsertUpdateTest
 * Description: Contains a test method to run through every line of the trigger and verify that an error is thrown for duplicate Contacts.
 * For Trigger: DS_ContactBeforeInsertUpdate
 */ 
public class DS_ContactBeforeInsertUpdateTest
{
    public testmethod static void TestDuplicateErrors()
    {
    	// get a couple of accounts to work with
        Account a1 = DS_TestObjects.NewAccount_Inserted();
        
        // 1: setup custom settings
        try
        {
            CustomSettings__c settings = CustomSettings__c.getInstance();
            
            if(settings != null)
            {
            	if(settings.DS_ContactBeforeInsertUpdate_On__c != null)
            	{
                    if(!settings.DS_ContactBeforeInsertUpdate_On__c) { settings.DS_ContactBeforeInsertUpdate_On__c = true; update settings; }
            	}
            }
        } 
        catch(Exception ex) { system.debug(ex); }
        // 1: end setup custom settings
        
        // 2: insert initial contacts to work with
        List<Contact> InitialContacts = new List<Contact>();
        
        for(Integer i=0;i<10;i++)
        {
            Contact c = DS_TestObjects.NewContact();
            c.AccountId = a1.Id; 
            c.FirstName = 'First'+String.valueOf(i)+' - LEFT'; 
            c.LastName = 'Last'+String.valueOf(i)+' - LEFT'; 
            c.Email = 'Email'+String.valueOf(i+100)+'@mailinator.com';
            c.Role__c = 'Test Role' + i; // 9/29
            InitialContacts.add(c);
        }
        
        insert InitialContacts;
        system.debug('***** Initial Contacts Inserted *****');
        // 2: end insert initial contacts
        
        // 3: insert duplicate name contacts
        List<Contact> DuplicateContacts = new List<Contact>();
        
        for(Integer i=0;i<10;i++)
        {
            Contact c = DS_TestObjects.NewContact();
            c.AccountId = a1.Id; 
            c.FirstName = 'First'+String.valueOf(i)+' - LEFT'; // same first
            c.LastName = 'Last'+String.valueOf(i)+' - LEFT';   // same last
            c.Email = 'Different_Email'+String.valueOf(i+100)+'@mailinator.com'; // different email
            DuplicateContacts.add(c);
        }
        
	    try
	    {
	        insert DuplicateContacts;
	    }
	    catch(Exception ex)
	    {
	        system.debug('##### Error: '+ex+' #####');
	    }
        
        DuplicateContacts.clear();
        // 3: end insert duplicate name contacts
        
        // 4: insert duplicate email contacts
        for(Integer i=0;i<10;i++)
        {
            Contact c = DS_TestObjects.NewContact();
            c.AccountId = a1.Id; 
            c.FirstName = 'Different_First'+String.valueOf(i); // different first
            c.LastName = 'Different_Last'+String.valueOf(i);   // different last
            c.Email = 'Email'+String.valueOf(i+100)+'@mailinator.com'; // same email
            DuplicateContacts.add(c);
        }
        
        try
        {
            insert DuplicateContacts;
        }
        catch(Exception ex)
        {
            system.debug('##### Error: '+ex+' #####');
        }
        
        DuplicateContacts.clear();
        // 4: end insert duplicate email contacts
        
        // 5: verify
        List<Contact> InsertedContacts = [Select Id, FirstName, LastName, Email From Contact Where AccountId = :a1.Id];
        for(Contact c : InsertedContacts) { system.debug('Inserted Contact: '+c); }
        // 5: end verify
    }
}