global with sharing class CB_CreativeSupportMStoneTimeTriggUpdte implements Support.MilestoneTriggerTimeCalculator
{
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneId) 
    {
        Case c = [SELECT Id, Priority, EntitlementId, SlaStartDate,X911_Escalation__c, DA_Echelon_Level__c FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneId];
        Entitlement ent = [Select Id, BusinessHoursId from Entitlement where Id = :c.EntitlementId];
        BusinessHours testhHours = [Select Id, TimeZoneSidKey,MondayStartTime, MondayEndTime,TuesdayStartTime, TuesdayEndTime,
                                    WednesdayStartTime, WednesdayEndTime,ThursdayStartTime, ThursdayEndTime,FridayStartTime, 
                                    FridayEndTime,SaturdayStartTime,SaturdayEndTime  from BusinessHours where id = :ent.BusinessHoursId];
        DateTime startDate = DateTime.valueOf((c.SlaStartDate.format('yyyy-MM-dd HH:mm:ss', testhHours.TimeZoneSidKey)));
        Integer removeSeconds = startDate.second();
        startDate = startDate.addSeconds(-removeSeconds);
		string startDay = startDate.format('EEEE');
        
        system.debug('----MilestoneType---'+mt);
        system.debug('----CaseMilestone---'+ent);
        system.debug('-----Case-----------'+c);
        if (c.X911_Escalation__c!= null && c.DA_Echelon_Level__c.equals('Platinum')){
              if (mt.Name != null && mt.Name.equals('0 Same Day')) 
              {                      
                  if(startDay.equals('Friday')){
                      return calcSameBDayDiff(startDate, testhHours.FridayEndTime,testhHours.FridayStartTime, testhHours.TimeZoneSidKey);   
                  }
                  else if(startDay.equals('Thursday') ){
                      return calcSameBDayDiff(startDate, testhHours.ThursdayEndTime, testhHours.ThursdayStartTime, testhHours.TimeZoneSidKey);
                  }
                  else if(startDay.equals('Wednesday') ){                      
                      return calcSameBDayDiff(startDate, testhHours.WednesdayEndTime,testhHours.WednesdayStartTime, testhHours.TimeZoneSidKey);
                  }
                  else if(startDay.equals('Tuesday') ){
                      return calcSameBDayDiff(startDate, testhHours.TuesdayEndTime,testhHours.TuesdayStartTime, testhHours.TimeZoneSidKey);                      
                  }
                  else if(startDay.equals('Monday') ){
                      return calcSameBDayDiff(startDate, testhHours.MondayEndTime,testhHours.MondayStartTime, testhHours.TimeZoneSidKey);
                  }
                  else{
                      return 0;
                  }
                      
                  
              }
              else { return 0; }
        }
        else {
            return 0;
        }
     
        
    }
   
    global static Integer calcSameBDayDiff(Datetime startDate, Time businessEndTime,Time businessStartTime,string TimeZoneKey){
        system.debug('startDateInPST***'+startDate);
        Date tempdate = startDate.date(); 
        DateTime tempGmtOfPST = DateTime.newInstanceGMT(tempdate.year(), tempdate.month(),tempdate.day(),0,0,0); 
        system.debug('tempDate1---JustStartDATEwith000timevalues'+tempGmtOfPST);
        tempGmtOfPST = tempGmtOfPST.addHours(16).addminutes(30).addSeconds(0);
        system.debug('tempDatefinal*****'+tempGmtOfPST);
        DateTime businessEndDateTime = DateTime.newInstance(tempdate.year(), tempdate.month(), tempdate.day());
        businessEndDateTime = businessEndDateTime.addHours(businessEndTime.hour()).addMinutes(businessEndTime.minute()).addSeconds(businessEndTime.second());
        DateTime businessStartDateTime = DateTime.newInstance(tempdate.year(), tempdate.month(), tempdate.day());
        businessStartDateTime = businessStartDateTime.addHours(businessStartTime.hour()).addMinutes(businessStartTime.minute()).addSeconds(businessStartTime.second());
        system.debug('-startDate-'+startDate);
        system.debug('-businessEndDateTime-'+businessEndDateTime);
        system.debug('-businessEndDateTime-'+businessStartDateTime);
        if(startDate.getTime() < tempGmtOfPST.getTime() && startDate.getTime()>=businessStartDateTime.getTime())
        {
            long timeDiff = (businessEndDateTime.getTime()  - startDate.getTime());
            integer diff = Math.abs(Integer.valueOf(timeDiff/(1000*60)));
            system.debug('-diff-'+diff);
            return diff;
        }
        else{
            return 540;
        }
    }
}