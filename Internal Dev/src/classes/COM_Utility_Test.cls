@IsTest
public class COM_Utility_Test {

    @IsTest static void test1()
    {
        COM_UtilityMock fakeResponse = new COM_UtilityMock(200,
                                                               'Complete',
                                                               '[{"Name": "sForceTest1"}]',
                                                               null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        COM_Utility.stockTickerServer();
    }
    
    @IsTest static void test12()
    {
        COM_UtilityMock fakeResponse = new COM_UtilityMock(300,
                                                               'Complete',
                                                               '[{"Name": "sForceTest1"}]',
                                                               null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        COM_Utility.stockTickerServer();
    }
    
}