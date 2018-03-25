//2017-04-12 ragashalini.koka@cdk.com - Created this class for RQ-09011
public class ALL_Contract_Handler 
{
    public static void updateAccount(List<Contract> contractList)
    {
        Set<String> partyNumberSet = new Set<String>();
        Set<String> accountNumberSet = new Set<String>();
        CustomSettings__c settings = CustomSettings__c.getOrgDefaults();
        Id defaultAccId = settings.Default_CPQ_Bulk_Load_Account__c;
        for(Contract con : contractList)
        {
            //System.debug('account Id : ' + con.AccountId + '---' + defaultAccId);
            if(con.AccountId == null || con.AccountId == defaultAccId)
            {
                if(con.Party_ID__c != null && con.Party_ID__c.length() > 0) 
                {
                    partyNumberSet.add(con.Party_ID__c);
                }
                else if(con.DMG_Account_Number__c != null && con.DMG_Account_Number__c.length() > 0)
                {
                    accountNumberSet.add(con.DMG_Account_Number__c);
                }
            }
        }
      
        List<Account> accList = [SELECT Id,PartyID__c, Account_Number__c FROM Account WHERE PartyID__c IN :partyNumberSet OR Account_Number__c IN :accountNumberSet];
        Map<String,Id> partyToAccIdMap = new Map<String,Id>();
        Map<String,Id> accountNumberToAccIdMap = new Map<String,Id>();
        
        for(Account acc : accList)
        {
            if(acc.PartyID__c != null && acc.PartyID__c.length() > 0)
            {
                partyToAccIdMap.put(acc.PartyID__c,acc.Id);
            }
            if(acc.Account_Number__c != null && acc.Account_Number__c.length() > 0)
            {
                accountNumberToAccIdMap.put(acc.Account_Number__c, acc.Id);
            }
        }
       // System.debug('partyToAccIdMap :' + partyToAccIdMap);
       // System.debug('accountNumberToAccIdMap :' + accountNumberToAccIdMap);
        for(Contract con : contractList)
        {
            if(con.AccountId == null || con.AccountId == defaultAccId) 
            {
                if(partyToAccIdMap.containsKey(con.Party_ID__c))
                {
                    con.AccountId = partyToAccIdMap.get(con.Party_ID__c);
                }
                else if(accountNumberToAccIdMap.containsKey(con.DMG_Account_Number__c))
                {
                    con.AccountId = accountNumberToAccIdMap.get(con.DMG_Account_Number__c);
                }
            }
        }
    }
    
}