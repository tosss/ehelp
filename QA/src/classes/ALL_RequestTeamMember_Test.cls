/*......................................................................
. Author        :   lalitha.adduru@cdk.com                     
. Description   :   Test class for `-    
.                   Trigger on Request_Team_Member__c           
. Date          :   July 2015 
. Code Coverage :   On Trigger All_RequestTeamMember - 100%
.                   On Handler All_RequestTeamMember_Handler - 91%
. 1/02/2016-   lalitha.adduru@cdk.com-   modified the test class to use 
.                    testSetUp and avoid dmls in testmethod
.........................................................................*/

@isTest
public class ALL_RequestTeamMember_Test 
{
    @testSetUp static void setup()
    {   
        // generating random values for to set user attributes while creating test users
        String RandomOne = ALL_UtilitiesRandom.TrueRandomUpToAMillion();
        String RandomTwo = ALL_UtilitiesRandom.TrueRandomUpToAMillion();
        String RandomUserNameOne = ALL_UtilitiesRandom.RandomUserName('RequestTeamMemberTriggerTestOne');
        String RandomUserNameTwo = ALL_UtilitiesRandom.RandomUserName('RequestTeamMemberTriggerTestTwo');
        
        // list of System Admin Profiles
        list<Profile> AdminProfiles = [
            Select Id, Name 
            From Profile 
            Where PermissionsModifyAllData = true 
            And PermissionsApiEnabled = true 
            And Name like '%System Administrator%'
            limit 1
        ];
        
        if(AdminProfiles != null && !AdminProfiles.isEmpty())
        {
            Profile AdminProfile = AdminProfiles.get(0);
            
            // creating a test User
            User testUserOne = new User(
                UserName=RandomUserNameOne, 
                Email=RandomUserNameOne, 
                Alias=RandomOne.length()>8?RandomOne.substring(4, RandomOne.length()):RandomOne,
                EmailEncodingKey='UTF-8', 
                FirstName='Apex',
                LastName='Test User', 
                LanguageLocaleKey='en_US', 
                LocaleSIDKey='en_US', 
                profileId=AdminProfile.Id, 
                TimeZoneSIDKey='America/Chicago',
                ADID__c='A'+RandomOne,
                FederationIdentifier = 'F'+RandomOne
            ); 
            
            testUserOne.putSObject('Profile', AdminProfile);
            insert testUserOne;
            
            // crating another test user to test updating request team member
            User testUserTwo = new User(
                UserName=RandomUserNameTwo, 
                Email=RandomUserNameTwo, 
                Alias=RandomTwo.length()>8?RandomTwo.substring(4, RandomTwo.length()):RandomTwo,
                EmailEncodingKey='UTF-8', 
                FirstName='Apex',
                LastName='Test User', 
                LanguageLocaleKey='en_US', 
                LocaleSIDKey='en_US', 
                profileId=AdminProfile.Id, 
                TimeZoneSIDKey='America/Chicago',
                ADID__c='A'+RandomTwo,
                FederationIdentifier = 'F'+RandomTwo
            ); 
            
            testUserTwo.putSObject('Profile', AdminProfile);
            insert testUserTwo;
            
            Request__c testReqOne = new Request__c(
                Name = 'TestDescriptionOne',
                Details__c='TestDetails',
                Business_Justification__c = 'TestJustification',
                Deployment_Strategy__c='In PROD Only',
                Status__c='Open',
                User__c = UserInfo.getUserId(),
                Internal_Priority__c='2 High', 
                Initial_Estimate__C= 12345,
                User_Groups_Impacted__c='CB - Finance'
            ); insert testReqOne;  
            
            Request__c testReqTwo = new Request__c(
                Name = 'TestDescriptionTwo',
                Details__c='TestDetails',
                Business_Justification__c = 'TestJustification',
                Deployment_Strategy__c='In PROD Only',
                Status__c='Open',
                User__c = UserInfo.getUserId(),
                Internal_Priority__c='2 High', 
                Initial_Estimate__C= 12345,
                User_Groups_Impacted__c='CB - Finance'
            ); insert testReqTwo;  
            
            Request_Team_Member__c test_rtm_one = new Request_Team_Member__c(Request__c = testReqOne.id, User__c= testUserOne.id, Role__c='Business Analyst');
            insert test_rtm_one;
            
            Request_Team_Member__c test_rtm_two = new Request_Team_Member__c(Request__c = testReqtwo.id, User__c= testUsertwo.id, Role__c='QA Tester');
            insert test_rtm_two;
            
        }
    }
    
    public static testmethod void testTrigger()
    {
        List<Request_Team_Member__c> rtmList = new List<Request_Team_Member__c>();
        rtmList = [select id, Role__c, Request__c, User__c from Request_Team_Member__c];
        
        List<Request__c> reqList = new List<Request__c>();
        reqList = [select id from Request__c Order By Name];
        
        List<User> userList = new List<User>();
        userList  = [select id from User Order By UserName];
        
        All_RequestTeamMember_Handler handler = new All_RequestTeamMember_Handler();
        handler.updateRequestsAfterInsert(rtmList);
        
        Map<id,Request_Team_Member__c> oldMap = new Map<id, Request_Team_Member__c>();
        for(Request_Team_Member__c rtm : rtmList)
        {
           oldMap.put(rtm.id, rtm.clone());
        }
        
        rtmList[0].Role__c = 'SF Developer';
        rtmList[0].Request__c = reqList[1].id;
        handler.UpdateRequestsAfterUpdate(oldMap, rtmList);
        
        rtmList[0].Role__c = 'Business Analyst';
        rtmList[0].Request__c = reqList[1].id;
        handler.UpdateRequestsAfterUpdate(oldMap, rtmList);
        
        rtmList[1].User__c = userList[0].id;
        handler.UpdateRequestsAfterUpdate(oldMap, rtmList);
        
        rtmList[0].role__c = 'External Developer';
        rtmList[0].Request__c = reqList[0].id;
        handler.UpdateRequestsAfterUpdate(oldMap, rtmList);
        
        rtmList[1].role__c = 'Project Manager';
        handler.UpdateRequestsAfterUpdate(oldMap, rtmList);
        
        rtmList[0].role__c = 'Technical Reviewer';
        handler.UpdateRequestsAfterUpdate(oldMap, rtmList);
        
        rtmList[1].role__c = 'Release Manager';
        handler.UpdateRequestsAfterUpdate(oldMap, rtmList);
        
        rtmList[0].role__c = 'SF Config Admin';
        handler.UpdateRequestsAfterUpdate(oldMap, rtmList);
               
        rtmList[1].Request__c = reqList[0].id;
        rtmList[0].User__c = userList[1].id;
        rtmList[1].user__c = userList[1].id;
        handler.UpdateRequestsAfterUpdate(oldMap, rtmList);
        
        handler.updateRequestsafterDelete(rtmList);
    }
}