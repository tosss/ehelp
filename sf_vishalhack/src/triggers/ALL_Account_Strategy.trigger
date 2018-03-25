trigger ALL_Account_Strategy on Account_Strategy__c (before insert, before update) 
{
    CB_AccountStrategyFieldUpdates.UpdatesMethod(Trigger.new);   
}