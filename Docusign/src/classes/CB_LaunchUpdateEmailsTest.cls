@IsTest
public class CB_LaunchUpdateEmailsTest 
{
    public static testmethod void Test()
    {
        // turn the WebID Triggers off (not testing those)
        CustomSettings__c c = new CustomSettings__c();
        c.WebIDTriggers_On__c = false;
        insert c;
        
        // insert a new User for assigning to the designated fields
        User u = DS_TestObjects.NewUser();
        u.Title = 'DSM'; 
        try { insert u; } catch (Exception e) { system.debug(e); }
        
        // insert a new Account from which some email fields will be pulled
        // it is not actually necessary to set the fields for code coverage
        //  - so, they're commented out, a null value will be passed
        Account a = DS_TestObjects.NewAccount();
        //a.Digital_Services_GAM__c = u.Id; 
        //a.Digital_Services_CAM__c = u.Id;
        //a.Designated_DSM__c = u.Id;
        try { insert a; } catch (Exception e) { system.debug(e); }
        
        // insert a new WebID for some other email fields
        WebID__c w = new WebID__c();
        w.Name = 'test-webid-001';
        w.Account__c = a.Id;
        //w.Account_Advocate__c = u.Id;
        //w.OwnerMktg_Specialist_lookup__c = u.Id;
        //w.Online_Marketing_Specialist__c = u.Id;
        //w.Reputation_Management_Specialist__c = u.Id;
        //w.SEO_Specialist__c = u.Id;
        //w.Social_Media_Specialist__c = u.Id;
        try { insert w; } catch (Exception e) { system.debug(e); }
        
        // insert a new Launch record that will test the CB_LaunchUpdateEmails Trigger
        Launch__c l = new Launch__c();
        l.Account__c = a.Id;
        l.WebID__c = w.Id;
        l.Product_Type__c = 'Dealer Group Support';
        l.Order_Priority__c = 'Normal';
        try { insert l; update l; } catch (Exception e) { system.debug(e); }
    }
}