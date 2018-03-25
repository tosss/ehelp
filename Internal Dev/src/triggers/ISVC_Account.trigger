trigger ISVC_Account on Account (before insert, before update, after insert, after update) {
    ALL_TriggerDispatcher.run(new ISVC_Account_Handler());
}