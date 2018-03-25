public class DS_DealStateNullifyFields_Handler 
{
    public static Map<String,DealStateFieldsToNull__c> fieldsMap;
    
    public static void nullifyFields(List<Deal_State__c> newList, Map<id,Deal_State__c> oldMap)
    {
        try
        {
            
            if(!Test.isRunningTest())
            {
                fieldsMap = DealStateFieldsToNull__c.getAll();
            }
            for(Deal_State__c ds: newList)
            {
                Deal_State__c oldDS = oldMap.get(ds.id);
                if(ds.Docusign_Envelope_Status__c!=oldDS.Docusign_Envelope_Status__c && ds.Docusign_Envelope_Status__c.toLowerCase()=='voided')
                {
                    
                    for(DealStateFieldsToNull__c dsfv: fieldsMap.values())
                    {
                        if(dsfv.Field_Type__c.toLowerCase() == 'text'|| dsfv.Field_Type__c.toLowerCase() == 'date/time')
                        {  
                            ds.put(dsfv.Field_API_Name__c,null);
                        }
                        else if(dsfv.Field_Type__c.toLowerCase() == 'checkbox')
                        {
                            ds.put(dsfv.Field_API_Name__c,false);
                        }
                    }
                    ds.put('Deal_Status__c','Envelope Voided');
                }
            } 
        }
        catch(Exception e)
        {
            System.debug('Exception :' + e.getMessage()+' at '+e.getLineNumber());
        }
    }
}