trigger ISVC_User on User (before insert, before update, before delete,  after insert, after delete, after update, after undelete) {
    ALL_TriggerDispatcher.run(new ISVC_User_Handler());
}