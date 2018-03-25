@IsTest
public class DS_FinalizedDealNSARequest_Test 
{
    public static testmethod void NSATriggerTest()
    {
        //profile p = [Select Id, Name From Profile Limit 1];
        // insert a standard user
        User ManagerUser = DS_TestObjects.NewUser_Inserted();
        
        /* User ManagerUser = new User(
            Username = 'test12@cobalt.com', 
            Email = 'test11@cobalt.com', 
            LastName = 'user11', 
            FirstName = 'test21', 
            Alias = 'tsas1', 
            CommunityNickName = 'testNickName1', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US', 
            ADID__c = 'est1', 
            IsActive = true,
            FederationIdentifier = 'fdhgu7897'
        ); insert ManagerUser;*/
        
        /* User SubordinateUser = new User(
            Username = 'tt1@cobalt.com', 
            Email = 'te1@cobalt.com', 
            LastName = 'us1', 
            FirstName = 'tt123', 
            Alias = 'tsAnj1', 
            CommunityNickName = 'testjkName1', 
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            ProfileId = p.Id, 
            LanguageLocaleKey = 'en_US', 
            ADID__c = 'test1', 
            IsActive = true,
            FederationIdentifier = 'bhj783423'
        ); insert SubordinateUser;*/
        
        // insert another user who has the manager as ManagerUser
        User SubordinateUser = DS_TestObjects.NewSecondUser_Inserted();
        SubordinateUser.ManagerId = ManagerUser.Id;
        update SubordinateUser;
              
        // insert a new account 
        Account NewAccount = DS_TestObjects.NewAccount_Inserted();
        NewAccount.Key_DOS__c = SubordinateUser.Id;
        Update NewAccount;
        
        // insert a new Opportunity
        Opportunity NewOpportunity = DS_TestObjects.NewOpportunity();        
        NewOpportunity.AccountId = NewAccount.Id;
        Insert NewOpportunity;
        
        // insert a new Deal State
        Deal_State__c NewDealState = new Deal_State__c();
        NewDealState.Opportunity__c = NewOpportunity.Id;
        Insert NewDealState;
        
        // insert new AVP RGM link
        AVP_RGM_Link__c AvpRGMLink = new AVP_RGM_Link__c();
        AvpRGMLink.AVP__c = ManagerUser.Id;
        AvpRGMLink.RGM__c = SubordinateUser.Id;
        Insert AvpRGMLink;
        
        // insert a new Finalized deal NSA request
        Finalized_Deal_NSA_Request__c FinalDealNSARequest = new Finalized_Deal_NSA_Request__c();
        FinalDealNSARequest.DOS__c = SubordinateUser.Id;
        FinalDealNSARequest.AVP__c = SubordinateUser.ManagerId;
        FinalDealNSARequest.Deal_State__c = NewDealState.Id;
        insert FinalDealNSARequest;        
    }
}