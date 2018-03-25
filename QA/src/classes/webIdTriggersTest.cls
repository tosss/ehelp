//2016-02-10- anirudh.singh@cdk.com- Commented this Test Class as per Request RQ-06027 Trigger on WebIDs update to follow standards.
//2016-02-10- anirudh.singh@cdk.com- A new Test Class CB_WebID_Test has been created. This Test Class will be deleted later.
@isTest
private class webIdTriggersTest 
{
    /*
    //Test that account team has accounts added/deleted properly
    static testMethod void AccountTeamTest() 
    {
        CustomSettings__c cs = new CustomSettings__c();
        cs.Name = 'AfterAPIver.24-haveTodoThis_:(';
        cs.WebIDTriggers_On__c = true;
        insert cs;
        
        List<Account_Team_Sync_Settings__c> AccountTeamSettings = DS_TestObjects.getAcountTeamSyncSettings();
        
        Map<String, String> WEBID_FIELDS = new Map<String, String>//();
        {
            'Account_Advocate__c' => 'Account Advocate',
            'Online_Marketing_Specialist__c' => 'Online Marketing Specialist',
            'OwnerMktg_Specialist_lookup__c' => 'Email Marketing Specialist',
            'Owner_Marketing_DAP__c' => 'Owner Marketing (DAP)',
            'Reputation_Management_Specialist__c' => 'Reputation Management Specialist',
            'SEO_Specialist__c' => 'Search Optimization Specialist',
            'Social_Media_Specialist__c' => 'Social Media Specialist'//,
            //'Account__r.Digital_Services_CAM__c' => 'Digital Services CAM',
            //'Account__r.Digital_Services_GAM__c' => 'Digital Services GAM'
        };
        
        //Map<String,String> WEBID_FIELDS = new Map<String,String>();
        //for(Account_Team_Sync_Settings__c s : Account_Team_Sync_Settings__c.getall().values()) { 
        //    if(s.sObject__c.toLowerCase() == 'webid__c') {
        //        WEBID_FIELDS.put(s.User_ID_Field_API_Name__c,s.Team_Role__c); 
        //    }
        //}
        
        system.debug('#Fields='+(WEBID_FIELDS.size()-1));
        
        Integer NumberOfWebIdsToTest = 1;
        
        List<Account> ab = new List<Account>();
        ab.add(new Account(Name = 'Test Account 001'));
        ab.add(new Account(Name = 'Test Account 002'));
        insert ab;
        
        Profile p = DS_TestObjects.getStandardProfile(); system.debug(p);
        Profile AdminProfile = DS_TestObjects.getAdminProfile();
        
        object AdminName = AdminProfile.get('Name');
        
        string Aname = (string)AdminName;
        
        system.debug(Aname);
        
        User RunAs = null;
        if(AdminName != null) {
            RunAs = [SELECT Id, Name, Profile.Name FROM User Where Profile.Name = :Aname AND IsActive = true LIMIT 1];
        }
        system.debug(RunAs);
        List<User> TestUsers = new List<User>();
        
        for(Integer i=0; i<((WEBID_FIELDS.size()-1)*NumberOfWebIdsToTest); i++)
        {
            User u = new User(Username = 'test'+String.valueOf(i)+'@cobalt.com'
                , IsActive = true
                , Email = 'test'+String.valueOf(i)+'@cobalt.com'
                , LastName = 'user'+String.valueOf(i)
                , FirstName = 'test'+String.valueOf(i)
                , Alias = 't'+String.valueOf(i)
                , CommunityNickName = 'testNickName'+String.valueOf(i)
                , TimeZoneSidKey = 'America/Los_Angeles'
                , LocaleSidKey = 'en_US'
                , EmailEncodingKey = 'UTF-8'
                , ProfileId = p.Id
                , LanguageLocaleKey = 'en_US'
                , ADID__c = 'test'+String.valueOf(i)+'UserAdid');
            
            //system.debug(u);
            TestUsers.add(u);
        }
        
        //system.debug(TestUsers.size());
        system.runas(RunAs) { insert TestUsers; } // setup object
        
        List<WebID__c> ww = new List<WebID__c>();
        
        for(Integer i=0; i<NumberOfWebIdsToTest; i++)
        {
            WebID__c w = new WebID__c(Name = 'test-WebID-'+i, Account__c = ab[0].Id);
            
            List<String> FieldNames = new List<String>(); 
            FieldNames.addAll(WEBID_FIELDS.keyset());
            
            for(Integer f=0; f<(FieldNames.size()-1); f++) 
            {
                system.debug('(FieldNames.size()-1)---->'+(FieldNames.size()-1));
                Integer n = f+(i*(FieldNames.size()-1)); //system.debug('f='+f+',i='+i+',n='+n);
                system.debug('n---->'+n);
                system.debug('FieldNames[f]---->'+FieldNames[f]);
                ALL_UtilitiesData.PutDataInNestedFields(FieldNames[f], w, TestUsers[n].Id);
            }
            system.debug('w---->'+w);
            ww.add(w);
        }
        
        test.startTest();
        
        //for(WebID__c w : ww) { system.debug(w); }
        
        system.runas(DS_TestObjects.CurrentUser()) { insert ww; } // custom object
        
        for(User u : TestUsers)
        {
            //system.debug([SELECT COUNT() FROM Account_Team__c WHERE Account__c = :ab[0].Id AND Team_Member__c = :u.Id] + ', User='+u);
            system.assertEquals([SELECT COUNT() FROM Account_Team__c WHERE Account__c = :ab[0].Id AND Team_Member__c = :u.Id],1);
        }
        
        // test account move
        //system.runas(DS_TestObjects.CurrentUser()) { ww[0].Account__c = ab[1].Id; update ww[0]; }
        
        // test delete(s)
        //system.runas(DS_TestObjects.CurrentUser()) { delete ww[0]; ww.remove(0); } // custom object
        //if(ww.size() > 0) { system.runas(DS_TestObjects.CurrentUser()) { delete ww; } } // custom object
        
        //system.assertEquals([SELECT COUNT() FROM Account_Team__c WHERE Account__c = :ab[0].Id AND Team_Member__c = :TestUsers[0].Id],0);
        
        test.stopTest();
    }*/
}