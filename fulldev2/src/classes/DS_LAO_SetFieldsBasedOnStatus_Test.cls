@IsTest
public class DS_LAO_SetFieldsBasedOnStatus_Test
{
    public static TestMethod Void Test()
    {
        
        Profile p = [SELECT Id FROM Profile WHERE Name='ADPDS - Inside Sales/Laser - LSR'];  
        
        // 2015-11-24 matt.keefe@cdk.com Changed query condition from Name = Timothy Woolley to Profile.Name = Laser - LAS
        User LASUser = [Select Id From User Where Profile.Name like '%Laser - LAS' And IsActive = true Limit 1];
        User TempRunAsUser1 = DS_TestObjects.NewUser();
        TempRunAsUser1.ProfileId = p.Id;
        TempRunAsUser1.FederationIdentifier = 'FederationId';
        test.startTest();
        Insert TempRunAsUser1;
        
        system.RunAs(TempRunAsUser1)
        {
            list<Laser_Artwork_Order__c> InsertList = new list<Laser_Artwork_Order__c>();
            
            set<String> StatusSet = new set<String> { 
                'Binder Sent', 'Proofs to LAS', 'Awaiting Approval', 
                'Approved', 'Burned', 'Installed', 
                'Artwork to LFD Team', 'Forms to LIS Team', 
                'Q/S Submitted', 'Q/S Approved', 'AWIP', 'At LI Team', 'Change & Burn' 
            };
                
            set<string> laserFnIList = new set<string>{
                'Data Mapping', 'Sent to FB and/or Complete' 
            };
            ID fnIRecordTypeID = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Laser_Artwork_Order__c', 'F&I');
            
            Contact con = DS_TestObjects.NewContact_Inserted();
            
            for(String s : laserFnIList)
            { 
                for(Integer i=0; i<laserFnIList.size(); i++){ 
                    Laser_Artwork_Order__c lao = new Laser_Artwork_Order__c();
                    
                    lao.RecordTypeId = fnIRecordTypeID;
                   
                    lao.Order_Status__c = s; 
                    lao.Initial_Client_Contact__c = dateTime.now();
                    lao.Forms_Collected__c = dateTime.now() + 2;
                    lao.Laser_F_I_Forms_Received__c = dateTime.now() + 4;
                    //18-03-2016  ragashalini.koka@cdk.com - added contact__c field for lao object
                    lao.Contact__c = con.ID;
                    InsertList.add(lao);
                }
            }
                
            for(String s : StatusSet)
            { 
                for(Integer i=0; i<StatusSet.size(); i++){ 
                    Laser_Artwork_Order__c lao = new Laser_Artwork_Order__c();
                    lao.Revision__c = String.ValueOf(i+1);
                    lao.LIS_Info_Received__c ='yes';
                    
                    If(i==1){Lao.Order_Priority__c = 'Rush';Lao.Artwork_to_LFD_Team__c = System.now()+i;}
                    If(i==2){Lao.Order_Priority__c = 'Standard';Lao.Artwork_to_LFD_Team__c = System.now()+i;}                    
                    lao.Order_Status__c = s; 
                    lao.Artwork_to_LFD_Team__c = System.now()+i;
                    lao.Approved_by_Client__c = DateTime.now() - 2;
                    lao.Quote_Sheet_Approved__c = DateTime.now() + 2;
                    lao.Proofs_to_LAS__c = DateTime.now() - 2;
                    lao.Proofs_to_Client__c = DateTime.now() - 2;
                    lao.Forms_to_LIS_Team__c = DateTime.now() - 2;
                    lao.Burn_Completed__c = DateTime.now() - 2;
                    lao.Quote_Sheet_Submitted__c = DateTime.now();
                    lao.Contact__c = con.ID;
                    InsertList.add(lao);
                }
            }
            
            Database.insert(InsertList);
            
            list<Laser_Artwork_Order__c> UpdateList = new list<Laser_Artwork_Order__c>();
            
            for(Integer i=0; i<InsertList.Size(); i++) //Laser_Artwork_Order__c s:
            {    
                
                InsertList[i].Revision__c = InsertList[i].Order_Status__c!='Approved'?String.ValueOf(1): String.ValueOf(i+1);
                InsertList[i].LIS_Info_Received__c ='yes';
                InsertList[i].Artwork_to_LFD_Team__c = System.now()+i;
                
                //18-03-2016 ragashalini.koka@cdk.com - modified the if conditions to imporve the code coverage
                if(i==0){InsertList[i].Order_Priority__c = 'Rush';InsertList[i].Artwork_to_LFD_Team__c = System.now()+i;}
                if(i==2){InsertList[i].Order_Priority__c = 'Standard';InsertList[i].Artwork_to_LFD_Team__c = System.now()+i;}
                
                if(i==0){InsertList[i].Order_Status__c = 'Approved';}
                if(i==1){InsertList[i].Order_Status__c = 'Proofs to LAS';}
                if(i==2){InsertList[i].Order_Status__c = 'Awaiting Approval';}
                if(i==3){InsertList[i].Order_Status__c = 'Forms to LIS Team';}
                if(i==4){InsertList[i].Order_Status__c = 'Burned';}
                if(i==5){InsertList[i].Order_Status__c = 'Installed';}
                if(i==6){InsertList[i].Order_Status__c = 'Artwork to LFD Team'; InsertList[i].Revision__c = null;}
                if(i==7){InsertList[i].Order_Status__c = 'Artwork to LFD Team'; InsertList[i].Revision__c = null;}
                if(i==8){InsertList[i].Order_Status__c = 'Q/S Submitted'; InsertList[i].Order_Type__c = 'Buy/Sell - Elite';InsertList[i].LAS_Name__c = LASUser.Id;}
                if(i==9){InsertList[i].Order_Status__c = 'Q/S Approved';}
                if(i==10){InsertList[i].Order_Status__c = 'Approved';}
                if(i==11){InsertList[i].Order_Status__c = 'AWIP'; InsertList[i].Revision__c = null;}
                if(i==12){InsertList[i].Order_Status__c = 'Artwork to LFD Team'; }
                if(i==InsertList.size()-1) {InsertList[i].Order_Status__c = 'Forms Posted'; }
                if(i==InsertList.size()-2) {InsertList[i].Order_Status__c = 'Change & Burn'; InsertList[i].Order_Type__c = 'Buy/Sell - DASH';}
                
                UpdateList.add(InsertList[i]);  
            }  
            
            Database.update(UpdateList,false);
        }
        test.stopTest();
       
        
        
    }
    
    public static TestMethod Void Test2()
    {   
         //18-03-2016  ragashalini.koka@cdk.com  added a Laser_Install__c object and Non_EFD_Lasers__c
        Laser_Install__c laserInstall = new Laser_Install__c();
        laserInstall.EFD_Last_Downloaded__c = System.today();
        laserInstall.EFD_Lasers__c = 13;
        laserInstall.non_EFD_Lasers__c = 1;
        laserInstall.EFD_Last_Downloaded_By__c = UserInfo.getUserId();
        insert laserInstall;
        
        EFD_Lasers__c EFDLaser = new EFD_Lasers__c();
        EFDLaser.Laser_Install__c = laserInstall.Id;
        insert EFDLaser;
        
        ID fnIRecordTypeID = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Laser_Artwork_Order__c', 'F&I');
        Contact con = DS_TestObjects.NewContact_Inserted();
        Laser_Artwork_Order__c lao = new Laser_Artwork_Order__c();
        lao.Order_Status__c = 'Artwork to LFD Team';
		lao.Status__c = 'Sent to FB and/or Complete';   
        lao.FCC_Name__c = UserInfo.getUserId();
        lao.Welcome_Kit_Type__c = 'CTW';
        lao.Laser_F_I_Forms_Received__c = System.today();
        lao.PSA_Forms_Received__c  = System.now();
        lao.Contact__c = con.ID;
        lao.RecordTypeId = fnIRecordTypeID;
        lao.Laser_Install__c = laserInstall.Id;
        insert lao;
        
        test.startTest();
        lao.Order_Status__c = 'AWIP';
        update lao;
        
        lao.Order_Status__c = 'Awaiting Approval';
        lao.Proofs_to_LAS__c = DateTime.now() - 2;
        update lao;
        
        lao.Order_Status__c = 'AWIP';
        update lao;
        
        lao.Order_Status__c = 'Binder Sent';
        update lao;
        
        lao.Order_Status__c = 'hold';
        lao.Revision__c = '1';
        update lao;
        
        lao.Order_Status__c = 'Artwork to LFD Team';
        lao.Revision__c = '1';
        update lao;
        
        lao.Order_Status__c = 'AWIP';
        update lao;
        
        
        lao.Order_Status__c = 'At LI Team';
        lao.Forms_to_LIS_Team__c = DateTime.now() - 2;
        Update lao;
        
        lao.Order_Status__c = 'Installed';
        lao.Order_Type__c = 'New Install - eShowroom/Showroom';
        Laser_Ordered_Forms_Catalog_Numbers__c catlog = new Laser_Ordered_Forms_Catalog_Numbers__c();
        catlog.Exclude_from_Quote__c = true;
        catlog.Exclude_from_SO_Total__c = true;
        catlog.Exclude_from_Total_Number_Of_Forms__c = true;
        insert catlog;
        
        Laser_Ordered_Forms__c lof = new Laser_Ordered_Forms__c();        
        lof.Laser_Artwork_Order__c = lao.Id;
        lof.Catalog_Number__c = catlog.Id;
        insert lof;
        
        lao.Quote_Sheet_Submitted__c = DateTime.now() - 5;
        lao.Quote_Sheet_Approved__c = DateTime.now() - 2;
        lao.Artwork_to_LFD_Team__c = DateTime.now();
        lao.Proofs_to_LAS__c = lao.Artwork_to_LFD_Team__c + 2;
        lao.Project__c = 'TBD';
        lao.Proofs_to_Client__c = lao.Proofs_to_LAS__c + 2;
        lao.Approved_by_Client__c = lao.Proofs_to_Client__c + 2;
        lao.Burn_Completed__c = lao.Approved_by_Client__c + 2;
        lao.Forms_Installed__c = lao.Burn_Completed__c + 4;
        lao.Revision__c = '2';
        
        update lao;
       
         //18-03-2016  ragashalini.koka@cdk.com  updated LAO object to new values to increase the code coverage
       
        lao.Order_Status__c = 'Artwork to LFD Team';
        Database.update(lao,false);
         test.stopTest();
    }
    
    public static TestMethod Void Test3() {
        ID fnIRecordTypeID1 = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Laser_Artwork_Order__c', 'Laser Imaging');
        ID fnIRecordTypeID2 = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Laser_Artwork_Order__c', 'F&I');
        Contact con = DS_TestObjects.NewContact_Inserted();
        List<Laser_Artwork_Order__c> laoList = new List<Laser_Artwork_Order__c>();
        Laser_Artwork_Order__c lao1 = new Laser_Artwork_Order__c();
        lao1.Order_Status__c = 'Sent to Data Mapping/Other';
		lao1.Status__c = 'Sent to FB and/or Complete';  
        lao1.FCC_Name__c = UserInfo.getUserId();
        lao1.Welcome_Kit_Type__c = 'CTW';
        lao1.Laser_F_I_Forms_Received__c = null;
        lao1.PSA_Forms_Received__c  = System.now();
        lao1.Sent_To_Data_Mapping_Other__c = null;
        lao1.Initial_Client_Contact__c = null;
        lao1.Contact__c = con.ID;
        lao1.RecordTypeId = fnIRecordTypeID1;
       	laoList.add(lao1);
        
        Laser_Artwork_Order__c lao2 = new Laser_Artwork_Order__c();
        lao2.Order_Status__c = 'Forms Posted';
		lao2.Status__c = 'Sent to FB and/or Complete';   
        lao2.FCC_Name__c = UserInfo.getUserId();
        lao2.Welcome_Kit_Type__c = 'CTW';
        lao2.Laser_F_I_Forms_Received__c = null;
        lao2.PSA_Forms_Received__c  = System.now();
        lao2.Sent_To_Data_Mapping_Other__c = null;
        lao2.Initial_Client_Contact__c = null;
        lao2.Contact__c = con.ID;
        lao2.RecordTypeId = fnIRecordTypeID2;
        laoList.add(lao2);
        
        test.startTest();
        insert laoList;
        
        for(Laser_Artwork_Order__c lao : laoList) {
            lao.Order_Status__c = 'Artwork to LFD Team';
            lao.Revision__c = null;
            lao.Initial_Client_Contact__c = System.now();
            lao2.PSA_Forms_Received__c  = null;
        }
        update laoList;
        
         for(Laser_Artwork_Order__c lao : laoList) {
            lao.Order_Status__c = 'AWIP';
            lao.Revision__c = null;
        }
        update laoList;
         
        for(Laser_Artwork_Order__c lao : laoList) {
            lao.Order_Status__c = 'Data Mapping';
            lao.Status__c = 'In Progress';
            lao.Revision__c = null;
           
        }
        update laoList;
        
      
        
        for(Laser_Artwork_Order__c lao : laoList) {
            lao.Order_Status__c = 'Sent to FB and/or Complete';
            lao.Status__c = 'Sent to FB and/or Complete';
             lao.Laser_F_I_Forms_Received__c = System.now();
            lao.PSA_Forms_Received__c = System.now();
            
        }
        update laoList;
        
        
        test.stopTest();
        
        
        
       
        
    }
       
    
    public static TestMethod Void TestForWeekendsAndHolidays()
    {
        ID fnIRecordTypeID = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Laser_Artwork_Order__c', 'Laser Imaging');
        Contact con = DS_TestObjects.NewContact_Inserted();
        Laser_Artwork_Order__c lao = new Laser_Artwork_Order__c();
        lao.Artwork_to_LFD_Team__c = Date.newInstance(2015, 07, 04);
        lao.Order_Priority__c = 'Rush';
        lao.Order_Status__c = 'Sent to Data Mapping/Other';
        lao.RecordTypeId = fnIRecordTypeID;
        lao.Contact__c = con.ID; 
        insert lao;
        
        DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
     
        
        lao.Order_Priority__c = 'Standard';
        lao.Order_Status__c = 'Change & Burn';
        update lao;
        DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
        
        lao.Order_Priority__c = 'Same Day Rush';
        update lao;
        DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
    }
}