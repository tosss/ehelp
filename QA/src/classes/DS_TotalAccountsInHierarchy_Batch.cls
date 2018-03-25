global Class DS_TotalAccountsInHierarchy_Batch implements Database.Batchable<sObject>
{
    global List<Account> AccountList = new List<Account>();
   
    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        return Database.getQueryLocator('Select ID, Name From Account');
    }
    
    public void execute(Database.BatchableContext BC, List<Account> AccountList)
    {
        list<ID> AccountsIDs = new list<ID>();
        
        for(Account a: AccountList)
        {
            AccountsIDs.add(a.ID);
        }
        
        if(AccountsIDs != null && !AccountsIDs.isEmpty())
        {
            DS_TotalAccountsInHierarchy_Batch.AccountHierarchyTotalSiteCount(AccountsIDs);
        }        
    }
    
    public static void AccountHierarchyTotalSiteCount(List<ID> AccountsIDs)
    {
        // below method organizes the childern accounts with filling the corp, group and district fields with relevant values
        DS_TotalAccountsInHierarchy_Batch.OrganizeChildToParentFieldValues(AccountsIDs);
        
        system.debug(AccountsIDs);
        
        map<Id, Id> ChildAccountIdToParentIdMap = AccountHierarchyTools.TopParentAccountIdsByAccountId(AccountsIDs);
        map<ID, Account> FinalUpdateMap = new map<ID, Account>();
        
        map<ID, Account> HierarchyMembersMap;
        set<ID> ParentIDset;
        
        
        system.debug(ChildAccountIdToParentIdMap);
        
        if(ChildAccountIdToParentIdMap != null && !ChildAccountIdToParentIdMap.isEmpty())
        {
            ParentIDset = new set<ID>(ChildAccountIdToParentIdMap.values());            
        }  
        
        system.debug(ParentIDset);
        
        if(ParentIDset != null && !ParentIDset.isEmpty())
        {
            // query children Accounts using Parent Account ID list
            HierarchyMembersMap = new map<ID, Account>([
                Select Id, Name, Site_Type__c, Site_Type__r.Name, Total_Hierarchy_Site_Count__c, Corporation__c, Group__c, District__c, ParentId 
                From Account 
                Where (Corporation__c IN: ParentIDset
                       OR Group__c IN: ParentIDset
                       OR District__c IN: ParentIDset 
                       OR ParentId IN: ParentIDset 
                       OR Id IN: ParentIDset) 
                AND Out_of_Business__c = false 
                AND Duplicate__c = false
            ]);
        } 
       
        map<ID, set<Account>> HierarchyMembersSortedMap = new map<ID, set<Account>>();
        
        if(HierarchyMembersMap != null && !HierarchyMembersMap.isEmpty())
        {
            for(ID id: HierarchyMembersMap.keySet())
            {
                Account CurrentAccount = HierarchyMembersMap.get(id);
                
                for(ID PId: ParentIDset)
                {
                    if((CurrentAccount.Corporation__c != null && PId == CurrentAccount.Corporation__c) ||
                      PId == CurrentAccount.Id)
                    {
                        if(HierarchyMembersSortedMap.get(PId) == null)
                        { 
                            HierarchyMembersSortedMap.put(PId, new set<Account>{CurrentAccount});
                        }
                        else{ HierarchyMembersSortedMap.get(PId).add(CurrentAccount); }
                    }
                    
                    if((CurrentAccount.Corporation__c == null && CurrentAccount.Group__c != null &&  PId == CurrentAccount.Group__c) ||
                      PId == CurrentAccount.Id)
                    {
                        if(HierarchyMembersSortedMap.get(PId) == null)
                        { 
                            HierarchyMembersSortedMap.put(PId, new set<Account>{CurrentAccount});
                        }
                        else{ HierarchyMembersSortedMap.get(PId).add(CurrentAccount); }                            
                    }
                    
                }
                
            }
        }
        
        set<Account> NoCorpGrpDist;        
        
        if(HierarchyMembersSortedMap != null && !HierarchyMembersSortedMap.isEmpty())
        {
            for(ID id: HierarchyMembersSortedMap.keySet())
            { 
                NoCorpGrpDist = new set<Account>();
                Integer TotalAccountsCount = 0;
                
                for(Account a: HierarchyMembersSortedMap.get(id))
                {  
                    if(a.Site_Type__c != null)
                    {                
                        if(a.site_Type__r.Name.toLowerCase() != 'corporation' && 
                           a.site_Type__r.Name.toLowerCase() != 'group' &&
                           a.site_Type__r.Name.toLowerCase() != 'district')
                        {
                            NoCorpGrpDist.add(a);
                        } 
                    }                    
                }
                
                system.debug(NoCorpGrpDist);
                
                if(NoCorpGrpDist != null && !NoCorpGrpDist.isEmpty())
                {
                    TotalAccountsCount = NoCorpGrpDist.size();
                }
                
                system.debug(TotalAccountsCount);
                
                if(HierarchyMembersSortedMap != null && !HierarchyMembersSortedMap.isEmpty())
                {
                    for(Account a: HierarchyMembersSortedMap.get(id))
                    {
                        if(FinalUpdateMap.containsKey(a.Id))
                        {
                            FinalUpdateMap.get(a.Id).Total_Hierarchy_Site_Count__c = TotalAccountsCount;                    
                        }
                        else
                        {
                            a.Total_Hierarchy_Site_Count__c = TotalAccountsCount;
                            FinalUpdateMap.put(a.Id, a);
                        }
                    }
                }                
            }
        }
        
        system.debug(FinalUpdateMap);
        
        if(FinalUpdateMap != null && !FinalUpdateMap.isEmpty())
        {
            Database.Update (FinalUpdateMap.values(), false);
        }
        
    }
    
    public static void OrganizeChildToParentFieldValues(List<ID> AccountsIDs)
    {
        system.debug(AccountsIDs);
        
        map<ID, map<String, Account>> SiteTypeMapByChildId = AccountHierarchyTools.HierarchySiteTypesForFiveLevels(AccountsIDs);
        map<ID, Account> FinalUpdateMap = new map<ID, Account>();
        
        system.debug(SiteTypeMapByChildId);        
        
        set<ID> AccountIDsSet = new set<ID>(AccountsIDs);
        
        system.debug(AccountIDsSet);      
        
        //the total accounts in a hierachy will change when ParentId field is changed so it has to be updated
        //query all Parent records for the incomming Accounts. these accounts are here only if ParentId has changed. it's checked in the trigger
        
        map<ID, Account> ChildAccountMap = new map<ID, Account>([
            Select Id, Name, ParentId, Group__c, Corporation__c, ShippingCountry, Parent.ParentId, Parent.Parent.ParentId, 
                  Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId,
                  (Select Id, Name, ParentId, Group__c, Corporation__c, District__c, 
                          Corporation__r.Name, Total_Hierarchy_Site_Count__c
                   From ChildAccounts)
            From Account
            Where ID IN :AccountsIDs
        ]);
        
        // loop through to see if the accounts that are comming through trigger have the Corporation__c same as the top parent. if no,
        // set it to the top parent
        
        system.debug(SiteTypeMapByChildId);
        system.debug(ChildAccountMap);
        
        if(SiteTypeMapByChildId != null && ChildAccountMap != null && !SiteTypeMapByChildId.keySet().isEmpty())
        {
            for(ID id: SiteTypeMapByChildId.keySet())
            {
                Account CurrentChildAccount = null;
                Account CorporateAccount = null;
                Account DistrictAccount = null;
                Account GroupAccount = null;
                
                map<string, Account> CurrentSiteTypeMap = SiteTypeMapByChildId.get(id);
                
                if (ChildAccountMap != null && ChildAccountMap.get(id) != null && 
                    SiteTypeMapByChildId != null && CurrentSiteTypeMap != null)
                {
                    CurrentChildAccount = ChildAccountMap.get(id);               
                    
                    if(CurrentSiteTypeMap.containsKey('Corporation')){ CorporateAccount = CurrentSiteTypeMap.get('Corporation'); }
                    if(CurrentSiteTypeMap.containsKey('District')){ DistrictAccount = CurrentSiteTypeMap.get('District'); }
                    if(CurrentSiteTypeMap.containsKey('Group')){ GroupAccount = CurrentSiteTypeMap.get('Group'); }
                    
                    system.debug(CorporateAccount);
                    system.debug(CurrentChildAccount.Name);
                    system.debug(CurrentChildAccount);
                    
                    
                    if(CorporateAccount != null && 
                       (CurrentChildAccount.Corporation__c != CorporateAccount.Id || CurrentChildAccount.Corporation__c == null)) 
                    {                           
                        CurrentChildAccount.Corporation__c = CorporateAccount.Id; 
                    } 
                    else if(CorporateAccount == null) { CurrentChildAccount.Corporation__c = null;}
                    
                    
                    if(GroupAccount != null && 
                       (CurrentChildAccount.Group__c != GroupAccount.Id || CurrentChildAccount.Group__c == null))
                    {
                        CurrentChildAccount.Group__c = GroupAccount.Id;                   
                    }
                    else if(GroupAccount == null) { CurrentChildAccount.Group__c = null; }
                    
                    
                    if(DistrictAccount != null && 
                       (CurrentChildAccount.District__c != DistrictAccount.Id || CurrentChildAccount.District__c == null))
                    {
                        CurrentChildAccount.District__c = DistrictAccount.Id;                   
                    }
                    else if(DistrictAccount == null){ CurrentChildAccount.District__c = null; }
                    
                    
                    if(!FinalUpdateMap.keySet().contains(CurrentChildAccount.Id))
                    {
                        FinalUpdateMap.put(CurrentChildAccount.Id, CurrentChildAccount);
                    }
                }
            }
        }
        
        if(FinalUpdateMap != null && !FinalUpdateMap.isEmpty())
        {
            Database.Update (FinalUpdateMap.values(), false);
        }
    }
    
    public void finish(Database.BatchableContext info) 
    {
    }
}