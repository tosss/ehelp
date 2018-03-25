public class DS_TestContactBeforeDelete {

	testMethod static void testContactBeforeDelete(){
    	Account acct = new Account(Name='Test Delete Contact Account');
    	insert acct;
    	Contact c = new Contact();
    		c.FirstName = 'Joe';
    		c.LastName = 'Perillo';
    		c.Department__c = 'Service';
    		c.Title__c ='Manager';
    		c.AccountId=acct.Id;
    		c.Primary_Contact__c = true;
               c.Role__c = 'Test Role'; // 9/29
    	insert c;    
 
 		delete c;
 				
	}
}