// rq-05034 combine contact triggers 
// 2015-08-27 - brian.cook@cdk.com, bill.thurow@cdk.com
@IsTest
public with sharing class ALL_Contact_Test {
    @testSetup static void initialDataSetup() {
        list<Contact> cList = new list<Contact>();
        for(integer i = 1; i < 5; i++) {
            Contact c = DS_TestObjects.NewContact();
            c.AccountId = CustomSettings__c.getOrgDefaults().CDK_Global_Account_Id__c;
            User u = [select id, username from User where username like 'cdk_global_associate_community%' limit 1];
            c.User__c = u.Id;
            if(i != 2) {
                c.Status__c = 'Active';
            } else {
                c.Status__c = 'Inactive';
            }
            c.FirstName = 'Contact' + i;
            if(i != 3) {
            c.No_Longer_There__c = true;
            } else {
                c.No_Longer_There__c = false;
            }
            
            cList.add(c);
        }
        system.debug('ready to insert');
        database.insert(cList);
        system.debug('did insert....');
        
        //  DSCB test stuff
        Account a = DS_TestObjects.NewAccount();
        a.Do_Not_Fax__c = true;
        insert a;
        
        Contact c = DS_TestObjects.NewContact();
        c.AccountId = a.id;
        c.Authorized_Contract_Signer__c = true;
        insert c;       
        
        // DS test stuff
        //Creating CDK GLOBAL Account
        Account newAccount =  DS_TestObjects.NewAccount();
        newAccount.Name = 'CDK GLOBAL';
        insert newAccount;
        
        Account newAccountTest = DS_TestObjects.NewAccount();
        newAccountTest.Name = 'Test Account';
        insert newAccountTest;
        
        //Updating the Org Defaults of CustomSetting__c 
        CustomSettings__c settings = CustomSettings__c.getOrgDefaults();
        settings.CDK_Global_Account_Id__c = newAccount.Id;
        settings.DS_ContactBeforeInsertUpdate_On__c = true;
        insert settings;
        
        Contact conDS = DS_TestObjects.NewContact();
        conDS.Authorized_Contract_Signer__c = true;
        database.insert(conDS);
        
        Contact ct = DS_TestObjects.NewContact();
        ct.Authorized_Contract_Signer__c = true;
        ct.AccountId = newAccounttest.Id;
        ct.LastName = 'Test';
        database.insert(ct);
        
        Contact con = DS_TestObjects.NewContact();
        con.Authorized_Contract_Signer__c = true;
        con.AccountId = newAccounttest.Id;
        con.LastName = 'NewTest';
        database.insert(con);
    }
    
    static testMethod void changeNoLongerThereOne() {
        system.debug('changeNoLongerThereOne start');
        list<Contact> c = [
            SELECT Id,Status__c,No_Longer_There__c,FirstName FROM Contact WHERE FirstName LIKE 'Contact%'
        ];
        
        if(c.size() == 4){
            c[0].Status__c = 'Inactive';
            c[1].Status__c = 'Active';
            c[2].No_Longer_There__c = true;
            c[3].No_Longer_There__c = false;
            
            Map<Id,Contact> m = new Map<Id,Contact>();
            for(Contact cm : c) {
                m.put(cm.Id,cm);
            }
            ALL_Contact_Handler.beforeUpdate(c,m);
                        
            update(c);
            
            boolean b = true;
            list<Contact> uc = [
                SELECT Id,Status__c,No_Longer_There__c,FirstName FROM Contact WHERE FirstName LIKE 'Contact%'
            ];
            if(uc.size() == 4){
                if(!uc[0].No_Longer_There__c) {
                    b = false;
                }
                if(uc[1].No_Longer_There__c) {
                    b = false;
                }
                if(uc[2].Status__c != 'Inactive'){
                    b = false;
                }
                if(uc[3].Status__c != 'Active'){
                    b = false;
                }
                system.assert(b);
            } else {
                system.assert(false,'4 contact records not created for testing!');
            }
        } else {
            system.assert(false,'4 contact records not created for testing!');
        }
        system.assert(true);
    }
    
    // DS contact Tests
    static testMethod void DSReallyTestDuplicate(){
        system.debug('DSReallyTestDuplicate start');
        try {
            Account a = [Select id from Account where Name = 'Test Account' LIMIT 1];
            Contact dup = DS_TestObjects.NewContact();
            dup.Authorized_Contract_Signer__c = true;
            dup.AccountId = a.Id;
            //dup.LastName = 'Test';
            database.insert(dup);
        } catch(exception e) {
            system.assert(true);
        }
    }
    static testMethod void DSTestDuplicate() {
        system.debug('DSTestDuplicate start');
        CustomSettings__c settings = CustomSettings__c.getOrgDefaults();
        Contact c = [
            SELECT Id, Name, AccountId, Authorized_Contract_Signer__c FROM Contact WHERE Authorized_Contract_Signer__c = true and LastName = 'Test' LIMIT 1  
        ];
        c.Authorized_Contract_Signer__c = !c.Authorized_Contract_Signer__c;
        database.upsert(c);
    }
    
    static testMethod void DSnegDeleteTest() {
        system.debug('DSnegDeleteTest start');
        list<Contact> c = [
            SELECT Id,Authorized_Contract_Signer__c FROM Contact WHERE Authorized_Contract_Signer__c = true LIMIT 1  
        ];
        if(c.size() > 0){
            try{
                database.delete(c);
                system.assert(false);
            } catch(Exception e){
                system.debug(e.getMessage());
                string err = e.getMessage();
                if(err.contains('ERROR: Contacts designated as Authorized Contract Signers can not be deleted!')) {
                    system.assert(true);
                } else {
                    system.assert(false);
                }
            }
        }
    }
    
    // DSCB contact tests
    private static testMethod void DSCBbeforeInsert(){
        system.debug('DSCBbeforeInsert start');
        Account a = DS_TestObjects.NewAccount();
        a.Do_Not_Fax__c = true;
        insert a;
        
        Contact c = DS_TestObjects.NewContact();
        c.AccountId = a.id;
        c.Authorized_Contract_Signer__c = true;
        insert c; 
    }
    
    private static testMethod void DSCBbeforeUpdate(){
        system.debug('DSCBbeforeUpdate start');
        Contact c = [select id, Do_Not_Fax__c, Do_Not_Solicit__c from Contact limit 1];
        c.Do_Not_Fax__c = !c.Do_Not_Fax__c;
        c.Do_Not_Solicit__c = !c.Do_Not_Solicit__c;
        upsert c;
    }
    
    private static testMethod void DSCBtestDoNotFields(){
        system.debug('DSCBtestDoNotFields start');
        Account a = [select id, Do_Not_Fax__c, Do_Not_Solicit__c from Account limit 1];
        Contact c = [select id, Do_Not_Fax__c, Do_Not_Solicit__c from Contact limit 1];
        a.Do_Not_Fax__c = true;
        a.Do_Not_Solicit__c = true;
        c.accountid = a.id;
        c.Do_Not_Fax__c = false;
        c.Do_Not_Solicit__c = false;
        
        list<Contact> con = new list<Contact>();
        con = ALL_Contact_Handler.SetContactDoNotFields(con, c, a);
    }
    
    private static testMethod void DSCBacctAfterUpdateFromAccount(){
       system.debug('DSCBacctAfterUpdateFromAccount start'); 
        map<Id, Account> nm = new map<Id, Account>();
        map<Id, Account> om = new map<Id, Account>();
        Account a = [select id, Do_Not_Fax__c, Do_Not_Solicit__c from Account limit 1];    
        a.Do_Not_Fax__c = true;
        a.Do_Not_Solicit__c = true;
        upsert a;
        om.put(a.id, a); 
        a.Do_Not_Fax__c = false;
        a.Do_Not_Solicit__c = false;
        nm.put(a.id, a);
        system.debug(om);
        system.debug(nm);
        list<Account> acc = new list<Account>();
        All_Contact_Handler.afterUpdateFromAccount(nm, om);
    } 
}