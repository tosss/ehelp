// GLOBIT-6230 Auto create termination cases

// 2017-11-14 stephen.li@cdk.com Created
public class ISVC_ADTermCaseCreation_Batch implements Database.Batchable<sObject> {
    
    public ISVC_ADTermCaseCreation_Batch(){ }

    /**
     * Find all Account records where AD_Account_Expires__pc is less than
     * 10 days from today.
     */
    public Database.QueryLocator start(Database.BatchableContext BC){
        Date myDT = Date.today();
        String query = 'SELECT Id, AD_Account_Expires__pc, Manager__pc, LastName, FirstName, Name, User_Id__pc, User_Record__pc FROM Account WHERE AD_Account_Expires_Changed__pc = true AND Is_Contractor__pc = true AND AD_Account_Expires__pc >=: myDT';
        System.debug('Query: ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('We have ' + scope.size() + ' objects in scope');
        
        List<Account> accounts = new List<Account>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        for (Account a : (List<Account>) scope) {
        		Date maxDt = a.AD_Account_Expires__pc;
        		Date minDt = a.AD_Account_Expires__pc.addDays(-10);
        		Date todayValue = Date.today();
        		System.debug('Filtering: ' + a.Id + ', MaxDt = ' + maxDt + ', MinDt = ' + minDt + ', AD Account Expire = ' + a.AD_Account_Expires__pc + ', today = ' + todayValue);
        		if (maxDt >= todayValue && todayValue >= minDt) {
        			accounts.add(a);
        			accountMap.put(a.Id, a);
        		}
        }
        
        System.debug('We need to process ' + accounts.size() + ' accounts');
        
        List<Integration_Error__c> integrationErrors = new List<Integration_Error__c>();
        
        // Create termination cases
        List<Case> caseList = buildTerminationCases(accounts);

		// Saving temrination case
        integrationErrors.addAll(saveCase(caseList));
        
        // Submit termination cases for approval
        integrationErrors.addAll(submitForApproval(buildApprovalRequests(caseList, accountMap)));
        
        // Update account by setting the flag to false so they won't get picked up again in the future run
        List<Account> accountsToUpdate = new List<Account>();
        for (Case c : caseList) {
            if (c.Id != null) {
                accountsToUpdate.add(new Account(Id = c.accountId, AD_Account_Expires_Changed__pc = false));
            }
        }
        integrationErrors.addAll(updateAccount(accountsToUpdate));
        
        // Save any errors generated during the process
        insert integrationErrors;
    }
    
    private List<Case> buildTerminationCases(List<Account> accounts) {
    		//Fetching the assignment rules on case
		AssignmentRule AR = new AssignmentRule();
		AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
		
		//Creating the DMLOptions for "Assign using active assignment rules" checkbox
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
    	
        List<Case> caseList = new List<Case>();
        for (Account a: accounts) {
	        System.debug('Processing Account ' + a.id + ' with Expiration Date = ' + a.AD_Account_Expires__pc);
	        // Create a termination case
	        Case c = new Case(
	                recordTypeId = ALL_RecordTypes_Utility.getRequestRecordTypeId(),
	                ownerId = UserInfo.getUserId(),
	                accountId = a.Id,
	                contactId = a.Manager__pc,
	                origin = 'Web',
	                severity__c = 'Severity3',
	                impact__c = 'A Single Person',
	                Category__c = 'Access/Passwords',
	                Sub_Category__c = 'User/Exchange Account',
	                Subject = 'Contractor AD Account Expiration: ' + a.LastName + ', ' + a.FirstName,
	                Description = 'The AD account for ' + a.Name + ' (' + a.User_Id__pc + ') will expire on ' + a.AD_Account_Expires__pc.format() + '. Verification by manager is required to extend the account expiration date'
	        );
	        c.setOptions(dmlOpts);
	        caseList.add(c);
        }
        return caseList;
    }
    
    @TestVisible
    private List<Integration_Error__c> saveCase(List<SObject> objList) {
            List<Integration_Error__c> integrationErrors = new List<Integration_Error__c>();
            System.debug('------ Saving Case');
            Integer i = 0;
            for (Database.SaveResult sr : Database.insert(objList, false)) {
                if (sr.isSuccess()) {
                System.debug('New Case ID: ' + sr.getId());
                } else {
                    // Operation failed, so get all errors
                    String msg = 'The following error has occurred: ';             
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Case fields that affected this error: ' + err.getFields());
                    msg += err.getStatusCode() + ': ' + err.getMessage() + '; ' + 'Case fields that affected this error: ' + err.getFields();
                }
                integrationErrors.add(new Integration_Error__c(
                        Account__c = ((Case) objList.get(i)).accountId,
                        Error__c = msg
                    )
                 );
                }
                i++;
            }
            System.debug('----- End Saving');
            return integrationErrors;
    }
    
    @TestVisible
    private List<Integration_Error__c> updateAccount(List<SObject> objList) {
    		List<Integration_Error__c> integrationErrors = new List<Integration_Error__c>();
    		System.debug('------ Updating Account');
    		Integer i = 0;
        for (Database.SaveResult sr : Database.update(objList, false)) {
        		if (sr.isSuccess()) {
        			System.debug('Update Account ID: ' + sr.getId());
            } else {
                // Operation failed, so get all errors
                String msg = 'The following error has occurred: ';             
                for(Database.Error err : sr.getErrors()) {
                		System.debug('The following error has occurred.');                    
                		System.debug(err.getStatusCode() + ': ' + err.getMessage());
                		System.debug('Case fields that affected this error: ' + err.getFields());
                		msg += err.getStatusCode() + ': ' + err.getMessage() + '; ' + 'Case fields that affected this error: ' + err.getFields();
                	}
                	integrationErrors.add(new Integration_Error__c(Account__c = objList.get(i).Id, Error__c = msg));
			}
			i++;
		}
		System.debug('----- End Saving');
		return integrationErrors;
	}
    
    private List<Approval.ProcessSubmitRequest> buildApprovalRequests(List<Case> caseList, Map<Id, Account> accountMap) {
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
        for (Case c : caseList) {
            if (c.Id != null) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
	            req.setComments('Auto sumbit for approval');
	            req.setObjectId(c.Id);
	            req.setSubmitterId(accountMap.get(c.accountId).User_Record__pc);
	            requests.add(req);
            }
        }
        return requests;
    }
    
    private List<Integration_Error__c> submitForApproval(List<Approval.ProcessSubmitRequest> requests) {
        List<Integration_Error__c> integrationErrors = new List<Integration_Error__c>();
        for(Approval.ProcessResult sr : Approval.process(requests)) {
            if (sr.isSuccess()) {
                System.debug('Submitted for approval successfully. Case Id: ' + sr.getEntityId());
            } else {
                // Operation failed, so get all errors
                String msg = 'The following error has occurred: ';             
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Case fields that affected this error: ' + err.getFields());
                    msg += err.getStatusCode() + ': ' + err.getMessage() + '; ' + 'Case fields that affected this error: ' + err.getFields();
                }
                integrationErrors.add(new Integration_Error__c(Case__c =  sr.getEntityId(),Error__c = msg));
			}
		}
		return integrationErrors;
    }

    public void finish(Database.BatchableContext BC){ }
}