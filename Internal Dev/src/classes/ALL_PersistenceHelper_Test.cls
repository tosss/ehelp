@isTest
public with sharing class ALL_PersistenceHelper_Test {
	
    public static testmethod void testInsertObjs() 
    {
        List<Asset> assetList = new List<Asset>();
        assetList.add(new Asset(Name = 'Pending'));
        
        Test.startTest();
        ALL_PersistenceHelper.insertObjs(assetList, null);
        Test.stopTest();
        
        for (Asset e : [SELECT Id, Name FROM Asset]) {
        		System.debug(e);
        		System.assert(false); // Fail the test case
        }
        
        // At least 1 integration error record will satisfy this test case
        for (Integration_Error__c e : [SELECT Id, Error__c FROM Integration_Error__c]) {
        		return;
        }
        
        System.assert(false); // If it reaches here, it means there are no integration error records.
    }
}