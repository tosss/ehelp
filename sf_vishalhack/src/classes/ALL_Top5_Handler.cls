//2016-12-26 - ragashalini.koka@cdk.com - RQ-08369 - Created this class to update the manger fields on Top_5__c
//2016-01-31 - vishal.bandari@cdk.com   - RQ-07865 - Added afterInsert , afterUpdate and afterDelete methods
//2016-01-31 - ragashalini.koka@cdk.com - RQ-08369 - Added submitForApproval, restoreStatus methods
//2017-03-27 - ragashalini.koka@cdk.com - RQ-08784 - Added Sharing functionality for the Top 5 Records
public class ALL_Top5_Handler {
    
    //2016-12-26 - ragashalini.koka@cdk.com - RQ-08369 - Updates the manger fields on Top_5__c
    public static void updateManagerFields(List<Top_5__c> oldList, List<Top_5__c> newList, Boolean isInsert) {
        
        Set<Id> userIdSet = new Set<Id>();
        
        for(Integer i = 0;i < newList.size();i++) {
            if(isInsert || oldList[i].OwnerId != newList[i].OwnerId) {
                userIdSet.add(newList[i].OwnerId);
            }
        }
        
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, ManagerId, Manager.ManagerId FROM User WHERE Id IN : userIdSet]);
        
        for(Integer i = 0;i < newList.size();i++) {
            Top_5__c top5Rec = newList[i];
            
            if(isInsert || oldList[i].OwnerId != top5Rec.OwnerId) {
                top5Rec.Owner_Manager__c = userMap.get(top5Rec.OwnerId).ManagerId;
                top5Rec.Owner_Manager_Mgr__c = userMap.get(top5Rec.OwnerId).Manager.ManagerId;
            }
        }
        
    }
    
    //keeps track of the old status value
    /*  public static void storeOldStatusValue(List<Top_5__c> oldList, List<Top_5__c> newList) {

for(Integer i = 0;i < newList.size();i++) {
if(newList[i].Status__c != oldList[i].Status__c) {
newList[i].Old_Status__c = oldList[i].Status__c;
}

}
}*/
    
    //submits the record for approval process if the criteria matches
    public static void submitForApproval(List<Top_5__c> oldList, List<Top_5__c> newList, Boolean isInsert) {
        
        List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest>();
        
        for(Integer i = 0;i < newList.size();i++) {
            if(newList[i].Status__c == 'Black' && (isInsert || (newList[i].Status__c != oldList[i].Status__c))) {
                Approval.ProcessSubmitRequest request = new Approval.ProcessSubmitRequest();
                request.setObjectId(newList[i].Id);
                request.setProcessDefinitionNameOrId('SLS_Top5_Status_Changev1');
                requestList.add(request);
                
            }
        }
        
        if(requestList.size() > 0) {
            List<Approval.ProcessResult> processResultList = Approval.process(requestList);
            
        }
        
    }
    
    //restores the Status value if the Approval gets Rejected
    public static void restoreStatus(Map<Id,Top_5__c> oldMap, Map<Id,Top_5__c> newMap) {
        Set<Id> rejectedIdSet = new Set<Id>();
        
        for(String recId : newMap.keySet()) {
            Top_5__c newRecord = newMap.get(recId);
            if(oldMap.get(recId).DOS_Reject_Approval__c != newRecord.DOS_Reject_Approval__c && newRecord.DOS_Reject_Approval__c) {
                rejectedIdSet.add(recId);
            }
        }
        
        
        List<Top_5s_Audit__c> top5AuditList = [
            SELECT Id, Status_Previous__c, Top_5s_Lookup__c, Status_Current__c 
            FROM Top_5s_Audit__c 
            WHERE Status_Current__c = 'Black' AND Top_5s_Lookup__c IN :rejectedIdSet
            ORDER BY Createddate desc
        ];
        Set<Id> processedIdSet = new Set<Id>();
        for(Top_5s_Audit__c audit : top5AuditList) {
            Id top5Id = audit.Top_5s_Lookup__c;
            if(!processedIdSet.contains(top5Id) && audit.Status_Current__c != audit.Status_Previous__c) {
                processedIdSet.add(top5Id);
                newMap.get(top5Id).Status__c = audit.Status_Previous__c;
            }
            
        }
    }
    
    
    //2016-01-31 - vishal.bandari@cdk.com   - RQ-07865 - Added afterInsert methods
    public static void afterInsert(List<Top_5__c> top5List)
    {
        List<Top_5s_Audit__c> top5AuditList = new List<Top_5s_Audit__c>();
        Map<Id,Schema.RecordTypeInfo> recordTypesMap = ALL_UtilitiesDescribe.getRecordTypeInfosByID('Top_5__c');
        Map<Id,Id> top5IdToAccIdMap =  new Map<Id,Id>();
        Map<Id,Id> top5IdToOwnerIdMap = new Map<Id,Id>();
        for(Top_5__c top5Obj : top5List)
        {
            top5IdToAccIdMap.put(top5Obj.Id, top5Obj.Account__c);
            top5IdToOwnerIdMap.put(top5Obj.Id, top5Obj.OwnerId);
            Top_5s_Audit__c top5AuditObj = new Top_5s_Audit__c();
            top5AuditObj.Top_5s_Lookup__c = top5Obj.Id;
            top5AuditObj.Account_Current__c = top5Obj.Account__c;
            top5AuditObj.Comments_Current__c = top5Obj.Comments__c;
            top5AuditObj.CDK_Executive_Owner_Current__c = top5Obj.CDK_Executive_Owner__c;
            top5AuditObj.DOS_Confirmed_Current__c = top5Obj.DOS_Confirmed__c;
            top5AuditObj.DOS_Ranking_Current__c = top5Obj.DOS_Ranking__c;
            top5AuditObj.DOS_Response_to_Status_Change_Current__c = top5Obj.DOS_Response_to_Status_Change__c;
            top5AuditObj.Main_Competitor_Current__c = top5Obj.Main_Competitor__c;
            top5AuditObj.RGM_Confirmed_Current__c = top5Obj.RGM_Confirmed__c;
            top5AuditObj.RGM_Ranking_Current__c = top5Obj.RGM_Ranking__c;
            top5AuditObj.Record_Type_Name_Current__c =  recordTypesMap.containsKey(top5Obj.RecordTypeId) ? recordTypesMap.get(top5Obj.RecordTypeId).Name : '';
            top5AuditObj.Status_Current__c = top5Obj.Status__c;
            top5AuditObj.Status_Change_Reason_Current__c = top5Obj.Status_Change_Reason__c;
            top5AuditObj.Rep_Ranking_Current__c = top5Obj.Rep_Ranking__c;
            top5AuditObj.Next_Activity_Date_Current__c = top5Obj.Next_Activity_Date__c;
            top5AuditObj.Next_Activity_Steps_Current__c = top5Obj.Next_Activity_Steps__c;
            top5AuditObj.Action__c = 'I';
            top5AuditList.add(top5AuditObj);
        }
        insert top5AuditList;
        
        Map<Id,Set<Id>> accIdToAccTeamIdMap = ALL_InsertTop5Share_Helper.getAccountTeamIds(new Set<Id>(top5IdToAccIdMap.values()));
        System.debug('accIdToAccTeamIdMap : ' + accIdToAccTeamIdMap);
        ALL_InsertTop5Share_Helper.insertTop5Share(accIdToAccTeamIdMap, top5IdToAccIdMap, top5IdToOwnerIdMap);
    }
    
    
    //2016-01-31 - vishal.bandari@cdk.com   - RQ-07865 - Added afterUpdate methods
    public static void afterUpdate(List<Top_5__c> top5List, Map<Id,Top_5__c> oldTop5Map)
    {
        List<Top_5s_Audit__c> top5AuditList = new List<Top_5s_Audit__c>();
        Map<Id,Schema.RecordTypeInfo> recordTypesMap = ALL_UtilitiesDescribe.getRecordTypeInfosByID('Top_5__c');
        for(Top_5__c top5Obj : top5List)
        {
            Top_5__c oldtop5Obj = oldTop5Map.get(top5Obj.Id);
            if(oldtop5Obj.Account__c != top5Obj.Account__c
               || oldtop5Obj.Comments__c != top5Obj.Comments__c 
               || oldtop5Obj.CDK_Executive_Owner__c != top5Obj.CDK_Executive_Owner__c 
               || oldtop5Obj.DOS_Confirmed__c != top5Obj.DOS_Confirmed__c 
               || oldtop5Obj.DOS_Ranking__c != top5Obj.DOS_Ranking__c 
               || oldtop5Obj.DOS_Response_to_Status_Change__c != top5Obj.DOS_Response_to_Status_Change__c
               || oldtop5Obj.Main_Competitor__c != top5Obj.Main_Competitor__c 
               || oldtop5Obj.RGM_Confirmed__c != top5Obj.RGM_Confirmed__c
               || oldtop5Obj.RGM_Ranking__c != top5Obj.RGM_Ranking__c
               || oldtop5Obj.Rep_Ranking__c != top5Obj.Rep_Ranking__c
               || oldtop5Obj.Next_Activity_Date__c != top5Obj.Next_Activity_Date__c
               || oldtop5Obj.Next_Activity_Steps__c != top5Obj.Next_Activity_Steps__c
               || oldtop5Obj.RecordTypeId != top5Obj.RecordTypeId
               || oldtop5Obj.Status__c != top5Obj.Status__c
               || oldtop5Obj.Status_Change_Reason__c != top5Obj.Status_Change_Reason__c)
            {
                Top_5s_Audit__c top5AuditObj = new Top_5s_Audit__c();
                top5AuditObj.Top_5s_Lookup__c = top5Obj.Id;
                top5AuditObj.Account_Current__c = top5Obj.Account__c;
                top5AuditObj.Account_Previous__c = oldtop5Obj.Account__c;
                top5AuditObj.Comments_Current__c = top5Obj.Comments__c;
                top5AuditObj.Comments_Previous__c = oldtop5Obj.Comments__c;
                top5AuditObj.CDK_Executive_Owner_Current__c = top5Obj.CDK_Executive_Owner__c;
                top5AuditObj.CDK_Executive_Owner_Previous__c = oldtop5Obj.CDK_Executive_Owner__c;
                top5AuditObj.DOS_Confirmed_Current__c = top5Obj.DOS_Confirmed__c;
                top5AuditObj.DOS_Confirmed_Previous__c = oldtop5Obj.DOS_Confirmed__c;
                top5AuditObj.DOS_Ranking_Current__c = top5Obj.DOS_Ranking__c;
                top5AuditObj.DOS_Ranking_Previous__c = oldtop5Obj.DOS_Ranking__c;
                top5AuditObj.DOS_Response_to_Status_Change_Current__c = top5Obj.DOS_Response_to_Status_Change__c;
                top5AuditObj.DOS_Response_to_Status_Change_Previous__c = oldtop5Obj.DOS_Response_to_Status_Change__c;
                top5AuditObj.Main_Competitor_Current__c = top5Obj.Main_Competitor__c;
                top5AuditObj.Main_Competitor_Previous__c = oldtop5Obj.Main_Competitor__c;
                top5AuditObj.RGM_Confirmed_Current__c = top5Obj.RGM_Confirmed__c;
                top5AuditObj.RGM_Confirmed_Previous__c = oldtop5Obj.RGM_Confirmed__c;
                top5AuditObj.RGM_Ranking_Current__c = top5Obj.RGM_Ranking__c;
                top5AuditObj.RGM_Ranking_Previous__c = oldtop5Obj.RGM_Ranking__c;
                top5AuditObj.Record_Type_Name_Current__c = recordTypesMap.containsKey(top5Obj.RecordTypeId) ? recordTypesMap.get(top5Obj.RecordTypeId).Name : '';
                top5AuditObj.Record_Type_Name_Previous__c =recordTypesMap.containsKey(oldtop5Obj.RecordTypeId) ? recordTypesMap.get(oldtop5Obj.RecordTypeId).Name : '';
                top5AuditObj.Status_Current__c = top5Obj.Status__c;
                top5AuditObj.Status_Previous__c = oldtop5Obj.Status__c;
                top5AuditObj.Status_Change_Reason_Current__c = top5Obj.Status_Change_Reason__c;
                top5AuditObj.Status_Change_Reason_Previous__c = oldtop5Obj.Status_Change_Reason__c;
                top5AuditObj.Rep_Ranking_Current__c = top5Obj.Rep_Ranking__c;
                top5AuditObj.Rep_Ranking_Previous__c = oldtop5Obj.Rep_Ranking__c;
                top5AuditObj.Next_Activity_Date_Current__c = top5Obj.Next_Activity_Date__c;
                top5AuditObj.Next_Activity_Date_Previous__c = oldtop5Obj.Next_Activity_Date__c;
                top5AuditObj.Next_Activity_Steps_Current__c = top5Obj.Next_Activity_Steps__c;
                top5AuditObj.Next_Activity_Steps_Previous__c = oldtop5Obj.Next_Activity_Steps__c;
                top5AuditObj.Action__c = 'U';
                top5AuditList.add(top5AuditObj);
            }
        }
        insert top5AuditList;
    }
    
    
    //2016-01-31 - vishal.bandari@cdk.com   - RQ-07865 - Added afterDelete method
    public static void afterDelete(List<Top_5__c> oldTop5List)
    {
        List<Top_5s_Audit__c> top5AuditList = new List<Top_5s_Audit__c>();
        Map<Id,Schema.RecordTypeInfo> recordTypesMap = ALL_UtilitiesDescribe.getRecordTypeInfosByID('Top_5__c');
        for(Top_5__c oldtop5Obj : oldTop5List)
        {
            Top_5s_Audit__c top5AuditObj = new Top_5s_Audit__c();
            top5AuditObj.Top_5s_Lookup__c = null;
            top5AuditObj.Account_Previous__c = oldtop5Obj.Account__c;
            top5AuditObj.Comments_Previous__c = oldtop5Obj.Comments__c;
            top5AuditObj.CDK_Executive_Owner_Previous__c = oldtop5Obj.CDK_Executive_Owner__c;
            top5AuditObj.DOS_Confirmed_Previous__c = oldtop5Obj.DOS_Confirmed__c;
            top5AuditObj.DOS_Ranking_Previous__c = oldtop5Obj.DOS_Ranking__c;
            top5AuditObj.DOS_Response_to_Status_Change_Previous__c = oldtop5Obj.DOS_Response_to_Status_Change__c;
            top5AuditObj.Main_Competitor_Previous__c = oldtop5Obj.Main_Competitor__c;
            top5AuditObj.RGM_Confirmed_Previous__c = oldtop5Obj.RGM_Confirmed__c;
            top5AuditObj.RGM_Ranking_Previous__c = oldtop5Obj.RGM_Ranking__c;
            top5AuditObj.Record_Type_Name_Previous__c =  recordTypesMap.containsKey(oldTop5Obj.RecordTypeId) ? recordTypesMap.get(oldTop5Obj.RecordTypeId).Name : '';
            top5AuditObj.Status_Previous__c = oldtop5Obj.Status__c;
            top5AuditObj.Status_Change_Reason_Previous__c = oldtop5Obj.Status_Change_Reason__c;
            top5AuditObj.Rep_Ranking_Previous__c = oldtop5Obj.Rep_Ranking__c;
            top5AuditObj.Next_Activity_Date_Previous__c = oldtop5Obj.Next_Activity_Date__c;
            top5AuditObj.Next_Activity_Steps_Previous__c = oldtop5Obj.Next_Activity_Steps__c;
            top5AuditObj.Action__c = 'D';
            top5AuditList.add(top5AuditObj);
        }
        insert top5AuditList;
    }
    
}