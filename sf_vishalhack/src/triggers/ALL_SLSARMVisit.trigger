//2016-02-08- lalitha.adduru@cdk.com- created the trigger SLS_ARM_Visit__c
//2017-01-30 - ragashalini.koka@cdk.com - added before insert, after insert and after update functionality for RQ-08537
//2017-04-11 - ragashalini.koka@cdk.com - added setKeyDOSEmail method to populate Key_DOS_Email__c for RQ-09007
trigger ALL_SLSARMVisit on SLS_ARM_Visit__c (before insert, after insert, after update, before update) 
{
    if(trigger.isBefore )
    {
        if(Trigger.isInsert) 
        {
            All_SLSARMVisit_Handler.setSupervisor(trigger.New);   
            ALL_SLSARMVisit_Handler.populateARMSupervisor(Trigger.new);
            ALL_SLSARMVisit_Handler.setKeyDOSEmail(Trigger.new);
        }
        else if(Trigger.isUpdate) 
        {
            ALL_SLSARMVisit_Handler.updateStatus(Trigger.old, Trigger.new);
            ALL_SLSARMVisit_Handler.setKeyDOSEmail(Trigger.new);
        } 
        
        
    }
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert) 
        {
            ALL_SLSARMVisit_Handler.submitForApproval(Trigger.old, Trigger.new);
            ALL_SLSARMVisit_Handler.postOnChatter(Trigger.oldMap, Trigger.new);
        }
        else if(Trigger.isUpdate) 
        {
            ALL_SLSARMVisit_Handler.submitForApproval(Trigger.old, Trigger.new);
            ALL_SLSARMVisit_Handler.postOnChatter(Trigger.oldMap, Trigger.new);
        }
    }
    
}