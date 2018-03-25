//2016-01-27- anirudh.singh@cdk.com- Created this class for the replacing the class DSCB_AccountReLinkTest for Request RQ-06021.
//2016-01-27- anirudh.singh@cdk.com- As the earlier class DSCB_AccountReLinkTest was not following naming standards.
//2016-01-27- anirudh.singh@cdk.com- Also, re-written the whole test class for following test class standards.
//2016-06-06- ragashalini.koka@cdk.com - Changed the test class to meet the requirements of Shared Contacts (RQ-06992)
//2016-06-10- ragashalini.koka@cdk.com  moved Role__c from Contact to Contact_Relationship__c.
@isTest
public class DSCB_AccountReLink_Test
{
    //2015-11-24- anirudh.singh@cdk.com- Added the below testSetup.
    @TestSetup
    private static void setupData()
    {
        Job_Settings__c batchSettingRef=new Job_Settings__c();
        batchSettingRef.Name='Record 1';
        batchSettingRef.Class_Name__c='DSCB_AccountReLink_Batch';
        //2015-12-23- anirudh.singh@cdk.com- Changed the reference Finish_Email__c to Finish_Emails__c.
        batchSettingRef.Finish_Emails__c='anirudh.singh@cdk.com';
        insert batchSettingRef;
        
        List<Account> accList=new List<Account>();
        Account testSourceAccount=new Account();
        testSourceAccount.Name='Source';
        testSourceAccount.PartyID__c='0001'; 
        testSourceAccount.Account_Number__c='10000';
        accList.add(testSourceAccount);
        
        Account testDestinationAccount=new Account();
        testDestinationAccount.Name='Destination';
        testDestinationAccount.PartyID__c='0002';
        testDestinationAccount.Account_Number__c='20000';
        accList.add(testDestinationAccount);
        insert accList;
        
        List<Contact> contactsList = new List<Contact>();
        
        Contact testSourceContact=DS_TestObjects.NewContact();
        testSourceContact.AccountId=testSourceAccount.Id;
        //2015-11-27  vishal.bandari@cdk.com RQ-05289:added contact record type
        testSourceContact.RecordType=[select id from recordtype where name='Customer Contact' and SobjectType='Contact'][0];
        //2016-06-15- ragashalini.koka@cdk.com- Added the below line for using ALL_SharedContacts_Helper for inserting Contact.
        ALL_SharedContact_Helper.insertContact(testSourceContact, 'Test Role', null, null);
        
        //2016-06-15- ragashalini.koka@cdk.com- Commented the below two lines as Role field is no longer present on Contact.
        //testSourceContact.Role__c='Test Role'; // 9/29
        //insert testSourceContact;
        
        Note testSourceNote=new Note();
        testSourceNote.ParentId=testSourceAccount.Id;
        testSourceNote.Title='Test Note 1';
        insert testSourceNote;
        
        Attachment atc = new Attachment();
        Blob b  = Blob.valueOf('Account Relink test Data');
        atc.Name = 'Test Attachment';
        atc.ParentId = testSourceAccount.Id;
        atc.Body =b;
        insert atc;
        
      
        
        List<AccountReLinkObject__c> accReLinkObjectList=new List<AccountReLinkObject__c>();
        AccountReLinkObject__c accReLinkObjectOne=new AccountReLinkObject__c();
        accReLinkObjectOne.Name='Contact';
        accReLinkObjectOne.Account_Field__c='AccountId';
        accReLinkObjectOne.Account_Relationship_Name__c='Contacts';
        accReLinkObjectOne.Action__c='Update';
        accReLinkObjectOne.Fields__c='Id, Name, AccountId,CreatedDate, OwnerId, Owner.IsActive, Owner.Name';
        accReLinkObjectOne.Object_API_Name__c='Contact';
        accReLinkObjectOne.Order__c=1;
        accReLinkObjectList.add(accReLinkObjectOne);
        
        AccountReLinkObject__c accReLinkObjectTwo=new AccountReLinkObject__c();
        accReLinkObjectTwo.Name='Note';
        accReLinkObjectTwo.Account_Field__c='ParentId';
        accReLinkObjectTwo.Account_Relationship_Name__c='Notes';
        accReLinkObjectTwo.Action__c='Clone';
        //accReLinkObjectTwo.Fields__c='Id, Title, ParentId, Owner.Profile.Name, OwnerId, Owner.Id, Owner.IsActive, Owner.Name';
        accReLinkObjectTwo.Object_API_Name__c='Note';
        accReLinkObjectTwo.Order__c=3;
        accReLinkObjectList.add(accReLinkObjectTwo);
        
        AccountReLinkObject__c accReLinkObjectThree = new AccountReLinkObject__c();
        accReLinkObjectThree.Name='Contact_Relationship__c';
        accReLinkObjectThree.Account_Field__c='Account__c';
        accReLinkObjectThree.Account_Relationship_Name__c='Contact_Relationships';
        accReLinkObjectThree.Action__c='Clone';
        accReLinkObjectThree.Object_API_Name__c='Contact_Relationship__c';
        accReLinkObjectThree.Fields__c='Id, Account__c, Contact__c';
        accReLinkObjectThree.Order__c=2;
        accReLinkObjectList.add(accReLinkObjectThree);
        
        insert accReLinkObjectList;
    }
    
    private static Map<String, Account> generateAccountMap()
    {
        List<Account> accList=[SELECT Name, Account_Number__c, PartyID__c FROM Account];
        
        Map<String, Account> accountMap=new Map<String, Account>();
        for(Account acc: accList)
        {
            accountMap.put(acc.Name, acc);
        }
        
        return accountMap;
    }
    
    private static Account_ReLink__c generateAccountReLink(Map<String, Account> accountMap)
    {
        Account_ReLink__c testAccountReLink=new Account_ReLink__c();
        testAccountReLink.Cobalt_Account_Number__c=accountMap.get('Source').Account_Number__c;
        testAccountReLink.Party_ID__c=accountMap.get('Destination').PartyID__c;
        
        return testAccountReLink;
    }
    
    private static testMethod void constructorTest()
    {
        test.startTest();
        DSCB_AccountReLink_Handler controller=new DSCB_AccountReLink_Handler();
        test.stopTest();
    }
    
    private static testmethod void processAccountReLinksBeforeInsertTestOne()
    {
        Map<String, Account> accountMap=generateAccountMap();
        
        test.startTest();
        Account_ReLink__c testAccountReLink=generateAccountReLink(accountMap);
        DSCB_AccountReLink_Handler.processAccountReLinksBeforeInsert(new List<Account_ReLink__c>{testAccountReLink});
        test.stopTest();
    }
    
    private static testmethod void processAccountReLinksBeforeInsertTestTwo()
    {
        test.startTest();
        Account_ReLink__c testAccountReLink=new Account_ReLink__c();
        DSCB_AccountReLink_Handler.processAccountReLinksBeforeInsert(new List<Account_ReLink__c>{testAccountReLink});
        DSCB_AccountReLink_Handler.processAccountReLinksAfterInsert(Null);
        test.stopTest();
    }
    
    private static testmethod void processAccountReLinksBeforeInsertTestThree()
    {
        test.startTest();
        Account_ReLink__c testAccountReLink=new Account_ReLink__c();
        testAccountReLink.Cobalt_Account_Number__c='278427147';
        testAccountReLink.Party_ID__c='2471527457';
        DSCB_AccountReLink_Handler.processAccountReLinksBeforeInsert(new List<Account_ReLink__c>{testAccountReLink});
        test.stopTest();
    }
    
    private static testMethod void processAccountReLinksAfterInsertTest()
    {
        Map<String, Account> accountMap=generateAccountMap();
        
        test.startTest();
        Account_ReLink__c testAccountReLink=generateAccountReLink(accountMap);
        insert testAccountReLink;
        
        DSCB_AccountReLink_Handler.processAccountReLinksAfterInsert(new List<Account_ReLink__c>{testAccountReLink});
        test.stopTest();
    }
    
    private static testMethod void processRelinksTest()
    {
        Map<String, Account> accountMap=generateAccountMap();
        
        Account_ReLink__c testAccountReLink=generateAccountReLink(accountMap);
        testAccountReLink.Cobalt_Account__c=accountMap.values()[0].Id;
        insert testAccountReLink;
        
        test.startTest();
        system.assert(DSCB_AccountReLink_Handler.processRelinks(new List<Account_ReLink__c>{testAccountReLink})!=Null);
        test.stopTest();
    }
    
    private static testMethod void queryAndUpdateTestOne()
    {
        Map<String, Account> accountMap=generateAccountMap();
        
        Account_ReLink__c testAccountReLink=generateAccountReLink(accountMap);
        insert testAccountReLink;
        
        Account_ReLink__c queryAccountReLink=[
            Select Id, Name, Party_ID__c, Cobalt_Account_Number__c, Cobalt_Account__c, Party_Account__c, CreatedDate 
            From Account_ReLink__c 
            Where Id=:testAccountReLink.Id 
            Limit 1
        ];
        
        Set<Id> contactIds=new Set<Id>();
        List<Contact> testAccountContacts=[Select Id From Contact Where AccountId=:queryAccountReLink.Cobalt_Account__c];
        for(Contact contactRec : testAccountContacts)
        {
            contactIds.add(contactRec.Id);
        }
        
        Map<Id, Id> replacementOwnerUsers=new Map<Id, Id>();
        replacementOwnerUsers.put(UserInfo.getUserId(), UserInfo.getUserId());
        
        AccountReLinkObject__c accReLinkContact=[
            SELECT Object_API_Name__c, Fields__c, Account_Field__c 
            FROM AccountReLinkObject__c 
            WHERE Name='Contact'
        ];
        
        test.startTest();
        system.assert((DSCB_AccountReLink_Handler.queryAndUpdate(contactIds, replacementOwnerUsers, accReLinkContact.Object_API_Name__c, accReLinkContact.Fields__c, 
                                                                 accReLinkContact.Account_Field__c, queryAccountReLink.Party_Account__c)).size()>0);
        test.stopTest();
    }
    
    private static testMethod void queryAndUpdateTestTwo()
    {
        Contact contactRecord=[SELECT Id FROM Contact limit 1];
        
        Map<Id, Id> replacementOwnerUsers=new Map<Id, Id>();
        replacementOwnerUsers.put(UserInfo.getUserId(), UserInfo.getUserId());
        
        test.startTest();
        system.assert(DSCB_AccountReLink_Handler.queryAndUpdate(Null, Null, Null, Null, Null, Null)==Null);
        
        system.assert(DSCB_AccountReLink_Handler.queryAndUpdate(new Set<Id>(), Null, Null, Null, Null, Null)==Null);
        
        system.assert(DSCB_AccountReLink_Handler.queryAndUpdate(new Set<Id>{contactRecord.Id}, replacementOwnerUsers, Null, Null, Null, Null)==Null);
        test.stopTest();
    }
    
    private static testmethod void queryAndCloneTestOne()
    {
        Map<String, Account> accountMap=generateAccountMap();
        
        AccountReLinkObject__c accReLinkNote=[
            SELECT Object_API_Name__c, Fields__c, Account_Field__c 
            FROM AccountReLinkObject__c 
            WHERE Name='Note' 
            Limit 1
        ];
		accReLinkNote.Fields__c='Id, Title, ParentId, Owner.Profile.Name, OwnerId, Owner.Id, Owner.IsActive, Owner.Name';
		update accReLinkNote;
        
        test.startTest();
        Account_ReLink__c testAccountReLink=generateAccountReLink(accountMap);
        insert testAccountReLink;
        
        Account_ReLink__c queryAccountReLink=[
            Select Id, Name, Party_ID__c, Cobalt_Account_Number__c, Cobalt_Account__c, Party_Account__c 
            From Account_ReLink__c 
            Where Id=:testAccountReLink.Id 
            Limit 1
        ];
        
        Set<Id> noteIds=new Set<Id>();
        List<Note> testAccountNotes=[Select Id From Note Where ParentId=:queryAccountReLink.Cobalt_Account__c];
        for(Note noteRec: testAccountNotes)
        {
            noteIds.add(noteRec.Id);
        }
        
        Map<Id, Id> ReplacementOwnerUsers=new Map<Id, Id>();
        ReplacementOwnerUsers.put(UserInfo.getUserId(), UserInfo.getUserId());
        
        system.assert(DSCB_AccountReLink_Handler.queryAndClone(noteIds, replacementOwnerUsers, accReLinkNote.Object_API_Name__c, accReLinkNote.Fields__c, 
                                                 accReLinkNote.Account_Field__c, queryAccountReLink.Party_Account__c).size()>0);
        test.stopTest();
    }
    
    private static testmethod void queryAndCloneTestTwo()
    {
        Note testSourceNote=[SELECT Id FROM Note];
        
        Map<Id, Id> replacementOwnerUsers=new Map<Id, Id>();
        replacementOwnerUsers.put(UserInfo.getUserId(), UserInfo.getUserId());
        
        test.startTest();
        system.assert(DSCB_AccountReLink_Handler.queryAndClone(Null, Null, Null, Null, Null, Null)==Null);
        
        system.assert(DSCB_AccountReLink_Handler.queryAndClone(new Set<Id>(), Null, Null, Null, Null, Null)==Null);
        
        system.assert(DSCB_AccountReLink_Handler.queryAndClone(new Set<Id>{testSourceNote.Id}, replacementOwnerUsers, Null, Null, Null, Null)==Null);
        test.stopTest();
    }
    
    private static testmethod void submitReLinkAndCheckReLinkTest()
    {
        Map<String, Account> accountMap=generateAccountMap();
        
		AccountReLinkObject__c accReLinkNote=[SELECT Fields__c FROM AccountReLinkObject__c WHERE Name='Note' Limit 1];
		accReLinkNote.Fields__c='Id, Title, ParentId, Owner.Profile.Name, OwnerId, Owner.Id, Owner.IsActive, Owner.Name';
		update accReLinkNote;

        test.startTest();
        Account_ReLink__c testAccountReLink=generateAccountReLink(accountMap);
        insert testAccountReLink;
        
        Id BatchId=DSCB_AccountReLink_Handler.submitReLink(testAccountReLink.Id);
        DSCB_AccountReLink_Handler.checkReLinkStatus(BatchId);
        test.stopTest();
    }
    
    private static testmethod void batchTest()
    {
        Map<String, Account> accountMap=generateAccountMap();
        
        AccountReLinkObject__c accReLinkNote=[SELECT Fields__c FROM AccountReLinkObject__c WHERE Name='Note' Limit 1];
		accReLinkNote.Fields__c='Id, Title, ParentId, Owner.Profile.Name, OwnerId, Owner.Id, Owner.IsActive, Owner.Name';
		update accReLinkNote;
        
        test.startTest();
        Account_ReLink__c testAccountReLink=generateAccountReLink(accountMap);
        insert testAccountReLink;
        
        DSCB_AccountReLink_Batch batch=new DSCB_AccountReLink_Batch();
        batch.conditions += ' And Id=\'' + testAccountReLink.Id + '\' ';
        
        Database.executeBatch(batch);
        test.stopTest();
    }
    
    private static testmethod void schedulerTest()
    {
    	test.startTest();
    	// Cron Expression Syntax: Seconds, Minutes, Hours, Day of month, Month, Day of week, optional Year
    	// 0 0 0 * * ? means, run every day at 12am
    	String jobId=System.schedule('TestReLinkScheduler', '0 0 0 * * ?', new DSCB_AccountReLink_Scheduler());
    	test.stopTest();
    }
}