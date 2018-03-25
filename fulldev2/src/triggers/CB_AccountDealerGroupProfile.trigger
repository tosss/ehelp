//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to run trigger code on when corresponding trigger toggle record is 'on' - RQ-06909 
//2016-04-25 - lalitha.adduru@cdk.com, sanjay.ghanathey@cdk.com - modified to skip integration user (even if trigger toggle is on ) while running trigger code - RQ-06909
//2016-04-26 - lalitha.adduru@cdk.com - modified the code to use Trigger_Toggle_Profile__c custom settig to check if a profile can fire/skip the trigger - RQ-06909 

trigger CB_AccountDealerGroupProfile on Dealer_Group_Profile__c (before insert, before update) 
{
    //2016-04-26 - lalitha.adduru@cdk.com - fetch code reference to on/off map for Dealer_Group_Profile__c (sObject)- RQ-06909
    Map<String, Boolean> codeReferenceToSwitchMap = new Map<String, Boolean>();
    codeReferenceToSwitchMap = ALL_TriggerToggle_Handler.getOrganizedTriggerToggles('Dealer_Group_Profile__c').codeReferenceToSwitchMap;
    
    //2016-04-26 - lalitha.adduru@cdk.com - fetch profileId to on/off map for CB_AccountDealerGroupProfile (code reference) on Dealer_Group_Profile__c (sObject)- RQ-06909
    Map<ID, Boolean> profileToSwitchMap = new Map<ID, Boolean>();
    profileToSwitchMap = ALL_TriggerToggleProfile_Handler.fetchProfileToSwitchMap('CB_AccountDealerGroupProfile','Dealer_Group_Profile__c');
    
    if(!profileToSwitchMap.containsKey(UserInfo.getProfileId()) || profileToSwitchMap.get(UserInfo.getProfileId()) ) // skip if it is integration user - RQ-06909
    {
        if(!codeReferenceToSwitchMap.containsKey('CB_AccountDealerGroupProfile') || codeReferenceToSwitchMap.get('CB_AccountDealerGroupProfile')) // if 'on' is checked in trigger toggle for trigger , then run the enclosed code
        {
            if(Trigger.new.size() > 1)
            {
                for(Dealer_Group_Profile__c d : Trigger.new) 
                {
                    d.AddError('Only one Dealer Group Profile may be inserted per batch.'); 
                }
            }
            
            Set<Id> ChildAccountIds = AccountHierarchyTools.ChildrenAccountIds(new Set<Id>{Trigger.new[0].Dealer_Group__c});
            List<Account> ChildAccounts = [
                SELECT Id, Name 
                FROM Account 
                WHERE Id IN :ChildAccountIds 
                AND (Site_Type__r.Name = 'Auto' OR (Status__c = 'Active' And Account_Number__c != null))
            ];
            
            Trigger.new[0].Number_of_Child_Accounts__c = ChildAccounts.size();
            Trigger.new[0].Number_of_WebIDs__c = [
                SELECT Id 
                FROM WebID__c 
                WHERE Account__c IN :ChildAccountIds 
                AND Status__c = 'Active'
            ].size();
        }
    }
    
}