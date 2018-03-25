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
        //insert c;    
        //2016-06-15 sanjay.ghanathey@cdk.com remove role and move it to CR
        // ALL_SharedContact_Helper.insertContact(c,'Test Role',null,null);
        Map<String, ALL_SharedContact_Helper.duplicateCheckWrapper>  insertContactMap 
            = ALL_SharedContact_Helper.InsertContact(c,'Test Role',Null,'');
        
        ALL_SharedContact_Helper.duplicateCheckWrapper results = insertContactMap.get('Contact');        
        //delete c; 
        List<Contact> ids = new List<Contact>();
        if(results.existingRecordIdToNewRecordMap.size() >0)
        {
            for(Id contactIds : results.existingRecordIdToNewRecordMap.keySet())
            {
                Contact tempObject = (Contact)results.existingRecordIdToNewRecordMap.get(contactIds);
                ids.add(tempObject);                   
            }
        }
        else // this is to get the newly created contact Id - using returnedContactId
        {
            List<Contact> contacts = [select id from Contact where id=:results.insertedRecordIds];
            ids.addAll(contacts);
        }
        delete ids;        
    }
}