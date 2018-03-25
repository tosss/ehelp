//2015-11-27 : vishal.bandari@cdk.com    RQ-05289:changed methods to add contact record type
@IsTest
public class DS_LAO_ApprovalProcess_Test
{  
    
    public static testMethod void InsertNewLaoRecord()
    {
        DS_LAO_ApprovalProcess_Test.FieldValueConditions();
        DS_LAO_ApprovalProcess_Test.ApprovalProcessSettings();
        User u = CreateUser();
                
        Account a = new Account();
        a.Name = 'TEst1';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'test1';
        c.LastName = 'Test2';
        c.AccountId = a.Id;
        c.Role__c = 'Test Role'; // 9/29
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        test.startTest();
        ID LaserImagingId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Laser_Artwork_Order__c', 'Laser Imaging');
        
        List<Forms_OwnerFieldSetting__c> LaserApprovalFields = GenerateLaserApprovalProcessSettings();
        Laser_Artwork_Order__c lao = new Laser_Artwork_Order__c();
        lao.Contact__c = c.Id;
        lao.Order_Type__c = 'New Install - Elite';
        lao.Order_Status__c = 'Artwork to LFD Team';
        lao.Revision__c = null;
        lao.Order_Priority__c = 'Standard';
        lao.Stock_Order__c = '11111';
        lao.Prev_SO__c = '99999';
        lao.Contract_PO__c = '77777';
        lao.Change_Notes__c = 'Notes';
        lao.Artwork_to_LFD_Team__c = DateTime.Now();
        lao.Binder_Sent__c = DateTime.now();
        lao.Artwork_Due_Date__c = DateTime.Now()+10;  
        lao.LFD_Name__c = u.Id;
        lao.Project__c = '123456';
        lao.RecordTypeId = LaserImagingId;
        Lao.Contact__c = c.ID;
        insert lao;
         
        // insert task objects to cover the future update methods in the DS_LAO_ApprovalProcess Class
       /* List<Task> TaskListToInsert = new List<Task>();
        Task t1 = new Task();
        t1.Subject = 'Proofs Follow-up';
        t1.WhatId = lao.Id;
        t1.ActivityDate = Date.today().addDays(3);
        TaskListToInsert.add(t1);
        
        Task t2 = new Task();
        t2.Subject = 'Quote Follow-up';
        t2.WhatId = lao.Id;
        t2.ActivityDate = Date.today().addDays(3);
        TaskListToInsert.add(t2);
        
        Insert TaskListToInsert;*/
        
        lao.Order_Type__c = 'New Install - Elite';
        lao.Order_Status__c = 'AWIP';
        lao.Artwork_to_LFD_Team__c = DateTime.Now();    
        lao.Artwork_Due_Date__c = DateTime.Now().addDays(10);    
        lao.Project__c = '35000';
        lao.Binder_Sent__c = DateTime.now(); 
        lao.Quote_Sheet_Approved__c = DateTime.now();
        lao.Revision__c = null;//'2';
        lao.Last_Approval_Status__c = 'Approved';
        update lao;       
       	test.stopTest();
    } 
    
    
    
    
    
    public static testMethod void InsertNewLaoRecord2()
    {
        DS_LAO_ApprovalProcess_Test.FieldValueConditions();
        DS_LAO_ApprovalProcess_Test.ApprovalProcessSettings();
       
        User u = CreateUser();
        
        Account a = new Account();
        a.Name = 'TEst1';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'test1';
        c.LastName = 'Test2';
        c.AccountId = a.Id;
        c.Role__c = 'Test Role'; // 9/29
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        c.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert c;
        
        list<Laser_artwork_Order__c> LaoList = new list<Laser_artwork_Order__c>();
        List<Forms_OwnerFieldSetting__c> LaserApprovalFields = GenerateLaserApprovalProcessSettings();        
        
        Laser_Artwork_Order__c lao2 = new Laser_Artwork_Order__c();
        lao2.Order_Type__c = 'Add/Change - Elite';
        Lao2.Order_Status__c = 'Q/S Submitted';     
        lao2.Proofs_Required__c = 'yes';
        Lao2.LIS_Info_Received__c = 'yes';
        Lao2.LAS_Name__c = UserInfo.getUserId();
        lao2.Contact__c = c.ID;
        
        Insert Lao2;
                
        Lao2.Order_Status__c = 'AWIP';
        Lao2.Artwork_to_LFD_Team__c = DateTime.now().addDays(1);
        Lao2.Artwork_Due_Date__c = DateTime.now().addDays(3);
        Lao2.LFD_Name__c = u.Id;
        Update Lao2;
        
    }
    
    public static testMethod void testForApprovalTriggerHandler()
    {
        DS_LAO_ApprovalProcess_Test.createTaskSettings();
        DS_LAO_ApprovalProcess_Test.FieldValueConditions();
        DS_LAO_ApprovalProcess_Test.ApprovalProcessSettings();
        Contact con = DS_TestObjects.NewContact_Inserted();
        User u = CreateUser();
        List<Forms_OwnerFieldSetting__c> LaserApprovalFields = GenerateLaserApprovalProcessSettings();
       
        System.runAs(u)
        {
            test.startTest();
            Laser_Artwork_Order__c lao = DS_TestObjects.NewLaserArtworkOrder();                
            lao.Order_Type__c = 'Buy/Sell - Elite';
            lao.Order_Status__c = 'Proofs to LAS';
            lao.Artwork_to_LFD_Team__c = DateTime.Now();   
            lao.Artwork_Due_Date__c = DateTime.Now()+10; 
            lao.Proofs_to_LAS__c = DateTime.now().addDays(1);
            lao.Revision__c = '4';
            lao.Contact__c = con.ID;
            
            insert lao; 
            
            Laser_Artwork_Order__c lao2 = DS_TestObjects.NewLaserArtworkOrder();                
            lao2.Order_Type__c = 'q/s approved';
            lao2.Order_Status__c = 'Proofs to LAS';
            lao2.Artwork_to_LFD_Team__c = DateTime.Now();   
            lao2.Artwork_Due_Date__c = DateTime.Now()+10; 
            lao2.Proofs_to_LAS__c = DateTime.now().addDays(1);
            lao2.Revision__c = '4';
            lao2.Contact__c = con.ID;
            
            insert lao2; 
           
           test.stopTest();
            
            //2016-03-21  ragashalini.koka@cdk.com - created tasks for Laser_Artwork_Order__c
          /*  List<Task> TaskListToInsert = new List<Task>();
            Task t1 = new Task();
            t1.Subject = 'Proofs Follow-up';
            t1.WhatId = lao.Id;
            t1.ActivityDate = Date.today().addDays(3);
            TaskListToInsert.add(t1);
            
            Task t2 = new Task();
            t2.Subject = 'Quote Follow-up';
            t2.WhatId = lao.Id;
            t2.ActivityDate = Date.today().addDays(3);
            TaskListToInsert.add(t2);
            
            Task t3 = new Task();
            t3.Subject = 'Welcome Kit Follow up';
            t3.WhatId = lao.Id;
            t3.ActivityDate = Date.today().addDays(3);
            TaskListToInsert.add(t3);
            
            Task t4 = new Task();
            t4.Subject = 'completed';
            t4.WhatId = lao.Id;
            t4.ActivityDate = Date.today().addDays(3);
            t4.Status = 'completed';
            TaskListToInsert.add(t4);
            
            insert TaskListToInsert;*/
            List<Task> tasksToUpdateList = [SELECT Id FROM Task WHERE WhatId = :lao.Id limit 1];
            if(tasksToUpdateList.size() > 0) {
                tasksToUpdateList[0].Status = 'complete';
                update tasksToUpdateList;
            }
            
            lao.Order_Type__c = 'Add/Change - Elite';
            lao.Order_Status__c = 'q/s approved';
            lao.Proofs_Required__c = 'yes';
            lao.LIS_Info_Received__c = 'yes';
            lao.LAS_Name__c = u.Id;
            lao.LFD_Name__c = u.Id;
            lao.LIS_Name__c = u.Id;
            lao.Quote_Sheet_Submitted__c = DateTime.now();
            
            update lao;
            
             
            
            
            lao.Order_Type__c = 'Add/Change – Elite';
            lao.Order_Status__c = 'approved';
            
            Update lao;
            
            lao.Is_Approved__c = DateTime.Now();
            lao.Order_Type__c = 'Add/Change – Elite';
            lao.Order_Status__c = 'Forms Collected';
            
            Update lao;
            
            //2016-03-21  ragashalini.koka@cdk.com  - added new values to update
         
            lao.Revision__c = '13';
            Update lao;   
           
                                 
        }
    }
    
    public static testMethod void getCreateTaskSettingsWithIdentifierAsKeyTest() {
        DS_LAO_ApprovalProcess_Test.createTaskSettings();
        DS_LAO_ApprovalProcess.getCreateTaskSettingsWithIdentifierAsKey();
    }
    
    public static testMethod List<Forms_OwnerFieldSetting__c> GenerateLaserApprovalProcessSettings()
    {
        List<Forms_OwnerFieldSetting__c> LaserApprovalFields = new List<Forms_OwnerFieldSetting__c>();
        
        LaserApprovalFields.add(new Forms_OwnerFieldSetting__c(
            Name = '1', Owner_to_LAS__c = True, Owner_to_LFD__c = True, Owner_to_LIS__c = True, 
            Rejected_LAS__c = True, 
            Rejected_LFD__c = True, Record_Type__c = 'Laser Imaging', Identifier__c = '006 AND 010'));
        
        LaserApprovalFields.add(new Forms_OwnerFieldSetting__c(
            Name = '2', Owner_to_LAS__c = True, Owner_to_LFD__c = True, Owner_to_LIS__c = True, 
            Rejected_LAS__c = True, 
            Rejected_LFD__c = True, Record_Type__c = 'Laser Imaging', Identifier__c = '005 AND 011'));
        
        LaserApprovalFields.add(new Forms_OwnerFieldSetting__c(
            Name = '3',  Record_Type__c = 'Laser Imaging', Identifier__c = '008 AND 010', Rejected_LAS__c = True,  Rejected_LFD__c = True));
        
        LaserApprovalFields.add(new Forms_OwnerFieldSetting__c(
            Name = '4',  Record_Type__c = 'Laser Imaging', Identifier__c = '007 AND 011', Assigned_Forms_Builder__c = True, Rejected_LAS__c = True,  Rejected_LFD__c = True));
        
        LaserApprovalFields.add(new Forms_OwnerFieldSetting__c(
            Name = '5', Owner_to_LAS__c = True, Record_Type__c = 'Laser Imaging', Identifier__c = '004 AND 010', Assigned_Forms_Builder__c = True, 
            Rejected_LAS__c = True,  Rejected_LFD__c = True));
        
        LaserApprovalFields.add(new Forms_OwnerFieldSetting__c(
            Name = '6', Owner_to_LFD__c = True, Record_Type__c = 'Laser Imaging', Identifier__c = '005 AND 010', Assigned_Forms_Builder__c = True));
        
        LaserApprovalFields.add(new Forms_OwnerFieldSetting__c(
            Name = '7',  Owner_to_LIS__c = True, Record_Type__c = 'Laser Imaging', Identifier__c = '001 AND 010', Assigned_Forms_Builder__c = True));
        
        LaserApprovalFields.add(new Forms_OwnerFieldSetting__c(
            Name = '8', Rejected_LAS__c = True, Record_Type__c = 'Laser Imaging', Identifier__c = '005 AND 011', Assigned_Forms_Builder__c = True,
        	Rejected_FCC__c = True));
        
        LaserApprovalFields.add(new Forms_OwnerFieldSetting__c(
            Name = '9', Rejected_LFD__c = True, Record_Type__c = 'Laser Imaging', Identifier__c = '004 AND 010', Assigned_Forms_Builder__c = True,
        	Rejected_FCC__c = True));
        
         LaserApprovalFields.add(new Forms_OwnerFieldSetting__c(
            Name = '10', Rejected_LFD__c = True, Record_Type__c = 'Laser Imaging', Identifier__c = '004', Assigned_Forms_Builder__c = True,
         	Rejected_FCC__c = True, Rejected_LAS__c = True));
     
        insert LaserApprovalFields;
        return LaserApprovalFields;
    }
    
    public static testMethod User CreateUser()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name= 'ADPDS - Inside Sales/Laser - LSR'];
        
        User NewUser = DS_TestObjects.NewUser();
        NewUser.ProfileId = p.Id;
        NewUser.FederationIdentifier = 'testuser';    
        
        insert NewUser;
        return NewUser;                
    }
    public static testMethod list<Field_Value_Conditions__c> FieldValueConditions()
    {
        list<Field_Value_Conditions__c> FieldValuesList = new List<Field_Value_Conditions__c>();
        FieldValuesList.add(new Field_Value_Conditions__c(Name='001', Field_Name__c='Order_Status__c', Field_Value__c='At LI Team', Identifier__c='001'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='002', Field_Name__c='Order_Status__c', Field_Value__c='Approved', Identifier__c='002'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='003', Field_Name__c='Order_Status__c', Field_Value__c='Burned', Identifier__c='003'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='004', Field_Name__c='Order_Status__c', Field_Value__c='Proofs to LAS', Identifier__c='004'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='005', Field_Name__c='Order_Status__c', Field_Value__c='AWIP', Identifier__c='005'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='006', Field_Name__c='Order_Status__c', Field_Value__c='Artwork to LFD Team', Identifier__c='006'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='007', Field_Name__c='Order_Status__c', Field_Value__c='Awaiting Approval', Identifier__c='007'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='008', Field_Name__c='Order_Status__c', Field_Value__c='Q/S Submitted', Identifier__c='008'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='009', Field_Name__c='Order_Type__c', Field_Value__c='Buy/Sell - Elite', Identifier__c='009'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='010', Field_Name__c='Order_Type__c', Field_Value__c='Add/Change - Elite', Identifier__c='010'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='011', Field_Name__c='Order_Type__c', Field_Value__c='New Install - Elite', Identifier__c='011'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='012', Field_Name__c='Order_Type__c', Field_Value__c='Add/Change - ELF', Identifier__c='012'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='013', Field_Name__c='Order_Type__c', Field_Value__c='New Install - ELF', Identifier__c='013'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='014', Field_Name__c='Order_Type__c', Field_Value__c='Buy/Sell - ELF', Identifier__c='014'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='015', Field_Name__c='Order_Type__c', Field_Value__c='Add/Change - DASH', Identifier__c='015'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='016', Field_Name__c='Order_Type__c', Field_Value__c='New Install - DASH', Identifier__c='016'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='017', Field_Name__c='Order_Type__c', Field_Value__c='Buy/Sell - DASH', Identifier__c='017'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='018', Field_Name__c='Welcome_kit_sent__c', Field_Value__c='Not Null', Identifier__c='018'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='019', Field_Name__c='Estimated_Transition_Date__c', Field_Value__c='Not Null', Identifier__c='019'));
        FieldValuesList.add(new Field_Value_Conditions__c(Name='020', Field_Name__c='Date_Forms_Shipped__c', Field_Value__c='Null', Identifier__c='020'));
        
        insert FieldValuesList;
        return FieldValuesList;
    }
    public static testMethod List<Create_Task_Settings__c> createTaskSettings()
    {
        List<Create_Task_Settings__c> ctsSettings = new List<Create_Task_Settings__c>();
        ctsSettings.add(new Create_Task_Settings__c(Name='001',Assigned_to__c='LAS_Name__c',Assignee_sObject__c='Laser_Artwork_Order__c',
                                                    BusinessDays__c='3',Identifier__c='004 AND 009',Record_Type__c='Laser Imaging',
                                                    Reference_Date__c='Today',sObject__c='Laser_Artwork_Order__c',Task_Subject_Type__c='Proofs Follow-up',
                                                   Who__c='Contact__c',Close_Completed_Tasks__c=True));
        ctsSettings.add(new Create_Task_Settings__c(Name='002',Assigned_to__c='LAS_Name__c',Assignee_sObject__c='Laser_Artwork_Order__c',
                                                    BusinessDays__c='Special Condition',Identifier__c='005 AND 011',Record_Type__c='Laser Imaging',
                                                    Reference_Date__c='Today',sObject__c='Laser_Artwork_Order__c',Task_Subject_Type__c='Welcome Kit Follow up',
                                                   Who__c='Contact__c', Number_of_Weeks__c='-2',Week_Day__c='Friday'));
        ctsSettings.add(new Create_Task_Settings__c(Name='003',Assigned_to__c='LAS_Name__c',Assignee_sObject__c='Laser_Artwork_Order__c',
                                                    BusinessDays__c='Special Condition',Identifier__c='005 AND 011',Record_Type__c='Laser Imaging',
                                                    Reference_Date__c='Tomorrow',sObject__c='Laser_Artwork_Order__c',Task_Subject_Type__c='completed',
                                                   Who__c='Contact__c', Number_of_Weeks__c='-2',Week_Day__c='Friday'));
        ctsSettings.add(new Create_Task_Settings__c(Name='004',Assigned_to__c='LAS_Name__c',Assignee_sObject__c='Laser_Artwork_Order__c',
                                                    BusinessDays__c='3',Identifier__c='004 AND 009',Record_Type__c='Laser Imaging',
                                                    Reference_Date__c='Today',sObject__c='Laser_Artwork_Order__c',Task_Subject_Type__c='Welcome Kit Follow up',
                                                   Who__c='Contact__c',Close_Completed_Tasks__c=True));
        ctsSettings.add(new Create_Task_Settings__c(Name='005',Assigned_to__c='LAS_Name__c',Assignee_sObject__c='Laser_Artwork_Order__c',
                                                    BusinessDays__c='3',Identifier__c='004 AND 009',Record_Type__c='Laser Imaging',
                                                    Reference_Date__c='Today',sObject__c='Laser_Artwork_Order__c',Task_Subject_Type__c='Quote Follow-up',
                                                   Who__c='Contact__c',Close_Completed_Tasks__c=True));
        
        insert ctsSettings;        
        return ctsSettings;        
    }
    public static testMethod list<ALL_Approval_Process__c> ApprovalProcessSettings()
    {
        list<ALL_Approval_Process__c> APsettings = new list<ALL_Approval_Process__c>();
        
        APsettings.add(new ALL_Approval_Process__c(Name='001',Identifier__c='006 AND 011',Record_Type__c='Laser Imaging',sObject__c='Laser_Artwork_Order__c'));
        
        insert APsettings;        
        return APsettings;
        
    }
}