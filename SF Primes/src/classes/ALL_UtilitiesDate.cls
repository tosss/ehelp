global class ALL_UtilitiesDate 
{
    //2015-07-17 siva.pragada@cdk.com Added Weekday List because referenced in multiple places
    global static list<string> Weekdays = new list<string>{'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'};
        
    //createdby siva.pragada@cdk.com and matt.keefe@cdk.com
    global static Integer BusinessDaysCounter(Date CurrentDate, Integer BusinessDaysToAdd, string HolidayFieldDescription)
    {
        // CurrentDate - date from when the user wants to calculate final date with business days in between
        // BusinessDaysToAdd - The number of business days
        // HolidayFieldDescription - The Description field value of the holiday record which is considered to find business days
        
        // if coming from a DateTime variable, use this to get the date
        //Date CurrentDate = CurrentDateTime.date();
        
        // If BusinessDaysToAdd is negative then preserve the original value by assaigning to a new boolean type variable
        boolean NegativeValue = false;
        
        if( BusinessDaysToAdd<0 )
        { 
            NegativeValue = true;
        }
        
        // add wildcards
        HolidayFieldDescription = '%'+HolidayFieldDescription+'%';
        
        List<Holiday> holidays = [
            Select h.StartTimeInMinutes, h.Name, h.ActivityDate, h.EndTimeInMinutes 
            From Holiday h 
            where h.Description like :HolidayFieldDescription
        ];
        
        Set<date> HolidayDateSet = new Set<date>();
        for( holiday h: holidays ){ HolidayDateSet.add( h.ActivityDate ); }
        
        Date StartDate = CurrentDate; // date provided by the method caller
        Date FinalDate;               // the date that is set on the user interface
        
        // lets start checking ( whether working day or holiday or weekend ) from the next day to the date provided by method caller
        if( CurrentDate != null ) 
        { 
            if( BusinessDaysToAdd >= 0 )
            {
                CurrentDate = CurrentDate.addDays( 1 ); 
            } 
            else
            {
                CurrentDate = CurrentDate.addDays( -1 ); 
            }
        }
        
        string day = ALL_UtilitiesDate.DayOfWeek( CurrentDate ); 
        
        // initialize the BusinessDays value with 0 and increment it in the below code if only the day is non- weekend or non-holiday
        integer BusinessDays = 0;
        
        if( BusinessDaysToAdd<0 )
        {
            BusinessDaysToAdd = Math.abs( BusinessDaysToAdd ); 
        }
        // while business days reaches the value provided by the method caller i.e BusinessDaysToAdd, keep loop going
        while( BusinessDays < BusinessDaysToAdd+1 ) 
        {
            // this condition lets in only if the day is a weekday and not a holiday
            if( day != 'Saturday' && day != 'Sunday' && !HolidayDateSet.contains( CurrentDate ) ) 
            {
                // once inside this condition, increment business day by 1
                BusinessDays = BusinessDays + 1;       
                
                // if businessdays equals the method caller ( required value ), go inside this condition
                if( BusinessDays == BusinessDaysToAdd )
                {
                    // once inside this condition, take the currentdate as the final date and break out of the loop and return the method value
                    FinalDate = CurrentDate;
                    break;
                }
                
                // if businessDays is not yet equal to the value specified by the method caller, then check for the next day, so go to next day
                // by incrementing 1 day to the CurrentDate BUT if Businessdays was negative decrement the value by 1
                if( !NegativeValue ) 
                {
                    CurrentDate = CurrentDate + 1;
                }
                else
                {
                    CurrentDate = CurrentDate - 1;
                }
                
                day = ALL_UtilitiesDate.DayOfWeek( CurrentDate );
            }
            else // if the day is a weekend or a holiday enter this loop and only increment CurrentDate not BusinessDays because it is weekend or holiday
            {
                // increment CurrentDate only, BusinessDays stays the same value BUT if Businessdays was negative decrement the value by 1
                if( !NegativeValue ) 
                {
                    CurrentDate = CurrentDate + 1;
                }
                else
                {
                    CurrentDate = CurrentDate - 1;
                }
                
                day = ALL_UtilitiesDate.DayOfWeek( CurrentDate );
                
                // businessDays stays the same value
                BusinessDays = BusinessDays;
            }
        } 
        
        // when the execution comes here, it broke out of the loop and now I have a FinalDate value, use it to calculate no. of days needed by the
        // method caller and return that value
        integer TotalDays = StartDate.daysBetween( FinalDate );
        
        system.debug( 'FinalDate: ' + FinalDate );
        system.debug( 'TotalDays: ' + TotalDays );
        
        
        return TotalDays;
    }
    
    //createdby matt.keefe@cdk.com
    global static string DayOfWeek( Date CurrentDate )
    {
        Date sunday = Date.newInstance( 1899, 12, 31 );
        Integer weekday = Math.mod( sunday.daysBetween( CurrentDate ), 7 );
        
        list<string> WeekdayNames = Weekdays.clone();
        
        return WeekdayNames[weekday];
    }
    
    //createdby siva.pragada@cdk.com and matt.keefe@cdk.com
    global static Date CalculateWeekDay( Date StartDate, Integer Weeks, String TargetDayOfWeek )
    {
        // get date in the past ( -1*weeks*7 ) 
        Integer Days = Weeks * 7;
        Date PrevDate = StartDate.addDays( Days );
        
        set<string> WeekdayNames = new set<string>();
        WeekdayNames.addAll( Weekdays.clone() );
        String PrevDayOfWeek = ALL_UtilitiesDate.DayOfWeek( PrevDate ); 
        
        // check if TargetDayOfWeek is valid
        if( !WeekdayNames.contains( TargetDayOfWeek ) )
        {
            return null;
        }
        
        Date ReferenceDate = PrevDate;
        // iterate until dayofweek = targetdayofweek
      
        while( !PrevDayOfWeek.equals( TargetDayOfWeek ) )
        {
            PrevDate = Weeks >= 0 ? PrevDate.addDays( -1 ) : PrevDate.addDays( 1 );
            PrevDayOfWeek = ALL_UtilitiesDate.DayOfWeek( PrevDate );          
        }  
        
        return PrevDate;
    }
    
}