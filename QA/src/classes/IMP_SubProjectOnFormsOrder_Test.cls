//2016-03-08- anirudh.singh@cdk.com- Created this test class for IMP_SubProjectOnFormsOrder_Extension as earlier, no test class was existing.
@isTest
public class IMP_SubProjectOnFormsOrder_Test
{
    @TestSetup
    private static void setupData()
    {
        Account accountRecord=IMP_TestFactory_Helper.buildAccount();
        insert accountRecord;
        
        Contact contactRecord=IMP_TestFactory_Helper.buildContact(accountRecord.Id);
        insert contactRecord;
        
        CMF_Info__c cmfInfoRecord=IMP_TestFactory_Helper.buildCMFInfo(accountRecord.Id);
        insert cmfInfoRecord;
        
        List<Laser_Artwork_Order__c> formsOrderList=new List<Laser_Artwork_Order__c>();
        Laser_Artwork_Order__c formsOrderRecordOne=IMP_TestFactory_Helper.buildLaserArtworkOrder(contactRecord.Id);
        formsOrderRecordOne.Ship_CMF_Info__c=cmfInfoRecord.Id;
        formsOrderList.add(formsOrderRecordOne);
        
        Laser_Artwork_Order__c formsOrderRecordTwo=IMP_TestFactory_Helper.buildLaserArtworkOrder(contactRecord.Id);
        formsOrderRecordTwo.Ship_CMF_Info__c=cmfInfoRecord.Id;
        formsOrderList.add(formsOrderRecordTwo);
        insert formsOrderList;
        
        Project__c projectRecord=IMP_TestFactory_Helper.buildProject(0);
        projectRecord.Project_Region__c='CANADA-EAST';
        insert projectRecord;
        
        SubProject__c subProjectRecord=IMP_TestFactory_Helper.buildSubProject(projectRecord.Id);
        subProjectRecord.SubProject_Region__c='CANADA-EAST';
        subProjectRecord.Confidential__c=false;
        subProjectRecord.Contract_Roll_Called__c=Null;
        insert subProjectRecord;
        
        SubProject_External_Reference__c subProjectExternalReferenceRecord=IMP_TestFactory_Helper.buildSubProjectExternalReference(formsOrderRecordOne.Id, 
                                                                                                                                   subProjectRecord.Id, 
                                                                                                                                   projectRecord.Id);
        insert subProjectExternalReferenceRecord;
    }
    
    private static testMethod void constructorTest()
    {
        Laser_Artwork_Order__c formsOrder=[
            SELECT ID, Go_Live_Date__c, Project_Manager__c, Subproject__c,Project_Type__c, 
            SubProject_Comments__c, Confidential__C, Client_Manager__c, Roll_Call_Date__c, 
            Impact_Project_Numbers__c, Estimated_Install_Date__c
            FROM Laser_Artwork_Order__c 
            LIMIT 1
        ];
        
        test.startTest();
        ApexPages.StandardController stdController=new ApexPages.StandardController(formsOrder);
        IMP_SubProjectOnFormsOrder_Extension formsOrderPage=new IMP_SubProjectOnFormsOrder_Extension(stdController);
        test.stopTest();
    }
    
    private static testMethod void fetchSubProjectDetailsTestOne()
    {
        Laser_Artwork_Order__c formsOrder=[
            SELECT ID, Go_Live_Date__c, Project_Manager__c, Subproject__c,Project_Type__c, 
            SubProject_Comments__c, Confidential__C, Client_Manager__c, Roll_Call_Date__c, 
            Impact_Project_Numbers__c, Estimated_Install_Date__c
            FROM Laser_Artwork_Order__c
            LIMIT 1
        ];
        
        test.startTest();
        ApexPages.StandardController stdController=new ApexPages.StandardController(formsOrder);
        IMP_SubProjectOnFormsOrder_Extension formsOrderPage=new IMP_SubProjectOnFormsOrder_Extension(stdController);
        
        formsOrderPage.fetchSubProjectDetails();
        System.assertNotEquals(Null, formsOrderPage.subProjectExternalReferenceRecord, 'Subproject External Reference Object Not Found');
        test.stopTest();
    }
    
    private static testMethod void fetchSubProjectDetailsTestTwo()
    {
        SubProject_External_Reference__c subProjectExternalReferenceRecord=[SELECT Id, LAO_ID__c FROM SubProject_External_Reference__c];
        
        Laser_Artwork_Order__c formsOrder=[
            SELECT Id 
            FROM Laser_Artwork_Order__c 
            WHERE Id!=:subProjectExternalReferenceRecord.LAO_ID__c 
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        
        test.startTest();
        ApexPages.StandardController stdController=new ApexPages.StandardController(formsOrder);
        IMP_SubProjectOnFormsOrder_Extension formsOrderPage=new IMP_SubProjectOnFormsOrder_Extension(stdController);
        
        formsOrderPage.fetchSubProjectDetails();
        System.assertEquals(Null, formsOrderPage.subProjectExternalReferenceRecord, 'Unexpected value for Subproject External Reference Object');
        test.stopTest();
    }
}