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
------------------------------------------------------------*/
@IsTest
public class IMP_UpdateFormsOrder_Test
{
    
    //to Setup Test Data
    @testSetup
    public static void setUpTestData()
    {
        //Inserting Sample Project__c
        Project__c projectObj = new Project__c();
        projectObj.Project_Region__c = 'CANADA-EAST';
        insert projectObj;
        
        //Inserting Sample SubProject__c
        Subproject__c subprojectObj = new Subproject__c();
        subprojectObj.SubProject_Name__c = 'Sample Subproject';
        subprojectObj.Project__c = projectObj.Id;
        subprojectObj.SubProject_Region__c = 'CANADA-EAST';
        subprojectObj.Number_of_Rooftops__c = 12.0;
        subprojectObj.Project_Type__c = 'Unhook';
        subprojectObj.Number_of_User_Connections__c = 12.0;
        subprojectObj.Market__c = 'LightSpeed-Powersports';
        subprojectObj.Confidential__c = false;
        subprojectObj.Contract_Roll_Called__c = null;
        subprojectObj.Comments__c = 'Sample Comment';
        insert subprojectObj;
        
        Account acc = new Account();
        acc.Name = 'Sample Account';
        insert acc;
        
        CMF_Info__c cmf = new CMF_Info__c();
        cmf.Name = 'Sample CMF';
        cmf.Account__c = acc.Id;
        insert cmf;
        
        Contact c = DS_TestObjects.NewContact_Inserted();
        
        List<Laser_Artwork_Order__c> laoList = new List<Laser_Artwork_Order__c>();
        //Inserting Sample Laser_Artwork_Order__c or Forms_Order__c object
        Laser_Artwork_Order__c laoObj = DS_TestObjects.NewLaserArtworkOrder();
        laoObj.Ship_CMF_Info__c = cmf.id;
        
        laoList.add(laoObj);
        
        //Inserting Sample Laser_Artwork_Order__c or Forms_Order__c object
        Laser_Artwork_Order__c laoObj2 = DS_TestObjects.NewLaserArtworkOrder();
        laoObj2.Ship_CMF_Info__c = cmf.id;
        laoList.add(laoObj2);
        
        insert laoList;
        
        //Insert SubProject_External_Reference__c object to relate SubProject and Forms_Order__c
        SubProject_External_Reference__c sperobj = new SubProject_External_Reference__c();
        sperObj.LAO_ID__c = laoObj.id;
        sperObj.Project__c = projectObj.Id;
        sperObj.SubProject__c = subprojectObj.Id;
        insert sperObj;
        
    }
    
    //to Test Confidential__c, Go_Live_Date__c, Project_Manager__c update on Subproject__c reflects on Forms_Order__c and Forms_Collection_c object
    public static testmethod void validateHandlerAndExtension()
    {
        test.startTest(); 
        Subproject__c subprojectObj = [
            SELECT ID, Go_Live_Date__c, Project_Type__c, Name, Project_Manager__c, Confidential__c, Contract_Roll_Called__c,Comments__c, Training_Implementation_Client_Mgr__c, Impact_Project_Numbers__c,Estimated_Install_Date_EID__c
            FROM Subproject__c
            WHERE SubProject_Name__c = 'Sample Subproject'
        ];
        
        //Initially values are not initialised when Subproject__c is inserted
        System.assertEquals(subprojectObj.Go_Live_Date__c,null, 'Go Live Date got initialized');
        System.assertEquals(subprojectobj.Project_Manager__c,null, 'Project Manager got initialized');
        System.assertEquals(subprojectobj.Confidential__c,false, 'Confidential got changed without update');
        System.assertEquals(subprojectObj.Contract_Roll_Called__c,null, 'Contract Roll Called Date got changed without update');
        System.assertEquals(subprojectObj.Impact_Project_Numbers__c,null, 'Impact Project Numbers got changed without update');
        
        //2015-11-04 vishal.bandari@cdk.com RQ-05690 added code to test update on Estimated_Install_Date__c
        System.assertEquals(subprojectObj.Estimated_Install_Date_EID__c,null, 'Estimated Install Date got changed without update');
        
        //2015-12-15 vishal.bandari@cdk.com RQ-05938 added code to test update on Client_Manager__c
        System.assertEquals(subprojectObj.Training_Implementation_Client_Mgr__c,null, 'Training Implementation Client Manager got changed without update');
        
        //2015-12-15 vishal.bandari@cdk.com RQ-06056 added code to test update on Comments__c and Project_Type__c
        System.assertEquals(subprojectObj.Comments__c,'Sample Comment', 'Comments got changed without update');
        System.assertEquals(subprojectObj.Project_Type__c,'Unhook', 'Project Type got changed without update');
        
        //Update the values of Subproject Object field
        subprojectObj.Go_Live_Date__c = System.Date.today();
        subprojectobj.Project_Manager__c = Userinfo.getUserId();
        subprojectobj.Confidential__c = !subprojectobj.Confidential__c;
        subprojectobj.Contract_Roll_Called__c = System.Date.today();
        subprojectobj.Impact_Project_Numbers__c = '5';
        subprojectObj.Estimated_Install_Date_EID__c = Date.Today().addDays(2);
        subprojectObj.Training_Implementation_Client_Mgr__c = Userinfo.getUserId();
        subprojectObj.Comments__c = 'Sample Comments Changed';
        subprojectObj.Project_Type__c = 'Upgrade';
        update subprojectObj;
        
        SubProject_External_Reference__c sperObj = [
            SELECT Id,  LAO_ID__c
            FROM SubProject_External_Reference__c
            WHERE SubProject__c =: subprojectObj.Id
        ];
        
        Laser_Artwork_Order__c laoObj = [
            SELECT ID, Go_Live_Date__c, Project_Manager__c, Subproject__c,Project_Type__c, SubProject_Comments__c, Confidential__C, Client_Manager__c, Roll_Call_Date__c, Impact_Project_Numbers__c, Estimated_Install_Date__c
            FROM Laser_Artwork_Order__c
            WHERE Id =: sperObj.LAO_ID__c
        ];
        
        //Check for update of Laser_Artwork_Order__c or Forms_Order__c object
        System.assertEquals(subprojectObj.Go_Live_Date__c,laoObj.Go_Live_Date__c, 'Go Live Date not updated in Forms Order');
        System.assertEquals(subprojectObj.Project_Manager__c,laoObj.Project_Manager__c, 'Project Manager not updated in Forms Order');
        System.assertEquals(subprojectobj.Confidential__c,laoObj.Confidential__c, 'Confidential not updated in Forms Order');
        System.assertEquals(subprojectobj.Contract_Roll_Called__c,laoObj.Roll_Call_Date__c, 'Confidential not updated in Forms Order');
        System.assertEquals('5',laoObj.Impact_Project_Numbers__c, 'Impact Project numbers not updated in Forms Order');
        
        //2015-11-04 vishal.bandari@cdk.com RQ-05690 added code to test update on Estimated_Install_Date__c
        System.assertEquals(subprojectObj.Estimated_Install_Date_EID__c,laoObj.Estimated_Install_Date__c, 'Estimated Install Date not updated in Forms Order');
        
        //2015-12-15 vishal.bandari@cdk.com RQ-05934 added code to test update on Subproject Name
        System.assertEquals(subprojectObj.Name,laoObj.Subproject__c, 'Subproject Name not updated in Forms Order');
        
        //2015-12-15 vishal.bandari@cdk.com RQ-05938 added code to test update on Training_Implementation_Client_Mgr__c
        System.assertEquals(subprojectObj.Training_Implementation_Client_Mgr__c,laoObj.Client_Manager__c, 'Client Manager not updated in Forms Order');
        
        //2015-01-20 vishal.bandari@cdk.com RQ-06056 added code to test update on SubProject_Comments__c and Project_Type__c
        System.assertEquals(subprojectObj.Comments__c,laoObj.SubProject_Comments__c, 'Comments not updated in Forms Order');
        System.assertEquals(subprojectObj.Project_Type__c,laoObj.Project_Type__c, 'Project Type not updated in Forms Order');
        
        //Testing Standard Layout of Laser_Artwork_Object__c SubprojectInfo Section
        
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(laoObj);
        IMP_Subproject_On_Laser_Extension laserArtworkPage = new IMP_Subproject_On_Laser_Extension(stdCtrl);
        laserArtworkPage.getSubprojectDetails();
        System.assertNotEquals(null, laserArtworkPage.sperObj, 'Subproject External Reference Object Not Found');
        
        laoObj = [SELECT ID  FROM Laser_Artwork_Order__c WHERE Id != :sperObj.LAO_ID__c order by CreatedDate desc Limit 1];
        stdCtrl = new ApexPages.StandardController(laoObj);
        laserArtworkPage = new IMP_Subproject_On_Laser_Extension(stdCtrl);
        laserArtworkPage.getSubprojectDetails();
        System.assertEquals(null, laserArtworkPage.sperObj, 'Unexpected value for Subproject External Reference Object');
        test.stopTest();
    }
    
    //to perform negitive test
    public static testmethod void negitiveTest()
    {
        IMP_UpdateFormsOrder_Handler.updateFormOrders(null,null);
    }
}