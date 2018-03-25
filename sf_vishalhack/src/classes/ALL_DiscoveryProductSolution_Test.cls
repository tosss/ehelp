@IsTest
public class ALL_DiscoveryProductSolution_Test {   
    
     @Testsetup
    public static void setupData()
    {               
        Account account=DS_TestObjects.NewAccount_Inserted();        
        Opportunity opportunity = DS_TestObjects.NewOpportunity();        
        opportunity.AccountId = account.Id;               
        insert opportunity;
        Id siteRTId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();        
        Opportunity_Location__c location = [SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId= :siteRTId And Opportunity__c= :opportunity.Id AND Site__c= :account.Id] ;
        
        CDK_Solution_Definition__c discoverySolution = new CDK_Solution_Definition__c();
        discoverySolution.Active__c = true;
        discoverySolution.Application_Area__c = 'Marketing';
        discoverySolution.Vendor__c = 'Test Vendor';
        discoverySolution.Dealership_Area__c = 'Front End';
        insert discoverySolution;
        
        Third_Party_Solution_Definition__c tpsd = new Third_Party_Solution_Definition__c();
        tpsd.Access_Type__c = 'Access';
        tpsd.Application_Area__c = 'Application Area';
        tpsd.Application_Name__c = 'App Name';
        tpsd.Business_Area__c = 'Business Area';        
        tpsd.Status__c = 'Sold';
        tpsd.Vendor__c = 'Vendor';
        insert tpsd;
        
        Solution_at_Site__c sas = new Solution_at_Site__c();
        sas.Current__c = true;
        sas.CDK_Solution_Definition__c = discoverySolution.Id;
        sas.Notes_Comments__c = 'notes';
        sas.Opportunity_Location__c = location.Id;
        sas.Solution_Status__c = 'Sold';
        insert sas;
        
        Discovery_Product_Definition__c dpd = new Discovery_Product_Definition__c();
        dpd.Active__c = true;
        dpd.Name = 'Sample Product';
        dpd.Department__c = 'Front End';
        dpd.Workflow__c = 'Accounting';
        insert dpd;
        
        Product_at_Site__c pas = new Product_at_Site__c();
        pas.Active__c = true;
        pas.Discovery_Product_Definition__c = dpd.Id;
        pas.Current__c = true;
        pas.Notes__c = 'sample notes';
        pas.Opportunity_Location__c = location.Id;
        insert pas;
    }
    
    public static testmethod void fetchAndSaveSolution()
    {
        Opportunity_Location__c location = [
            Select Id 
            From Opportunity_Location__c 
            Limit 1
        ];
        ApexPages.currentPage().getParameters().put('OppLocId',location.Id);        
        List<ALL_DiscoveryProductSolution_Controller.ALL_solutionsWrapper> wrapper = ALL_DiscoveryProductSolution_Controller.getRecords(); 
        for(ALL_DiscoveryProductSolution_Controller.ALL_solutionsWrapper tempWrapperObject : wrapper){
            tempWrapperObject.isChecked = true;
        }
        ALL_DiscoveryProductSolution_Controller.solutionsWrapper = wrapper;
        ALL_DiscoveryProductSolution_Controller.SaveSolution();        
        List<Solution_At_Site__c> tpsList = [
            Select Id 
            From Solution_At_Site__c
            Limit 1
        ];
        //There must be a record in TPS after saving tps above
        system.assertNotEquals(0, tpsList.size());
        ALL_DiscoveryProductSolution_Controller.saveOtherSolution((string)location.Id, 'Solution Name', 'Vendor Name', false, true, false, 'Notes');
        ALL_DiscoveryProductSolution_Controller.getRecords();
        Solution_at_Site__c sas = [
            Select Id 
            From Solution_at_Site__c 
            Limit 1
        ];
        ALL_DiscoveryProductSolution_Controller.deleteTPS(sas.Id, location.Id);
        tpsList = [
            Select Id 
            From Solution_At_Site__c
            Limit 1
        ];
        //There must be one record after excuting above delete TPS
        system.assertEquals(1, tpsList.size());
    }                      
    
    public static testmethod void fetchAndSaveProducts()
    {
        Opportunity_Location__c location = [
            Select Id 
            From Opportunity_Location__c 
            Limit 1
        ];
        ApexPages.currentPage().getParameters().put('OppLocId',location.Id);        
        List<ALL_DiscoveryProductSolution_Controller.ALL_solutionsWrapper> wrapper = ALL_DiscoveryProductSolution_Controller.getProducts(); 
        for(ALL_DiscoveryProductSolution_Controller.ALL_solutionsWrapper tempWrapperObject : wrapper){
            tempWrapperObject.isChecked = true;
        }
        ALL_DiscoveryProductSolution_Controller.solutionsWrapper = wrapper;
        ALL_DiscoveryProductSolution_Controller.SaveProduct();        
        ALL_DiscoveryProductSolution_Controller.getProducts();
        Product_at_Site__c discoveryProduct = [
            Select Id 
            From Product_at_Site__c 
            Limit 1
        ];
        
        ALL_DiscoveryProductSolution_Controller.deleteProduct(discoveryProduct.Id,location.Id);
        List<Product_at_Site__c> productList = [
            Select Id 
            From Product_at_Site__c
            Limit 1
        ];
        //There must be one record after excuting above delete product
        system.assertNotEquals(1, productList.size());
                
        ALL_DiscoveryProductSolution_Controller.saveOtherProduct((string)location.Id,'Test Product',
                                        true, false, false, 'testing notes');
        ALL_DiscoveryProductSolution_Controller.getProducts();
    }  

}