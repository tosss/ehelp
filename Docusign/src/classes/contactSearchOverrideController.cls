/*

Page designed to simply show list of existing contacts that match rough 
search criteria and to only show New Contact after they've searched

*/

public class contactSearchOverrideController {
	public String fName {get;set;}
	public String lName {get;set;}
	public String email {get;set;}
	public String acctId {get;set;}
	public Boolean renderNew {get;set;}
	public List<Contact> contactResultsList {get;set;}
	public Integer searchLimit {get;set;}
	
	public contactSearchOverrideController(ApexPages.StandardController stdController){
		renderNew = false;
		searchLimit = 10;
		
		Map<String,String> params = ApexPages.currentPage().getParameters();
		acctId = params.get('accid');
	}
	
	public PageReference newContact(){
		String url = '/003/e?nooverride=1&name_firstcon2='+EncodingUtil.urlEncode(fName,'UTF-8')+'&name_lastcon2='+EncodingUtil.urlEncode(lName,'UTF-8')+'&con15='+EncodingUtil.urlEncode(email,'UTF-8')+'&retURL=%2Fapex%2FcontactSearchOverride';
		if (acctId != null){
			url += '&accid='+acctId;
		}
		PageReference pageRef = new PageReference(url);
		return pageRef;
	}
	
	public PageReference searchExisting(){
		if(fName == '' && lName == '' && email == ''){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'At least one field must be completed.'));
			// remove stale results from last 'good' search
			if (contactResultsList != null){
				if (!contactResultsList.isEmpty()){
					contactResultsList.clear();
				}
			}
			renderNew = false;
		} else {
			
			// Build search string
			String searchString = '';
			if (fName.length() > 1 && fName != ''){
				searchString =+ searchString + ' ' + String.escapeSingleQuotes(fName) + '*';
			} else if (fName != ''){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Search terms must be longer than one character.'));
				renderNew = false;
				return null;
			}
			if (lName.length() > 1 && lName != ''){
				searchString =+ searchString + ' ' + String.escapeSingleQuotes(lName) + '*';
			} else if (lName != ''){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Search terms must be longer than one character.'));
				renderNew = false;
				return null;
			}
			if (email.length() > 1 && email != ''){
				searchString =+ searchString + ' ' + String.escapeSingleQuotes(email);  // Not adding asterisk, email must be exact.
			} else if (email != ''){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Search terms must be longer than one character.'));
				renderNew = false;
				return null;
			}
			
			// build dynamic SOSL statement
			String dSOSL = 'FIND \'' + searchString + '\' IN ALL FIELDS RETURNING Contact(Id) LIMIT '+searchLimit;
			
			// Execute Dynamic SOSL to check for any results
			system.debug('Dynamic SOSL Statement:    '+dSOSL);
			List<List<SObject>> contactResults = search.query(dSOSL);
			
			system.debug('Contact Results:      --- '+contactResults[0].isEmpty());
			// Check to see if SOSL returned anything at all - 
			if (!contactResults[0].isEmpty()){
				List<Id> contactIds = new List<Id>();
				for (SObject ss : contactResults[0]){
					contactIds.add(ss.Id);
				}
				
				// Have to use SOQL to get additional fields beside Id, yes - tried adding Id, Name, etc to SOSL.  (TODO)
				contactResultsList = [SELECT Id, FirstName, LastName, Email, Account.Name, AccountId FROM Contact WHERE Id IN :contactIds];
				renderNew = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO, 'Found existing contacts... please select existing, or click \'New Contact\' if contact is new.'));
			} else {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'No matching contacts found, please select \'New Contact\''));
				
				// remove stale results from last 'good' search
				if (contactResultsList != null){
					if (!contactResultsList.isEmpty()){
						contactResultsList.clear();
					}
				}
				renderNew = true;
			}
		}
		return null;
	}
}