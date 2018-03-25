/*--------------------------------------------------------
* 08/03/2015  -Venkata Shrivol  -Created
* Description - Test class for CB_CreativeCaseTallyOnWebID_Scheduler
* ---HISTORY-----


 ---------------------------------------------------------*/
@isTest
private class CB_CreativeCseTallyOnWebIDScheduler_Test 
{

    static testMethod void schedularTestForCCTallyReset() 
    {
       Test.startTest();
       	CB_CreativeCaseTallyOnWebID_Scheduler testCCTallyScheudular= new CB_CreativeCaseTallyOnWebID_Scheduler();
        //CB_CreativeCaseTallyOnWebID_Scheduler.schedulefunc();
       	string testScheduleString = '0 0 3 1 * ?'; //Every 1st of the month at 3AM
       	system.schedule('Test for CCTally Reset Schedular', testScheduleString, testCCTallyScheudular);
       Test.stopTest(); 
    }
}