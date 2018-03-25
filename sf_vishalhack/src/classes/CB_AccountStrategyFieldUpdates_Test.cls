@isTest
public class CB_AccountStrategyFieldUpdates_Test 
{
    static testmethod void unitTest()
    {        
        Account a = DS_TestObjects.NewAccount_Inserted();
        
        WebId__c w = DS_TestObjects.NewWebID();
        
        w.Account__c = a.Id;
        ID id = userInfo.getUserId();
        w.Account_Advocate__c = id;
        w.Reputation_Management_Specialist__c = id;
        w.LMA_Analyst2__c  = id;
        w.SEO_Specialist__c  = id;
        w.Social_Media_Specialist__c  = id;
        w.Online_Marketing_Specialist__c  = id;
        w.OwnerMktg_Specialist_lookup__c  = id;
        w.Client_Account_Manager__c  = id;
        w.LMA_Strategist__c  = id;       
        
        insert w; 
        Account_Plan__c ap;
        
        list<string> RecordTypesList = new list<string>{'AA Account Plan', 'SEO Account Plan', 'SMS Account Plan', 'RMS Account Plan',
            'DAA Account Plan', 'EMS Account Plan'};
        
        list<Account_Plan__c> APlist = new list<Account_Plan__c>();
        
        for(integer i=0; i<RecordTypesList.size(); i++)
        {
            Id RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', RecordTypesList[i]);
            ap = DS_TestObjects.NewAccountPlan();
            ap.RecordtypeId = RecordTypeId;
            ap.WebID__c = w.Id;
            ap.Account__c = a.Id;
            APlist.add(ap);
        }
        
        insert APlist;
        
        Account_Strategy__c accStrategy = new Account_Strategy__c();
        accStrategy.WebID__c = w.Id;
        accStrategy.Account__c = a.Id;
        accStrategy.Traditional__c = 90;
        accStrategy.Social__c = 5;
        accStrategy.Digital__c = 5;
       
        insert accStrategy;
    }
}