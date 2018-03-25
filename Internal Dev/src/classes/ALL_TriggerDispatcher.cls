public class ALL_TriggerDispatcher {

    public static void run(ALL_TriggerHandler_Interface handler){
        if(!handler.isDisabled()){
            dispatch(handler);
        }
    }

    private static void dispatch(ALL_TriggerHandler_Interface handler){
        if(Trigger.isBefore) {
            if(Trigger.isInsert){
                handler.beforeInsert(Trigger.new);
            } else if(Trigger.isUpdate){
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            } else if(Trigger.isDelete){
                handler.beforeDelete(Trigger.oldMap);
            }
        } else if(Trigger.isAfter){
            if(Trigger.isInsert){
                handler.afterInsert(Trigger.newMap);
            } else if(Trigger.isUpdate){
                handler.afterUpdate(trigger.newMap, trigger.oldMap);
            } else if(Trigger.isDelete){
                handler.afterDelete(trigger.oldMap);
            } else if(Trigger.isUndelete){
                handler.afterUndelete(trigger.oldMap);
            }
        }
        handler.andFinally();
    }
}