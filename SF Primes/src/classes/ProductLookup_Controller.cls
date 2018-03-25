public class ProductLookup_Controller {
    
    @AuraEnabled
    public static List<SObject> getProductsData(Integer catalogNo, String country) {
        country = country.toUpperCase();
        return [
            		SELECT Id, Name, Auto__c, Description__c, Catalog_Description__c, List_Price__c, Section_Description__c, Catalog__c
            		FROM Product_Lookup__c
            		WHERE Catalog__c = :catalogNo AND Country__c = :country
               ];
    }
    
    @AuraEnabled 
    public static List<SObject> getRecordDetails(String recId) {
        
        return [
            SELECT Id, Catalog__c, Catalog_Description__c, Freight__c, Monthlies__c, Installs__c,
            System_Integration_Fee__c, Consulting_Fee__c, List_Price__c, Monthly_ASP_Fees__c,
            Update_Fee__c, Auto__c, Truck__c, Heavy_Equipment__c, Rental__c, Maintainence_Only__c,
            Flat_QC__c 
            FROM Product_Lookup__c 
            WHERE Id = :recId
            
        ];
    }
   
}