@IsTest
public class DS_CompetitiveProductsExtension_Test
{
    public static testmethod void Test()
    {
    	Account a = DS_TestObjects.NewAccount_Inserted();
    	
    	ADP_Product_Solution__c ProductSolution = new ADP_Product_Solution__c();
    	ProductSolution.Name = 'Test Product Solution';
    	ProductSolution.ADP_Product_Solution_ID__c = 100;
    	insert ProductSolution;
    	
    	List<Competitive_Vendor__c> CompetitiveVendors = new List<Competitive_Vendor__c>();
    	for(Integer i=0; i<5; i++) {
			CompetitiveVendors.add(new Competitive_Vendor__c(
				ADP_Product_Solution__c = ProductSolution.Id, 
				Competitive_Vendor_Name__c = 'Test Vendor Name ' + String.valueOf(i)
			));
		}
		insert CompetitiveVendors;
    	
    	Competitive_Products_At_Dealership__c CompetitiveProducts = new Competitive_Products_At_Dealership__c();
    	CompetitiveProducts.Account__c = a.Id;
    	CompetitiveProducts.ADP_Product_Name__c = ProductSolution.Id;
    	CompetitiveProducts.Competitive_Vendor__c = CompetitiveVendors[0].Id;
    	insert CompetitiveProducts;
    	
    	PageReference pg = Page.DS_CompetitiveProductsAtDealership_Edit;
        pg.getParameters().put('id',CompetitiveProducts.Id);
        Test.setCurrentPage(pg);
        Test.startTest();
        
        ApexPages.StandardController ctrlr = new ApexPages.StandardController(CompetitiveProducts);
        DS_CompetitiveProductsExtension CompetitiveProductsExtension = new DS_CompetitiveProductsExtension(ctrlr);
        CompetitiveProductsExtension.SaveAndNew();
    }
}