trigger DEP_Changeset on Change_Set__c (before insert, after insert, before update, after update, before delete, after delete) 
{
    if(Trigger.IsBefore)
    {
        if(Trigger.IsInsert)
        {
            DEP_Changeset_Handler.beforeInsert(Trigger.New);
        }
        else if(Trigger.IsUpdate)
        {
            DEP_Changeset_Handler.beforeUpdate(Trigger.New, Trigger.OldMap);
        }
        else
        {
            DEP_Changeset_Handler.beforeDelete(Trigger.Old);
        }
    }
    else
    {
        if(Trigger.IsInsert)
        {
            DEP_Changeset_Handler.afterInsert(Trigger.New);
        }
        else if(Trigger.IsUpdate)
        {
            DEP_Changeset_Handler.afterUpdate(Trigger.New, Trigger.OldMap);
        }
        else
        {
            DEP_Changeset_Handler.afterDelete(Trigger.Old);
        }
    }
}