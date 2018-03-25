@isTest
public class LookupField_Test
{
    @TestSetup
    private static void initTestDataSet()
    {
        Contact cnt = new Contact(LastName = 'testLastName', FirstName = 'testFirstName');
        insert cnt;
    }
    
    private static testmethod void unit_test_1()
    {
        Test.startTest();
        LookupField_Controller controller = new LookupField_Controller();
        
        //nothing passed
        String result = LookupField_Controller.getCurrentValue(null, null);
        System.assert(String.isBlank(result), 'Why an actual result? '+result);
        
        //only type passed: no ID expected to be loaded
        result = LookupField_Controller.getCurrentValue('Contact', null);
        System.assert(String.isBlank(result), 'Why an actual result? '+result);
        
        //wrong type
        Contact testContact = [Select Id, Name From Contact Limit 1];
        result = LookupField_Controller.getCurrentValue('ContactERROR', testContact.Id);
        System.assert(String.isBlank(result), 'Why an actual result? '+result);
        
        //wrong ID value
        result = LookupField_Controller.getCurrentValue('Contact', 'ERROR');
        System.assert(String.isBlank(result), 'Why an actual result? '+result);
        
        //found 1 result
        result = LookupField_Controller.getCurrentValue('Contact', testContact.Id);
        System.assert(result == testContact.Name, 'Why account name mismatch? '+result);
        
        //found 0 result
        delete testContact;
        result = LookupField_Controller.getCurrentValue('Contact', testContact.Id);
        System.assert(String.isBlank(result), 'Why an actual result? '+result);
        
        
        Test.stopTest();
    }
    
    private static testmethod void unit_test_2()
    {
        Test.startTest();
        Contact testContact = [Select Id, Name From Contact Limit 1];
        //https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_testing_SOSL.htm
        Test.setFixedSearchResults(new List<ID>{testContact.Id});
        
        String result = LookupField_Controller.searchSObject(null, null);
        System.assert(String.isBlank(result), 'Why an actual result? '+result);
        
        //invalid sobject type
        result = LookupField_Controller.searchSObject('InvalidObject','test');
        System.assert(String.isBlank(result), 'Why an actual result? '+result);
        
        //found result
        result = LookupField_Controller.searchSObject('Contact', 'test');
        System.assert(String.isNotBlank(result),'Why null result?'); 
        List<LookupField_Controller.SearchResult> output = (List<LookupField_Controller.SearchResult>)JSON.deserialize(result, List<LookupField_Controller.SearchResult>.class);
        System.assert(output.size()==1,'Why not 1 result? '+result);
        System.assert(output[0].value == testContact.Name, 'Contact name mismatch: '+result);
        Test.stopTest();
    }
}