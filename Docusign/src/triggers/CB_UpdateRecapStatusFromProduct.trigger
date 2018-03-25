trigger CB_UpdateRecapStatusFromProduct on Recap_Product__c (before insert, before update, after insert, after update) 
{
    if(Trigger.isBefore && Trigger.isInsert)
    {
        Set<Id> RecapIds = new Set<Id>();
        for(Recap_Product__c RecapProduct : Trigger.New) { if(RecapProduct.Recap__c != null) { RecapIds.add(RecapProduct.Recap__c); } }
        
        Map<Id, Recap__c> Recaps = new Map<Id, Recap__c>([
            Select Id, Name, Account__c, (Select Id, Name, Recap__c, RecordTypeId, RecordType.Name From Recap_Products__r) 
            From Recap__c 
            Where Id IN :RecapIds
        ]); 
        
        //List<Recap_Product__c> Test = New List<Recap_Product__c>();
        //Test = [Select Id, Name, Recap__c, RecordTypeId, RecordType.Name, Recap__r.Product__c From Recap_Product__c Where Recap__c IN :RecapIds];
        
        //System.debug('test.RecordType.Name---'+test[0].RecordType.Name);
        //System.debug('Test.Recap__c---'+test[0].Recap__c);
        //System.debug('RecapIds---'+RecapIds);
        //System.debug('Test---'+Test);
        //System.debug('Recaps---'+Recaps);
            
        //Map<String, String> RecapIdRecapProdNameMap = new Map<String, String>();
        //for(Recap_Product__c rp: Test){RecapIdRecapProdNameMap.put(rp.RecordTypeId, rp.RecordType.Name);} 
        
        //System.debug('RecapIdRecapProdNameMap---'+RecapIdRecapProdNameMap);
        
        for(Recap_Product__c RecapProduct : Trigger.New) { 
            if(RecapProduct.Recap__c != null) { 
                Recap__c CurrentRecap = Recaps.get(RecapProduct.Recap__c);
                if(CurrentRecap != null && CurrentRecap.Account__c != null) { RecapProduct.Recap_Account__c = CurrentRecap.Account__c; } 
            } 
        }
        
        CB_Recap.CheckDuplicateRecapProducts(Recaps, Trigger.New); 
    }
    
    if(Trigger.isAfter) { CB_Recap.InvokeRecapStatusUpdate(Trigger.new, 'Recap__c'); }
}