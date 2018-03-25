/*--------------------------------------------------------------
09/18/15  - Venkata Shrivol -Created
Description - Test class for IMP_DeletePMInterfaceAuditLogs_Scheduler
 --------------------------------------------------------------*/
 
@isTest
public class IMP_DeletePMInterAuditLogsScheduler_Test {

    static testMethod void myUnitTest() 
    {
        list<sObject> listTest = Test.loadData(PM_Interface_Audit_Log__c.sobjectType, 'IMP_RecordsTestLoad_CSV');
    	String scheduleString = '0 0 15 1 * ?'; 
    	Test.StartTest();
    		IMP_DeletePMInterfaceAuditLogs_Scheduler testSchedular = new IMP_DeletePMInterfaceAuditLogs_Scheduler();
    		Id jobId = System.schedule('Scheduling DeleteTest', scheduleString, testSchedular);
        	CronTrigger ct = [select Id, CronExpression, TimesTriggered from CronTrigger where Id =:jobId];
        	system.assertEquals(scheduleString, ct.CronExpression);
        	System.assertEquals(0, ct.TimesTriggered);

    	Test.StopTest();
    }
}