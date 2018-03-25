//2016-12-05 -venkata.shrivol@cdk.com -commented the whole class as project object is getting deleted RQ-08305	
public class UnfollowRecords_Handler
{
    //Author: Anirudh Singh
    //Dated: 16th April, 2015
    //Description: SubProject Records should be auto-unfollowed if Project is Closed.
   /* public static void unfollowSubProjects(List<Project__c> updatedProjectsList)
    {
        try
        {
            Set<Id> closedProjectsIds=new Set<Id>();
            
            for(Project__c pRef: updatedProjectsList)
            {
                if(pRef.Project_Status__c != null && pRef.Project_Status__c.toLowerCase() == 'closed')
                {
                    closedProjectsIds.add(pRef.Id);
                }
            }
            
            List<EntitySubscription> listSubscriptionOnSubProjects = [
                SELECT Id 
                FROM EntitySubscription 
                WHERE ParentId IN (
                    SELECT Id 
                    FROM SubProject__c 
                    WHERE Project__r.Id IN :closedProjectsIds
                )
            ];
            
            delete listSubscriptionOnSubProjects;
        }
        catch(Exception ex)
        {
            system.debug('Exception: '+ex.getMessage());
        }
    }*/
}