//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user (even if trigger toggle is on ) while running trigger code - RQ-06909
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 
trigger CB_UpdateRecapStatusFromProduct on Recap_Product__c (before insert, before update, after insert, after update) 
{
    //2016-04-26 - lalitha.adduru@cdk.com - fetch code reference to on/off map for Recap_Product__c (sObject)- RQ-06909
    Map<String, Boolean> codeReferenceToSwitchMap = new Map<String, Boolean>();
    codeReferenceToSwitchMap = ALL_TriggerToggle_Handler.getOrganizedTriggerToggles('Recap_Product__c').codeReferenceToSwitchMap;
    
    //2016-04-26 - lalitha.adduru@cdk.com - fetch profileId to on/off map for CB_AccountDealerGroupProfile (code reference) on Recap_Product__c (sObject)- RQ-06909
    Map<ID, Boolean> profileToSwitchMap = new Map<ID, Boolean>();
    profileToSwitchMap = ALL_TriggerToggleProfile_Handler.fetchProfileToSwitchMap('CB_UpdateRecapStatusFromProduct','Recap_Product__c');
    
    if(!profileToSwitchMap.containsKey(UserInfo.getProfileId()) || profileToSwitchMap.get(UserInfo.getProfileId()) ) // skip if it is integration user - RQ-06909
    {
        if(!codeReferenceToSwitchMap.containsKey('CB_UpdateRecapStatusFromProduct') ||codeReferenceToSwitchMap.get('CB_UpdateRecapStatusFromProduct')) // if 'on' is checked in trigger toggle for trigger , then run the enclosed code
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
            
            if(Trigger.isAfter) 
            { 
                CB_Recap.InvokeRecapStatusUpdate(Trigger.new, 'Recap__c'); 
            }
        }
    }
}