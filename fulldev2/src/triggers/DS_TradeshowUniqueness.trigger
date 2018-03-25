trigger DS_TradeshowUniqueness on Tradeshow__c (before insert) {
    for(Tradeshow__c ts : Trigger.New) { ts.Guarantee_Uniqueness__c = ts.Name; }
}