trigger ISVC_Asset on Asset (before insert, before update) {
    ALL_TriggerDispatcher.run(new ISVC_Asset_Handler());
}