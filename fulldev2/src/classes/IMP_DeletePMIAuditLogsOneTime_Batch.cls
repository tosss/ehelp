/*
*/
global with sharing class IMP_DeletePMIAuditLogsOneTime_Batch implements Database.Batchable<sObject>
{
	global Database.QueryLocator start(Database.BatchableContext bc)
	{
		//string query = '';
		string query='select Id from PM_Interface_Audit_Log__c where CreatedDate < LAST_N_MONTHS:4 ';
		return Database.getQueryLocator(query);
		
	}
	global void execute(Database.BatchableContext bc, list<PM_Interface_Audit_Log__c> scope)
	{
		if(!scope.isEmpty())
		{
			try
			{
				delete scope;
			}
			catch(Exception ex)
			{
				system.debug(ex);
			}
		}
	}
	global void finish(Database.BatchableContext bc)
	{
		
	}

}