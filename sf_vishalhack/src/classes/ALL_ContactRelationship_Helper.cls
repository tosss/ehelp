/*----------------------------------------------------------------------
* RQ-07014
* 2016-05-19 lalitha.adduru@cdk.com - created this class  
* Description: Helper class for Triggers related to sharedcontacts project.
* ---------------------------MODIFICATIONS-----------------------------
* 2016-06-08 lalitha.adduru@cdk.com - populate contact relationship field when account or contact lookup is updated (Revised)
* accountLookup will be null when the object doesn't have an account lookup field, parentAccountIdMap will be null when the object does.
* 2016-06-28 - vijay.manimaran@cdk.com - Added the logic to make the ID's null as we using this for IsInsert in Triggers. 
* 2016-07-21 - vijay.manimaran@cdk.com - Added Additional filter to eliminate exception for LMA RFP object.  
------------------------------------------------------------------------*/

public class ALL_ContactRelationship_Helper
{
    public static void assignContactRelationship(
        List<sObject> newList, Map<Id, sObject> oldMap, String accountLookup,
        Map<Id, Id> parentAccountIdMap, Map<String, String> contactToCRMap)
    {
        Map<String, sObject> combinedIdTosObjectMap = new Map<String, sObject> ();
        Set<String> accountContactSet = new Set<String> ();
        
        List<sObject> sObjectsToProcess = new List<sObject> ();
        //system.debug('******** ******** ******** new list ' + newList + 'oldMap ' + oldMap + 
        //             'accountLookup ' + accountLookup + 'parentAccountIdMap ' + parentAccountIdMap + 'contactToCRMap ' + contactToCRMap);
        
        for (sObject updatedRecord : newList)
        {
            for (String contactLookUp : contactToCRMap.keyset())
            {
                // set current and previous
                Id currentAccountId = accountLookup == null ? 
                    parentAccountIdMap.get(updatedRecord.Id) : 
                    (Id) ALL_UtilitiesData.GetDataFromNestedFields(accountLookup, updatedRecord);
                
                Id currentContactId = (Id) updatedRecord.get(contactLookup);
                Id previousAccountId = null;
                Id previousContactId = null;
                
                if (accountLookup == null) {
                    previousAccountId = parentAccountIdMap.get(updatedRecord.Id);
                    system.debug('************* previousAccountId' + previousAccountId);
                }
                
                if (oldMap != null && oldMap.get(updatedRecord.Id) != null)
                {
                    system.debug(oldMap.get(updatedRecord.Id));
                    system.debug(accountLookup);
                    sObject OldRecord = oldMap.get(updatedRecord.Id);
                    
                    if (accountLookup != null && ALL_UtilitiesData.GetDataFromNestedFields(accountLookup, oldRecord) != null && previousAccountId == null) {
                        previousAccountId = (Id) ALL_UtilitiesData.GetDataFromNestedFields(accountLookup, oldRecord);
                        system.debug('************* previousAccountId' + previousAccountId);
                        
                    }
                    
                    if (contactLookup != null && ALL_UtilitiesData.GetDataFromNestedFields(contactLookup, oldRecord) != null) {
                        previousContactId = (Id) ALL_UtilitiesData.GetDataFromNestedFields(contactLookup, oldRecord);
                    }
                }
                // end set current and previous
                system.debug('******previousAccountId**** ' + previousAccountId + '******currentAccountId**** ' + currentAccountId);
                system.debug('******currentContactId**** ' + currentContactId + '******previousContactId**** ' + previousContactId);
                
                if (currentContactId != previousContactId || currentAccountId != previousAccountId)
                {
                    if (currentContactId == null || currentAccountId == null)
                    {
                        system.debug('corresponding CR ' + contactToCRMap.get(contactLookUp) + ' is assigned null');
                        updatedRecord.put(contactToCRMap.get(contactLookUp), null);
                    }
                    else
                    {
                        String accountContactId = String.valueOf(currentAccountId) + String.valueOf(currentContactId);
                        system.debug('*********** accountContactId' + accountContactId);
                        accountContactSet.add(accountContactId);
                        combinedIdTosObjectMap.put(accountContactId, updatedRecord);
                        sObjectsToProcess.add(updatedRecord);
                    }
                }
            }
        }
        
        List<Contact_Relationship__c> contactRelationshipList = new List<Contact_Relationship__c> ();
        
        contactRelationshipList =
            [
                SELECT Id, Status__c, Account_Contact_Id__c
                FROM Contact_Relationship__c
                WHERE Account_Contact_Id__c in : accountContactSet
            ];
        
        Map<String, Contact_Relationship__c> combinedIdToCRMap = new Map<String, Contact_Relationship__c> ();
        
        for (Contact_Relationship__c existingCR : contactRelationshipList)
        {
            combinedIdToCRMap.put(existingCR.Account_Contact_Id__c, existingCR);
            system.debug('********* CR ' + existingCR.Id);
        }
        
        for (sObject updatedRecord : sObjectsToProcess)
        {
            for (String contactLookup : contactToCRMap.keyset())
            {
                // set current and previous
                Id currentAccountId = accountLookup == null ? 
                    parentAccountIdMap.get(updatedRecord.Id) : 
                    (Id) ALL_UtilitiesData.GetDataFromNestedFields(accountLookup, updatedRecord);
                
                Id currentContactId = (Id) updatedRecord.get(contactLookup);
                Id previousAccountId = null;
                Id previousContactId = null;
                
                if (accountLookup == null) {
                    previousAccountId = parentAccountIdMap.get(updatedRecord.Id);
                }
                
                if (oldMap != null && oldMap.get(updatedRecord.Id) != null)
                {
                    sObject OldRecord = oldMap.get(updatedRecord.Id);
                    
                    if (accountLookup != null && ALL_UtilitiesData.GetDataFromNestedFields(accountLookup, oldRecord) != null && previousAccountId == null) {
                        previousAccountId = (Id) ALL_UtilitiesData.GetDataFromNestedFields(accountLookup, oldRecord);
                    }
                    
                    if (contactLookup != null && ALL_UtilitiesData.GetDataFromNestedFields(contactLookup, oldRecord) != null) {
                        previousContactId = (Id) ALL_UtilitiesData.GetDataFromNestedFields(contactLookup, oldRecord);
                    }
                }
                
                // end set current and previous
                //system.debug('******previousAccountId**** ' + previousAccountId + '******currentAccountId**** ' + currentAccountId);
                //system.debug('******currentContactId**** ' + currentContactId + '******previousContactId**** ' + previousContactId);
                
                CustomSettings__c allowinactive = CustomSettings__c.getInstance();
                
                // 2016-06-18 vijay.manimaran@cdk.com - changed condition to check previous value instead of existing CR
                if (currentContactId != null && currentAccountId != null && (currentContactId != previousContactId || currentAccountId != previousAccountId))
                {
                    String accountContactId = String.valueOf(currentAccountId) + String.valueOf(currentContactId);
                    Contact_Relationship__c existingCR = combinedIdToCRMap.get(accountContactId);
                    LMA_RFP__c lma;
                    if (existingCR != null) 
                    {
                        if (existingCR.Status__c != 'Inactive' || allowinactive.Disable_Shared_Contact_Active_Check__c == True)
                        {
                            //system.debug('***********************existingCR.Id' + existingCR.Id);
                            updatedRecord.put(contactToCRMap.get(contactLookup), existingCR.Id);
                        }
                        else
                        {
                            updatedRecord.put(contactToCRMap.get(contactLookup), null);
                            
                        }
                    }
                    else
                    {
                        GlobalSettings__c gs = GlobalSettings__c.getOrgDefaults();
                        
                        if(UserInfo.getUserName() != gs.Admin_Integration_Username__c)
                        {
                            // 2016-07-26 matt.keefe@cdk.com - uncommented and added null checks for updatedRecord
                            Schema.SObjectType targetType = Schema.getGlobalDescribe().get('LMA_RFP__c'); //globaldescribe used to get objectname. 
                            if(updatedRecord != null && updatedRecord.Id != null && updatedRecord.Id.getSobjectType() == targetType) 
                            {
                                updatedRecord.put(contactToCRMap.get(contactLookup), null);
                            }
                            else
                            { 
                                system.debug('adding error at ' + updatedRecord.Id);
                                updatedRecord.addError('Contact Relationship doesn\'t exist for this combination of Account and Contact');
                            }
                        }
                    } // end else existingCR 
                }
            } // end for contactLookup in contactToCRMap
        } // end for updatedRecord in sObjectsToProcess
    }
}