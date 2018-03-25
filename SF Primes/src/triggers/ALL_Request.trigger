// Author : Lalitha Adduru
// Description : Trigger on Request Object

trigger ALL_Request on Request__c (before update) {
    if(trigger.isbefore)
    {
        if(trigger.isUpdate)
        {
			// unfollow all followers when a record status is changed to 'completed'
            All_Request_Handler.unfollowOnCompletion(trigger.new, trigger.oldMap);
        }
    }
}