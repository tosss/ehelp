global with sharing class CB_GMTechMileStonesTimeTriggerUpdate implements Support.MilestoneTriggerTimeCalculator
{
    
    global Integer calculateMilestoneTriggerTime(string caseId, string milestoneId) 
    {
        Case c = [SELECT Id, Priority, EntitlementId, SlaStartDate, Product_Category__c,Problem_Code__c FROM Case WHERE Id=:caseId];
        MilestoneType mt = [SELECT Name FROM MilestoneType WHERE Id=:milestoneId ];
        Entitlement ent = [Select Id, BusinessHoursId from Entitlement where Id = :c.EntitlementId ];
        system.debug('----BusinessHoursId----'+ent.BusinessHoursId);
        BusinessHours testhHours = [Select Id, TimeZoneSidKey,MondayStartTime, MondayEndTime,TuesdayStartTime, TuesdayEndTime,
                                    WednesdayStartTime, WednesdayEndTime,ThursdayStartTime, ThursdayEndTime,FridayStartTime, 
                                    FridayEndTime,SaturdayStartTime,SaturdayEndTime  from BusinessHours where id = :ent.BusinessHoursId limit 1];
        system.debug('-----EProcess Started Time--------'+c.SlaStartDate);
        Datetime startDate = DateTime.valueOf((c.SlaStartDate.format('yyyy-MM-dd HH:mm:ss', testhHours.TimeZoneSidKey)));
        Integer removeSeconds = startDate.second();
        startDate = startDate.addSeconds(-removeSeconds);
		string startDay = startDate.format('EEEE');
        system.debug('----MilestoneType---'+mt);
        system.debug('----CaseMilestone---'+ent);
        system.debug('-----StartDay---------'+startDay);
        if (c.Priority != null && c.Priority.equals('Same Day')){
              if (mt.Name != null && mt.Name.equals('0 Same Day')) 
              {
                  if(startDay.equals('Saturday')){
                      return calcSameBDayDiffSaturday(startDate, testhHours.SaturdayEndTime,testhHours.SaturdayStartTime );    
                  }else if(startDay.equals('Friday')){
                      return calcSameBDayDiffFriday(startDate, testhHours.FridayEndTime,testhHours.FridayStartTime, true );   
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
                      return 720;
                  }
                      
                  
              }
              else { return 0; }
        }
        else if (mt.Name != null && mt.Name.equals('1 Day')) 
        {
            if(startDay.equals('Saturday')){
                return calcSameBDayDiffSaturday(startDate, testhHours.SaturdayEndTime,testhHours.SaturdayStartTime );    
            }else if(startDay.equals('Friday')){
                return calcSameBDayDiffFriday(startDate, testhHours.FridayEndTime,testhHours.FridayStartTime, false );   
            }   
            else{
                return 720;
            }     
        }
        else if (mt.Name != null && mt.Name.equals('2 Day')) 
        {
            if(startDay.equals('Saturday')){
                return 720 + calcSameBDayDiffSaturday(startDate, testhHours.SaturdayEndTime,testhHours.SaturdayStartTime );    
            }else if(startDay.equals('Friday')){
                return 720 + calcSameBDayDiffFriday(startDate, testhHours.FridayEndTime,testhHours.FridayStartTime, false );
            }else{
                return 1440;
            }
        } 
        else if (mt.Name != null && mt.Name.equals('3 Day')) 
        {
            if(startDay.equals('Saturday')){
                return 1440 + calcSameBDayDiffSaturday(startDate, testhHours.SaturdayEndTime,testhHours.SaturdayStartTime );    
            }else if(startDay.equals('Friday')){
                return 1440 + calcSameBDayDiffFriday(startDate, testhHours.FridayEndTime,testhHours.FridayStartTime, false );
            }else{
                return 2160;
            }
            
            
        } 
        else if (mt.Name != null && mt.Name.equals('10 Day')) 
        {
            system.debug('------I am entering the first if---------');
            if(startDay.equals('Saturday')){
                return 6480 + calcSameBDayDiffSaturday(startDate, testhHours.SaturdayEndTime,testhHours.SaturdayStartTime );    
            }else if(startDay.equals('Friday')){
                return 6480 + calcSameBDayDiffFriday(startDate, testhHours.FridayEndTime,testhHours.FridayStartTime, false );
            }else{
                system.debug('---------Are you entering here?----------');
                return 7200;
            }
        }
                      
        else {
            return 20;
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
            tw.diffType = 'InTime';
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
        if(tw.diffType.equals('InTime')){
            integer diff = Math.abs((Integer.valueOf(timeDiff/(1000*60))));
            system.debug('The difference returned is----'+diff);
            return diff; //remaining time from business hours...
        }
        else{
            return 720;
        }        
    }
    global static Integer calcSameBDayDiffSaturday(Datetime startDate, Time businessEndTime, Time businessStartTime){
        TimeWrap tw = calcBusinessTimeDiff(startDate, businessEndTime, businessStartTime);
        Long timeDiff = tw.timeDiff;
        system.debug('---tw-Sat-'+tw);
        if(tw.diffType.equals('Early')){
            return 1440; 
        }else if(tw.diffType.equals('InTime')){
            integer diff = Math.abs((Integer.valueOf(timeDiff/(1000*60)))); 
            system.debug('---diff-Sat-'+diff);
            return diff+720; //remaining time from business hours...
         } 
        else{
          return 720;
        }       
    }
    global static Integer calcSameBDayDiffFriday(Datetime startDate, Time businessEndTime, Time businessStartTime, Boolean isSameDay){
        TimeWrap tw = calcBusinessTimeDiff(startDate, businessEndTime, businessStartTime);
        Long timeDiff = tw.timeDiff;
        system.debug('---tw-Fri-'+tw);
        if(tw.diffType.equals('Early'))
        {
            return 720; 
        }
        else if(tw.diffType.equals('InTime'))
        { 
            if(isSameDay)
            {
                integer diff = Math.abs((Integer.valueOf(timeDiff/(1000*60))));
                system.debug('---diff-Fri-'+diff);
                return diff;
            }
            else
            {
                return 720;
            }                 
        }
        else
        {
            return 1440;
        }       
    }
    global class TimeWrap
    {
        Long timeDiff;
        string diffType;        
    }
}