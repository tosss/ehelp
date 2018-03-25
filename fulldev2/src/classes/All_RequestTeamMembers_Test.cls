/*......................................................................
. Author		:	lalitha.adduru@cdk.com                     
. Description	:	Test class for All_RequestTeamMembers-    
.               	Trigger on Request_Team_Member__c           
. Date			:	July 2015 
. Code Coverage	:	On Trigger All_RequestTeamMembers - 100%
.					On Handler All_RequestTeamMembers_Handler - 95%
.........................................................................*/

@isTest
public class All_RequestTeamMembers_Test {
    
    public static testmethod void testTrigger()        
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
                Name = 'TestDescription',
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
                Name = 'TestDescription',
                Details__c='TestDetails',
                Business_Justification__c = 'TestJustification',
                Deployment_Strategy__c='In PROD Only',
                Status__c='Open',
                User__c = UserInfo.getUserId(),
                Internal_Priority__c='2 High', 
                Initial_Estimate__C= 12345,
                User_Groups_Impacted__c='CB - Finance'
            ); insert testReqTwo;  
                                    
            Request_Team_Member__c test_rtm = new Request_Team_Member__c(Request__c = testReqOne.id, User__c= testUserOne.id, Role__c='Business Analyst');
            insert test_rtm;
            
            test_rtm.Role__c = 'External Developer'; // update role
            update test_rtm;
            
            test_rtm.Role__c = 'QA Engineer'; // update role
            update test_rtm;
            
            test_rtm.Role__c = 'SF Config Admin'; // update role
            update test_rtm;
                        
            test_rtm.User__c = testUserTwo.id; // update user
            update test_rtm;
            
            test_rtm.Request__c = testReqTwo.id; // update request
            update test_rtm;
            
            // update role and user
            test_rtm.Role__c = 'SF Developer';
            test_rtm.user__c = testUserOne.id;
            update test_rtm;
                        
            // update role and request
            test_rtm.Role__c = 'Code Reviewer';
            test_rtm.Request__c = testReqOne.id;
            update test_rtm;
            
            // update user and request
            test_rtm.User__c = testUserTwo.id;
            test_rtm.Request__c = testReqTwo.id;
            update test_rtm;
            
            // update role , user, and request
            test_rtm.User__c = testUserOne.id;
            test_rtm.Role__c = 'Release Manager';
            test_rtm.Request__c = testReqOne.id;
            update test_rtm;
            
            // delete request team meber
            delete test_rtm;
        }   
    
    }
}