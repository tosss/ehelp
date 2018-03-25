/*......................................................................
. Author        :   lalitha.adduru@cdk.com                     
. Description   :   Trigger on Request_Team_Member__c           
. Date          :   July 2015 
......................................................................*/

trigger All_RequestTeamMembers on Request_Team_Member__c(after insert, after update, after delete)
{
    All_RequestTeamMembers_Handler updateRequest=new All_RequestTeamMembers_Handler();
    
    if(Trigger.isinsert)
    {  
        // call updateFieldsafterInsert method from All_RequestTeamMembers_Handler class
        if(!trigger.new.isEmpty())
        {
            updateRequest.updateRequestsAfterInsert(trigger.new);
        }
    }        
    if(trigger.isUpdate)
    {            
        // call updateFieldsafterUpdate method from All_RequestTeamMembers_Handler class
        if(!trigger.old.isempty() && !trigger.new.isEmpty())
        {
            updateRequest.updateRequestsAfterUpdate(trigger.oldMap,trigger.new);
        }                           
    }
    if(trigger.isDelete)
    {        
        // call updateFieldsafterDelete method from All_RequestTeamMembers_Handler class
        if(!trigger.old.isEmpty())
        {
            updateRequest.updateRequestsAfterDelete(trigger.old);
        }
    }
}