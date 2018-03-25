//2015-09-22- anirudh.singh@cdk.com- To upgrade the API Version FROM 19.0 to 34.0.
/* Test calss for the SyncAccountNWebIDJobSchedulerTest.cls */
@isTest
private class SyncAccountNWebIDJobSchedulerTest
{
    //2015-11-24- anirudh.singh@cdk.com- Added the below testSetup.
    @TestSetup
    private static void setupData()
    {
        Job_Settings__c batchSettingRef=new Job_Settings__c();
        batchSettingRef.Name='Record 1';
        batchSettingRef.Class_Name__c='SyncAccountNWebIDJob';
        batchSettingRef.Finish_Email__c='anirudh.singh@cdk.com';
        insert batchSettingRef;
    }
    
    static testMethod void SyncAccountNWebIDJobSchedulerTestTestCase()
    {
        Integer howManyToTest=5;
        
        //2015-09-22- anirudh.singh@cdk.com- It was not used anywhere.
        //Profile p=[SELECT Id FROM Profile LIMIT 1];
        
        User adminUser=[
            SELECT Id 
            FROM User 
            WHERE Profile.Name='ADPDS - Admin - System Administrator' 
            AND isActive=true 
            LIMIT 1
        ];
        
        system.runAs(adminUser)
        {
            User u1=DS_TestObjects.NewUser();
            u1.Username += 'webidsync1';
            u1.Alias='widsync1';
            u1.Title='DSM';
            //User u1=new User(  
            //    Username='test1@cobalt.com'
            //    , Email='test1@cobalt.com'
            //    , LastName='user1'
            //    , FirstName='test1'
            //    , Alias='tsAlias1'
            //    , CommunityNickName='testNickName1'
            //    , TimeZoneSidKey='America/Los_Angeles'
            //    , LocaleSidKey='en_US'
            //    , EmailEncodingKey='UTF-8'
            //    , Title='DSM'
            //    , ProfileId=p.Id
            //    , LanguageLocaleKey='en_US'
            //    , ADID__c='tsAdid1'
            //);
            insert u1;
            
            User u2=DS_TestObjects.NewUser();
            u2.Username += 'webidsync2';
            u2.Alias='widsync2';
            u2.Title='DSM';
            //User u2=new User(  
            //    Username='test2@cobalt.com'
            //    , Email='test2@cobalt.com'
            //    , LastName='user2'
            //    , FirstName='test2'
            //    , Alias='tsAlias2'
            //    , CommunityNickName='testNickName122'
            //    , TimeZoneSidKey='America/Los_Angeles'
            //    , LocaleSidKey='en_US'
            //    , EmailEncodingKey='UTF-8'
            //    , Title='DSM'
            //    , ProfileId=p.Id
            //    , LanguageLocaleKey='en_US'
            //    , ADID__c='tsAdid2'
            //);
            insert u2;
            
            Account a=new Account(Name='test', Account_Number__c='T100', Designated_DSM__c=u1.Id);
            insert a;
            
            List<WebID__c> webIDList=new List<WebID__c>();
            
            for(Integer i=0; i<howManyToTest; i++)
            {
                WebID__c w1=new WebID__c(Status__c='Active', Account__c=a.id, External_ID__c='TW100'+i);
                w1.Account_Executive__c=u1.Id;
                
                if(math.mod(i,2)==0)
                {
                    w1.Account_Executive__c=u2.Id;
                }
                
                webIDList.add(w1);
            }
            
            try
            {
                Database.insert(webIDList);
            }
            catch(Exception e)
            {
                system.debug(e);
            }   
            
            List<String> accList=new List<String>();
            accList.add('T100');
            SyncAccountNWebIDJobScheduler test1=new SyncAccountNWebIDJobScheduler(Null, accList);  
            SyncAccountNWebIDJobScheduler dummy=new SyncAccountNWebIDJobScheduler();     
            SyncAccountNWebIDJob dummy2=new SyncAccountNWebIDJob();//test coverage  
            SyncAccountNWebIDJob.LIMITCOUNT=howManyToTest;
            SchedulableContext SC;
            
            Test.startTest();
            test1.execute(SC);
            Test.stopTest();
            
            String eID='TW1002';
            
            WebID__c aeWebID=[
                SELECT Id, Account_Executive__c, Account_Executive__r.Id 
                FROM WebID__c 
                WHERE External_ID__c=:eID 
                LIMIT 1
            ];
            
            String r=aeWebID!=Null && aeWebID.Account_Executive__c!=Null ? aeWebID.Account_Executive__r.Id : Null;
            system.assertEquals(r, u1.Id);
        }
    }// end of SyncAccountNWebIDJobSchedulerTestTestCase method
} //end of class