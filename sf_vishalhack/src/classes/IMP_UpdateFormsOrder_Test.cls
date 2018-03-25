/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Test Class to test IMP_UpdateFormsOrder_Handler Class and Subproject_On_Laser_Extension Class
Created on:    16 July 2015.
Code Coverage: 100%
------------------------------------------------------------
History
16 July 2015    Vishal Bandari          RQ-04982: Added setupTestData Method
16 July 2015    Vishal Bandari          RQ-04982: Added validateHandlerAndExtension Method
16 July 2015    Vishal Bandari          RQ-04982: Added negitiveTest Method
30 July 2015    Vishal Bandari          RQ-04982: Added code to test Subproject_On_Laser_Extension Class in validateHandlerAndExtension Method
2015-11-04      vishal.bandari@cdk.com  RQ-05690: Added code to test update on Estimated_Install_Date__c field in Laser_Artwork_Order__c
2015-12-15      vishal.bandari@cdk.com  RQ-05934: Added code to test update on Subproject__c field in Laser_Artwork_Order__c
2015-12-15      vishal.bandari@cdk.com  RQ-05938: Added code to test update on Client_Manager__c field in Laser_Artwork_Order__c
2016-01-20      vishal.bandari@cdk.com  RQ-06056: Added code to test update on SubProject_Comments__c and Project_Type__c field in Laser_Artwork_Order__c
2015-12-22      venkata.shrivol@cdk.com	added DS_TestObjects reference for creation of laser objects in test setup
2016-03-08      anirudh.singh@cdk.com- Modified this class for Request RQ-06018 Update Trigger on SubProject and SubProjectOpp so they follow current dev stds.
2016-06-06      anirudh.singh@cdk.com- Modified to resolve error due to additional filter on Project_Manager__c field of SubProject for profile for Shared Contacts project.
2016-06-16      venkata.shrivol@cdk.com - added CR test records after account and contact insertion. 
2016-12-05      venkata.shrivol@cdk.com - commented project object code as it is getting deleted RQ-08305
------------------------------------------------------------*/
@isTest
public class IMP_UpdateFormsOrder_Test
{
    @TestSetup
    private static void setupData()
    {
        //2016-06-06- anirudh.singh@cdk.com- Added to resolve error due to additional filter on Project_Manager__c field of SubProject for profile for Shared Contacts project.
        String Random=DS_TestObjects.NextTestUserRandom();
        Profile profileRecord=[SELECT Id, Name FROM Profile WHERE Name='ADPDS - Implementation - PM' LIMIT 1];
        
        User newUser=new User(
            UserName='test-'+Random+'@cdk.com', 
            Email='test-'+Random+'@cdk.com', 
            Alias=Random.length()>8?Random.substring(4, Random.length()):Random,
            EmailEncodingKey='UTF-8', 
            FirstName='Apex',
            LastName='IMP_UpdateFormsOrder_Test User', 
            LanguageLocaleKey='en_US', 
            LocaleSIDKey='en_US', 
            profileid=profileRecord.Id, 
            TimeZoneSIDKey='America/Chicago',
            ADID__c='A'+Random,
            FederationIdentifier = 'F'+Random
        );
        insert newUser;
        
        Account accountRecord=IMP_TestFactory_Helper.buildAccount();
        insert accountRecord;
        
        Contact contactRecord=IMP_TestFactory_Helper.buildContact(accountRecord.Id);
        insert contactRecord;
        
        Contact_Relationship__c crRecord = IMP_TestFactory_Helper.buildContactRelationship(accountRecord.Id, contactRecord.Id);
        insert crRecord;
        
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
        
        /*Project__c projectRecord=IMP_TestFactory_Helper.buildProject(0);
        projectRecord.Project_Region__c='CANADA-EAST';
        insert projectRecord;*/
        
        SubProject__c subProjectRecord=IMP_TestFactory_Helper.buildSubProject();
        subProjectRecord.SubProject_Region__c='CANADA-EAST';
        subProjectRecord.Confidential__c=false;
        subProjectRecord.Contract_Roll_Called__c=Null;
        insert subProjectRecord;
        
        SubProject_External_Reference__c subProjectExternalReferenceRecord=IMP_TestFactory_Helper.buildSubProjectExternalReference(formsOrderRecordOne.Id, 
                                                                                                                                   subProjectRecord.Id 
                                                                                                                                  );
        insert subProjectExternalReferenceRecord;
    }
    
    //To Test Confidential__c, Go_Live_Date__c, Project_Manager__c update on Subproject__c reflects on Forms_Order__c and Forms_Collection_c object.
    private static testmethod void updateFormOrdersPositiveTest()
    {
        //2016-06-06- anirudh.singh@cdk.com- Added the below line to resolve error due to additional filter on Project_Manager__c field of SubProject for profile for Shared Contacts project.
        User userRecord=[SELECT Id FROM User WHERE LastName='IMP_UpdateFormsOrder_Test User' LIMIT 1];
        
        Subproject__c subProjectRecord=[
            SELECT ID, Go_Live_Date__c, Project_Type__c, Name, Project_Manager__c, Confidential__c, Contract_Roll_Called__c, Comments__c, 
            Training_Implementation_Client_Mgr__c, Impact_Project_Numbers__c, Estimated_Install_Date_EID__c
            FROM Subproject__c
        ];
        
        test.startTest();
        //Initially values are not initialised when Subproject__c is inserted
        system.assertEquals(subProjectRecord.Go_Live_Date__c, Null, 'Go Live Date got initialized');
        system.assertEquals(subProjectRecord.Project_Manager__c, Null, 'Project Manager got initialized');
        system.assertEquals(subProjectRecord.Confidential__c, false, 'Confidential got changed without update');
        system.assertEquals(subProjectRecord.Contract_Roll_Called__c, Null, 'Contract Roll Called Date got changed without update');
        system.assertEquals(subProjectRecord.Impact_Project_Numbers__c, Null, 'Impact Project Numbers got changed without update');
        
        //2015-11-04 vishal.bandari@cdk.com RQ-05690 added code to test update on Estimated_Install_Date__c
        system.assertEquals(subProjectRecord.Estimated_Install_Date_EID__c, System.today()+2, 'Estimated Install Date got changed without update');
        
        //2015-12-15 vishal.bandari@cdk.com RQ-05938 added code to test update on Client_Manager__c
        system.assertEquals(subProjectRecord.Training_Implementation_Client_Mgr__c, Null, 'Training Implementation Client Manager got changed without update');
        
        //2015-12-15 vishal.bandari@cdk.com RQ-06056 added code to test update on Comments__c and Project_Type__c
        system.assertEquals(subProjectRecord.Comments__c, 'Subproject Sample Comments', 'Comments got changed without update');
        system.assertEquals(subProjectRecord.Project_Type__c, 'Upgrade', 'Project Type got changed without update');
        
        //Update the values of Subproject Object field
        subProjectRecord.Go_Live_Date__c=system.Date.today();
        //2016-06-06- anirudh.singh@cdk.com- Commented the below line and added a new line for Project_Manager__c.
        //subProjectRecord.Project_Manager__c=Userinfo.getUserId();
        subProjectRecord.Project_Manager__c=userRecord.Id;
        subProjectRecord.Confidential__c=!subProjectRecord.Confidential__c;
        subProjectRecord.Contract_Roll_Called__c=system.Date.today();
        subProjectRecord.Impact_Project_Numbers__c='5';
        subProjectRecord.Estimated_Install_Date_EID__c=Date.Today().addDays(4);
        subProjectRecord.Training_Implementation_Client_Mgr__c=Userinfo.getUserId();
        subProjectRecord.Comments__c='Sample Comments Changed';
        subProjectRecord.Project_Type__c='Upgrade';
        update subProjectRecord;
        
        SubProject_External_Reference__c subProjectExternalReferenceRecord=[
            SELECT Id, LAO_ID__c
            FROM SubProject_External_Reference__c
            WHERE SubProject__c =: subProjectRecord.Id
        ];
        
        Laser_Artwork_Order__c formsOrder=[
            SELECT Id, Go_Live_Date__c, Project_Manager__c, Subproject__c, Project_Type__c, SubProject_Comments__c, 
            Confidential__C, Client_Manager__c, Roll_Call_Date__c, Impact_Project_Numbers__c, Estimated_Install_Date__c
            FROM Laser_Artwork_Order__c
            WHERE Id =: subProjectExternalReferenceRecord.LAO_ID__c
        ];
        
        //Check for update of Laser_Artwork_Order__c or Forms_Order__c object
        system.assertEquals(subProjectRecord.Go_Live_Date__c, formsOrder.Go_Live_Date__c, 'Go Live Date not updated in Forms Order');
        system.assertEquals(subProjectRecord.Project_Manager__c, formsOrder.Project_Manager__c, 'Project Manager not updated in Forms Order');
        system.assertEquals(subProjectRecord.Confidential__c, formsOrder.Confidential__c, 'Confidential not updated in Forms Order');
        system.assertEquals(subProjectRecord.Contract_Roll_Called__c, formsOrder.Roll_Call_Date__c, 'Confidential not updated in Forms Order');
        system.assertEquals('5', formsOrder.Impact_Project_Numbers__c, 'Impact Project numbers not updated in Forms Order');
        
        //2015-11-04 vishal.bandari@cdk.com RQ-05690 added code to test update on Estimated_Install_Date__c
        system.assertEquals(subProjectRecord.Estimated_Install_Date_EID__c, formsOrder.Estimated_Install_Date__c, 'Estimated Install Date not updated in Forms Order');
        
        //2015-12-15 vishal.bandari@cdk.com RQ-05934 added code to test update on Subproject Name
        system.assertEquals(subProjectRecord.Name, formsOrder.Subproject__c, 'Subproject Name not updated in Forms Order');
        
        //2015-12-15 vishal.bandari@cdk.com RQ-05938 added code to test update on Training_Implementation_Client_Mgr__c
        system.assertEquals(subProjectRecord.Training_Implementation_Client_Mgr__c, formsOrder.Client_Manager__c, 'Client Manager not updated in Forms Order');
        
        //2015-01-20 vishal.bandari@cdk.com RQ-06056 added code to test update on SubProject_Comments__c and Project_Type__c
        system.assertEquals(subProjectRecord.Comments__c, formsOrder.SubProject_Comments__c, 'Comments not updated in Forms Order');
        system.assertEquals(subProjectRecord.Project_Type__c, formsOrder.Project_Type__c, 'Project Type not updated in Forms Order');
        test.stopTest();
    }
    
    //To perform Negative test.
    private static testmethod void updateFormOrdersNegativeTest()
    {
        test.startTest();
        IMP_UpdateFormsOrder_Handler.updateFormOrders(Null, Null);
        test.stopTest();
    }
}