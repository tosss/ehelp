//2016-08-18 - vishal.bandari@cdk.com - RQ-07433:created the class
//2017-01-12 - ragashalini.koka@cdk.com -  RQ-07433 - modified the code based on the changes
public class ALL_CMFInfo_Handler 
{
 
    public static void afterInsert(List<CMF_Info__c> newCMFInfoList) {
        
        Map<Id,String> accountIdToCMFMap = new Map<Id,String>();
        Set<Id> accountIdSet = new Set<Id>();
        for(CMF_Info__c cmfInfoObj : newCMFInfoList) {
            if(cmfInfoObj.SLS_Baseline_CMF_Number__c == cmfInfoObj.Ship_CMF__c && cmfInfoObj.Status__c == 'A') {
                accountIdToCMFMap.put(cmfInfoObj.Account__c, cmfInfoObj.SLS_Baseline_CMF_Number__c);
            }
            else {
                if(!accountIdToCMFMap.containsKey(cmfInfoObj.Account__c)) {
                     accountIdToCMFMap.put(cmfInfoObj.Account__c, null);
                }
            }
        }
        
        processCMFList(accountIdToCMFMap);
        ALL_CMFInfo_Helper.accountChangesFromCMF(accountIdToCMFMap);
        
        
    }
    
    public static void afterUpdate(List<CMF_Info__c> newCMFInfoList, Map<Id,CMF_Info__c> oldCMFInfoMap) {
         Map<Id,String> accountIdToCMFMap = new Map<Id,String>();
        for(CMF_Info__c cmfInfoObj : newCmfInfoList)
        {
            CMF_Info__c oldCMFInfoObj = oldCMFInfoMap.get(cmfInfoObj.Id);
            
            if(cmfInfoObj.SLS_Baseline_CMF_Number__c == cmfInfoObj.Ship_CMF__c 
               && (cmfInfoObj.SLS_Baseline_CMF_Number__c != oldCMFInfoObj.SLS_Baseline_CMF_Number__c
                   || cmfInfoObj.Status__c != oldCMFInfoObj.Status__c  )  && cmfInfoObj.Status__c == 'A') {
                accountIdToCMFMap.put(cmfInfoObj.Account__c, cmfInfoObj.SLS_Baseline_CMF_Number__c);
            }
            else {
                 if(!accountIdToCMFMap.containsKey(cmfInfoObj.Account__c)) {
                     accountIdToCMFMap.put(cmfInfoObj.Account__c, null);
                }
                
            }
            
        }
         processCMFList(accountIdToCMFMap);
        ALL_CMFInfo_Helper.accountChangesFromCMF(accountIdToCMFMap);
    }
    
    private static void processCMFList(Map<Id,String> accountIdToCMFMap) {
       Set<Id> accountIdSet = new Set<Id>();
        for(String accId : accountIdToCMFMap.keySet()) {
            if(accountIdToCMFMap.get(accId) == null) {
                accountIdSet.add(accId);
            }
        }
        
        List<CMF_Info__c> cmfInfoList = [SELECT Id, SLS_Baseline_CMF_Number__c, Account__c,Ship_CMF__c
                                         FROM CMF_Info__c 
                                         WHERE Account__c IN :accountIdSet AND SLS_Baseline_CMF_Number__c != null AND Ship_CMF__c != null AND Status__c='A'];
        
        for(CMF_Info__c cmfInfo : cmfInfoList) {
            if(cmfInfo.SLS_Baseline_CMF_Number__c == cmfInfo.Ship_CMF__c) {
                accountIdToCMFMap.put(cmfInfo.Account__c, cmfInfo.SLS_Baseline_CMF_Number__c);
            }
        }
    }
}