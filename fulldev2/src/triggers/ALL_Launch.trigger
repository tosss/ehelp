trigger ALL_Launch on Launch__c (before insert, after insert, before update, after update) 
{
    if(Trigger.isAfter && ALL_CheckRecursive.runCodeBlockOnce('runOnlyOnceToavoidDuplicateCases'))
    {
        DS_Launch_Handler.processLaunch2CaseLogic();
    }
    
    if(Trigger.isBefore && ALL_CheckRecursive.runCodeBlockOnce('runOnlyOnceToUpdateLaunch'))
    {
        DS_Launch_Handler.CB_LaunchUpdateEmails();
    }
}