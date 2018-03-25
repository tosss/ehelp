//2017-03-20 ragashalini.koka@cdk.com  - Created this class
@isTest
public class Layout_Test {
    
    public class MultiHttpMockForLayout implements HttpCalloutMock {
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
           System.debug('received request : ' + req.getEndpoint());
            //sample data set to send the response for Account_Contract Object
            if(req.getEndpoint().containsIgnoreCase('CustomObject')) {
                res.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"CustomObject",' +
                            '"records":[{"attributes":{"type":"CustomObject",' +
                            '"url":"/services/data/v34.0/tooling/sobjects/CustomObject/01I400000005kk4EAA"},"Id":"01I400000005kk4EAA"}]}');
            }
            else if(req.getEndpoint().containsIgnoreCase('Layout')) {
                res.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"Layout",' +
                    '"records":[{"attributes":{"type":"Layout","url":"/services/data/v34.0/tooling/sobjects/Layout/00h40000001OK72AAG"},' +
                        '"Id":"00h40000001OK72AAG","Name":"Account Contract Layout"}]}');
            }
          
            return res;
        }
        
    }
    
    private testmethod static void validateLayouts() {
        Test.startTest();
        Layouts layoutObj = new Layouts(null);
        Test.setMock(HttpCalloutMock.class, new Layout_Test.MultiHttpMockForLayout());
        Layouts.getData('Account_contracts__c');
        Test.stopTest();
    }
    
    
    
}