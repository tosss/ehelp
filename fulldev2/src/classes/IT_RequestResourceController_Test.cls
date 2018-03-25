@isTest
public class IT_RequestResourceController_Test {
    public static testmethod void requestResourceTest()
    {
        // set RequestResource vf page as the current page
        PageReference pageRef = Page.IT_RequestResource;
        Test.setCurrentPage(pageRef);
        
        // insert a sample Request Record to pass id as a parameter
        Request__c req = new Request__c(Name = 'TestRequest');
        insert req;
        
        // testing check for a valid id ( parameter passed in the VF page URL)
        ApexPages.currentPage().getParameters().put('id',req.id);        
        IT_RequestResource_Controller ctrl = new IT_RequestResource_Controller();
        
        // testing displaying request details after selecting a request
        ctrl.requestPopulated();
        
        // test insertion
        IT_RequestResource_Controller.saveRecord(req.id, 'Apex Page', 'RequestResource');
        
        // testing duplicacy check
        IT_RequestResource_Controller.saveRecord(req.id, 'Apex Page', 'RequestResource');
        
        // testing search for resources
        List<String> stdObjLabels = IT_RequestResource_Controller.searchObjects('StandardSObject', 'Account');
        List<String> customObjLabels = IT_RequestResource_Controller.searchObjects('CustomSObject', 'Request');
        List<Object> objList = IT_RequestResource_Controller.searchResource('ApexPage', 'RequestResource');
        
        
        // Test for an invalid id ( To improve code coverage )
        ApexPages.currentPage().getParameters().put('id','ajdjkfei'); 
        IT_RequestResource_Controller ctrl2 = new IT_RequestResource_Controller();
    }
    
}