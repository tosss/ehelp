//2017-03-23 ragashalini.koka@cdk.com - Created this class for RQ-08784
public class ALL_InsertTop5Share_Helper
{
    public static Map<Id,Set<Id>> getAccountTeamIds(Set<Id> accIdSet)
    {
        Map<Id,Set<Id>> accountIdToAccTeamIdMap = new Map<Id,Set<Id>>();
        List<Account_Team__c> accountTeamList = [
            SELECT Account__c, Team_Member__c 
            FROM Account_Team__c 
            WHERE Account__c IN :accIdSet AND Team_Role__c LIKE 'Forecasting%'
        ];
        for(Account_Team__c accTeam : accountTeamList)
        {
            Id accId = accTeam.Account__c;
            if(!accountIdToAccTeamIdMap.containsKey(accId)) 
            {
                accountIdToAccTeamIdMap.put(accId, new Set<Id>());
            }
            Set<Id> accTeamIdSet = accountIdToAccTeamIdMap.get(accId);
            accTeamIdSet.add(accTeam.Team_Member__c);
            
        }
        return accountIdToAccTeamIdMap;
        
    }
    
    public static void insertTop5Share(Map<Id,Set<Id>> accIdToAccTeamIdMap, Map<Id,Id> top5IdToAccIdMap, Map<Id,Id> top5IdToOwnerIdMap) 
    {
        List<Top_5__Share> top5ShareList = new List<Top_5__Share>();
        for(Id top5Id : top5IdToAccIdMap.keySet()) 
        {
            Id accId = top5IdToAccIdMap.get(top5Id);
            if(accId != null && accIdToAccTeamIdMap.get(accId)!=null ) 
            {
                for(Id memId : accIdToAccTeamIdMap.get(accId)) 
                {
                    System.debug(memId + '----' + UserInfo.getUserId());
                    // System.debug('memId : ' + accIdToAccTeamIdMap.get(accId));
                    if(memId != top5IdToOwnerIdMap.get(top5Id)) 
                    {
                        Top_5__Share top5Share = new Top_5__Share();
                        top5Share.ParentId = top5Id;
                        top5Share.UserOrGroupId = memId;
                        top5Share.AccessLevel = 'Read'; 
                        top5Share.RowCause = 'Manual';
                        top5ShareList.add(top5Share);
                    }
                }
            }
        }
        System.debug('Top 5 Testing top5ShareList : ' + top5ShareList);
        insert top5ShareList;
        
        
    }
    //called when Account Member is inserted, updated or deleted
    public static Top5Info getTop5RecordsInfo(Set<Id> accIdSet)
    {
        List<Top_5__c> top5List = [SELECT Id,Account__c,OwnerId FROM Top_5__c WHERE Account__c IN :accIdSet and Status__c != 'Black'];
        Top5Info top5InfoRec = new Top5Info();
        Map<Id,Id> top5ToAccMap = new Map<Id,Id>();
        for(Top_5__c top5Rec : top5List)
        {
            top5InfoRec.top5IdToAccIdMap.put(top5Rec.Id, top5Rec.Account__c);
            top5InfoRec.top5IdToOwnerIdMap.put(top5Rec.Id, top5Rec.OwnerId);
        }
        return top5InfoRec;
    }
    
    public static void deleteManualShare(String objName, String filter1, Set<Id> filter1IdSet, String filter2, Set<Id> filter2IdSet)
    {
        String query = 'SELECT Id FROM ' + objName + ' WHERE RowCause=\'Manual\'';
        String condition = '';
        if(filter1 != null && filter1 != '') 
        {
            condition += ' AND ' + filter1 + ' IN :filter1IdSet';
        }
        if(filter2 != null && filter2 != '')
        {
            condition += ' AND ' + filter2 + ' IN :filter2IdSet';
            
        }
        query += condition;
        
        List<SObject> recordsToDeleteList = Database.query(query);
        System.debug('recordsToDeleteList : ' + recordsToDeleteList);
        Database.delete(recordsToDeleteList, false);
        
    }
    
    public class Top5Info 
    {
        public Map<Id,Id> top5IdToAccIdMap;
        public Map<Id,Id> top5IdToOwnerIdMap;
        
        public Top5Info() 
        {
            top5IdToAccIdMap = new Map<Id,Id>();
            top5IdToOwnerIdMap = new Map<Id,Id>();
        }
    }
}