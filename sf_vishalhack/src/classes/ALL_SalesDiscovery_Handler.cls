//2017-05-17 - lalitha.adduru@cdk.com - modified this  class to implement RQ-09223
public class ALL_SalesDiscovery_Handler 
{
    public static void beforeInsert(List<Sales_Discovery__c> newList)
    {
        Set<Id> opportunityIds = new Set<Id>();
        for(Sales_Discovery__c salesDiscoveryObj : newList)
        {
            opportunityIds.add(salesDiscoveryObj.Opportunity__c);
        }
        
        //2017-05-17 - lalitha.adduru@cdk.com - added Account.Region__c to the query- RQ-09223
        Set<String> regionSet = new Set<String>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([
            SELECT Id, (SELECT Id FROM Sales_Discovery__r), Account.Region__c 
            FROM Opportunity 
            WHERE Id IN: opportunityIds
        ]);
        
        for(Opportunity opp : opportunityMap.values())
        {
            regionSet.add(opp.Account.Region__c);
        }
		
        //2017-05-17 - lalitha.adduru@cdk.com - get relevant AVP RGM Links- RQ-09223
        Map<String, Id> regionToUserMap = new Map<String, Id>();
        List<AVP_RGM_Link__c> linkList = new List<AVP_RGM_Link__c>();
        linkList = [
            SELECT Id, Region__c, Implementation_Director__c
            FROM AVP_RGM_Link__c
            Where Region__c in :regionSet
        ];
        
        for(AVP_RGM_Link__c link : linkList)
        {
            regionToUserMap.put(link.Region__c, link.Implementation_Director__c);
        }

        for(Sales_Discovery__c salesDiscoveryObj : newList)
        {
            List<Sales_Discovery__c> existingList = opportunityMap.get(salesDiscoveryObj.Opportunity__c).Sales_Discovery__r;
            if(existingList != null  &&  existingList.size() > 0)
            {
                salesDiscoveryObj.addError('Sales Discovery already exists with given Opportunity');
            }
            else
            {
                //2017-05-17 - lalitha.adduru@cdk.com - populate Implementation DIr on SD from relevant AVP RGM Links- RQ-09223
                String region = opportunityMap.get(salesDiscoveryObj.Opportunity__c).Account.Region__c;
                salesDiscoveryObj.Implementation_Director__c = regionToUserMap.get(region);
                system.debug('modified  -- >'+salesDiscoveryObj.Implementation_Director__c);
            }            
        }
    }
}