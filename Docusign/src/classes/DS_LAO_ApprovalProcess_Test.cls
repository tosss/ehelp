@IsTest
public class DS_LAO_ApprovalProcess_Test
{ 
    public static boolean testAidVariable = true; // this variable will facilitate the continuous execution of trigger even when All_CheckREcursive stops any
                                                  // Self recursive triggers.
    
    public static testMethod void OnlyInsertLaoRecordNoUpdate()
    {
        User LaserUser = CreateUser();
        
        System.runAs(LaserUser)
        {
            List<Laser_Approval_Process__c> LaserApprovalFields = GenerateLaserApprovalProcessSettings();
            Laser_Artwork_Order__c lao1 = new Laser_Artwork_Order__c();
            lao1.Order_Type__c = 'Add/Change - Elite';
            lao1.Order_Status__c = 'AWIP';//'At LI Team';
            lao1.LIS_Name__c = LaserUser.Id;
            lao1.LIS_Info_Received__c = 'yes';
            lao1.Proofs_Required__c = 'Yes';
            lao1.Artwork_to_LFD_Team__c = DateTime.Now(); 
            lao1.Revision__c = '4';
            lao1.Is_Approved__c = DateTime.Now();
            lao1.LFD_Name__c = userInfo.getUserId();
            insert Lao1;
            
            Task t1 = new Task(WhatId = lao1.ID,Subject = 'Quote Follow-up');                        
            Task t2 = new Task(WhatId = lao1.ID,Subject = 'Proofs Follow-up');
            insert new List<Task>{t1, t2};        
            update lao1;
        }
    } 
    
    public static testMethod void InsertNewLaoRecord()
    {
        User u = CreateUser();
        
        Account a = new Account();
        a.Name = 'TEst1';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'test1';
        c.LastName = 'Test2';
        c.AccountId = a.Id;
        c.Role__c = 'Test Role'; // 9/29
        insert c;
        
        List<Laser_Approval_Process__c> LaserApprovalFields = GenerateLaserApprovalProcessSettings();
        Laser_Artwork_Order__c lao = new Laser_Artwork_Order__c();
        lao.Contact__c = c.Id;
        lao.Order_Type__c = 'New Install - Elite';
        lao.Order_Status__c = 'Artwork to LFD Team';
        lao.Revision__c = '1';
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
        insert lao;
        
        lao.Order_Type__c = 'New Install - Elite';
        lao.Order_Status__c = 'AWIP';
        lao.Artwork_to_LFD_Team__c = DateTime.Now();    
        lao.Artwork_Due_Date__c = DateTime.Now().addDays(10);    
        lao.Project__c = '35000';
        lao.Binder_Sent__c = DateTime.now(); 
        lao.Quote_Sheet_Approved__c = DateTime.now();
        lao.Revision__c = '2';
        lao.Last_Approval_Status__c = 'Approved';
        update lao;     
    }
    
    public static testMethod void InsertNewLaoRecord2()
    {
        User u = CreateUser();
        
        Account a = new Account();
        a.Name = 'TEst1';
        insert a;
        
        Contact c = new Contact();
        c.FirstName = 'test1';
        c.LastName = 'Test2';
        c.AccountId = a.Id;
        c.Role__c = 'Test Role'; // 9/29
        insert c;
        
        list<Laser_artwork_Order__c> LaoList = new list<Laser_artwork_Order__c>();
        List<Laser_Approval_Process__c> LaserApprovalFields = GenerateLaserApprovalProcessSettings();
        Laser_Artwork_Order__c lao = new Laser_Artwork_Order__c();
        lao.Contact__c = c.Id;
        lao.Order_Type__c = 'Add/Change - Elite';
        lao.Order_Status__c = 'Artwork to LFD Team';
        lao.Quote_Sheet_Approved__c = DateTime.now();
        lao.Quote_Sheet_Submitted__c = DateTime.now();
        lao.Revision__c = '1';
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
        lao.LIS_Info_Received__c = 'yes';
        lao.Proofs_Required__c = 'yes';
        LaoList.add(lao);
        
        Laser_Artwork_Order__c lao1 = new Laser_Artwork_Order__c();
        lao1.Order_Type__c = 'Add/Change – Elite';
        lao1.Order_Status__c = 'Awaiting Approval';
        lao1.Artwork_to_LFD_Team__c = DateTime.Now();    
        lao1.Artwork_Due_Date__c = DateTime.Now().addDays(10);    
        lao1.Project__c = '35000';
        lao1.Binder_Sent__c = DateTime.now(); 
        lao1.Quote_Sheet_Approved__c = DateTime.now();
        lao1.Revision__c = '2';
        lao1.Last_Approval_Status__c = 'Approved';
        lao.LIS_Info_Received__c = 'yes';
        lao.Proofs_Required__c = 'yes';
        LaoList.add(Lao1);
        
        Insert LaoList;
    }
    
    public static testMethod void testForApprovalTriggerHandler()
    {
        User u = CreateUser();
        List<Laser_Approval_Process__c> LaserApprovalFields = GenerateLaserApprovalProcessSettings();
        
        System.runAs(u)
        {
            for(integer i=0; i<1; i++)
            {
                Laser_Artwork_Order__c lao = DS_TestObjects.NewLaserArtworkOrder();                
                lao.Order_Type__c = 'Buy/Sell - Elite';
                lao.Order_Status__c = 'Proofs to LAS';
                lao.Artwork_to_LFD_Team__c = DateTime.Now();   
                lao.Artwork_Due_Date__c = DateTime.Now()+10; 
                lao.Proofs_to_LAS__c = DateTime.now().addDays(1);
                lao.Revision__c = '4';
                
                insert lao; 
                
                lao.Order_Type__c = 'Buy/Sell - Elite';
                lao.Order_Status__c = 'Q/S Submitted';
                lao.LAS_Name__c = u.Id;
                lao.LFD_Name__c = u.Id;
                lao.LIS_Name__c = u.Id;
                DS_LAO_ApprovalProcess_Test.testAidVariable = true;
                update lao;
                
                lao.Order_Type__c = 'Add/Change – Elite';
                lao.Order_Status__c = 'Awaiting Approval';
                DS_LAO_ApprovalProcess_Test.testAidVariable = true;
                Update lao;
                
                lao.Is_Approved__c = DateTime.Now();
                lao.Order_Type__c = 'Add/Change – Elite';
                lao.Order_Status__c = 'Proofs to LAS';
                DS_LAO_ApprovalProcess_Test.testAidVariable = true;
                Update lao;
                
                lao.Order_Type__c = 'Add/Change – Elite';
                lao.Order_Status__c = 'AWIP';
                DS_LAO_ApprovalProcess_Test.testAidVariable = true;
                Update lao;
                
                lao.Order_Type__c = 'Add/Change – Elite';
                lao.Order_Status__c = 'At LI Team';
                DS_LAO_ApprovalProcess_Test.testAidVariable = true;
                Update lao;
                
                lao.Order_Type__c = 'New Install - Elite';
                lao.Order_Status__c = 'AWIP';
                DS_LAO_ApprovalProcess_Test.testAidVariable = true;              
                Update lao; 
                
                lao.Order_Type__c = 'Buy/Sell - Elite';
                lao.Order_Status__c = 'Q/S Submitted';
                DS_LAO_ApprovalProcess_Test.testAidVariable = true;              
                Update lao;               
            }          
        }
    }
    
    public static testMethod List<Laser_Approval_Process__c> GenerateLaserApprovalProcessSettings()
    {
        List<Laser_Approval_Process__c> LaserApprovalFields = new List<Laser_Approval_Process__c>();
        
        LaserApprovalFields.add(new Laser_Approval_Process__c(
            Name = '1', Order_Status__c = 'Artwork to LFD Team', Order_Type__c = 'Add/Change - Elite', 
            Owner_to_LAS__c = True, Owner_to_LFD__c = True, Owner_to_LIS__c = True, Submit_Approval__c = True,
            Rejected_LAS__c = True, TaskQuote_FollowUp__c = True, TaskProofs_FollowUp__c = True,
            Rejected_LFD__c = True));
        
        LaserApprovalFields.add(new Laser_Approval_Process__c(
            Name = '2', Order_Status__c = 'AWIP', Order_Type__c = 'New Install - Elite', 
            Owner_to_LAS__c = True, Owner_to_LFD__c = True, Owner_to_LIS__c = True, Submit_Approval__c = True,
            Rejected_LAS__c = False, TaskQuote_FollowUp__c = True, TaskProofs_FollowUp__c = True,
            Rejected_LFD__c = False));
        
        LaserApprovalFields.add(new Laser_Approval_Process__c(Name = '3', Order_Status__c = 'Q/S Submitted', Order_Type__c = 'Buy/Sell - Elite', TaskQuote_FollowUp__c = True));
        LaserApprovalFields.add(new Laser_Approval_Process__c(Name = '4', Order_Status__c = 'Awaiting Approval', Order_Type__c = 'Add/Change – Elite', TaskProofs_FollowUp__c = True));
        LaserApprovalFields.add(new Laser_Approval_Process__c(Name = '5', Order_Status__c = 'Proofs to LAS', Order_Type__c = 'Add/Change – Elite', Owner_to_LAS__c = True));
        LaserApprovalFields.add(new Laser_Approval_Process__c(Name = '6', Order_Status__c = 'AWIP', Order_Type__c = 'Add/Change – Elite', Owner_to_LFD__c = True));
        LaserApprovalFields.add(new Laser_Approval_Process__c(Name = '7', Order_Status__c = 'At LI Team', Order_Type__c = 'Add/Change – Elite', Owner_to_LIS__c = True));
        LaserApprovalFields.add(new Laser_Approval_Process__c(Name = '8', Order_Status__c = 'AWIP', Order_Type__c = 'New Install - Elite', Rejected_LAS__c = True)); 
        LaserApprovalFields.add(new Laser_Approval_Process__c(Name = '9', Order_Status__c = 'Proofs to LAS', Order_Type__c = 'Add/Change – Elite', Rejected_LFD__c = True));
        
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
}