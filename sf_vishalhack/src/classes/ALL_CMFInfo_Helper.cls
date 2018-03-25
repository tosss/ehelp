//2016-08-18 - vishal.bandari@cdk.com - RQ-07433:created the class
//2017-01-12 - ragashalini.koka@cdk.com -RQ-07433 - modified the code based on the changes
public class ALL_CMFInfo_Helper 
{
    public static void accountChangesFromCMF(Map<Id,String> accountIdToCMFMap)
    {
       List<Account> accList = new List<Account>();
            for(String accId : accountIdToCMFMap.keySet())
            {
                Account accObj = new Account();
                accObj.Id = accId;
                accObj.SLS_BaseLine_CMF_Number__c = accountIdToCMFMap.get(accObj.Id);
                accList.add(accObj);
            }
        
            update accList;
       
    }
}