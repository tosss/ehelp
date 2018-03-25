//2015-09-22- anirudh.singh@cdk.com- Upgraded the API Version FROM 27.0 to 34.0.
//2016-01-21- anirudh.singh@cdk.com- Commented this class for Request RQ-06024 due to naming issue. Name doesnot follow standards.
@IsTest
public class DS_KeyRepChangeTest
{
    /*public static testmethod void Test()
    {
        User u = DS_TestObjects.NewUser();
        u.Forecasting_Channel__c = 'National';
        insert u;
        
        Account a = DS_TestObjects.NewAccount();
        a.Region__c = 'National';
        insert a;
        
        Key_Rep_Changes__c k = new Key_Rep_Changes__c();
        k.New_Key_Rep__c = u.Id;
        k.Account__c = a.Id;
        
        // this should throw an error due to Trigger validation
        try { insert k; } catch (Exception e) { system.debug(e); }
        
        ADP_Default_Team__c d = new ADP_Default_Team__c();
        d.Name = u.Name + 'Team';
        d.Key_Rep__c = u.Id;
        d.Region__c = 'National';
        insert d;
        
        // this should succeed (passing Trigger validation)
        try { insert k; } catch (Exception e) { system.debug(e); }
    }*/
}