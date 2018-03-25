trigger ISVC_Task on Task (after update) {
    ALL_TriggerDispatcher.run(new ISVC_Task_Handler());
}