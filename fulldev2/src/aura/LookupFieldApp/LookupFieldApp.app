<aura:application implements="force:appHostable" controller="SLS_LeadLink_Controller">
    <c:LookupField objectAPIName="Account" selectedId="{!v.leadAndLeadMatchesRecord.leadRecord.Current_Account__c}" label=""/>
</aura:application>