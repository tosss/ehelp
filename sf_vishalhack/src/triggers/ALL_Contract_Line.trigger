//2016-10-04 - ragashalini.koka@cdk.com - RQ-07945 - added code to update Product_Current__c and Product__c on insert and update
//2016-11-17 - ragashalini.koka@cdk.com - RQ-08207 - added code to update WebId field on insert and update
//2017-01-11 - ragashalini.koka@cdk.com - RQ-07943 - added after update functionality
trigger ALL_Contract_Line on ALL_Contract_Line__c (before insert, before update, after update) 
{
    if(Trigger.isBefore)
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            ALL_Contract_Line_Handler.populateCurrentProduct(Trigger.old, Trigger.new, Trigger.isInsert);
			ALL_Contract_Line_Handler.updateWebId(Trigger.old, Trigger.new, Trigger.isInsert);
        }
    }
    
    if(Trigger.isAfter)
    {
        if(Trigger.isUpdate)
        {
            ALL_Contract_Line_Handler.updateContractAudit(Trigger.oldMap, Trigger.newMap);
        }
    }

}