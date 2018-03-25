/*
 *  CB SyncWebId Account Team Members Scheduler Code
 *  (ONLY RUN THIS AS ADMIN)
 *
 * Scheduler String (sch) means, run at every:
 *   0 Seconds
 *   0 Minutes
 *   3 Hour (3am)
 *   Of * (Every) Day of the Month
 *   Of * (Every) Month
 *   On ? (Any) Day of the Week
 *   Between the Year 2012-2030
 *
	CB_WebIDAccountTeamMembersBatchScheduler s = new CB_WebIDAccountTeamMembersBatchScheduler();
	String sch = '0 0 4 * * ? 2012-2030';
	System.schedule('CB SyncWebId Account Team Members', sch, s);
 */

global class CB_WebIDAccountTeamMembersBatchScheduler implements Schedulable 
{
    global void execute(SchedulableContext SC) {
        CB_WebIDAccountTeamMembersBatch b = new CB_WebIDAccountTeamMembersBatch();
        ID BatchId = Database.executeBatch(b, 1);
    }
}