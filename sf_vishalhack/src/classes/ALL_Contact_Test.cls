// rq-05034 combine contact triggers 
// 2015-08-27 - brian.cook@cdk.com, bill.thurow@cdk.com
//2016-05-02- anirudh.singh@cdk.com- For RQ-06383, Removed the test method for setContactDoNotFields method, as the method is not public.
//2017-02-27  ragashalini.koka@cdk.com - Bulkified the SOQLs in testSetup to avoid the SOQL Limits
@IsTest
public with sharing class ALL_Contact_Test {
  
    @testSetup static void initialDataSetup() {
        CustomSettings__c cs = CustomSettings__c.getOrgDefaults();
        cs.CDK_Global_Account_Id__c = DS_TestObjects.NewAccount_Inserted().Id;
        upsert cs;
        List<Account> accList = new List<Account>();
        List<Contact> cList = new List<Contact>();
        List<Contact_Relationship__c> crList = new list<Contact_Relationship__c>();
        for(integer i = 1; i < 5; i++) {
            Contact c = DS_TestObjects.NewContact();
            c.AccountId = CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c;
            User u = [select id, username from User where username like 'cdk_global_associate_community%' limit 1];
            c.User__c = u.Id;
            
            c.FirstName = 'Contact' + i;
            cList.add(c);
        }
        
        //  DSCB test stuff
        Account a = DS_TestObjects.NewAccount();
        a.Do_Not_Fax__c = true;
        accList.add(a);
        //insert a;
        
        // DS test stuff--Creating CDK GLOBAL Account
        Account newAccount =  DS_TestObjects.NewAccount();
        newAccount.Name = 'CDK GLOBAL';
        accList.add(newAccount);
        //insert newAccount;
        
        Account newAccountTest = DS_TestObjects.NewAccount();
        newAccountTest.Name = 'Test Account';
        accList.add(newAccountTest);
        //insert newAccountTest;
        
        insert accList;
        
        //Updating the Org Defaults of CustomSetting__c 
        CustomSettings__c settings = CustomSettings__c.getOrgDefaults();
        settings.CDK_Global_Account_Id__c = newAccount.Id;
        settings.DS_ContactBeforeInsertUpdate_On__c = true;
        upsert settings;
        
        
        Contact c = DS_TestObjects.NewContact();
        c.AccountId = accList[0].Id;
        // c.Authorized_Contract_Signer__c = true;
        cList.add(c);
        //insert c;  
        
        Contact conDS = DS_TestObjects.NewContact();
        //database.insert(conDS);
        cList.add(conDS);
        
        Contact ct = DS_TestObjects.NewContact();
        //ct.Authorized_Contract_Signer__c = true;
        ct.AccountId = newAccounttest.Id;
        ct.LastName = 'Test';
        ct.Do_Not_Solicit__c = True;
        //database.insert(ct);
        cList.add(ct);
        
        Contact con = DS_TestObjects.NewContact();
        //con.Authorized_Contract_Signer__c = true;
        con.AccountId = newAccounttest.Id;
        con.LastName = 'NewTest';
        con.Do_Not_Solicit__c = True;
        //database.insert(con);
        cList.add(con);
        
        insert cList;
        
        Contact_Relationship__c crObj = new Contact_Relationship__c();
        crObj.Account__c = a.id;
        crObj.Contact__c = c.id;
        crObj.Authorized_Contract_Signer__c = true;
        crList.add(crObj);
        //insert crObj;
        Contact_Relationship__c CR = new Contact_Relationship__c();
        CR.Account__c = newAccounttest.Id;
        CR.Contact__c = conDS.Id;
        CR.Authorized_Contract_Signer__c = true;
        // database.insert(CR);
        crList.add(CR);
        
        CR = new Contact_Relationship__c();
        CR.Account__c = newAccounttest.Id;
        CR.Contact__c = ct.Id;
        CR.Authorized_Contract_Signer__c = true;
        // database.insert(CR);
        crList.add(CR);
        
        CR = new Contact_Relationship__c();
        CR.Account__c = newAccounttest.Id;
        CR.Contact__c = con.Id;
        CR.Account_Contact_Id__c = newAccounttest.Id +''+con.Id;
        CR.Authorized_Contract_Signer__c = true;
        //database.insert(CR);
        crList.add(CR);
        //database.insert(cList);
        
        
        
        for(integer i = 0; i < 4; i++)
        {
            Contact_Relationship__c crRef = DS_TestObjects.newContactRelationship();
            crRef.Account__c = CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c;
            crRef.Contact__c = cList[i].id;
            
            if(i != 1) {
                crRef.Status__c = 'Active';
            } else {
                crRef.Status__c = 'Inactive';
            }
            if(i != 2) {
                crRef.No_Longer_There__c = true;
            } else {
                crRef.No_Longer_There__c = false;
            }
            crList.add(crRef);
        }
        
        insert crList;
        
        
        
    }
    
    static testMethod void changeNoLongerThereOne() {
        Test.startTest();
        Map<Id,Contact> c = new Map<Id,Contact>([
            SELECT Id,FirstName,AccountId
            FROM 
            Contact 
            WHERE FirstName LIKE 'Contact%'
        ]);
        List<Contact_Relationship__c> crList = [Select id,Status__c,No_Longer_There__c from Contact_Relationship__c where contact__c IN: c.keySet()];
        if(crList.size() == 4){
            crList[0].Status__c = 'Inactive';
            crList[1].Status__c = 'Active';
            crList[2].No_Longer_There__c = true;
            crList[3].No_Longer_There__c = false;
            
            Map<Id,Contact> m = new Map<Id,Contact>();
            for(Contact cm : c.values()) {
                m.put(cm.Id,cm);
            }
            ALL_Contact_Handler.beforeUpdate(c.values(),m);
            update crList;
        }
        else 
        {
            system.assert(false,'4 contact records not created for testing!');
        }
        system.assert(true);
        Test.stopTest();
    }
    
    // DS contact Tests
    static testMethod void DSReallyTestDuplicate() {
        Test.startTest();
        system.debug('DSReallyTestDuplicate start');
        try {
            Account a = [Select id from Account where Name = 'Test Account' LIMIT 1];
            Contact dup = DS_TestObjects.NewContact();
            dup.AccountId = a.Id;
            database.insert(dup);
        } catch(exception e) {
            system.assert(true);
        }
        Test.stopTest();
    }
    static testMethod void DSTestDuplicate() {
        Test.startTest();
        CustomSettings__c settings = CustomSettings__c.getOrgDefaults();
        Contact c = [
            SELECT Id, Name, AccountId FROM Contact WHERE LastName = 'Test' LIMIT 1  
        ];
        Contact_Relationship__c cr = [Select id,Authorized_Contract_Signer__c from  Contact_Relationship__c where contact__c =: c.id Limit 1];
        cr.Authorized_Contract_Signer__c = !cr.Authorized_Contract_Signer__c;
        database.upsert(cr);
        Test.stopTest();
    }
    
    static testMethod void DSnegDeleteTest() {
        Test.startTest();
        list<Contact> contacts = [
            SELECT Id FROM Contact LIMIT 1  
        ];
        Contact_Relationship__c cr = new Contact_Relationship__c();
        cr.Contact__c = contacts[0].Id;
        cr.Account__c = DS_TestObjects.NewAccount_Inserted().Id;
        insert cr;
        if(contacts.size() > 0){
            database.delete(contacts);
        }
        Test.stopTest();
    }
    
    // DSCB contact tests
    private static testMethod void DSCBbeforeInsert(){
        Account a = DS_TestObjects.NewAccount();
        a.Do_Not_Fax__c = true;
        insert a;
        Test.startTest();
        Contact c = DS_TestObjects.NewContact();
        c.AccountId = a.id;
        insert c; 
        Test.stopTest();
    }
    
    private static testMethod void DSCBbeforeUpdate(){
        Test.startTest();
        Contact c = [select id, Do_Not_Fax__c, Do_Not_Solicit__c from Contact limit 1];
        c.Do_Not_Fax__c = !c.Do_Not_Fax__c;
        c.Do_Not_Solicit__c = !c.Do_Not_Solicit__c;
        upsert c;
        Test.stopTest();
    }
    
    private static testMethod void DSCBacctAfterUpdateFromAccount(){
        Test.startTest();
        map<Id, Account> nm = new map<Id, Account>();
        map<Id, Account> om = new map<Id, Account>();
        Account a = [
            Select 
            id, Do_Not_Fax__c, Do_Not_Solicit__c
            From Account limit 1
        ];    
        a.Do_Not_Fax__c = true;
        a.Do_Not_Solicit__c = true;
        upsert a;
        om.put(a.id, a); 
        a.Do_Not_Fax__c = false;
        a.Do_Not_Solicit__c = false;
        nm.put(a.id, a);
        list<Account> acc = new list<Account>();
        Test.stopTest();
    } 
}