trigger CB_AccountPlanStrategy on Monthly_Maintenance__c (before insert, before update) 
{
    for(Monthly_Maintenance__c Strategy : Trigger.New)
    {
        Monthly_Maintenance__c old = Trigger.oldMap != null ? Trigger.oldMap.get(Strategy.Id) : new Monthly_Maintenance__c();
        
        if(Strategy.Status__c != null && Strategy.Status__c != old.Status__c)
        {
            if(Strategy.Status__c == 'Completed' 
            || Strategy.Status__c == 'Cancelled'
            || Strategy.Status__c == 'Expired')
            {
                Strategy.Completed_By__c = UserInfo.getUserId();
                Strategy.Completed_Date__c = DateTime.now();
            }
            else
            {
                Strategy.Completed_By__c = null;
                Strategy.Completed_Date__c = null;
            }
        }
    }
}