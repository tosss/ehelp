//2017-06-19- anirudh.singh@cdk.com- Created this class for RQ-09460.
global class ALL_TaskEvent_Scheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        ALL_TaskEvent_Batch batch1=new ALL_TaskEvent_Batch();
        batch1.queryStr='SELECT WhatId, WhoId, AccountId, Primary_Account__c FROM Task WHERE Primary_Account__c=Null'
            +' AND (WhatId!=Null OR WhoId!=Null)';
        Id batchId1=Database.executeBatch(batch1);
        
        ALL_TaskEvent_Batch batch2=new ALL_TaskEvent_Batch();
        batch2.queryStr='SELECT WhatId, WhoId, AccountId, Primary_Account__c FROM Event WHERE Primary_Account__c=Null'
            +' AND (WhatId!=Null OR WhoId!=Null)';
        Id batchId2=Database.executeBatch(batch2);
    }
}