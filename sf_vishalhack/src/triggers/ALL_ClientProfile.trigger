//2016-08-26 - Created - siva.pragada@cdk.com
trigger ALL_ClientProfile on Client_Profile__c (Before Insert, Before Update) 
{
    if(Trigger.isBefore && ALL_CheckRecursive.runCodeBlockOnce('ALL_ClientProfile_isBefore'))
    {
        ALL_ClientProfile_Handler.mainMethod(Trigger.new);
        
        Map<String, String> contactToCRMap = new Map<String, String> ();
        contactToCRMap.put('Advertising_Contact__c', 'Contact_Relationship__c');
        contactToCRMap.put('SEO_Contact__c', 'SEO_Contact_Relationship__c');
        ALL_ContactRelationship_Helper.assignContactRelationship(
            Trigger.New, Trigger.oldMap, 'Account__c', null, contactToCRMap);
    }
}