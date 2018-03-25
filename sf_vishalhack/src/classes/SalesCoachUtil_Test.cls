//2015-11-13- anirudh.singh@cdk.com- Created this test class for SalesCoachUtil. Earlier no test class existed for SalesCoachUtil.
@isTest
public class SalesCoachUtil_Test
{
    private static testmethod void testOne()
    {
        test.startTest();
        system.assert(SalesCoachUtil.getOpptyStages().size()>0);
        test.stopTest();
    }
}