public class DS_OpportunityDealChange_Extension 
{
    public Boolean DealStateExists {get;set;}
    
    public Opportunity CurrentOpportunity {get;set;}
    public Deal_State__c DealState {get;set;}
    public Deal_Change__c DealChange {get;set;}
    
    public DS_OpportunityDealChange_Extension(ApexPages.StandardController ctr)
    {
        CurrentOpportunity = (Opportunity) ctr.getRecord();
        
        initialize();
    }
    
    public void initialize()
    {
        if(CurrentOpportunity != null)
        {
            list<Deal_State__c> DealStates = [
                select Id, Name From Deal_State__c Where Opportunity__c = :CurrentOpportunity.Id
            ];
            
            if(DealStates != null && !DealStates.isEmpty()) 
            { 
                DealState = DealStates.get(0); 
                
                DealStateExists = true;
            }
            else
            {
                DealState = new Deal_State__c();
                DealState.Opportunity__c = CurrentOpportunity.Id;
                DealState.Deal_Status__c = 'New Deal Arrived';
                DealState.Description_of_Need__c = 'Requested Changes from Opportunity Page';
                
                DealStateExists = false;
            }
            
            DealChange = new Deal_Change__c();
            if(DealStateExists) { DealChange.Deal_State__c = DealState.Id; }
        }
    }
    
    public void SaveDealChange()
    {
        try
        {
            if(!DealStateExists) { 
                insert DealState; DealChange.Deal_State__c = DealState.Id; 
            }
            
            upsert DealChange;
            
            initialize();
        }
        catch(Exception e) 
        { 
            ApexPages.addMessages(e); 
        }
    }
}