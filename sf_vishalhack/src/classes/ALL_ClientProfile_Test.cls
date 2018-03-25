@isTest
public class ALL_ClientProfile_Test 
{
    static testMethod void unitTest()
    {
        Account newAccount = DS_TestObjects.NewAccount_Inserted();
        
        ID AAaccountPlan = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'AA Account Plan');
        ID DAAaccountPlan = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'DAA Account Plan');
        ID SEOAccountPlan = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'SEO Account Plan');
        ID PowerSEOAccountPlan = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account_Plan__c', 'PowerSEO Account Plan');
        
        WebID__c webID1 = DS_TestObjects.NewWebID();
        webID1.Account__c = newAccount.ID;
        
        WebID__c webID2 = DS_TestObjects.NewWebID();
        webID2.Account__c = newAccount.ID;
        
        WebID__c webID3 = DS_TestObjects.NewWebID();
        webID3.Account__c = newAccount.ID;
        
        WebID__c webID4 = DS_TestObjects.NewWebID();
        webID4.Account__c = newAccount.ID;
        
        insert new list<webID__c> { webID1, webID2, webID3, webID4 };
            
        Account_Plan__c AA_AP = DS_TestObjects.NewAccountPlan();
        AA_AP.RecordTypeId = AAaccountPlan;
        AA_AP.Account_Status__c = 'Active';
        AA_AP.webID__c = webID1.ID;
        AA_AP.Account__c = newAccount.ID;
        AA_AP.Product_Mix__c = 'Product mixture is pretty good';
                
        Account_Plan__c DAA_AP = DS_TestObjects.NewAccountPlan();
        DAA_AP.RecordTypeId = DAAaccountPlan;
        DAA_AP.Account_Status__c = 'Active';
        DAA_AP.webID__c = webID2.ID;
        DAA_AP.Account__c = newAccount.ID;
        DAA_AP.Product_Mix__c = 'Product mixture is pretty good';
        
        Account_Plan__c SEO_AP = DS_TestObjects.NewAccountPlan();
        SEO_AP.RecordTypeId = SEOAccountPlan;
        SEO_AP.Account_Status__c = 'Active';
        SEO_AP.webID__c = webID3.ID;
        SEO_AP.Account__c = newAccount.ID;
        SEO_AP.Product_Mix__c = 'Product mixture is pretty good';
        
        Account_Plan__c PowerSEO_AP = DS_TestObjects.NewAccountPlan();
        PowerSEO_AP.RecordTypeId = PowerSEOAccountPlan;
        PowerSEO_AP.Account_Status__c = 'Active';
        PowerSEO_AP.webID__c = webID4.ID;
        PowerSEO_AP.Account__c = newAccount.ID;
        PowerSEO_AP.Product_Mix__c = 'Product mixture is pretty good';
         
        insert new list<Account_Plan__c>{ AA_AP, DAA_AP, SEO_AP, PowerSEO_AP };
            
        Client_Profile__c cp1 = new Client_Profile__c();
        cp1.WebID__c =  webID1.ID;
        
        Client_Profile__c cp2 = new Client_Profile__c();
        cp2.WebID__c =  webID2.ID;
        
        Client_Profile__c cp3 = new Client_Profile__c();
        cp3.WebID__c =  webID3.ID;
        
        Client_Profile__c cp4 = new Client_Profile__c();
        cp4.WebID__c =  webID4.ID;
        
        insert new list<Client_Profile__c> { cp1, cp2, cp3, cp4 };             
    }
}