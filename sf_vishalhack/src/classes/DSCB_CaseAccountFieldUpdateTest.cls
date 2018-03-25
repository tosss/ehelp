@IsTest 
public class DSCB_CaseAccountFieldUpdateTest
{
    public static testmethod List<Trigger_Toggle__c> InquirySEOtoggleList()
    {
        List<Trigger_Toggle__c> ToggleList = new List<Trigger_Toggle__c>();
        
        ToggleList.add(new Trigger_Toggle__c(
            Name='02', sObject__c='Case', Code_Reference__c='DSCB_CaseAccountFieldUpdate', On__c=true));
        
        insert ToggleList;
        return ToggleList;
    }
    public static testmethod void CreateNewCase()
    {
        List<Trigger_Toggle__c> ToggleList = InquirySEOtoggleList();       
        
        Id AccountRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account', 'ADPDS Other Account');
        Id CaseRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Case', 'IFS - Contract Admin');
        
        User RunAs = [Select Id From User 
            Where Profile.Name = :DS_TestObjects.getAdminProfile().Name AND IsActive = true LIMIT 1]; 
        
        if(CustomSettings__c.getInstance() == null)
        {
            CustomSettings__c s = new CustomSettings__c();
            s.WebIDTriggers_On__c = false;
            insert s;
        }
        
        Test.startTest();
        
        Account a = new Account(
            Name = 'Test Account 001 Test',
            RecordTypeId = AccountRecordTypeId
        ); System.RunAs(RunAs) { insert a; }
        
        WebID__c w = new WebID__c(
            Name = 'test-001-test',
            Account__c = a.Id
        ); System.RunAs(RunAs) { insert w; }
        
        Case c = new Case(
            AccountId = a.Id,
            WebID__c = w.Id,
            RecordTypeId = CaseRecordTypeId,
            Subject = 'Test',
            Description = 'Test',
            Status = 'Open',
            Type = 'Customer Buy/Sell',
            Assumption_Approved__c = 'Yes',
            End_Billing_Date__c = Date.Today(),
            Seller__c = a.Id,
            Buyer_Contact_Details__c = 'Test'
        ); System.RunAs(RunAs) { insert c; }
        
        c.Type = 'GM Complete Buy/Sell';
        c.BAC__c = 'Test';
        System.RunAs(RunAs) { update c; }
        
        Test.stopTest();
    }
}