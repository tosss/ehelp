//2016-01-11- anirudh.singh@cdk.com- Created this test class for the handler class DS_ManufacturersAtDealership_Handler.
@isTest
public class DS_ManufacturersAtDealership_Test
{
    @TestSetup
    private static void setupData()
    {
        Site_Type__c sType = DS_TestObjects.NewSiteType();
        sType.Active__c = true;
        sType.Name = 'Brand';
        sType.Corporation_Flag__c = true;
        sType.District_Flag__c = true;
        sType.Group_Flag__c = true;
        
        insert sType;
        
        Account acc=new Account();
        acc.Name='testAccount';
        acc.Migration_ID__c = '9000733';
        //insert acc;
        
        Account brandAccount = new Account();
        Id brandREcordTypeID = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account', 'CDK OEM/Brand');
        brandAccount.Name = 'Honda';
        brandAccount.Migration_ID__c = 'AC-Auto';
        brandAccount.RecordTypeId = brandREcordTypeID;
        brandAccount.Site_Type__c = sType.ID;
        insert new List<Account> { acc, brandAccount};
        
        Manufacturer__c manfRec=new Manufacturer__c();
        manfRec.Segment_Code__c='AUTG';
        manfRec.Ora_Manufacturers_Code__c = 'AC';
        manfRec.Subsegments__c = 'Auto';
        insert manfRec;
    }
    
    private static testMethod void testCompositeExtIdNegative()
    {
        DS_ManufacturersAtDealership_Handler.createCompositeId(Null, Null);
    }
    
    private static testMethod void testCompositeExtIdAfterInsert()
    {
        Account acc=[SELECT Id From Account Where RecordType.Name != 'CDK OEM/Brand'];
        
        Manufacturer__c manf=[SELECT Id, Ora_Manufacturers_Code__c, Segment_Code__c From Manufacturer__c];
        
        test.startTest();
        Manufacturer_At_Dealership__c mdRec=new Manufacturer_At_Dealership__c();
        mdRec.account__c = acc.ID;       
        mdRec.Manufacturer__c=manf.Id;
        mdRec.putSobject('Manufacturer__r', manf);
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
        Account acc=[SELECT Id From Account Where RecordType.Name != 'CDK OEM/Brand'];
        
        Manufacturer__c manf=[SELECT Id, Ora_Manufacturers_Code__c, Segment_Code__c From Manufacturer__c];
        
        test.startTest();
        Manufacturer_At_Dealership__c mdRec=new Manufacturer_At_Dealership__c();
        mdRec.account__c = acc.ID;       
        mdRec.Manufacturer__c=manf.Id;
        mdRec.putSobject('Manufacturer__r', manf);
        insert mdRec;
        
        //Holding the Composite Id of the record inserted in oldCompositeIdValue.
        Manufacturer_At_Dealership__c compositeIdUpdatedRecord=[SELECT CompositeExtID__c, Id FROM Manufacturer_at_Dealership__c];
        String oldCompositeIdValue=compositeIdUpdatedRecord.CompositeExtID__c;
        
        Map<Id, Manufacturer_at_Dealership__c> recordsWithOldValuesMap=new Map<Id, Manufacturer_at_Dealership__c>();
        recordsWithOldValuesMap.put(mdRec.Id, mdRec);
        
        //Change the Manufacturer value of the Manufacturer_At_Dealership__c record.
        //Manufacturer__c manfRec=new Manufacturer__c();
        //manfRec.Segment_Code__c='NAAT';
        //insert manfRec;
        
        manf.Segment_Code__c='NAAT';
        update manf;
        
        mdRec.Manufacturer__c=manf.Id;
        mdRec.putSobject('Manufacturer__r', manf);
        update mdRec;
        
        //Holding the Composite Id of the record updated in newCompositeIdValue.
        Manufacturer_At_Dealership__c newCompositeIdUpdatedRecord=[SELECT CompositeExtID__c, Id FROM Manufacturer_at_Dealership__c];
        String newCompositeIdValue=newCompositeIdUpdatedRecord.CompositeExtID__c;
        
        //Invoking the Handler method after inserting the record.
        List<Manufacturer_at_Dealership__c> recordsWithNewValues=new List<Manufacturer_at_Dealership__c>();
        recordsWithNewValues.add(mdRec);
        
        DS_ManufacturersAtDealership_Handler.createCompositeId(recordsWithNewValues, recordsWithOldValuesMap);
        
        //system.assert(oldCompositeIdValue!=newCompositeIdValue);
        test.stopTest();
    }
}