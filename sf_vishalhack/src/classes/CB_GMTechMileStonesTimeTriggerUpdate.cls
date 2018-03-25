//4-12-2016 - siva.pragada@cdk.com - added code to convert integer to long to avoid number overflow.
//2-17-2016 - siva.pragada@cdk.com - removed soql queries and referenced static maps from ALL_Case_Handler - fix for 101 soql error

global with sharing class CB_GMTechMileStonesTimeTriggerUpdate implements Support.MilestoneTriggerTimeCalculator
{
    //static boolean isInsert = ALL_Case_Handler.isInsert;
    //static boolean isUpdate = ALL_Case_Handler.isUpdate;
    static map<ID, Case> staticNewMap = ALL_Case_Handler.staticNewMap;
    static map<ID, Case> staticOldMap = ALL_Case_Handler.staticOldMap;
    static map<ID, Case> staticCaseMap = ALL_Case_Handler.staticCaseMap;
    static long extraMilliMinutes = null;
    static boolean targetDateSet = false;
    static Case currentCase;
    static MilestoneType milestone;
    static BusinessHours bHours;
    static Case oldCase;
    Static Case newCase;
    
    static void initiateCheckUpForExtraTime(ID CaseID)
    {
        oldCase = staticOldMap != null ? staticOldMap.get(caseId) : null;       
        newCase = staticNewMap != null ? staticNewMap.get(caseId) : null;
        
        Boolean oldCaseConditions = (oldCase != null && oldCase.StopStartDate != null && oldCase.isStopped == true);
        Boolean newCaseConditions = (newCase != null && newCase.isStopped == false && newCase.Status != 'Closed' &&
                                      newCase.Status != 'Resolved');
        
        if(oldCaseConditions && newCaseConditions)
        {
            extraMilliMinutes = BusinessHours.diff(bHours.ID, oldCase.StopStartDate, DateTime.now());
        } 
    }
    
    static integer addExtraTimeSpentWaiting()
    {  
        if(bHours != null && currentCase != null)
        {    
            dateTime calculatedTargetDateTime;
            
            if(currentCase.Target_Date_Time__c != null && extraMilliMinutes != null)
            {  
                if(currentCase.Target_Date_Time__c > DateTime.now())
                {
                    calculatedTargetDateTime = BusinessHours.add(bHours.ID, currentCase.Target_Date_Time__c, extraMilliMinutes);
                }                
                else //if(currentCase.Target_Date_Time__c < DateTime.now())
                { 
                    Integer minutes  = returnMinutes(); 
                    Long totalMilliMinutes = minutes * 60000;
                    Long timeDifference = 0;
                    
                    List<CaseHistory> caseHistories = new List<CaseHistory>();  
                    caseHistories = currentCase.Histories;                    
                    SortUtility SortMe = new SortUtility(caseHistories, 'CreatedDate');
                    caseHistories = SortMe.CustomSort();
                    
                    for(integer i=0;  i < caseHistories.size(); i++ )
                    {
                        if(caseHistories[i].newValue == true && currentCase.Histories[i].CreatedDate < currentCase.Target_Date_Time__c)
                        {
                            long hisCreatedDate = caseHistories[i].CreatedDate.getTime();
                            
                            if(i != 0 && caseHistories[i-1].newValue == false)
                            {
                                timeDifference += BusinessHours.diff(bHours.ID, caseHistories[i-1].CreatedDate, caseHistories[i].CreatedDate);
                            }
                            else // if i=0 that means, status changed to Waiting first time.
                            {
                                timeDifference += BusinessHours.diff(bHours.ID, currentCase.CreatedDate, caseHistories[i].CreatedDate);
                            }
                           
                        }
                    }
                    
                    long milliMinutes2Set = totalMilliMinutes - timeDifference;
                    calculatedTargetDateTime = BusinessHours.add(bHours.ID, DateTime.now(), milliMinutes2Set);                    
                    currentCase.Target_Date_Time__c = calculatedTargetDateTime;
                    currentCase.Target_Date_Time_SLA__c = calculatedTargetDateTime;
                    Database.Update(currentCase);
                    return integer.valueOf(totalMilliMinutes/60000);
                }
                
                currentCase.Target_Date_Time__c = calculatedTargetDateTime;
                currentCase.Target_Date_Time_SLA__c = calculatedTargetDateTime;
                Database.Update(currentCase);
                targetDateSet = true;
            }
        }
        return null;
    }
    
    static void retrieveRecords(String caseId, String milestoneId)
    {
        currentCase = new Case();
        
        if(caseId != null && ALL_Case_Handler.staticCaseMap != null)
        {
            currentCase = ALL_Case_Handler.staticCaseMap.get((ID)caseId);
        }
        
        milestone = new MilestoneType();
        
        if(milestoneId != null && ALL_Case_Handler.staticMileStonesMap != null)
        {
            milestone = ALL_Case_Handler.staticMileStonesMap.get((ID)milestoneId);
        }
        
        Entitlement entitlementRecord = new Entitlement();
        
        if(currentCase != null && currentCase.EntitlementId != null)
        {
            entitlementRecord = (Entitlement)currentCase.getsObject('Entitlement');
        }
        
        bHours = null;
        
        if(entitlementRecord != null && entitlementRecord.BusinessHoursId != null)
        {
            bHours = (BusinessHours)entitlementRecord.getsObject('BusinessHours');
        }
    }
    
    static Integer returnMinutes()
    {
        Datetime startDate = DateTime.newInstance(00, 00, 00);
        
        if(currentCase != null && currentCase.SlaStartDate != null && bHours != null && bHours.TimeZoneSidKey != null)
        {
            startDate = DateTime.valueOf((currentCase.SlaStartDate.format('yyyy-MM-dd HH:mm:ss', bHours.TimeZoneSidKey)));
        }
        
        Integer removeSeconds = 0;
        
        if(startDate != null)
        {
            removeSeconds = startDate.second();
        }
        
        startDate = startDate.addSeconds(-removeSeconds);
        string startDay = startDate.format('EEEE');
        
        integer multiplier = 0;
        Time StartDateTime = Time.newInstance(00, 00, 00, 00);
        Time EndDateTime = Time.newInstance(00, 00, 00, 00);
        
        if(bHours != null && startDay != null)
        {
            StartDateTime = (Time)bHours.get(startDay + 'StartTime');
            EndDateTime = (Time)bHours.get(startDay + 'EndTime');
        }
        
        if(milestone != null && milestone.Name != null)
        {
            multiplier = integer.valueOf(milestone.Name.split(' ')[0]);
        }
        
        integer minutes = 1;
        
        system.debug(multiplier);
        
        if (currentCase != null && currentCase.Priority != null && currentCase.Priority.equals('Same Day') && 
            milestone != null && milestone.Name != null && milestone.Name.equals('0 Same Day'))
        {
            
            if(startDay == 'Saturday')
            {
                minutes = calcSameBDayDiffSaturday(startDate, EndDateTime, StartDateTime);
            }
            else if(startDay == 'Friday')
            {
                minutes = calcSameBDayDiffFriday(startDate, EndDateTime, StartDateTime, true );
            }
            else if(startDay == 'Sunday')
            {
                minutes = 720;
            }
            else
            {
                minutes = calcSameBDayDiff(startDate, EndDateTime, StartDateTime);
            }
            
        }
        else if(multiplier != null && multiplier >= 1)
        { 
            if(startDay == 'Saturday')
            {
                minutes = 720 * (multiplier - 1) + calcSameBDayDiffSaturday(startDate, EndDateTime, StartDateTime);
            }
            else if(startDay == 'Friday')
            {
                minutes = 720 * (multiplier - 1) + calcSameBDayDiffFriday(startDate, EndDateTime, StartDateTime, false );
            }
            else
            {
                minutes = multiplier * 720;
            }
        }         
        else 
        {
            minutes = 20;
        }
        
        return minutes;
    }
    
    public static boolean mileStoneChanged(String milestoneId)
    {
        List<CaseMileStone> oldCaseMileStones = new List<CaseMileStone>();
        
        if(currentCase != null)
        {
            oldCaseMileStones = currentCase.CaseMileStones;
        }
        
        CaseMileStone oldCaseMileStone;
        //displayDebuggedValueOnScreen(staticCaseMap, new map<ID, Case>());
        if(oldCaseMileStones != null && !oldCaseMileStones.isEmpty())
        {
            oldCaseMileStone = oldCaseMileStones[0];
        }
        
        MileStoneType newMileStone = ALL_Case_Handler.staticMileStonesMap.get((ID)milestoneId);
        Boolean mileStoneChanged = null;
        
        if(oldCaseMileStone != null && newMileStone != null && oldCaseMileStone.MileStoneTypeId != newMileStone.ID)
        {
        	mileStoneChanged = true;
        }
        else if(oldCaseMileStone == null && newMileStone != null)
        {
            mileStoneChanged = true;
        }
        
        return mileStoneChanged;
    }
    
    global Integer calculateMilestoneTriggerTime(string caseId, string milestoneId) 
    { 
        //retrive currentCase, MilestoneType and BusinessHours and assign to static variables
        retrieveRecords(caseId, milestoneId);
        
        //case ca = [select id, milestoneStatus from Case WHere id = :caseid limit 1];
        //system.assertEquals(ca.MilestoneStatus, 'gdhdhd');
        //below method evaluates extraMilliMinutes variable.
        initiateCheckUpForExtraTime(caseId);
        
        String milestoneStatus = oldCase != null ? oldCase.MilestoneStatus : 'Coolio';
        
        if(currentCase != null &&  bHours != null && extraMilliMinutes != null &&
          (currentCase.MilestoneStatus != 'Open Violation' || (currentCase.MilestoneStatus == 'Open Violation' && milestoneStatus == 'Compliant')))// || currentCase.MilestoneStatus == 'Compliant'))
        {
            integer totalMinutes = addExtraTimeSpentWaiting();
            
            if(totalMinutes != null)
            {
                return totalMinutes;
            }
        }
        
        Integer minutes = returnMinutes();
        
        boolean mileStoneChanged = mileStoneChanged(milestoneId);
        
        if(ALL_CheckRecursive.runCodeBlockOnce('runOnce_3@Case'))
        {
            if(mileStoneChanged != null && mileStoneChanged == true && 
               (currentCase.MilestoneStatus != 'Open Violation'))// || currentCase.MilestoneStatus == 'Compliant'))
        	{
                setTheTargetDateTimeOnCase(minutes);
            }
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
        
        DateTime businessEndDateTime = null;
        
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
            tw.diffType = 'InTime';
        }
        else
        {
            if(businessEndDateTime != null && startDate != null)
            {
                tw.timeDiff = businessEndDateTime.getTime() - startDate.getTime();
            }
            tw.diffType = 'Late';
        }
        
        return tw;
    }
    global static Integer calcSameBDayDiff(Datetime startDate, Time businessEndTime, Time businessStartTime)
    {
        TimeWrap tw = calcBusinessTimeDiff(startDate, businessEndTime, businessStartTime);
        Long timeDiff = null;
        
        if(tw != null)
        {
            timeDiff = tw.timeDiff;
        }
        
        if(tw != null && tw.diffType != null && 
           timeDiff != null && tw.diffType.equals('InTime'))
        {
            integer diff = Math.abs((Integer.valueOf(timeDiff/(1000*60))));
            system.debug('The difference returned is----'+diff);
            return diff; //remaining time from business hours...
        }
        else
        {
            return 720;
        }        
    }
    global static Integer calcSameBDayDiffSaturday(Datetime startDate, Time businessEndTime, Time businessStartTime)
    {
        TimeWrap tw = calcBusinessTimeDiff(startDate, businessEndTime, businessStartTime);
        
        Long timeDiff = null ;
        
        if(tw != null)
        {
            timeDiff = tw.timeDiff;
        }
        
        if(tw != null && tw.diffType != null && tw.diffType.equals('Early'))
        {
            return 1440; 
        }
        else if(tw != null && tw.diffType != null && 
                timeDiff != null && tw.diffType.equals('InTime'))
        {
            integer diff = Math.abs((Integer.valueOf(timeDiff/(1000*60)))); 
            
            return diff+720; //remaining time from business hours...
         } 
        else
        {
          return 720;
        }       
    }
    global static Integer calcSameBDayDiffFriday(Datetime startDate, Time businessEndTime, Time businessStartTime, Boolean isSameDay)
    {
        TimeWrap tw = calcBusinessTimeDiff(startDate, businessEndTime, businessStartTime);
        
        Long timeDiff = null;
        
        if(tw != null)
        {
            timeDiff = tw.timeDiff;
        }
        
        if(tw != null && tw.diffType != null && tw.diffType.equals('Early'))
        {
            return 720; 
        }
        else if(tw != null && tw.diffType != null && tw.diffType.equals('InTime'))
        { 
            if(isSameDay && timeDiff != null)
            {
                integer diff = Math.abs((Integer.valueOf(timeDiff/(1000*60))));
                
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
    public static void setTheTargetDateTimeOnCase(Integer totalMinutes)
    {  
        if(bHours != null && currentCase != null && 
        totalMinutes != null && targetDateSet == false && 
        currentCase.Status != 'Waiting')
        {
            long minutes = (long)totalMinutes;
            long seconds = 60;
            long milliSeconds = 1000;
            
            dateTime startDate = currentCase.SlaStartDate;
            long convertedToMilliSeconds = minutes * seconds * milliSeconds;            
            dateTime calculatedTargetDateTime = BusinessHours.add(bHours.ID, startDate, convertedToMilliSeconds);            
            currentCase.Target_Date_Time__c = calculatedTargetDateTime;
                   
            if(currentCase.Target_Date_Time_SLA__c == null) 
            {
                currentCase.Target_Date_Time_SLA__c = calculatedTargetDateTime;
            }
            Database.Update(currentCase, false);
        } 
    }
}