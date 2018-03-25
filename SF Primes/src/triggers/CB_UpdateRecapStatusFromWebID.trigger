trigger CB_UpdateRecapStatusFromWebID on Recap_WebID__c (after insert, after update) {
    if(Trigger.isAfter) { CB_Recap.InvokeRecapStatusUpdate(Trigger.new, 'Recap__c'); }
}