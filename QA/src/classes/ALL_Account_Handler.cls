// 2016-02-12 - created by lalitha.adduru@cdk.com - RQ-6139

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
        
        system.debug('stateToDataRightsMap -- >'+stateToDataRightsMap);
        for(Account newAccount: TriggerNew)
        {
            //to check BillingState Matches the required values 
            if(newAccount.BillingState != null)
            {
                system.debug('newAccount.BillingState -- >'+newAccount.BillingState);
                system.debug('stateToDataRightsMap.get(newAccount.BillingState) -- >'+stateToDataRightsMap.get(newAccount.BillingState));
                
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
                            system.debug('newAccount.BillingState -- >'+newAccount.BillingState);
                            newAccount.DS_LGL_Data_Rights_Opt_Out__c += '; '+ stateToDataRightsMap.get(newAccount.BillingState);
                            system.debug('newAccount.BillingState -- >'+newAccount.BillingState);
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
                system.debug('in account isInsert');
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
                system.debug('newAccounts --->'+newAccounts);
                
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
                system.debug('parentToChildAccountsMap -->'+parentToChildAccountsMap.size());
                
                // variables to store DS_LGL_Data_Rights_Opt_Out__c picklist values
                Set<String> valuesToBeAdded = new Set<String>();
                Set<String> valuesToBeRemoved = new Set<String>();
                Set<string> newSelectedValues = new Set<String>();
                Set<string> oldSelectedValues = new Set<String>();
                
                for(Account acc : requiredAccountMap.Values())
                {
                    String newDataRightsOptOut = acc.DS_LGL_Data_Rights_Opt_Out__c;
                    system.debug('new datarights of '+acc.name+' --> '+newDataRightsOptOut);
                    String oldDataRightsOptOut = oldAccountMap.get(acc.id).DS_LGL_Data_Rights_Opt_Out__c;
                    system.debug('old datarights of '+acc.name+' --> '+oldDataRightsOptOut);
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
                        system.debug('valuesToBeRemoved from trigger.new '+acc.name +'--- >'+valuesToBeRemoved);
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
                        system.debug('valuesToBeAdded to trigger.new  '+acc.name+' --> '+valuesToBeAdded);
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
            system.debug( 'To be added to '+acc.name+' that has '+acc.DS_LGL_Data_Rights_Opt_Out__c+' --- > '+valueSet);
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
}