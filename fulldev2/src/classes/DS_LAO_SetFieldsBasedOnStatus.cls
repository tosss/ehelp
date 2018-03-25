public class DS_LAO_SetFieldsBasedOnStatus 
{   
    // below boolean variable has to set true in the DS_LaserRollupTriggerHandler class to avoid duplicate snapshots
    // Avoids creating snapshots if trigger fired due to field update/insert
    // of Stock_order_total__c from Laser Order Forms trigger
    public Static Boolean IsThisTrigger_LaserOrderForms;
    
    public static BusinessHours Bh;/* {
        get{
            Bh = [
                Select Id, Name 
                From BusinessHours 
                where Name = 'Laser Business Hours'
            ];
            return Bh;
        } set;
    }*/
    
    public static boolean currentUserProfileConditionMet;
    
    public DS_LAO_SetFieldsBasedOnStatus()
    {
        string currentUserProfileName = null;
        
        User currentUser = [
            Select Id, Name, isActive, ProfileId, Profile.Name
            From User
            Where Id = :userInfo.getUserId()];
        System.debug('user' + currentUser);
        if(currentUser != null)
        {
            currentUserProfileName = currentUser.Profile.Name;
        }
        
        if(currentUserProfileName != null &&
           (currentUserProfileName.containsIgnoreCase('laser') || currentUserProfileName.containsIgnoreCase('admin')) &&
           currentUser.isActive == true)
        {
            currentUserProfileConditionMet = true;
        }
        else
        {
            currentUserProfileConditionMet = false;
        }
    }
    
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
        DS_LAO_SetFieldsBasedOnStatus instance = new DS_LAO_SetFieldsBasedOnStatus();
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
                    string recordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Laser_Artwork_Order__c', lao.RecordTypeId);
                    System.debug('lao checking' + recordTypeName + lao.Order_Status__c);
                    Laser_Artwork_Order__c oldLAO = LaoOldMap.get(lao.Id);
                    
                    if(oldLAO == null) 
                    { 
                        oldLAO = new Laser_Artwork_order__c(); 
                    }
                    
                    if(lao.Order_Status__c == 'AWIP' && oldLAO.Order_Status__c != 'AWIP')                        
                    {
                       Lao.Artwork_to_LFD_Team__c = DateTime.Now();
                       
                        if(lao.Revision__c == null) 
                        {
                            lao.Revision__c = '1';                            
                        }
                        else 
                        {  
                            DateTime laserArtworkOrderTime = DS_LAO_SetFieldsBasedOnStatus.WeekendsAndHolidays(lao.Order_Priority__c);
                            
                            if(lao.Revision__c != null && LaoOldMap.get(lao.Id).Order_Status__c == 'Awaiting Approval')                               
                            {
                                Integer I = LaoOldMap.get(lao.Id).Revision__c != null ? 
                                    Integer.ValueOf(LaoOldMap.get(lao.Id).Revision__c): null;
                                lao.Revision__c = (I + 1) != null ? String.valueof(I + 1): null;
                                Lao.Artwork_to_LFD_Team__c = DateTime.Now();                                 
                                lao.Artwork_Due_Date__c = laserArtworkOrderTime;
                            }
                            if(lao.Revision__c != null && lao.Revision__c != '1')                              
                            {
                                Lao.Artwork_to_LFD_Team__c = DateTime.Now(); 
                                lao.Artwork_Due_Date__c = laserArtworkOrderTime;
                            }
                            else
                            {
                                lao.Revision__c = LaoOldMap.get(lao.Id).Revision__c;
                            }
                        }                  
                        LAO_TimeSnapshots__c snp3 = new LAO_TimeSnapshots__c();                        
                        snp3.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    
                    if(lao.Order_Status__c == 'Proofs to LAS' && oldLAO.Order_Status__c != 'Proofs to LAS')
                    {
                        lao.Proofs_to_LAS__c = DateTime.Now();
                        LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                        snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                        snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                        snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    
                    if(lao.Order_Status__c == 'Forms Posted' && oldLAO.Order_Status__c != 'Forms Posted')
                    {
                        lao.Forms_Posted__c = Date.today();
                    }
                    
                    if(lao.Order_Status__c == 'At LI Team' && oldLAO.Order_Status__c != 'At LI Team')
                    {
                        Lao.Forms_to_LIS_Team__c = DateTime.Now();
                    }
                    
                    if(lao.Order_Status__c == 'Burned' && oldLAO.Order_Status__c != 'Burned')
                    {
                        Lao.Burn_Completed__c = DateTime.Now();
                        
                        LAO_TimeSnapshots__c snp = new LAO_TimeSnapshots__c();
                        snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                        snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                        snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    
                    if(recordTypeName != null)
                    {
                        if(recordTypeName.containsIgnoreCase('Laser Imaging'))
                        {
                            
                            if(lao.Order_Status__c == 'Change & Burn' && oldLAO.Order_Status__c != 'Change & Burn')                                              
                            {
                                lao.Approved_by_Client__c = DateTime.Now();
                                Integer daysToAdd = ALL_UtilitiesDate.BusinessDaysCounter(Date.today(), 1, 'Laser Holiday');            
                                lao.Artwork_Due_Date__c =  DateTime.now().addDays(daysToAdd);
                                
                            }
                            if(lao.Order_Status__c == 'Artwork to LFD Team' && oldLAO.Order_Status__c != 'Artwork to LFD Team')                                               
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
                            if(lao.Order_Status__c == 'AWIP' 
                               && oldLAO.Order_Status__c != 'AWIP' 
                               && oldLAO.Order_Status__c == 'Artwork to LFD Team')
                            {
                                Lao.Artwork_to_LFD_Team__c = DateTime.Now();                                  
                            }
                            
                            if(lao.Order_Type__c != null && lao.Order_Type__c.containsIgnoreCase('dash') &&
                               lao.Order_Status__c != null && lao.Order_Status__c.equalsIgnoreCase('Sent to Data Mapping/Other') &&
                               lao.Sent_To_Data_Mapping_Other__c == null)
                            {
                                lao.Sent_To_Data_Mapping_Other__c = DateTime.now();
                            }
                        }
                        else if(recordTypeName.containsIgnoreCase('F&I'))
                        {
                            if(lao.Order_Status__c == 'AWIP' && oldLAO.Order_Status__c != 'AWIP')
                            { 
                                if(lao.Revision__c == null)
                                {
                                    lao.Revision__c = '1';
                                }
                                lao.Artwork_to_LFD_Team__c = dateTime.now();
                            }
                            if(lao.Order_Status__c == 'Data Mapping' && oldLAO.Order_Status__c != 'Data Mapping')
                            {
                                lao.Data_Mapping__c = Date.today();
                            }
                            if(lao.Status__c == 'Sent to FB and/or Complete' && oldLAO.Status__c != 'Sent to FB and/or Complete')
                            {
                                lao.Sent_To_FB__c = dateTime.now();
                            }
                            if(lao.Initial_Client_Contact__c != null && oldLao.Initial_Client_Contact__c == null)
                            {
                                LAO_TimeSnapshots__c snap = new LAO_TimeSnapshots__c();                        
                                snap.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                                snap.DateTime_of_Change__c = DateTime.Now();
                                snap.Field_Changed__c = 'Initial Client Contact';
                                snap.LAO__c = lao.Id;
                                snap.Reason_for_Change__c = lao.Reason_for_Change__c;
                                snap.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                                snap.Cycle_Time_Label__c = ' Initial Contact Time';
                                snap.Cycle_End_Time__c = DateTime.now();
                                snap.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                                    lao.Initial_Client_Contact__c, lao.CreatedDate);
                                snap.Cycle_Start_Time__c = lao.CreatedDate;                      
                                
                                TobeInsertedList.add(snap);
                            }
                            if((lao.Forms_Collected__c != null && lao.Initial_Client_Contact__c != null) && 
                               (oldLao.Forms_Collected__c != null || oldLao.Initial_Client_Contact__c != null))
                            {
                                LAO_TimeSnapshots__c snap = new LAO_TimeSnapshots__c();                        
                                snap.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                                snap.DateTime_of_Change__c = DateTime.Now();
                                snap.Field_Changed__c = 'Forms Collected';
                                snap.LAO__c = lao.Id;
                                snap.Reason_for_Change__c = lao.Reason_for_Change__c;
                                snap.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                                snap.Cycle_Time_Label__c = 'Forms Collected Time';
                                snap.Cycle_End_Time__c = DateTime.now();
                                snap.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                                    lao.Forms_Collected__c, lao.Initial_Client_Contact__c);
                                snap.Cycle_Start_Time__c = lao.Initial_Client_Contact__c;                      
                                
                                TobeInsertedList.add(snap);
                            }
                            DateTime tempDateTime;
                            if(lao.Laser_F_I_Forms_Received__c != null && oldLao.Laser_F_I_Forms_Received__c == null)
                            {
                                tempDateTime = lao.Laser_F_I_Forms_Received__c;
                            }
                            else
                            {
                                if(lao.PSA_Forms_Received__c != null && oldLao.PSA_Forms_Received__c == null)
                                {
                                   tempDateTime = lao.PSA_Forms_Received__c;
                                }
                            }
                            
                            if(tempDateTime != null)
                            {
                                LAO_TimeSnapshots__c snap = new LAO_TimeSnapshots__c();                        
                                snap.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                                snap.DateTime_of_Change__c = DateTime.Now();
                                
                                if(lao.Laser_F_I_Forms_Received__c != null && oldLao.Laser_F_I_Forms_Received__c == null)
                                {
                                    snap.Field_Changed__c = 'Laser FI Forms Received';
                                }
                                else
                                {
                                    if(lao.PSA_Forms_Received__c != null && oldLao.PSA_Forms_Received__c == null)
                                    {
                                        snap.Field_Changed__c = 'PSA Forms Received';
                                    }
                                }
                                
                                snap.LAO__c = lao.Id;
                                snap.Reason_for_Change__c = lao.Reason_for_Change__c;
                                snap.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                                snap.Cycle_Time_Label__c = 'Forms Transit Time';
                                snap.Cycle_End_Time__c = DateTime.now();
                                snap.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                                    tempDateTime, lao.Welcome_Kit_Sent__c);
                                snap.Cycle_Start_Time__c = lao.Welcome_Kit_Sent__c;                      
                                
                                TobeInsertedList.add(snap);
                            }
                            
                            if(lao.Status__c == 'Sent to FB And/Or Complete' && oldLao.Status__c != 'Sent to FB And/Or Complete')
                            {
                                lao.Send_To_FB__c = dateTime.now();
                            }
                            
                            if(lao.Status__c == 'Sent to FB And/Or Complete' && oldLao.Status__c != 'Sent to FB And/Or Complete' && tempDateTime != null)
                            {
                                LAO_TimeSnapshots__c snap = new LAO_TimeSnapshots__c();                        
                                snap.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                                snap.DateTime_of_Change__c = DateTime.Now();
                                
                                if(lao.Laser_F_I_Forms_Received__c != null)
                                {
                                    snap.Field_Changed__c = 'Laser FI Forms Received';
                                }
                                else
                                {
                                    if(lao.PSA_Forms_Received__c != null)
                                    {
                                        snap.Field_Changed__c = 'PSA Forms Received';
                                    }
                                }
                                
                                snap.LAO__c = lao.Id;
                                snap.Reason_for_Change__c = lao.Reason_for_Change__c;
                                snap.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                                snap.Cycle_Time_Label__c = 'LAS Handoff Time';
                                snap.Cycle_End_Time__c = DateTime.now();
                                snap.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                                    tempDateTime, lao.Send_To_FB__C);
                                snap.Cycle_Start_Time__c = lao.Send_To_FB__C;                      
                                
                                TobeInsertedList.add(snap);
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
                        snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                        snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                        
                        LAO_TimeSnapshots__c snp2 = new LAO_TimeSnapshots__c();
                        snp2.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                        snp2.DateTime_of_Change__c = DateTime.Now();
                        snp2.Field_Changed__c = 'Forms Installed';
                        snp2.LAO__c = lao.Id;
                        snp2.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp2.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        snp2.Cycle_Time_Label__c = 'Total Cycle Time';
                        snp2.Cycle_End_Time__c = lao.Forms_Installed__c;
                        long snp2_CycleTime_long = BusinessHours.diff(bh.Id, lao.CreatedDate, lao.Forms_Installed__c);
                        snp2.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(lao.Forms_Installed__c, lao.CreatedDate);
                        //snp2.Cycle_Start_Time__c = oldLAO.Order_Status__c=='At LI Team'?oldLAO.At_LI_Team__c:null;
                        TobeInsertedList.add(snp2);
                        
                        LAO_TimeSnapshots__c snp3 = new LAO_TimeSnapshots__c();
                        snp3.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                        snp3.DateTime_of_Change__c = DateTime.Now();
                        snp3.Field_Changed__c = 'Forms Installed';
                        snp3.LAO__c = lao.Id;
                        snp3.Reason_for_Change__c = lao.Reason_for_Change__c;
                        snp3.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                        snp3.Cycle_Time_Label__c = 'Total CDK Cycle Time';
                        snp3.Cycle_End_Time__c = lao.Forms_Installed__c;
                        long snp3_CycleTime_long = BusinessHours.diff(bh.Id, lao.Quote_Sheet_Approved__c, lao.Proofs_To_Client__c);
                        long difference = snp2_CycleTime_long - snp3_CycleTime_long;
                        double TotalMinutes = Difference/(60000);
                        integer h = Integer.valueOf(Math.floor(TotalMinutes/60));
                        integer m = Math.mod(Integer.valueOf(TotalMinutes), 60);
                        snp3.Cycle_Time__c = string.valueOf(h) + ':' + string.valueOf(m).leftPad(2).replaceAll(' ', '0');
                        //snp2.Cycle_Start_Time__c = oldLAO.Order_Status__c=='At LI Team'?oldLAO.At_LI_Team__c:null;
                        TobeInsertedList.add(snp3); 
                        
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
                    string recordTypeName = ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Laser_Artwork_Order__c', lao.RecordTypeId);
                    
                    if(recordTypeName != null)
                    {
                        if(recordTypeName.containsIgnoreCase('F&I'))
                        {   
                            if(lao.Order_Status__c == 'Data Mapping')
                            {
                                lao.Data_Mapping__c = Date.today();
                            }
                            if(lao.Status__c == 'Sent to FB and/or Complete')
                            {
                                lao.Sent_To_FB__c = dateTime.now();
                            }
                            if(lao.Initial_Client_Contact__c != null)
                            {
                                LAO_TimeSnapshots__c snap = new LAO_TimeSnapshots__c();                        
                                snap.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                                snap.DateTime_of_Change__c = DateTime.Now();
                                snap.Field_Changed__c = 'Initial Client Contact';
                                snap.LAO__c = lao.Id;
                                snap.Reason_for_Change__c = lao.Reason_for_Change__c;
                                snap.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                                snap.Cycle_Time_Label__c = ' Initial Contact Time';
                                snap.Cycle_End_Time__c = DateTime.now();
                                snap.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                                    lao.Initial_Client_Contact__c, lao.CreatedDate);
                                snap.Cycle_Start_Time__c = lao.CreatedDate;                      
                                
                                TobeInsertedList.add(snap);
                            }
                            if(lao.Forms_Collected__c != null && lao.Initial_Client_Contact__c != null)
                            {
                                LAO_TimeSnapshots__c snap = new LAO_TimeSnapshots__c();                        
                                snap.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                                snap.DateTime_of_Change__c = DateTime.Now();
                                snap.Field_Changed__c = 'Forms Collected';
                                snap.LAO__c = lao.Id;
                                snap.Reason_for_Change__c = lao.Reason_for_Change__c;
                                snap.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                                snap.Cycle_Time_Label__c = ' Forms Collected Time';
                                snap.Cycle_End_Time__c = DateTime.now();
                                snap.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                                    lao.Forms_Collected__c, lao.Initial_Client_Contact__c);
                                snap.Cycle_Start_Time__c = lao.Initial_Client_Contact__c;                      
                                
                                TobeInsertedList.add(snap);
                            }
                            DateTime tempDateTime;
                            if(lao.Laser_F_I_Forms_Received__c != null)
                            {
                                tempDateTime = lao.Laser_F_I_Forms_Received__c;
                            }
                            else
                            {
                                if(lao.PSA_Forms_Received__c != null)
                                {
                                   tempDateTime = lao.PSA_Forms_Received__c;
                                }
                            }
                            
                            if(tempDateTime != null)
                            {
                                LAO_TimeSnapshots__c snap = new LAO_TimeSnapshots__c();                        
                                snap.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                                snap.DateTime_of_Change__c = DateTime.Now();
                                
                                if(lao.Laser_F_I_Forms_Received__c != null)
                                {
                                    snap.Field_Changed__c = 'Laser FI Forms Received';
                                }
                                else
                                {
                                    if(lao.PSA_Forms_Received__c != null)
                                    {
                                        snap.Field_Changed__c = 'PSA Forms Received';
                                    }
                                }
                                
                                snap.LAO__c = lao.Id;
                                snap.Reason_for_Change__c = lao.Reason_for_Change__c;
                                snap.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                                snap.Cycle_Time_Label__c = 'Forms Transit Time';
                                snap.Cycle_End_Time__c = DateTime.now();
                                snap.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                                    tempDateTime, lao.Welcome_Kit_Sent__c);
                                snap.Cycle_Start_Time__c = lao.Welcome_Kit_Sent__c;                      
                                
                                TobeInsertedList.add(snap);
                            }
                            if(lao.Status__c == 'Sent to FB And/Or Complete')
                            {
                               lao.Send_To_FB__c = dateTime.now(); 
                            }
                            if(lao.Status__c == 'Sent to FB And/Or Complete' && tempDateTime != null)
                            {
                                LAO_TimeSnapshots__c snap = new LAO_TimeSnapshots__c();                        
                                snap.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                                snap.DateTime_of_Change__c = DateTime.Now();
                                
                                if(lao.Laser_F_I_Forms_Received__c != null)
                                {
                                    snap.Field_Changed__c = 'Laser FI Forms Received';
                                }
                                else
                                {
                                    if(lao.PSA_Forms_Received__c != null)
                                    {
                                        snap.Field_Changed__c = 'PSA Forms Received';
                                    }
                                }
                                
                                snap.LAO__c = lao.Id;
                                snap.Reason_for_Change__c = lao.Reason_for_Change__c;
                                snap.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                                snap.Cycle_Time_Label__c = 'LAS Handoff Time';
                                snap.Cycle_End_Time__c = DateTime.now();
                                snap.Cycle_Time__c = DS_LAO_SetFieldsBasedOnStatus.CycleTimeCalculator(
                                    tempDateTime, lao.Send_To_FB__C);
                                snap.Cycle_Start_Time__c = lao.Send_To_FB__C;                      
                                
                                TobeInsertedList.add(snap);
                            }
                        }
                        else
                        {
                            if(lao.Order_Type__c != null && lao.Order_Type__c.containsIgnoreCase('dash') &&
                               lao.Order_Status__c != null && lao.Order_Status__c.equalsIgnoreCase('Sent to Data Mapping/Other') &&
                               lao.Sent_To_Data_Mapping_Other__c == null)
                            {
                                lao.Sent_To_Data_Mapping_Other__c = DateTime.now();
                            }
                            if(lao.Order_Status__c == 'Change & Burn')
                            {
                                lao.Approved_by_Client__c = DateTime.Now();                      
                                Integer daysToAdd = ALL_UtilitiesDate.BusinessDaysCounter(Date.today(), 1, 'Laser Holiday');            
                                lao.Artwork_Due_Date__c =  DateTime.now().addDays(daysToAdd);
                            }
                        }
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
                    if(lao.Order_Status__c == 'Forms Posted')
                    {
                        lao.Forms_Posted__c = Date.today();  
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
                    
                    if(lao.Order_Status__c == 'AWIP')
                    {
                        lao.Revision__c = '1';
                        Lao.Artwork_to_LFD_Team__c = DateTime.Now();
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
                        Lao.Forms_to_LIS_Team__c = DateTime.Now();
                    }  
                }
            }
        }       
    
        
        if(Trigger.isUpdate)
        {
            map <ID, Laser_Artwork_Order__c> LaosForInstalledProcess = new map <ID, Laser_Artwork_Order__c>();
            
            for(Laser_Artwork_Order__c lao: LaoNewList)
            {               
                if(lao.Order_Status__c == 'Installed')
                { 
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
        DS_LAO_SetFieldsBasedOnStatus instance = new DS_LAO_SetFieldsBasedOnStatus();
        
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
                    
                    snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                    snp.DateTime_of_Change__c = Lao.Artwork_to_LFD_Team__c;
                    snp.Field_Changed__c = 'Artwork to LFD Team';
                    snp.LAO__c = lao.Id;
                    snp.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    
                    snp2.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
                    snp2.DateTime_of_Change__c = Lao.Artwork_to_LFD_Team__c;
                    snp2.Field_Changed__c = 'Artwork Due Date';
                    snp2.LAO__c = lao.Id;
                    snp2.Reason_for_Change__c = lao.Reason_for_Change__c;
                    snp2.Revision__c = lao.Revision__c!= null?Integer.valueof(lao.Revision__c):null;
                    
                    snp3.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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
                    snp.Change_Made_By__c = currentUserProfileConditionMet == true ? UserInfo.getUserId() : null;
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