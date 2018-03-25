//4-12-2016 - siva.pragada@cdk.com - added code to convert integer to long to avoid number overflow.
//2-17-2016 - siva.pragada@cdk.com - removed soql queries and referenced static maps from ALL_Case_Handler - fix for 101 soql error

global with sharing class CB_HoldenTechMileStonesTimeTriggerUpdate implements Support.MilestoneTriggerTimeCalculator
{
    
    global Integer calculateMilestoneTriggerTime(String caseId, String milestoneId) 
    {
        Case currentCase = new Case();
        
        if(caseId != null && ALL_Case_Handler.staticCaseMap != null)
        {
            currentCase = ALL_Case_Handler.staticCaseMap.get((ID)caseId);
        }
        
        MilestoneType milestone = new MilestoneType();
        
        if(milestoneId != null && ALL_Case_Handler.staticMileStonesMap != null)
        {
            milestone = ALL_Case_Handler.staticMileStonesMap.get((ID)milestoneId);
        }
        
        Entitlement entitlementRecord = new Entitlement();
        
        if(currentCase != null && currentCase.EntitlementId != null)
        {
            entitlementRecord = (Entitlement)currentCase.getsObject('Entitlement');
        }
        
        BusinessHours testhHours = new BusinessHours();
        
        if(entitlementRecord != null && entitlementRecord.BusinessHoursId != null)
        {
            testhHours = (BusinessHours)entitlementRecord.getsObject('BusinessHours');
        }
        
        Datetime startDate = DateTime.newInstance(00, 00, 00);
        
        if(currentCase != null && currentCase.SlaStartDate != null && testhHours != null && testhHours.TimeZoneSidKey != null)
        {
            startDate = DateTime.valueOf((currentCase.SlaStartDate.format('yyyy-MM-dd HH:mm:ss', testhHours.TimeZoneSidKey)));
        }
        
        Integer removeSeconds = 0;
        
        if(startDate != null)
        {
            removeSeconds = startDate.second();
        }
        
        startDate = startDate.addSeconds(-removeSeconds);        
		string startDay = startDate.format('EEEE');
        
        
        system.debug('----MilestoneType---'+milestone);
        system.debug('----CaseMilestone---'+entitlementRecord);
        
        integer multiplier = 0;
        
        if(milestone != null && milestone.Name != null)
        {
            multiplier = integer.valueOf(milestone.Name.split(' ')[0]);
        }
        
        Time StartDateTime = Time.newInstance(00, 00, 00, 00);
        Time EndDateTime = Time.newInstance(00, 00, 00, 00);
        
        if(testhHours != null)
        {
            StartDateTime = (Time)testhHours.get(startDay + 'StartTime');
            EndDateTime = (Time)testhHours.get(startDay + 'EndTime');
        }
        
        integer minutes = 0;
        
        
        if (currentCase.Priority != null && currentCase.Priority.equals('Same Day'))
        {
              if (milestone.Name != null && milestone.Name.equals('0 Same Day')) 
              {
                  if(startDay.equals('Satuday') || startDay.equals('Sunday'))
                  {
                      minutes = 960;
                  } 
                  else 
                  {
                      minutes = calcSameBDayDiff(startDate, EndDateTime, StartDateTime);
                  }                  
              }
              else 
              { 
                  minutes = 0;
              }
        }
        else if(multiplier != null && multiplier >= 1)
        {
            minutes = multiplier * 960;
        }
        else 
        {
            minutes = 0;
        }
        
        if(testhHours != null && currentCase != null && minutes != null)
        {
            setTheTargetDateTimeOnCase(testhHours, currentCase, minutes);
        }
        
        return minutes;
    }
   
    global static TimeWrap calcBusinessTimeDiff(Datetime startDate, Time businessEndTime, Time businessStartTime)
    {
        Date tempdate = null;
        
        if(startDate != null)
        {
            tempdate = startDate.date();
        }
        
        DateTime businessEndDateTime = DateTime.newInstance(00, 00, 00);
        
        if(tempdate != null)
        {
            businessEndDateTime = DateTime.newInstance(tempdate.year(), tempdate.month(), tempdate.day());
        }
        
        if(businessEndTime != null)
        {
            businessEndDateTime = businessEndDateTime.addHours(
                businessEndTime.hour()).addMinutes(businessEndTime.minute()).addSeconds(businessEndTime.second());
        }
        
        DateTime businessStartDateTime = null;
        
        if(tempdate != null)
        {
           businessStartDateTime = DateTime.newInstance(tempdate.year(), tempdate.month(), tempdate.day());
        }
        
        if(businessStartTime != null)
        {
            businessStartDateTime = businessStartDateTime.addHours(
                businessStartTime.hour()).addMinutes(businessStartTime.minute()).addSeconds(businessStartTime.second());
        }
        
        TimeWrap tw = new TimeWrap();
        
        if(businessStartDateTime != null && startDate != null && 
           businessStartDateTime.getTime() >= startDate.getTime())
        {
            tw.timeDiff = businessStartDateTime.getTime() - startDate.getTime();
            tw.diffType = 'Early';
        }
        else if(businessEndDateTime != null && startDate != null && 
                businessEndDateTime.getTime() > startDate.getTime() && 
                businessStartDateTime.getTime() < startDate.getTime())
        {
            tw.timeDiff = businessEndDateTime.getTime() - startDate.getTime();
            tw.diffType = 'In Time';
        }
        else
        {
            if(businessEndDateTime != null && startDate != null)
            {
                tw.timeDiff = businessEndDateTime.getTime() - startDate.getTime();
            }
            tw.diffType = 'Late';
        }
        system.debug('***tw***'+tw);
        return tw;
    }
    global static Integer calcSameBDayDiff(Datetime startDate, Time businessEndTime, Time businessStartTime)
    {
        TimeWrap tw = calcBusinessTimeDiff(startDate, businessEndTime, businessStartTime);
        
        Long timeDiff = tw.timeDiff;
        
        integer diff = Math.abs(Integer.valueOf(timeDiff/(1000*60)));
        
        if(tw != null && tw.diffType == 'Early')
        {
            return 960; 
        }
        else if(tw != null && tw.diffType == 'In Time')
        {
            return diff; //remaining time from business hours...
        }
        else
        {
            return 960;
        }        
    }
    global class TimeWrap
    {
        Long timeDiff;
        String diffType;        
    }
    
    public static void setTheTargetDateTimeOnCase(BusinessHours bh, Case currentCase, Integer totalMinutes)
    {
        if(bh != null && currentCase != null && totalMinutes != null)
        {
            long minutes = (long)totalMinutes;
            long seconds = 60;
            long milliSeconds = 1000;
            
            dateTime startDate = currentCase.SlaStartDate;
            long convertedToMilliSeconds = minutes * seconds * milliSeconds;               
            dateTime calculatedTargetDateTime = BusinessHours.add(bh.ID, startDate, convertedToMilliSeconds);            
            currentCase.Target_Date_Time__c = calculatedTargetDateTime;
            
            if(currentCase.Target_Date_Time_SLA__c == null)// only set it on insert
            {
                currentCase.Target_Date_Time_SLA__c = calculatedTargetDateTime;
            }
            
            Database.Update(currentCase, false);
        } 
    }
}