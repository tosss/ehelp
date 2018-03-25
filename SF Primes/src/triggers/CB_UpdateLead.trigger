trigger CB_UpdateLead on Lead(before insert, before update) {
    CB_UpdateLeadHandler.UpdateOpportunity(Trigger.NewMap, Trigger.OldMap);
}