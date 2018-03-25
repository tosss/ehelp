/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas
Description: 
Test Class: 
History
10/29/15    Kimiko Roberto      Created
------------------------------------------------------------*/
@isTest
public class IMP_ForceLogicalRollup_Scheduler_Test{    
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    static testmethod void testForceRollupSchedule() {
      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new IMP_ForceLogicalRollup_Scheduler());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
    }
}