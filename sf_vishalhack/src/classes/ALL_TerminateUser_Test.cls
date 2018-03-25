/****************************************************************************************************************
*  2016-09-02 ragashalini.koka@cdk.com - RQ-07383 Created this class 
* ****************************************************************************************************************/
//2017-03-30- anirudh.singh@cdk.com- Modified this class for RQ-08829 Termination Process.
@isTest
public class ALL_TerminateUser_Test
{
    @TestSetup
    private static void setupTestData()
    {
        GlobalSettings__c globalValues=new GlobalSettings__c();
        globalValues.User_Titles__c='ARM';
        insert globalValues;
        
        Set<String> profileSet=new Set<String>{'Standard User', 'ADPDS - Admin - System Administrator', 'ADPDS - Sales - Inside Sales'};
        List<Profile> userProfileList=[SELECT Id, Name FROM Profile WHERE Name IN : profileSet];
        
        List<User> userList=new List<User>();
        
        for(Profile userProfile: userProfileList)
        {
            User newUser=DS_TestObjects.NewUser();
            newUser.ProfileId=userProfile.Id;
            if(userProfile.Name.containsIgnoreCase('Sales'))
            {
                newUser.Forecasting_Channel__c='Test';
            }
            userList.add(newUser);
        }
        
        insert userList;
        
        ALL_Terminate_User_Endpoints__c dmiEndpoint=new ALL_Terminate_User_Endpoints__c();
        dmiEndpoint.Name='DMI Endpoint';
        dmiEndpoint.API_Endpoint_URL__c='https://cs53.salesforce.com/services/Soap/class/ALL_TerminateUser_Controller';
        dmiEndpoint.Service_Endpoint_URL__c='https://test.salesforce.com/services/Soap/u/39.0';
        dmiEndpoint.Username__c='anirudh.singh@test.com';
        dmiEndpoint.Password__c='test812dguhqtsyudt2138';
        insert dmiEndpoint;
    }
    
    //2017-03-30- anirudh.singh@cdk.com- Modified this method for RQ-08829 Termination Process.
    private testmethod static void terminateUserVFTestOne()
    {
        Map<Id, User> userMap=new Map<Id, User>([SELECT Id FROM User Order By CreatedDate DESC LIMIT 1]);
        
        test.startTest();
        Set<Id> userIds=userMap.keySet();
        Id firstUserId=new List<Id>(userIds)[0];
        
        ApexPages.StandardController stdController=new ApexPages.StandardController(userMap.get(firstUserId));
        ALL_TerminateUser_Controller termUserRef=new ALL_TerminateUser_Controller(stdController);
        termUserRef.terminateUserVF();
        test.stopTest();
        
        system.assert(termUserRef.statusMessage.contains('User Terminated Successfully'));
        
        User userRecord=[SELECT Id, Termination_Date__c FROM User WHERE Id=:firstUserId];
        system.assert(userRecord.Termination_Date__c!=Null);
    }
    
    //2017-03-30- anirudh.singh@cdk.com- Added this method for RQ-08829 Termination Process.
    private testmethod static void terminateUserVFTestTwo()
    {
        test.startTest();
        Id currentUserId=userInfo.getUserId();
        
        ApexPages.StandardController stdController=new ApexPages.StandardController([SELECT Id FROM User WHERE Id=:currentUserId]);
        ALL_TerminateUser_Controller termUserRef=new ALL_TerminateUser_Controller(stdController);
        
        system.assertEquals('You cannot terminate your own record.', termUserRef.statusMessage);
        
        termUserRef.terminateUserVF();
        test.stopTest();
        
        system.assert(termUserRef.statusMessage.contains('User cannot be terminated'));
        
        User userRecord=[SELECT Id, Termination_Date__c FROM User WHERE Id=:currentUserId];
        system.assert(userRecord.Termination_Date__c==Null);
    }
    
    //2017-03-30- anirudh.singh@cdk.com- Added this method for RQ-08829 Termination Process.
    private testmethod static void terminateUserVFTestThree()
    {
        Map<Id, User> userMap=new Map<Id, User>([SELECT Id FROM User Order By CreatedDate DESC LIMIT 1]);
        
        test.startTest();
        Set<Id> userIds=userMap.keySet();
        Id firstUserId=new List<Id>(userIds)[0];
        
        User firstUserRec=userMap.get(firstUserId);
        firstUserRec.Non_Interactive_User__c=true;
        update firstUserRec;
        
        ApexPages.StandardController stdController=new ApexPages.StandardController(userMap.get(firstUserId));
        ALL_TerminateUser_Controller termUserRef=new ALL_TerminateUser_Controller(stdController);
        test.stopTest();
        
        system.assertEquals('This user cannot be terminated.', termUserRef.statusMessage);
    }
    
    //2017-03-30- anirudh.singh@cdk.com- Added this method for RQ-08829 Termination Process.
    private testmethod static void terminateUserVFTestFour()
    {
        Map<Id, User> userMap=new Map<Id, User>([SELECT Id FROM User Order By CreatedDate DESC LIMIT 1]);
        
        test.startTest();
        Set<Id> userIds=userMap.keySet();
        Id firstUserId=new List<Id>(userIds)[0];
        
        User firstUserRec=userMap.get(firstUserId);
        firstUserRec.IsActive=false;
        firstUserRec.Termination_Date__c=system.today();
        update firstUserRec;
        
        ApexPages.StandardController stdController=new ApexPages.StandardController(userMap.get(firstUserId));
        ALL_TerminateUser_Controller termUserRef=new ALL_TerminateUser_Controller(stdController);
        test.stopTest();
        
        system.assertEquals('This user has been terminated.', termUserRef.statusMessage);
    }
    
    //2017-03-30- anirudh.singh@cdk.com- Added this method for RQ-08829 Termination Process.
    private testmethod static void invokeTermUserWSTestOne()
    {
        Map<Id, User> userMap=new Map<Id, User>([SELECT Id FROM User Order By CreatedDate DESC LIMIT 1]);
        
        Set<Id> userIds=userMap.keySet();
        Id firstUserId=new List<Id>(userIds)[0];
        
        test.startTest();
        Test.setMock(WebServiceMock.class, new DMI_TerminateUserService_Mock());
        DMI_PartnerSoapSforceCom_Service.Soap sp=new DMI_PartnerSoapSforceCom_Service.Soap();
        sp.login('', '');
        
        ApexPages.StandardController stdController=new ApexPages.StandardController(userMap.get(firstUserId));
        ALL_TerminateUser_Controller termUserRef=new ALL_TerminateUser_Controller(stdController);
        termUserRef.invokeTerminateUserWebService();
        test.stopTest();
    }
    
    //2017-03-30- anirudh.singh@cdk.com- Added this method for RQ-08829 Termination Process.
    private testmethod static void invokeTermUserWSTestTwo()
    {
        Map<Id, User> userMap=new Map<Id, User>([SELECT Id FROM User Order By CreatedDate DESC LIMIT 1]);
        
        Set<Id> userIds=userMap.keySet();
        Id firstUserId=new List<Id>(userIds)[0];
        
        test.startTest();
        ApexPages.StandardController stdController=new ApexPages.StandardController(userMap.get(firstUserId));
        ALL_TerminateUser_Controller termUserRef=new ALL_TerminateUser_Controller(stdController);
        termUserRef.invokeTerminateUserWebService();
        test.stopTest();
    }
}