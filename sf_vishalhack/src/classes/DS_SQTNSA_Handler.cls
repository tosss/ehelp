public class DS_SQTNSA_Handler 
{
    public static void RollUpCountofSQTNSA(List<SQT_NSA__c >newList, Map<ID, SQT_NSA__c>oldMap)
    {
        List<SQT_NSA__c > newListForProcessing = newList != null ? newList : oldMap.values();
        
        set<ID> DealStateIDs = new Set<ID>();
        map<ID, Deal_State__c> DealStateWithChildrenMap;
        
        for(SQT_NSA__c sa: newListForProcessing)
        {
            DealStateIDs.add(sa.Deal_State__c);
        }
        
        if(DealStateIDs != null && !DealStateIDs.isEmpty())
        {
            DealStateWithChildrenMap = new map<ID, Deal_State__c>([
                Select ID, Name, /*Count_of_SQT_NSA__c,*/ 
                
                (Select Id, Name, Deal_State__c 
                 From SQT_NSA__r)
                
                From Deal_State__c
                Where ID
                IN :DealStateIDs
            ]);
        }
        
        if(DealStateWithChildrenMap != null && !DealStateWithChildrenMap.isEmpty())
        {
            for(ID id: DealStateWithChildrenMap.keySet())
            {
                Deal_State__c CurrentDealState = DealStateWithChildrenMap.get(id);
                
                if(CurrentDealState != null)
                {
                    List<SQT_NSA__c> CurrentSQTNSAs = CurrentDealState.getSobjects('SQT_NSA__r');
                    
                    /*if(CurrentSQTNSAs != null && !CurrentSQTNSAs.isEmpty())
                    {
                        CurrentDealState.Count_of_SQT_NSA__c = CurrentSQTNSAs.size();
                    }*/
                }
            }
        }
        
        if(DealStateWithChildrenMap != null && !DealStateWithChildrenMap.isEmpty())
        {
            Update DealStateWithChildrenMap.values();
        }
    }
}