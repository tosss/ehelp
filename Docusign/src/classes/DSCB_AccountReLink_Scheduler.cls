/*
 *  Account ReLink Scheduler Code
 *  (ONLY RUN THIS AS ADMIN)
 *
 * Scheduler String (sch) means, run at every:
 *   0 Seconds
 *   0 Minutes
 *   0,1,2,22,23 Hours (10am-2am: 12:00am, 1:00am, 2:00am, 10:00am, 11:00am)
 *   Of * (Every) Day of the Month
 *   Of * (Every) Month
 *   On ? (Any) Day of the Week
 *   Between the Year 2012-2030
 *
	DSCB_AccountReLink_Scheduler s = new DSCB_AccountReLink_Scheduler();
	String sch = '0 0 0,1,2,22,23 * * ? 2012-2030';
	System.schedule('DSCB Account ReLink', sch, s);
 */

global class DSCB_AccountReLink_Scheduler implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        DSCB_AccountReLinkBatch b = new DSCB_AccountReLinkBatch();
        ID BatchId = Database.executeBatch(b,1);
    }
}