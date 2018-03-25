trigger DEP_ChangesetComponent on Change_Set_Component__c (before insert, after insert, before update, after update, before delete, after delete) 
{
    if(Trigger.IsBefore)
    {
        if(Trigger.IsInsert)
        {
            DEP_ChangesetComponent_Handler.beforeInsert(Trigger.New);
        }
        else if(Trigger.IsUpdate)
        {
            DEP_ChangesetComponent_Handler.beforeUpdate(Trigger.New, Trigger.OldMap);
        }
        else
        {
            DEP_ChangesetComponent_Handler.beforeDelete(Trigger.Old);
        }
    }
    else
    {
        if(Trigger.IsInsert)
        {
            DEP_ChangesetComponent_Handler.afterInsert(Trigger.New);
        }
        else if(Trigger.IsUpdate)
        {
            DEP_ChangesetComponent_Handler.afterUpdate(Trigger.New, Trigger.OldMap);
        }
        else
        {
            DEP_ChangesetComponent_Handler.afterDelete(Trigger.Old);
        }
    }
}