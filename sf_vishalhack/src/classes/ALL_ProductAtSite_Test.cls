/*--------------------------------------------------------
 * 2016-12-07 -venkata.shrivol@cdk.com -Created 
 * Description - Test class for ALL_ProductAtSite_Handler
 * 
----------------------------------------------------------*/
@isTest
public class ALL_ProductAtSite_Test 
{
    @testSetup static void prepareTestData()
    {
       
        //customSettings
        ALL_DiscoveryProducts__c adp = new ALL_DiscoveryProducts__c();
        adp.Name = 'ACCOUNTING';
        adp.Related_Product_Names__c='CVR, VIRTUAL BILLER';
        insert adp;
        
        Account testAccount = IMP_TestFactory_Helper.buildAccount();
        testAccount.Name = 'Discovery app test';
        insert testAccount;
        
        Opportunity testOpp = IMP_TestFactory_Helper.buildOpportunity();
        testOpp.AccountId = testAccount.Id;
        insert testOpp;  
        
        list<Discovery_Product_Definition__c> dpdlist = new list<Discovery_Product_Definition__c>();
        Discovery_Product_Definition__c dfd = new Discovery_Product_Definition__c();
        dfd.Name = 'ACCOUNTING';
        dfd.Department__c = 'Dealer Ops';
        dfd.Workflow__c = 'Accounting';
        dpdlist.add(dfd);
        
        Discovery_Product_Definition__c dfd2 = new Discovery_Product_Definition__c();
        dfd2.Name = 'CVR';
        dfd2.Department__c = 'Dealer Ops';
        dfd2.Workflow__c = 'Accounting';
        dpdlist.add(dfd2);
        insert dpdlist;
        
        string siteRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Site');
        system.debug(siteRecordTypeId);
        
        Opportunity_Location__c siteLocation = null;
        list<Opportunity_Location__c> siteLocations = [
            SELECT Id FROM Opportunity_Location__c 
            WHERE RecordTypeId= :siteRecordTypeId 
            And Opportunity__c= :testOpp.Id 
            AND Site__c= :testAccount.Id
        ];
        
        if(!siteLocations.isEmpty()) { 
            siteLocation = siteLocations.get(0); 
        }
        else {
            siteLocation = new Opportunity_Location__c(RecordTypeId = siteRecordTypeId);
            siteLocation.Opportunity__c = testOpp.Id;
            siteLocation.Site__c = testAccount.Id;
            insert siteLocation;
        }
        
    }
    
    static testMethod void testOnInsert()
    {
    	list<Opportunity_Location__c> insertedList = [select Id from Opportunity_Location__c where RecordType.Name = 'Site'];
        Opportunity_Location__c thisOppLoc = insertedList.size() > 0 ? insertedList.get(0) : new Opportunity_Location__c();
        Test.startTest();
            list<Discovery_Product_Definition__c> dpdlist = [ select Id from Discovery_Product_Definition__c where Name='CVR'];
            Discovery_Product_Definition__c cvrProduct = dpdlist.size() > 0 ? dpdlist.get(0) : new Discovery_Product_Definition__c();
            
            Product_at_Site__c pas = new Product_at_site__c();
            pas.Discovery_Product_Definition__c= cvrProduct.Id;
        	pas.Opportunity_Location__c = thisOppLoc.Id;
        	pas.Current__c = true;
        	pas.Include_Questions__c = true;
        	insert pas;
        	
        	list<Product_at_Site__c> pasSites = [select Id, Product_definition_name__c, Include_Questions__c 
                       from Product_at_Site__c 
                       where Opportunity_Location__c = :thisOppLoc.Id
                       and Product_definition_name__c = 'ACCOUNTING'
              ];
        	system.assertEquals(1, pasSites.size(), 'Related product did not get created');
        	Product_at_Site__c retrievedProduct = pasSites.size() > 0 ? pasSites.get(0) : new Product_at_Site__c();
        	system.assert(retrievedProduct.Include_Questions__c, 'Related product did not get created in testOnInsert Method');
        Test.stopTest();
    }

}