trigger CB_AccountDealerGroupProfile on Dealer_Group_Profile__c (before insert, before update) 
{
    if(Trigger.new.size() > 1)
    {
        for(Dealer_Group_Profile__c d : Trigger.new) {
            d.AddError('Only one Dealer Group Profile may be inserted per batch.'); }
    }
    
    Set<Id> ChildAccountIds = AccountHierarchyTools.ChildrenAccountIds(new Set<Id>{Trigger.new[0].Dealer_Group__c});
    List<Account> ChildAccounts = [Select Id, Name From Account Where Id IN :ChildAccountIds And (Site_Type__r.Name = 'Auto' OR (Status__c = 'Active' And Account_Number__c != null))];
    
    Trigger.new[0].Number_of_Child_Accounts__c = ChildAccounts.size();
    Trigger.new[0].Number_of_WebIDs__c = [Select Id From WebID__c Where Account__c IN :ChildAccountIds And Status__c = 'Active'].size();
}