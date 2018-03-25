//2016-05-20 lalitha.adduru@cdk.com - RQ-06982
//2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument)
trigger ALL_OEM_District on CB_OEM_District__c (before update) 
{
   /* Trigger moved to ALL_OEMDistrict
   if(Trigger.isBefore && Trigger.isUpdate)
    {        
        Map<String, String> contactToCRMap = new Map<String, String>();
        contactToCRMap.put('CB_District_Manager__c','District_Manager_Relationship__c');
        contactToCRMap.put('CB_Zone_Manager__c','Zone_Manager_Relationship__c');   
        ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap,'CB_Region_Account__c', null, contactToCRMap);
    }*/

}