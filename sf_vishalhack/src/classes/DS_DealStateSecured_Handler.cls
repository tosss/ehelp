//2016-01-22- anirudh.singh@cdk.com- Created this Handler class for the Trigger DS_DealStateSecured to bring it up to Standards for Request RQ-06022.
public class DS_DealStateSecured_Handler
{
    public static void preventMultipleRecsOnParent(List<Deal_State_Secured__c> newdealStateSecuredList)
    {
        String pageErrorMessage='Only one Deal State Secured document may be added per Deal State';
        
        ALL_UtilitiesMiscellaneous.PreventMultipleOnParent(newdealStateSecuredList, 'Deal_State__c', 
                                                           'Deal_State__c', 'Deal_State_Secured_Docs__r', 
                                                           pageErrorMessage);
    }
    
    public static void updateDealStateRecords(List<Deal_State_Secured__c> newdealStateSecuredList)
    {
    	boolean bool = ALL_CheckRecursive.runCodeBlockOnce('updateDealStateRecords');
    	
        if(bool)
        {
            List<Deal_State__c> dealStatesToUpdate=new List<Deal_State__c>();   
            
            for(Deal_State_Secured__c dss: newdealStateSecuredList)
            {
                Deal_State__c currentDealState=new Deal_State__c(
                    Id=dss.Deal_State__c, 
                    Deal_State_Secured_Id__c=(String)dss.Id
                );
                dealStatesToUpdate.add(currentDealState);
            }
            
            if(!dealStatesToUpdate.isEmpty())
            {
                database.update(dealStatesToUpdate);
            }
        }
    }
}