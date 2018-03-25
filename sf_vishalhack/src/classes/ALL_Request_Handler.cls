// Author : Lalitha Adduru
// Description : Handler class for All_Request Trigger. 
// 2016-07-28  ragashalini.koka@cdk.com - RQ-07464 - 
//     Added a method setDefaultInternalPriority which sets the Internal Priority of the Request 
// 	   based on the Requestor Priority if Internal Priority is null
//2017-02-02 ragashalini.koka@cdk.com - Added the method populateITProjectShortNames for RQ-08409
public class ALL_Request_Handler 
{

    // lalitha.adduru@cdk.com  - Unfollows all followers of a request when its status is changed to 'Completed'
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
     
    // 2016-07-28  ragashalini.koka@cdk.com - RQ-07464 - Added the method
    public static void setDefaultInternalPriority(List<Request__c> requestList) 
    {
        for(Request__c req : requestList) 
        {
            if(req.Internal_Priority__c == null) {
                if(req.Priority__c == 'Standard') {
                    req.Internal_Priority__c = '4 Standard';
                }
                else if (req.Priority__c == 'High' || req.Priority__c == 'Critical') {
                    req.Internal_Priority__c = '2 High';
                }
                else if(req.Priority__c == 'Mass Hysteria!') {
                    req.Internal_Priority__c = '1 Immediate';
                }
            }
        }
    }
    
    // 2017-01-16 matt.keefe@cdk.com - RQ-08409: Append Request Name
    public static void concatenateName(list<Request__c> requestList) 
    {
        populateITProjectShortNames(requestList);
        for(Request__c req : requestList) 
        {
            string RequestName = (req.IT_Project_Short_Name__c != null) ? req.IT_Project_Short_Name__c + ' ' : '';
            string SprintNumber = (req.Sprint_Number__c != null) ? '(Sprint ' + String.valueOf(req.Sprint_Number__c)  + ') ': '';
            
            RequestName += SprintNumber;
            
            string BriefDescription = (req.Brief_Description__c != null) ? String.valueOf(req.Brief_Description__c) : '';
            RequestName += (RequestName.length() > 0 && BriefDescription.length() > 0 ? ' - ' : '' )+ BriefDescription;
            
            if(RequestName.length() > 0) {
               
                if(RequestName.length() > 80) {
                    RequestName = RequestName.substring(0, 77) + '...';
                }

                req.Name = RequestName;
            }
              
        }
      
    }
    
    //2017-02-02 - ragashalini.koka@cdk.com - gets the IT Project short names from their respective parents
    private static void populateITProjectShortNames(List<Request__c> requestList) {
        
        Set<Id> parentRequestIdSet = new Set<Id>();
        
        for(Request__c req : requestList) {
            parentRequestIdSet.add(req.Parent_Request__c);
        }
        parentRequestIdSet.remove(null);
        
        if(parentRequestIdSet.size() > 0) {
            
            Map<Id,Request__c> parentRequestMap = new Map<Id,Request__c>([
                SELECT Id, IT_Project_Short_Name__c 
                FROM Request__c WHERE 
                Id IN :parentRequestIdSet AND RecordType.Name='IT Project']);
            
            for(Request__c req : requestList) {
                Id parentId = req.Parent_Request__c;
                if(parentRequestIdSet.contains(parentId) && parentRequestMap.containsKey(parentId)) {
                    req.IT_Project_Short_Name__c = parentRequestMap.get(parentId).IT_Project_Short_Name__c;
                }
                
            }
        }
    }
    

}