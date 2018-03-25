global class Utilities
{
	//2015-06-30 hemanth.kesapragada@cdk.com Added flag to enable/disable debugging
    global static Boolean showDebug;
	
    global static string ListTostring(List<string> Values) 
    { 
        return ListToEnclosedCsv(Values, '\''); 
    }
    
    global static string ListToDelimitedstring(List<string> Values, string Delimiter)
    {
        string DelimitedString = '';
        
        if(values.size() > 0)
        {
            for(Integer i=0; i<Values.size(); i++) 
            {
                DelimitedString += values[i] + (i == (values.size()-1) ? '' : Delimiter);
            }
        }
        return DelimitedString;
    }
    
    global static string ListToCSV(List<string> Values) 
    { 
        return ListToEnclosedCsv(Values, '\''); 
    }
    
    global static string ListToEnclosedCsv(List<string> Values, string EncloseChar)
    {
        string CSV = '';
        
        if(Values.size() > 0) {
            for(Integer i=0; i<Values.size(); i++) {
                CSV += (i != 0 ? ',' + EncloseChar : EncloseChar) + Values[i] + EncloseChar; } }
        
        return CSV;
    }
    
    global static string ListToParenthesesCsv(List<string> Values) 
    {
        if(Values == null) { return ''; } // no values
        
        string Csv = ListToCSV(Values);
        return '(' + Csv + ')'; // values with parentheses
    }
    
    global static string ListToInclusiveCondition(string WhereOrAnd, string FieldName, List<string> Values) 
    {
    	string WhereOrAndLower = WhereOrAnd != null ? WhereOrAnd.ToLowerCase() : null;
    	
    	// validation
    	if(WhereOrAndLower != 'where' && WhereOrAndLower != 'and' 
    	|| FieldName.length() < 1 
    	|| Values == null 
    	|| Values.IsEmpty()) { 
    		return ''; 
		}
    	
    	if(Values.size() == 1) { return WhereOrAnd + ' ' + FieldName + ' = ' + ListToCSV(Values); }
    	else { return WhereOrAnd + ' ' + FieldName + ' IN ' + ListToParenthesesCsv(Values); }
    }
    
	global static Object GetDataFromNestedFields(string FieldName, sObject ParseObject)
	{
		//system.debug(FieldName);
		//system.debug(ParseObject);
		
		Object FieldValue = null;
		
        // if nested query fields, get the nested field value
        if(FieldName.contains('.'))
        {
            List<string> NestedFields = FieldName.split('\\.'); system.debug(NestedFields);
            sObject RelationshipSObject = ParseObject.getSObject(NestedFields[0]); //system.debug(RelationshipSObject);
            
            for(Integer j=1; j<NestedFields.size()-1; j++) {
                RelationshipSObject = RelationshipSObject.getSObject(NestedFields[j]); //system.debug(RelationshipSObject); 
            }
            
            if(RelationshipSObject != null) 
            {
            	string NestedFieldName = NestedFields[NestedFields.size()-1];
            	
                //try { // try to get the value, but if error do not set the FieldValue (return null)
                    FieldValue = NestedFieldName.toLowerCase().endsWith('__r') ? 
                        RelationshipSObject.getSObject(NestedFieldName) :
                        RelationshipSObject.get(NestedFieldName);
                //}
                //catch(Exception e) { system.debug(e); }
        	}
        }
        // otherwise, get the field value directly
        else 
        { 
            //try { // try to get the value, but if error do not set the FieldValue (return null)
                FieldValue = FieldName.toLowerCase().endsWith('__r') ? 
                    ParseObject.getSObject(FieldName) : 
                	ParseObject.get(FieldName); 
            //}
            //catch(Exception e) { system.debug(e); }
		}
        
        return FieldValue;
	}
	
	global static sObject PutDataInNestedFields(string FieldName, sObject OverrideSObject, Object ReplacementFieldValue)
	{
		// if nested replacement fields, get the nested sObject
        if(FieldName.contains('.'))
        {
            List<string> NestedFields = FieldName.split('\\.'); //system.debug(NestedFields);
            sObject RelationshipSObject = OverrideSObject.getSObject(NestedFields[0]);
            
            for(Integer j=1; j<NestedFields.size()-1; j++) {
                RelationshipSObject = RelationshipSObject.getSObject(NestedFields[j]); }
            
            RelationshipSObject.put(NestedFields[NestedFields.size()-1], ReplacementFieldValue);
        }
        // otherwise, put the field value directly
        else { OverrideSObject.put(FieldName, ReplacementFieldValue); }
        
        return OverrideSObject;
	}
    
    public static integer RandomInteger(integer min, integer max)
    {
        integer range = Math.abs(max - min) + 1;
        return integer.valueOf( (Math.random() * range) + (min <= max ? min : max) );
    }
    
    public static long CryptoRandom()
    {
        return Math.abs(Crypto.getRandomLong()); 
    }
    
    global static string TrueRandomUpToAMillion()
    {
        // RandomNumber is at max 999000 (1000*999) to begin with
        //   note zero is not an included possibility
        integer RandomNumber = Utilities.RandomInteger(1,1000) * DateTime.now().millisecond();
        
        // add remaining random to get up to but not including one million
        RandomNumber += Utilities.RandomInteger(1,999);
        
        string Random = string.valueOf( RandomNumber );
        return Random;
    }
    
    public static string GetCurrentInstanceName()
    {
        string InstanceName = UserInfo.getOrganizationId();
        
        string SystemHost = URL.getSalesforceBaseUrl().getHost();
        list<string> SystemHostParts = SystemHost.split('\\.');
        
        string SystemSubDomain = null; 
        if(SystemHostParts != null && !SystemHostParts.isEmpty()) { 
            SystemSubDomain = SystemHostParts.get(0); 
        }
        
        if(SystemSubDomain != null) 
        {
            // check dash dash for sandbox with custom domain
            if(SystemSubDomain.contains('--') && !SystemSubDomain.endsWith('--'))
            {
                list<string> SubDomainParts = SystemSubDomain.split('--');
                InstanceName = SubDomainParts.get(SubDomainParts.size()-1);
            }
            else
            {
                InstanceName = SystemSubDomain;
            }
        }
        
        return InstanceName;
    }
    
    public static string RandomUserName(string Context)
    {
        string Random = Utilities.TrueRandomUpToAMillion();
        string InstanceName = GetCurrentInstanceName();
        
        return 'test-'+Random+'-'+Context+'@cdk.com.'+InstanceName;
    }
    
    global static void PreventMultipleOnParent(
        list<sObject> ChildObjects, 
        string ParentSObjectType, 
        string ParentIdField, 
        string ChildObjectRelationship, 
        string PageErrorMessage)
    {
        if(ChildObjects != null && !ChildObjects.IsEmpty())
        {
            list<Id> ParentIds = new list<Id>();
            
            for(sObject s : ChildObjects) { 
                if(s.get(ParentIdField) != null) { 
                    ParentIds.add((Id)s.get(ParentIdField)); 
                } 
            }
            
            string WhereInParentIds = Utilities.ListToInclusiveCondition('Where', 'Id', ParentIds);
            
            string ParentQuery = ''
                + 'Select Id, (Select Id From ' + ChildObjectRelationship + ') '
                + 'From ' + ParentSObjectType + ' '
                +  WhereInParentIds;
            
            map<Id, sObject> Parents = new map<Id, sObject>((list<sObject>)database.query(ParentQuery));
            
            if(Parents != null && !Parents.isEmpty())
            {
                for(sObject CurrentChild : ChildObjects)
                {
                    Id ParentId = (Id)CurrentChild.get(ParentIdField);
                    
                    if(ParentId != null) 
                    {
                        sObject CurrentParent = Parents.get(ParentId); 
                        list<sObject> ChildrenFromParent = CurrentParent.getSObjects(ChildObjectRelationship);
                        
                        if(ChildrenFromParent != null && !ChildrenFromParent.isEmpty())
                        {
                            CurrentChild.addError(PageErrorMessage);
                        }
                    }
                } // end Current Child for loop
            }
        } // end if ChildObjects records
    }
    
    public static Integer BusinessDaysCounter(Date CurrentDate, Integer BusinessDaysToAdd, string HolidayFieldDescription)
    {
        // CurrentDate - date from when the user wants to calculate final date with business days in between
        // BusinessDaysToAdd - The number of business days
        // HolidayFieldDescription - The Description field value of the holiday record which is considered to find business days
        
        // if coming from a DateTime variable, use this to get the date
        //Date CurrentDate = CurrentDateTime.date();
        
        // If BusinessDaysToAdd is negative then preserve the original value by assaigning to a new boolean type variable
        boolean NegativeValue = false;
        
        if(BusinessDaysToAdd<0)
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
        for(holiday h: holidays){ HolidayDateSet.add(h.ActivityDate); }
        
        Date StartDate = CurrentDate; // date provided by the method caller
        Date FinalDate;               // the date that is set on the user interface
        
        // lets start checking (whether working day or holiday or weekend) from the next day to the date provided by method caller
        if(CurrentDate != null) 
        { 
            if(BusinessDaysToAdd >= 0)
            {
                CurrentDate = CurrentDate.addDays(1); 
            } 
            else
            {
                CurrentDate = CurrentDate.addDays(-1); 
            }
        }
        
        string day = Utilities.DayOfWeek(CurrentDate); 
        
        // initialize the BusinessDays value with 0 and increment it in the below code if only the day is non- weekend or non-holiday
        integer BusinessDays = 0;
        
        if(BusinessDaysToAdd<0)
        {
            BusinessDaysToAdd = Math.abs(BusinessDaysToAdd); 
        }
        // while business days reaches the value provided by the method caller i.e BusinessDaysToAdd, keep loop going
        while(BusinessDays < BusinessDaysToAdd+1) 
        {
            // this condition lets in only if the day is a weekday and not a holiday
            if(day != 'Saturday' && day != 'Sunday' && !HolidayDateSet.contains(CurrentDate)) 
            {
                // once inside this condition, increment business day by 1
                BusinessDays = BusinessDays + 1;       
                
                // if businessdays equals the method caller (required value), go inside this condition
                if(BusinessDays == BusinessDaysToAdd)
                {
                    // once inside this condition, take the currentdate as the final date and break out of the loop and return the method value
                    FinalDate = CurrentDate;
                    break;
                }
                
                // if businessDays is not yet equal to the value specified by the method caller, then check for the next day, so go to next day
                // by incrementing 1 day to the CurrentDate BUT if Businessdays was negative decrement the value by 1
                if(!NegativeValue) 
                {
                    CurrentDate = CurrentDate + 1;
                }
                else
                {
                    CurrentDate = CurrentDate - 1;
                }
                
                day = Utilities.DayOfWeek(CurrentDate);
            }
            else // if the day is a weekend or a holiday enter this loop and only increment CurrentDate not BusinessDays because it is weekend or holiday
            {
                // increment CurrentDate only, BusinessDays stays the same value BUT if Businessdays was negative decrement the value by 1
                if(!NegativeValue) 
                {
                    CurrentDate = CurrentDate + 1;
                }
                else
                {
                    CurrentDate = CurrentDate - 1;
                }
                
                day = Utilities.DayOfWeek(CurrentDate);
                
                // businessDays stays the same value
                BusinessDays = BusinessDays;
            }
        } 
        
        // when the execution comes here, it broke out of the loop and now I have a FinalDate value, use it to calculate no. of days needed by the
        // method caller and return that value
        integer TotalDays = StartDate.daysBetween(FinalDate);
        
        system.debug('FinalDate: ' + FinalDate);
        system.debug('TotalDays: ' + TotalDays);
        
        
        return TotalDays;
    }
    
    global static string DayOfWeek(Date CurrentDate)
    {
        Date sunday = Date.newInstance(1899, 12, 31);
        Integer weekday = Math.mod(sunday.daysBetween(CurrentDate), 7);
        
        list<string> WeekdayNames = new list<string>{'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'};
        
        return WeekdayNames[weekday];
    }
    
    // 2015-06-30 hemanth.kesapragada@cdk.com Method to show debug flags if showDebug variable set to TRUE
    global static void debug( object objectRecord )
    {
        //flag to enable debugging
        Boolean customSetting = CustomSettings__c.getOrgDefaults().Show_Debug__c;
        if( showDebug && customSetting )
        {
            System.debug( '***** '+objectRecord );
        }
    }
    
    global class Job
    {
    	global string Status;
		global Integer NumberOfErrors;
		global Integer JobItemsProcessed;
		global Integer TotalJobItems;
		global string CreatedByEmail;
		global DateTime CreatedDate;
		
		global Job(AsyncApexJob j) { if(j != null) {
			Status = j.Status;
			NumberOfErrors = j.NumberOfErrors;
			JobItemsProcessed = j.JobItemsProcessed;
			TotalJobItems = j.TotalJobItems;
			CreatedByEmail = j.CreatedBy != null ? j.CreatedBy.Email : null;
			CreatedDate = j.CreatedDate;
		} }
		
		global Job() 
		{
			Status = 'Job ID not found';
			NumberOfErrors = 0;
			JobItemsProcessed = 0;
			TotalJobItems = 0;
			CreatedByEmail = '';
			CreatedDate = DateTime.Now();
		}
    }
    
    global static ID getRecordTypeIdOfAnySObject(string sObjectName, string RecordTypeName)
    {
        map<string, Schema.RecordTypeInfo> rtMapByName 
            = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosByName();
        
        return rtMapByName.get(RecordTypeName).getRecordTypeId();
    }
    
    global static string getRecordTypeNameOfAnySObject(string sObjectName, ID RecordTypeId)
    {
        map<ID, Schema.RecordTypeInfo> rtMapByName 
            = Schema.getGlobalDescribe().get(sObjectName).getDescribe().getRecordTypeInfosById();
        
        return rtMapByName.get(RecordTypeId).getName();
    }
    
    global static void SendBatchCompleteMessage(Job j, string title, string description, string msg)
    {
        GlobalSettings gs = GlobalSettings.getInstance(null);
        system.debug(gs.ERROR_EMAIL);
        
        if(gs.ERROR_EMAIL != null && j != null) 
        {
            system.debug(j);
            
            // Send an email to the Apex job's submitter notifying of job completion.  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // string[] toAddresses = new string[] {a.CreatedBy.Email};
            string[] toAddresses = gs.ERROR_EMAIL;
            
            mail.setToAddresses(toAddresses);
            mail.setSubject(title + ' executed on: ' + j.CreatedDate.format(gs.DATETIME_FORMAT) + ' Status:' + j.Status);
            
            string summary = ''
                + '<style media="all" type="text/css">'
                    + 'body { font-family: Verdana, Geneva, sans-serif; }'
                    + 'td { font-family: \'Lucida Console\', Monaco, monospace; font-size: 10pt; }'
                + '</style>'
                + '<p>' 
                    + '<h2>' + title + ' Batch Job Summary</h2>'
                    + '<h3>' + description + '</h3>' 
                    + '<p>'
                        + '<table>' 
                            + '<tr><td>Job Start Date and Time</td><td>: ' + j.CreatedDate.format(gs.DATETIME_FORMAT) + '</td></tr>'
                            + '<tr><td>Job End Date and Time</td><td>: ' + system.now().format(gs.DATETIME_FORMAT) + '</td></tr>'
                            + '<tr><td>Job Status</td><td>: ' + j.Status + '</td></tr>'
                            + '<tr><td>Job Executed User</td><td>: ' + Userinfo.getName() + ' (' + UserInfo.getUserName() + ')</td></tr>'
                            + '<tr><td>Total Number of Accounts Processed</td><td>: ' + j.JobItemsProcessed + '</td></tr>'
                            + '<tr><td>Total Number of Failure Records</td><td>: ' + j.NumberOfErrors + '</td></tr>'
                            + '<tr><td>Additional Information</td><td>: ' + msg + '</td></tr>'
                         + '</table>'
                    + '</p>'
                + '</p>'
            ; 
            
            mail.setHtmlBody(summary);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
            string mailList='';
            for(Integer i=0;i<toAddresses.size();i++) { mailList = mailList + ';' + toAddresses[i]; }
        } 
    } // end of send-message method
}