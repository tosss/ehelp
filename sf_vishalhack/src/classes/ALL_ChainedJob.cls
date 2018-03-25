public class ALL_ChainedJob implements Database.Batchable<SObject>, Database.Stateful {
     
    public String description {get; private set;}
     
    private Database.Batchable<SObject> delegate;
    private Integer scope;
    private ALL_ChainedJob nextJob;
     
    public ALL_ChainedJob(
            Database.Batchable<SObject> delegate,
            Integer scope,
            String description
            ) {
        this.delegate = delegate;
        this.scope = scope;
        this.description = description;
    }
     
    public Database.QueryLocator start(Database.BatchableContext context) {
        return (Database.QueryLocator) delegate.start(context);
    }
     
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        delegate.execute(context, scope);
    }
     
    public void finish(Database.BatchableContext context) {
        try {
            delegate.finish(context);
        } finally {
            if (nextJob != null) {
                // Next job
                nextJob.execute();
            }
        }
    }
     
    // Create the list and then invoke this method
    public static Id executeAsChain(List<ALL_ChainedJob> jobs) {
        if(Test.isRunningTest())
        {
            ALL_ChainedJob chainedObj = jobs.get(0);
            return Database.executeBatch(chainedObj.delegate); 
        }
        else
        {
            if (jobs.size() > 0) {
                for (Integer i = 0; i < jobs.size() - 1; i++) {
                    jobs[i].nextJob = jobs[i + 1];
                }
                // First job
                return jobs[0].execute();
            } else {
                return null;
            }  
        }
        
    }
     
    private Id execute() {
        System.debug('>>> executing "' + this.description + '"');
        return Database.executeBatch(this, scope);
    }
}