/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Handles trigger context methods
Test Class:  IMP_SubProjectSite_Test
History
12/29/14     Samuel Oberes       Created
02/06/15     Samuel Oberes       Updated error message ERR_MESSAGE_DUPLICATE_SITE
------------------------------------------------------------*/
public class IMP_SubProjectSite_Handler {

    public static final String ERR_MESSAGE_DUPLICATE_SITE = 'A Subproject Site for the same Account already exists. Please use the Apply CMF to Existing Site button on the SubProject related list to add CMF for the same Subproject Site.';

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: 1) Maps the site's account to the CMF Info's account provided they have the same ship CMF.
                 2) Maps the site's dealer group to its account's topmost parent.
    Parameters:  shipCmfsSet - Set<String>
                 newSites    - accepts the Trigger.new values
    History
    12/30/14     Samuel Oberes       Created
    03/19/15     Samuel Oberes       Used the new implementation of getTopParentAccountId
    ------------------------------------------------------------*/
    public static void populateAccountAndDealerGroup(Set<String> shipCmfsSet, List<SubProjectSite__c> newSites) {
        
        // exit if one of the parameters are null or blank
        if (shipCmfsSet == null || shipCmfsSet.isEmpty() || newSites == null || newSites.isEmpty()) {
            return;
        }

        List<CMF_Info__c> cmfInfoList = [SELECT Ship_CMF__c, 
                                                Account__c 
                                           FROM CMF_Info__c 
                                          WHERE Ship_CMF__c IN :shipCmfsSet 
                                            AND Status__c = 'A' 
                                       ORDER BY Ship_CMF__c, Account__c];

        Map<String, String> shipCmfToAccountMap = new Map<String, String>();
        Map<Id, Id> accountToDealerGroupMap = new Map<Id, Id>();
        Set<Id> accountIdsSet = new Set<Id>();

        for (CMF_Info__c cmfInfo : cmfInfoList) {
            shipCmfToAccountMap.put(cmfInfo.Ship_CMF__c, cmfInfo.Account__c);
            //accountToDealerGroupMap.put(cmfInfo.Account__c, IMP_Project_Utility.getTopParentAccountId(cmfInfo.Account__c));
            accountIdsSet.add(cmfInfo.Account__c);
        }

        accountToDealerGroupMap.putAll( IMP_Project_Utility.getTopParentAccountId( accountIdsSet ) );

        for(SubProjectSite__c sps: newSites) {
            sps.Account__c = shipCmfToAccountMap.get(sps.Ship_CMF__c);
            sps.Dealer_Group__c = accountToDealerGroupMap.get(sps.Account__c);
        }

    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Responsible for the discardment of subProject sites with the same account or subproject
    Parameters:  subProjectIdsSet       - set of subProject IDs that were affected by the change in Ship CMF
                 accountIdsSet          - set of account IDs that were affected by the change in Ship CMF
                 randomSiteForErrorCall - any subProject site record that the error can be attached on to prevent the DML operation from committing when a duplicate site is found
    History
    12/29/14     Samuel Oberes       Created
    ------------------------------------------------------------*/
    public static void rejectDuplicateSites(Set<Id> subProjectIdsSet, Set<Id> accountIdsSet, SubProjectSite__c randomSiteForErrorCall) {

        // exit if randomSiteForErrorCall is null, because it means that no site changed its ship cmf
        if (randomSiteForErrorCall == null) {
            return;
        }
        
        List<SubProjectSite__c> existingSubProjectSitesList = [SELECT Id 
                                                                 FROM SubProjectSite__c 
                                                                WHERE Account__c IN :accountIdsSet
                                                                  AND SubProject__c IN :subProjectIdsSet];

        if (existingSubProjectSitesList.size() > 0) {
            randomSiteForErrorCall.addError(ERR_MESSAGE_DUPLICATE_SITE);
        }

    }

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: if a user selects a different CMF Name via the lookup that is associated with a different Account, CMF_Numbers field gets overwritten with just the Ship_CMF__c value now stamped
    Parameters:  oldMap   - Trigger.oldMap values 
                 newSites - Trigger.new values
    History
    02/06/15     Samuel Oberes       Created
    ------------------------------------------------------------*/
    public static void forcePopulateCMF(Map<Id, SubProjectSite__c> oldMap, List<SubProjectSite__c> newSites) {

        for (SubProjectSite__c newSite : newSites) {
            if (oldMap.get(newSite.Id).CMF_Name__c != newSite.CMF_Name__c && oldMap.get(newSite.Id).Account__c != newSite.Account__c) {
                newSite.CMF_Numbers__c = newSite.Ship_CMF__c;
            }
        }

    }
}