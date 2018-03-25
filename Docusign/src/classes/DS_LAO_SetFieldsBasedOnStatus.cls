public class DS_LAO_SetFieldsBasedOnStatus 
{   
    // below boolean variable has to set true in the DS_LaserRollupTriggerHandler class to avoid duplicate snapshots
    // Avoids creating snapshots if trigger fired due to field update/insert
    // of Stock_order_total__c from Laser Order Forms trigger
    public Static Boolean IsThisTrigger_LaserOrderForms;
    
    public static BusinessHours Bh;
    
    public static string CycleTimeCalculator(DateTime GreaterDate, DateTime LesserDate)
    {
        if(GreaterDate != null && LesserDate != null)
        {
            Long Difference = BusinessHours.diff(bh.Id, LesserDate, GreaterDate);
            
            double TotalMinutes = Difference/(60000);
            integer h = Integer.valueOf(Math.floor(TotalMinutes/60));
            integer m = Math.mod(Integer.valueOf(TotalMinutes), 60);
            
            return string.valueOf(h) + ':' + string.valueOf(m).leftPad(2).replaceAll(' ', '0');
        }
        else
        {
            return '';
        }
    }
    
    public static void Before(list <Laser_Artwork_Order__c> LaoNewList, list <Laser_Artwork_Order__c> LaoOldList) 
    {           
        Bh = [
            Select Id, Name 
            From BusinessHours 
            where Name = 'Laser Business Hours'
        ]; system.debug(Bh);
        
        map<Id, Laser_Artwork_Order__c> LaoOldMap = new map<Id, Laser_Artwork_Order__c>();
        list<LAO_TimeSnapshots__c> TobeInsertedList = new list<LAO_TimeSnapshots__c>(); 
        
        if(Trigger.IsBefore)
        { 
            if(Trigger.IsUpdate)
            {  
                for(Laser_Artwork_Order__c l : LaoOldList) {LaoOldMap.put(l.Id, l);}
                
                for (Laser_Artwork_Order__c lao : LaoNewList) 
                {
                    Laser_Artwork_Order__c oldLAO = LaoOldMap.get(lao.Id);
                    
                    if(oldLAO == null) 
                    { 
                        oldLAO = new Laser_Artwork_order__c(); 
                    }
                    
                    if(lao.Order_Status__c == 'AWIP' && oldLAO.Order_Status__c != 'AWIP')
                        // && oldLAO.Order_Status__c.toLowerCase().Contains('hold')) 
                    {
                       Lao.Artwork_to_LFD_Team__c = DateTime.Now();
                       
                        if(lao.Revision__c == null) 
                        {
                            lao.Revision__c = '1';                            
                        }
                        else 
                        {  
                            if(lao.Revision__c != null && LaoOldMap.get(lao.Id).Order_Status__c == 'Awaiting Approval')                               
                            {
                                Integer I = LaoOldMap.get(lao.Id).Revision__c != null ? 
                                    Integer.ValueOf(LaoOldMap.get(lao.Id).Revision__c): null;
                                lao.Revision__c = (I + 1) != null ? String.valueof(I + 1): null;
                                Lao.Artwork_to_LFD_Team__c = DateTime.Now(); 
                                //moving these two lines out of this condition to make this field update independent of Revision value
                                lao.Artwork_Due_Date__c = DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
                            }
                            if(lao.Revision__c != null && lao.Revision__c != '1')                              
                            {
                                Lao.Artwork_to_LFD_Team__c = DateTime.Now(); 
                                //commentedout since Artwork to LFD no longer dependent on Revision value to be set 
                                lao.Artwork_Due_Date__c = DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
                            }
                            else
                            {
                                lao.Revision__c = LaoOldMap.get(lao.Id).Revision__c;
                            }
                        }                  
                        LAO_TimeSnapshots__c snp3 = new LAO_TimeSnapshots__c();                        
                        snp3.Change_Made_By__c = UserInfo.GetUserId();
                        snp3.DateTime_of_Change__c = DateTime.Now();
                        snp3.Field_Changed__c = 'AWIP';
                        snp3.LAO__c = lao.Id;
                        snp3.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp3.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        snp3.Cycle_Time_Label__c = 'LFD Assignment Time';
                        snp3.Cycle_End_Time__c = DateTime.now();
                        snp3.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                            DateTime.Now(), LaoOldMap.get(lao.Id).Artwork_to_LFD_Team__c);
                        snp3.Cycle_Start_Time__c = oldLAO.Order_Status__c=='Artwork to LFD Team'?oldLAO.Artwork_to_LFD_Team__c:null;                      
                        
                        TobeInsertedList.add(snp3);
                    }
                    
                    if(lao.Order_Status__c == 'AWIP' 
                       && oldLAO.Order_Status__c != 'AWIP' 
                       && oldLAO.Order_Status__c == 'Artwork to LFD Team')
                    {
                        Lao.Artwork_to_LFD_Team__c = DateTime.Now();                                  
                    }
                    
                    if(lao.Order_Status__c == 'Proofs to LAS' && oldLAO.Order_Status__c != 'Proofs to LAS')
                    {
                        lao.Proofs_to_LAS__c = DateTime.Now();
                        LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                        snp.Change_Made_By__c = UserInfo.GetUserId();
                        snp.DateTime_of_Change__c = lao.Proofs_to_LAS__c;
                        snp.Field_Changed__c = 'Proofs to LAS';
                        snp.LAO__c = lao.Id;
                        snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        snp.Cycle_Time_Label__c = 'AWIP Cycle Time';
                        snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                            lao.Proofs_to_LAS__c, Lao.Artwork_to_LFD_Team__c);
                        snp.Cycle_End_Time__c = Lao.Proofs_to_LAS__c;
                        snp.Cycle_Start_Time__c = oldLAO.Order_Status__c=='AWIP'?oldLAO.Artwork_to_LFD_Team__c:null;
                        TobeInsertedList.add(snp);
                    }
                    
                    if(lao.Order_Status__c == 'Awaiting Approval' && oldLAO.Order_Status__c != 'Awaiting Approval')
                    {
                        lao.Proofs_to_Client__c = DateTime.Now();
                        
                        LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                        snp.Change_Made_By__c = UserInfo.GetUserId();
                        snp.DateTime_of_Change__c = lao.Proofs_to_Client__c;
                        snp.Field_Changed__c = 'Proofs to Client';
                        snp.LAO__c = lao.Id;
                        snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        snp.Cycle_Time_Label__c = 'Proof Delivery Cycle Time';
                        snp.Cycle_End_Time__c = lao.Proofs_to_Client__c;
                        snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                            lao.Proofs_to_Client__c, lao.Proofs_to_LAS__c);
                        snp.Cycle_Start_Time__c = oldLAO.Order_Status__c=='Proofs to LAS'?lao.Proofs_to_LAS__c:null;
                        
                        TobeInsertedList.add(snp);
                    }
                                        
                    if(lao.Order_Status__c == 'Approved' && oldLAO.Order_Status__c != 'Approved')
                        // && oldLAO.Order_Status__c.toLowerCase().Contains('hold'))                       
                    {
                        lao.Approved_by_Client__c = DateTime.Now();
                        
                        if(lao.Order_Priority__c == 'Standard' || Lao.Order_Priority__c == 'Rush')
                        {
                            Integer daysToAdd = ALL_UtilitiesDate.BusinessDaysCounter(Date.today(), 1, 'Laser Holiday');            
                            lao.Artwork_Due_Date__c =  DateTime.now().addDays(daysToAdd);
                        }
                        else
                        {
                            lao.Artwork_Due_Date__c = DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
                        }
                        
                        LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                        snp.Change_Made_By__c = UserInfo.GetUserId();
                        snp.DateTime_of_Change__c = DateTime.Now();
                        snp.Field_Changed__c = 'Artwork due date';
                        snp.LAO__c = lao.Id;
                        snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        snp.Cycle_Time_Label__c = 'Proof Approval Cycle Time';
                        snp.Cycle_End_Time__c = lao.Approved_by_Client__c;
                        snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                            lao.Approved_by_Client__c, lao.Proofs_to_Client__c);
                        snp.Cycle_Start_Time__c = oldLAO.Order_Status__c=='Awaiting Approval'?oldLAO.Proofs_to_Client__c:null;
                        TobeInsertedList.add(snp);
                    }
                    
                    if(lao.Order_Status__c == 'Burned' && oldLAO.Order_Status__c != 'Burned')
                    {
                        Lao.Burn_Completed__c = DateTime.Now();
                        
                        LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                        snp.Change_Made_By__c = UserInfo.GetUserId();
                        snp.DateTime_of_Change__c = DateTime.Now();
                        snp.Field_Changed__c = 'Burned';
                        snp.LAO__c = lao.Id;
                        snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        snp.Cycle_Time_Label__c = 'Burn Cycle Time';
                        snp.Cycle_End_Time__c = lao.Burn_Completed__c;
                        snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                            lao.Burn_Completed__c, lao.Approved_by_Client__c);
                        snp.Cycle_Start_Time__c = oldLAO.Order_Status__c=='Approved'?oldLAO.Approved_by_Client__c:null;
                        TobeInsertedList.add(snp);
                    }
                   
                    if(lao.Order_Status__c == 'Q/S Approved' && oldLAO.Order_Status__c != 'Q/S Approved')
                    {
                        Lao.Quote_Sheet_Approved__c = DateTime.Now();
                        
                        LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                        snp.Change_Made_By__c = UserInfo.GetUserId();
                        snp.DateTime_of_Change__c = DateTime.Now();
                        snp.Field_Changed__c = 'Quote Sheet Approved';
                        snp.Cycle_Time_Label__c = 'Quote Approval Time';
                        snp.Cycle_Start_Time__c = oldLAO.Order_Status__c == 'Q/S Submitted'?oldLAO.Quote_Sheet_Submitted__c:null;
                        snp.Cycle_End_Time__c = lao.Quote_Sheet_Approved__c;
                        snp.LAO__c = lao.Id;
                        snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                            lao.Quote_Sheet_Approved__c, Lao.Quote_Sheet_Submitted__c);
                        TobeInsertedList.add(snp);
                    }
                    
                    if(lao.Order_Status__c == 'Binder Sent' && oldLAO.Order_Status__c != 'Binder Sent')
                    {
                        Lao.Binder_Sent__c = DateTime.Now();
                    }
                    
                    if(lao.Order_Status__c == 'At LI Team' && oldLAO.Order_Status__c != 'At LI Team')
                    {
                        //lao.At_LI_Team__c = DateTime.Now(); //At_LI_Team__c needs to be created in Fulldev 3/27/2015 SivaP
                        LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                        snp.Change_Made_By__c = UserInfo.GetUserId();
                        snp.DateTime_of_Change__c = DateTime.Now();
                        snp.Field_Changed__c = 'At LI Team';
                        snp.Cycle_Time_Label__c = 'LIS Assignment Time';
                        //snp.Cycle_End_Time__c = lao.At_LI_Team__c;
                        snp.LAO__c = lao.Id;
                        snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        //snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.At_LI_Team__c, lao.Forms_to_LIS_Team__c);
                        snp.Cycle_Start_Time__c = oldLAO.Order_Status__c=='Forms to LIS Team'?oldLAO.Forms_to_LIS_Team__c:null;
                        TobeInsertedList.add(snp);
                    }
                    
                    if(lao.Order_Status__c == 'Artwork to LFD Team' && oldLAO.Order_Status__c != 'Artwork to LFD Team')
                        // && oldLAO.Order_Status__c.toLowerCase().Contains('hold'))                        
                    {                        
                        if(lao.Revision__c == null) 
                        {
                            lao.Revision__c = '1';  
                            lao.Artwork_to_LFD_Team__c = DateTime.Now();
                            lao.Artwork_Due_Date__c = DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
                        }
                        else
                        {
                            if(LaoOldMap.get(lao.Id).Revision__c != null && LaoOldMap.get(lao.Id).Revision__c != '1')
                            {  
                                lao.AddError('This order is already in process, please use AWIP');
                            } 
                        }                        
                    }
                    
                    // set both Artwork to LFD team and Artwork due date if the previous status contains hold
                    if(lao.Order_Status__c == 'Artwork to LFD Team' 
                       && oldLAO.Order_Status__c != 'Artwork to LFD Team' 
                       && oldLAO.Order_Status__c.toLowerCase().Contains('hold')
                       && oldLAO.Revision__c == '1') // ask Irfan if Revision no. has to be in the condition
                    {
                        lao.Artwork_to_LFD_Team__c = DateTime.Now();               
                        lao.Artwork_Due_Date__c = DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
                    }
                    
                    if(lao.Order_Status__c == 'Forms to LIS Team' && oldLAO.Order_Status__c != 'Forms to LIS Team')
                    {
                        lao.Forms_to_LIS_Team__c = DateTime.Now();
                        LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                        snp.Change_Made_By__c = UserInfo.GetUserId();
                        snp.DateTime_of_Change__c = DateTime.Now();
                        snp.Field_Changed__c = 'Forms to LIS team';
                        snp.LAO__c = lao.Id;
                        snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        snp.Cycle_Time_Label__c = 'Dispatch Cycle Time';
                        snp.Cycle_End_Time__c = lao.Forms_to_LIS_Team__c;
                        snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.Forms_to_LIS_Team__c, lao.Burn_Completed__c);
                        snp.Cycle_Start_Time__c = oldLAO.Order_Status__c=='Burned'?oldLAO.Burn_Completed__c:null;
                        TobeInsertedList.add(snp);
                    }
                    
                    if(lao.Order_Status__c == 'Installed' && oldLAO.Order_Status__c != 'Installed')
                    {
                        Lao.Forms_Installed__c = DateTime.Now();
                        
                        LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                        snp.Change_Made_By__c = UserInfo.GetUserId();
                        snp.DateTime_of_Change__c = DateTime.Now();
                        snp.Field_Changed__c = 'Forms Installed';
                        snp.LAO__c = lao.Id;
                        snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        snp.Cycle_Time_Label__c = 'Install Cycle Time';
                        snp.Cycle_End_Time__c = lao.Forms_Installed__c;
                        snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.Forms_Installed__c, lao.Forms_to_LIS_Team__c);
                        //snp.Cycle_Start_Time__c = oldLAO.Order_Status__c=='At LI Team'?oldLAO.At_LI_Team__c:null;
                        TobeInsertedList.add(snp);                       
                        
                    }                                    
                }
                
                if(IsThisTrigger_LaserOrderForms == null || !IsThisTrigger_LaserOrderForms)
                {
                    insert TobeInsertedList;
                }               
            }
            
            if(Trigger.IsInsert)
            {
                for (Laser_Artwork_Order__c lao : LaoNewList) 
                {
                    if(lao.Order_Status__c == 'AWIP')
                    {
                        lao.Revision__c = '1';
                        Lao.Artwork_to_LFD_Team__c = DateTime.Now();
                    }
                    
                    if(lao.Order_Status__c == 'Proofs to LAS')
                    {
                        lao.Proofs_to_LAS__c = DateTime.Now();
                    }
                    
                    if(lao.Order_Status__c == 'Awaiting Approval') 
                    {
                        lao.Proofs_to_Client__c = DateTime.Now();                       
                    }
                    
                    if(lao.Order_Status__c == 'Approved') 
                    {
                        lao.Approved_by_Client__c = DateTime.Now();                        
                        if(lao.Order_Priority__c == 'Standard' || Lao.Order_Priority__c == 'Rush')
                        {
                            Integer daysToAdd = ALL_UtilitiesDate.BusinessDaysCounter(Date.today(), 1, 'Laser Holiday');            
                            lao.Artwork_Due_Date__c =  DateTime.now().addDays(daysToAdd);
                        }
                        else
                        {
                            lao.Artwork_Due_Date__c = DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
                        }
                    }
                    
                    if(lao.Order_Status__c == 'Burned') 
                    {
                        Lao.Burn_Completed__c = DateTime.Now();
                    }
                    
                    if(lao.Order_Status__c == 'Q/S Submitted')
                    {
                        Lao.Quote_Sheet_Submitted__c = DateTime.Now();
                    }
                    
                    if(lao.Order_Status__c == 'Q/S Approved')
                    {
                        Lao.Quote_Sheet_Approved__c = DateTime.Now();
                    }
                    
                    if(lao.Order_Status__c == 'Binder Sent')
                    {
                        Lao.Binder_Sent__c = DateTime.Now();
                    }
                    
                    if(lao.Order_Status__c == 'Artwork to LFD Team')
                    {    
                       lao.Revision__c = '1';
                       Lao.Artwork_to_LFD_Team__c = DateTime.Now();
                    }
                    if(lao.Order_Status__c == 'Forms to LIS Team')
                    {
                        lao.Forms_to_LIS_Team__c = DateTime.Now();
                    }
                    
                    if(lao.Order_Status__c == 'Installed')
                    {
                        Lao.Forms_Installed__c = DateTime.Now();
                    } 
                    
                    if(lao.Order_Status__c == 'At LI Team')
                    {
                        //Lao.At_LI_Team__c = DateTime.Now();
                    }  
                }
            }
        }       
    
        
        if(Trigger.isUpdate)
        {
            map <ID, Laser_Artwork_Order__c> LaosForInstalledProcess = new map <ID, Laser_Artwork_Order__c>();
            
            /*set<string> OrderTypes = new set<string>{'Buy/Sell - DASH', 'Buy/Sell - ELF', 'Buy/Sell - Elite', 
                'Buy/Sell - eShowroom/Showroom', 'Buy/Sell - FI/DC', 'Buy/Sell - Other', 'New Install - DASH', 
                'New Install - ELF', 'New Install - Elite', 'New Install - eShowroom/Showroom', 'New Install - FI/DC',
                'New Install - Other'};*/
            
            for(Laser_Artwork_Order__c lao: LaoNewList)
            {               
                if(lao.Order_Status__c == 'Installed' /*&& OrderTypes.contains(lao.Order_Type__c)*/)
                { system.debug('am I here?');
                  LaosForInstalledProcess.put(lao.Id, lao); 
                }
            }
            
            if(LaosForInstalledProcess != null && !LaosForInstalledProcess.isEmpty())
            {
                DS_LAO_SetFieldsBasedOnStatus.InsertNewInstalledOrderedForms(LaosForInstalledProcess);
            }
        }
        
    }
    
    public static void After(list<Laser_Artwork_Order__c> LaoNewList)
    {      
        list<LAO_TimeSnapshots__c> TobeInsertedList = new list<LAO_TimeSnapshots__c>();
        
        if(Trigger.IsAfter && Trigger.IsInsert) 
        {
            for (Laser_Artwork_Order__c lao : LaoNewList) 
            {
                if(lao.Order_Status__c == 'AWIP') 
                {
                    LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                    LAO_TimeSnapshots__c snp2 = new LAO_TimeSnapshots__c();
                    LAO_TimeSnapshots__c snp3 = new LAO_TimeSnapshots__c();
                    
                    snp.Change_Made_By__c = UserInfo.GetUserId();
                    snp.DateTime_of_Change__c = Lao.Artwork_to_LFD_Team__c;
                    snp.Field_Changed__c = 'Artwork to LFD Team';
                    snp.LAO__c = lao.Id;
                    snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    
                    snp2.Change_Made_By__c = UserInfo.GetUserId();
                    snp2.DateTime_of_Change__c = Lao.Artwork_to_LFD_Team__c;
                    snp2.Field_Changed__c = 'Artwork Due Date';
                    snp2.LAO__c = lao.Id;
                    snp2.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp2.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    
                    snp3.Change_Made_By__c = UserInfo.GetUserId();
                    snp3.DateTime_of_Change__c = DateTime.Now();
                    snp3.Field_Changed__c = 'AWIP';
                    snp3.LAO__c = lao.Id;
                    snp3.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp3.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    snp3.Cycle_Time_Label__c = 'LFD Assignment Time';
                    snp3.Cycle_End_Time__c = DateTime.now();
                    snp3.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(DateTime.Now(), lao.Artwork_to_LFD_Team__c);
                    
                    TobeInsertedList.add(snp);
                    TobeInsertedList.add(snp2);
                    TobeInsertedList.add(snp3);
                }
                
                if(lao.Order_Status__c == 'Proofs to LAS')
                {
                    LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                    snp.Change_Made_By__c = UserInfo.GetUserId();
                    snp.DateTime_of_Change__c = lao.Proofs_to_LAS__c;
                    snp.Field_Changed__c = 'Proofs to LAS';
                    snp.LAO__c = lao.Id;
                    snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    snp.Cycle_Time_Label__c = 'AWIP Cycle Time';
                    snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.Proofs_to_LAS__c, Lao.Artwork_to_LFD_Team__c);
                    snp.Cycle_End_Time__c = Lao.Proofs_to_LAS__c;
                    TobeInsertedList.add(snp);
                }
                
                if(lao.Order_Status__c == 'Awaiting Approval')
                {
                    LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                    snp.Change_Made_By__c = UserInfo.GetUserId();
                    snp.DateTime_of_Change__c = lao.Proofs_to_Client__c;
                    snp.Field_Changed__c = 'Proofs to Client';
                    snp.LAO__c = lao.Id;
                    snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    snp.Cycle_Time_Label__c = 'Proof Delivery Cycle Time';
                    snp.Cycle_End_Time__c = lao.Proofs_to_Client__c;
                    snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.Proofs_to_Client__c, lao.Proofs_to_LAS__c);
                    
                    TobeInsertedList.add(snp);
                }
                
                if(lao.Order_Status__c == 'Approved') 
                {
                    LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                    snp.Change_Made_By__c = UserInfo.GetUserId();
                    snp.DateTime_of_Change__c = DateTime.Now();
                    snp.Field_Changed__c = 'Artwork due date';
                    snp.LAO__c = lao.Id;
                    snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    snp.Cycle_Time_Label__c = 'Proof Approval Cycle Time';
                    snp.Cycle_End_Time__c = lao.Approved_by_Client__c;
                    snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.Approved_by_Client__c, lao.Proofs_to_Client__c);
                    TobeInsertedList.add(snp);
                }
                
                if(lao.Order_Status__c == 'Forms to LIS Team')
                {                    
                    LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                    snp.Change_Made_By__c = UserInfo.GetUserId();
                    snp.DateTime_of_Change__c = DateTime.Now();
                    snp.Field_Changed__c = 'Forms to LIS team';
                    snp.LAO__c = lao.Id;
                    snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    snp.Cycle_Time_Label__c = 'Dispatch Cycle Time';
                    snp.Cycle_End_Time__c = lao.Forms_to_LIS_Team__c;
                    snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.Forms_to_LIS_Team__c, lao.Burn_Completed__c);
                    TobeInsertedList.add(snp);
                }
                
                if(lao.Order_Status__c == 'Q/S Approved')
                {                   
                    LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                    snp.Change_Made_By__c = UserInfo.GetUserId();
                    snp.DateTime_of_Change__c = DateTime.Now();
                    snp.Field_Changed__c = 'Quote Sheet Approved';
                    snp.Cycle_Time_Label__c = 'Quote Approval Time';
                    snp.Cycle_End_Time__c = lao.Quote_Sheet_Approved__c;
                    snp.LAO__c = lao.Id;
                    snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                        lao.Quote_Sheet_Approved__c, Lao.Quote_Sheet_Submitted__c);
                    TobeInsertedList.add(snp);
                }
                
                if(lao.Order_Status__c == 'Installed')
                {                   
                    LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                    snp.Change_Made_By__c = UserInfo.GetUserId();
                    snp.DateTime_of_Change__c = DateTime.Now();
                    snp.Field_Changed__c = 'Forms Installed';
                    snp.LAO__c = lao.Id;
                    snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    snp.Cycle_Time_Label__c = 'Install Cycle Time';
                    snp.Cycle_End_Time__c = lao.Forms_Installed__c;
                    snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.Forms_Installed__c, lao.Forms_to_LIS_Team__c);
                    TobeInsertedList.add(snp);              
                } 
                
                if(lao.Order_Status__c == 'Burned')
                {
                    LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                    snp.Change_Made_By__c = UserInfo.GetUserId();
                    snp.DateTime_of_Change__c = DateTime.Now();
                    snp.Field_Changed__c = 'Burned';
                    snp.LAO__c = lao.Id;
                    snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    snp.Cycle_Time_Label__c = 'Burn Cycle Time';
                    snp.Cycle_End_Time__c = lao.Burn_Completed__c;
                    snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.Burn_Completed__c, lao.Approved_by_Client__c);
                    TobeInsertedList.add(snp);
                }
                
                if(lao.Order_Status__c == 'At LI Team')
                {
                    LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                    snp.Change_Made_By__c = UserInfo.GetUserId();
                    snp.DateTime_of_Change__c = DateTime.Now();
                    snp.Field_Changed__c = 'At LI Team';
                    snp.Cycle_Time_Label__c = 'LIS Assignment Time';
                    //snp.Cycle_End_Time__c = lao.At_LI_Team__c;
                    snp.LAO__c = lao.Id;
                    snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    //snp.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.At_LI_Team__c, lao.Forms_to_LIS_Team__c);
                    TobeInsertedList.add(snp);
                }
            }  
            
            try
            {
                insert TobeInsertedList;
            }
            
            catch(DmlException e)
            { 
                system.debug(e.getMessage());
            }   
        }
    }
    
    public static void InsertNewInstalledOrderedForms(map<Id, Laser_Artwork_Order__c> LaosForInstalledProcess)
    {
        // query all Laser ordered forms that are child records of the Lao(s)
        map<ID, Laser_Artwork_Order__c> QueryChildrenInThisQuery = new map<ID, Laser_Artwork_Order__c>([
            Select Id, Name, Ship_CMF_Info__c, Laser_Install__r.Name, Laser_Install__c, // related to RQ-04268
                   (Select Id, Name, Form_Types__c, Quantity__c, Catalog_Number__r.Form_Type__c, 
                           Laser_Artwork_Order__c 
                    From Forms__r)
            From Laser_Artwork_Order__c 
            Where ID IN:LaosForInstalledProcess.keySet()
        ]);
        
        //related to RQ-04268
        set<string> LINset = new set<string>();
        map<ID, Laser_Install__c> LiUpdateMap = new map<ID, Laser_Install__c>();
        map<ID, EFD_Lasers__c> EfdUpdateMap = new map<ID, EFD_Lasers__c>();
        
        if(QueryChildrenInThisQuery != null && !QueryChildrenInThisQuery.isEmpty())
        {
            for(ID id: QueryChildrenInThisQuery.keySet())
            {
                LINset.add(QueryChildrenInThisQuery.get(id).Laser_Install__r.Name);
            }
        }        
        system.debug(LINset);
        map<ID, Laser_Install__c> LaserInstallsMap = new map<ID, Laser_Install__c>([
            Select Id, Name, (Select Id, Name, Installed_Date__c From Non_EFD_Lasers__r) 
            From Laser_Install__c 
            Where Name IN: LINset
        ]);
        
        system.debug(LaserInstallsMap);
        
        map<String, Laser_Install__c> LinToLaserInstall = new map<string, Laser_Install__c>();
        
        if(LaserInstallsMap != null && !LaserInstallsMap.isEmpty())
        {
            for(ID id: LaserInstallsMap.keySet())
            {
                LinToLaserInstall.put(LaserInstallsMap.get(id).Name, LaserInstallsMap.get(id));
            }
        }
        
        list<Installed_Laser_Forms__c> TobeInsertedIlfs = new list<Installed_Laser_Forms__c>();
        
        if(QueryChildrenInThisQuery != null && !QueryChildrenInThisQuery.isEmpty())
        {
            for(ID id: QueryChildrenInThisQuery.keySet())
            {
                Laser_Artwork_Order__c LaoWithChidren = QueryChildrenInThisQuery.get(id);
                List<Laser_Ordered_Forms__c> Lofs = LaoWithChidren.getsObjects('Forms__r');
                               
                if(Lofs != null && !Lofs.isEmpty())
                {
                    for(Laser_Ordered_Forms__c lof: Lofs)
                    {                   
                        Installed_Laser_Forms__c Ilf = new Installed_Laser_Forms__c();
                        Ilf.Laser_Order_Form_Form_Type__c = (lof.Form_Types__c != null?lof.Form_Types__c:lof.Catalog_Number__r.Form_Type__c);
                        Ilf.Laser_Order_Form_Quantity__c = lof.Quantity__c;
                        Ilf.Lao_Id__c = LaoWithChidren.Id;
                        Ilf.Lao_Name__c = LaoWithChidren.Name;
                        Ilf.CMF_Info__c = LaoWithChidren.Ship_CMF_Info__c;
                        
                        TobeInsertedIlfs.add(Ilf);
                    }
                }
                
                //related to RQ-04268
                if(LaoWithChidren.Laser_Install__c != null)
                {
                    Laser_Install__c Li = LinToLaserInstall.get(LaoWithChidren.Laser_Install__r.Name);
                    system.debug(Li);
                    if(Li != null)
                    {
                        list<EFD_Lasers__c> EFDLasers = Li.getSobjects('Non_EFD_Lasers__r');
                        LinToLaserInstall.get(LaoWithChidren.Laser_Install__r.Name).LIN_Status__c = 'Installed';
                        LiUpdateMap.put(LinToLaserInstall.get(LaoWithChidren.Laser_Install__r.Name).ID, 
                                        LinToLaserInstall.get(LaoWithChidren.Laser_Install__r.Name));
                        system.debug(LiUpdateMap);
                        if(EFDLasers != null && !EFDLasers.isEmpty())
                        {
                            for(EFD_Lasers__c efd: EFDLasers)
                            {
                                efd.Installed_Date__c = Date.Today();
                                EfdUpdateMap.put(efd.ID, efd);
                            }
                        }
                    }
                }
            }
        }
        
        //related to RQ-04268
        if(LiUpdateMap != null && !LiUpdateMap.isEmpty())
        {
            Update LiUpdateMap.values();
        }
        
        if(EfdUpdateMap != null && !EfdUpdateMap.isEmpty())
        {
            Update EfdUpdateMap.values();
        }
        
        if(TobeInsertedIlfs != null && !TobeInsertedIlfs.isEmpty())
        {
            insert TobeInsertedIlfs;
        }
    }
    
    public static DateTime WeekendsAndHolidays(String OrderPriority)
    {  
        if(OrderPriority == null || OrderPriority == '' || OrderPriority == 'Rush') 
        {
            Integer daysToAdd = ALL_UtilitiesDate.BusinessDaysCounter(Date.today(), 1, 'Laser Holiday');            
            return DateTime.now().addDays(daysToAdd);
        }
        else  if(OrderPriority == 'Standard')
        {
            Integer daysToAdd = ALL_UtilitiesDate.BusinessDaysCounter(Date.today(), 2, 'Laser Holiday');            
            return DateTime.now().addDays(daysToAdd);
        }
        else
        {
            Time Laser7pm = Time.newInstance(24, 0, 0, 0);
            DateTime dt = DateTime.newInstanceGMT((Date.today()+1), Laser7pm);
            return dt;            
        }
    }  
}