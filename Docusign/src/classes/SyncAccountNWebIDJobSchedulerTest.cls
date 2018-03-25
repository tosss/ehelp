/* Test calss for the SyncAccountNWebIDJobSchedulerTest.cls */
@isTest
private class SyncAccountNWebIDJobSchedulerTest{
    
    static testMethod void SyncAccountNWebIDJobSchedulerTestTestCase()
    {
        Integer howManyToTest=5;
        Profile p = [SELECT Id FROM Profile LIMIT 1];
        
        User adminUser = [
            select Id 
            from User 
            where Profile.Name='ADPDS - Admin - System Administrator' 
            and isActive = true 
            limit 1
        ];
        
        system.runAs(adminUser)
        {
            User u1 = DS_TestObjects.NewUser();
            u1.Username += 'webidsync1';
            u1.Alias = 'widsync1';
            u1.Title = 'DSM';
            //User u1 = new User(  
            //    Username = 'test1@cobalt.com'
            //    , Email = 'test1@cobalt.com'
            //    , LastName = 'user1'
            //    , FirstName = 'test1'
            //    , Alias = 'tsAlias1'
            //    , CommunityNickName = 'testNickName1'
            //    , TimeZoneSidKey = 'America/Los_Angeles'
            //    , LocaleSidKey = 'en_US'
            //    , EmailEncodingKey = 'UTF-8'
            //    , Title = 'DSM'
            //    , ProfileId = p.Id
            //    , LanguageLocaleKey = 'en_US'
            //    , ADID__c = 'tsAdid1'
            //);
            insert u1;
            
            User u2 = DS_TestObjects.NewUser();
            u2.Username += 'webidsync2';
            u2.Alias = 'widsync2';
            u2.Title = 'DSM';
            //User u2 = new User(  
            //    Username = 'test2@cobalt.com'
            //    , Email = 'test2@cobalt.com'
            //    , LastName = 'user2'
            //    , FirstName = 'test2'
            //    , Alias = 'tsAlias2'
            //    , CommunityNickName = 'testNickName122'
            //    , TimeZoneSidKey = 'America/Los_Angeles'
            //    , LocaleSidKey = 'en_US'
            //    , EmailEncodingKey = 'UTF-8'
            //    , Title = 'DSM'
            //    , ProfileId = p.Id
            //    , LanguageLocaleKey = 'en_US'
            //    , ADID__c = 'tsAdid2'
            //);
            insert u2;
            
            Account a = new Account(Name = 'test',Account_Number__c='T100',Designated_DSM__c=u1.Id);
            insert a;
            
            List<WebID__c> webIDList=new List<WebID__c>();
            
            for(Integer i=0;i<howManyToTest;i++)
            {
                WebID__c w1 = new WebID__c(Status__c='Active',Account__c=a.id,External_ID__c='TW100'+i);
                w1.Account_Executive__c = u1.Id;
                
                if(math.mod(i,2)==0) {
                    w1.Account_Executive__c=u2.Id;
                }
                
                webIDList.add(w1);
            }
            
            try{
                Database.insert(webIDList);
            }
            catch(Exception e){
                system.debug(e);
            }   
            
            List<String> accList=new List<String>();
            accList.add('T100');
            SyncAccountNWebIDJobScheduler test1=new SyncAccountNWebIDJobScheduler(null,accList);  
            SyncAccountNWebIDJobScheduler dummy = new SyncAccountNWebIDJobScheduler();     
            SyncAccountNWebIDJob dummy2=new SyncAccountNWebIDJob();//test coverage  
            SyncAccountNWebIDJob.LIMITCOUNT=howManyToTest;
            SchedulableContext SC;
            
            Test.startTest();
            test1.execute(SC);
            Test.stopTest();
            
            String eID='TW1002';
            
            WebID__c aeWebID = [
                Select Id, Account_Executive__c, Account_Executive__r.Id 
                From WebID__c Where External_ID__c = :eID 
                LIMIT 1
            ];
            
            string r = aeWebID != null && aeWebID.Account_Executive__c != null ? aeWebID.Account_Executive__r.Id : null;
            system.assertEquals(r, u1.Id);
        }
        
    }// end of SyncAccountNWebIDJobSchedulerTestTestCase method
    
} //end of class