//2016-02-12- anirudh.singh@cdk.com- Modified this class for Request RQ-06027 Trigger on WebIDs update to follow standards.
//2016-02-12- anirudh.singh@cdk.com- Corrected the indetation, variable names to follow standards.
public class CB_WebID_Handler
{
    private static FieldSettings settings;
    private static String sObjectName;
    
    public static void initializeAndProcessRecords(String objectAPIName, Map<Id, sObject> oldMap, Map<Id, sObject> newMap)
    {
        system.debug('Start initializeAndProcessRecords---->');
        
        initializeVariables(objectAPIName);
        
        if(oldMap!=Null || newMap!=Null)
        {
            processWebIdsAndSyncAccountTeam(objectAPIName, oldMap, newMap);
        }
        
        system.debug('End initializeAndProcessRecords---->');
    }
    
    //sObject Name(Account or WebID__c).
    private static void initializeVariables(String objectAPIName)
    {
        system.debug('Start initializeVariables---->');
        
        if(objectAPIName==Null || objectAPIName=='')
        {
            objectAPIName='WebID__c';
        }
        //Initialize settings and containers.
        settings=new FieldSettings(objectAPIName);
        sObjectName=objectAPIName;
        
        system.debug('End initializeVariables---->');
    }
    
    private static void processWebIdsAndSyncAccountTeam(String objectAPIName, Map<Id, sObject> oldMap, Map<Id, sObject> newMap)
    {
        system.debug('Start processWebIdsAndSyncAccountTeam---->');
        
        //Filter WebIDs based on whether or not any of the fields have (or the Account has) changed.
        Set<Id> accountIds;
        
        //2016-02-19- anirudh.singh@cdk.com- Added the below IF and ELSE IF Blocks.
        if(objectAPIName=='WebID__c')
        {
            Map<Id, WebID__c> webIdOldMap=oldMap!=Null ? (Map<Id, WebID__c>)oldMap : Null;
            
            Map<Id, WebID__c> webIdNewMap=newMap!=Null ? (Map<Id, WebID__c>)newMap : Null;
            
            accountIds=filterWebIDsFromWebIdTrigger(webIdOldMap, webIdNewMap);
        }
        else if(objectAPIName=='Account')
        {
            Map<Id, Account> accountOldMap=oldMap!=Null ? (Map<Id, Account>)oldMap : Null;
            
            Map<Id, Account> accountNewMap=newMap!=Null ? (Map<Id, Account>)newMap : Null;
            
            accountIds=filterWebIDsFromAccountTrigger(accountOldMap, accountNewMap);
        }
        
        //Sync the WebID fields and the Account Team Members.
        if(accountIds!=Null && !accountIds.IsEmpty())
        {
            syncAccountTeamAndWebIdUsers(new List<Id>(accountIds));
        }
        
        system.debug('End processWebIdsAndSyncAccountTeam---->');
    }
    
    //This method is invoked for WebID Trigger Scenario.
    private static Set<Id> filterWebIDsFromWebIdTrigger(Map<Id, WebID__c> webIdOldMap, Map<Id, WebID__c> webIdNewMap)
    {
        system.debug('Start filterWebIDsFromWebIdTrigger---->');
        
        //2016-02-11- anirudh.singh@cdk.com- Commented the below line as it was not being used anywhere.
        //Map<Id, WebID__c> webIdsToProcess=new Map<Id, WebID__c>(); 
        Set<Id> accountIds=new Set<Id>();
        
        //newMap is Null in delete operations, so swap newMap and oldMap to process records for the after delete operation.
        if(webIdNewMap==Null)
        {
            webIdNewMap=webIdOldMap;
            webIdOldMap=Null;
        }
        
        //Only process if specific fields have changed.
        for(WebID__c webIdRef: webIdNewMap.values())
        {
            WebID__c old=webIdOldMap!=Null ? webIdOldMap.get(webIdRef.Id): Null;
            
            if(old==Null)
            {
                old=new WebID__c();
            }
            
            // compile lists and delete previous Account Team Members that will be replaced
            for(String field: settings.getFieldAndTeamRoleMap().keyset())
            {
                //old.get(field); 
                Id oldFieldValue=(Id)ALL_UtilitiesData.GetDataFromNestedFields(field, old);
                
                //w.get(field);
                Id newFieldValue=(Id)ALL_UtilitiesData.GetDataFromNestedFields(field, webIdRef);
                
                if(oldFieldValue!=newFieldValue)
                { 
                    WebID__c webIdToAdd=ProcessIfBatchSizeIsOne(webIdNewMap.size(), webIdRef);
                    
                    //if(webIdToAdd!=Null) { WebIdsToProcess.put(webIdToAdd.Id, webIdToAdd); }
                    if(webIdToAdd!=Null)
                    {
                        accountIds.add(webIdToAdd.Account__c);
                    } 
                }
            }
            
            // 2012-11-27 MK - added condition for update (update is checked by checking oldMap)
            // because inserts from CastIron were failing
            if(webIdOldMap!=Null && !webIdOldMap.IsEmpty()) 
            {
                Boolean statusInactive=(webIdRef.Status__c=='Inactive' || old.Status__c=='Inactive');
                Boolean statusChanged=(webIdRef.Status__c!=old.Status__c);
                
                // if the WebID Account has changed, process old Accounts
                if((webIdRef.Account__c!=old.Account__c) || (statusInactive && statusChanged)) 
                {
                    // check for valid conditions
                    WebID__c newWebIdToAdd=processIfBatchSizeIsOne(webIdNewMap.size(), webIdRef); 
                    
                    if(newWebIdToAdd!=Null) // if the WebID is valid
                    {
                        if(webIdRef.Account__c!=Null)
                        {
                            accountIds.add(webIdRef.Account__c);
                        }
                        
                        if(old.Account__c!=Null)
                        {
                            accountIds.add(old.Account__c);
                        }
                    } 
                }
            }
        }
        
        system.debug('End filterWebIDsFromWebIdTrigger---->');
        return accountIds;
    }
    
    //This method is invoked for Account Trigger Scenario.
    private static Set<Id> filterWebIDsFromAccountTrigger(Map<Id, Account> accountOldMap, Map<Id, Account> accountNewMap)
    {
        system.debug('Start filterWebIDsFromAccountTrigger---->');
        
        //2016-02-22- anirudh.singh@cdk.com- Commented the below Map as it was not used anywhere.
        //Map<Id, Account> AccountsToProcess=new Map<Id, Account>();
        
        Set<Id> accountIdsToProcess=new Set<Id>();
        
        //Only process if specific fields have changed.
        if(accountNewMap!=Null)
        {
	        for(Account acc: accountNewMap.values())
	        {
	            Account old=accountOldMap!=Null ? accountOldMap.get(acc.Id) : Null;
	            if(old==Null)
                {
                    old=new Account();
                }
	            
	            // compile lists and delete previous Account Team Members that will be replaced
	            for(String field: settings.getFieldAndTeamRoleMap().keyset())
	            {
	                Id oldFieldValue=(Id) ALL_UtilitiesData.GetDataFromNestedFields(field, old); //old.get(field); 
	                Id newFieldValue=(Id) ALL_UtilitiesData.GetDataFromNestedFields(field, acc); //a.get(field);
	                
	                if(oldFieldValue!=newFieldValue)
                    { 
	                    //if(WebIdToAdd!=Null) { WebIdsToProcess.put(WebIdToAdd.Id, WebIdToAdd); }
	                    if(acc!=Null)
                        {
                            accountIdsToProcess.add(acc.Id);
                        } 
	                }
	            }
	        }
        }
        
        system.debug('End filterWebIDsFromAccountTrigger---->');
        return accountIdsToProcess;
    }
    
    private static WebID__c processIfBatchSizeIsOne(Integer numberOfWebIdRecs, WebID__c currentWebIdRecord)
    {
        system.debug('Start processIfBatchSizeIsOne---->');
        
        if(numberOfWebIdRecs>1 && !UserInfo.getUserName().toLowerCase().startsWith('integration_user@adp.com')
           && !UserInfo.getUserName().toLowerCase().startsWith('castiron.integration@adp.com')) 
        {
            currentWebIdRecord.addError('Only one WebID may be inserted or updated at a time. '
                                        + 'Please ensure the batch size is set to 1.');
            
            system.debug('End processIfBatchSizeIsOne Return Null---->');
            return Null;
        }
        else
        {
            system.debug('End processIfBatchSizeIsOne Return currentWebIdRecord---->');
            return currentWebIdRecord;
        }
    }
    
    public static void syncAccountTeamAndWebIdUsers(List<Id> accountIdsList)
    {
        system.debug('Start syncAccountTeamAndWebIdUsers---->');
        
        //Sets for uniqueness.
        Set<Account_Team__c> accTeamMembersToInsert=new Set<Account_Team__c>(); 
        Set<Account_Team__c> accTeamMembersToDelete=new Set<Account_Team__c>();
        
        //Lists to perform DML (inserts/deletes).
        List<Account_Team__c> accTeamMembersToInsertList=new List<Account_Team__c>(); 
        List<Account_Team__c> accTeamMembersToDeleteList=new List<Account_Team__c>();
        
        //Query the records (complete with WebID and Account Team subqueries).
        String queryString=buildQuery(accountIdsList, settings.fieldAndTeamRoleMap.keySet());
        List<Account> accountsList=Database.query(queryString);
        
        //Remove field values if WebID is inactive, and store the WebIDs to update for updating after inserts/deletes.
        List<WebID__c> webIDsToUpdateList=new List<WebID__c>();
        
        if(sObjectName.toLowerCase()=='webid__c')
        {
            webIDsToUpdateList=removeAllFieldValuesFromInactiveWebIDs(accountsList);
        }
        
        // gather data
        Map<Id, Map<Id, Account_Team__c>> accIdAndAccTeamMemberMap=gatherAccountTeamUserIdsByAccountId(accountsList);
        Map<Id, Map<Id, Account_Team__c>> accIdUserIdAndAccTeamMemberMap=gatherUsersByAccountId(accountsList, settings.getFieldAndTeamRoleMap());
        
        for(Id accountId: accountIdsList)
        {
            // compare which Users are on the Account Team
            ComparedUsers comparedUserRef=compareUserSets(accountId, settings.getFieldAndTeamRoleMap(), 
                                                          accIdAndAccTeamMemberMap.get(accountId), accIdUserIdAndAccTeamMemberMap.get(accountId));
            
            // compile a list for all Accounts
            for(Account_Team__c atm: comparedUserRef.userIdsToAddToAccountTeam.values())
            {
                accTeamMembersToInsert.add(atm);
            }
            
            for(Account_Team__c atm: comparedUserRef.userIdsToRemoveFromAccountTeam.values())
            {
                accTeamMembersToDelete.add(atm);
            }
        }
        
        accTeamMembersToInsertList.addAll(accTeamMembersToInsert);
        accTeamMembersToDeleteList.addAll(accTeamMembersToDelete);
        
        if(!accTeamMembersToInsertList.IsEmpty())
        {
            insert accTeamMembersToInsertList;
        }
        
        if(!accTeamMembersToDeleteList.IsEmpty())
        {
            delete accTeamMembersToDeleteList;
        }
        
        if(!webIDsToUpdateList.IsEmpty())
        {
            update webIDsToUpdateList;
        }
        
        system.debug('End syncAccountTeamAndWebIdUsers---->');
    }
    
    private static String buildQuery(List<String> allAccountIds, Set<String> fieldApiNames)
    {
        system.debug('Start buildQuery---->');
        String accountIds=ALL_UtilitiesString.ListToParenthesesCsv(allAccountIds);
        
        // build the Query String with Conditions (limiting Accounts by supplied Ids)
        String queryString=buildQueryWithoutConditions(fieldApiNames) + 'WHERE Id IN ' + accountIds;
        
        system.debug('End buildQuery---->');
        return queryString;
    }
    
    private static String buildQueryWithoutConditions(Set<String> fieldApiNames) 
    {
        system.debug('Start buildQueryWithoutConditions---->');
        
        //String TeamRoles=ALL_UtilitiesString.ListToParenthesesCsv(settings.getFields().values());
        
        // build the Account query string
        String queryString='';
        queryString += 'SELECT Id, Name, ';
        queryString += '(SELECT Id, Team_Member__c, Team_Member__r.IsActive, Team_Role__c ' 
            + 'FROM AccountTeamAccounts__r ' // AccountTeamAccounts__r is the relationship for Account Team Members
            //+ 'WHERE Team_Role__c IN ' + TeamRoles 
            + '), ';
        queryString += '(SELECT Id, Name, Account__c, Status__c ';
        
        if(sObjectName.toLowerCase()=='webid__c')
        {
            queryString += addFieldsToQuery(fieldApiNames);
        }
        
        // Sites__r is the relationship for WebIDs.
        queryString += ' ' + 'FROM Sites__r) ';
        
        if(sObjectName.toLowerCase()=='account')
        {
            queryString += addFieldsToQuery(fieldApiNames);
        }
        
        queryString += 'FROM Account '
            + '';
        
        system.debug('End buildQueryWithoutConditions---->');
        return queryString;
    }
    
    private static String addFieldsToQuery(Set<String> fieldApiNames)
    {
        system.debug('Start addFieldsToQuery---->');
        String queryString='';
        
        // loop through the fieldApiNames and add them to the query
        for(String field: fieldApiNames) 
        {
            // add the field
            queryString += ',' + field;
            
            // build the relationship name for the field (to get the IsActive status of the referenced User)
            String fieldc=field;
            String fieldr='';
            
            try
            {
                fieldr=fieldc.substring(0, fieldc.length()-1) + 'r';
            }
            catch(Exception ex) { }
            
            // add the relationship name and IsActive field
            if(fieldr!='')
            {
                queryString += ',' + fieldr + '.IsActive ';
            }
        }
        
        system.debug('End addFieldsToQuery---->');
        return queryString;
    }
    
    private static List<WebID__c> removeAllFieldValuesFromInactiveWebIDs(List<Account> accountList)
    {
        system.debug('Start removeAllFieldValuesFromInactiveWebIDs---->');
        
        List<WebID__c> webIDsToUpdateList=new List<WebID__c>();
        
        for(Account acc: accountList)
        {
            List<WebID__c> webIdsList=acc.getSObjects('Sites__r');
            
            if(webIdsList!=Null)
            {
                // for each WebID
                for(WebID__c webIdRec: webIdsList)
                {
                    // if WebID is inacitve
                    if(webIdRec.Status__c=='Inactive')
                    {
                        // remove values from all WebID fields
                        Boolean fieldsUpdated=false;
                        
                        for(String fieldApiName: settings.getFieldAndTeamRoleMap().keyset())
                        { 
                            if(ALL_UtilitiesData.GetDataFromNestedFields(fieldApiName, webIdRec)!=Null)
                            { 
                                ALL_UtilitiesData.PutDataInNestedFields(fieldApiName, webIdRec, Null);
                                fieldsUpdated=true;
                            } 
                        }
                        
                        if(fieldsUpdated==true)
                        {
                            webIDsToUpdateList.add(webIdRec);
                        }
                    }
                }
            }
        }
        
        system.debug('End removeAllFieldValuesFromInactiveWebIDs---->');
        return webIDsToUpdateList;
    }
    
    //Account Team User Ids (and Roles) by Account Ids.
    private static Map<Id, Map<Id, Account_Team__c>> gatherAccountTeamUserIdsByAccountId(List<Account> accountList)
    {
        system.debug('Start gatherAccountTeamUserIdsByAccountId---->');
        
        Map<Id, Map<Id, Account_Team__c>> accIdAndAccTeamMemberMap=new Map<Id, Map<Id, Account_Team__c>>();
        
        for(Account acc: accountList) 
        {
            Map<Id, Account_Team__c> accTeamMemberMap=new Map<Id, Account_Team__c>();
            
            List<Account_Team__c> accTeamMembersList=acc.getSObjects('AccountTeamAccounts__r');
            
            if(accTeamMembersList!=Null)
            {
                for(Account_Team__c atm: accTeamMembersList)
                {
                    if(atm.Team_Member__c!=Null)
                    { 
                        accTeamMemberMap.put(atm.Team_Member__c, atm); 
                    }
                }
            }
            
            accIdAndAccTeamMemberMap.put(acc.Id, accTeamMemberMap);
        }
        
        system.debug('End gatherAccountTeamUserIdsByAccountId---->');
        return accIdAndAccTeamMemberMap;
    }
    
    //sObject User Ids (and Roles) by Account Ids.
    private static Map<Id, Map<Id, Account_Team__c>> gatherUsersByAccountId(List<Account> accountList, Map<String, String> fieldAndTeamRoleMap) 
    {
        system.debug('Start gatherUsersByAccountId---->');
        
        Map<Id, Map<Id, Account_Team__c>> accIdUserIdAndAccTeamMemberMap=new Map<Id, Map<Id, Account_Team__c>>();
        
        for(Account acc: accountList) 
        {
            List<sObject> sObjectList=new List<sObject>(); 
            
            if(sObjectName.toLowerCase()=='webid__c')
            {
                sObjectList=acc.getSObjects('Sites__r');
            }
            
            if(sObjectName.toLowerCase()=='account')
            {
                sObjectList=new List<sObject>{acc};
            }
            
            Map<Id, Account_Team__c> userIdAndAccTeamMemberMap=gatherUserIdsWithRolesFromSObjects(sObjectList, fieldAndTeamRoleMap);
            
            accIdUserIdAndAccTeamMemberMap.put(acc.Id, userIdAndAccTeamMemberMap);
        }
        
        system.debug('End gatherUsersByAccountId---->');
        return accIdUserIdAndAccTeamMemberMap;
    }
    
    private static Map<Id, Account_Team__c> gatherUserIdsWithRolesFromSObjects(List<sObject> sObjectList, Map<String, String> fieldAndTeamRoleMap)
    {
        system.debug('Start gatherUserIdsWithRolesFromSObjects---->');
        
        Map<Id, Account_Team__c> userIdAndAccTeamMemberMap=new Map<Id, Account_Team__c>();
        
        if(sObjectList!=Null)
        {
            for(sObject rec: sObjectList)
            {
                for(String fieldApiName: fieldAndTeamRoleMap.keySet())
                {
                    String fieldc=fieldApiName;
                    String fieldr='';
                    if(fieldApiName.endsWith('__c'))
                    {
                        try
                        {
                            fieldr=fieldc.substring(0, fieldc.length()-1) + 'r';
                        }
                        catch(Exception ex) { }
                    }
                    
                    User userRecord=new User();
                    if(fieldr!='')
                    {
                        userRecord=(User) ALL_UtilitiesData.GetDataFromNestedFields(fieldr, rec);
                    }
                    
                    if(userRecord!=Null && userRecord.IsActive)
                    {
                        Account_Team__c atm=new Account_Team__c();
                        atm.Team_Role__c=fieldAndTeamRoleMap.get(fieldApiName); 
                        atm.put('Team_Member__c', userRecord.Id);
                        atm.putSObject('Team_Member__r', userRecord);
                        
                        Id userId=(Id) ALL_UtilitiesData.GetDataFromNestedFields(fieldApiName, rec);
                        if(userId!=Null)
                        {
                            userIdAndAccTeamMemberMap.put(userId, atm);
                        }
                    }
                }
            }
        }
        
        system.debug('End gatherUserIdsWithRolesFromSObjects---->');
        return userIdAndAccTeamMemberMap;
    }
    
    //To be looped through by account
    private static ComparedUsers compareUserSets(Id accountId, Map<String, String> fieldAndTeamRoleMap, 
                                                 Map<Id, Account_Team__c> accTeamMemberMap, Map<Id, Account_Team__c> userIdAndAccTeamMemberMap)
    {
        system.debug('Start compareUserSets---->');
        
        ComparedUsers comparedUserRef=new ComparedUsers();
        
        // check Account Team Members for WebID Users
        //   if not on Account Team, add to add list
        for(Id userId: userIdAndAccTeamMemberMap.keySet()) 
        {
            if(!accTeamMemberMap.keySet().contains(userId)) 
            {
                Account_Team__c accountTeamMember=userIdAndAccTeamMemberMap.get(userId);
                
                comparedUserRef.userIdsToAddToAccountTeam.put(userId, 
                                                              new Account_Team__c(
                                                                  Account__c=accountId,
                                                                  Team_Member__c=userId,
                                                                  Team_Role__c=accountTeamMember!=Null ? accountTeamMember.Team_Role__c: Null, 
                                                                  Account_Access__c='Read/Write', 
                                                                  Opportunity_Access__c='Read Only', 
                                                                  Case_Access__c='Read/Write'
                                                              )); 
            }
        }
        
        // check WebID Users for Account Team Members
        //   if not on any WebID, add to remove list
        for(Id accountTeamUserId: accTeamMemberMap.keySet()) 
        {
            if(!userIdAndAccTeamMemberMap.keySet().contains(accountTeamUserId)) 
            {
                // get the current Account Team Member and their Team Role
                Account_Team__c atm=accTeamMemberMap.get(accountTeamUserId);
                String atmTeamRole=atm!=Null ? atm.Team_Role__c: Null;
                
                // since all Account Team Members are included, only remove if the Team Role is in the Field Settings
                Set<String> fieldTeamRoles=new Set<String>();
                fieldTeamRoles.addAll(fieldAndTeamRoleMap.values());
                
                if(fieldTeamRoles.contains(atmTeamRole)) 
                {
                    comparedUserRef.userIdsToRemoveFromAccountTeam.put(accountTeamUserId, (Account_Team__c) accTeamMemberMap.get(accountTeamUserId)); 
                }
            }
        }
        
        system.debug('End compareUserSets---->');
        return comparedUserRef;
    }
    
    //2016-02-25- anirudh.singh@cdk.com- Added this method.
    public static void processWebIdsAfterInsert(Map<Id, WebID__c> newMap)
    {
        system.debug('Start processWebIdsAfterInsert---->');
        createEntitlementOnInsert(newMap);
        setAccountPlanFields();
        system.debug('End processWebIdsAfterInsert---->');
    }
    
    //To Pass the Id of WebId object which are 'Active' on Insert.
    private static void createEntitlementOnInsert(Map<Id, WebID__c> newMap)
    {
        system.debug('Start createEntitlementOnInsert---->');
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlementOnInsert(newMap);
        system.debug('End createEntitlementOnInsert---->');
    }
    
    //2016-02-25- anirudh.singh@cdk.com- Added this method.
    public static void processWebIdsAfterUpdate(Map<Id, WebID__c> oldMap, Map<Id, WebID__c> newMap)
    {
        system.debug('Start processWebIdsAfterUpdate---->');
        createEntitlementOnUpdate(oldMap, newMap);
        setAccountPlanFields();
        system.debug('End processWebIdsAfterUpdate---->');
    }
    
    private static void createEntitlementOnUpdate(Map<Id, WebID__c> oldMap, Map<Id, WebID__c> newMap)
    {
        system.debug('Start createEntitlementOnUpdate---->');
        CB_EntitlementsToWebIdAssignment_Handler.createEntitlementOnUpdate(oldMap, newMap);
        system.debug('End createEntitlementOnUpdate---->');
    }
    
    private static void setAccountPlanFields()
    {
        system.debug('Start setAccountPlanFields---->');
        List<WebID__c> webIDlist=Trigger.new!=Null ? (List<WebID__c>)Trigger.new: Null;
        Map<ID, WebID__c> webIDMap=Trigger.newMap!=Null ? (Map<ID, WebID__c>)Trigger.newMap: Null;
        Map<ID, WebID__c> webIDOldMap=Trigger.oldMap!=Null ? (Map<ID, WebID__c>)Trigger.oldMap: new Map<ID, WebID__c>();
        
        Set<String> fieldSet=new Set<String>{'LMA_Analyst__c', 'LMA_Analyst2__c', 'LMA_strategist__c', 'Digital_Advertising_Strategist__c', 'Online_Marketing_Specialist__c'};
        Set<ID> webIDset=new Set<ID>();
        
        if(webIDlist!=Null && !webIDlist.isEmpty())
        {
            for(WebID__c webIdRecord: webIDlist)
            {  
                WebID__c newRecord=webIdRecord;
                WebID__c oldRecord=(webIDOldMap!=Null && !webIDOldMap.isEmpty()) ? webIDOldMap.get(webIdRecord.ID): Null;
                
                if(fieldSet!=Null && newRecord!=Null && oldRecord!=Null)
                {
                    Boolean fieldValueChanged=false;
                    fieldValueChanged=ALL_UtilitiesLogic.compareNewAndOldTriggerValues(fieldSet, newRecord, oldRecord);
                    
                    if(fieldValueChanged)
                    {
                        webIDset.add(webIdRecord.ID);
                    }
                }
            }
        }
        
        Map<ID, Account_Plan__c> accountPlanMap;
        
        if(webIDset!=Null && !webIDset.isEmpty())
        {
            accountPlanMap=new Map<ID, Account_Plan__c>([
                Select Id, WebId__c, OwnerID, Secondary_Owner__c, RecordTypeId
                From Account_Plan__c
                Where WebID__c
                IN :webIDset
            ]);
        }
        
        if(accountPlanMap!=Null && !accountPlanMap.isEmpty())
        {
            for(Account_Plan__c accPlan: accountPlanMap.values())
            {
                string recordTypeName;
                if(accPlan!=Null && accPlan.RecordTypeId!=Null)
                {
                    recordTypeName=ALL_UtilitiesDescribe.getRecordTypeNameOfAnySObject('Account_Plan__c', accPlan.RecordTypeId);
                }
                
                if(accPlan.webID__c!=Null)
                {
                    webID__c currentWebID=webIDMap.get(accPlan.webId__c);
                    
                    if(currentWebID!=Null)
                    {
                        if(currentWebID.Digital_Advertising_Strategist__c!=Null)
                        {
                            if(recordTypeName=='DAA Account Plan')
                            {
                                if(currentWebID.Digital_Advertising_Strategist__c!=Null)
                                {
                                    accPlan.ownerID=currentWebID.Digital_Advertising_Strategist__c;
                                }
                                accPlan.Secondary_Owner__c=currentWebID.Online_Marketing_Specialist__c;
                            }
                        }
                        if(currentWebID.Digital_Advertising_Strategist__c==Null)
                        {
                            if(recordTypeName=='DAA Account Plan')
                            {
                                if(currentWebID.Online_Marketing_Specialist__c!=Null)
                                {
                                    accPlan.ownerID=currentWebID.Online_Marketing_Specialist__c;
                                }
                                accPlan.Secondary_Owner__c=Null;
                            }
                        }
                        if(currentWebID.LMA_Strategist__c!=Null)
                        {
                            if(recordTypeName=='AMA Account Plan')
                            {
                                accPlan.OwnerId=currentWebID.LMA_Strategist__c;
                            }
                        }
                    }
                }
            }
        }
        
        if(accountPlanMap!=Null && !accountPlanMap.isEmpty())
        {
            //update accountPlanMap.values();
            ALL_UtilitiesData.SerializesObjectList(accountPlanMap.values(), 'Update');           
        }
        system.debug('End setAccountPlanFields---->');
    }
    
    //Inner Class.
    public class FieldSettings
    {
        //2016-02-12- anirudh.singh@cdk.com- Commented the ListOfFields variable and getListOfFields List as it were not used anywhere in the code.
        //Full field definition.
        //private List<Account_Team_Sync_Settings__c> ListOfFields=new List<Account_Team_Sync_Settings__c>();
        //public List<Account_Team_Sync_Settings__c> getListOfFields()
        //{
        //return ListOfFields;
        //}
        
        //Field API Name indexes the Labels (Name) of each field.
        private Map<String, String> fieldAndTeamRoleMap=new Map<String, String>();
        public Map<String, String> getFieldAndTeamRoleMap()
        {
            return fieldAndTeamRoleMap;
        }
        
        public FieldSettings(String objName)
        {
            // get the custom settings to determine the fields to process
            for(Account_Team_Sync_Settings__c accTeamSyncSettingRef: Account_Team_Sync_Settings__c.getall().values())
            {
                if(accTeamSyncSettingRef.sObject__c==objName)
                {
                    //2016-02-12- anirudh.singh@cdk.com- Commented the below line ListOfFields.add(accTeamSyncSettingRef) as it was not used anywhere in the code.
                    //ListOfFields.add(accTeamSyncSettingRef);
                    fieldAndTeamRoleMap.put(accTeamSyncSettingRef.User_ID_Field_API_Name__c, accTeamSyncSettingRef.Team_Role__c);
                }
            }
        }
    }
    
    //Inner Class
    //To be collected by account
    public class ComparedUsers
    {
        // User Id (unique by User Id) and Account Team Member
        Map<Id, Account_Team__c> userIdsToAddToAccountTeam;
        Map<Id, Account_Team__c> userIdsToRemoveFromAccountTeam;
        
        public ComparedUsers()
        {
            userIdsToAddToAccountTeam=new Map<Id, Account_Team__c>();
            userIdsToRemoveFromAccountTeam=new Map<Id, Account_Team__c>();
        }
    }
}