trigger DS_OrderAccuracy on Order_Accuracy__c (before insert, before update) 
{
    List<Order_Accuracy__c> AccuraciesToProcess = new List<Order_Accuracy__c>();
    List<Id> LaunchIdsToProcess = new List<Id>();
    List<Id> CaseIdsToProcess = new List<Id>();
    Map<Id, Launch__c> QueriedLaunches = new Map<Id, Launch__c>();
    Map<Id, Case> QueriedCases = new Map<Id, Case>();
    
    // find all Order Accuracy records that need to be processed
    for(Order_Accuracy__c CurrentOrderAccuracy : Trigger.New)
    {
        // 2014-03-06 MK - Updated trigger to run whenever an Order Accuracy record is Saved
        //   This will improve the synchronization of the Email fields 
        
        //Order_Accuracy__c OldOrderAccuracy = Trigger.OldMap != null ? Trigger.OldMap.get(CurrentOrderAccuracy.Id) : null;
        //if(OldOrderAccuracy == null) { OldOrderAccuracy = new Order_Accuracy__c(); }
        
        //if(CurrentOrderAccuracy.Launch__c != OldOrderAccuracy.Launch__c)
        //{
            AccuraciesToProcess.add(CurrentOrderAccuracy); 
            
            if(CurrentOrderAccuracy.Launch__c != null) {
                LaunchIdsToProcess.add(CurrentOrderAccuracy.Launch__c);
            }
        //}  
        
        //if(CurrentOrderAccuracy.Case__c != OldOrderAccuracy.Case__c)
        //{
            AccuraciesToProcess.add(CurrentOrderAccuracy); 
            
            if(CurrentOrderAccuracy.Case__c != null) {
                CaseIdsToProcess.add(CurrentOrderAccuracy.Case__c);
            }
        //}
    }
    
    // Digital_Sales_Consultant__c is really Digital_Solutions_Consultant__c
    
    if(LaunchIdsToProcess.Size()>0){
        QueriedLaunches = new Map<Id, Launch__c>([
            Select Id, Name, Account__c, 
            Account__r.DIGITAL_SERVICES_CAM__C,Account__r.DIGITAL_SERVICES_CAM__r.email,Account__r.Designated_DSM__c, 
            Account__r.Designated_DSM__r.Email, Account__r.Designated_DSM__r.ManagerId, Account__r.Designated_DSM__r.Manager.Email, 
            Account__r.Digital_Sales_Consultant__c, Account__r.Digital_Sales_Consultant__r.Email, 
            Account__r.Designated_DSM_Nat_Ent__c, Account__r.Designated_DSM_Nat_Ent__r.Email, 
            Account__r.Designated_DSM_Nat_Ent__r.ManagerId, Account__r.Designated_DSM_Nat_Ent__r.Manager.Email
            From Launch__c
            Where Id IN :LaunchIdsToProcess
        ]);
    }
    
    if(CaseIdsToProcess.Size()>0){
        QueriedCases = new Map<Id, Case>([
            Select Id, CaseNumber, AccountId, 
            Account.DIGITAL_SERVICES_CAM__C,Account.DIGITAL_SERVICES_CAM__r.email,Account.Designated_DSM__c, 
            Account.Designated_DSM__r.Email, Account.Designated_DSM__r.ManagerId, Account.Designated_DSM__r.Manager.Email, 
            Account.Digital_Sales_Consultant__c, Account.Digital_Sales_Consultant__r.Email, 
            Account.Designated_DSM_Nat_Ent__c, Account.Designated_DSM_Nat_Ent__r.Email, 
            Account.Designated_DSM_Nat_Ent__r.ManagerId, Account.Designated_DSM_Nat_Ent__r.Manager.Email
            From Case
            Where Id IN :CaseIdsToProcess
        ]);
    }
    
    for(Order_Accuracy__c CurrentOrderAccuracy : AccuraciesToProcess)
    {
        Launch__c CurrentLaunch = QueriedLaunches.get(CurrentOrderAccuracy.Launch__c);
        Case CurrentCase = QueriedCases.get(CurrentOrderAccuracy.Case__c);
        
        Account OrderAccuracyAccount = null;
        
        if(CurrentLaunch != null && CurrentLaunch.Account__c != null) { 
            OrderAccuracyAccount = (Account) CurrentLaunch.Account__r; }
        
        if(OrderAccuracyAccount == null && CurrentCase != null && CurrentCase.Account != null) { 
            OrderAccuracyAccount = (Account) CurrentCase.Account; }
        
        // if the new value for Account (from Launch or Case) in an insert or update is a blank value
        if(OrderAccuracyAccount == null)
        {
            CurrentOrderAccuracy.DSM_Email__c = null;
            CurrentOrderAccuracy.DSC_Email__c = null;
            CurrentOrderAccuracy.DSM_DOS_Email__c = null;
            CurrentOrderAccuracy.DSM_Nat_Ent_Email__c = null;
            CurrentOrderAccuracy.Digital_Services_Marketing_Strategist__c = null; 
        }
        
        if(OrderAccuracyAccount != null)
        {
            // Set "DSM Email" = Order_Accuracy__c -> Launch (Account) -> Account (Designated_DSM__c) -> User (Email) 
            if(OrderAccuracyAccount.Designated_DSM__c != null && OrderAccuracyAccount.Designated_DSM__r.Email != null) 
            {
                CurrentOrderAccuracy.DSM_Email__c = OrderAccuracyAccount.Designated_DSM__r.Email; 
            }
            
            // Set "DSC Email" = Order_Accuracy__c -> Launch (Account) -> Account (Digital Solution Consultant) -> User (Email) 
            if(OrderAccuracyAccount.Digital_Sales_Consultant__c != null && OrderAccuracyAccount.Digital_Sales_Consultant__r.Email != null) 
            {
                CurrentOrderAccuracy.DSC_Email__c = OrderAccuracyAccount.Digital_Sales_Consultant__r.Email; 
            }
            
            // Set "DSM DOS Email" = Order_Accuracy__c -> Launch (Account) -> Account (Designated_DSM__c) -> User (Email) 
            if(OrderAccuracyAccount.Designated_DSM__c != null && OrderAccuracyAccount.Designated_DSM__r.ManagerId != null
               && OrderAccuracyAccount.Designated_DSM__r.Manager.Email != null) 
            {
                CurrentOrderAccuracy.DSM_DOS_Email__c = OrderAccuracyAccount.Designated_DSM__r.Manager.Email; 
            }
            
            // Set "DSM_Nat_Ent Email" = Order_Accuracy__c -> Launch (Account) -> Account (Designated_DSM_Nat_Ent__c) -> User (Email) 
            if(OrderAccuracyAccount.Designated_DSM_Nat_Ent__c != null && OrderAccuracyAccount.Designated_DSM_Nat_Ent__r.Email != null) 
            {
                CurrentOrderAccuracy.DSM_Nat_Ent_Email__c = CurrentLaunch.Account__r.Designated_DSM_Nat_Ent__r.Email; 
            }
            
            // Set "DSM_Nat_Ent Email" = Order_Accuracy__c -> Launch (Account) -> Account (Designated_DSM_Nat_Ent__c) -> User (Email) 
            if(OrderAccuracyAccount.Designated_DSM_Nat_Ent__c != null && OrderAccuracyAccount.Designated_DSM_Nat_Ent__r.ManagerId != null
               && OrderAccuracyAccount.Designated_DSM_Nat_Ent__r.Manager.Email != null) 
            {
                CurrentOrderAccuracy.DSM_Nat_Ent_DOS_Email__c = OrderAccuracyAccount.Designated_DSM_Nat_Ent__r.Manager.Email; 
            }
            
            // Set "Digital_Services_CAM__c Email" = Order_Accuracy__c -> Launch (Account) -> Account (Digital_Services_CAM__c) -> User (Email) 
            if(OrderAccuracyAccount.Digital_Services_CAM__c != null && OrderAccuracyAccount.Digital_Services_CAM__r.Email != null) 
            {
                CurrentOrderAccuracy.Digital_Services_Marketing_Strategist__c = OrderAccuracyAccount.Digital_Services_CAM__r.Email; 
            }
        }
    }
}