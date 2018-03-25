//2016-08-26 - Created - siva.pragada@cdk.com
public class ALL_ClientProfile_Handler 
{
    public static void mainMethod(list<Client_Profile__c> newList)
    {
        try
        {
            Set<ID> webIDset = new Set<ID>();
            
            for(Client_Profile__c cp: newList)
            {
                webIDset.add(cp.WebID__c);
            }
            
            map<ID, WebID__c> webIDsMap = new map<ID, WebID__c>([
                Select ID, Name,
                (Select ID, Name, WebID__c, Account_Status__c, Product_Mix__c, RecordType.Name 
                 From Account_Plans__r Where Account_Status__c = 'Active')  
                From WebID__c
                Where ID IN :webIDset
            ]);
            
            
            for(Client_Profile__c cp: newList)
            {
                //clear the field first
                cp.Product_Mix__c = null;
                
                if(cp.WebID__c != null) 
                {
                    WebID__c currentWebID = webIDsMap.get(cp.WebID__c);
                    list<Account_Plan__c> currentAccountPlans = currentWebID.Account_Plans__r;
                    
                    for(Account_Plan__c ap: currentAccountPlans)
                    {
                        if(ap.Account_Status__c == 'Active')
                        {
                            string currentRecordType = ap.recordType.Name;
                            
                            if(currentRecordType == 'AA Account Plan' && ap.Product_Mix__c != null)
                            { cp.Product_Mix__c = ap.Product_Mix__c; break; }
                            
                            if(currentRecordType == 'DAA Account Plan' && ap.Product_Mix__c != null)
                            { cp.Product_Mix__c = ap.Product_Mix__c; break; }
                            
                            if(currentRecordType == 'SEO Account Plan' && ap.Product_Mix__c != null)
                            { cp.Product_Mix__c = ap.Product_Mix__c; break; }
                            
                            if(currentRecordType == 'PowerSEO Account Plan' && ap.Product_Mix__c != null)
                            { cp.Product_Mix__c = ap.Product_Mix__c; }
                        }
                    }
                }    
            }
        }
        Catch(Exception exp)
        {
            ALL_UtilitiesMiscellaneous.logException(exp);
        }
    }
}