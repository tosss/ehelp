/*----------------------------------------------------------
 * RQ-06546
 * 03-28-2016 -venkata.shrivol@cdk.com -created this class.
 * Description: Updates the Region of Account field on child deal state 
                records whenever region on account is updated.
 * Test Class: DS_UpdRegionOnDealStateFromAcc_Test
-----------------------------------------------------------*/
public class DS_UpdRegionOnDealStateFromAcc_Handler 
{
    public static void updateRegionOnDealStates(map<Id, string> inputAccountMap)
    {
        list<Deal_State__c> dealStateRecsToUpdate = new list<Deal_State__c>();
        for(Deal_State__c ds:[
            select Opportunity__r.AccountId, Region_Of_Account__c from Deal_State__c where Opportunity__r.AccountId IN:inputAccountMap.keySet()
        ])
        {
            ds.Region_Of_Account__c = inputAccountMap.get(ds.Opportunity__r.AccountId);
            dealStateRecsToUpdate.add(ds);
        }
        try{
        	update dealStateRecsToUpdate;    
        }
        catch(Exception e)
        {
            system.debug('------Exception Caught-------'+e);
        }
        
    }
}