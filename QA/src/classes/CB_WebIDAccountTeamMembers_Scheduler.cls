//2016-02-22- anirudh.singh@cdk.com- Created this class as the earlier class was not following standards.
global class CB_WebIDAccountTeamMembers_Scheduler implements Schedulable
{
    global void execute(SchedulableContext SC)
    {
        CB_WebIDAccountTeamMembers_Batch batch=new CB_WebIDAccountTeamMembers_Batch();
        Id BatchId=Database.executeBatch(batch, 1);
    }
}