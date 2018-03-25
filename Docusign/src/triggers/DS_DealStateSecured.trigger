trigger DS_DealStateSecured on Deal_State_Secured__c (before insert,after insert) 
{
    // if trigger is before insert/update
    if(Trigger.isBefore)// before insert
    {
        string PageErrorMessage = 'Only one Deal State Secured document may be added per Deal State';
        
        ALL_UtilitiesMiscellaneous.PreventMultipleOnParent(
            Trigger.New, 'Deal_State__c', 'Deal_State__c', 'Deal_State_Secured_Docs__r', PageErrorMessage);
    }
    
    // 2015-01 modified by Lalitha Adduru to after insert, as a Id can be created ( thereby queried ) for a record only after insert.
    if(Trigger.isAfter) // after insert
    {
        if(ALL_CheckRecursive.runOnce())
        {
            list<Deal_State__c> DealStatesToUpdate = new list<Deal_State__c>();   
            for(Deal_State_Secured__c dss : Trigger.New)
            {
                Deal_State__c CurrentDealState = new Deal_State__c(
                    Id = dss.Deal_State__c, 
                    Deal_State_Secured_Id__c = (string)dss.Id
                );
                DealStatesToUpdate.add(CurrentDealState);
            }
            
            if(!DealStatesToUpdate.isEmpty()) { database.update(DealStatesToUpdate); }
        }
    }
}