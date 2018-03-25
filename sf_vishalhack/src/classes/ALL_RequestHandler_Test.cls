// Author : Lalitha Adduru
// Description : Test class for All_Request trigger
// 2016-07-28  ragashalini.koka@cdk.com - RQ-07464 - added code to improve test coverage
@isTest
public class ALL_RequestHandler_Test 
{
    @testSetUp static void setUp()
    {
        List<Request__c> requestList = new List<Request__c>();
        List<String> priorityList = new List<String>{'Standard','High','Critical','Mass Hysteria!'};
        Id projectRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Request__c', 'IT Project');
        Id sprintRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Request__c', 'IT Sprint');
        //2016-07-28  ragashalini.koka@cdk.com - RQ-07464 commented Internal_Priority__c and added Priority__c field 
        for(Integer i = 0;i < 4;i++) {
            Request__c req = new Request__c(
            Name = 'TestDescription' + i,
            Details__c='TestDetails' + i,
            Business_Justification__c = 'TestJustification',
            Deployment_Strategy__c='In PROD Only',
            Status__c='Open',
            //Internal_Priority__c='2 High',
            Priority__c = priorityList[i], 
            Initial_Estimate__C= 12345,
            User_Groups_Impacted__c='CB - Finance'
        );
            if(i == 0) {
                req.RecordTypeId = projectRecordTypeId;
            }
          requestList.add(req);  
        }
        
        insert requestList;
        
        Request__c sprintRequest = new Request__c();
        sprintRequest.RecordTypeId = sprintRecordTypeId;
        sprintRequest.Name = 'Sprint Test1';
        sprintRequest.Brief_Description__c = 'Test';
        sprintRequest.Details__c = 'Test';
        sprintRequest.Deployment_Strategy__c = 'In PROD Only';
        sprintRequest.Status__c = 'Open';
        sprintRequest.Priority__c = 'Standard';
        sprintRequest.User_Groups_Impacted__c = 'CB - Finance';
        sprintRequest.Parent_Request__c = requestList[0].Id;
        insert sprintRequest;
        
        EntitySubscription follower = new EntitySubscription(ParentId = requestList[0].id , subscriberId = UserInfo.getUserId());
        insert follower;        
    }
    
    
    public static testmethod void testRequestTrigger()
    {
        List<Request__c> requestList = [select id, Internal_Priority__c, Priority__c,Status__c from Request__c ORDER By Createddate];
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
        
        //2016-07-28  ragashalini.koka@cdk.com - RQ-07464 Added Assert to check the functionality
        if(req.Priority__c == 'Standard') {
            System.assertEquals('4 Standard',req.Internal_Priority__c);
        }
        
    }
}