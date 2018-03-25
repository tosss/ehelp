// Author : Lalitha Adduru
// Description : Test class for All_Request trigger

@isTest
public class ALL_RequestHandler_Test 
{
    @testSetUp static void setUp()
    {
        Request__c req = new Request__c(
            Name = 'TestDescription',
            Details__c='TestDetails',
            Business_Justification__c = 'TestJustification',
            Deployment_Strategy__c='In PROD Only',
            Status__c='Open',
            Internal_Priority__c='2 High', 
            Initial_Estimate__C= 12345,
            User_Groups_Impacted__c='CB - Finance'
        );
        insert req;
        
        EntitySubscription follower = new EntitySubscription(ParentId = req.id , subscriberId = UserInfo.getUserId());
        insert follower;        
    }
    
    
    public static testmethod void testRequestTrigger()
    {
        List<Request__c> requestList = [select id from Request__C where Name='TestDescription'];
        Request__c req = requestList[0];

        // Map to store old request clone
        Map<id,Request__c> oldRequestMap = new Map<id,Request__c>();
        Request__c req2 = requestList[0].clone(false,false,false,false);
        oldRequestMap.put(req.id, req2);
        
        // update the status of the record
        req.Status__c = 'Completed';
        req.Change_Classification__c = 'Routine';
        req.Duration_to_Completion__c = 20;
        //req.Completed_in_Unified__c = true;
        //req.Completed_in_Prod__c= true;
        //req.Completed_in_QA__c = true;
        req.Reason_Not_Completed_In_All_Environments__c = 'sample reason';
        req.OwnerId = UserInfo.getUserId(); // 2015-12-17 matt.keefe@cdk.com - need to change owner to satisfy validation rule in unified
        
        // call the method with OldrequestMap mimicking trigger.oldMap
        ALL_Request_Handler.unfollowOnCompletion(requestList, oldRequestMap);       
    }
}