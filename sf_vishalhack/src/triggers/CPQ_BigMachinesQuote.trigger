//2016-08-08 - vishal.bandari@cdk.com - added before Delete Code to delete record with particular status - RQ-07540.
//2016-10-18 - ragashalini.koka@cdk.com - added after insert and after update funtionality to update the Sites for RQ-08013
//2016-11-10 - ragashalini.koka@cdk.com - added code to update fields related to NSA before insert for RQ-08164
//2016-11-21 - vishal.bandari@cdk.com - added code to Parse Pending Approval String - RQ-08211
//2017-04-14 ragashalini.koka@cdk.com - Added a method updateQuoteCreationOnOpportunity on after insert and update for RQ-09040
trigger CPQ_BigMachinesQuote on BigMachines__Quote__c (before delete, after insert, after update, before insert,before update) 
{
    //2016-08-08 - vishal.bandari@cdk.com - added before Delete Code to delete record with particular status - RQ-07540
    if(Trigger.IsDelete)
    {
        if(Trigger.IsBefore)
        {
           CPQ_BigMachinesQuote_Handler.beforeDelete(Trigger.old);
        }
    }
    //2016-10-18 - ragashalini.koka@cdk.com - added after insert and after update funtionality to update the Sites for the RQ-08013
    if(Trigger.isAfter && ALL_CheckRecursive.runCodeBlockOnce('BigMachineQuoteAfterInsertUpdate'))
    {
        if(Trigger.isInsert || Trigger.isUpdate)
        {
            CPQ_BigMachinesQuote_Handler.updateSitesOnOpportunity(Trigger.old, Trigger.new, Trigger.isInsert);
            CPQ_BigMachinesQuote_Handler.updateQuoteCreationOnOpportunity(Trigger.old, Trigger.new);
        }
     
    }
    
    if(Trigger.isBefore  && ALL_CheckRecursive.runCodeBlockOnce('BigMachineQuoteBeforeInsert')) 
    {
        if(Trigger.isInsert) 
        {
            CPQ_BigMachinesQuote_Handler.updateNSAInfo(Trigger.new);
            
            //2016-11-21 - vishal.bandari@cdk.com - added code to Parse Pending Approval String - RQ-08211
            CPQ_BigMachinesQuote_Handler.beforeInsert(Trigger.new);
        }
        
    }
    
    //2016-11-21 - vishal.bandari@cdk.com - added code to Parse Pending Approval String - RQ-08211
    if(Trigger.isBefore  && ALL_CheckRecursive.runCodeBlockOnce('BigMachineQuoteBeforeUpdate')) 
    {
        if(Trigger.IsUpdate)
        {
            CPQ_BigMachinesQuote_Handler.beforeUpdate(Trigger.new,Trigger.oldMap);
        }
        
    }
}