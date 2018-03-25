// 2016-06-08 vijay.manimaran@cdk.com created the trigger  
trigger All_Agency_Account_Contact on Agency_Account_Contact__c (after insert, after update, before insert, before update) {
    // trigger moved to All_AgencyAccountContact
    /*     
    if(Trigger.isBefore && Trigger.isUpdate)
    {   
        //2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
        Map<String, String> contactToCRMap = new Map<String, String>();
        contactToCRMap.put('Contact__c','Contact_Role_Contact_Relationship__c');
        ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'Agency_Account__c', null, contactToCRMap );
    }
    */
}