@isTest
private class OwnerLookUpTriggerTest
{
    static testmethod void testAssignCaseUserManager() 
    {
        /*
        User u = [select ManagerId From User where Id = : UserInfo.getUserId()];
        
        if(u.ManagerId == null) {
            User m = [select Id From User where Id != : u.Id];
            u.ManagerId = m.Id;
        }
        update u;
        */       
        
        // Commented out above and made a test user instead, so we're not hitting querylimit on DML.
        Profile p = [ SELECT Id FROM Profile LIMIT 1];
        
        User m = new User (	Username = 'manager@cobalt.com'
        					, Email = 'manager@cobalt.com'
        					, LastName = 'manager1'
        					, FirstName = 'manager1'
        					, Alias = 'malias1'
        					, CommunityNickName = 'managertestNickName1'
        					, TimeZoneSidKey = 'America/Los_Angeles'
        					, LocaleSidKey = 'en_US'
        					, EmailEncodingKey = 'UTF-8'
        					, ProfileId = p.Id
        					, LanguageLocaleKey = 'en_US'
        					, IsActive = true
                            , ADID__c = 'managerOne');
       	insert m;
        
        User u = new User(	Username = 'test1@cobalt.com'
        					, Email = 'test1@cobalt.com'
        					, LastName = 'user1'
        					, FirstName = 'test1'
        					, Alias = 'tsAlias1'
        					, CommunityNickName = 'testNickName1'
        					, TimeZoneSidKey = 'America/Los_Angeles'
        					, LocaleSidKey = 'en_US'
        					, EmailEncodingKey = 'UTF-8'
        					, ProfileId = p.Id
        					, LanguageLocaleKey = 'en_US'
        					, ManagerId = m.Id
        					, IsActive = true
                            , ADID__c = 'test1User');
        insert u;
        
        contact con = DS_TestObjects.NewContact_Inserted();
        Case ca;
        
        // Added Subject to next line to avoid validation issue
        ca = new Case(
            Status = 'New', Origin = 'Phone', OwnerId = u.Id, Subject = 'Test Case', 
            Dealer_Group_Contact__c=con.Id, ContactId=con.Id);
        // Turning Case triggers off so they're not firing while we just want to test this one
        caseTriggers.run = false;
        insert ca;
        
        // Moved startTest here, so update/insert do not count against execution governors - 
        test.startTest();
        ca.Status = 'Working';
        update ca;
        // turning caseTriggers back on
        caseTriggers.run = true;
        test.stopTest();
        
    }



}// end of method