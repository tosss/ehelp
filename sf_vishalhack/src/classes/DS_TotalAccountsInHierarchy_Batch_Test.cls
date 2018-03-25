@isTest
public class DS_TotalAccountsInHierarchy_Batch_Test 
{
    static testMethod void unitTest()
    {
        Account acc = DS_TestObjects.NewAccount_Inserted();
        
        Test.startTest();
        DS_TotalAccountsInHierarchy_Batch spaceCode = new DS_TotalAccountsInHierarchy_Batch();
        ID batchcoded = Database.executebatch(SpaceCode); 
        Test.stopTest();
    }
}