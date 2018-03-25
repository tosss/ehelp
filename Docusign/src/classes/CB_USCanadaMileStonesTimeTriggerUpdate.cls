global with sharing class CB_USCanadaMileStonesTimeTriggerUpdate implements Support.MilestoneTriggerTimeCalculator
{
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneId) 
    {
        Case c = [SELECT Id, Priority, EntitlementId, SlaStartDate FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneId];
        Entitlement ent = [Select Id, BusinessHoursId from Entitlement where Id = :c.EntitlementId];
        BusinessHours testhHours = [Select Id, TimeZoneSidKey,MondayStartTime, MondayEndTime,TuesdayStartTime, TuesdayEndTime,
                                    WednesdayStartTime, WednesdayEndTime,ThursdayStartTime, ThursdayEndTime,FridayStartTime, 
                                    FridayEndTime from BusinessHours where id = :ent.BusinessHoursId];
        Datetime startDate = DateTime.valueOf((c.SlaStartDate.format('yyyy-MM-dd HH:mm:ss', testhHours.TimeZoneSidKey)));
        Integer removeSeconds = startDate.second();
        startDate = startDate.addSeconds(-removeSeconds);
		string startDay = startDate.format('EEEE');
        system.debug('----MilestoneType---'+mt);
        system.debug('----CaseMilestone---'+ent);
        if (c.Priority != null && c.Priority.equals('Same Day')){
              if (mt.Name != null && mt.Name.equals('0 Same Day')) 
              {
                      
                  if(startDay.equals('Friday')){
                      return calcSameBDayDiff(startDate, testhHours.FridayEndTime, testhHours.FridayStartTime);   
                  }
                  else if(startDay.equals('Thursday') ){
                      return calcSameBDayDiff(startDate, testhHours.ThursdayEndTime, testhHours.ThursdayStartTime);
                  }
                  else if(startDay.equals('Wednesday') ){                      
                      return calcSameBDayDiff(startDate, testhHours.WednesdayEndTime, testhHours.WednesdayStartTime);

                  }
                  else if(startDay.equals('Tuesday') ){
                      return calcSameBDayDiff(startDate, testhHours.TuesdayEndTime, testhHours.TuesdayStartTime);                      
                  }
                  else if(startDay.equals('Monday') ){
                      return calcSameBDayDiff(startDate, testhHours.MondayEndTime, testhHours.MondayStartTime);
                  }
                  else{
                      return 780;
                  }
              }
              else { return 0; }
        }
        else {
            return 0;
        }
     
        
    }
   
    global static TimeWrap calcBusinessTimeDiff(Datetime startDate, Time businessEndTime, Time businessStartTime){
        Date tempdate = startDate.date();        
        DateTime businessEndDateTime = DateTime.newInstance(tempdate.year(), tempdate.month(), tempdate.day());
        businessEndDateTime = businessEndDateTime.addHours(businessEndTime.hour()).addMinutes(businessEndTime.minute()).addSeconds(businessEndTime.second());
        DateTime businessStartDateTime = DateTime.newInstance(tempdate.year(), tempdate.month(), tempdate.day());
        businessStartDateTime = businessStartDateTime.addHours(businessStartTime.hour()).addMinutes(businessStartTime.minute()).addSeconds(businessStartTime.second());
        TimeWrap tw = new TimeWrap();
        system.debug('***businessStartDateTime***' + businessStartDateTime.getTime());
        system.debug('***businessEndDateTime***' + businessEndDateTime.getTime());
        system.debug('***startDateTime***' + startDate.getTime());
        if(businessStartDateTime.getTime() >= startDate.getTime()){
            tw.timeDiff = businessStartDateTime.getTime() - startDate.getTime();
            tw.diffType = 'Early';
        }else if(businessEndDateTime.getTime() > startDate.getTime() && businessStartDateTime.getTime() < startDate.getTime()){
            tw.timeDiff = businessEndDateTime.getTime() - startDate.getTime();
            tw.diffType = 'In Time';
        }else{
            tw.timeDiff = businessEndDateTime.getTime() - startDate.getTime();
            tw.diffType = 'Late';
        }
        system.debug('***tw***'+tw);
        return tw;
    }
    global static Integer calcSameBDayDiff(Datetime startDate, Time businessEndTime, Time businessStartTime){
        TimeWrap tw = calcBusinessTimeDiff(startDate, businessEndTime, businessStartTime);
        Long timeDiff = tw.timeDiff;
        if(tw.diffType == 'Early'){
            return 780; 
        }else if(tw.diffType == 'In Time'){
            integer diff = Math.abs(Integer.valueOf(timeDiff/(1000*60)));
            return diff; //remaining time from business hours...
        }else{
            return 780;
        }        
    }
    global class TimeWrap{
        Long timeDiff;
        string diffType;        
    }
}