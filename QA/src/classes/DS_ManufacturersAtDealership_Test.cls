//2016-01-11- anirudh.singh@cdk.com- Created this test class for the handler class DS_ManufacturersAtDealership_Handler.
@isTest
public class DS_ManufacturersAtDealership_Test
{
    @TestSetup
    private static void setupData()
    {
        Account acc=new Account();
        acc.Name='testAccount';
        insert acc;
        
        Manufacturer__c manfRec=new Manufacturer__c();
        manfRec.Segment_Code__c='AUTG';
        insert manfRec;
    }
    
    private static testMethod void testCompositeExtIdNegative()
    {
        DS_ManufacturersAtDealership_Handler.createCompositeId(Null, Null);
    }
    
    private static testMethod void testCompositeExtIdAfterInsert()
    {
        Account acc=[SELECT Id From Account];
        
        Manufacturer__c manf=[SELECT Id From Manufacturer__c];
        
        test.startTest();
        Manufacturer_At_Dealership__c mdRec=new Manufacturer_At_Dealership__c();
        mdRec.Account__c=acc.Id;
        mdRec.Manufacturer__c=manf.Id;
        insert mdRec;
        
        //Invoking the Handler method after inserting the record.
        List<Manufacturer_at_Dealership__c> manufAtDealershipList=new List<Manufacturer_at_Dealership__c>();
        manufAtDealershipList.add(mdRec);
        
        DS_ManufacturersAtDealership_Handler.createCompositeId(manufAtDealershipList, Null);
        
        //Checking if the value of the Composite Id is not Null.
        Manufacturer_At_Dealership__c updatedManufAtDealershipList=[SELECT CompositeExtID__c, Id FROM Manufacturer_at_Dealership__c];
        
        system.assert(updatedManufAtDealershipList.CompositeExtID__c!=Null);
        test.stopTest();
    }
    
    private static testMethod void testCompositeExtIdAfterUpdate()
    {
        Account acc=[SELECT Id From Account];
        
        Manufacturer__c manf=[SELECT Id From Manufacturer__c];
        
        test.startTest();
        Manufacturer_At_Dealership__c mdRec=new Manufacturer_At_Dealership__c();
        mdRec.Account__c=acc.Id;
        mdRec.Manufacturer__c=manf.Id;
        insert mdRec;
        
        //Holding the Composite Id of the record inserted in oldCompositeIdValue.
        Manufacturer_At_Dealership__c compositeIdUpdatedRecord=[SELECT CompositeExtID__c, Id FROM Manufacturer_at_Dealership__c];
        String oldCompositeIdValue=compositeIdUpdatedRecord.CompositeExtID__c;
        
        Map<Id, Manufacturer_at_Dealership__c> recordsWithOldValuesMap=new Map<Id, Manufacturer_at_Dealership__c>();
        recordsWithOldValuesMap.put(mdRec.Id, mdRec);
        
        //Change the Manufacturer value of the Manufacturer_At_Dealership__c record.
        Manufacturer__c manfRec=new Manufacturer__c();
        manfRec.Segment_Code__c='NAAT';
        insert manfRec;
        
        mdRec.Manufacturer__c=manfRec.Id;
        update mdRec;
        
        //Holding the Composite Id of the record updated in newCompositeIdValue.
        Manufacturer_At_Dealership__c newCompositeIdUpdatedRecord=[SELECT CompositeExtID__c, Id FROM Manufacturer_at_Dealership__c];
        String newCompositeIdValue=newCompositeIdUpdatedRecord.CompositeExtID__c;
        
        //Invoking the Handler method after inserting the record.
        List<Manufacturer_at_Dealership__c> recordsWithNewValues=new List<Manufacturer_at_Dealership__c>();
        recordsWithNewValues.add(mdRec);
        
        DS_ManufacturersAtDealership_Handler.createCompositeId(recordsWithNewValues, recordsWithOldValuesMap);
        
        system.assert(oldCompositeIdValue!=newCompositeIdValue);
        test.stopTest();
    }
}