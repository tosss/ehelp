@isTest
public class DSCB_CaseAssignment_Test 
{
    public static testmethod List<Trigger_Toggle__c> InquirySEOtoggleList()
    {
        List<Trigger_Toggle__c> ToggleList = new List<Trigger_Toggle__c>();
        ToggleList.add(new Trigger_Toggle__c(Name='ALL DSCB_CaseAssignment', sObject__c='Case', Code_Reference__c='DSCB_CaseAssignment'));
        ToggleList.add(new Trigger_Toggle__c(
            Name='SEO DSCB_CaseAssignment', sObject__c='Case', Code_Reference__c='DSCB_CaseAssignment', RecordType_Name__c='Inquiry - SEO', On__c=true));
        
        insert ToggleList;
        return ToggleList;
    }
    
    public static testmethod void CaseAssignment()
    {        
        List<Trigger_Toggle__c> ToggleList = DSCB_CaseAssignment_Test.InquirySEOtoggleList();
        
        User u = DS_TestObjects.NewUser_Inserted();
        
        Account a = DS_TestObjects.NewAccount_Inserted();
        WebId__c w = DS_TestObjects.NewWebID();
        w.Account__c = a.Id;
        insert w;
        
        list<Account_Plan__c> APList = new list<Account_Plan__c>();
        
        ID RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'SEO Account Plan');
        Account_Plan__c ap = new Account_Plan__c();
        ap.RecordTypeId = RecordTypeId;
        ap.ownerId = userInfo.getUserId();
        ap.WebID__c = w.Id;
        ap.Account__c = a.Id;
        ap.Account_Status__c = 'Active';
        ap.Secondary_Owner__c = u.Id;
        
        APList.add(ap);       
        
        ID RecordTypeId2 = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'PowerSEO Account Plan');
        Account_Plan__c ap2 = new Account_Plan__c();
        ap2.RecordTypeId = RecordTypeId2;
        ap2.ownerId = u.Id;
        ap2.WebID__c = w.Id;
        ap2.Account__c = a.Id;
        ap2.Account_Status__c = 'Active';
        
        APList.add(ap2);
        
        insert APList;
        
        list<case> CaseList = new list<case>();
        
        ID CaseRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('case', 'Inquiry - SEO');
        Case c = DS_TestObjects.NewCase();
        c.AccountId = a.Id;
        c.WebID__c = w.Id;
        c.RecordTypeId = CaseRecordTypeId;
        c.Product_Category__c = 'Performance';
        c.Priority = '1-ONE Business Day';
        CaseList.add(c);
        
        
        Case c2 = DS_TestObjects.NewCase();
        c2.AccountId = a.Id;
        c2.WebID__c = w.Id;
        c2.RecordTypeId = CaseRecordTypeId;
        CaseList.add(c2);
        
        insert CaseList;

        c2.Product_Category__c = 'Performance';
        c2.Priority = '1-ONE Business Day';  
        Update c2;
    }
}