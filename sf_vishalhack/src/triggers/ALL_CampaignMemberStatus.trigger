trigger ALL_CampaignMemberStatus on Campaign_Member_Status__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
     DS_CampaignMemberStatus_Handler.executeTrigger();  
}