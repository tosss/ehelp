//2016-10-12 - ragashalini.koka@cdk.com - RQ-07945 - Created this class
@isTest
private class ALL_Contract_Line_Test {
    
    @TestSetup static void setupTestData() {
        List<Product2> productList = new List<Product2>();
        Product2 productRecord1 = new Product2();
        productRecord1.Name = '123456';
        productRecord1.Migration_ID__c = 'Test1';
        productRecord1.Schedule_Type__c = 'EQ';
        productList.add(productRecord1);
        Product2 productRecord2 = new Product2();
        productRecord2.Name = '78910';
        productRecord2.Migration_ID__c = 'Test2';
        productRecord2.Schedule_Type__c = 'SW';
        productList.add(productRecord2);
        insert productList;
        
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        insert accountRecord;
        
        WebId__c webId = DS_TestObjects.NewWebID_Inserted();
        
        Contract contractRecord = new Contract();
        contractRecord.AccountId = accountRecord.Id;
        contractRecord.Status = 'Draft';
        contractRecord.Migration_ID__c = 'Test';
        contractRecord.External_Data_Source__c = 'ARNA';
		insert contractRecord;        
        
        List<ALL_Contract_Line__c> contractLineList = new List<ALL_Contract_Line__c>();
    	ALL_Contract_Line__c  contractLineRecord1 = new ALL_Contract_Line__c();
        contractLineRecord1.Name = 'Test Contract Line1';
        contractLineRecord1.Quantity_Sold__c = 10;
        contractLineRecord1.Contract__c = contractRecord.Id;
        contractLineRecord1.Part_Number__c = '123456';
        contractLineRecord1.Data_Source__c = 'ARNA';
        contractLineList.add(contractLineRecord1);
        
        ALL_Contract_Line__c  contractLineRecord2 = new ALL_Contract_Line__c();
        contractLineRecord2.Name = 'Test Contract Line2';
        contractLineRecord2.Quantity_Sold__c = 10;
        contractLineRecord2.Contract__c = contractRecord.Id;
        contractLineRecord2.Data_Source__c = 'ARNA';
        contractLineList.add(contractLineRecord2);
        insert contractLineList;
   
        
    }
    
    testmethod static void validateCurrentProductUpdation() {
        
        Test.startTest();
        ALL_Contract_Line__c contractLine = [SELECT Id, Product__c, Product_Current__c, Part_Number__c FROM ALL_Contract_Line__c WHERE Name LIKE '%Test Contract Line1%' LIMIT 1];
        Map<Id,Product2> productsMap = new Map<Id,Product2>([SELECT Id,Name, Schedule_Type__c FROM Product2]);
		System.assertEquals(productsMap.get(contractLine.Product__c).Name, contractLine.Part_Number__c);
        System.assertEquals(productsMap.get(contractLine.Product_Current__c).Name, contractLine.Part_Number__c);
        
        contractLine.Part_Number__c = '78910';
        update contractLine;
        contractLine = [SELECT Id, Product__c, Product_Current__c, Part_Number__c, Schedule_Type__c FROM ALL_Contract_Line__c WHERE Name LIKE '%Test Contract Line1%' LIMIT 1];
        System.assertNotEquals(productsMap.get(contractLine.Product__c).Name, contractLine.Part_Number__c);
        System.assertEquals(productsMap.get(contractLine.Product_Current__c).Name, contractLine.Part_Number__c);
        System.assertEquals(productsMap.get(contractLine.Product_Current__c).Schedule_Type__c, contractLine.Schedule_Type__c);
        Test.stopTest();
        
        
    }
    
    testmethod static void validateWebIdUpdate() {
        WebId__c webId = [Select Id, Name FROM WebId__c LIMIT 1];
        ALL_Contract_Line__c contractLine = [SELECT Id FROM ALL_Contract_Line__c LIMIT 1];
        contractLine.WebId_Text__c = webId.Name;
        Test.startTest();
        update contractLine;
        contractLine = [SELECT Id, WebId__c FROM ALL_Contract_Line__c WHERE Id = :contractLine.Id];
        System.assertEquals(webId.Id, contractLine.WebID__c);
        Test.stopTest();
        
    }
    
    testmethod static void validateUpdateContractAudit() {
       
        List<ALL_Contract_Line__c> contractLineList = [SELECT Id FROM ALL_Contract_Line__c];
        Set<Id> contractLineIdSet = new Set<Id>();
        for(Integer i = 0;i < contractLineList.size();i++) {
            if(Math.mod(i, 2) == 0) {
                contractLineList[i].Quantity_Lost__c = 1; 
            }
            else {
                contractLineList[i].Quantity_Cancelled__c = 1;
            }
            contractLineIdSet.add(contractLineList[i].Id);
        }
        update contractLineList;
        
       contractLineList = [SELECT Id, (SELECT Id FROM Contract_Audits__r) FROM ALL_Contract_Line__c];
        
        for(ALL_Contract_Line__c contractLine : contractLineList) {
            System.assertEquals(true, contractLine.Contract_Audits__r.size() > 0, 'Contract Audit not found');
        }
        
        
        
    }

}