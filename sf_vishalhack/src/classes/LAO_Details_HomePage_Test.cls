/*------------------------------------------------------------
Author:        Vishal Bandari
Description:   Test Class to test LAO_Details_HomePage_Controller Class 
Created on:    6 August 2015.
Code Coverage: 100%
------------------------------------------------------------
History
2015-08-06     Vishal Bandari           RQ-05120: Created
2015-12-22     matt.keefe@cdk.com       updated for Contact validation error
2016-06-07     venkata.shrivol@cdk.com -updated this test Class with runAs methods because of the sharing access of subProjects 
2016-06-16     venkata.shrivol@cdk.com - added CR test records after account and contact insertion. 
2016-07-25     vishal.bandari@cdk.com   RQ-07423 : Update Profile 'ADPDS - Laser - LIS' to 'CDK - FFC - Laser'
2016-12-02     venkata.shrivol@cdk.com	RQ-08305 :commented the project object reference in the code. 
2017-04-19     venkata.shrivol@cdk.com  updated the code at different places - code clean-up
------------------------------------------------------------*/
@IsTest
public with sharing class LAO_Details_HomePage_Test {
    
    static LAO_Details_HomePage_Controller page;
    static User userObj;
    
    @testSetup
    public static void setUpTestData()
    {
        
        Profile adminProfile = [select Id from Profile where Name='ADPDS - Admin - System Administrator' limit 1];
        
        UserRole upperHierarchyRole = new UserRole(Name='UpperHierarchy');
        insert upperHierarchyRole;
        
        UserRole lowerHierarchyRole = new UserRole(Name='LowerHierarchy', ParentRoleId=upperHierarchyRole.Id);
        insert lowerHierarchyRole;
		
		Profile p = [select id from profile where name = 'CDK - FFC - Laser'];
        
        list<User> usersToInsert = new list<User>();
        
        userObj = DS_TestObjects.NewUser();
        userObj.LastName = 'FCC User';
        userObj.ProfileId = p.id;
        userObj.UserRoleId = upperHierarchyRole.Id;
        //insert userObj;
        usersToInsert.add(userObj);   
        
        User u = DS_TestObjects.NewUser();
        u.FirstName = 'SystemAdminWithImpRole';
        u.profileId = adminProfile.Id;
        u.UserRoleId = lowerHierarchyRole.Id;
        //insert u;
        usersToInsert.add(u); 
        
        insert usersToInsert;
        
        Subproject__c subprojectObj;
        //Project__c projectObj;
        Account acc;
        CMF_Info__c cmf;
        system.runAs(u)
        {
            /*acc = new Account();
            acc.Name = 'Sample Account';
            insert acc;
            
            cmf = new CMF_Info__c();
            cmf.Name = 'Sample CMF';
            cmf.Account__c = acc.Id;
            insert cmf;*/
            
            //Inserting Sample Project__c
            /*projectObj = new Project__c();
            projectObj.Project_Region__c = 'CANADA-EAST';
            insert projectObj;*/
            
            //Inserting Sample SubProject__c
            subprojectObj = new Subproject__c();
            subprojectObj.SubProject_Name__c = 'Sample Subproject';
            //subprojectObj.Project__c = projectObj.Id;
            subprojectObj.SubProject_Region__c = 'CANADA-EAST';
            subprojectObj.Number_of_Rooftops__c = 12.0;
            subprojectObj.Project_Type__c = 'Unhook';
            subprojectObj.Number_of_User_Connections__c = 12.0;
            subprojectObj.Market__c = 'LightSpeed-Powersports';
            subprojectObj.Confidential__c = false;
            subprojectObj.Contract_Roll_Called__c = null;
            insert subprojectObj;	
            
            List<Laser_Artwork_Order__c> laoList1 = new List<Laser_Artwork_Order__c>();
            
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
            
            Id accountId = null;
            
            map<Id, Contact> ContactsByLaoId = new map<Id, Contact>();
            for(Laser_Artwork_Order__c order : laoList1) {
                Contact c = DS_TestObjects.NewContact();
                c.AccountId = order.Ship_CMF_Info__r.Account__c;
                accountId = order.Ship_CMF_Info__r.Account__c;
                ContactsByLaoId.put(order.Id, c);
            }
            insert ContactsByLaoId.values();
            
            for(Laser_Artwork_Order__c order : laoList1) {
                order.Contact__c = ContactsByLaoId.get(order.Id) != null ? ContactsByLaoId.get(order.Id).Id : null;
            }
            
            insert laoList1;
            
            list<Contact_Relationship__c> relationRecList = new list<Contact_Relationship__c>();
            
            
            /*for(Laser_Artwork_Order__c lao:[
                select Contact__c, Ship_CMF_Info__r.Account__c 
                from  Laser_Artwork_Order__c 
            ])
            {
                Contact_Relationship__c crt = IMP_TestFactory_Helper.buildContactRelationship(lao.Ship_CMF_Info__r.Account__c, lao.Contact__c);
                relationRecList.add(crt);
            }
			insert relationRecList;  */
            
            //Insert SubProject_External_Reference__c object to relate SubProject and Forms_Order__c
            SubProject_External_Reference__c sperobj = new SubProject_External_Reference__c();
            sperObj.LAO_ID__c = laoList1[0].id;
            //sperObj.Project__c = projectObj.Id;
            sperObj.SubProject__c = subprojectObj.Id;
            insert sperObj; 
        }
        
        
        
        //Insert vlaues with 'CDK - Laser - FCC' profile
        System.runAs(userObj)
        {
            Account acc2 = new Account();
            acc2.Name = 'Sample Account1';
            insert acc2;
            
            CMF_Info__c cmf2 = new CMF_Info__c();
            cmf2.Name = 'Sample CMF1';
            cmf2.Account__c = acc2.Id;
            insert cmf2;
            
            list<Laser_Artwork_Order__c> laoList1 = new List<Laser_Artwork_Order__c>();
            Laser_Artwork_Order__c laoObj = new Laser_Artwork_Order__c();
            laoObj.Ship_CMF_Info__c = cmf2.Id;
            laoObj.Contact__c = DS_TestObjects.NewContact_Inserted().Id;
            laoList1.add(laoObj);
            
            //Inserting Sample Laser_Artwork_Order__c or Forms_Order__c object
            Laser_Artwork_Order__c laoObj2 = new Laser_Artwork_Order__c();
            laoObj2.Ship_CMF_Info__c = cmf2.Id;
            laoObj2.Contact__c = DS_TestObjects.NewContact_Inserted().Id;
            laoList1.add(laoObj2);
            
            insert laoList1;
            
            list<Contact_Relationship__c> crtList = new list<Contact_Relationship__c>();
            
            /*for(Laser_Artwork_Order__c lao:[
                select Contact__c, Ship_CMF_Info__r.Account__c 
                from  Laser_Artwork_Order__c 
                where Ship_CMF_Info__c = :cmf2.Id])
            {
                Contact_Relationship__c crt = IMP_TestFactory_Helper.buildContactRelationship(lao.Ship_CMF_Info__r.Account__c, lao.Contact__c);
                crtList.add(crt);
            }
			insert crtList;*/
            
            //Insert SubProject_External_Reference__c object to relate SubProject and Forms_Order__c
            SubProject_External_Reference__c sperobj = new SubProject_External_Reference__c();
            sperObj.LAO_ID__c = laoList1[0].id;
            //sperObj.Project__c = projectObj.Id;
            sperObj.SubProject__c = subprojectObj.Id;
            insert sperObj;            
        }
        
        system.runAs(u)
        {
            //Inserting Sample Records for FormsOrderFieldsToProfile__c Custom Setting
            List<FormsOrderFieldsToProfile__c> fl = new List<FormsOrderFieldsToProfile__c>();
            FormsOrderFieldsToProfile__c foftp1 = new FormsOrderFieldsToProfile__c(Name ='1',Field_API_Name__c = 'Contact__c',Profile_Name__c = 'CDK - FFC - Laser' );
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
        User fccUser = [select id from user where LastName = 'FCC User' order by createddate desc Limit 1];
        system.debug(fccUser);
        
        page = new LAO_Details_HomePage_Controller();
        System.runAs(fccUser)
        {
            test.startTest();
            page = new LAO_Details_HomePage_Controller();
            page.self='all';
            page.getDetails();
            page.viewChanged();
            test.stopTest();
            
            system.debug(page.LAODetails_List);
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