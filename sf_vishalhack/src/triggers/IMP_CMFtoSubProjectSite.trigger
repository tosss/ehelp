/*------------------------------------------------------------
Author:      Samuel Oberes
Company:     Cloud Sherpas
Description: Trigger for the RMStoSubProjectSite__c junction object
Test Class:  
History
07/28/15    Samuel Oberes       Created
------------------------------------------------------------*/
trigger IMP_CMFtoSubProjectSite on CMFtoSubProjectSite__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if (Trigger.isBefore) 
    {
        
        if(Trigger.isInsert)
        {
            
        } 
        else if(Trigger.isUpdate)
        {
            
        } 
        else if(Trigger.isDelete)
        {
            
        }
        
    } 
    else if (Trigger.isAfter) 
    {
        
        if(Trigger.isInsert)
        {
            IMP_SubProjectSite_Handler.refreshRMSRequestIdField(Trigger.new);
        } 
        else if(Trigger.isUpdate)
        {

        } 
        else if(Trigger.isDelete)
        {

        } 
        else if(Trigger.isUndelete)
        {
            
        }
        
    }

}