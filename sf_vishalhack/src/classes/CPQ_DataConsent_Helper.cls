//2016-10-12 vishal.bandari@cdk.com   - created Class- RQ-07963
public class CPQ_DataConsent_Helper 
{
    public static Account_Product_Data_Consent__c createProductDataConsent(String fieldValues,Id OpportunityId)
    {
        List<String> allFieldValues = fieldValues.split('\\$,\\$');
        if(allFieldValues != null && allFieldValues.size() == 5)
        {
            return new Account_Product_Data_Consent__c(
                Account__c = allFieldValues[0],
                Lead_to_Broad_Consent__c = (allFieldValues[1] != null && allFieldValues[1] != ''?Date.parse(allFieldValues[1]) == Date.today():false),
                Consent_Provided_Date__c = (allFieldValues[2] != null && allFieldValues[2] != ''? Date.parse(allFieldValues[2]):null),
                Consent_Provided__c = allFieldValues[3],
                Consented_Product__c = allFieldValues[4],
                Migration_ID__c = allFieldValues[0]+'-'+allFieldValues[4],
                Opportunity__c = OpportunityId
            );
        }
        return null;
    }
    
    public static void updateProductDataConsent(List<Opportunity> opportunityList)
    {
        Map<String,String> allDataConsentChanges = new Map<String,String>();
        for(Opportunity opportunityObj : opportunityList)
        {
            if(opportunityObj.CPQ_Data_Consent_Changes__c != null && opportunityObj.CPQ_Data_Consent_Changes__c!='')
            {
                List<String> dataConsentChangesList = opportunityObj.CPQ_Data_Consent_Changes__c.remove('\n').split('###');
                if(dataConsentChangesList != null)
                {
                    for(String dataConsentChanges : dataConsentChangesList)
                    {
                        allDataConsentChanges.put(dataConsentChanges.trim(),opportunityObj.Id);
                    }
                }
            }
        }
        if(allDataConsentChanges.size()>0)
        {
            List<Account_Product_Data_Consent__c> dataConsentChangesList = new List<Account_Product_Data_Consent__c>();
            if(allDataConsentChanges.size() > 0)
            {
                for(String dataConsentChanges : allDataConsentChanges.KeySet())
                {
                    dataConsentChangesList.add(createProductDataConsent(dataConsentChanges,allDataConsentChanges.get(dataConsentChanges)));
                }
                if(dataConsentChangesList.size() > 0)
                {
                    upsert dataConsentChangesList Migration_Id__c;
                }
            }            
        }
    }
}