//2017-01-11 -  lalitha.adduru@cdk.com - created to refactor order accuracy trigger - RQ-06026
//2017-04-06 - siva.pragada@cdk - code formatted for readability and null checks.
//2017-05-17 - lalitha.adduru@cdk.com commented references to DESIGNATED_DSM_NAT_ENT__C as part of RQ-09180
public class DS_OrderAccuracy_Handler 
{
    public static void updateAccuracyEmailFields(List<Order_Accuracy__c> newOrderAccuracies)
    {
        Set<Id> LaunchIds = new Set<Id>();
        Set<Id> CaseIds = new Set<Id>();
        Map<Id, Launch__c> QueriedLaunches = new Map<Id, Launch__c>();
        Map<Id, Case> QueriedCases = new Map<Id, Case>();
        
        for(Order_Accuracy__c newOrderAccuracy : newOrderAccuracies)
        {
            if(newOrderAccuracy.Launch__c != null)
            {
                LaunchIds.add(newOrderAccuracy.Launch__c);
            }
            
            if(newOrderAccuracy.Case__c != null)
            {
                CaseIds.add(newOrderAccuracy.Case__c);
            }
        }
        
        QueriedLaunches = fetchLaunches(LaunchIds);
        QueriedCases = fetchCases(CaseIds);
        
        for(Order_Accuracy__c currentOA : newOrderAccuracies)
        {
            Launch__c CurrentLaunch = currentOA.Launch__c != null ? QueriedLaunches.get(currentOA.Launch__c) : null;
            Case CurrentCase = currentOA.Case__c != null ? QueriedCases.get(currentOA.Case__c) : null;
            
            Account oaAcc = null;
            oaAcc = (CurrentLaunch != null && CurrentLaunch.Account__c != null) ? CurrentLaunch.Account__r : null;
            oaAcc = (oaAcc == null && CurrentCase != null && CurrentCase.Account != null) ?
                CurrentCase.Account : oaAcc;
            
            // if the new value for Account (from Launch or Case) in an insert or update is a blank value
            if(oaAcc == null)
            {
                currentOA.DSM_Email__c = null;
                currentOA.DSC_Email__c = null;
                currentOA.DSM_DOS_Email__c = null;
                currentOA.DSM_Nat_Ent_Email__c = null;
                currentOA.Digital_Services_Marketing_Strategist__c = null; 
            } 
            else
            {
                // Set "DSM Email" = Order_Accuracy__c -> Launch (Account) -> Account (Designated_DSM__c) -> User (Email) 
                if(oaAcc.Designated_DSM__c != null && 
                   oaAcc.Designated_DSM__r.Email != null) 
                {
                    currentOA.DSM_Email__c = oaAcc.Designated_DSM__r.Email; 
                }
                
                // Set "DSC Email" = Order_Accuracy__c -> Launch (Account) -> Account (Digital Solution Consultant) -> User (Email) 
                if(oaAcc.Digital_Sales_Consultant__c != null && 
                   oaAcc.Digital_Sales_Consultant__r.Email != null) 
                {
                    currentOA.DSC_Email__c = oaAcc.Digital_Sales_Consultant__r.Email; 
                }
                
                // Set "DSM DOS Email" = Order_Accuracy__c -> Launch (Account) -> Account (Designated_DSM__c) -> User (Email) 
                if(oaAcc.Designated_DSM__c != null && 
                   oaAcc.Designated_DSM__r.ManagerId != null &&
                   oaAcc.Designated_DSM__r.Manager.Email != null) 
                {
                    currentOA.DSM_DOS_Email__c = oaAcc.Designated_DSM__r.Manager.Email; 
                }
                
                //2017-05-17 lalitha.adduru@cdk.com commented this as part of RQ-09180
                // Set "DSM_Nat_Ent Email" = Order_Accuracy__c -> Launch (Account) -> Account (Designated_DSM_Nat_Ent__c) -> User (Email) 
                /*if(oaAcc.Designated_DSM_Nat_Ent__c != null && 
                   oaAcc.Designated_DSM_Nat_Ent__r.Email != null) 
                {
                    currentOA.DSM_Nat_Ent_Email__c = oaAcc.Designated_DSM_Nat_Ent__r.Email; 
                }*/
                
                // Set "DSM_Nat_Ent Email" = Order_Accuracy__c -> Launch (Account) -> Account (Designated_DSM_Nat_Ent__c) -> User (Email) 
                /*if(oaAcc.Designated_DSM_Nat_Ent__c != null && 
                   oaAcc.Designated_DSM_Nat_Ent__r.ManagerId != null &&
                   oaAcc.Designated_DSM_Nat_Ent__r.Manager.Email != null) 
                {
                    currentOA.DSM_Nat_Ent_DOS_Email__c = oaAcc.Designated_DSM_Nat_Ent__r.Manager.Email; 
                }*/
                
                // Set "Digital_Services_CAM__c Email" = Order_Accuracy__c -> Launch (Account) -> Account (Digital_Services_CAM__c) -> User (Email) 
                if(oaAcc.Digital_Services_CAM__c != null && 
                   oaAcc.Digital_Services_CAM__r.Email != null) 
                {
                    currentOA.Digital_Services_Marketing_Strategist__c = oaAcc.Digital_Services_CAM__r.Email; 
                }
            }
        }
    }
    
    public static Map<Id, Launch__c> fetchLaunches(Set<Id> launchIds)
    {
        Map<Id, Launch__c> QueriedLaunches = new Map<Id, Launch__c>();
        
        if(!launchIds.isEmpty())
        {
            QueriedLaunches = new Map<Id, Launch__c>([
                
                SELECT Id, Name, Account__c, 
                       Account__r.DIGITAL_SERVICES_CAM__C, Account__r.DIGITAL_SERVICES_CAM__r.email,
                       Account__r.Designated_DSM__c, Account__r.Designated_DSM__r.Email, 
                       Account__r.Designated_DSM__r.ManagerId, Account__r.Designated_DSM__r.Manager.Email, 
                       Account__r.Digital_Sales_Consultant__c, Account__r.Digital_Sales_Consultant__r.Email 
                       //Account__r.Designated_DSM_Nat_Ent__c, Account__r.Designated_DSM_Nat_Ent__r.Email, 
                       //Account__r.Designated_DSM_Nat_Ent__r.ManagerId, Account__r.Designated_DSM_Nat_Ent__r.Manager.Email
                FROM   Launch__c
                WHERE  Id IN :launchIds
                
            ]);
        }
        
        return QueriedLaunches;      
    }
    
    public static Map<Id, Case> fetchCases(Set<Id> caseIds)
    {
        Map<Id, Case> QueriedCases = new Map<Id, Case>();
        
        if(!caseIds.isEmpty())
        {
            QueriedCases = new Map<Id, Case>([
                SELECT Id, CaseNumber, AccountId, 
                       Account.DIGITAL_SERVICES_CAM__C,Account.DIGITAL_SERVICES_CAM__r.email,
                       Account.Designated_DSM__c, Account.Designated_DSM__r.Email, 
                       Account.Designated_DSM__r.ManagerId, Account.Designated_DSM__r.Manager.Email, 
                       Account.Digital_Sales_Consultant__c, Account.Digital_Sales_Consultant__r.Email
                       //Account.Designated_DSM_Nat_Ent__c, Account.Designated_DSM_Nat_Ent__r.Email, 
                       //Account.Designated_DSM_Nat_Ent__r.ManagerId, Account.Designated_DSM_Nat_Ent__r.Manager.Email
                FROM   Case
                WHERE  Id IN :caseIds
            ]);
        }
        
        return QueriedCases;
    }
    
}