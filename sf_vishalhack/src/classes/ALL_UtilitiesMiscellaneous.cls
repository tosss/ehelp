// 2016-06-20 siva.pragada@cdk.com - created method logTheError
//2015-06-30 hemanth.kesapragada@cdk.com Added flag to enable/disable debugging
//2016-08-16 ragashalini.koka@cdk.com - RQ-07539 modified the Exception_Log__c custom setting to Apex_Code_Exception__c
global class ALL_UtilitiesMiscellaneous 
{
    global static Boolean showDebug;
    
    //createdby Matt.Keefe@cdk.com
    global static string GetCurrentInstanceName()
    {
        string InstanceName = UserInfo.getOrganizationId();
        
        string SystemHost = URL.getSalesforceBaseUrl().getHost();
        list<string> SystemHostParts = SystemHost.split( '\\.' );
        
        string SystemSubDomain = null; 
        if( SystemHostParts != null && !SystemHostParts.isEmpty() ) { 
            SystemSubDomain = SystemHostParts.get( 0 ); 
        }
        
        if( SystemSubDomain != null ) 
        {
            // check dash dash for sandbox with custom domain
            if( SystemSubDomain.contains( '--' ) && !SystemSubDomain.endsWith( '--' ) )
            {
                list<string> SubDomainParts = SystemSubDomain.split( '--' );
                InstanceName = SubDomainParts.get( SubDomainParts.size()-1 );
            }
            else
            {
                InstanceName = SystemSubDomain;
            }
        }
        
        return InstanceName;
    } 
    
    //Created by Hemanth.Kesapragada@cdk.com
    global static Boolean isProductionOrg()
    {
        if(String.valueOf(UserInfo.getOrganizationId()).substring(0,15)=='00D400000009Zyd')
        {
            return true;
        }
        return false;
    }
    
    //createdby Matt.Keefe@cdk.com
    global class Job
    {
        global string Status;
        global Integer NumberOfErrors;
        global Integer JobItemsProcessed;
        global Integer TotalJobItems;
        global string CreatedByEmail;
        global DateTime CreatedDate;
        
        global Job( AsyncApexJob j ) { if( j != null ) {
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
    
    //createdby Matt.Keefe@cdk.com
    global static void SendBatchCompleteMessage( Job j, string title, string description, string msg )
    {
        GlobalSettings gs = GlobalSettings.getInstance( null );
        system.debug( gs.ERROR_EMAIL );
        
        if( gs.ERROR_EMAIL != null && j != null ) 
        {
            system.debug( j );
            
            // Send an email to the Apex job's submitter notifying of job completion.  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            // string[] toAddresses = new string[] {a.CreatedBy.Email};
            string[] toAddresses = gs.ERROR_EMAIL;
            
            mail.setToAddresses( toAddresses );
            mail.setSubject( title + ' executed on: ' + j.CreatedDate.format( gs.DATETIME_FORMAT ) + ' Status:' + j.Status );
            
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
                + '<tr><td>Job Start Date and Time</td><td>: ' + j.CreatedDate.format( gs.DATETIME_FORMAT ) + '</td></tr>'
                + '<tr><td>Job End Date and Time</td><td>: ' + system.now().format( gs.DATETIME_FORMAT ) + '</td></tr>'
                + '<tr><td>Job Status</td><td>: ' + j.Status + '</td></tr>'
                + '<tr><td>Job Executed User</td><td>: ' + Userinfo.getName() + ' ( ' + UserInfo.getUserName() + ' )</td></tr>'
                + '<tr><td>Total Number of Accounts Processed</td><td>: ' + j.JobItemsProcessed + '</td></tr>'
                + '<tr><td>Total Number of Failure Records</td><td>: ' + j.NumberOfErrors + '</td></tr>'
                + '<tr><td>Additional Information</td><td>: ' + msg + '</td></tr>'
                + '</table>'
                + '</p>'
                + '</p>'
                ; 
            
            mail.setHtmlBody( summary );
            Messaging.sendEmail( new Messaging.SingleEmailMessage[] { mail } );
            
            string mailList='';
            for( Integer i=0;i<toAddresses.size();i++ ) { mailList = mailList + ';' + toAddresses[i]; }
        } 
    } // end of send-message method
    
    //createdby Matt.Keefe@cdk.com
    global static void PreventMultipleOnParent( 
        list<sObject> ChildObjects, 
        string ParentSObjectType, 
        string ParentIdField, 
        string ChildObjectRelationship, 
        string PageErrorMessage )
    {
        if( ChildObjects != null && !ChildObjects.IsEmpty() )
        {
            list<Id> ParentIds = new list<Id>();
            
            for( sObject s : ChildObjects ) { 
                if( s.get( ParentIdField ) != null ) { 
                    ParentIds.add( ( Id )s.get( ParentIdField ) ); 
                } 
            }
            
            string WhereInParentIds = ALL_UtilitiesString.ListToInclusiveCondition( 'Where', 'Id', ParentIds );
            
            string ParentQuery = ''
                + 'Select Id, ( Select Id From ' + ChildObjectRelationship + ' ) '
                + 'From ' + ParentSObjectType + ' '
                +  WhereInParentIds;
            
            map<Id, sObject> Parents = new map<Id, sObject>( ( list<sObject> )database.query( ParentQuery ) );
            
            if( Parents != null && !Parents.isEmpty() )
            {
                for( sObject CurrentChild : ChildObjects )
                {
                    Id ParentId = ( Id )CurrentChild.get( ParentIdField );
                    
                    if( ParentId != null ) 
                    {
                        sObject CurrentParent = Parents.get( ParentId ); 
                        list<sObject> ChildrenFromParent = CurrentParent.getSObjects( ChildObjectRelationship );
                        
                        if( ChildrenFromParent != null && !ChildrenFromParent.isEmpty() )
                        {
                            CurrentChild.addError( PageErrorMessage );
                        }
                    }
                } // end Current Child for loop
            }
        } // end if ChildObjects records
    }
    
    // 2015-06-30 hemanth.kesapragada@cdk.com Method to show debug flags if showDebug variable set to TRUE
    global static void debug(object objectRecord)
    {
        //flag to enable debugging
        Boolean customSetting = CustomSettings__c.getOrgDefaults().Show_Debug__c;
        if( showDebug && customSetting )
        {
            System.debug( '***** '+objectRecord );
        }
    }
    
    // 2016-06-20 siva.pragada@cdk.com - created method logTheError
    global static void insertExceptionObject(exception exceptionObject)
    { 
       //2016-08-16 ragashalini.koka@cdk.com - RQ-07539 - commented and added to modify Exception_Log__c to Apex_Code_Exception__c
        //list<Exception_Log__c> errorsToInsert = new list<Exception_Log__c>();
        list<Apex_Code_Exception__c> errorsToInsert = new list<Apex_Code_Exception__c>();
        string exceptionType = exceptionObject.getTypeName();
        integer randomInteger = crypto.getRandomInteger();
        string userName = userInfo.getUserName();
        String Name = userInfo.getName();
        ID userId = userInfo.getUserId();
        string userEmail = userInfo.getUserEmail();
        string userProfileID = userInfo.getProfileId();
        system.timeZone userTimeZone = userInfo.getTimeZone();
        boolean isTest = test.isRunningTest();
        boolean isTrigger = trigger.isExecuting == null ? false : trigger.isExecuting;
        boolean isInsert = trigger.isInsert == null ? false : trigger.isInsert;
        boolean isUpdate = trigger.isUpdate == null ? false : trigger.isUpdate;
        boolean isDelete = trigger.isDelete == null ? false : trigger.isDelete;
        boolean isBefore = trigger.isBefore == null ? false : trigger.isBefore;
        boolean isAfter = trigger.isAfter == null ? false : trigger.isAfter;
        
        string eLogName = string.valueOf(DateTime.now());
        
        Exception exp = exceptionObject.getCause();
        integer lineNumber = exceptionObject.getLineNumber();
        string message = exceptionObject.getMessage();
        //message = message.length() > 225 ? message.substring(0, 224) : message;
        string stackTrace = exceptionObject.getStackTraceString();
        //stackTrace = stackTrace.length() > 255 ? stackTrace.substring(0, 224) : stackTrace;
        
        system.debug(exceptionType);
        
        if(exceptionType == 'System.DmlException')
        {  
            integer numberOfDml = exceptionObject.getNumDml();
            
            for (Integer i = 0; i < numberOfDml; i++)
            {
                //2016-08-16 ragashalini.koka@cdk.com - RQ-07539 - commented and added to modify Exception_Log__c to Apex_Code_Exception__c
                //Exception_Log__c elog = new Exception_Log__c();
                Apex_Code_Exception__c elog = new Apex_Code_Exception__c();
                string[] dmlFields = exceptionObject.getDmlFieldNames(i);
                string dmlID = exceptionObject.getDmlId(i);
                ID recordID = (ID)dmlID;
                string sObjectType;
                
                if(recordID != null)
                {
                    sObjectType = recordID.getSobjectType().getDescribe().getName();
                }
                
                integer dmlIndex = exceptionObject.getDmlIndex(i);
                string dmlMessage = exceptionObject.getDmlMessage(i);
                //dmlMessage = dmlMessage.length() > 225 ? dmlMessage.substring(0, 224) : dmlMessage;
                string dmlStatusCode = exceptionObject.getDmlStatusCode(i);
                System.statusCOde statusCode = exceptionObject.getDmlType(i);
                
                elog.Name = eLogName + '-' + string.valueOf(ALL_UtilitiesRandom.RandomInteger(100, 999));
                elog.Dml_Fields__c = string.join(dmlFields, ',');
                elog.Dml_ID__c = dmlID;
                elog.Dml_Index__c = dmlIndex;
                elog.Dml_Message__c = dmlMessage;
                elog.Dml_Status_Code__c = dmlStatusCode;
                elog.Exception_Type__c = exceptionType;
                elog.Dml_Object_Type__c = sObjectType;
                elog.Time_of_Exception__c = DateTime.now();               
                elog.Line_Number__c = lineNumber;
                elog.Message__c = message;
                elog.Stack_Trace__c = stackTrace;
                
                //user info
                elog.User_Name__c = Name;
                elog.Profile_ID__c = userProfileID;
                elog.User_ID__c = userId;
                elog.User_Email__c = userEmail;
                elog.User_Timezone__c = string.valueOf(userTimeZone);
                
                
                //context info
                elog.isTest__c = isTest;
                elog.isTrigger__c = isTrigger;
                elog.isInsert__c = isInsert;
                elog.isUpdate__c = isUpdate;                
                elog.isDelete__c = isDelete;
                elog.isBefore__c = isBefore;
                elog.isAfter__c = isAfter;
                
                errorsToInsert.add(elog);
            } 
        }
        else
        {
            //2016-08-16 ragashalini.koka@cdk.com - RQ-07539 - commented and added to modify Exception_Log__c to Apex_Code_Exception__c
            //Exception_Log__c elog = new Exception_Log__c();
            Apex_Code_Exception__c elog = new Apex_Code_Exception__c();            
            elog.Name = eLogName + '-' + string.valueOf(ALL_UtilitiesRandom.RandomInteger(100, 999));
            //standard methods
            elog.Line_Number__c = lineNumber;
            elog.Message__c = message;
            elog.Stack_Trace__c = stackTrace;
            elog.Exception_Type__c = exceptionType;
            elog.Time_of_Exception__c = DateTime.now();
            
            //user info
            elog.User_Name__c = Name;
            elog.Profile_ID__c = userProfileID;
            elog.User_ID__c = userId;
            elog.User_Email__c = userEmail;
            elog.User_Timezone__c = string.valueOf(userTimeZone);
            
            //context info
            elog.isTest__c = isTest;
            elog.isTrigger__c = isTrigger;
            elog.isInsert__c = isInsert;            
            elog.isUpdate__c = isUpdate;
            elog.isDelete__c = isDelete;
            elog.isBefore__c = isBefore;
            elog.isAfter__c = isAfter;
            
            errorsToInsert.add(elog);
        }
        
        insert  errorsToInsert;
    }
    
    // 2016-07-01 - siva.pragada@cdk.com - created below method
    global static void logException(exception exceptionObject)
    {
        if(GlobalSettings__c.getInstance().Allow_Exception_Handling__c)
        {
            ALL_UtilitiesMiscellaneous.insertExceptionObject(exceptionObject);
        }
    }
    //2016-08-05 - siva.pragada@cdk.com - created below method
    global static void logDmlFailedRecords(list<Database.SaveResult> srList)
    {
        //2016-08-16 ragashalini.koka@cdk.com - RQ-07539 - commented and added to modify Exception_Log__c to Apex_Code_Exception__c
       // list<Exception_Log__c> errorsToInsert = new list<Exception_Log__c>();
        list<Apex_Code_Exception__c> errorsToInsert = new list<Apex_Code_Exception__c>();
        string userName = userInfo.getUserName();
        String Name = userInfo.getName();
        ID userId = userInfo.getUserId();
        string userEmail = userInfo.getUserEmail();
        string userProfileID = userInfo.getProfileId();
        system.timeZone userTimeZone = userInfo.getTimeZone();
        boolean isTest = test.isRunningTest();
        boolean isTrigger = trigger.isExecuting == null ? false : trigger.isExecuting;
        boolean isInsert = trigger.isInsert == null ? false : trigger.isInsert;
        boolean isUpdate = trigger.isUpdate == null ? false : trigger.isUpdate;
        boolean isDelete = trigger.isDelete == null ? false : trigger.isDelete;
        boolean isBefore = trigger.isBefore == null ? false : trigger.isBefore;
        boolean isAfter = trigger.isAfter == null ? false : trigger.isAfter;
        
        for(Database.SaveResult sr: srList)
        {
            if (!sr.isSuccess())        
            {
                for(Database.Error err : sr.getErrors())
                {
                    //string statusCode = (string)err.getStatusCode();
                    //statusCode = statusCode.length() > 255 ? statusCode.substring(0, 224) : statusCode;
                    string message = err.getMessage();
                    //message = message.length() > 255 ? message.substring(0, 224) : message;
                    string fields = string.join(err.getFields(), ',');
                    //fields = fields.length() > 255 ? fields.substring(0, 224) : fields;
                    //2016-08-16 ragashalini.koka@cdk.com - RQ-07539 - commented and added to modify Exception_Log__c to Apex_Code_Exception__c
                    //Exception_Log__c elog = new Exception_Log__c();
                    Apex_Code_Exception__c elog = new Apex_Code_Exception__c();
                    integer i = crypto.getRandomInteger();
                    elog.Name = 'DmlFail-' + string.valueOf(i);
                    elog.Message__c = message;
                    elog.Dml_Fields__c = fields;
                    elog.Dml_ID__c = sr.getID();
                    
                    //user info
                    elog.User_Name__c = Name;
                    elog.Profile_ID__c = userProfileID;
                    elog.User_ID__c = userId;
                    elog.User_Email__c = userEmail;
                    elog.User_Timezone__c = string.valueOf(userTimeZone);
                    
                    //context info
                    elog.isTest__c = isTest;
                    elog.isTrigger__c = isTrigger;
                    elog.isInsert__c = isInsert;
                    elog.isUpdate__c = isUpdate;                
                    elog.isDelete__c = isDelete;
                    elog.isBefore__c = isBefore;
                    elog.isAfter__c = isAfter;              
                    
                    errorsToInsert.add(elog);
                }
            }
        }
        
        if(!errorsToInsert.isEmpty())
        {
            insert errorsToInsert;
        }
    }
    
    //2016-08-18 - siva.pragada@cdk.com - created below method
    global static void logDmlFailedRecords(Database.SaveResult sr)
    {
        logDmlFailedRecords(new list<Database.SaveResult> { sr });
    }
}