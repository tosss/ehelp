/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Test Class to test LAO_Details_HomePage_Controller Class 
Created on:    6 August 2015.
Code Coverage: 100%
------------------------------------------------------------
History
2015-08-06     Vishal Bandari      RQ-05120: Created
2015-12-22     matt.keefe@cdk.com  updated for Contact validation error
------------------------------------------------------------*/
@IsTest
public class LAO_Details_HomePage_Test {
    
    static LAO_Details_HomePage_Controller page;
    static User userObj;
    
    @testSetup
    public static void setUpTestData()
    {
        Account acc = new Account();
        acc.Name = 'Sample Account';
        insert acc;
        
        CMF_Info__c cmf = new CMF_Info__c();
        cmf.Name = 'Sample CMF';
        cmf.Account__c = acc.Id;
        insert cmf;
        
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
        
        List<Laser_Artwork_Order__c> laoList1 = new List<Laser_Artwork_Order__c>();
        
        
        Profile p = [select id from profile where name = 'CDK - Laser - FCC'];
        
        
        userObj = DS_TestObjects.NewUser();
        userObj.LastName = 'FCC User';
        userObj.ProfileId = p.id;
        insert userObj;
        
        //for(Integer i=0;i<=8;i++)
        //{
        //    Laser_Artwork_Order__c laoObj3 = new Laser_Artwork_Order__c();
        //    laoObj3.Status__c= 'On Hold';
        //    laoObj3.Ship_CMF_Info__c = cmf.Id;
        //    laoList1.add(laoObj3);
        //}
        //insert laoList1;
        
        // 2015-12-22 matt.keefe@cdk.com - changed to standard TestObjects method and added Contacts
        laoList1.addAll(DS_TestObjects.NewLaserArtworkOrders());
        
        map<Id, Contact> ContactsByLaoId = new map<Id, Contact>();
        for(Laser_Artwork_Order__c order : laoList1) {
            Contact c = DS_TestObjects.NewContact();
            c.AccountId = order.Ship_CMF_Info__r.Account__c;
            ContactsByLaoId.put(order.Id, c);
        }
        insert ContactsByLaoId.values();
        
        for(Laser_Artwork_Order__c order : laoList1) {
            order.Contact__c = ContactsByLaoId.get(order.Id) != null ? ContactsByLaoId.get(order.Id).Id : null;
        }
        
        insert laoList1;
        
        //Insert SubProject_External_Reference__c object to relate SubProject and Forms_Order__c
        SubProject_External_Reference__c sperobj = new SubProject_External_Reference__c();
        sperObj.LAO_ID__c = laoList1[0].id;
        sperObj.Project__c = projectObj.Id;
        sperObj.SubProject__c = subprojectObj.Id;
        insert sperObj;
        
        //Insert vlaues with 'CDK - Laser - FCC' profile
        System.runAs(userObj)
        {
            acc = new Account();
            acc.Name = 'Sample Account1';
            insert acc;
            
            cmf = new CMF_Info__c();
            cmf.Name = 'Sample CMF1';
            cmf.Account__c = acc.Id;
            insert cmf;
            
            laoList1 = new List<Laser_Artwork_Order__c>();
            
            for(Integer i=0;i<6;i++)
            {
                Laser_Artwork_Order__c laoObj = new Laser_Artwork_Order__c();
                laoObj.Ship_CMF_Info__c = cmf.Id;
                laoObj.Contact__c = DS_TestObjects.NewContact_Inserted().Id;
                laoList1.add(laoObj);
            }
            
            
            
            insert laoList1;
            
            //Insert SubProject_External_Reference__c object to relate SubProject and Forms_Order__c
            sperobj = new SubProject_External_Reference__c();
            sperObj.LAO_ID__c = laoList1[0].id;
            sperObj.Project__c = projectObj.Id;
            sperObj.SubProject__c = subprojectObj.Id;
            insert sperObj;            
        }
        
        //Inserting Sample Records for FormsOrderFieldsToProfile__c Custom Setting
        List<FormsOrderFieldsToProfile__c> fl = new List<FormsOrderFieldsToProfile__c>();
        FormsOrderFieldsToProfile__c foftp1 = new FormsOrderFieldsToProfile__c(Name ='1',Field_API_Name__c = 'Contact__c',Profile_Name__c = 'ADPDS - Laser - LIS' );
        fl.add(foftp1);
        FormsOrderFieldsToProfile__c foftp2 = new FormsOrderFieldsToProfile__c(Name ='2',Field_API_Name__c = 'Name',Profile_Name__c = 'CDK - Laser - FCC' );
        fl.add(foftp2);
        FormsOrderFieldsToProfile__c foftp3 = new FormsOrderFieldsToProfile__c(Name ='3',Field_API_Name__c = 'Impact_Project_Numbers__c',Profile_Name__c = 'CDK - Laser - FCC' );
        fl.add(foftp3);
        FormsOrderFieldsToProfile__c foftp4 = new FormsOrderFieldsToProfile__c(Name ='4',Field_API_Name__c = 'Status__c',Profile_Name__c = 'CDK - Laser - FCC' );
        fl.add(foftp4);
        FormsOrderFieldsToProfile__c foftp5 = new FormsOrderFieldsToProfile__c(Name ='5',Field_API_Name__c = 'Subproject__c',Profile_Name__c = 'CDK - Laser - FCC' );
        fl.add(foftp5);
        insert fl;
    }
    
    //Test for Page Navigation and View Change
    public static testmethod void test1()
    {
        test.startTest();
        page = new LAO_Details_HomePage_Controller();
        page.getDetails();
        page.self = 'all';
        page.viewChanged();
        page.next();
        page.previous();
        test.stoptest();
        System.assert(page.LAODetails_List.size()>0,'Records Not Found');
    }
    
    //Test with 'ADPDS - Laser - FCC' profile user
    public static testmethod void test2()
    {
        userobj= [select id from user where LastName = 'FCC User' order by createddate desc Limit 1];
        page = new LAO_Details_HomePage_Controller();
        System.runAs(userObj)
        {
            test.startTest();
            page = new LAO_Details_HomePage_Controller();
            page.self='all';
            page.getDetails();
            page.viewChanged();
            test.stopTest();
            System.assert(page.LAODetails_List.size()>0,'Records Not Found');
        }
    }
    
    //Negitive Test with different field API name  and Forms Order deleted.
    public static testmethod void test3()
    {
        test.startTest();
        FormsOrderFieldsToProfile__c foftp6 = new FormsOrderFieldsToProfile__c(Name ='6',Field_API_Name__c = 'abc',Profile_Name__c = 'ADPDS - Laser - FCC' );
        insert foftp6;
        page = new LAO_Details_HomePage_Controller();
        page.getDetails();
        delete foftp6;
        System.assert(page.LAODetails_List==null,'Unexpected Result');
        List<Laser_Artwork_Order__c> laolist = [select id from Laser_Artwork_Order__c];
        page = new LAO_Details_HomePage_Controller();
        delete laolist;
        page.getDetails();
        System.assert(page.LAODetails_List==null,'Unexpected Result');
        test.stopTest();
    }
}