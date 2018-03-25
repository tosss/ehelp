//2017-04-12 ragashalini.koka@cdk.com - Created this trigger for RQ-09011
trigger ALL_Contract on Contract (before insert) 
{
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            ALL_Contract_Handler.updateAccount(Trigger.new);
        }
    }

}