@isTest
public class EMP_MyInformationController_Test 
{
    testMethod static void test_loadData()
    {
        generateData();
        test.startTest();
        EMP_MyInformationController controller = new EMP_MyInformationController();
        test.stopTest();
        system.assertEquals(1, controller.infoSource.size());
    }
    
    private static void generateData()
    {
        Account acc =  new Account();
        acc.Name = 'Shared Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Austral';
        con.FirstName = 'Rey';
        con.AccountId = acc.id;
        con.User__c = userinfo.getUserId();
        con.Role__c = 'Test Role';
        insert con;

    }
}