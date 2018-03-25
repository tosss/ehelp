@Istest
public class ALL_LightningUtility_Test {
    @testSetup
    public static void testsetup()
    {
        Account accObj = DS_TestObjects.NewAccount_Inserted();
    }
    public static testmethod void test()
    {
        ALL_LightningUtility.getSearchList('Account', 'Name', 'Test');
    }
}