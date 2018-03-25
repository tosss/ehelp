/*----------------------------------------------------------------
* 2016-10-03 -venkata.shrivol@cdk.com -created
* Test Class for : ALL_DiscoveryBuildingImages_Controller
-------------------------------------------------------------------*/
//2017-01-04- anirudh.singh@cdk.com- Included two new methods saveMapTest and fetchMapTest to the class to increase test coverage.
//2017-05-23 -venkata.shrivol@cdk.com - added list reference to soql query to retrieve building locations
@isTest
public class ALL_DiscoveryBuildingImages_Test 
{
    @TestSetup 
    private static void prepareTestData()
    {
        List<sObject> settingsObjects=new List<sObject>{
            new Trigger_Toggle__c(Name='001', Code_Reference__c='CDK_Default_Team', On__c=false, RecordType_Name__c=null, sObject__c='Account'),
            new Trigger_Toggle__c(Name='002', Code_Reference__c='CDK_Default_Team', On__c=true, RecordType_Name__c='CDK OEM/Brand', sObject__c='Account')
		};
        insert settingsObjects;
        
        Account testAccount=IMP_TestFactory_Helper.buildAccount();
        testAccount.Name='Discovery app test';
        insert testAccount;
        
        Opportunity testOpp=IMP_TestFactory_Helper.buildOpportunity();
        testOpp.AccountId=testAccount.Id;
        insert testOpp;
        
        String siteRecordTypeId=ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Opportunity_Location__c', 'Site');
        List<Opportunity_Location__c> siteLocationList=[
            SELECT Id 
            FROM Opportunity_Location__c 
            WHERE RecordTypeId=:siteRecordTypeId 
            And Opportunity__c=:testOpp.Id 
            AND Site__c=:testAccount.Id
        ];
        
        Opportunity_Location__c siteLocation=siteLocationList.size()>0 ? siteLocationList.get(0) : new Opportunity_Location__c();
        
        list<Opportunity_Location__c> buildingLocations=[
            SELECT Id 
            FROM Opportunity_Location__c 
            WHERE Building_Site__c =: siteLocation.Id 
            LIMIT 1
        ];
        //2017-05-23 -venkata.shrivol@cdk.com -added this terenary operator to avoid list soql exception
        Opportunity_Location__c buildingLocation =buildingLocations.size()>0 ? buildingLocations.get(0) : new Opportunity_Location__c();
        
        Attachment att=new Attachment();
        att.Body=Blob.valueOf('This is a test image attachment on Building');
        att.ContentType='image/jpeg';
        att.Name='Test image';
        att.ParentId=buildingLocation.Id;
        insert att;
    }
    
    private static testMethod void buildingImagesTest()
    {
        List<Opportunity_Location__c> siteRecords=[
            select Id 
            from Opportunity_Location__c 
            where RecordType.Name='Site'
        ];
        Opportunity_Location__c siteRec=siteRecords.size()>0 ? siteRecords.get(0) : new Opportunity_Location__c();
        
        Test.startTest();
        ALL_DiscoveryBuildingImages_Controller buildingController=new ALL_DiscoveryBuildingImages_Controller();
        buildingController.oppLocationSiteIdForRecs=siteRec.Id;
        
        ApexPages.currentPage().getParameters().put('oppLocId', siteRec.Id);
        ALL_DiscoveryBuildingImages_Controller.BuildingImgWrapper buildingImgWrapperRec=new ALL_DiscoveryBuildingImages_Controller.BuildingImgWrapper();
        buildingImgWrapperRec=buildingController.buildingImgWrapperRec;
        //buildingController.getBuildingRecords();
        system.assert(buildingImgWrapperRec.isAttachment);
        Test.stopTest();
    }
    
    private static testMethod void buildingCommentsUpdateTest()
    {
        List<Opportunity_Location__c> siteRecords=[
            select Id, Site__r.Name, Site__r.BillingStreet, Site__r.BillingCity, 
            Site__r.BillingPostalCode, Comments_on_Building_Images__c
            from Opportunity_Location__c 
            where RecordType.Name='Site'
        ];
        Opportunity_Location__c siteRec=siteRecords.size()>0 ? siteRecords.get(0) : new Opportunity_Location__c();
        
        Test.startTest();
        ALL_DiscoveryBuildingImages_Controller buildingController=new ALL_DiscoveryBuildingImages_Controller();
        buildingController.oppLocationSiteIdForRecs=siteRec.Id;
        buildingController.oppLocRecord.Comments_on_Building_Images__c='Comments Changed';
        buildingController.saveAndRefresh();
        
        List<Opportunity_Location__c> updatedSites=[
            select Id, Comments_on_Building_Images__c
            from Opportunity_Location__c 
            where RecordType.Name='Site'
        ];
        
        Opportunity_Location__c updatedSiteRec=updatedSites.size()>0 ? updatedSites.get(0) : new Opportunity_Location__c();
        system.assertEquals(updatedSiteRec.Comments_on_Building_Images__c, 'Comments Changed', 'Site Record did not get updated in saveAndRefresh Method');
        Test.stopTest();
    }
    
    private static testMethod void cancelMethodTest()
    {
        List<Opportunity_Location__c> siteRecords=[
            select Id, Site__r.Name, Site__r.BillingStreet, Site__r.BillingCity, 
            Site__r.BillingPostalCode, Comments_on_Building_Images__c
            from Opportunity_Location__c 
            where RecordType.Name='Site'
        ];
        Opportunity_Location__c siteRec=siteRecords.size()>0 ? siteRecords.get(0) : new Opportunity_Location__c();
        
        Test.startTest();
        ALL_DiscoveryBuildingImages_Controller buildingController=new ALL_DiscoveryBuildingImages_Controller();
        buildingController.oppLocationSiteIdForRecs=siteRec.Id;
        
        ALL_DiscoveryBuildingImages_Controller.BuildingImgWrapper buildingImgWrapperRec=buildingController.buildingImgWrapperRec;
        
        List<Opportunity_Location__c> updatedSites=[
            select Id, Comments_on_Building_Images__c
            from Opportunity_Location__c 
            where RecordType.Name='Site'
        ];
        
        Opportunity_Location__c updatedSiteRec=updatedSites.size()>0 ? updatedSites.get(0) : new Opportunity_Location__c();
        system.assertEquals(updatedSiteRec.Comments_on_Building_Images__c, null, 'Site Record got updated in cancel Method');
        Test.stopTest();
    }
    
    private static testMethod void saveMapTest()
    {
        List<Opportunity_Location__c> siteRecords=[
            select Id 
            from Opportunity_Location__c 
            where RecordType.Name='Site'
        ];
        Opportunity_Location__c siteRec=siteRecords.size()>0 ? siteRecords.get(0) : new Opportunity_Location__c();
        
        Test.startTest();
        String errMessage=ALL_DiscoveryBuildingImages_Controller.saveMap(siteRec.Id, 'Test');
        Test.stopTest();
        
        system.assertEquals(errMessage, '', 'No errors. Updated successful.');
        
        List<Opportunity_Location__c> updatedSites=[
            select Id, Map_Annotations__c
            from Opportunity_Location__c 
            where RecordType.Name='Site'
        ];
        
        Opportunity_Location__c updatedSiteRec=updatedSites.size()>0 ? updatedSites.get(0) : new Opportunity_Location__c();
        system.assertEquals(updatedSiteRec.Map_Annotations__c, 'Test', 'Map Annotations field updated');
        
        errMessage=ALL_DiscoveryBuildingImages_Controller.saveMap(siteRec.Id, 'Test');
        system.assertEquals(errMessage, 'Save not valid. No changes found.', 'No update.');
    }
    
    private static testMethod void fetchMapTest()
    {
        List<Opportunity_Location__c> siteRecords=[
            select Id 
            from Opportunity_Location__c 
            where RecordType.Name='Site'
        ];
        Opportunity_Location__c siteRec=siteRecords.size()>0 ? siteRecords.get(0) : new Opportunity_Location__c();
        
        Test.startTest();
        ALL_DiscoveryBuildingImages_Controller.saveMap(siteRec.Id, 'Test');
        
        String mapAnnotationsValue=ALL_DiscoveryBuildingImages_Controller.fetchMap(siteRec.Id);
        Test.stopTest();
        
        system.assertEquals(mapAnnotationsValue, 'Test', 'Map Annotations value.');
    }
    
    private static testMethod void saveImgChangesTestOne()
    {
        List<Opportunity_Location__c> buildingRecords=new List<Opportunity_Location__c>([
            SELECT Id,
            (
                SELECT Id, Description 
                FROM Attachments 
                WHERE ContentType LIKE 'image%'
            )
            FROM Opportunity_Location__c 
            WHERE RecordType.Name='Building'
        ]);
        
        String oppBuildingObj='{"oppBuildingId":"","imgRotations":""}';
        
        Test.startTest();
        if(buildingRecords.size()>0)
        {
            String returnedMessage=ALL_DiscoveryBuildingImages_Controller.saveImgChanges(buildingRecords[0].Attachments[0].Id, 'Test Image', oppBuildingObj);
            system.assert(returnedMessage.contains('Invalid id value for this SObject type:'));
        }
        Test.stopTest();
    }
    
    private static testMethod void saveImgChangesTestTwo()
    {
        List<Opportunity_Location__c> buildingRecords=new List<Opportunity_Location__c>([
            SELECT Id,
            (
                SELECT Id, Description 
                FROM Attachments 
                WHERE ContentType LIKE 'image%'
            )
            FROM Opportunity_Location__c 
            WHERE RecordType.Name='Building'
        ]);
        
        String oppBuildingObj='{"oppBuildingId":"'+buildingRecords[0].Id+'","imgRotations":"Test"}';
        
        Test.startTest();
        if(buildingRecords.size()>0)
        {
            String returnedMessage=ALL_DiscoveryBuildingImages_Controller.saveImgChanges(buildingRecords[0].Attachments[0].Id, 'Test Image', oppBuildingObj);
            system.assertEquals('Success', returnedMessage);
        }
        Test.stopTest();
    }
    
    private static testMethod void fetchImgRotationsTestOne()
    {
        List<Opportunity_Location__c> siteRecords=new List<Opportunity_Location__c>([
            SELECT Id 
            FROM Opportunity_Location__c 
            WHERE RecordType.Name='Site'
        ]);
        
        Test.startTest();
        List<ALL_DiscoveryBuildingImages_Controller.BuildingIdRotatnsWrapper> fetchImgRotations=ALL_DiscoveryBuildingImages_Controller.fetchImgRotations(siteRecords[0].Id);
        system.assertEquals(1, fetchImgRotations.size());
        Test.stopTest();
    }
}