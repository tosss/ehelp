public class DS_FinalizedDealNSARequest_Handler 
{
    public static void FinalizedDealNSARequest(List<Finalized_Deal_NSA_Request__c> NewNSARequests)
    {
        Set<Id> DealStateIds =  new Set<Id>();                
        Set<String> Accountfield = new Set<String>();
        
        Map<Id, Finalized_Deal_NSA_Request__c> FinalizedDealsMap = new Map<Id, Finalized_Deal_NSA_Request__c>(
            [
                SELECT Id, Deal_State__r.Opportunity__r.Account.Key_DOS__r.ManagerId
                FROM Finalized_Deal_NSA_Request__c 
                WHERE Id 
                IN :NewNSARequests
            ]
        );
        
        
        List<Finalized_Deal_NSA_Request__c> FinalDealsToUpdate = new List<Finalized_Deal_NSA_Request__c>();
        
        // prepare query and collections for setting RGM
        Map<string, string> AVPToRGMMap =  new Map<string, string>();
        List<AVP_RGM_Link__c> AVP_RGMList = new List<AVP_RGM_Link__c>();
        
        AVP_RGMList = [Select Id, AVP__c, RGM__c From AVP_RGM_Link__c];
        
        for(AVP_RGM_Link__c a: AVP_RGMList){
            AVPToRGMMap.put(a.AVP__c, a.RGM__c);
        }
        
        System.debug(AVPToRGMMap);
        
        for(Id key : FinalizedDealsMap.KeySet())
        { 
            Finalized_Deal_NSA_Request__c FinalizedDealNSARequest = new Finalized_Deal_NSA_Request__c();
            Deal_State__c CurrentDealState = new Deal_State__c();
            Opportunity CurrentOpportunity = new Opportunity();
            Account CurrentAccount = new Account();
            User CurrentUser = new User();
            
            FinalizedDealNSARequest = FinalizedDealsMap.get(key);
            CurrentDealState = FinalizedDealNSARequest != null ? FinalizedDealNSARequest.Deal_State__r : null;
            CurrentOpportunity = CurrentDealState != null ? CurrentDealState.Opportunity__r : null;
            CurrentAccount = CurrentOpportunity != null ? CurrentOpportunity.Account : null;
            CurrentUser = CurrentAccount != null ? CurrentAccount.Key_DOS__r : null;
            
            System.debug(CurrentAccount);
            
            if(CurrentAccount != null) { 
                FinalizedDealNSARequest.DOS__c = CurrentAccount.Key_DOS__c; 
            }
            
            System.debug(CurrentUser);
            
            if(CurrentUser != null)
            {
                FinalizedDealNSARequest.AVP__c = CurrentUser.ManagerId;
                
                System.debug(AVPToRGMMap);
                System.debug(AVPToRGMMap.get(CurrentUser.ManagerId) != null);
                
                if(AVPToRGMMap != null && !AVPToRGMMap.isEmpty() && AVPToRGMMap.get(CurrentUser.ManagerId) != null) { 
                    FinalizedDealNSARequest.RGM__c = AVPToRGMMap.get(CurrentUser.ManagerId); 
                }
            }
            
            FinalDealsToUpdate.add(FinalizedDealNSARequest);
        }        
        
        update FinalDealsToUpdate;
    }
}