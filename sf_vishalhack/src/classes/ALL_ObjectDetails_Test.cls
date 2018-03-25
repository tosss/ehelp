//2016-09-27- anirudh.singh@cdk.com- Created this test class for ALL_ObjectDetails_Controller.
@isTest
public class ALL_ObjectDetails_Test
{
    @TestSetup
    private static void setupData()
    {
        Account accountRecord=DS_TestObjects.NewAccount_Inserted();
        
        Opportunity oppRecord=DS_TestObjects.NewOpportunity();
        oppRecord.AccountId=accountRecord.Id;
        insert oppRecord;
        
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId= :siteRecordTypeId AND Opportunity__c= :oppRecord.Id AND Site__c= :accountRecord.Id] ;
        
        Opportunity_Location__c buildingRecord=[SELECT Id FROM Opportunity_Location__c WHERE Building_Site__c=:locRecord.Id LIMIT 1];
        
        Device__c hardwareDeviceRecord=new Device__c();
        hardwareDeviceRecord.Device_Type__c='Copier';
        hardwareDeviceRecord.Opportunity_Building_Hardware_Device__c=buildingRecord.Id;
        hardwareDeviceRecord.Quantity__c=2;
        insert hardwareDeviceRecord;
        
        Head_Count_Detail__c headCountRecord=new Head_Count_Detail__c();
        headCountRecord.Opportunity_Location__c=buildingRecord.Id;
        headCountRecord.Quantity__c=2;
        insert headCountRecord;
        
        Hours_Of_Operation__c hoursOfOperationRecord=new Hours_Of_Operation__c();
        hoursOfOperationRecord.Opportunity_Location__c=locRecord.Id;
        hoursOfOperationRecord.TimeZone__c='Central Time Zone (CDT / CST)';
        hoursOfOperationRecord.Department__c='Accounting';
        hoursOfOperationRecord.Common_Start_Time__c='10:00 AM';
        hoursOfOperationRecord.Common_End_Time__c='08:00 PM';
        hoursOfOperationRecord.Days_to_Select__c='Monday';
        insert hoursOfOperationRecord;
        
        List<ALL_ObjectFieldIds__c> objectFieldIdsList=new List<ALL_ObjectFieldIds__c>();
        ALL_ObjectFieldIds__c recordOne=new ALL_ObjectFieldIds__c();
        recordOne.Name='Record 1';
        recordOne.Object_Or_Field_Id__c='01I230000000Nb7';
        recordOne.Object_API_Name__c='Head_Count_Detail__c';
        objectFieldIdsList.add(recordOne);
        
        ALL_ObjectFieldIds__c recordTwo=new ALL_ObjectFieldIds__c();
        recordTwo.Name='Record 2';
        recordTwo.Object_Or_Field_Id__c='CF00N23000000P6m1';
        recordTwo.Field_API_Name__c='Opportunity_Location__c';
        recordTwo.Object_API_Name__c='Hours_Of_Operation__c';
        recordTwo.Equivalent_OppSite_Field_API_Name__c='Name';
        objectFieldIdsList.add(recordTwo);
        
        ALL_ObjectFieldIds__c recordThree=new ALL_ObjectFieldIds__c();
        recordThree.Name='Record 3';
        recordThree.Object_Or_Field_Id__c='CF00N23000000P0zT';
        recordThree.Field_API_Name__c='Building_Site__c';
        recordThree.Object_API_Name__c='Opportunity_Location__c';
        recordThree.Record_Type_Name__c='Building';
        recordThree.Equivalent_OppSite_Field_API_Name__c='Name';
        objectFieldIdsList.add(recordThree);
        
        ALL_ObjectFieldIds__c recordFour=new ALL_ObjectFieldIds__c();
        recordFour.Name='Record 4';
        recordFour.Object_Or_Field_Id__c='CF00N23000000P0z4';
        recordFour.Field_API_Name__c='Opportunity__c';
        recordFour.Object_API_Name__c='Opportunity_Location__c';
        recordFour.Equivalent_OppSite_Field_API_Name__c='Opportunity__r.Name';
        recordFour.Record_Type_Name__c='Building';
        objectFieldIdsList.add(recordFour);
        
        insert objectFieldIdsList;
        
        List<ALL_ObjectReportIds__c> reportSettingList=new List<ALL_ObjectReportIds__c>();
        ALL_ObjectReportIds__c reportSettingOne=new ALL_ObjectReportIds__c();
        reportSettingOne.Name='Record 1';
        reportSettingOne.Object_API_Name__c='Head_Count_Detail__c';
        reportSettingOne.Parameter_Number__c='pv0';
        reportSettingOne.Report_Id__c='00O23000000PXZs';
        reportSettingList.add(reportSettingOne);
        
        ALL_ObjectReportIds__c reportSettingTwo=new ALL_ObjectReportIds__c();
        reportSettingTwo.Name='Record 2';
        reportSettingTwo.Object_API_Name__c='Device__c';
        reportSettingTwo.Parameter_Number__c='pv1';
        reportSettingTwo.Record_Type_Name__c='Hardware Device';
        reportSettingTwo.Report_Id__c='00O23000000PXaW';
        reportSettingList.add(reportSettingTwo);
        
        insert reportSettingList;
    }
    
    private static testMethod void hardwareDetailsTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Opportunity_Locations__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_SObject__mdt sObjectMetadataRecord=[
            SELECT SObject_Name__c, Building_Dependent__c, Where_Clause_Field_API_Name__c, 
            SObject_Record_Type__c, Field_Set_API_Name__c
            FROM ALL_SObject__mdt
            WHERE MasterLabel='Hardware Details'
        ];
        
        ALL_ObjectDetails_Controller ref=new ALL_ObjectDetails_Controller();
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        ref.sObjectMetadataRecord=sObjectMetadataRecord;
        
        Test.startTest();
        system.assertEquals(1, ref.wrapperRecordToDisplay.sObjectList.size());
        
        Device__c hardwareDeviceRecord=new Device__c();
        hardwareDeviceRecord.Device_Type__c='Fax Machine';
        hardwareDeviceRecord.Opportunity_Building_Hardware_Device__c=locRecord.Opportunity_Locations__r[0].Id;
        hardwareDeviceRecord.Quantity__c=10;
        insert hardwareDeviceRecord;
        
        ALL_ObjectDetails_Controller refAfterAddingRecord=new ALL_ObjectDetails_Controller();
        refAfterAddingRecord.oppLocationSiteIdForRecs=locRecord.Id;
        refAfterAddingRecord.sObjectMetadataRecord=sObjectMetadataRecord;
        
        system.assertEquals(2, refAfterAddingRecord.wrapperRecordToDisplay.sObjectList.size());
        Test.stopTest();
    }
    
    private static testMethod void networkDetailsTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id, (SELECT Id FROM Opportunity_Locations__r) FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_SObject__mdt sObjectMetadataRecord=[
            SELECT SObject_Name__c, Building_Dependent__c, Where_Clause_Field_API_Name__c, 
            SObject_Record_Type__c, Field_Set_API_Name__c
            FROM ALL_SObject__mdt
            WHERE MasterLabel='Network Details'
        ];
        
        ALL_ObjectDetails_Controller ref=new ALL_ObjectDetails_Controller();
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        ref.sObjectMetadataRecord=sObjectMetadataRecord;
        
        Test.startTest();
        ALL_ObjectDetails_Controller.ObjectDetailsWrapper wrapperRecordToDisplay=ref.wrapperRecordToDisplay;
        
        Id networkDeviceRecordTypeId=Schema.SObjectType.Device__c.getRecordTypeInfosByName().get('Network Device').getRecordTypeId();
        system.assertEquals(Null, wrapperRecordToDisplay.sObjectList);
        system.assertEquals('Device', wrapperRecordToDisplay.sObjectLabel);
        
        Device__c networkDeviceRecord=new Device__c();
        networkDeviceRecord.Device_Type__c='Router';
        networkDeviceRecord.Opportunity_Building_Network_Device__c=locRecord.Opportunity_Locations__r[0].Id;
        networkDeviceRecord.Total_No_of_Switch_Ports__c=2;
        networkDeviceRecord.PoE__c='Yes';
        networkDeviceRecord.Managed_Unmanaged__c='Managed';
        networkDeviceRecord.No_of_GigE_Ports__c=2;
        networkDeviceRecord.No_of_Linked_Switched_Ports__c=6;
        networkDeviceRecord.RecordTypeId=networkDeviceRecordTypeId;
        insert networkDeviceRecord;
        
        networkDeviceRecord=[SELECT Id, RecordTypeId FROM Device__c WHERE RecordTypeId=:networkDeviceRecordTypeId];
        
        ALL_ObjectDetails_Controller refAfterInsertingRecord=new ALL_ObjectDetails_Controller();
        refAfterInsertingRecord.oppLocationSiteIdForRecs=locRecord.Id;
        refAfterInsertingRecord.sObjectMetadataRecord=sObjectMetadataRecord;
        
        system.assertEquals(1, refAfterInsertingRecord.wrapperRecordToDisplay.sObjectList.size());
        system.assertEquals(networkDeviceRecord.Id, refAfterInsertingRecord.wrapperRecordToDisplay.sObjectList[0].Id);
        Test.stopTest();
    }
    
    private static testMethod void hoursOfOperationTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_SObject__mdt sObjectMetadataRecord=[
            SELECT SObject_Name__c, Building_Dependent__c, Where_Clause_Field_API_Name__c, 
            SObject_Record_Type__c, Field_Set_API_Name__c
            FROM ALL_SObject__mdt
            WHERE MasterLabel='Hours of Operation'
        ];
        
        ALL_ObjectDetails_Controller ref=new ALL_ObjectDetails_Controller();
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        ref.sObjectMetadataRecord=sObjectMetadataRecord;
        
        Test.startTest();
        ALL_ObjectDetails_Controller.ObjectDetailsWrapper wrapperRecordToDisplay=ref.wrapperRecordToDisplay;
        
        system.assertEquals(1, wrapperRecordToDisplay.sObjectList.size());
        system.assertEquals('Hours Of Operation', wrapperRecordToDisplay.sObjectLabel);
        
        system.assertEquals(Null, wrapperRecordToDisplay.holidayScheduleForSite);
        Test.stopTest();
        
        locRecord.Holiday_Schedule__c='Christmas; Columbus Day';
        update locRecord;
        
        ALL_ObjectDetails_Controller refAfterUpdatingRecord=new ALL_ObjectDetails_Controller();
        refAfterUpdatingRecord.oppLocationSiteIdForRecs=locRecord.Id;
        refAfterUpdatingRecord.sObjectMetadataRecord=sObjectMetadataRecord;
        
        system.assertEquals('Christmas, Columbus Day', refAfterUpdatingRecord.wrapperRecordToDisplay.holidayScheduleForSite);
    }
    
    private static testMethod void headCountDetailTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_SObject__mdt sObjectMetadataRecord=[
            SELECT SObject_Name__c, Building_Dependent__c, Where_Clause_Field_API_Name__c, 
            SObject_Record_Type__c, Field_Set_API_Name__c
            FROM ALL_SObject__mdt
            WHERE MasterLabel='Headcount Details'
        ];
        
        ALL_ObjectDetails_Controller ref=new ALL_ObjectDetails_Controller();
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        ref.sObjectMetadataRecord=sObjectMetadataRecord;
        
        Test.startTest();
        ALL_ObjectDetails_Controller.ObjectDetailsWrapper wrapperRecordToDisplay=ref.wrapperRecordToDisplay;
        
        system.assertEquals(1, wrapperRecordToDisplay.sObjectList.size());
        system.assertEquals('Head Count Detail', wrapperRecordToDisplay.sObjectLabel);
        Test.stopTest();
        
        Map<String, String> reportNameLinkMap=wrapperRecordToDisplay.getReportNameLinkMap();
        system.assertEquals(Null, reportNameLinkMap);
        
        wrapperRecordToDisplay.reportNameLinkMap.put('test', 'testReportLink');
        reportNameLinkMap=wrapperRecordToDisplay.getReportNameLinkMap();
        system.assertEquals(1, reportNameLinkMap.size());
    }
    
    private static testMethod void oppLocBuildingTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_SObject__mdt sObjectMetadataRecord=[
            SELECT SObject_Name__c, Building_Dependent__c, Where_Clause_Field_API_Name__c, 
            SObject_Record_Type__c, Field_Set_API_Name__c
            FROM ALL_SObject__mdt
            WHERE MasterLabel='Opportunity Location- Building'
        ];
        
        ALL_ObjectDetails_Controller ref=new ALL_ObjectDetails_Controller();
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        ref.sObjectMetadataRecord=sObjectMetadataRecord;
        
        Test.startTest();
        system.assert( ref.wrapperRecordToDisplay.sObjectList.size() >= 1);
        system.assertEquals('Opportunity Location', ref.wrapperRecordToDisplay.sObjectLabel);
        Test.stopTest();
    }
    
    private static testMethod void deleteObjectRecordTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_SObject__mdt sObjectMetadataRecord=[
            SELECT SObject_Name__c, Building_Dependent__c, Where_Clause_Field_API_Name__c, 
            SObject_Record_Type__c, Field_Set_API_Name__c
            FROM ALL_SObject__mdt
            WHERE MasterLabel='Opportunity Location- Building'
        ];
        
        ALL_ObjectDetails_Controller ref=new ALL_ObjectDetails_Controller();
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        ref.sObjectMetadataRecord=sObjectMetadataRecord;
        
        Test.startTest();
        system.assert(ref.wrapperRecordToDisplay.sObjectList.size() >= 1);
        Test.stopTest();
        
        ALL_ObjectDetails_Controller.deleteObjectRecord(ref.wrapperRecordToDisplay.sObjectList[0].Id, 'Opportunity_Location__c');
    }
    
    private static testMethod void deleteObjectRecordNegativeTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_SObject__mdt sObjectMetadataRecord=[
            SELECT SObject_Name__c, Building_Dependent__c, Where_Clause_Field_API_Name__c, 
            SObject_Record_Type__c, Field_Set_API_Name__c
            FROM ALL_SObject__mdt
            WHERE MasterLabel='Opportunity Location- Building'
        ];
        
        ALL_ObjectDetails_Controller ref=new ALL_ObjectDetails_Controller();
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        ref.sObjectMetadataRecord=sObjectMetadataRecord;
        
        Test.startTest();
        system.assert(ref.wrapperRecordToDisplay.sObjectList.size() >= 1);
        Test.stopTest();
        
        ALL_ObjectDetails_Controller.deleteObjectRecord(ref.wrapperRecordToDisplay.sObjectList[0].Id, 'Device__c');
    }
    
    private static testMethod void pdfVersionTest()
    {
        Id siteRecordTypeId=Schema.SObjectType.Opportunity_Location__c.getRecordTypeInfosByName().get('Site').getRecordTypeId();
        Opportunity_Location__c locRecord=[SELECT Id FROM Opportunity_Location__c WHERE RecordTypeId=:siteRecordTypeId];
        
        ALL_SObject__mdt sObjectMetadataRecord=[
            SELECT SObject_Name__c, Building_Dependent__c, Where_Clause_Field_API_Name__c, 
            SObject_Record_Type__c, Field_Set_API_Name__c
            FROM ALL_SObject__mdt
            WHERE MasterLabel='Opportunity Location- Building'
        ];
        
        ALL_ObjectDetails_Controller ref=new ALL_ObjectDetails_Controller();
        ref.sObjectMetadataRecord=sObjectMetadataRecord;
        ref.objDetailsScenario='pdf';
        ref.oppLocationSiteIdForRecs=locRecord.Id;
        
        Test.startTest();
        system.assertEquals(10, ref.wrapperRecordToDisplay.noOfRowsToDisplay);
        Test.stopTest();
    }
}