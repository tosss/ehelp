global class DS_Account_LastActivity_Scheduler implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
	    DS_Account_LastActivity b = new DS_Account_LastActivity();
	    b.useLastRunConditions = true; // optional
	    
	    // batch size of 100 because there is one query in the execute method Account loop and one query outside the loop = 101 queries per execute
	    ID BatchId = Database.executeBatch(b,100);
    }
}