//2017-05-17- anirudh.singh@cdk.com- Created this class for ALL_Task_Handler and ALL_Event_Handler.
//2017-06-21- anirudh.singh@cdk.com- Added Null check.
public class ALL_TaskEvent_Helper
{
    public static List<sObject> populatePrimaryAccField(List<sObject> sObjectList)
    {
        List<sObject> recsToModifyList=new List<sObject>();
        Map<String, All_SharedContactsActivityRelationships__c> sharedContCSMap=All_SharedContactsActivityRelationships__c.getAll();
        
        //2017-06-21- anirudh.singh@cdk.com- Included the sObjectList!=Null && sObjectList.size()>0 conditions.
        if(sharedContCSMap!=Null && sharedContCSMap.size()>0 && sObjectList!=Null && sObjectList.size()>0)
        {
            Map<String, CSDataRelIdsWrapper> keyPrefixCSDataWrapperMap=new Map<String, CSDataRelIdsWrapper>();
            Map<sObject, Id> filteredRecListRelIdMap=new Map<sObject, Id>();
            processSObjectList(sObjectList, sharedContCSMap, keyPrefixCSDataWrapperMap, filteredRecListRelIdMap);
            
            if(keyPrefixCSDataWrapperMap.size()>0)
            {
                for(String keyPrefix: keyPrefixCSDataWrapperMap.keySet())
                {
                    CSDataRelIdsWrapper wrapperRec=keyPrefixCSDataWrapperMap.get(keyPrefix);
                    List<Id> relIdsList=new List<Id>(wrapperRec.relatedIds);
                    
                    Map<Id, sObject> relatedRecsMap=new Map<Id, sObject>(
                        Database.query(
                            'SELECT '+(wrapperRec.traverseFieldName=='' ? ' Id ' : wrapperRec.traverseFieldName)
                            +' FROM '+wrapperRec.objName
                            +' WHERE Id IN :relIdsList'
                        )
                    );
                    
                    wrapperRec.sObjectsMap.putAll(relatedRecsMap);
                    keyPrefixCSDataWrapperMap.put(keyPrefix, wrapperRec);
                }
                
                for(sObject rec: filteredRecListRelIdMap.keySet())
                {
                    Id relatedId=filteredRecListRelIdMap.get(rec);
                    String keyPrefix=String.valueOf(relatedId).substring(0, 3);
                    CSDataRelIdsWrapper wrapperRec=keyPrefixCSDataWrapperMap.get(keyPrefix);
                    Map<Id, sObject> sObjectsMap=wrapperRec.sObjectsMap;
                    
                    sObject relatedObject=sObjectsMap.get(relatedId);
                    rec.put('Primary_Account__c', (Id)ALL_UtilitiesData.GetDataFromNestedFields(wrapperRec.traverseFieldName, relatedObject));
                    recsToModifyList.add(rec);
                }
            }
        }
        
        return recsToModifyList;
    }
    
    private static void processSObjectList(List<sObject> sObjectList, 
                                           Map<String, All_SharedContactsActivityRelationships__c> sharedContCSMap, 
                                           Map<String, CSDataRelIdsWrapper> keyPrefixCSDataWrapperMap, 
                                           Map<sObject, Id> filteredRecListRelIdMap)
    {
        for(sObject rec: sObjectList)
        {
            if(rec.get('Primary_Account__c')==Null)
            {
                Id recWhatId=(Id)rec.get('WhatId');
                Id recAccId=(Id)rec.get('AccountId');
                Id recWhoId=(Id)rec.get('WhoId');
                
                if(recWhatId!=Null && checkIfCSRecExists(recWhatId, sharedContCSMap, keyPrefixCSDataWrapperMap))
                {
                    filteredRecListRelIdMap.put(rec, recWhatId);
                }
                else if(recAccId!=Null)
                {
                    rec.put('Primary_Account__c', recAccId);
                }
                else if(recWhoId!=Null 
                        && (String.valueOf(recWhoId).substring(0, 3)=='00Q' || String.valueOf(recWhoId).substring(0, 3)=='003') 
                        && checkIfCSRecExists(recWhoId, sharedContCSMap, keyPrefixCSDataWrapperMap))
                {
                    filteredRecListRelIdMap.put(rec, recWhoId);
                }
            }
        }
    }
    
    private static Boolean checkIfCSRecExists(Id idValue, 
                                              Map<String, All_SharedContactsActivityRelationships__c> sharedContCSMap, 
                                              Map<String, CSDataRelIdsWrapper> keyPrefixCSDataWrapperMap)
    {
        Boolean recExists=false;
        String keyPrefix=String.valueOf(idValue).substring(0, 3);
        All_SharedContactsActivityRelationships__c csRec=sharedContCSMap.get(keyPrefix);
        
        if(csRec!=Null)
        {
            String objName=csRec.Object__c;
            CSDataRelIdsWrapper wrapperRec;
            
            if(!keyPrefixCSDataWrapperMap.containsKey(keyPrefix))
            {
                wrapperRec=new CSDataRelIdsWrapper();
                wrapperRec.objName=objName;
                wrapperRec.traverseFieldName=fetchTraverseFieldAPIName(csRec);
                keyPrefixCSDataWrapperMap.put(keyPrefix, wrapperRec);
            }
            
            wrapperRec=keyPrefixCSDataWrapperMap.get(keyPrefix);
            wrapperRec.relatedIds.add(idValue);
            
            keyPrefixCSDataWrapperMap.put(keyPrefix, wrapperRec);
            recExists=true;
        }
        
        return recExists;
    }
    
    private static String fetchTraverseFieldAPIName(All_SharedContactsActivityRelationships__c csRec)
    {
        String fieldAPIName='';
        
        if(String.isNotEmpty(csRec.Field__c) && String.isNotEmpty(csRec.Field_L1__c))
        {
            fieldAPIName+=fetchRelName(csRec.Object__c, csRec.Field__c);
        }
        else if(String.isNotEmpty(csRec.Field__c))
        {
            fieldAPIName+=csRec.Field__c;
        }
        
        if(String.isNotEmpty(csRec.Field_L1__c) && String.isNotEmpty(csRec.Field_L2__c))
        {
            fieldAPIName+='.'+fetchRelName(csRec.Object_L1__c, csRec.Field_L1__c);
        }
        else if(String.isNotEmpty(csRec.Field_L1__c))
        {
            fieldAPIName+='.'+csRec.Field_L1__c;
        }
        
        if(String.isNotEmpty(csRec.Field_L2__c))
        {
            fieldAPIName+='.'+csRec.Field_L2__c;
        }
        
        return fieldAPIName;
    }
    
    private static String fetchRelName(String objAPIName, String fieldAPIName)
    {
        Schema.DescribeSObjectResult objDetail=Schema.describeSObjects(new List<String>{objAPIName})[0];
        Map<String, Schema.SObjectField> fieldMap=objDetail.fields.getMap();
        
        return fieldMap.get(fieldAPIName).getDescribe().getRelationShipName();
    }
    
    //2016-11-02 - ragashalini.koka@cdk.com - update the DS_Service_Connect_Visit__c field on the Account.
    public static void updateServiceConnectVisitTracking(Map<Id, sObject> newMap, String objectName) 
    {
        //2017-06-21- anirudh.singh@cdk.com- Included the newMap!=Null && newMap.size()>0 && String.isNotBlank(objectName) conditions.
        if(newMap!=Null && newMap.size()>0 && String.isNotBlank(objectName))
        {
            String queryTemplate='SELECT {0} FROM {1} WHERE {2}';
            String columns='Id, AccountId, Account.Group__c, DS_Service_Connect_Visit__c';
            Set<Id> recordIdSet=newMap.keySet();
            String condition='Id IN :recordIdSet AND AccountId!=Null';
            String query=String.format(queryTemplate, new List<String>{columns, objectName, condition});
            
            List<sObject> recordsList=Database.query(query);
            
            Set<Id> accountIdSet=new Set<Id>();
            for(sObject record: recordsList)
            {
                if(record.get('DS_Service_Connect_Visit__c')=='Yes')
                {
                    accountIdSet.add(String.valueOf(record.get('AccountId')));
                    try
                    {
                        String groupAccount=String.valueOf(ALL_UtilitiesData.GetDataFromNestedFields('Account.Group__c', record));
                        if(groupAccount!=Null)
                        {
                            accountIdSet.add(groupAccount);
                        }
                    }
                    catch(Exception ex) 
                    {
                        
                    }
                }
            }
            
            if(accountIdSet.size()>0)
            {
                List<Account> accountList=new List<Account>();
                for(String accountId: accountIdSet) 
                {
                    Account acc=new Account();
                    acc.Id=accountId;
                    acc.DS_Service_Connect_Visit__c=true;
                    accountList.add(acc);
                }
                update accountList;
            }
        }
    }
    
    public class CSDataRelIdsWrapper
    {
        public String objName{get; set;}
        public String traverseFieldName{get; set;}
        public Set<Id> relatedIds{get; set;}
        public Map<Id, sObject> sObjectsMap{get; set;}
        
        public CSDataRelIdsWrapper()
        {
            relatedIds=new Set<Id>();
            sObjectsMap=new Map<Id, sObject>();
        }
    }
}