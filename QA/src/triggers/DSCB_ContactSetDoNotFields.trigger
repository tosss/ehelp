// rq-05034 combine contact triggers into one (this is old trigger commenting out)
// 2015-08-27 - brian.cook@cdk.com, bill.thurow@cdk.com
// 2014-04-21 - siva.pragada@cdk.com - contactsetdonotfields
trigger DSCB_ContactSetDoNotFields on Contact(before insert)
{
    //DSCB_SetDoNotFields.BeforeInsertContactFromContact(Trigger.new);
}