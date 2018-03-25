trigger ISVC_Deactivation on Deactivation__c (after insert) {
    ALL_TriggerDispatcher.run(new ISVC_Deactivation_Handler());
}