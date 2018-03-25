/* 
*  This is called in SyncAccountNWebIDScheduler to sync Account & WebID
*   - To copy Account Executive (Account Owner) name from Account Object into WebID Object.
*   - Concatenate all WebID Object Account Advocates into Account Object Account Advocate.
*   - Concatenate all WebID Object SEO Specialist into Account Object SEO Specialist.
*   - A batch process to run once in a day to synchronize Account & WebID Objects such as map 
*  Account.Account Execute into WebID.Account Execute, update & concatenate WebID Account Advocate, 
*  SEO Specialist into Account WebID Account Advocate, WebID SEO specialist.
*/

global class SyncAccountNWebIDJob implements Database.Batchable<Sobject>, Database.Stateful
{
	private static final GlobalSettings gs = GlobalSettings.getInstance(null);
	public Batch_Jobs_Audit_Log__c jobLog;
	private String query;
	private String errorString;
	private List<String> accountList;
	
	private static final String QUERY_STRING = 
		'Select Id, OwnerId, Designated_DSM__c ' +
			//', (select Id, Account_Executive__c FROM Sites__r) ' + // removed 2012-03-02 MK - this subquery was causing an error in the batch process
		'FROM Account ';
	
	public static Integer LIMITCOUNT = 0;
	
	global SyncAccountNWebIDJob()
	{
		this.accountList = null;
		this.query = null;
		setjob();
	}
	
	global SyncAccountNWebIDJob(String q, List<String> aList)
	{
		this.query = q;
		this.accountList = aList;
		setjob();
	}
	
	private void setjob()
	{
		this.query = (this.query==null) ? QUERY_STRING : this.query;
		
		if(this.accountList!=null)
		{
			String aSet = GlobalSettings.convertListToString(accountList);
			String whereString = ' WHERE Account_Number__c IN ' + aSet ;
			this.query = (this.accountList==null) ? this.query : (this.query + whereString);
		}
		
		this.query = (LIMITCOUNT > 0 && this.accountList == null) ? (this.query + ' LIMIT ' + LIMITCOUNT) : this.query;
		
		system.debug('setJob Query........++++++++++++++++++'+this.query);
		
		//set the Audit log data
		jobLog = new Batch_Jobs_Audit_Log__c();
		jobLog.Name = 'SyncAccountNWebIDJob';
		jobLog.Job_Start_Date__c = system.now();
		jobLog.Job_Executed_User__c = Userinfo.getName();
		jobLog.Job_Status__c = 'Started';
		jobLog.Total_Number_of_Failure_Records__c = 0;
		jobLog.Total_Number_of_Success_Records__c = 0;
		jobLog.Total_Number_Of_Records_processed__c = 0;
		errorString = '';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		try
		{
			jobLog.Job_ID__c = BC.getJobId();
			insert jobLog;
			return Database.getQueryLocator(this.query);
		}
		catch (Exception e)
		{
			sendMessage(BC, e.getMessage());
			return null;
		}
	}
	global void execute(Database.BatchableContext BC, List<SObject> mms)
	{
		System.debug('SyncAccountNWebID -execute-start');
		
		try
		{
			if(mms != null) {
				jobLog.Total_Number_Of_Records_processed__c += mms.size(); }
			
			List<WebID__c> updateList = new List<WebID__c>();
			// List<Account> updateAccList = new List<Account>();
			
			// 2012-03-02 MK - Added to compensate for the removal of subquery
			List<WebID__c> AllWebIds = [Select Id, Account_Executive__c, Account__c From WebId__c Where Account__c IN :mms];
			Map<Id, List<WebID__c>> WebIdsByAccount = new Map<Id, List<WebID__c>>(); 
			
			for(WebID__c w : AllWebIds)
			{
				if(WebIdsByAccount.get(w.Account__c) == null) 
				{
					List<WebID__c> NewWebIdList = new List<WebID__c>(); NewWebIdList.add(w);
					WebIdsByAccount.put(w.Account__c,NewWebIdList); 
				}
				else
				{
					WebIdsByAccount.get(w.Account__c).add(w);
				}
			}
			// end of added code
			
			for(Account acc : (List<Account>)mms)
			{
				// String accountAdvocate='  ';
				// String SEOSpecialist='  ';
				
				//Get all related WebIds and update Account Executive
				List<WebID__c> webList = WebIdsByAccount.get(acc.Id); // acc.Sites__r; // 2012-03-02 MK - changed
				
				if(webList != null)
				{
					for(WebID__c c : webList)
					{
						if(c.Account_Executive__c != acc.Designated_DSM__c)
						{
							c.Account_Executive__c = acc.Designated_DSM__c;
							updateList.add(c);
						}
					} // end of internal for
				}
			} // end of extrenal for
			
			if(!(updateList.isEmpty()))
			{
				Database.SaveResult[] lsr = Database.update(updateList,false);
				Integer counter = 0;
				
				for(Database.SaveResult sr : lsr)
				{
					if(!sr.isSuccess())
					{
						jobLog.Total_Number_of_Failure_Records__c += 1;
						Database.Error err = sr.getErrors()[0];
						errorString += updateList.get(counter) + ': ' + 'Error ' + err + '\n;';
					}
					else
					{
						jobLog.Total_Number_of_Success_Records__c += 1;
					}
					
					counter++;
				}
			}
			
			System.debug('SyncAccountNWebID -execute-stop');
		}
		catch (Exception e)
		{
			System.debug(logginglevel.ERROR,'SyncAccountNWebIDJob -execute-exception++++++++++++++++++++++');
			sendMessage(BC,e.getMessage());
		}
	} // end of execute method
	
	global void finish(Database.BatchableContext BC)
	{
		sendMessage(BC,'Success');
	}
	
	global void sendMessage(Database.BatchableContext BC,String msg)
	{
		if (msg != null && gs.ERROR_EMAIL != null)
		{
			system.debug(logginglevel.INFO,'gs.ERROR_EMAIL ++++++++++++++++++++++' + gs.ERROR_EMAIL);
			
			AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :BC.getJobId()];
			
			// Send an email to the Apex job's submitter notifying of job completion.
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			
			//String[] toAddresses = new String[] {a.CreatedBy.Email};
			String[] toAddresses = gs.ERROR_EMAIL;

			mail.setToAddresses(toAddresses);
			mail.setSubject('Account to WebID sync Batch executed on: ' + jobLog.Job_Start_Date__c.format(gs.DATETIME_FORMAT) + ' Status: ' +a.Status);
			
			if(errorString.length() > 1)
			{
				msg = errorString;
				jobLog.Job_Failure_Reason__c = errorString;
			}
			
			String summary = ''
				+ '<style media="all" type="text/css">'
					+ 'body { font-family: Verdana, Geneva, sans-serif; }'
					+ 'td { font-family: \'Lucida Console\', Monaco, monospace; font-size: 10pt; }'
				+ '</style>'
				+ '<p>' 
					+ '<h2>Account to WebID Synchronization Batch Job Summary </h2>'
					+ '<h3>Replacing WebID Account Executive with Account Designated DSM (Account Executive)</h3>' 
					+ '<p>'
						+ '<table>' 
							+ '<tr><td>Job Start Date and Time</td><td>: ' + jobLog.Job_Start_Date__c.format(gs.DATETIME_FORMAT) + '</td></tr>'
							+ '<tr><td>Job End Date and Time</td><td>: ' + system.now().format(gs.DATETIME_FORMAT) + '</td></tr>'
							+ '<tr><td>Job Status</td><td>: ' + a.Status + '</td></tr>'
							+ '<tr><td>Job Executed User</td><td>: ' + Userinfo.getName() + ' (' + UserInfo.getUserName() + ')</td></tr>'
							+ '<tr><td>Total Number of Accounts Processed</td><td>: ' + jobLog.Total_Number_Of_Records_processed__c + '</td></tr>'
							+ '<tr><td>Total Number of WebIDs updated</td><td>: ' + jobLog.Total_Number_of_Success_Records__c + '</td></tr>'
							+ '<tr><td>Total Number of Failure Records</td><td>: ' + jobLog.Total_Number_of_Failure_Records__c + '</td></tr>'
							+ '<tr><td>No of Job Failures</td><td>: ' + a.NumberOfErrors + '</td></tr>'
							+ '<tr><td>Job Input Parameters</td><td>: ' + jobLog.Job_Input_Parameters__c + '</td></tr>'
							+ '<tr><td>Overall Status</td><td>: ' + msg + '</td></tr>'
						 + '</table>'
					+ '</p>'
				+ '</p>'
		 	;
			
			mail.setHtmlBody(summary); 
			// mail.setPlainTextBody('The batch Apex job monthlyMaintenanceRecharge processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
			
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			
			//Audit Log
			jobLog.Job_Status__c = a.Status;
			jobLog.Job_ID__c = BC.getJobId();
			jobLog.Job_End_Date__c = System.now();
			jobLog.Job_Summary__c = summary;
			String mailList = '';
			
			for(Integer i=0; i < toAddresses.size(); i++) {
				mailList = mailList + ';' + toAddresses[i]; }
			
			jobLog.Job_Status_Email_Send_To__c = mailList;
			
			upsert jobLog Job_ID__c;
		}
	} // end of method

} // end of class