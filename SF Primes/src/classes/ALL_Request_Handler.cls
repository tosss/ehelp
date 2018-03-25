// Author : Lalitha Adduru
// Description : Handler class for All_Request Trigger. 

public class ALL_Request_Handler 
{

    // Unfollows all followers of a request when its status is changed to 'Completed'
    public static void unfollowOnCompletion(List<Request__c> requestList, Map<id, Request__c> oldRequestMap)
    {
        system.debug('unfollow on completion');
        List<Request__c> validRequestList = new List<Request__c>();
        if(requestList != null && requestList.size() > 0)
        {
            for(Request__c req : requestList)
            {
                if(req.Status__c == 'Completed' && req.Status__c != oldRequestMap.get(req.id).Status__c )
                {
                    system.debug('status changed to completed');
                	validRequestList.add(req);   
                }
            }
        } 
        if(validRequestList != null && validRequestList.size() > 0)
        {
            List<EntitySubscription> followers = new List<EntitySubscription>();
            followers = [
                select id 
                from EntitySubscription 
                where parentId in :validRequestList 
                LIMIT 1000
            ];
            
            if(followers.size() > 0)
            {
                try
                {
                    delete followers;
                }
                catch(Exception ex)
                {
                    system.debug('Exception at '+ ex.getLineNumber() + ': '+ex.getMessage());
                }
            }
        }
    }
}