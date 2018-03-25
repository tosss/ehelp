public class DS_DealStateUpdateController_Handler 
{ 
    public static Boolean AVP_RGM_Change;
    public static List<Deal_State__c> dealStateList; 
    public static Map<Id, User> userMap;
    public static map<string, Deal_State__c> regionToDealStateMap;
    public static void updateControllerEmail(List<AVP_RGM_Link__C> newList, Map<Id,AVP_RGM_Link__C> oldMap)
    {
        try
        {
            List<String> requiredRegions =  new List<String>();
            Set<ID> ControllerIDs = new Set<ID>();
            map<ID, string> avpIdToControllerEmail = new map<ID, string>();
            map<ID, user> ControllerMap;
            
            for(AVP_RGM_Link__c currentObj : newList) 
            {
                if(currentObj.Controller__c != oldMap.get(currentObj.Id).Controller__c)
                {
                    requiredRegions.add(currentObj.Region__c);
                    ControllerIDs.add(currentObj.Controller__c);
                } 
            }
            
            if(ControllerIDs != null && !ControllerIDs.isEmpty())
            {
                ControllerMap = new map<ID, User>([
                    Select ID, Name, Email From USer Where ID IN : ControllerIDs
                ]);
            }
            
            if(requiredRegions.size()>0)
            {
                //if(!Test.isRunningTest())
                {
                    dealStateList = [
                        SELECT ID, Account_Region__c, Controller_Email__c, Opportunity__r.Account.Region__c
                        FROM Deal_State__c 
                        WHERE Account_Region__c IN: requiredRegions 
                    ]; 
                }
                if(dealStateList.size()>0)
                {
                    regionToDealStateMap = new map<string, Deal_State__c>();
                    
                    for(Deal_State__c ds: dealStateList)
                    {
                        //have to reach account region, can't use Account_Region__c on deal state because it's a formula field
                        regionToDealStateMap.put(ds.opportunity__r.Account.Region__c, ds); 
                    }
                    
                    for(AVP_RGM_Link__C avp: newList)
                    {
                        if(avp.Region__c != null)
                        {
                            regionToDealStateMap.get(avp.Region__c).Controller_Email__c = ControllerMap.get(avp.Controller__c).Email;                                
                        }
                    }
                   
                   // dealStateList = DS_DealStateUpdateFields_Handler.updateControllerField(dealStateList); 
                    update regionToDealStateMap.values();
                }
                
            }
        }
        catch(exception e)
        {
            System.debug('Exception :'+e.getMessage()+' at '+e.getCause());
        }
    }
    
}