// Author : Lalitha Adduru
// Description : Trigger on Request Object
// 2016-07-28  ragashalini.koka@cdk.com - RQ-07464 - Added code to call setDefaultInternalPriority

trigger ALL_Request on Request__c (before update, before insert) {
    if(trigger.isbefore) {
        
        if(trigger.isUpdate) {
			// unfollow all followers when a record status is changed to 'completed'
            All_Request_Handler.unfollowOnCompletion(trigger.new, trigger.oldMap);
        }
        
        if(trigger.isInsert || trigger.isUpdate) {
            // defaults Internal Priority value if it is null 
            ALL_Request_Handler.setDefaultInternalPriority(trigger.New);
            
            // set Request Name
            ALL_Request_Handler.concatenateName(Trigger.New);
        }
    }
    
   
}