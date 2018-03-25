/*******************************************************************************
*  2016-08-23 ragashalini.koka@cdk.com - RQ-07383 Created this class 
*  Description : Test class for ALL_UpdateEmail_Controller
* *****************************************************************************/
//2017-05-17 - lalitha.adduru@cdk.com commented references to DESIGNATED_DSM_NAT_ENT__C as part of RQ-09180

@isTest
public class ALL_UpdateEmail_Test {
    
    @testSetup static void setupTestData() {
        
        List<Update_Email_Fields__c> updateEmailFieldsList = new List<Update_Email_Fields__c>();
        
        List<String> namesList = new List<String>{'Object-001', 'Object-002'};
        List<String> objectsList = new List<String>{'Lead', 'Order_Accuracy__c'};
        List<String> fieldsetsList = new List<String>{'Batch_Field_Updates', null};
        List<Boolean> runBatchStatusList = new List<Boolean>{true, false};
        List<String> conditionList = new List<String>{'Company like \'test\'', null};
            
            for(Integer i = 0;i < namesList.size();i++) {
                Update_Email_Fields__c updateEmailFieldRef = new Update_Email_Fields__c();
                updateEmailFieldRef.Name = namesList[i];
                updateEmailFieldRef.Object_API_Name__c = objectsList[i];
                updateEmailFieldRef.FieldSet_API__c = fieldsetsList[i];
                updateEmailFieldRef.Run_Batch__c = runBatchStatusList[i];
                updateEmailFieldRef.Log_Exception__c = true;
                updateEmailFieldsList.add(updateEmailFieldRef);
            }
        
        insert updateEmailFieldsList;
        
        List<Update_Email_Fields_Data__c> updateEmailFieldsDataList = new List<Update_Email_Fields_Data__c>();
        namesList = new List<String>{'Field-001','Field-002'};
        List<String> sourceFieldList = new List<String>{'OwnerId', 'Contact__c'}; 
        List<String> destinationFieldList = new List<String>{'Lead_Owner_Mgr_Email__c', 'Email'}; 
        List<String> objectAPIList = new List<String>{'Lead', 'Lead'}; 
        List<String> referenceObjectList = new List<String>{'User', 'Contact'}; 
        List<String> referenceFieldList = new List<String>{'Manager.Email', 'Email'};
        
            for(Integer i = 0;i < namesList.size();i++) {
                Update_Email_Fields_Data__c updateEmailFieldDataRef = new Update_Email_Fields_Data__c();
                updateEmailFieldDataRef.Name = namesList[i];
                updateEmailFieldDataRef.Destination_Field__c = destinationFieldList[i];
                updateEmailFieldDataRef.Object_API_Name__c = objectAPIList[i];
                updateEmailFieldDataRef.Reference_Field__c = referenceFieldList[i];
                updateEmailFieldDataRef.Reference_Object__c = referenceObjectList[i];
                updateEmailFieldDataRef.Source_Field__c = sourceFieldList[i];
                updateEmailFieldsDataList.add(updateEmailFieldDataRef);
               
            }
         insert updateEmailFieldsDataList;
        
        Job_Settings__c jobSetting = new Job_Settings__c();
        jobSetting.Name = '6.Update_Email_Batch';
        jobSetting.Class_Name__c = 'ALL_Update_Email_Batch';
        jobSetting.Finish_Emails__c = 'ragashalini.koka@cdk.com';
        insert jobSetting;
       
        
        Contact contactRef = DS_TestObjects.NewContact();
        ALL_SharedContact_Helper.insertContact(contactRef, null, null, null);
        
        List<Lead> leadList = new List<Lead>();
        
        for(Integer i = 0;i < 2;i++) {
            Lead leadRef = DS_TestObjects.NewLead();
            leadRef.OwnerId = UserInfo.getUserId();
            leadRef.Contact__c = contactRef.Id;
            leadList.add(leadRef);
        } 
        insert leadList;    
        
    
        User testUser1 = DS_TestObjects.NewUser();
        testUser1.Alias = 'Test';
        testUser1.Title = 'DSM Test';
        insert testUser1;
        
        User testUser2 = DS_TestObjects.NewUser();
        testUser2.FirstName = 'first test';
        testUser2.LastName = 'last test';
        testUser2.Email = 'test2@test.com';
        testUser2.Title = 'DSM Test';
        insert testUser2;
       
        Account acc = DS_TestObjects.NewAccount();
        acc.Digital_Sales_Consultant__c = testUser1.Id;
        acc.Designated_DSM__c = testUser1.Id;
        //acc.Designated_DSM_Nat_Ent__c = testUser1.Id; -- by lalitha
        insert acc;
        
        
       
        Launch__c launchRef = DS_TestObjects.NewLaunch();
        launchRef.Account__c = acc.Id;
        insert launchRef;
        
        Case caseRef = DS_TestObjects.NewCase();
        caseRef.AccountId = acc.Id;
        insert caseRef;
        
        List<Order_Accuracy__c> orderAccuracyList = new List<Order_Accuracy__c>();
        
        for(Integer i = 0;i < 2;i++) {
            Order_Accuracy__c orderAccuracy = new Order_Accuracy__c();
            orderAccuracy.MDA_Incorrect_Data__c = true;
            orderAccuracy.MDA_Incorrect_Data_Count__c = 1;
            
            if(Math.mod(i, 2) == 0) {
                orderAccuracy.Launch__c = launchRef.Id;
            }
            else {
                orderAccuracy.Case__c = caseRef.Id;
            }
            orderAccuracyList.add(orderAccuracy);
        }
        
        insert orderAccuracyList;
        
        
    }
    
    static testMethod void validateEmailFieldsUpdateWithSingleJob() {
        
        List<AsyncApexJob> apexJobList = [
            select id 
            from AsyncApexJob 
            where Status='Completed' 
            and JobType='BatchApex'
        ];
        
        test.startTest();
        Contact conRef = [SELECT Id FROM Contact LIMIT 1];
        conRef.Email = 'change@test.com';
        update conRef;
        new ALL_UpdateEmail_Controller();
        test.stopTest();
        
        List<AsyncApexJob> newApexJobList = [
            select id 
            from AsyncApexJob
            where Status='Completed'
            and JobType='BatchApex'
        ];
        System.assert(newApexJobList.size() > apexJobList.size());
    }
    
    static testMethod void validateEmailFieldUpdateWithMultipleJobs() {
        
        List<Update_Email_Fields__c> updateEmailFieldsList = Update_Email_Fields__c.getAll().values();
        
        for(Update_Email_Fields__c ref : updateEmailFieldsList) {
            ref.Run_Batch__c = true;
        }
        update updateEmailFieldsList;
        
         List<AsyncApexJob> apexJobList = [
            select Id 
            from AsyncApexJob 
            where Status='Completed' 
            and JobType='BatchApex'
        ];
        
        test.startTest();
        new ALL_UpdateEmail_Controller();
        test.stopTest();
        
        List<AsyncApexJob> newApexJobList = [
            select Id 
            from AsyncApexJob
            where Status='Completed'
            and JobType='BatchApex'
        ];
        System.assert(newApexJobList.size() > apexJobList.size());
    }
    
    static testMethod void validateUpdateEmailScheduler() {
        
        test.startTest();
        String[] dateOfTomorrow = String.valueof(System.today().addDays(1)).split('-'); 
        String cronExpression = '0 0 0 ' + dateOfTomorrow[2] + ' ' + dateOfTomorrow[1] + ' ? ' + dateOfTomorrow[0];
        System.schedule('Update Email Scheduler', cronExpression, new ALL_UpdateEmail_Scheduler());
        test.stopTest();
        
    }
    static testMethod void validateMiscellaneous1() {
        Account acc1 = [SELECT Id FROM Account LIMIT 1];
        User usr1 = [SELECT Id FROM User WHERE Name LIKE '%first test%' ORDER BY CreatedDate desc LIMIT 1];
        acc1.Digital_Sales_Consultant__c = usr1.Id;
        acc1.Designated_DSM__c = usr1.Id;
        //acc1.Designated_DSM_Nat_Ent__c = usr1.Id; --  by lalitha
        update acc1;
        
        User usr2 = [SELECT Id FROM User WHERE Alias LIKE '%Test%' ORDER BY CreatedDate desc LIMIT 1];
        usr1.ManagerId = usr2.Id;
        update usr1;
        ALL_Update_Email_Batch.updateOrderAccuracyEmailFields(Database.query(ALL_UpdateEmail_Controller.buildQuery('Order_Accuracy__c', null, null,null)));
        
        
    }
    
    static testMethod void validateMiscellaneous2() {
        
        Lead leadRec = [SELECT Id FROM Lead LIMIT 1];
        User usr1 = [SELECT Id, LastName FROM User WHERE Name LIKE '%first test%' ORDER BY CreatedDate desc LIMIT 1];
        usr1.LastName += 'retired';
        update usr1;
        leadRec.OwnerId = usr1.Id;
        update leadRec;
        ALL_Update_Email_Batch.getData('Lead',Database.query(ALL_UpdateEmail_Controller.buildQuery('Lead', null, null,null)));
    }
    
   

}