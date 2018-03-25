//2016-07-18 - vishal.bandari@cdk.com - RQ-07371:created the class
//2016-08-10- anirudh.singh@cdk.com- Changed the API Name Opportunity_Site_Building__c to Opportunity_Location__c for RQ-07569.
//2016-09-22  -vishal.bandari@cdk.com - RQ-07834 : added condition for record type building in SOQL
public class CPQ_SOWQuestions_Helper 
{
    public static Map<Id, Opportunity_Location__c> getOpporunityBuildingsDetailsByIds(List<String> opportunityBuildingsIds)
    {
        return new Map<Id, Opportunity_Location__c>([
            SELECT ID, Opportunity__c, Site__c, Solution_Design_Building_ID__c, Solution_Design_ID__c
            FROM Opportunity_Location__c 
            WHERE ID IN: opportunityBuildingsIds
            AND RecordType.Name = 'Building'  //2016-09-22 vishal.bandari@cdk.com added condition for recordtype in SOQL
        ]);
    }
    
    public static Map<String, String> getOpporunityBuildingsDetailsBySite(Set<String> oppToSiteSet)
    {
        List<String> oppIds=new List<String>();
        List<String> siteIds=new List<String>();
        
        for(String oppToSiteString: oppToSiteSet)
        {
            oppIds.add(oppToSiteString.split(',')[0]);
            siteIds.add(oppToSiteString.split(',')[1]);
        }
        
        List<Opportunity_Location__c> oppSiteBuildingList=[
            SELECT ID, Opportunity__c, Site__c, Solution_Design_Building_ID__c, Solution_Design_ID__c
            FROM Opportunity_Location__c 
            WHERE Opportunity__c IN: oppIds
            AND Site__c IN: siteIds
        ];
        
        
        Map<String,String> reqOppSiteBuildingMap=new Map<String,String>();
        for(Opportunity_Location__c oppSiteBuildingObj: oppSiteBuildingList)
        {
            if(oppToSiteSet.contains(oppSiteBuildingObj.Opportunity__c+','+oppSiteBuildingObj.Site__c))
            {
                reqOppSiteBuildingMap.put(oppSiteBuildingObj.Opportunity__c+','+oppSiteBuildingObj.Site__c, oppSiteBuildingObj.Id);
            }
        }
        
        return reqOppSiteBuildingMap;
    }
}