//2015-11-27 : vishal.bandari@cdk.com - RQ-05289:changed CaseReferenceLimitsWorkAround method to add contact record type
@IsTest
public class DSCB_CaseReferenceFieldsTest
{
    static testMethod void CaseReferenceLimitsWorkAround()
    {
        Trigger_Toggle__c tt = new Trigger_Toggle__c();
        tt.Name = 'ALL DSCB_CaseReferenceFields';
        tt.Code_Reference__c = 'DSCB_CaseReferenceFields';
        tt.On__c = true;
        tt.sObject__c = 'Case';
        insert tt;
        
        //Insert User and Account
        User u = DS_TestObjects.NewUser_Inserted();
        Account a = New Account(); 
        a.Name ='testName'; 
        a.Account_Number__c = '12345';
        insert a;
        
        //Insert WebId Field values
        WebId__c w = New WebId__c(); 
        w.Account__c = a.Id; 
        w.BAC_Dealer_Code__c = '1234';
        w.Account_Advocate__c = u.Id;
        w.Online_Marketing_Specialist__c = u.Id;
        w.Primary__c = True;
        w.WebNum__c = '12345';
        insert w;
        
        contact con = DS_TestObjects.NewContact();
        con.AccountId = a.Id;
        //2015-11-27 vishal.bandari@cdk.com RQ-05289:added contact record type
        con.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
        insert con;
        
        // 2016-07-27 matt.keefe@cdk.com - added contact relationship for shared contacts (Case Lookup requires)
        Contact_Relationship__c cr1 = new Contact_Relationship__c(Contact__c = con.Id, Account__c = a.Id);
        cr1.Role__c = 'Accountant';
        insert cr1;
        
        //Insert Case Filed values
        Case c = New Case(); 
        c.AccountId = a.Id; 
        c.BAC_Dealer_Code__c = w.BAC_Dealer_Code__c; 
        c.Account_Advocate__c = 'Siva Pragada';
        c.Online_Marketing_Specialist__c = 'Siva Pragada';
        c.Zip_Code__c = '12345'; 
        c.WebNum__c = '1234';
        //c.Primary_Site_Status__c = 'Primary';  
        c.webid__c = w.id;
        c.Destination_Account__c = a.id;
        c.Dealer_Group_Contact__c = con.Id;
        c.ContactId = con.Id;
        insert c;
        
        // Update Case
        w.Primary__c = False;
        update w;
        
        u.Extension = '123';
        
        update u;
        update c;
    }
}