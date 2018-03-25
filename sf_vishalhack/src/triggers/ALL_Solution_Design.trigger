trigger ALL_Solution_Design on Solution_Design__c (after insert, after update) 
{
    try
    {
        if(Trigger.New!=null)
        { 
            List<Opportunity> OpportunityList = new List<Opportunity>();
            Map<Id,Opportunity> OpportunityMap = new Map<Id,Opportunity>();
            List<Id> oppIds = new List<id>();
            
            for(Solution_Design__c Solution_Design_object: Trigger.New)
            {
                oppIds.add(Solution_Design_object.Opportunity__c);                
            }
            
            if(oppIds!=null && oppIds.size()!=0)
            {
                OpportunityList = [SELECT id,Solution_Design_Completion_Date__c,Name FROM Opportunity where id in :oppIds];
                
                if(OpportunityList!=null)
                {
                    for(Opportunity Opportunity_object:OpportunityList)
                    {
                        OpportunityMap.put(Opportunity_object.id,Opportunity_object);
                    }
                    for(Solution_Design__c Solution_Design_object:Trigger.New)
                    {  
                        if(OpportunityMap.get(Solution_Design_object.Opportunity__c)!=null)
                        {
                            if(Solution_Design_object.E_Mailed_to_BDC__c!=null)
                            {
                                OpportunityMap.get(Solution_Design_object.Opportunity__c).Solution_Design_Completion_Date__c 
                                    = Solution_Design_object.E_Mailed_to_BDC__c.date();
                            }
                            else
                            {
                                OpportunityMap.get(Solution_Design_object.Opportunity__c).Solution_Design_Completion_Date__c = null;    
                            }
                        }
                    }
                    upsert OpportunityMap.values();
                }
            }
        }
    }
    catch(DMLException e)
    {
        System.debug('Exception in '+e.getMessage());
    }
    catch(Exception e)
    {
        System.debug('Exception in '+e.getMessage());
    }   
}