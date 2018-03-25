// this class can handle 22 field changes at one single account save call with a total of 198 soql queries
public class DS_AccountHierarchyFieldUpdates
{   
    public static void AccountHierarchyProcessBeforeFuture(list<Account> newAccounts, map<Id, Account> oldMap)
    { 
        map<string, Account_Hierarchy_Rolldown__c> AccountHierarchyProfileIdsMap = Account_Hierarchy_Rolldown__c.getAll();        
        set<string> FieldSetForCurrentProfile = new set<string>();
        list<ID> AccountsIDs = new list<ID>();
        
        for(Account NewAccount: newAccounts)
        {
            if(Trigger.isInsert)
            {                
                AccountsIDs.add(NewAccount.ID);                
            }
            else
            {
                Account OldAccount = oldMap.get(NewAccount.Id);
                
                if (NewAccount.Corporation__c != OldAccount.Corporation__c || NewAccount.Group__c != OldAccount.Group__c ||
                    NewAccount.District__c != OldAccount.District__c || NewAccount.ParentId != OldAccount.ParentId)
                {               
                    //to prevent validation rule in the trigger context               
                    AccountsIDs.add(NewAccount.ID);
                    
                    if(NewAccount.ParentId != OldAccount.ParentId) 
                    { 
                        if(OldAccount.ParentId != null)
                        {
                            AccountsIDs.add(OldAccount.ParentId); 
                        }                      
                    }
                }
            }
        }
        
        for(Account_Hierarchy_Rolldown__c ahp: AccountHierarchyProfileIdsMap.values())
        {
            //ProfileIdSet.add(ahp.Profile_Id__c);
            // this should filter the profile's that are allowed to change field in hierarchy
            if(ahp.All_Profiles_Allowed__c || ahp.Profile_Id__c == userInfo.getProfileId()) 
            { 
                FieldSetForCurrentProfile.add(ahp.Field_Name__c); 
            }            
        }  
        
        system.debug(FieldSetForCurrentProfile);
        
        map<string, list<sobject>> newAccountsByChangedField = new map<string, list<sobject>>();
        Boolean AllowForFieldUpdate = false;
        
        //set of fields with permission to edit in custom settings for current profile are sent to future method if those are not null or empty
        if(FieldSetForCurrentProfile != null && !FieldSetForCurrentProfile.isEmpty()) 
        {                   
            list<sobject> newAddToMap;         
            
            for(string s: FieldSetForCurrentProfile)
            {
                newAddToMap = new list<Account>();  
                
                for(Account NewAccount: newAccounts)
                {
                    if(Trigger.isInsert)
                    {
                        newAddToMap.add(newAccount);                        
                        AllowForFieldUpdate = true; 
                    }
                    else
                    {
                        Account OldAccount = oldMap.get(NewAccount.Id);
                        
                        if (NewAccount.get(s) != OldAccount.get(s) ||
                            NewAccount.get('Corporation__c') != OldAccount.get('Corporation__c') ||
                            NewAccount.get('Group__c') != OldAccount.get('Group__c') ||
                            NewAccount.get('District__c') != OldAccount.get('District__c'))
                        {   
                            newAddToMap.add(newAccount);                        
                            AllowForFieldUpdate = true;
                        }
                    }
                }            
                newAccountsByChangedField.put(s, newAddToMap); // for the current profile only            
            }
        }        
        
        DS_EncapsulationHelperClass EncapsulateMap = new DS_EncapsulationHelperClass(newAccountsByChangedField);
        String serialize = JSON.serialize(EncapsulateMap);
        system.debug(newAccountsByChangedField);
        //String serialize = JSON.serialize(newAccountsByChangedField);
        
        Boolean NotAsynchronousProcess = !system.isFuture() && !system.isBatch() && !system.isScheduled();
        
        if ( (All_CheckRecursive.runCodeBlockOnce('AccountHierarchyFieldUpdates20150330') || Test.isRunningTest()) && 
            NotAsynchronousProcess && (!AccountsIDs.isEmpty() || AllowForFieldUpdate))
        {
            DS_AccountHierarchyFieldUpdates.AccountHierarchyFutureUpdates(serialize, AccountsIDs, AllowForFieldUpdate);
        }        
    }
    
    @future//(limits = '2XSOQL') optional, may be needed in the future
    public static void AccountHierarchyFutureUpdates(string serialize, list<ID> AccountsIDs, boolean AllowForFieldUpdate)
    {         
        // Execute this code only if PrentId or Corporation__c or Group__c or District__c changes
        //Beginning of DS_TotalAccountsInHierarchy_Future 
        boolean TotalAccountsInHierarchy_Future = (AccountsIDs != null && !AccountsIDs.isEmpty());
        
        system.debug(AccountsIDs);
        
        if(TotalAccountsInHierarchy_Future)
        {
            DS_AccountHierarchyFieldUpdates.AccountHierarchyTotalSiteCount(AccountsIDs);
        }//end of DS_TotalAccountsInHierarchy_Future
        
        DS_EncapsulationHelperClass CurrentTriggerPack = null;
        
        // deserialize and assign the values to local variables       
        CurrentTriggerPack = (DS_EncapsulationHelperClass)JSON.deserialize(serialize, DS_EncapsulationHelperClass.class);
        map<string, list<sobject>> FieldToParentAccountlist = CurrentTriggerPack.newSObjectListByObject;
        //map<string, list<sobject>> FieldToParentAccountlist = (map<string, list<sobject>>)JSON.deserialize(serialize, map<string, list<sobject>>.class);
                
        // Beginning of DS_AccountHierarchyFieldUpdates
        boolean AccountHierarchyFieldUpdates = (
            AllowForFieldUpdate && FieldToParentAccountlist != null && !FieldToParentAccountlist.isEmpty()
        );
        
        system.debug(AccountHierarchyFieldUpdates);
        system.debug(FieldToParentAccountlist);
        if(AccountHierarchyFieldUpdates)
        {
            DS_AccountHierarchyFieldUpdates.HierarchyFiledUpdates(FieldToParentAccountlist);
        } // End Of DS_AccountHierarchyFieldUpdates
    }  
    
    public static void AccountHierarchyTotalSiteCount(List<ID> AccountsIDs)
    {
        // below method organizes the childern accounts with filling the corp, group and district fields with relevant values
        DS_AccountHierarchyFieldUpdates.OrganizeChildCorporationDistrictAndGroup(AccountsIDs);
        
        //system.debug(AccountsIDs);
        
        map<Id, Id> ChildAccountIdToParentIdMap = AccountHierarchyTools.TopParentAccountIdsByAccountId(AccountsIDs);
        map<ID, Account> FinalUpdateMap = new map<ID, Account>();
        
        map<ID, Account> HierarchyMembersMap;
        set<ID> ParentIDset;
        
        
        //system.debug(ChildAccountIdToParentIdMap);
        
        if(ChildAccountIdToParentIdMap != null && !ChildAccountIdToParentIdMap.isEmpty())
        {
            ParentIDset = new set<ID>(ChildAccountIdToParentIdMap.values());            
        }  
        
        //system.debug(ParentIDset);
        
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
        
        //system.debug(HierarchyMembersMap);
        
        map<ID, List<Account>> HierarchyMembersSortedMap = new map<ID, List<Account>>();
        
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
                            HierarchyMembersSortedMap.put(PId, new List<Account>{CurrentAccount});
                        }
                        else{ HierarchyMembersSortedMap.get(PId).add(CurrentAccount); }
                    }
                    
                    if((CurrentAccount.Corporation__c == null && CurrentAccount.Group__c != null &&  PId == CurrentAccount.Group__c) ||
                      PId == CurrentAccount.Id)
                    {
                        if(HierarchyMembersSortedMap.get(PId) == null)
                        { 
                            HierarchyMembersSortedMap.put(PId, new List<Account>{CurrentAccount});
                        }
                        else{ HierarchyMembersSortedMap.get(PId).add(CurrentAccount); }                            
                    }
                    
                }
                
            }
        }
        
        list<Account> NoCorpGrpDist;        
        
        if(HierarchyMembersSortedMap != null && !HierarchyMembersSortedMap.isEmpty())
        {
            for(ID id: HierarchyMembersSortedMap.keySet())
            { 
                NoCorpGrpDist = new list<Account>();
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
                
                //system.debug(NoCorpGrpDist);
                
                if(NoCorpGrpDist != null && !NoCorpGrpDist.isEmpty())
                {
                    TotalAccountsCount = NoCorpGrpDist.size();
                }
                
               // system.debug(TotalAccountsCount);
                
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
        
        //system.debug(FinalUpdateMap);
        
        if(FinalUpdateMap != null && !FinalUpdateMap.isEmpty())
        {
            Database.Update (FinalUpdateMap.values(), false);
        }
        
    }
    
    public static void OrganizeChildCorporationDistrictAndGroup(List<ID> AccountsIDs)
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
        
        //system.debug(SiteTypeMapByChildId);
        //system.debug(ChildAccountMap);
        
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
                    
                    //system.debug(CorporateAccount);
                    //system.debug(CurrentChildAccount.Name);
                    //system.debug(CurrentChildAccount);
                    
                    
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
    
    public static void HierarchyFiledUpdates(map<string, list<sobject>> FieldToParentAccountlist)
    {
        
        list<sObject> newAccountList;
        
        system.debug(FieldToParentAccountlist);
        
        map<ID, Account> TobeUpdatedAccountMap = new map<ID, Account>();
        map<ID, WebID__c> TobeUpdatedWebIDMap = new map<ID, WebID__c>();           
        
        for(string Field: FieldToParentAccountlist.keySet())
        { 
            system.debug(Field);
            system.debug(FieldToParentAccountlist.keySet());
            
            newAccountList = new list<sobject>();
            newAccountList = FieldToParentAccountlist.get(Field);
            
            if(newAccountList.isEmpty())
            {
                continue;
            }            
            
            map<Id, sObject> ParentIdToRecordMap = new map<Id, sObject>(); // to be set after top account query            
            
            // get custom settings for the CAM field profiles and check if the current user profile Id matches with the Custom settings
            Map<String, Account_Hierarchy_Rolldown__c> AccountHierarchyProfileIdsMap = Account_Hierarchy_Rolldown__c.getAll();
            
            //separate map into field versus set of profile Ids
            Map<String, Set<object>> AccountHierarchyprofileIdToFieldsMap = new Map<String, Set<object>>();
            set<object> FieldSet = new set<object>();
            
            Map<string, Account_Hierarchy_Rolldown__c> FieldNameToAHProfileIdsRecord = new map<string, Account_Hierarchy_Rolldown__c>();
            
            Set<String> QueryFieldSet = new Set<String>();
            QueryFieldSet.add(Field);
            
            map<string, string> ProfileIdToQueryCondition = new map<string, string>();
            
            string CurrentProfileIdString = userInfo.getProfileId();
            
            for(Account_Hierarchy_Rolldown__c ahp: AccountHierarchyProfileIdsMap.values())
            {        
                if(ahp.All_Profiles_Allowed__c || ahp.profile_Id__c == CurrentProfileIdString)
                {
                    FieldSet.add(ahp.Field_Name__c);
                }
                
                AccountHierarchyProfileIdToFieldsMap.put(CurrentProfileIdString, FieldSet); 
                
                
                FieldNameToAHProfileIdsRecord.put(ahp.Field_Name__c, ahp);
                ProfileIdToQueryCondition.put(
                    (ahp.All_Profiles_Allowed__c == true ? CurrentProfileIdString : ahp.Profile_Id__c) + ahp.Field_Name__c, ahp.Query_Condition__c);
            } 
            //system.debug(ProfileIdToQueryCondition);
            //system.debug(AccountHierarchyProfileIdToFieldsMap);
            //system.debug(QueryFieldSet);          
            
            List<String> FieldList = new List<String>(); FieldList.addAll(QueryFieldSet);
            String FieldString = ALL_UtilitiesString.ListToEnclosedCSV(FieldList, '');
            String QueryFieldString = '';
            
            if(FieldString != null && FieldString.trim() != '') { 
                QueryFieldString = FieldString + ', '; }
            
            system.debug(QueryFieldString);
            
            list<Id> AlteredAccountIdsList = new list<Id>();
            for(sObject a: newAccountList) { AlteredAccountIdsList.add(a.Id); }
            
            system.debug(AlteredAccountIdsList);
            
            // collect TopParentAccount IDs from AccountHierarchyTools
            map<Id, Id> ChildAccountIdToParentIdMap = new map<Id, Id>();
            
            if(AlteredAccountIdsList != null && !AlteredAccountIdsList.isEmpty()) {
                ChildAccountIdToParentIdMap = AccountHierarchyTools.TopParentAccountIdsByAccountId(AlteredAccountIdsList); }
            
            if(ChildAccountIdToParentIdMap != null && !ChildAccountIdToParentIdMap.isEmpty()) 
            {
                String TopParentAccountsToQuery = ALL_UtilitiesString.ListToParenthesesCsv(ChildAccountIdToParentIdMap.values()); 
                
                // query TopParentAccounts for the fields from 
                
                String ParentQueryString = 'Select Id, Name, Account_Number__c, Status__c, Site_Type__r.Name, Corporation__c, Group__c, Out_of_Business__c, Duplicate__c, ' 
                    + QueryFieldString + '(select Id, Name, Client_Account_Manager__c From Sites__r) ' 
                    + 'From Account ' 
                    + 'Where ID IN ' + TopParentAccountsToQuery + ' AND Out_of_Business__c = false AND Duplicate__c = false';
                
                system.debug(ParentQueryString);
                
                newAccountList = database.query(ParentQueryString);
                
                if(newAccountList != null && !newAccountList.isEmpty())
                {
                    for(sObject a : newAccountList) 
                    { 
                        ParentIdToRecordMap.put(a.Id, a); 
                    } 
                }
            }
            
            // if there are no accounts to process
            if(ParentIdToRecordMap == null || ParentIdToRecordMap.isEmpty()) 
            {
                continue; // not sure return or continue at this point, discuss with Matt
            }
            
            //declare a map that points from field name to account id set to collect all the account ids of the eligible accounts for field update
            map<string, set<Id>> FieldNameToParentIdSet = new map<string, set<Id>>();
            map<string, set<Id>> FieldNameToIdSetForChildAccounts = new map<string, set<Id>>();
            set<Id> ParentAccountIdSet;
            set<Id> ChildAccountIdSet;
            
            for(integer i=0; i<FieldList.size(); i++)
            { 
                ParentAccountIdSet = new set<Id>();               
                
                for(SObject a: newAccountList)
                { 
                    if(AccountHierarchyprofileIdToFieldsMap.keySet() != null 
                       && AccountHierarchyprofileIdToFieldsMap.keySet().Contains(userInfo.getProfileId()))
                    {
                        // if profile allowed                    
                        if(AccountHierarchyprofileIdToFieldsMap.get(userInfo.getProfileId()).contains(FieldList[i]))
                        { 
                            ParentAccountIdSet.add(a.Id);
                        }
                    }             
                }                
                FieldNameToParentIdSet.put(FieldList[i], ParentAccountIdSet);                
            }
            
            Set<Id> ConsolidatedParentAccIds = new Set<Id>();
            
            for(string FieldName: FieldNameToParentIdSet.keySet())
            {
                ConsolidatedParentAccIds.addAll(FieldNameToParentIdSet.get(FieldName));
            }
            
            system.debug(ConsolidatedParentAccIds);
            
            List<Id> ParentAccIdsList = new List<Id>();
            
            ParentAccIdsList.addAll(ConsolidatedParentAccIds);
            
            if(ParentAccIdsList != null && !ParentAccIdsList.isEmpty()) 
            {
                List<Account> TobeUpdatedAccounts = new List<Account>();
                
                String ParentAccIdsString = ALL_UtilitiesString.ListToParenthesesCsv(ParentAccIdsList);
                
                //system.debug(ParentAccIdsString);                
                string QueryConditions = ProfileIdToQueryCondition.get(userInfo.getProfileId() + Field);
                if(QueryConditions == null){ QueryConditions = '';}
                
                //system.debug(Field + ':-' + QueryConditions);
                
                if(ParentAccIdsString != null && ParentAccIdsString.trim() != '' && ParentAccIdsString.trim() != '()') 
                { 
                    String ChildQueryString = 'Select Id, Name, Account_Number__c, Status__c, Site_Type__r.Name, Corporation__c, Group__c, Out_of_Business__c, Duplicate__c, ' 
                        + QueryFieldString + '(select Id, Name, Client_Account_Manager__c From Sites__r) ' 
                        + 'From Account ' 
                        + 'Where (Corporation__c IN ' + ParentAccIdsString + ' OR Group__c IN ' + ParentAccIdsString + ') '
                        + 'AND Out_of_Business__c = false AND Duplicate__c = false '
                        +  QueryConditions; 
                    
                    //system.debug(ChildQueryString);
                    
                    
                    TobeUpdatedAccounts = Database.query(ChildQueryString);
                    
                    // separate all the child accounts that are to be updated with parent fields
                    // create a map of field that points to a map of the Parent Account Id and the corresponding child Accounts that are needed to be updated with same Parent field
                    map<string, map<Id, set<Account>>> FieldToMapOfParentIdToChildAccSet = new map<string, map<Id, set<Account>>>();               
                    
                    // loop through each of the child account and catch that and put it in Map if that satisfies the conditions       
                    for(string FieldName: FieldNameToParentIdSet.keySet())
                    {
                        map<Id, set<Account>> ParentIdToChildAccountMap = new map<Id, set<Account>>();
                        
                        for(Id AccountId: FieldNameToParentIdSet.get(FieldName))
                        {               
                            set<Account> childAccountSet = new set<Account>();
                            
                            for(Account ChildRecord: TobeUpdatedAccounts)
                            {
                                if(ChildRecord.Corporation__c == AccountId || ChildRecord.Group__c == AccountId)
                                {                                                        
                                    childAccountSet.add(ChildRecord);                                
                                }
                            }                
                            ParentIdToChildAccountMap.put(AccountId, childAccountSet);                
                        }
                        
                        FieldToMapOfParentIdToChildAccSet.put(FieldName, ParentIdToChildAccountMap);
                    }
                    
                    //system.debug(FieldToMapOfParentIdToChildAccSet);
                    
                    for(string FieldName: FieldToMapOfParentIdToChildAccSet.keySet())
                    {     
                        for(Id parentId: FieldToMapOfParentIdToChildAccSet.get(FieldName).keySet())
                        {
                            for(Account ChildAccount: FieldToMapOfParentIdToChildAccSet.get(FieldName).get(parentId))
                            {
                                if(TobeUpdatedAccountMap.containsKey(ChildAccount.ID))
                                {
                                    TobeUpdatedAccountMap.get(ChildAccount.ID).put(FieldName, ParentIdToRecordMap.get(parentId).get(FieldName)); 
                                }
                                else
                                {
                                    ChildAccount.put(FieldName, ParentIdToRecordMap.get(parentId).get(FieldName));
                                    TobeUpdatedAccountMap.put(ChildAccount.ID, ChildAccount);
                                }
                                
                                if(FieldNameToAHProfileIdsRecord.get(FieldName).Update_WebID_Field__c != null)
                                {
                                    list<WebId__c> ChildWebIds = ChildAccount.sites__r;
                                    for(WebId__c w: ChildWebIds)
                                    {  
                                        if(TobeUpdatedWebIDMap.containsKey(w.ID))
                                        {
                                            TobeUpdatedWebIDMap.get(w.ID).put(
                                                FieldNameToAHProfileIdsRecord.get(FieldName).Update_WebID_Field__c, ParentIdToRecordMap.get(parentId).get(FieldName));
                                        }
                                        else
                                        {
                                            w.put(FieldNameToAHProfileIdsRecord.get(FieldName).Update_WebID_Field__c, ParentIdToRecordMap.get(parentId).get(FieldName));
                                            TobeUpdatedWebIDMap.put(w.ID, w);
                                        }
                                    }                                                               
                                }                                    
                            }  
                        }    
                    } // end for FieldToMapOfParentIdToChildAccSet map                          
                }
            }
        } 
        
        if(TobeUpdatedAccountMap != null && !TobeUpdatedAccountMap.isEmpty()){ database.update(TobeUpdatedAccountMap.values(), false); }
        if(TobeUpdatedWebIDMap != null && !TobeUpdatedWebIDMap.isEmpty()){ database.update(TobeUpdatedWebIDMap.values(), false); }
        
    }
}