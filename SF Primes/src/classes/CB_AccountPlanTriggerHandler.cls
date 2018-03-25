public with sharing class CB_AccountPlanTriggerHandler 
{
    public static boolean hasAlreadyRanBeforeUpdate = false;
    public static set<String> FieldsToCheck;    
    
    public static void handleBeforeUpdate(map<Id, Account_Plan__c> newAccountPlanMap, map<Id, Account_Plan__c> oldAccountPlanMap) 
    {      
        
        FieldsToCheck = new set<string>();
        
        FieldsToCheck = Account_Plan_Fields__c.getAll().keySet();
        
        
        if(!hasAlreadyRanBeforeUpdate) 
        {
            hasAlreadyRanBeforeUpdate = true;
        }
        
        List<Account_Plan__c> updateAccountPlanList = new List<Account_Plan__c>();
        
        Set<ID> webIds = new Set<ID>();
        set<ID> AccountPlanIdSet = new set<ID>();
        
        map<Id, Account> EchelonAccountsToUpdate = new map<Id, Account>();       
        
        for(Account_Plan__c accPlanObj : newAccountPlanMap.values()) 
        {
            Account a = new Account(Id=accPlanObj.Account__c);            
            a.DA_Echelon_Level__c = accPlanObj.DA_Echelon_Level__c;
            EchelonAccountsToUpdate.put(a.Id, a);          
            
            boolean checkUpdate = false;
            
            for(String field : FieldsToCheck) 
            {
                if(oldAccountPlanMap.get(accPlanObj.id).get(field) != accPlanObj.get(field)) 
                {
                    checkUpdate = true;
                }
            }
            
            if(checkUpdate) 
            {
                webIds.add(accPlanObj.WebId__c);
                AccountPlanIdSet.add(accPlaNObj.id);
            }
        }
        
        if(!EchelonAccountsToUpdate.isEmpty()) 
        {
            try
            {
                update EchelonAccountsToUpdate.values();
            } 
            catch(exception e)
            {
                e.setMessage(e.getMessage());
            }
        }
        
        if(webIds != null && webIds.size() > 0) 
        {                
            map<String, List<Account_Plan__c>> webIdsAccountPlansMap = new map<String, List<Account_Plan__c>>();
            
            list<string> AccountPlanFieldsList = new list<string>();
            list<ID> AccountPlanIdList = new list<ID>();
            list<ID> WebIdsList = new list<ID>();
            
            AccountPlanFieldsList.addAll(FieldsToCheck);                    
            AccountPlanIdList.addAll(AccountPlanIdSet);                    
            WebIdsList.addAll(webIds);
            
            string WebIDString = ALL_UtilitiesString.ListToParenthesesCsv(WebIdsList);
            string AccountPlanIdString = ALL_UtilitiesString.ListToParenthesesCsv(AccountPlanIdList);
            String AccountPlanFields = ALL_UtilitiesString.ListToEnclosedCSV(AccountPlanFieldsList,'');
            
            system.debug(AccountPlanFields);
            
            if(WebIDString != null && WebIDString.trim() != '' && WebIDString.trim() != '()'
               && AccountPlanIdString != null && AccountPlanIdString.trim() != '' && AccountPlanIdString.trim() != '()')
            {
                
                string QueryString = 'SELECT Id, Name, WebId__c,' + AccountPlanFields + ' FROM Account_Plan__c' + ' WHERE WebId__c IN ' + WebIDString 
                    + ' AND Id NOT IN ' + AccountPlanIdString;
                
                system.debug(QueryString);
                
                List<Account_Plan__c> accountPlans = Database.Query(QueryString);                    
                
                if(accountPlans != null && accountPlans.size() > 0) 
                {
                    for(Account_Plan__c ap : accountPlans) 
                    {
                        List<Account_Plan__c> tempAPs = webIdsAccountPlansMap.get(ap.WebId__c);
                        
                        if(tempAPs != null)
                        {
                            tempAPs.add(ap);
                            webIdsAccountPlansMap.put(ap.WebId__c, tempAPs);
                        }
                        else
                        {
                            tempAPs = new List<Account_Plan__c>();
                            tempAPs.add(ap);
                            webIdsAccountPlansMap.put(ap.WebId__c, tempAPs);
                        }
                    }
                    
                    Boolean isAccountPlanUpdated = false;
                    
                    for(Account_Plan__c accPlanObj : newAccountPlanMap.values()) 
                    {
                        List<Account_Plan__c> relatedAccountPlans = webIdsAccountPlansMap.get(accPlanObj.WebId__c);
                        
                        if(relatedAccountPlans != null && relatedAccountPlans.size() > 0) 
                        {
                            for(Account_Plan__c ap : relatedAccountPlans) 
                            {
                                for(string field : FieldsTocheck) 
                                {
                                    Account_Plan__c oldAccountPlan = OldAccountPlanMap.get(accPlanObj.id);
                                    if(oldAccountPlan == null) { oldAccountPlan = new Account_Plan__c(); }
                                    
                                    if(oldAccountPlan.get(field)!= accPlanObj.get(field)) 
                                    {
                                        ap.put(field, accPlanObj.get(field)); 
                                        isAccountPlanUpdated = true;
                                    }
                                }
                                
                                if(isAccountPlanUpdated) 
                                {
                                    updateAccountPlanList.add(ap);
                                    isAccountPlanUpdated = false;
                                }
                            }
                        }
                    }
                    
                    if(updateAccountPlanList != null && updateAccountPlanList.size() > 0)
                    {
                        try
                        { 
                            update updateAccountPlanList;
                        }
                        catch(exception e)
                        { 
                            
                        }
                    }
                }                
            }
        }       
    }
}