/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Handles trigger context methods
Test Class:  IMP_SubProjectSite_Test
History
12/29/14     Samuel Oberes       Created
02/06/15     Samuel Oberes       Updated error message ERR_MESSAGE_DUPLICATE_SITE
07/28/15     Samuel Oberes       added refreshRMSRequestIdField method
11/12/15     Venkata Shrivol	 commented out the DealerGroup field assignment as it is populated by
								 for formula field now
								 
12/11/15    Venkata Shrivol		Added all_checkrecursive check for before update call on rejectDuplicateSites method
04/18/17    Venkata Shrivol     added a null check on account assignment in populateAccountAndDealerGroup method
------------------------------------------------------------*/
public class IMP_SubProjectSite_Handler {
	
	private static map<Id, boolean> checkrecursiveMap =null;

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

        for(SubProjectSite__c sps: newSites) 
        {
        	Id AccountId = shipCmfToAccountMap.get(sps.Ship_CMF__c);
        	if(AccountId != null){
        		sps.Account__c = shipCmfToAccountMap.get(sps.Ship_CMF__c);
        	}
            //sps.Dealer_Group__c = accountToDealerGroupMap.get(sps.Account__c);
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
    public static void rejectDuplicateSites(Set<Id> subProjectIdsSet, Set<Id> accountIdsSet, SubProjectSite__c randomSiteForErrorCall, boolean isupdate) {
		
		boolean checkpoint = true;
        // exit if randomSiteForErrorCall is null, because it means that no site changed its ship cmf
        if (randomSiteForErrorCall == null) {
            return;
        }
        if(subProjectIdsSet == null || accountIdsSet == null){
        	return;
        }
        //system.debug('------checkrecursiveMap-------'+checkrecursiveMap);
        if(isupdate)
        {
        	if(checkrecursiveMap==null)
	        {
	        	checkrecursiveMap = new map<Id, boolean>();
	        }
	        checkPoint = checkrecursiveMap.containsKey(randomSiteForErrorCall.Id)? checkrecursiveMap.get(randomSiteForErrorCall.Id) : true;
	    }
        if(checkPoint)
        {
        	if(isupdate)
        	{
        		checkrecursiveMap.put(randomSiteForErrorCall.Id, false);	
        	}
        	
        	
        	List<SubProjectSite__c> existingSubProjectSitesList = [SELECT Id 
                                                                 FROM SubProjectSite__c 
                                                                WHERE Account__c IN :accountIdsSet
                                                                  AND SubProject__c IN :subProjectIdsSet];
	        if (existingSubProjectSitesList.size() > 0) {
	            randomSiteForErrorCall.addError(ERR_MESSAGE_DUPLICATE_SITE);
	        }
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

    /*------------------------------------------------------------
    Author:      Samuel Oberes
    Company:     Cloud Sherpas
    Description: Refreshes a site's RMS_Request_Ids__c field by recreating the concatenation of its values and adding the newly inserted RMS request IDs in the CMFtoSubProjectSite__c object.
    Parameters:  recs - Trigger.new values
    History
    07/28/15     Samuel Oberes       Created
    10/20/15     Samuel Oberes       Updated logic to cater for CMFs
    ------------------------------------------------------------*/
    public static void refreshRMSRequestIdField(List<CMFtoSubProjectSite__c> recs) {

        // It is possible that there are multiple records containing the same Site Id, but with different RMS request Ids.
        // To organize things, create a map of site ids, where its value is a set of all the RMS request Ids.
        Map<Id, Set<String>> siteIdsToRMSRequestIdsSetMap = new Map<Id, Set<String>>();

        // It is possible that there are multiple records containing the same Site Id, but with different CMF Ids.
        // To organize things, create a map of site ids, where its value is a set of all the CMF Ids.
        Map<Id, Set<String>> siteIdsToCMFIdsSetMap = new Map<Id, Set<String>>();

        for (CMFtoSubProjectSite__c r : recs)
        {
            if (siteIdsToRMSRequestIdsSetMap.containsKey(r.SubProjectSite__c))
            {
                siteIdsToRMSRequestIdsSetMap.get(r.SubProjectSite__c).add(r.RMS_Request_Id__c);
            }
            else
            {
                siteIdsToRMSRequestIdsSetMap.put(r.SubProjectSite__c, new Set<String>{ r.RMS_Request_Id__c });
            }

            if (siteIdsToCMFIdsSetMap.containsKey(r.SubProjectSite__c))
            {
                siteIdsToCMFIdsSetMap.get(r.SubProjectSite__c).add(r.Ship_CMF__c);
            }
            else
            {
                siteIdsToCMFIdsSetMap.put(r.SubProjectSite__c, new Set<String>{ r.Ship_CMF__c });
            }
        }

        Set<Id> siteIds = new Set<Id>();
        siteIds.addAll(siteIdsToRMSRequestIdsSetMap.keySet());
        siteIds.addAll(siteIdsToCMFIdsSetMap.keySet());

        // Query for the value of the RMS_Request_Ids__c field of each site
        Map<Id, SubProjectSite__c> subProjectSiteMap = new Map<Id, SubProjectSite__c>([SELECT Id, RMS_Request_Ids__c, CMF_Numbers__c 
                                                                                         FROM SubProjectSite__c 
                                                                                        WHERE Id IN :siteIds]);

        // Iterate through all of the sites contained in siteIdsToRMSRequestIdsSetMap and siteIdsToCMFIdsSetMap.
        // If a new RMS request Id is not yet in the site's RMS_Request_Ids__c/CMF_Numbers__c field, append the entity number to the site's respective field and update the site.
        Map<Id, SubProjectSite__c> subProjectSitesToUpdateMap = new Map<Id, SubProjectSite__c>();
        for (Id siteId : siteIds)
        {
            if (siteIdsToRMSRequestIdsSetMap.keySet().contains(siteId))
            {
                Set<String> siteExistingRMSRequestIdsSet = new Set<String>(IMP_Project_Utility.parseDelimitedString(subProjectSiteMap.get(siteId).RMS_Request_Ids__c, ',', true));
                Set<String> newRMSRequestIdsToAddToSiteSet = new Set<String>();
                for (String rmsRequestId : siteIdsToRMSRequestIdsSetMap.get(siteId))
                {
                    if (!siteExistingRMSRequestIdsSet.contains(rmsRequestId))
                    {
                        newRMSRequestIdsToAddToSiteSet.add(rmsRequestId);
                    }
                }

                if (!newRMSRequestIdsToAddToSiteSet.isEmpty())
                {
                    siteExistingRMSRequestIdsSet.addAll(newRMSRequestIdsToAddToSiteSet);
                    SubProjectSite__c siteToUpdate = subProjectSiteMap.get(siteId);
                    siteToUpdate.RMS_Request_Ids__c = String.join(new List<String>(siteExistingRMSRequestIdsSet), ',');
                    subProjectSitesToUpdateMap.put(siteToUpdate.Id, siteToUpdate);
                }
            }

            if (siteIdsToCMFIdsSetMap.keySet().contains(siteId))
            {
                Set<String> siteExistingCMFIdsSet = new Set<String>(IMP_Project_Utility.parseDelimitedString(subProjectSiteMap.get(siteId).CMF_Numbers__c, ',', true));
                Set<String> newCMFIdsToAddToSiteSet = new Set<String>();
                for (String cmfId : siteIdsToCMFIdsSetMap.get(siteId))
                {
                    if (!siteExistingCMFIdsSet.contains(cmfId))
                    {
                        newCMFIdsToAddToSiteSet.add(cmfId);
                    }
                }

                if (!newCMFIdsToAddToSiteSet.isEmpty())
                {
                    siteExistingCMFIdsSet.addAll(newCMFIdsToAddToSiteSet);
                    SubProjectSite__c siteToUpdate = new SubProjectSite__c();
                    
                    if (subProjectSitesToUpdateMap.keySet().contains(siteId))
                    {
                        siteToUpdate = subProjectSitesToUpdateMap.get(siteId);
                    }
                    else
                    {
                        siteToUpdate = subProjectSiteMap.get(siteId);
                    }
                    
                    siteToUpdate.CMF_Numbers__c = String.join(new List<String>(siteExistingCMFIdsSet), ',');
                    subProjectSitesToUpdateMap.put(siteToUpdate.Id, siteToUpdate);
                }
            }
            
        }

        if (!subProjectSitesToUpdateMap.isEmpty()) 
        {
            update subProjectSitesToUpdateMap.values();
        }

    }
}