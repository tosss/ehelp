//2017-04-17 ragashalini.koka@cdk.com - Created this class
@isTest
public class ALL_Contract_Test 
{
    @testSetup
    static void setupTestData()
    {
        Account defaultAcc = DS_TestObjects.NewAccount_Inserted();
        CustomSettings__c settings = CustomSettings__c.getOrgDefaults();
        settings.Default_CPQ_Bulk_Load_Account__c = defaultAcc.Id;
        insert settings;
        
       	Account acc =  DS_TestObjects.NewAccount();
        acc.PartyID__c = '12344545';
        acc.Account_Number__c = '545452';
        insert acc;
    }
    
    testmethod static void validateContractInsert()
    {
        Test.startTest();
        List<Contract> contractList = new List<Contract>();
        CustomSettings__c settings = CustomSettings__c.getOrgDefaults();
        Id defaultAccId = settings.Default_CPQ_Bulk_Load_Account__c;
        for(Integer i = 0;i < 2;i++)
        {
            Contract con = new Contract();
            con.Name = 'Test Contract ' + i; 
            con.AccountId = defaultAccId;
            con.Status = 'Draft';
            con.Migration_ID__c = String.valueOf(Math.random());
            con.External_Data_Source__c = 'ARNA';
            if(i == 0)
            {
             	con.Party_ID__c = '12344545';   
            }
            else if(i == 1)
            {
                con.DMG_Account_Number__c = '545452';
            }
            contractList.add(con);
        }
        insert contractList;
        
        Account acc = [SELECT Id FROM Account WHERE PartyID__c = '12344545' LIMIT 1];
        Contract contractRec = [SELECT Id, AccountId FROM Contract WHERE Party_ID__c = '12344545' LIMIT 1];
        System.assertEquals(acc.Id, contractRec.AccountId);
        Test.stopTest();
    }

}