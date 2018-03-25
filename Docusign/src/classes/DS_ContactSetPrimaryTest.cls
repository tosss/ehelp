public class DS_ContactSetPrimaryTest {
    testMethod static void testContactSetPrimary(){
    	Account acct = new Account(Name='John');
    	insert acct;
    	Contact c = new Contact();
    		c.FirstName = 'Joe';
    		c.LastName = 'Perillo';
    		c.Department__c = 'Service';
    		c.Title__c='Manager';
    		c.AccountId=acct.Id;
    		c.Primary_Contact__c = true;
               c.Role__c = 'Test Role'; // 9/29
    	insert c;    
    	Contact d = new Contact();
    		d.FirstName = 'Frank';
    		d.LastName = 'Perillo';
    		d.Department__c = 'Service';
    		d.Title__c='Manager';
    		d.AccountId=acct.Id;
    		d.Primary_Contact__c = true;
               d.Role__c = 'Test Role'; // 9/29
    	insert d;   	
    }
    
}