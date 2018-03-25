//2016-09-30 - vishal.bandari@cdk.com - RQ-07843:created the class
public class CPQ_OpportunitySplit_Handler 
{
    public static void beforeDelete(Map<Id,Opportunity_Split__c> oldMap)
    {
        CPQ_OpportunitySplit_Helper.preventDelete(oldMap);
    }
    
    public static void beforeInsert(List<Opportunity_Split__c> newList)
    {
        CPQ_OpportunitySplit_Helper.preventInsertAndUpdate(newList,true);
        CPQ_OpportunitySplit_Helper.setOpportunityLocation(newList,null, false);
    } 
     public static void beforeUpdate(List<Opportunity_Split__c> newList, Map<Id,Opportunity_Split__c> oldMap)
    {
        CPQ_OpportunitySplit_Helper.preventInsertAndUpdate(newList,false);
        CPQ_OpportunitySplit_Helper.setOpportunityLocation(newList, oldMap, true);
    } 
}