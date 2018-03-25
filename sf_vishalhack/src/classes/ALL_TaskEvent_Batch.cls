//2017-06-19- anirudh.singh@cdk.com- Created this class for RQ-09460.
global class ALL_TaskEvent_Batch implements Database.Batchable<sObject>, Database.Stateful
{
    //This is the query String.
    public String queryStr;
    
    //This list will hold the Sobject record Ids to delete.
    public List<sObject> sObjectRecsToModify;
    
    global ALL_TaskEvent_Batch()
    {
        sObjectRecsToModify=new List<sObject>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> sObjectList)
    {
        sObjectRecsToModify.addAll(ALL_TaskEvent_Helper.populatePrimaryAccField(sObjectList));
    }
    
    global void finish(Database.BatchableContext bc)
    {
        try
        {
            if(sObjectRecsToModify.size()>0)
            {
                Database.update(sObjectRecsToModify);
            }
        }
        catch(Exception ex)
        {
            system.debug('Exception---->'+ex.getMessage());
        }
    }
}