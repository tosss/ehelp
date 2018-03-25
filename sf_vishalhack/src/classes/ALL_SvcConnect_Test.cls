@isTest
public class ALL_SvcConnect_Test 
{
    //1. Success
    //  a. Contact inserted, Cr created and returned
    //2. Failure
    //  a. Contact found in database. CR retrieved and returned
    //  b. Contact found in database. CR created and returned. 
    //Static RestRequest request;
   
    Static testMethod RestRequest getRestContext()
    {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ALL_SvcConnect_Service/createContact';
        request.httpMethod = 'POST';
        request.requestBody = 
            Blob.valueOf('[{"PartyId" : "15499",' +
            '"LastName" : "Tail",' +
            '"FirstName" : "Head",' +
            '"Email" : "Tail.Head@Belly41526372818.com",' +
            '"Role__c" : "Account"},' +
            
            '{"PartyId" : "15499",' +
            '"LastName" : "Rise",' +
            '"FirstName" : "Sun",' +
            '"Email" : "Sun.Raise@672728282.com",' +
            '"Role__c" : "Account"},' +
            
            '{"PartyId" : "15499",' +
            '"LastName" : "Kitty",' +
            '"FirstName" : "Cat", ' +  
            '"Email" : "Kitty.Cat@672728282.com",' +
            '"Role__c" : "Account"}]');
        
        return request;
    }
    
    Static testMethod Account getAccount()
    {
        Account newAccount = DS_TestObjects.NewAccount();
        newAccount.PartyID__c = '15499';
        insert newAccount;
        
        
        
        return newAccount;
    }
    
    Static testMethod void testForPositiveCreateContact()
    {  
        Account newAccount = getAccount();
        RestContext.request = getRestContext();
        List<ALL_SvcConnect_Service.resultObject> results = ALL_SvcConnect_Service.createContact();
        List<ALL_SvcConnect_Service.resultObject> duplicateResults = ALL_SvcConnect_Service.createContact();
        
        
        for(ALL_SvcConnect_Service.resultObject ro: results)
        {
            RestContext.request.requestBody = 
                Blob.valueOf('[{"PartyId" : "15499",' + (ro.contactRelation.Email_LGY__c == 'Tail.Head@Belly41526372818.com' ? '"Id" : "' + ro.contactRelation.Id + '",' : '') +
                             '"LastName" : "Tail",' +
                             '"FirstName" : "Head",' +
                             '"Email" : "Tail.Head@Belly41526372818.com",' +
                             '"Role__c" : "Account"},' +
                             
                             '{"PartyId" : "15499",' + (ro.contactRelation.Email_LGY__c == 'Sun.Raise@672728282.com' ? '"Id" : "' + ro.contactRelation.Id + '",' : '') +
                             '"LastName" : "Rise",' +
                             '"FirstName" : "Sun",' +
                             '"Email" : "Sun.Raise@672728282.com",' +
                             '"Role__c" : "Account"},' +
                             
                             '{"PartyId" : "15499",' + (ro.contactRelation.Email_LGY__c == 'Kitty.Cat@672728282.com' ? '"Id" : "' + ro.contactRelation.Id + '",' : '') +
                             '"LastName" : "Kitty",' +
                             '"FirstName" : "Cat", ' +  
                             '"Email" : "Kitty.Cat@672728282.com",' +
                             '"Role__c" : "Account"}]');
        }
        
        List<ALL_SvcConnect_Service.resultObject> updateResults = ALL_SvcConnect_Service.createContact();
        
        
        if(!results.isEmpty())
        {
            ALL_SvcConnect_Service.resultObject singleResult = results[0];
            Contact_Relationship__c crs = singleResult.contactRelation;
            
            RestRequest request2 = new RestRequest();
            request2.requestURI = '/services/apexrest/ALL_SvcConnect_Service/createContact/'+ crs.ID;
            request2.httpMethod = 'DELETE';
            ALL_SvcConnect_Service.deleteContact();
        }
    }
    
    Static testMethod void testForNegativeCreateContact()
    {
        Account newAccount = DS_TestObjects.NewAccount();
        newAccount.PartyID__c = '15499';
        insert newAccount;
        
        RestRequest request = getRestContext();
        request.requestBody = 
            Blob.valueOf('[{"PartyId" : "15499",' +
            '"LastName" : "Tail",' +
            '"FirstName" : "Head",' +
            '"Email" : "Tail.Head@cdk.com",' +
            '"Role__c" : "Account"}]');
        RestContext.request = request;
        List<ALL_SvcConnect_Service.resultObject> results = ALL_SvcConnect_Service.createContact();
    }
    
}