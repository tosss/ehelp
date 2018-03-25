global class ALL_UtilitiesMiscellaneous 
{
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
}