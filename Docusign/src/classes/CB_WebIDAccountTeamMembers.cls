public class CB_WebIDAccountTeamMembers
{
    // -- subclasses
    
    public class FieldSettings {
        // full field definition
        private List<Account_Team_Sync_Settings__c> ListOfFields = new List<Account_Team_Sync_Settings__c>();
        public List<Account_Team_Sync_Settings__c> getListOfFields() { return ListOfFields; }
        
        // Field API Name indexes the Labels (Name) of each field
        private Map<String, String> Fields = new Map<String, String>();
        public Map<String, String> getFields() { return Fields; }
        
        public FieldSettings(String sObjectName) {
            // get the custom settings to determine the fields to process
            for(Account_Team_Sync_Settings__c s : Account_Team_Sync_Settings__c.getall().values()) {
                if(s.sObject__c == sObjectName) { ListOfFields.add(s); Fields.put(s.User_ID_Field_API_Name__c, s.Team_Role__c); } }
        }
    }
    
    // -- variables
    
    // Settings
    public FieldSettings Settings;
    public String sObjectName;
    
    // -- constructors
    
    public CB_WebIDAccountTeamMembers() { Initialize('WebID__c'); } // default to WebID
    public CB_WebIDAccountTeamMembers(String sn) { Initialize(sn); }
    
    // -- methods
    
    public void Initialize(String SalesforceObjectName) // sObject Name (Account or WebID__c)
    {
        // initialize settings and containers
        Settings = new FieldSettings(SalesforceObjectName);
        sObjectName = SalesforceObjectName;
    }
    
    public String BuildQuery(List<String> AllAccountIds, Set<String> Fields)
    {
        String AccountIds = ALL_UtilitiesString.ListToParenthesesCsv(AllAccountIds);
        
        // build the Query String with Conditions (limiting Accounts by supplied Ids)
        String q = BuildQueryWithoutConditions(Fields) + 'WHERE Id IN ' + AccountIds;
        
        system.debug(q);
        return q;
    }
    
    public String AddFieldsToQuery(Set<String> Fields)
    {
    	String q = '';
    	
		// loop through the fields and add them to the query
        for(String field : Fields) 
        {
            q += ',' + field; // add the field
            
            // build the relationship name for the field (to get the IsActive status of the referenced User)
            String fieldc = field; String fieldr = '';
            try { fieldr = fieldc.substring(0, fieldc.length()-1) + 'r'; } catch(Exception ex) { }
            
            // add the relationship name and IsActive field
            if(fieldr != '') { q += ',' + fieldr + '.IsActive '; }
        }
        
        return q;
    }
    
    public String BuildQueryWithoutConditions(Set<String> Fields) 
    {
    	//String TeamRoles = ALL_UtilitiesString.ListToParenthesesCsv(Settings.getFields().values());
    	
        // build the Account query string
        String q = '';
            q += 'SELECT Id, Name, ';
            	
                q += '(SELECT Id, Team_Member__c, Team_Member__r.IsActive, Team_Role__c ' 
                    + 'FROM AccountTeamAccounts__r ' // AccountTeamAccounts__r is the relationship for Account Team Members
                    //+ 'WHERE Team_Role__c IN ' + TeamRoles 
                    + '), ';
                q += '(SELECT Id, Name, Account__c, Status__c ';
                
                if(sObjectName.toLowerCase() == 'webid__c') {
	                q += AddFieldsToQuery(Fields); }
                
                q += ' ' + 'FROM Sites__r) '; // Sites__r is the relationship for WebIDs
                
                if(sObjectName.toLowerCase() == 'account') {
					q += AddFieldsToQuery(Fields); }
                
            q += 'FROM Account '
        + '';
        
        system.debug(q);
        return q;
    }
    
    public Set<Id> GatherAccountIdsFromWebIds(List<WebID__c> WebIDs)
    {
        Set<Id> AllAccountIds = new Set<Id>();
        
        for(WebID__c w : WebIDs) { 
            if(w.Account__c != null) { AllAccountIds.add(w.Account__c); } }
        
        return AllAccountIds;
    }
    
    // Account Team User Ids (and Roles) by Account Ids
    public Map<Id, Map<Id, Account_Team__c>> GatherAccountTeamUserIdsByAccountId(List<Account> Accounts)
    {
        Map<Id, Map<Id, Account_Team__c>> AccountTeamMemberIdsByAccountId = new Map<Id, Map<Id, Account_Team__c>>();
        
        for(Account a : Accounts) 
        {
            Map<Id, Account_Team__c> AccountTeamMemberIdsWithRoles = new Map<Id, Account_Team__c>();
            
            List<Account_Team__c> AccountTeamMembers = a.getSObjects('AccountTeamAccounts__r');
            
            if(AccountTeamMembers != null) {
                for(Account_Team__c atm : AccountTeamMembers) {
                    if(atm.Team_Member__c != null) { 
                        AccountTeamMemberIdsWithRoles.put(atm.Team_Member__c, atm); 
                    }
                }
            }
            
            AccountTeamMemberIdsByAccountId.put(a.Id, AccountTeamMemberIdsWithRoles);
        }
        
        return AccountTeamMemberIdsByAccountId;
    }
    
    // sObject User Ids (and Roles) by Account Ids
    public Map<Id, Map<Id, Account_Team__c>> GatherUsersByAccountId(List<Account> Accounts, Map<String, String> Fields) 
    {
        Map<Id, Map<Id, Account_Team__c>> UserIdsByAccountId = new Map<Id, Map<Id, Account_Team__c>>();
        
        for(Account a : Accounts) 
        {
        	List<sObject> sObjects = new List<sObject>(); 
        	
        	if(sObjectName.toLowerCase() == 'webid__c') {
        		sObjects = a.getSObjects('Sites__r'); }
    		
    		if(sObjectName.toLowerCase() == 'account') {
    			sObjects = new List<sObject> {a}; }
            
            Map<Id, Account_Team__c> UserIdsWithRoles = GatherUserIdsWithRolesFromSObjects(sObjects, Fields);
            
	        UserIdsByAccountId.put(a.Id, UserIdsWithRoles);
        }
        
        return UserIdsByAccountId;
    }
    
    public Map<Id, Account_Team__c> GatherUserIdsWithRolesFromSObjects(List<sObject> sObjects, Map<String, String> FieldsByApiName)
    {
		Map<Id, Account_Team__c> UserIdsWithRoles = new  Map<Id, Account_Team__c>();
        
        if(sObjects != null)
        {
            for(sObject s : sObjects)
            {
                for(String FieldApiName : FieldsByApiName.keySet())
                {
                	String fieldc = FieldApiName; String fieldr = '';
                	if(FieldApiName.endsWith('__c')) {
                		try { fieldr = fieldc.substring(0, fieldc.length()-1) + 'r'; } catch(Exception ex) { } }
                	
                	User u = new User();
                	if(fieldr != '') { u = (User) ALL_UtilitiesData.GetDataFromNestedFields(fieldr, s); }
                	
                	if(u != null && u.IsActive)
                	{
	                	Account_Team__c atm = new Account_Team__c();
	                	atm.Team_Role__c = FieldsByApiName.get(FieldApiName); 
	                	atm.put('Team_Member__c', u.Id);
	                	atm.putSObject('Team_Member__r', u);
	                	
	                    Id UserId = (Id) ALL_UtilitiesData.GetDataFromNestedFields(FieldApiName, s);
	                    if(UserId != null) { UserIdsWithRoles.put(UserId, atm); }
                	}
                }
            }
        }
        
        return UserIdsWithRoles;
    }
    
    // to be collected by account
    public class ComparedUsers
    {
        // User Id (unique by User Id) and Account Team Member
        Map<Id, Account_Team__c> UserIdsToAddToAccountTeam;
        Map<Id, Account_Team__c> UserIdsToRemoveFromAccountTeam;
        
        public ComparedUsers() {
            UserIdsToAddToAccountTeam = new Map<Id, Account_Team__c>();
            UserIdsToRemoveFromAccountTeam = new Map<Id, Account_Team__c>();
        }
    }
    
    // to be looped through by account
    public ComparedUsers CompareUserSets(Id AccountId, Map<String, String> Fields, 
    	Map<Id, Account_Team__c> AccountTeamUsers, Map<Id, Account_Team__c> FieldUsers)
    {
        ComparedUsers cu = new ComparedUsers();
        
        // check Account Team Members for WebID Users
        //   if not on Account Team, add to add list
        for(Id UserId : FieldUsers.keySet()) 
        {
            if(!AccountTeamUsers.keySet().contains(UserId)) 
            {
                Account_Team__c AccountTeamMember = FieldUsers.get(UserId);
                
                cu.UserIdsToAddToAccountTeam.put(UserId, 
                    new Account_Team__c(
                        Account__c = AccountId,
                        Team_Member__c = UserId,
                        Team_Role__c = AccountTeamMember != null ? AccountTeamMember.Team_Role__c : null, 
                        Account_Access__c = 'Read/Write', 
						Opportunity_Access__c = 'Read Only', 
						Case_Access__c = 'Read/Write'
                    )
                ); 
            }
        }
        
        // check WebID Users for Account Team Members
        //   if not on any WebID, add to remove list
        for(Id AccountTeamUserId : AccountTeamUsers.keySet()) 
        {
            if(!FieldUsers.keySet().contains(AccountTeamUserId)) 
            {
            	// get the current Account Team Member and their Team Role
            	Account_Team__c atm = AccountTeamUsers.get(AccountTeamUserId);
            	String atmTeamRole = atm != null ? atm.Team_Role__c : null;
            	
                // since all Account Team Members are included, only remove if the Team Role is in the Field Settings
                Set<String> FieldTeamRoles = new Set<String>(); FieldTeamRoles.addAll(Fields.values());
                
                if(FieldTeamRoles.contains(atmTeamRole)) 
                {
	                cu.UserIdsToRemoveFromAccountTeam.put(AccountTeamUserId, 
	                    (Account_Team__c) AccountTeamUsers.get(AccountTeamUserId) 
	                ); 
                }
            }
        }
        
        return cu;
    }
    
    public void SyncAccountTeamAndWebIdUsers(List<Id> AccountIdsToProcess)
    {
    	// sets for uniqueness
        Set<Account_Team__c> AccountTeamMembersToInsertSet = new Set<Account_Team__c>(); 
        Set<Account_Team__c> AccountTeamMembersToDeleteSet = new Set<Account_Team__c>();
        
        // lists to perform DML (inserts/deletes)
        List<Account_Team__c> AccountTeamMembersToInsert = new List<Account_Team__c>(); 
        List<Account_Team__c> AccountTeamMembersToDelete = new List<Account_Team__c>();
        
        // query the records (complete with WebID and Account Team subqueries)
        String q = BuildQuery(AccountIdsToProcess, Settings.Fields.keySet());
        List<Account> AccountsToProcess = Database.query(q);
        
        // remove field values if WebID is inactive, and store the WebIDs to update for updating after inserts/deletes
        List<WebID__c> WebIDsToUpdate = new List<WebID__c>();
        if(sObjectName.toLowerCase() == 'webid__c') { WebIDsToUpdate = RemoveAllFieldValuesFromInactiveWebIDs(AccountsToProcess); }
        
        // gather data
        Map<Id, Map<Id, Account_Team__c>> AccountTeamMemberIdsByAccountId = GatherAccountTeamUserIdsByAccountId(AccountsToProcess);
        Map<Id, Map<Id, Account_Team__c>> WebIdUserIdsByAccountId = GatherUsersByAccountId(AccountsToProcess, Settings.getFields());
        
        for(Id AccountId : AccountIdsToProcess)
        {
        	// compare which Users are on the Account Team
            ComparedUsers cu = CompareUserSets(
                AccountId,
                Settings.getFields(),
                AccountTeamMemberIdsByAccountId.get(AccountId), 
                WebIdUserIdsByAccountId.get(AccountId)
            );
            
            system.debug(cu);
            
            // compile a list for all Accounts
            for(Account_Team__c atm : cu.UserIdsToAddToAccountTeam.values()) { AccountTeamMembersToInsertSet.add(atm); }
            for(Account_Team__c atm : cu.UserIdsToRemoveFromAccountTeam.values()) { AccountTeamMembersToDeleteSet.add(atm); }
        }
        
        AccountTeamMembersToInsert.addAll(AccountTeamMembersToInsertSet);
        AccountTeamMembersToDelete.addAll(AccountTeamMembersToDeleteSet);
        
        system.debug(AccountTeamMembersToInsert);
        if(!AccountTeamMembersToInsert.IsEmpty()) { insert AccountTeamMembersToInsert; }
        
        system.debug(AccountTeamMembersToDelete);
        if(!AccountTeamMembersToDelete.IsEmpty()) { delete AccountTeamMembersToDelete; }
        
        system.debug(WebIDsToUpdate);
        if(!WebIDsToUpdate.IsEmpty()) { update WebIDsToUpdate; }
    }
    
    public List<WebID__c> RemoveAllFieldValuesFromInactiveWebIDs(List<Account> Accounts)
    {
    	List<WebID__c> WebIDsToUpdate = new List<WebID__c>();
    	
    	for(Account a : Accounts)
        {
            List<WebID__c> WebIds = a.getSObjects('Sites__r');
            
            if(WebIds != null)
            {
                // for each WebID
		    	for(WebID__c w : WebIds)
		        {
		        	// if WebID is inacitve
		        	if(w.Status__c == 'Inactive')
		        	{
			        	// remove values from all WebID fields
			            Boolean FieldsUpdated = false;
			            for(String field : Settings.getFields().keyset()) { 
			            	if(ALL_UtilitiesData.GetDataFromNestedFields(field, w) != null) { 
			            		ALL_UtilitiesData.PutDataInNestedFields(field, w, null); FieldsUpdated = true; } 
		            	}
		            	
		            	if(FieldsUpdated == true) { WebIDsToUpdate.add(w); }
		        	}
		        } // end for
            } // end if WebIDs != null
        }
    	
    	return WebIDsToUpdate;
    }
    
    // -- Trigger methods
    
    public WebID__c ProcessIfBatchSizeIsOne(Integer NumberOfWebIDs, WebID__c CurrentWebID)
    {
        if(NumberOfWebIDs > 1 
        && !UserInfo.getUserName().toLowerCase().startsWith('integration_user@adp.com')
        && !UserInfo.getUserName().toLowerCase().startsWith('castiron.integration@adp.com')) 
        {
            CurrentWebID.addError('Only one WebID may be inserted or updated at a time. '
                + 'Please ensure the batch size is set to 1.'); 
            return null;
        }
        else { return CurrentWebID; }
    }
    
    // trigger setup - returning Accounts to process list
    public Set<Id> FilterWebIDsToProcessFromWebIdTrigger(Map<Id, WebID__c> oldMap, Map<Id, WebID__c> newMap)
    {
        Map<Id, WebID__c> WebIdsToProcess = new Map<Id, WebID__c>(); 
        Set<Id> AccountIdsToProcess = new Set<Id>();
        
        // because newMap is null in delete operations
        //   swap newMap and oldMap to process records for the after delete operation
        if(newMap == null) { newMap = oldMap; oldMap = null; }
        
        // only process if specific fields have changed
        for(WebID__c w : newMap.values())
        {
            WebID__c old = oldMap != null ? oldMap.get(w.Id) : null;
            if(old == null) { old = new WebID__c(); }
            
            // compile lists and delete previous Account Team Members that will be replaced
            for(String field : Settings.getFields().keyset())
            {
                Id oldFieldValue = (Id) ALL_UtilitiesData.GetDataFromNestedFields(field, old); //old.get(field); 
                Id newFieldValue = (Id) ALL_UtilitiesData.GetDataFromNestedFields(field, w); //w.get(field);
                
                if(oldFieldValue != newFieldValue) { 
                    WebID__c WebIdToAdd = ProcessIfBatchSizeIsOne(newMap.size(), w); 
                    //if(WebIdToAdd != null) { WebIdsToProcess.put(WebIdToAdd.Id, WebIdToAdd); }
                    if(WebIdToAdd != null) { AccountIdsToProcess.add(WebIdToAdd.Account__c); } 
                }
            }
            
            // 2012-11-27 MK - added condition for update (update is checked by checking oldMap)
            // because inserts from CastIron were failing
            if(oldMap != null && !oldMap.IsEmpty()) 
            {
            	Boolean StatusInactive = (w.Status__c == 'Inactive' || old.Status__c == 'Inactive');
            	Boolean StatusChanged = (w.Status__c != old.Status__c);
            	
                // if the WebID Account has changed, process old Accounts
                if((w.Account__c != old.Account__c) || (StatusInactive && StatusChanged)) 
                {
                	// check for valid conditions
                    WebID__c NewWebIdToAdd = ProcessIfBatchSizeIsOne(newMap.size(), w); 
                    
                    if(NewWebIdToAdd != null) // if the WebID is valid
                    {
                    	if(w.Account__c != null) { AccountIdsToProcess.add(w.Account__c); }
                    	if(old.Account__c != null) { AccountIdsToProcess.add(old.Account__c); }
                    } 
                }
            }
        }
        
        return AccountIdsToProcess;
    }
    
    // trigger setup - returning Accounts to process list
    public Set<Id> FilterWebIDsToProcessFromAccountTrigger(Map<Id, Account> oldMap, Map<Id, Account> newMap)
    {
        Map<Id, Account> AccountsToProcess = new Map<Id, Account>(); 
        Set<Id> AccountIdsToProcess = new Set<Id>();
        
        // only process if specific fields have changed
        if(newMap != null)
        {
	        for(Account a : newMap.values())
	        {
	            Account old = oldMap != null ? oldMap.get(a.Id) : null;
	            if(old == null) { old = new Account(); }
	            
	            // compile lists and delete previous Account Team Members that will be replaced
	            for(String field : Settings.getFields().keyset())
	            {
	                Id oldFieldValue = (Id) ALL_UtilitiesData.GetDataFromNestedFields(field, old); //old.get(field); 
	                Id newFieldValue = (Id) ALL_UtilitiesData.GetDataFromNestedFields(field, a); //a.get(field);
	                
	                if(oldFieldValue != newFieldValue) { 
	                    //if(WebIdToAdd != null) { WebIdsToProcess.put(WebIdToAdd.Id, WebIdToAdd); }
	                    if(a != null) { AccountIdsToProcess.add(a.Id); } 
	                }
	            }
	        }
        }
        
        return AccountIdsToProcess;
    }
}