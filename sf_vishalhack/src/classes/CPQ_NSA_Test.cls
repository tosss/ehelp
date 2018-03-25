@isTest
public class CPQ_NSA_Test {

    @testSetup
    public static void setupTestData() {
        Account parentAccount = DS_TestObjects.NewAccount();
        parentAccount.Name = 'Test parent account';
        insert parentAccount;
        List<Account> accountsList = new List<Account>();
        Account acc1 = DS_TestObjects.NewAccount();
        acc1.Name = 'Test Acc1';
        acc1.ParentId = parentAccount.Id;
        accountsList.add(acc1);
        Account acc2 = DS_TestObjects.NewAccount();
        acc2.Name = 'Test Acc2';
        accountsList.add(acc2);
        insert accountsList;
        
        List<System_at_Dealership__c> dealershipRecordsList = new List<System_at_Dealership__c>();
        System_at_Dealership__c dealershipRecord1 = DS_TestObjects.NewSystemAtDealership();
        dealershipRecord1.Account__c = accountsList[0].Id;
        dealershipRecord1.Install_Date__c = System.today();
        dealershipRecord1.System_Type__c = 'DMS';
        dealershipRecordsList.add(dealershipRecord1);
        System_at_Dealership__c dealershipRecord2 = DS_TestObjects.NewSystemAtDealership();
        dealershipRecord2.Account__c = accountsList[1].Id;
        dealershipRecord2.System_Type__c = 'DMS';
        dealershipRecordsList.add(dealershipRecord2);
        System_at_Dealership__c dealershipRecord3 = DS_TestObjects.NewSystemAtDealership();
        dealershipRecord3.Account__c = parentAccount.Id;
        dealershipRecord3.Install_Date__c = System.today() + 1; 
        dealershipRecord3.System_Type__c = 'DMS';
        dealershipRecordsList.add(dealershipRecord3);
        insert dealershipRecordsList;
        
        
		List<NSA__c> nsaRecordsList = new List<NSA__c>();       
        NSA__c nsaRecord1 = new NSA__c();
        nsaRecord1.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('NSA__c', 'NSA');
        nsaRecord1.Account__c = accountsList[0].Id;
        //insert nsaRecord1;
        nsaRecordsList.add(nsaRecord1);
        
        NSA__c nsaRecord2 = new NSA__c();
        nsaRecord2.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('NSA__c', 'Price Protection');
        nsaRecord2.Account__c =  accountsList[0].Id;
        //insert nsaRecord2;
        nsaRecordsList.add(nsaRecord2);
        insert nsaRecordsList;

      
        
    }
    
    testmethod static void validateMainNSA() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Name LIKE '%Test Acc1%' LIMIT 1];
        NSA__c nsaRecord1 = [SELECT Id FROM NSA__c WHERE RecordType.Name = 'NSA' AND Account__c = :acc.Id];
        NSA__c nsaRecord2 = [SELECT Id, Main_NSA__c FROM NSA__c WHERE RecordType.Name = 'Price Protection' and Account__c = :acc.Id];
        System.assertEquals(nsaRecord1.Id, nsaRecord2.Main_NSA__c);
        Test.stopTest();
        
    }
    
    testmethod static void validateNSAFieldsOnAccount() {
        Test.startTest();
        Account acc1 = [SELECT Id, NSA__c, Price_Protection_NSA__c FROM Account WHERE Name LIKE '%Test Acc1%' LIMIT 1];
        Account acc2 = [SELECT Id, NSA__c, Price_Protection_NSA__c FROM Account WHERE Name LIKE '%Test Acc2%' LIMIT 1];
        NSA__c nsaRecord1 = [SELECT Id FROM NSA__c WHERE RecordType.Name = 'NSA' AND Account__c = :acc1.Id];
        NSA__c nsaRecord2 = [SELECT Id FROM NSA__c WHERE RecordType.Name = 'Price Protection' and Account__c = :acc1.Id];
        System.assertEquals(nsaRecord1.Id, acc1.NSA__c);
        System.assertEquals(nsaRecord2.Id, acc1.Price_Protection_NSA__c);
     
        nsaRecord1.Account__c = acc2.Id;
        nsaRecord2.Account__c = acc2.Id;
        update nsaRecord1;
        update nsaRecord2;
       
        Test.stopTest();
    }
    
    testmethod static void validateTermDates() {
        Account acc = [SELECT Id FROM Account WHERE Name LIKE '%Test parent account%' LIMIT 1];
        System_at_Dealership__c dealershipRecord1 = [SELECT Id, Install_Date__c, Contract_Term_Date__c FROM System_at_Dealership__c WHERE Account__r.Name LIKE '%test parent account%'];
        System_at_Dealership__c dealershipRecord2 = [SELECT Id, Install_Date__c, Contract_Term_Date__c FROM System_at_Dealership__c WHERE Account__r.Name LIKE '%Test acc1%'];
        System_at_Dealership__c minDateDealershipRecord = dealershipRecord1;
        if(dealershipRecord1.Install_Date__c > dealershipRecord2.Install_Date__c) {
            minDateDealershipRecord = dealershipRecord2;
        }
        NSA__c nsaRecord = new NSA__c();
        nsaRecord.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('NSA__c', 'Price Protection');
        nsaRecord.Account__c =  acc.Id;
        insert nsaRecord;
        
        nsaRecord = [SELECT Id, Term1_Start__c, Term1_End__c FROM NSA__c WHERE Id = :nsaRecord.Id];
        System.assertEquals(minDateDealershipRecord.Install_Date__c, nsaRecord.Term1_Start__c, 'NSA Term1 start date doesnot match');
        System.assertEquals(minDateDealershipRecord.Contract_Term_Date__c, nsaRecord.Term1_End__c, 'NSA Term1 end date doesnot match');
        
    }
    
}