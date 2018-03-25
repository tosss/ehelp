/*----------------------------------------------------------------------
 * RQ-06982
 * 2016-05-20 lalitha.adduru@cdk.com - RQ-06982 - created  
 * Description: Added functionality : Trigger to populate Contact Relationship Lookup on insert and on update(only when account or contact is changed)
 * ---------------------------MODIFICATIONS-----------------------------
 * 2016-06-09 lalitha.adduru@cdk.com - edited to use the modified method (added another argument) 
 * 2016-06-28 - vijay.manimaran@cdk.com modified "IF" condition adding IsInsert
 * 2016-06-28 - vijay.manimaran@cdk.com Added the comments  header.
  ------------------------------------------------------------------------*/

trigger ALL_OEMDistrict on CB_OEM_District__c(before update, before insert)
{
    if (Trigger.isBefore && (Trigger.IsInsert || Trigger.isUpdate))
    {
        Map<String, String> contactToCRMap = new Map<String, String> ();
        contactToCRMap.put('CB_District_Manager__c', 'District_Manager_Relationship__c');
        contactToCRMap.put('CB_Zone_Manager__c', 'Zone_Manager_Relationship__c');
        ALL_ContactRelationship_Helper.assignContactRelationship(Trigger.New, Trigger.oldMap, 'CB_Region_Account__c', null, contactToCRMap);
    }

}