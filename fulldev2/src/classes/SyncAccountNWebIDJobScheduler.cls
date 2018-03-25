//This is wrapper class for SyncAccountNWebID class. 
//This is create a Schedular and will run once in a month
//2015-09-22- anirudh.singh@cdk.com- To upgrade the API Version FROM 24.0 to 34.0.
global class SyncAccountNWebIDJobScheduler implements Schedulable 
{
    private String query=Null;
    private List<String> accountList;
    
    global SyncAccountNWebIDJobScheduler(String query, List<String> aList)
    {
        this.query=query;
        this.accountList=aList;
    } 
    
    global SyncAccountNWebIDJobScheduler()
    {
        this.query=Null;
        accountList=Null;
    } 
    
    global void execute(SchedulableContext SC)
    {
        SyncAccountNWebIDJob webIds=new SyncAccountNWebIDJob(this.query, this.accountList);
        database.executebatch(webIds);
    }
} // end of class