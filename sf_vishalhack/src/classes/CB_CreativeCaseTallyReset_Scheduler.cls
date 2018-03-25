//2016-01-14- anirudh.singh@cdk.com- Created this class to replace CB_CreativeCaseTallyOnWebID_Scheduler class due to naming standards issue.
global with sharing class CB_CreativeCaseTallyReset_Scheduler implements Schedulable
{
	public static string scheduleString='0 0 3 1 * ?'; //Every 1st of the month at 3AM 
	
	global void execute(SchedulableContext sc)
	{
		
		CB_CreativeCaseTallyReset_Batch batchclass=new CB_CreativeCaseTallyReset_Batch();
		database.executeBatch(batchclass);
	}
	
    global static string schedulefunc()
    {
		CB_CreativeCaseTallyReset_Scheduler scheduler=new CB_CreativeCaseTallyReset_Scheduler();
		return system.schedule('Creative Case Tally Reset on WebID', scheduleString, scheduler);
	}
}