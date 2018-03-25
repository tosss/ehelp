//2015-09-23- anirudh.singh@cdk.com- Upgraded the API Version FROM 27.0 to 34.0.
//2016-01-21- anirudh.singh@cdk.com- Modified this trigger for bringing it up to the Standards as per Request RQ-06024.
trigger DS_KeyRepChange on Key_Rep_Changes__c(before insert) 
{
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert)
        {
            DS_KeyRepChange_Handler.addErrorToInsertedRecords(Trigger.New);
        }
    }
}