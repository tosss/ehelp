// 2016-02-12 - created by lalitha.adduru@cdk.com - RQ-6139
//2016-08-02 ragashalini.koka@cdk.com - RQ-07349 - added handleContactRelationshipsOfDuplicateAccounts method
//2016-11-07 - lalitha.adduru@cdk.com - RQ-08111 
public class ALL_Account_Handler  
{     
    // 2016-02-12 - added by lalitha.adduru@cdk.com to verify that accounts with BillingState NC and CA have 9D in their dataRightsOptOut Field - RQ-06139
    public static void verifyStateToDataRights(List<Account> TriggerNew)
    {
        Map<String, Account__c> dataRightsCustomSettingMap = Account__c.getAll();
        Map<String,String> stateToDataRightsMap = new Map<String,String>();
        for(Account__c dataRightsCustomSetting : dataRightsCustomSettingMap.values() )
        {
            stateToDataRightsMap.put(dataRightsCustomSetting.Data_Rights_State_to_Skip__c, dataRightsCustomSetting.Data_Rights_Name__c);    
        }
        
        /*List<Account__c> dataRightsCustomSetting = new List<Account__c>();
dataRightsCustomSetting = [
SELECT id, Data_Rights_Name__c, Data_Rights_State_to_Skip__c 
FROM Account__c
];

// to form a map from state to data rights name
Map<String,String> stateToDataRightsMap = new Map<String,String>();
for(Account__c customSetting : dataRightsCustomSetting)
{
stateToDataRightsMap.put(customSetting.Data_Rights_State_to_Skip__c, customSetting.Data_Rights_Name__c);
}*/
        
        //system.debug('stateToDataRightsMap -- >'+stateToDataRightsMap);
        for(Account newAccount: TriggerNew)
        {
            //to check BillingState Matches the required values 
            if(newAccount.BillingState != null)
            {
                //system.debug('newAccount.BillingState -- >'+newAccount.BillingState);
                //system.debug('stateToDataRightsMap.get(newAccount.BillingState) -- >'+stateToDataRightsMap.get(newAccount.BillingState));
                
                if(stateToDataRightsMap.get(newAccount.BillingState)!= null)
                {
                    if(newAccount.DS_LGL_Data_Rights_Opt_Out__c == null)
                    {
                        newAccount.DS_LGL_Data_Rights_Opt_Out__c= stateToDataRightsMap.get(newAccount.BillingState);       
                    }
                    else
                    {
                        Set<String> selectedDataRightsOptOut = new Set<String>(newAccount.DS_LGL_Data_Rights_Opt_Out__c.split(';'));
                        
                        if(!selectedDataRightsOptOut.contains(stateToDataRightsMap.get(newAccount.BillingState)))
                        {
                            //system.debug('newAccount.BillingState -- >'+newAccount.BillingState);
                            newAccount.DS_LGL_Data_Rights_Opt_Out__c += '; '+ stateToDataRightsMap.get(newAccount.BillingState);
                            //system.debug('newAccount.BillingState -- >'+newAccount.BillingState);
                        }
                    }
                    
                }
            }
        }
    }
    
    // 2016-02-16 - lalitha.adduru@cdk.com - added to propagate DS_LGL_Data_Rights_Opt_Out__c field value down to all child records - RQ-06139
    public static void propagateDataRights(List<Account> newAccounts, Map<id, Account> oldAccountMap)
    {
        if(newAccounts != null && !newAccounts.isEmpty())
        {       
            // before insert
            if(oldAccountMap == null || oldAccountMap.isEmpty())
            {
                //system.debug('in account isInsert');
                Map<Id, String> parentToDataRightsMap = new Map<Id, String>();
                Set<Id> parentAccountIdSet = new Set<Id>();
                
                for(Account acc : newAccounts)
                {
                    if(acc.parentId != null)
                    {
                        parentAccountIdSet.add(acc.ParentId);
                    }
                }
                
                if(parentAccountIdSet != null && !parentAccountIdSet.isEmpty())
                {
                    
                    Map<Id, Account> parentAccountsMap = new Map<Id, Account>([ SELECT Id, DS_LGL_Data_Rights_Opt_Out__c FROM Account WHERE Id in :parentAccountIdSet ]);
                    
                    if(!parentAccountsMap.isEmpty())
                    {
                        for( Account acc : newAccounts )
                        {
                            
                            if(parentAccountsMap.get(acc.parentId) != null && parentAccountsMap.get(acc.parentId).DS_LGL_Data_Rights_Opt_Out__c != null)
                            {
                                acc.DS_LGL_Data_Rights_Opt_Out__c = (acc.DS_LGL_Data_Rights_Opt_Out__c == null) ? parentAccountsMap.get(acc.parentId).DS_LGL_Data_Rights_Opt_Out__c : acc.DS_LGL_Data_Rights_Opt_Out__c+';'+parentAccountsMap.get(acc.parentId).DS_LGL_Data_Rights_Opt_Out__c;
                                if(acc.DS_LGL_Data_Rights_Opt_Out__c != parentAccountsMap.get(acc.parentId).DS_LGL_Data_Rights_Opt_Out__c )
                                {
                                    acc.DS_LGL_Data_Rights_Opt_Out__c = All_UtilitiesString.removeDuplicatesFromDelimitedString(acc.DS_LGL_Data_Rights_Opt_Out__c, ';');
                                }
                            }
                        }
                    }
                }
            }
            else
            { 
                // before update
                Map<id, Account> accountsToUpdateMap = new Map<id, Account>();
                Map<id,Account> requiredAccountMap = new Map<id,Account>();
                //system.debug('newAccounts --->'+newAccounts);
                
                // get only those accounts in which DS_LGL_Data_Rights_Opt_Out__c is getting updated
                for(Account acc : newAccounts)
                {
                    //system.debug('oldAccountMap.get(acc.id).DS_LGL_Data_Rights_Opt_Out__c on '+acc.name+'  -->'+oldAccountMap.get(acc.id).DS_LGL_Data_Rights_Opt_Out__c);
                    Set<String> dataRightsOptOutNew = new Set<String>( All_UtilitiesString.delimitedStringToList( acc.DS_LGL_Data_Rights_Opt_Out__c, ';' ) );
                    //system.debug('dataRightsOptOutNew on '+acc.name+' -->'+dataRightsOptOutNew);
                    Set<String> dataRightsOptOutOld = new Set<String>( All_UtilitiesString.delimitedStringToList( oldAccountMap.get(acc.id).DS_LGL_Data_Rights_Opt_Out__c, ';' ) );
                    //system.debug('dataRightsOptOutOld on '+acc.name+' -->'+dataRightsOptOutOld);
                    
                    if(!(dataRightsOptOutNew.containsAll(dataRightsOptOutOld) && dataRightsOptOutOld.containsAll(dataRightsOptOutNew)))
                    {
                        requiredAccountMap.put(acc.id, acc);
                    }
                }
                
                // get parent to child accounts map of all account in the hierarchy of trigger.newmap
                Map<id,List<Account>> parentToChildAccountsMap = new Map<id, List<Account>>();
                parentToChildAccountsMap = AccountHierarchyTools.parentToChildAccountsMap(requiredAccountMap.values());
               // system.debug('parentToChildAccountsMap -->'+parentToChildAccountsMap.size());
                
                // variables to store DS_LGL_Data_Rights_Opt_Out__c picklist values
                Set<String> valuesToBeAdded = new Set<String>();
                Set<String> valuesToBeRemoved = new Set<String>();
                Set<string> newSelectedValues = new Set<String>();
                Set<string> oldSelectedValues = new Set<String>();
                
                for(Account acc : requiredAccountMap.Values())
                {
                    String newDataRightsOptOut = acc.DS_LGL_Data_Rights_Opt_Out__c;
                    //system.debug('new datarights of '+acc.name+' --> '+newDataRightsOptOut);
                    String oldDataRightsOptOut = oldAccountMap.get(acc.id).DS_LGL_Data_Rights_Opt_Out__c;
                    //system.debug('old datarights of '+acc.name+' --> '+oldDataRightsOptOut);
                    newSelectedValues.addAll(ALL_UtilitiesString.delimitedStringToList(newDataRightsOptOut, ';'));
                    //system.debug('newSelectedValues -- >'+newSelectedValues);
                    OldSelectedValues.addAll(ALL_UtilitiesString.delimitedStringToList(oldDataRightsOptOut, ';'));
                    //system.debug('oldSelectedValues -->'+oldSelectedValues);
                    
                    if(oldSelectedValues != null && !oldSelectedValues.isEmpty())
                    {
                        for(String str : oldSelectedValues)
                        {
                            if(!newSelectedValues.contains(str))
                            {
                                valuesToBeRemoved.add(str);
                            }
                        }
                        //system.debug('valuesToBeRemoved from trigger.new '+acc.name +'--- >'+valuesToBeRemoved);
                    }
                    
                    if(newSelectedValues != null && !newSelectedValues.isEmpty())
                    {
                        for(String str : newSelectedValues)
                        {
                            if(!oldSelectedValues.contains(str))
                            {
                                valuesToBeAdded.add(str);
                            }
                        }
                        //system.debug('valuesToBeAdded to trigger.new  '+acc.name+' --> '+valuesToBeAdded);
                    }
                    
                    List<Account> childAccountList = new List<Account>();
                    childAccountList = parentToChildAccountsMap.get(acc.id);
                    //system.debug('childAccountList --> '+childAccountList);
                    List<Account> temporaryList = new List<Account>();
                    
                    while(childAccountList != null && !childAccountList.isEmpty())
                    {
                        if(!valuesToBeRemoved.isEmpty()){accountsToUpdateMap.putAll(removeValuesFromDataRights(childAccountList, valuesToBeRemoved,requiredAccountMap.keySet() ));}
                        if(!valuesToBeAdded.isEmpty()){accountsToUpdateMap.putAll(addValuesToDataRights(childAccountList, valuesToBeAdded, requiredAccountMap.keySet()));}
                        //system.debug('accountsToUpdateMap -- >'+accountsToUpdateMap.values());
                        //system.debug('childAccountList -->'+childAccountList);
                        
                        for(Account tempAccount : childAccountList)
                        {
                            //system.debug('parentToChildAccountsMap.get(tempAccount.id) -->'+parentToChildAccountsMap.get(tempAccount.id));
                            if(parentToChildAccountsMap.get(tempAccount.id) != null && !parentToChildAccountsMap.get(tempAccount.id).isEmpty())
                            {
                                temporaryList.addAll(parentToChildAccountsMap.get(tempAccount.id));
                                //system.debug('temporaryList -- >'+temporaryList);
                            }
                        }
                        
                        childAccountList.clear();
                        childAccountList.addAll(temporaryList);
                        temporaryList.clear();
                    }
                    
                    valuesToBeAdded.clear();
                    valuesToBeRemoved.clear();
                    newSelectedValues.clear();
                    OldSelectedValues.clear();
                }
                if(!accountsToUpdateMap.isEmpty())
                {
                    update accountsToUpdateMap.values();
                }
            }
        }
    }
    
    // 2016-02-20 - added by lalitha.adduru@cdk.com to add valueSet to dataRightsOptOut multi picklist in account - RQ-06139
    public static Map<id, Account> removeValuesFromDataRights(List<Account> childAccountList, Set<String> valueSet, Set<Id> idsToCheck)
    {
        Map<id,Account> accountsToUpdateMap = new Map<id,Account>();
        
        for(Account acc : childAccountList)
        {
            String dataRightsOptOut = acc.DS_LGL_Data_Rights_Opt_Out__c;
            
            if((dataRightsOptOut != null && !dataRightsOptOut.isWhitespace()) ||( valueSet!=null && !valueSet.isEmpty()))
            {
                system.debug('To be removed from '+acc.name+' that has '+acc.DS_LGL_Data_Rights_Opt_Out__c+' ---> '+valueSet);
                acc.DS_LGL_Data_Rights_Opt_Out__c = All_UtilitiesString.removeListOfStringsFromString(dataRightsOptOut, new List<String>(valueSet), ';');
                
                if(!IdsToCheck.Contains(acc.id))
                {
                    accountsToUpdateMap.put(acc.id, acc);
                    //system.debug('to update acc.name --> '+acc.name + ' with '+acc.DS_LGL_Data_Rights_Opt_Out__c);
                    //system.debug('accountsToUpdateMap ---> '+accountsToUpdateMap);
                }
            }
            
        }
        return accountsToUpdateMap;
    }
    
    // 2016-02-20 - added by lalitha.adduru@cdk.com to remove valueSet from dataRightsOptOut multi picklist in account - RQ-06139
    public static Map<id,Account> addValuesToDataRights(List<Account> childAccountList, Set<String> valueSet, Set<id> idsToCheck)
    {
        Map<id,Account> accountsToUpdateMap = new Map<id,Account>();
        
        for(Account acc : childAccountList)
        {
            Set<String> temporarySet = new Set<String>();
            temporarySet.addAll(valueSet);
            //system.debug( 'To be added to '+acc.name+' that has '+acc.DS_LGL_Data_Rights_Opt_Out__c+' --- > '+valueSet);
            if(valueSet != null && !valueSet.isEmpty())
            {
                acc.DS_LGL_Data_Rights_Opt_Out__c = (acc.DS_LGL_Data_Rights_Opt_Out__c == null) ? '' : acc.DS_LGL_Data_Rights_Opt_Out__c;
                if(acc.DS_LGL_Data_Rights_Opt_Out__c != '')
                {
                    temporarySet.add(acc.DS_LGL_Data_Rights_Opt_Out__c);
                }
                acc.DS_LGL_Data_Rights_Opt_Out__c = All_UtilitiesString.ListToDelimitedString( new List<String>(temporarySet), ';' );
                //system.debug('after adding value set acc.DS_LGL_Data_Rights_Opt_Out__c --> '+acc.DS_LGL_Data_Rights_Opt_Out__c);
                
                acc.DS_LGL_Data_Rights_Opt_Out__c = All_UtilitiesString.removeDuplicatesFromDelimitedString( acc.DS_LGL_Data_Rights_Opt_Out__c, ';' );
                //system.debug('after removing duplicates acc.DS_LGL_Data_Rights_Opt_Out__c --> '+acc.DS_LGL_Data_Rights_Opt_Out__c);
                
                if(!idsToCheck.contains(acc.id))
                {	
                    //system.debug('to update acc.name --> '+acc.name+'with '+acc.DS_LGL_Data_Rights_Opt_Out__c);
                    accountsToUpdateMap.put(acc.id, acc);
                    //system.debug('accountsToUpdateMap --- >'+accountsToUpdateMap);
                }  
            }
        }
        return accountsToUpdateMap;
    }
    
    // 2016-06-08 - added by sanjay.ghanathey@cdk.com Contact.Dealer_Group__c Update based on Buy-Sell - RQ-07181
    public static void updateContactDealerGroup(List<Account> newAccounts,Map<Id,Account> oldAccounts)
    {
        List<Id> accountIds = new List<Id>();
        Map<Id,Id> accountIdToParentAccountId = new Map<Id,Id>();
        List<Contact> contactsToUpdate = new List<Contact>();
        
        for(Account newAccount : newAccounts)
        {
            Account oldAccount = oldAccounts != null ? oldAccounts.get(newAccount.Id) : null;
            Boolean isChanged = (oldAccount == null || (oldAccount != null && oldAccount.ParentId != newAccount.ParentId));
            
            if((newAccount.ParentId != null || newAccount.ParentId != '') && isChanged){
                accountIds.add(newAccount.Id);
            }
        }
        
        //system.debug('$$ newAccounts'+newAccounts);
        //system.debug('$$ accountIds'+accountIds);
        
        if(accountIds != null && !accountIds.isEmpty()){
            accountIdToParentAccountId = AccountHierarchyTools.recursivelyFetchTopParentAccountIdList(accountIds);
            //system.debug('$$ accountIdToParentAccountId'+accountIdToParentAccountId);
            
            List<Contact> contactList = [select id,Dealer_Group__c,AccountId from Contact where accountId =:accountIds];
            //system.debug('$$ contactList'+contactList);
            
            if(contactList!=null && !contactList.isEmpty()){
                Id tempId;
                for(Contact contact : contactList){
                    tempId =  accountIdToParentAccountId.get(contact.AccountId);
                    
                    if(tempId != null)
                    {
                        contact.Dealer_Group__c = tempId;
                        contactsToUpdate.add(contact);
                    }
                }
            }
        }
        
        if(contactsToUpdate !=null && !contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }
        
        //system.debug('$$ exiting method - contacts'+contactsToUpdate);
    }
    
    
    //2016-08-02 ragashalini.koka@cdk.com - RQ-07349 - added logic to delete duplicate Contact Relationships and update the Account_Contact_Id__c 
    // 												field of losing account CR's  while merging Accounts 
    public static void handleContactRelationshipsOfDuplicateAccounts(Map<Id,Account> oldMap) {
        Map<Id,Id> oldAccIdToNewAccIdMap = new Map<Id,Id>();
        //identify the records that are deleted due to the merge process
        for(Account acc : oldMap.values()) {
            if(acc.MasterRecordId != null) {
                oldAccIdToNewAccIdMap.put(acc.Id,acc.MasterRecordId);
            }
        }
        if(oldAccIdToNewAccIdMap.size() > 0) {
            Set<Id> newAccIdSet = new Set<Id>(oldAccIdToNewAccIdMap.values());
            List<Contact_Relationship__c> crList = [SELECT Id, Account__c, Contact__c, Account_Contact_Id__c FROM Contact_Relationship__c WHERE Account__c IN :newAccIdSet];
            
            Map<Id,Set<Id>> accIdToContactIdMap = new Map<Id,Set<Id>>();
            List<Contact_Relationship__c> crListOfLosingAccount = new List<Contact_Relationship__c>();
            for(Contact_Relationship__c crRef : crList) {
                if(String.valueOf(crRef.Account__c) + String.valueOf(crRef.Contact__c) == String.valueOf(crRef.Account_Contact_Id__c)) {
                    if(!accIdToContactIdMap.containsKey(crRef.Account__c)) {
                        accIdToContactIdMap.put(crRef.Account__c,new Set<Id>());
                    }
                    Set<Id> contactIdSet = accIdToContactIdMap.get(crRef.Account__c);
                    
                    contactIdSet.add(crRef.Contact__c);
                    accIdToContactIdMap.put(crRef.Account__c, contactIdSet);
                }
                else {
                    crListOfLosingAccount.add(crRef);
                }
                
            }
            Set<Id> crSetToBeDeleted = new Set<Id>();
            Map<Id,Contact_Relationship__c> crMapToBeUpdated = new Map<Id,Contact_Relationship__c>();
            Set<String> processedAccountContactIdSet = new Set<String>();
            for(Contact_Relationship__c crRef : crListOfLosingAccount) {
                //checks if the winning accounts already has a combination of CR
                if(accIdToContactIdMap.containsKey(crRef.Account__c)) {
                    if(accIdToContactIdMap.get(crRef.Account__c).contains(crRef.Contact__c)) {
                        crSetToBeDeleted.add(crRef.Id);
                    }
                    else {
                        crRef.Account_Contact_Id__c = String.valueOf(crRef.Account__c) + String.valueOf(crRef.Contact__c);
                        //checks if 2 losing accounts form same combination of CR
                        if(processedAccountContactIdSet.contains(crRef.Account_Contact_Id__c)) {
                            crSetToBeDeleted.add(crRef.Id);
                        }
                        else {
                            processedAccountContactIdSet.add(crRef.Account_Contact_Id__c); 
                            crMapToBeUpdated.put(crRef.Id,crRef);
                        }
                    }
                }
            }
            
            crList = [SELECT Id FROM Contact_Relationship__c WHERE Id IN :crSetToBeDeleted];
            delete crList;
            
            update crMapToBeUpdated.values();
            
            
        }
        
    }
    
       //2017-02-27 ragashalini.koka@cdk.com - RQ-08685 - Added this method to make the CRs inactive if the Account is marked Duplicate
    public static void inactivateCROfDuplicateAccounts(Map<Id,Account> oldMap, List<Account> newList) {
        Set<Id> accIdSet = new Set<Id>();
        for(Account acc : newList) {
            Account oldAcc = oldMap.get(acc.Id);
            if(acc.Duplicate__c && (acc.Duplicate__c != oldAcc.Duplicate__c)) {
                accIdSet.add(acc.Id);
            }
        }
        
        if(accIdSet.size() > 0) {
            //check for CRs with Authorized_Contract_Signer as true and make them false for successful inactivation
            
            List<Contact_Relationship__c> crList = [SELECT Id,Authorized_Contract_Signer__c FROM Contact_Relationship__c WHERE Status__c = 'Active' AND Account__c IN :accIdSet];
            for(Contact_Relationship__c cr : crList) {
                cr.Authorized_Contract_Signer__c = false;
                cr.Status__c = 'Inactive';
            }
            update crList;
        }
    
    }
   
    
    //2016-11-07 - lalitha.adduru@cdk.com - add relevant Account Teams when an Account is inserted with a CDK DEfault Team - RQ-08111 
    public static void populateAccountTeamMembers(List<Account> newAccounts)
    {
        if(newAccounts != null && !newAccounts.isEmpty())
        {
            List<Account_Team__c> teamsToInsert = new List<Account_Team__c>();
            Set<Id> cdkdefaultTeamIds = new Set<Id>();
            for(Account newAccount : newAccounts)
            {
                if(newAccount.CDK_Default_Team__c != null)
                {
                    cdkdefaultTeamIds.add(newAccount.CDK_Default_Team__c);
                }
            }
            // get a Map that maps a CDK Default team with a Map of Team_Member__c (user) to ADP_Default_Team_Members__c 
            Map<Id, Map<Id, ADP_Default_Team_Members__c>> teamToMembersMap = new Map<Id, Map<Id, ADP_Default_Team_Members__c>>();
            teamToMembersMap = ALL_ADPDefaultTeamMembers_Handler.getDefTeamToTeamMemMap(cdkdefaultTeamIds);
            for(Account newAccount : newAccounts)
            {
                if(newAccount.CDK_Default_Team__c!= null)
                {
                    List<ADP_Default_Team_Members__c> teamMemberList;
                    teamMemberList = teamToMembersMap.containsKey(newAccount.CDK_Default_Team__c) != null ? 
                        teamToMembersMap.get(newAccount.CDK_Default_Team__c).values() : new List<ADP_Default_Team_Members__c>();
                    for(ADP_Default_Team_Members__c teamMember : teamMemberList)
                    {
                        Account_Team__c newAccountTeam = new Account_Team__c();
                        newAccountTeam.Team_Member__c = teamMember.Team_Member__c;
                        newAccountTeam.Opportunity_Access__c = teamMember.Opportunity_Access__c;
                        newAccountTeam.Account_Access__c = teamMember.Account_Access__c;
                        newAccountTeam.Case_Access__c = newAccountTeam.Case_Access__c;
                        newAccountTeam.Team_Role__c = 'OEM Sales';
                        newAccountTeam.Account__c = newAccount.Id;
                        teamsToInsert.add(newAccountTeam);
                    }
                }
            }
            if(!teamsToInsert.isEmpty())
            {
                system.debug('Account is inserted with account team---> '+teamsToInsert);
                insert teamsToInsert;
            }
        }
    }
    
    //2016-11-07 - lalitha.adduru@cdk.com - add relevant Account Teams when CDK Default Team is updated - RQ-08111 
    public static void updateAccountTeamMembers(List<Account> updatedAccounts, Map<Id, Account> oldAccountMap)
    {
        if(updatedAccounts != null)
        {
            system.debug('**************** updateAccountTeamMembers started *********************');
            system.debug('********************$$$$'+updatedAccounts+'$$$ ****'+oldAccountMap);
            Set<Account> requiredAccounts = new Set<Account>();
            Set<Id> CDKDefaultTeamIdList = new Set<Id>();
            
            // get only those accounts for which CDK Default team is changing
            for(Account updatedAccount : updatedAccounts)
            {
                if(updatedAccount.CDK_Default_Team__c != oldAccountMap.get(updatedAccount.Id).CDK_Default_Team__c)
                {
                    if(updatedAccount.CDK_Default_Team__c != null)
                    {
                        CDKDefaultTeamIdList.add(updatedAccount.CDK_Default_Team__c);
                    }
                    if(oldAccountMap.get(updatedAccount.Id).CDK_Default_Team__c != null)
                    {
                        CDKDefaultTeamIdList.add(oldAccountMap.get(updatedAccount.Id).CDK_Default_Team__c);
                    }
                    requiredAccounts.add(updatedAccount);
                }
            }
            
            // get a Map that maps a CDK Default team with a Map of Team_Member__c (user) to ADP_Default_Team_Members__c 
            Map<Id, Map<Id, ADP_Default_Team_Members__c>> teamToMembersMap = new Map<Id, Map<Id, ADP_Default_Team_Members__c>>();
            teamToMembersMap = ALL_ADPDefaultTeamMembers_Handler.getDefTeamToTeamMemMap(CDKDefaultTeamIdList);
            //system.debug('teamToMembersMap --- > '+teamToMembersMap);
            
            // Map that maps an Account to its Account Teams member Ids and a Map that maps account to its account teams with role 'OEM Sales'
            Map<Id, Map<Id, Account_Team__c>> accountToAccountTeamMap = new Map<Id, Map<Id, Account_Team__c>>();
            Map<Id, Map<Id, Account_Team__c>> accountToOEMSalesMap = new Map<Id, Map<Id, Account_Team__c>>();
            accountToAccountTeamMap = getAccountToAccountTeamMap(requiredAccounts);
            for(Account requiredAccount : requiredAccounts)
            {
                List<Account_Team__c> accountTeams;
                accountTeams = accountToAccountTeamMap.get(requiredAccount.Id) != null ? accountToAccountTeamMap.get(requiredAccount.Id).values() : new List<Account_Team__c>();
                for(Account_Team__c accountTeam : accountTeams)
                {
                    if(accountTeam.Team_Role__c == 'OEM Sales')
                    {
                        if(accountToOEMSalesMap.containsKey(accountTeam.Account__c))
                        {
                            accountToOEMSalesMap.get(accountTeam.Account__c).put(accountTeam.Team_Member__c, accountTeam);
                        }
                        else
                        {
                            accountToOEMSalesMap.put(accountTeam.Account__c, new Map<Id, Account_Team__c>{accountTeam.Team_Member__c=>accountTeam});
                        }
                    }
                }
            }
            //system.debug('accountToAccountTeamMap --- >'+accountToAccountTeamMap);
            
            List<Account_Team__c> accountTeamsToBeInserted = new List<Account_Team__c>();
            List<Account_Team__c> teamsToDelete = new List<Account_Team__c>();
            List<Account_Team__c> teamsToUpdate = new List<Account_Team__c>();
            for(Account updatedAccount : requiredAccounts)
            {
                if(updatedAccount.CDK_Default_Team__c == null)
                {
                    if(accountToOEMSalesMap.get(updatedAccount.Id) != null && !accountToOEMSalesMap.get(updatedAccount.Id).isEmpty())
                    {
                        teamsToDelete.addAll(accountToOEMSalesMap.get(updatedAccount.Id).values());
                    }               
                }
                else
                {
                    Map<Id, ADP_Default_Team_Members__c> userToTeamMemberMap =  teamToMembersMap.get(updatedAccount.CDK_Default_Team__c);
                    if(userToTeamMemberMap!=null && userToTeamMemberMap.keySet() != null)
                    {
                        Set<Id> existingAccountTeamUserIds = accountToAccountTeamMap.get(updatedAccount.Id)!=null ? accountToAccountTeamMap.get(updatedAccount.Id).keySet() : new Set<Id>();
                        if(existingAccountTeamUserIds!=null)
                        {
                            for(Id teamMemberId : userToTeamMemberMap.keySet())
                            {
                                // scenarios 
                                // 1. The user doesn't exist as a Team Member already on the Account - new Account Team is inserted
                                // 2. The user does exist with Role as OEM Sales, but the access permissions are different, in which case, existing account team is updated
                                if(!existingAccountTeamUserIds.contains(teamMemberId) || existingAccountTeamUserIds.isEmpty())
                                {
                                    Account_Team__c newAccountTeam = new Account_Team__c();
                                    newAccountTeam.Account__c = updatedAccount.Id;
                                    newAccountTeam.Team_Member__c = teamMemberId;
                                    newAccountTeam.Team_Role__c = 'OEM Sales';
                                    newAccountTeam.Account_Access__c = userToTeamMemberMap.get(teamMemberId).Account_Access__c;
                                    newAccountTeam.Opportunity_Access__c = userToTeamMemberMap.get(teamMemberId).Opportunity_Access__c;
                                    newAccountTeam.Case_Access__c = userToTeamMemberMap.get(teamMemberId).Account_Access__c;
                                    accountTeamsToBeInserted.add(newAccountTeam);
                                }
                                else if(existingAccountTeamUserIds.contains(teamMemberId)
                                        && (accountToAccountTeamMap.get(updatedAccount.Id).get(teamMemberId).Account_Access__c != userToTeamMemberMap.get(teamMemberId).Account_Access__c
                                            || accountToAccountTeamMap.get(updatedAccount.Id).get(teamMemberId).Opportunity_Access__c != userToTeamMemberMap.get(teamMemberId).Opportunity_Access__c
                                            || accountToAccountTeamMap.get(updatedAccount.Id).get(teamMemberId).Case_Access__c != userToTeamMemberMap.get(teamMemberId).Account_Access__c))
                                {
                                    accountToAccountTeamMap.get(updatedAccount.Id).get(teamMemberId).Account_Access__c = userToTeamMemberMap.get(teamMemberId).Account_Access__c;
                                    accountToAccountTeamMap.get(updatedAccount.Id).get(teamMemberId).Opportunity_Access__c = userToTeamMemberMap.get(teamMemberId).Opportunity_Access__c;
                                    accountToAccountTeamMap.get(updatedAccount.Id).get(teamMemberId).Case_Access__c = userToTeamMemberMap.get(teamMemberId).Account_Access__c;
                                    teamsToUpdate.add(accountToAccountTeamMap.get(updatedAccount.Id).get(teamMemberId));                               
                                }
                            }
                            
                        }
                    }
                    if(oldAccountMap.get(updatedAccount.Id).CDK_Default_Team__c != null)
                    {
                        if(accountToOEMSalesMap.get(updatedAccount.Id) != null && !accountToOEMSalesMap.get(updatedAccount.Id).isEmpty())
                        {
                            Set<Id> existingOEMSalesTeamIds = accountToOEMSalesMap.get(updatedAccount.Id).keyset();
                            for(Id existingTeamMemberId : existingOEMSalesTeamIds)
                            {
                                if(!userToTeamMemberMap.keySet().contains(existingTeamMemberId))
                                {
                                    teamsToDelete.add(accountToOEMSalesMap.get(updatedAccount.Id).get(existingTeamMemberId));
                                }
                            }
                        }
                    }
                }
            }
            
            if(!teamsToDelete.isEmpty())
            {system.debug('Account Teams to be deleted -- > '+teamsToDelete);
             delete teamsToDelete;}
            if(!accountTeamsToBeInserted.isEmpty())
            {system.debug('Account Teams to be inserted -- > '+accountTeamsToBeInserted);insert accountTeamsToBeInserted;}
            
            if(!teamsToUpdate.isEmpty())
            {
                system.debug('Account Team to be updated -- > '+teamsToUpdate);
                update teamsToUpdate;            
            }
            
            system.debug('********************** updateAccountTeamMembers ended ***********************');
        }
    }
    
    //2016-11-07 - lalitha.adduru@cdk.com - get Account to Account Team Map - RQ-08111 
    //'SampleAccountId'=>('AccountTeamUserId' = > 'AccountTeamRecord')
    public static Map<Id, Map<Id, Account_Team__c>> getAccountToAccountTeamMap(Set<Account> accounts)
    {
        Map<Id, Map<Id, Account_Team__c>> accountToAccountTeamMap = new Map<Id, Map<Id, Account_Team__c>>();
        List<Account_Team__c> accountTeamList = new List<Account_Team__c>();
        accountTeamList = [
            SELECT id, Account__c, Team_Member__c, Account_User_Id__c,Account_Access__c, Case_Access__c,Opportunity_Access__c, Team_Role__c
            FROM Account_Team__c WHERE Account__c in :accounts
        ];
        for(Account_Team__c accountTeam : accountTeamList)
        {
            if(accountToAccountTeamMap.containsKey(accountTeam.Account__c))
            {
                accountToAccountTeamMap.get(accountTeam.Account__c).put(accountTeam.Team_Member__c,accountTeam);
            }
            else
            {
                accountToAccountTeamMap.put(accountTeam.Account__c, new Map<Id, Account_Team__c>{accountTeam.Team_Member__c=>accountTeam});
            }
        }
        return accountToAccountTeamMap;
    }    
}