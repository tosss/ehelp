//2015-12-03- anirudh.singh@cdk.com- Modified the API Version from 24.0 to 34.0. Also, corrected the indentation.
//2016-01-22- anirudh.singh@cdk.com- Modified the Trigger for the request RQ-06021 for bringing it up to standards.
//2016-02-24- anirudh.singh@cdk.com- Removed the Trigger.OldMap as it will be Null for after insert scenario.
trigger DSCB_AccountReLink on Account_ReLink__c(before insert, after insert) 
{
    if(Trigger.isBefore)
    {
        //2016-02-24- anirudh.singh@cdk.com- Added (ALL_CheckRecursive.runCodeBlockOnce('DSCB_AccountReLink_ConditionBeforeInsert') || test.isRunningTest())
        if((ALL_CheckRecursive.runCodeBlockOnce('DSCB_AccountReLink_ConditionBeforeInsert') || test.isRunningTest()) && Trigger.isInsert)
        {
            DSCB_AccountReLink_Handler.processAccountReLinksBeforeInsert(Trigger.New);
        }
    }
    else if(Trigger.isAfter)
    {
        //2016-02-24- anirudh.singh@cdk.com- Added (ALL_CheckRecursive.runCodeBlockOnce('DSCB_AccountReLink_ConditionAfterInsert') || test.isRunningTest())
        if((ALL_CheckRecursive.runCodeBlockOnce('DSCB_AccountReLink_ConditionAfterInsert') || test.isRunningTest()) && Trigger.isInsert)
        {
            //2016-02-24- anirudh.singh@cdk.com- Removed the Trigger.OldMap as it will be Null for after insert scenario.
            //2016-02-24- anirudh.singh@cdk.com- Also, modified the method to comment the Trigger.OldMap logic.
            DSCB_AccountReLink_Handler.processAccountReLinksAfterInsert(Trigger.New);
        }
    }
}