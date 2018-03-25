trigger DSCB_ContactSetDoNotFields on Contact(before insert)
{
    DSCB_SetDoNotFields.BeforeInsertContactFromContact(Trigger.new);
}