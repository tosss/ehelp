//2016-11-10 ragashalini.koka@cdk.com Created the class for RQ-08164
//2016-11-22 ragashalini.koka@cdk.com added code to update term dates for RQ-08233

public class CPQ_NSA_Handler {
    
    public static void setMainNSA(List<NSA__c> oldList, List<NSA__c> newList, Boolean isInsert) {
        
        Set<Id> priceProtectionAccountIdSet = new Set<Id>();
        Set<Id> priceProtectionNSAIdSet = new Set<Id>();
        Id priceProtectionRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('NSA__c', 'Price Protection');
        
        for(Integer i = 0;i < newList.size();i++) {
            NSA__c NSARecord = newList[i];
            if((NSARecord.RecordTypeId == priceProtectionRecordTypeId) && (NSARecord.Main_NSA__c == null || (!isInsert && oldList[i].Account__c != NSARecord.Account__c))) {
                
                priceProtectionNSAIdSet.add(NSARecord.Id);
                priceProtectionAccountIdSet.add(NSARecord.Account__c);
                
            }
            
            
        }
        priceProtectionAccountIdSet.remove(null);
        
        List<NSA__c> NSARecordsList = [SELECT Id, Account__c FROM NSA__c WHERE RecordType.Name = 'NSA' AND Account__c= :priceProtectionAccountIdSet];
        Map<Id,Id> accountToNSAMap = new Map<Id,Id>();
        
        for(NSA__c record : NSARecordsList) {
            accountToNSAMap.put(record.Account__c, record.Id);
        }
        
        //populates Main_NSA__c in records of RecordType Price Protection
        for(NSA__c record : newList) {
            
            if(isInsert || priceProtectionNSAIdSet.contains(record.Id)) {
                record.Main_NSA__c = accountToNSAMap.get(record.Account__c);
            }
        }
        
    }
    
    private static Map<Id,Id> getAccountToNSARecordMap(List<NSA__c> NSARecordsList) {
        
        Map<Id,Id> accountToNSARecordsMap = new Map<Id,Id>();
        
        for(NSA__c nsa : NSARecordsList) {
            accountToNSARecordsMap.put(nsa.Account__c, nsa.Id);
        }
        
        return accounttoNSARecordsMap;
        
    }
    
    public static void setNSAOnAccount(List<NSA__c> oldList, List<NSA__c> newList, Boolean isInsert) {
        try {
            Id priceProtectionRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('NSA__c', 'Price Protection');
            Id NSARecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('NSA__c', 'NSA');
            
            Map<Id,Account> accountMap = new map<Id,Account>();
            Map<String,Set<Id>> recordTypeToIdSet = new Map<String,Set<Id>>();
            
            recordTypeToIdSet.put('Price Protection', new Set<Id>());
            recordTypeToIdSet.put('NSA', new Set<Id>());
            
            //maintains the list of old Accounts to set the Price Protection and NSA fields on Account to null
            if(!isInsert) {
                
                for(Integer i = 0;i < oldList.size();i++) {
                    if(oldList[i].Account__c != null && newList[i].Account__c != oldList[i].Account__c) {
                        if(oldList[i].RecordTypeId == priceProtectionRecordTypeId) {
                            Set<Id> recIdSet = recordTypeToIdSet.get('Price Protection');
                            recIdSet.add(oldList[i].Account__c);
                        }
                        else if(oldList[i].RecordTypeId == NSARecordTypeId) {
                            Set<Id> recIdSet = recordTypeToIdSet.get('NSA');
                            recIdSet.add(oldList[i].Account__c);
                        }
                    }
                }
            }
            
            
            //updates the Account with the fields and removes the accountId from recordTypeToIdSet if same accounts are in new list
            for(Integer i = 0;i < newList.size();i++) {
                Id accId = newList[i].Account__c;
                
                if(accId != null && (isInsert || oldList[i].Account__c != accId)) {
                    
                    Account acc = accountMap.containsKey(accId) ? accountMap.get(accId) : new Account();
                    acc.Id = accId;
                    
                    if(newList[i].RecordTypeId == priceProtectionRecordTypeId) {
                        acc.Price_Protection_NSA__c = newList[i].Id;
                        recordTypeToIdSet.get('Price Protection').remove(accId);
                    }
                    else if(newList[i].RecordTypeId == NSARecordTypeId) {
                        acc.NSA__c = newList[i].Id;
                        recordTypeToIdSet.get('NSA').remove(accId);
                    }
                    
                    accountMap.put(accId, acc);
                }
                
                
            }
            //sets null values on Account for the NSA fields
            for(String recordTypeName : recordTypeToIdSet.keySet()) {
                for(Id accId : recordTypeToIdSet.get(recordTypeName)) {
                    Account acc = accountMap.containsKey(accId) ? accountMap.get(accId) : new Account();
                    acc.Id = accId;
                    if(recordTypeName == 'Price Protection') {
                        acc.Price_Protection_NSA__c = null;
                    }
                    else if(recordTypeName == 'NSA') {
                        acc.NSA__c = null;
                    }
                    accountMap.put(accId, acc); 
                }
            }
            
            update accountMap.values();
            
            Set<Id> newNSAIdSet = new Set<Id>();
            Set<Id> oldNSAIdSet = new Set<Id>();
            
            updateMainNSARecords(oldList, newList, isInsert, NSARecordTypeId);
        }
        catch(Exception exp) {
            System.debug('exp : ' + exp.getLineNumber() + exp.getMessage());
        }
    }
    
    private static void updateMainNSARecords(List<NSA__c> oldList, List<NSA__c> newList, Boolean isInsert, Id nsaRecordTypeId) {
        Set<Id> allIdSet = new Set<Id>();
        Set<Id> nsaIdSet = new Set<Id>();
        for(Integer i = 0;i < newList.size();i++) {
            if(newList[i].RecordTypeId == nsaRecordTypeId && (isInsert || (!isInsert && newList[i].Account__c != oldList[i].Account__c))) {
                allIdSet.add(newList[i].Account__c);
                if(!isInsert) {
                    allIdSet.add(oldList[i].Account__c);
                }
                nsaIdSet.add(newList[i].Id);
            }
        }
        
        
        List<NSA__c> NSARecordsList = [SELECT Id,Account__c FROM NSA__c WHERE RecordType.Name = 'Price Protection' AND Account__c IN :allIdSet AND Id NOT IN :nsaIdSet];
        
        Map<Id,Id> accountToNSAMap = getAccountToNSARecordMap(newList);
        
        for(NSA__c nsaRecord : NSARecordsList) {
            nsaRecord.Main_NSA__c = accountToNSAMap.get(nsaRecord.Account__c);
        }
        
        update NSARecordsList;
        
    }
    
    public static void updateTermDates(List<NSA__c> oldList, List<NSA__c> newList, Boolean isInsert) {
        try {
            System.debug('In update term dates');
            Id priceProtectionRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('NSA__c', 'Price Protection');
            Set<Id> accountIdSet = new Set<Id>();
            
            for(Integer i = 0;i < newList.size();i++) {
                if(isInsert || (newList[i].RecordTypeId == priceProtectionRecordTypeId && newList[i].RecordTypeId  != oldList[i].RecordTypeId)) {
                    accountIdSet.add(newList[i].Account__c);
                }
            }
            if(accountIdSet.size() > 0) {
                Map<Id,Id> childToParentIdMap = AccountHierarchyTools.TopParentAccountIdsByAccountId(new List<Id>(accountIdSet));
                Set<Id> matchedAccountIdSet = new Set<Id>();
                Set<Id> unmatchedAccountIdSet = new Set<Id>();
                
                for(Integer i = 0;i < newList.size();i++) {
                    Id accId = newList[i].Account__c;
                    if(isInsert || (newList[i].RecordTypeId == priceProtectionRecordTypeId && newList[i].RecordTypeId  != oldList[i].RecordTypeId)) {
                        if(accId == childToParentIdMap.get(accId)) {
                            matchedAccountIdSet.add(accId);
                        }
                        else {
                            unmatchedAccountIdSet.add(accId);
                        }
                    }
                    
                }
                
                List<Account> accountList = [SELECT Id FROM Account WHERE Id IN :matchedAccountIdSet];
                Map<Id,List<Account>> parentToChildAccountMap = AccountHierarchyTools.ParentToChildAccountsMap(accountList);
                Map<Id,Set<Id>> parentToChildIdMap = getChildIds(parentToChildAccountMap);
                Map<Id,Set<Id>> topParentToChildSetMap = new Map<Id,Set<Id>>();
                
                for(Id accId : matchedAccountIdSet) {
                    topParentToChildSetMap.put(accId, parentToChildIdMap.get(accId));
                }
                getTopAccountHierarchy(topParentToChildSetMap, matchedAccountIdSet, parentToChildIdMap);
                
                Set<Id> allAccountIdSet = new Set<Id>();
                for(String recId : topParentToChildSetMap.keySet()) {
                    allAccountIdSet.addAll(topParentToChildSetMap.get(recId));
                }
                allAccountIdSet.addAll(unmatchedAccountIdSet);
                
                List<System_at_Dealership__c> dealershipRecordsList = [SELECT Account__c, Install_Date__c, Contract_Term_Date__c 
                                                                       FROM System_at_Dealership__c
                                                                       WHERE System_Type__c = 'DMS' AND Account__c IN :allAccountIdSet];
                
                Map<Id,System_at_Dealership__c> accountToDealershipMap = getAccountToDealershipMap(dealershipRecordsList);
                Map<Id,System_at_Dealership__c> accountToMinDateDealershipMap = new Map<Id,System_at_Dealership__c>();
                
                accountToMinDateDealershipMap.putAll(getDealershipRecordsWithMinInstallDateInHierarchy(accountToDealershipMap, topParentToChildSetMap));
                for(Id accId : unmatchedAccountIdSet) {
                    if(accountToDealershipMap.containsKey(accId)) {
                        accountToMinDateDealershipMap.put(accId, accountToDealershipMap.get(accId));
                    }
                }
                
                //populates the NSA Records with install date and contract term date
                for(Integer i = 0;i < newList.size();i++) {
                    Id accId = newList[i].Account__c;
                    if((isInsert || (newList[i].RecordTypeId == priceProtectionRecordTypeId && newList[i].RecordTypeId  != oldList[i].RecordTypeId)) 
                       && accountToMinDateDealershipMap.containsKey(accId)) {
                           System_at_Dealership__c dealershipRecord = accountToMinDateDealershipMap.get(accId);
                           if(dealershipRecord.Install_Date__c != null) {
                               newList[i].Term1_Start__c = dealershipRecord.Install_Date__c;
                               newList[i].Term1_End__c = dealershipRecord.Contract_Term_Date__c;
                           }
                       }
                    
                }
            }
        }
        catch(Exception exp) {
            System.debug('exp in updateTermDates : ' + exp.getLineNumber() + exp.getMessage());
        }
    }
    
    //returns a map of parent Id to set of child Ids
    public static Map<Id,Set<Id>> getChildIds(Map<Id,List<Account>> parentToChildAccountMap) {
        Map<Id,Set<Id>> parentToChildIdMap = new Map<Id,Set<Id>>();
        
        for(Id parentId : parentToChildAccountMap.keySet()) {
            Map<Id,Account> accountMap = new Map<Id,Account>(parentToChildAccountMap.get(parentId));
            parentToChildIdMap.put(parentId, accountMap.keySet());
        }
        
        return parentToChildIdMap;
        
    }
    
    public static void getTopAccountHierarchy(Map<Id,Set<Id>>topParentToChildSetMap, Set<Id> accIdSet, Map<Id,Set<Id>> parentToChildIdMap) {
        
        for(Id accId : topParentToChildSetMap.keySet()) {
            
            Set<Id> childIdSet = new Set<Id>();
            childIdSet.add(accId);
            childIdSet.addAll(getAllChildren(parentToChildIdMap, topParentToChildSetMap.get(accId)));
            topParentToChildSetMap.put(accId, childIdSet);
            
        }
        
        System.debug('topParentToChildSetMap' + topParentToChildSetMap);
    }
    
    private static Set<Id> getAllChildren(Map<Id,Set<Id>> parentToChildIdMap, Set<Id> accIdSet ) {
        Set<Id> recIdSet = new Set<Id>(); 
        if(accIdSet != null) {
            recIdSet.addAll(accIdSet);
            for(Id accId : accIdSet) {
                recIdSet.addAll(getAllChildren(parentToChildIdMap, parentToChildIdMap.get(accId)));
                
            }
        }
        return recIdSet;
        
    }
    
    //forms a map of Account To Dealership Record
    private static Map<Id,System_at_Dealership__c> getAccountToDealershipMap(List<System_at_Dealership__c> dealershipRecordsList) {
        Map<Id,System_at_Dealership__c> accountToDealershipMap = new Map<Id,System_at_Dealership__c>();
        for(System_at_Dealership__c dealershipRecord : dealershipRecordsList) {
            accountToDealershipMap.put(dealershipRecord.Account__c, dealershipRecord);
        }
        return accountToDealershipMap;
        
    }
    
    //identifies the Dealership with oldest Install Date for the hierarchy of Accounts
    private static Map<Id,System_at_Dealership__c> getDealershipRecordsWithMinInstallDateInHierarchy(Map<Id,System_at_Dealership__c> accountToDealershipMap, Map<Id,Set<Id>> topParentToChildSetMap ) {
        Map<Id,System_at_Dealership__c> accountToMinDateDealershipMap = new Map<Id,System_at_Dealership__c>();
        for(Id accId : topParentToChildSetMap.keySet()) {
            for(Id childId : topParentToChildSetMap.get(accId)) {
                if(accountToDealershipMap.containsKey(childId)) {
                    if(!accountToMinDateDealershipMap.containsKey(accId)) {
                        accountToMinDateDealershipMap.put(accId, accountToDealershipMap.get(childId));
                    }
                    else {
                        System_at_Dealership__c dealershipRecord = accountToMinDateDealershipMap.get(accId);
                        System_at_Dealership__c currentDealershipRecord = accountToDealershipMap.get(childId);
                        if(currentDealershipRecord.Install_Date__c < dealershipRecord.Install_Date__c) {
                            accountToMinDateDealershipMap.put(accId, currentDealershipRecord);
                        }
                    }
                }
            }
        }
        return accountToMinDateDealershipMap;
    }
}