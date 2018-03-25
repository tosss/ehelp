//This is wrapper class for SyncAccountNWebID class. 
//This is create a Schedular and will run once in a month

global class SyncAccountNWebIDJobScheduler implements Schedulable 
{
    private String query = null;
    private List<String> accountList;

    global SyncAccountNWebIDJobScheduler(String query,List<String> aList){
        this.query = query;
        this.accountList = aList;
    } 
    
    global SyncAccountNWebIDJobScheduler(){
        this.query = null;
        accountList = null;
    } 
	
    global void execute(SchedulableContext SC) {
        SyncAccountNWebIDJob webIds = new SyncAccountNWebIDJob(this.query, this.accountList);
        database.executebatch(webIds);
    }
} // end of class