/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   To Test IMP_SperToFormsOrderUpdate_Handler
Created on:    07 September 2015.
Code Coverage: 100%
------------------------------------------------------------
History
15 July 2015    Vishal Bandari          RQ-04982: Added setUpTestData, validateHandler method
2015-11-04      vishal.bandari@cdk.com  RQ-05690: Added code to test update on Estimated_Install_Date__c field in Laser_Artwork_Order__c
2015-12-15      vishal.bandari@cdk.com  RQ-05934: Added code to update Subproject__c field in Laser_Artwork_Order__c
2015-12-15      vishal.bandari@cdk.com  RQ-05938: Added code to test update on Client_Manager__c field in Laser_Artwork_Order__c
2015-12-22      venkata.shrivol@cdk.com	added DS_TestObjects reference for creation of laser objects in test setup
------------------------------------------------------------*/
@IsTest
public class IMP_SperToFormsOrderUpdate_Test 
{
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
        insert subprojectObj;
        
        Account acc = new Account();
        acc.Name = 'Sample Account';
        insert acc;
        
        CMF_Info__c cmf = new CMF_Info__c();
        cmf.Name = 'Sample CMF';
        cmf.Account__c = acc.Id;
        insert cmf;
        
        List<Laser_Artwork_Order__c> laoList = new List<Laser_Artwork_Order__c>();
        //Inserting Sample Laser_Artwork_Order__c or Forms_Order__c object
        Laser_Artwork_Order__c laoObj = DS_TestObjects.NewLaserArtworkOrder();
        laoObj.Ship_CMF_Info__c = cmf.id;
        laoList.add(laoObj);
        
        //Inserting Sample Laser_Artwork_Order__c or Forms_Order__c object
        Laser_Artwork_Order__c laoObj2 = DS_TestObjects.NewLaserArtworkOrder();
        laoObj.Ship_CMF_Info__c = cmf.id;
        laoList.add(laoObj2);
        
        insert laoList;
        
        //Insert SubProject_External_Reference__c object to relate SubProject and Forms_Order__c
        SubProject_External_Reference__c sperobj = new SubProject_External_Reference__c();
        sperObj.LAO_ID__c = laoObj.id;
        sperObj.Project__c = projectObj.Id;
        sperObj.SubProject__c = subprojectObj.Id;
        insert sperObj;
        
    }
    
    public static testmethod void validateHandler()
    {
        test.startTest();
        
        //2015-11-06 vishal.bandari@cdk.com RQ-05690 added Business_Alignment_Workshop_Date__c and Estimated_Install_Date_EID__c fields in SOQL
        //2015-12-15 vishal.bandari@cdk.com RQ-05934 added Subproject__c fields in SOQL
        //2015-12-15 vishal.bandari@cdk.com RQ-05938 added Client_Manager__c fields in SOQL
        
        SubProject_External_Reference__c sperobj = [
            SELECT ID, Subproject__c, Subproject__r.Name, Subproject__r.Go_Live_Date__c,
            Subproject__r.Confidential__c, Subproject__r.Project_Manager__c, Subproject__r.Contract_Roll_Called__c,
            Subproject__r.Impact_Project_Numbers__c,Subproject__r.Estimated_Install_Date_EID__c, Subproject__r.Training_Implementation_Client_Mgr__c,
            LAO_ID__r.Go_Live_Date__c, LAO_ID__r.Subproject__c,LAO_ID__r.Project_Manager__c, LAO_ID__r.Confidential__c, 
            LAO_ID__r.Roll_Call_Date__c, LAO_ID__r.Impact_Project_Numbers__c , LAO_ID__r.Estimated_Install_Date__c, LAO_ID__r.Client_Manager__c
            FROM SubProject_External_Reference__c 
            Order by CreatedDate 
            LIMIT 1 
        ];
        
        System.assertEquals(sperobj.Subproject__r.Go_Live_Date__c, sperobj.LAO_ID__r.Go_Live_Date__c,'Go_Live_Date__c field is not updated');
        System.assertEquals(sperobj.Subproject__r.Project_Manager__c, sperobj.LAO_ID__r.Project_Manager__c,'Project_Manager__c field is not updated');
        System.assertEquals(sperobj.Subproject__r.Contract_Roll_Called__c, sperobj.LAO_ID__r.Roll_Call_Date__c,'Roll_Call_Date__c field is not updated');
        System.assertEquals(sperobj.Subproject__r.Confidential__c, sperobj.LAO_ID__r.Confidential__c,'Confidential__c field is not updated');
        System.assertEquals(sperobj.Subproject__r.Impact_Project_Numbers__c, sperobj.LAO_ID__r.Impact_Project_Numbers__c,'Impact_Project_Numbers__c field is not updated');
        System.assertEquals(sperobj.Subproject__r.Estimated_Install_Date_EID__c, sperobj.LAO_ID__r.Estimated_Install_Date__c,'Estimated_Install_Date__c field is not updated');
        System.assertEquals(sperobj.Subproject__r.Name, sperobj.LAO_ID__r.Subproject__c,'Subproject__c field is not updated');
        System.assertEquals(sperobj.Subproject__r.Training_Implementation_Client_Mgr__c, sperobj.LAO_ID__r.Client_Manager__c,'Client_Manager__c field is not updated');
        
        test.stopTest();
        
    }
}