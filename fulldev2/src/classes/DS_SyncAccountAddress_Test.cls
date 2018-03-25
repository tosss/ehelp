@isTest
public class DS_SyncAccountAddress_Test 
{   
    static testMethod void unitTestIt()
    {
        string cdkGlobalAccId = CustomSettings__c.getInstance(userInfo.getOrganizationId()).CDK_Global_Account_Id__c; 
        Account a = DS_TestObjects.NewAccount();
        Account CDKglobalAcc = DS_TestObjects.NewAccount();
        CDKglobalAcc.Id = (ID)CDKglobalAccId;
        CDKglobalAcc.BillingCity = 'Andromeda';
        
        insert new list<Account> {a,CDKglobalAcc};
        
        contact c = DS_TestObjects.NewContact();
        c.AccountId = a.Id;
        insert c;
        
        CDKglobalAcc.BillingCity = 'Sedna';
        a.BillingCity = 'Seattle';
        update new list<Account>{a,CDKglobalAcc};
    }
}