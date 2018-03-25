//2016-05-30 - vishal.bandari@cdk.com - added the recursivelyFetchTopParentAccountIdList method - RQ-07014
public without sharing class AccountHierarchyTools
{
    public static Id TopParentAccountId(Id ChildAccountId)
    {
        list<Account> AccountList = [Select Id, Name, ParentId From Account Where Id = :ChildAccountId Limit 1];
        Account CurrentAccount = AccountList != null && !AccountList.isEmpty() ? AccountList[0] : null;
        
        if(CurrentAccount != null && CurrentAccount.ParentId == null) { return CurrentAccount.Id; }
        
        while (CurrentAccount != null && CurrentAccount.ParentId != null)
        {
            AccountList = [Select Id, Name, ParentId From Account Where Id = :CurrentAccount.ParentId Limit 1];
            
            if(AccountList != null && !AccountList.isEmpty()) {
                CurrentAccount = AccountList[0]; }
            else { 
                return CurrentAccount.Id; }
        }
        
        if(CurrentAccount != null) { return CurrentAccount.Id; }
        else { return null; }
    }
    
    // 2015-07-30 matt.keefe@cdk.com - added alias for backward compatibility
    public static Id RecursiveTopParentAccountId(Id ChildAccountId)
    {
        return recursivelyFetchTopParentAccountId(ChildAccountId);
    }
    
    // 2015-07-24 anirudh.singh@cdk.com - Removed the method RecursiveTopParentAccountId as it was not working properly.
    // 2015-07-24 anirudh.singh@cdk.com - Added the method recursivelyFetchTopParentAccountId. 
    // This method is used to fetch the topMost Parent Account Id.
    public static Id recursivelyFetchTopParentAccountId(String accountId)
    {
        system.debug('Start recursivelyFetchTopParentAccountId---->');
        Boolean checkTopAccount=false;
        Id topmostParentId=Null;
        
        Account acc=[
            SELECT Id, 
            ParentId, 
            Parent.ParentId, 
            Parent.Parent.ParentId, 
            Parent.Parent.Parent.ParentId, 
            Parent.Parent.Parent.Parent.ParentId, 
            Parent.Parent.Parent.Parent.Parent.ParentId
            FROM Account 
            WHERE Id=:accountId];
        
        if(acc.Parent.Parent.Parent.Parent.Parent.ParentId!=Null)
        {
            topmostParentId=acc.Parent.Parent.Parent.Parent.Parent.ParentId;
            checkTopAccount=true;
        }
        else if(acc.Parent.Parent.Parent.Parent.ParentId!=Null)
        {
            topmostParentId=acc.Parent.Parent.Parent.Parent.ParentId;
        }
        else if(acc.Parent.Parent.Parent.ParentId!=Null)
        {
            topmostParentId=acc.Parent.Parent.Parent.ParentId;
        }
        else if(acc.Parent.Parent.ParentId!=Null)
        {
            topmostParentId=acc.Parent.Parent.ParentId;
        }
        else if(acc.Parent.ParentId!=Null)
        {
            topmostParentId=acc.Parent.ParentId;
        }
        else if(acc.ParentId!=Null)
        {
            topmostParentId=acc.ParentId;
        }
        else
        {
            topmostParentId=acc.Id;
        }
        
        if(checkTopAccount)
        {
            return recursivelyFetchTopParentAccountId(topmostParentId);
        }
        
        system.debug('End recursivelyFetchTopParentAccountId---->');
        return topmostParentId;
    }
    
    
    //2016-05-19 vishal.bandari@cdk.com - added Method to bulkify Code - RQ-07014
    public static Map<Id,Id> recursivelyFetchTopParentAccountIdList(List<Id> accountId)
    {
        system.debug('Start recursivelyFetchTopParentAccountIdList---->');
        Boolean checkTopAccount=false;
        
        Map<Id,Account> accMap=new Map<Id,Account>([
            SELECT Id, 
            ParentId, 
            Parent.ParentId, 
            Parent.Parent.ParentId, 
            Parent.Parent.Parent.ParentId, 
            Parent.Parent.Parent.Parent.ParentId, 
            Parent.Parent.Parent.Parent.Parent.ParentId
            FROM Account 
            WHERE Id =: accountId
        ]);
        
        Map<Id,Id> accountTopMap = new Map<Id,Id>();
        
        List<Id> accountList = new List<Id>();
        
        for(Account acc: accMap.values())
        {
            if(acc.Parent.Parent.Parent.Parent.Parent.ParentId!=Null)
            {
                checkTopAccount=true;
                accountList.add(acc.Parent.Parent.Parent.Parent.Parent.ParentId);
            }
            else if(acc.Parent.Parent.Parent.Parent.ParentId!=Null)
            {
                accountTopMap.put(acc.Id,acc.Parent.Parent.Parent.Parent.ParentId);
            }
            else if(acc.Parent.Parent.Parent.ParentId!=Null)
            {
                accountTopMap.put(acc.Id,acc.Parent.Parent.Parent.ParentId);
            }
            else if(acc.Parent.Parent.ParentId!=Null)
            {
                accountTopMap.put(acc.Id,acc.Parent.Parent.ParentId);
            }
            else if(acc.Parent.ParentId!=Null)
            {
                accountTopMap.put(acc.Id,acc.Parent.ParentId);
            }
            else if(acc.ParentId!=Null)
            {
                accountTopMap.put(acc.Id,acc.ParentId);
            }
            else
            {
                accountTopMap.put(acc.Id,acc.Id);
            }
        }
        
        if(checkTopAccount)
        {
            Map<Id,Id> topResult = recursivelyFetchTopParentAccountIdList(accountList);
            accountTopMap.putAll(topResult);
        }
        
        system.debug('End recursivelyFetchTopParentAccountIdList---->');
        return accountTopMap;
    }
    
    // this only works 100 levels deep because it is recursive and 
    // it may run into a governor limit (number of queries)
    public static Set<Id> ChildrenAccountIds(Set<Id> AccountIds)
    {
        // create a new temporary set of Ids
        Set<Id> CurrentAccountIds = new Set<Id>();
        
        // for all Accounts that have the current Account as a ParentId, 
        // add their Account Ids to the process list
        for(Account a : [SELECT Id, CBLTBillState__c, DS_LGL_Data_Rights_Opt_Out__c FROM Account WHERE ParentId IN :AccountIds AND ParentId != null]) {
            CurrentAccountIds.add(a.Id); }
        
        // Recursion!
        // get all of the children Accounts for any Accounts returned by the query
        if(CurrentAccountIds.size() > 0) {
            system.debug('CurrentAccountIds.size() -->'+CurrentAccountIds.size());
            CurrentAccountIds.addAll(ChildrenAccountIds(CurrentAccountIds)); }
        
        // return all of the Child Account Ids
        return CurrentAccountIds;
    }
    
    // 2016-02-17 - lalitha.adduru@cdk.com - parent to child accounts Map of each account in the hierarchy - RQ-6139
    public static Map<id, List<Account>> ParentToChildAccountsMap(List<Account> accountList)
    {
        
        Map<id,List<Account>> childrenAccountMap = new Map<id,List<Account>>();
        
        if(accountList != null && !accountList.isEmpty())
        {
            // create a new temporary set of Ids
            Set<Id> CurrentAccountIds = new Set<Id>();
            List<Account> childAccountList = new List<Account>();
            
            childAccountList = [
                SELECT Id, Name, CBLTBillState__c, DS_LGL_Data_Rights_Opt_Out__c, ParentId 
                FROM Account 
                WHERE ParentId IN :AccountList and ParentId != null
            ];
            
            for(Account a : childAccountList )
            {
                CurrentAccountIds.add(a.Id);
                if(childrenAccountMap.containsKey(a.parentId))
                {
                    childrenAccountMap.get(a.parentId).add(a); 
                }
                else
                {
                    childrenAccountMap.put(a.parentId, new List<Account>{a}); 
                }
                
            }
            childrenAccountMap.putAll(ParentToChildAccountsMap(childAccountList));
        }
        return childrenAccountMap;
    }
    // 2016-02-17 - lalitha.adduru@cdk.com - parent to child accounts Map of each account in th hierarchy - end
    
    public static Map<Id, Id> TopParentAccountIdsByAccountId(List<Id> AccountIds)
    {
        system.debug(AccountIds);
        // TopParentAccounts - Parent Account Ids by Account Ids
        Map<Id, Id> TopParentAccounts = new Map<Id, Id>();
        for(Id aid : AccountIds) { TopParentAccounts.put(aid, aid); }
        
        system.debug(TopParentAccounts);
        
        return TopParentAccountIdsByAccountId(TopParentAccounts);
    }
    
    public static Map<Id, Id> TopParentAccountIdsByAccountId(Map<Id, Id> TopParentAccounts)
    {
        if(TopParentAccounts == null) { return new Map<Id, Id>(); }
        
        // reverse the map so that we can lookup the original Account Id by the Parent Account Id
        Map<Id, Id> OriginalAccounts = new Map<Id, Id>();
        for(Id aid : TopParentAccounts.keyset()) { 
            OriginalAccounts.put(TopParentAccounts.get(aid), aid); }
        
        system.debug(TopParentAccounts.values());
        
        // get the current set of Parent Ids (even if AccountId = ParentId)
        String AccountIdConditions = ALL_UtilitiesString.ListToParenthesesCsv(TopParentAccounts.values());
        
        system.debug(AccountIdConditions);
        
        // query for Parent Account Ids
        String q = 'Select Id, ParentId From Account Where Id IN ' + AccountIdConditions; system.debug(q);
        List<Account> Accounts = Database.query(q);
        
        boolean MoreAccounts = false;
        
        for(Account a : Accounts)
        {
            // a.Id is the queried/current Parent Account
            // a.ParentId is the Account above the Parent Account
            
            if(a.ParentId != null) 
            {
                MoreAccounts = true;
                
                // get the Original Account Id from the Parent Account Id, and replace its Top Account
                Id OriginalAccountId = OriginalAccounts.get(a.Id);
                TopParentAccounts.put(OriginalAccountId, a.ParentId);
            }
        }
        
        // if additional Parent Account Ids were found, perform recursion!
        if(MoreAccounts) { TopParentAccounts = TopParentAccountIdsByAccountId(TopParentAccounts); }
        
        return TopParentAccounts;
    }
    
    // map<ChildId, map<SiteTypeName, ParentId>>
    public static Map<ID, Map<string, Account>> HierarchySiteTypesForFiveLevels(List<ID> AccountIDs)
    {
        Map<ID, Account> IncommingAccountsMap;
        
        if(AccountIDs != null && !AccountIDs.isEmpty())
        {
            //2017-03-15  ragashalini.koka@cdk.com - commented the field District__c in SOQL for RQ-08732
            IncommingAccountsMap = new map<ID, Account>([
                Select Id, Name, Corporation__c, Group__c, /*District__c,*/ Site_Type__r.Name, ShippingCountry,
                Parent.Id, Parent.Site_Type__r.Name, Parent.ShippingCountry, Parent.Name,
                Parent.Parent.Id, Parent.Parent.Site_Type__r.Name, Parent.Parent.ShippingCountry, Parent.Parent.Name,
                Parent.Parent.Parent.Id, Parent.Parent.Parent.Site_Type__r.Name, Parent.Parent.Parent.ShippingCountry,
                Parent.Parent.Parent.Name, Parent.Parent.Parent.Parent.Id, Parent.Parent.Parent.Parent.Site_Type__r.Name,
                Parent.Parent.Parent.Parent.ShippingCountry, Parent.Parent.Parent.Parent.Name
                From Account
                Where ID IN: AccountIDs
            ]);
        }
        
        Map<ID, Map<string, Account>> SiteTypeMapByChildId = new Map<ID, Map<string, Account>>();
        
        if(IncommingAccountsMap != null && AccountIDs != null)
        {
            for(ID id: IncommingAccountsMap.keySet())
            {
                Account a = IncommingAccountsMap.get(id);
                
                if(SiteTypeMapByChildId.get(id) == null){ SiteTypeMapByChildId.put(Id, new Map<string, Account>()); }               
                
                if(a != null)
                {
                    if(a.Parent.Parent.Parent.Parent.Site_Type__r.Name != null)
                    {
                        SiteTypeMapByChildId.get(id).put(
                            a.Parent.Parent.Parent.Parent.Site_Type__r.Name, 
                            a.Parent.Parent.Parent.Parent);
                    }
                    if(a.Parent.Parent.Parent.Site_Type__r.Name != null)
                    {
                        SiteTypeMapByChildId.get(id).put(
                            a.Parent.Parent.Parent.Site_Type__r.Name,
                            a.Parent.Parent.Parent);
                    }
                    if(a.Parent.Parent.Site_Type__r.Name != null)
                    {
                        SiteTypeMapByChildId.get(id).put(
                            a.Parent.Parent.Site_Type__r.Name, 
                            a.Parent.Parent);
                    }
                    if(a.Parent.Site_Type__r.Name != null)
                    {
                        SiteTypeMapByChildId.get(id).put(
                            a.Parent.Site_Type__r.Name, 
                            a.Parent);
                    }
                }
            }
        }
        
        return SiteTypeMapByChildId;
    }
    
    // 2016-2-18 lalitha.adduru@cdk.com added a method to get all accounts which do not have child accounts 
    public static List<Account> getAccountsOfNullChildAccounts(List<Account> accounts)
    {
        List<Account> accountsWithNullchildAccounts = new List<Account>();
        List<Account> accountList = new List<Account>();
        accountList = [select id, name,CBLTBillState__c,DS_LGL_Data_Rights_Opt_Out__c, (select id, name,CBLTBillState__c,DS_LGL_Data_Rights_Opt_Out__c from childAccounts) from Account where id in :accountList];
        for(Account a : accountList)
        {
            if(a.getsObjects('ChildAccounts') == null)
            {
                accountsWithNullchildAccounts.add(a);
            }
        }
        return accountsWithNullchildAccounts;       
    }
}