trigger ALL_CampaignAccountMember on Campaign_Account_Members__c (Before Update, Before Insert, Before Delete, After Insert, After Update) {
    
    DS_CampaignAccountMember_Handler.executeTrigger();
}