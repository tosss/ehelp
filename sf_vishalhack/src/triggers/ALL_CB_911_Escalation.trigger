//2016-06-06 vijay.manimaran@cdk.com Created 
//2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
trigger ALL_CB_911_Escalation on CB_911_Escalation__c (after insert, after update, before insert,before update) {
   /* Trigger moved to ALL_CB911Escalation 
    if(Trigger.isBefore && Trigger.isUpdate)
    {        
        Map<String, String> contactToCRMap = new Map<String, String>();
        contactToCRMap.put('Dealer_Contact_Name__c','Contact_Relationship__c');
        ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Account__c', null, contactToCRMap );
    }*/
}