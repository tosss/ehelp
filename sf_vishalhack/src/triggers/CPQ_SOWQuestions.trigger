//2016-07-18 - vishal.bandari@cdk.com - RQ-07371:created the trigger
trigger CPQ_SOWQuestions on SOW_Question__c (before insert, before update) 
{
    if(Trigger.isInsert && Trigger.isBefore && ALL_CheckRecursive.runCodeBlockOnce('CPQ_SOWQuestions_BeforeInsert'))
    {
        CPQ_SOWQuestions_Handler.beforeInsert(Trigger.New);
    }
    else if(Trigger.isUpdate && Trigger.isBefore && ALL_CheckRecursive.runCodeBlockOnce('CPQ_SOWQuestions_BeforeUpdate'))
    {
        CPQ_SOWQuestions_Handler.beforeUpdate(Trigger.New, Trigger.OldMap);
    }
}