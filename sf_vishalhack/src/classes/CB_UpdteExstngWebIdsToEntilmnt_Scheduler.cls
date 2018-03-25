global with sharing class CB_UpdteExstngWebIdsToEntilmnt_Scheduler implements Schedulable{
	
	
	global void execute(SchedulableContext sc)
	{
		
		CB_UpdateExistingWebIdsToEntilmnts_Batch batchclass = new CB_UpdateExistingWebIdsToEntilmnts_Batch();
		database.executeBatch(batchclass);
	}
	

}