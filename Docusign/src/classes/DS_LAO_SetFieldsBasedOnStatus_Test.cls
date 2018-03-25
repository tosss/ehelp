@IsTest
public class DS_LAO_SetFieldsBasedOnStatus_Test
{
    public static TestMethod Void Test()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='ADPDS - Inside Sales/Laser - LSR'];  
        User LASUser = [Select Id From User Where Name = 'Timothy Woolley'];
        User TempRunAsUser = DS_TestObjects.NewUser();
        TempRunAsUser.ProfileId = p.Id;
        TempRunAsUser.FederationIdentifier = 'FederationId';
        Insert TempRunAsUser;
        
        system.RunAs(TempRunAsUser)
        {
            list<Laser_Artwork_Order__c> InsertList = new list<Laser_Artwork_Order__c>();
            
            set<String> StatusSet = new set<String> { 
                'Binder Sent', 'Proofs to LAS', 'Awaiting Approval', 
                'Approved', 'Burned', 'Installed', 
                'Artwork to LFD Team', 'Forms to LIS Team', 
                'Q/S Submitted', 'Q/S Approved', 'AWIP', 'At LI Team' 
            };
                
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
                    lao.Proofs_to_LAS__c = DateTime.now() - 2;
                    lao.Proofs_to_Client__c = DateTime.now() - 2;
                    lao.Forms_to_LIS_Team__c = DateTime.now() - 2;
                    lao.Burn_Completed__c = DateTime.now() - 2;
                    Lao.Quote_Sheet_Submitted__c = DateTime.now();
                    InsertList.add(lao);
                }
            }
            
            insert InsertList;
            
            list<Laser_Artwork_Order__c> UpdateList = new list<Laser_Artwork_Order__c>();
            
            for(Integer i=0; i<InsertList.Size(); i++) //Laser_Artwork_Order__c s:
            {    
                
                InsertList[i].Revision__c = InsertList[i].Order_Status__c!='Approved'?String.ValueOf(1): String.ValueOf(i+1);
                InsertList[i].LIS_Info_Received__c ='yes';
                InsertList[i].Artwork_to_LFD_Team__c = System.now()+i;
                
                if(i!=3){InsertList[i].Order_Priority__c = 'Rush';InsertList[i].Artwork_to_LFD_Team__c = System.now()+i;}
                if(i==2){InsertList[i].Order_Priority__c = 'Standard';InsertList[i].Artwork_to_LFD_Team__c = System.now()+i;}
                If(i==0){InsertList[i].Order_Status__c = 'Forms to LIS Team';}
                If(i==1){InsertList[i].Order_Status__c = 'Proofs to LAS';}
                If(i==2){InsertList[i].Order_Status__c = 'Awaiting Approval';}
                If(i==3){InsertList[i].Order_Status__c = 'Approved';}
                If(i==4){InsertList[i].Order_Status__c = 'Burned';}
                If(i==5){InsertList[i].Order_Status__c = 'Installed';}
                If(i==6){/*InsertList[i].Order_Status__c = 'Artwork to LFD Team';*/  InsertList[i].Revision__c = null;}
                If(i==7){InsertList[i].Order_Status__c = 'AWIP'; InsertList[i].Revision__c = null;}
                If(i==8){InsertList[i].Order_Status__c = 'Q/S Submitted'; InsertList[i].Order_Type__c = 'Buy/Sell - Elite';InsertList[i].LAS_Name__c = LASUser.Id;}
                If(i==9){InsertList[i].Order_Status__c = 'Q/S Approved';}
                If(i==10){InsertList[i].Order_Status__c = 'Binder Sent';}
                
                UpdateList.add(InsertList[i]);  
            }  
            
            update UpdateList;
        }
    }
    
    public static TestMethod Void Test2()
    {   //related to RQ-04268
        /*Laser_Install__c Li = new Laser_Install__c();
        //EFD_Lasers__c, non_EFD_Lasers__c, EFD_Last_Downloaded__c
        Li.EFD_Lasers__c = 2.2;
        Li.non_EFD_Lasers__c = 4.4;
        Li.EFD_Last_Downloaded__c = Date.today() -10;
        Insert Li;
        EFD_Lasers__c Efd = new EFD_Lasers__c();
        Efd.Laser_Install__c = Li.ID;
        insert Efd;*/
        Laser_Artwork_Order__c lao = new Laser_Artwork_Order__c();
        lao.Order_Status__c = 'Artwork to LFD Team';
        //Li = [Select Id, Name From Laser_Install__c Where ID = :Li.ID Limit 1]; related to RQ-04268
        //Lao.LIN__c = Li.Name; related to RQ-04268       
        insert lao;
        
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
    }
    
    public static TestMethod Void TestForWeekendsAndHolidays()
    {
        Laser_Artwork_Order__c lao = new Laser_Artwork_Order__c();
        lao.Artwork_to_LFD_Team__c = Date.newInstance(2015, 07, 04);
        lao.Order_Priority__c = 'Rush';
        insert lao;
        
        DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
     
        
        lao.Order_Priority__c = 'Standard';
        update lao;
        DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
        
        lao.Order_Priority__c = 'Same Day Rush';
        update lao;
        DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
    }
}