trigger ISVC_Case on Case (before insert, after insert, before update, after update) {
    ALL_TriggerDispatcher.run(new ISVC_Case_Handler());
}