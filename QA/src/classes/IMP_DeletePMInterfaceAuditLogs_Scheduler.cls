/*--------------------------------------------------------
09/16/15  - Venkata Shrivol - Created
Description:  Scheduler class to delete the PM Interface Audit logs.

----------------------------------------------------------*/
global with sharing class IMP_DeletePMInterfaceAuditLogs_Scheduler implements Schedulable 
{
	global void execute(SchedulableContext sc)
	{
		list<PM_Interface_Audit_Log__c> listToDelete = [select Id from PM_Interface_Audit_Log__c  where CreatedDate < LAST_N_MONTHS:4 limit 10000];
		if(!listToDelete.isEmpty())
		{
			try
			{
				delete listToDelete;
			}
			catch(Exception e)
			{
				system.debug('-----EXCEPTION CAUSED-----'+e);
			}
		}
	}

}