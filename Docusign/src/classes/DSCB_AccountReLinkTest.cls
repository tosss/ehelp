public class DSCB_AccountReLinkTest
{
    // -- TEST TRIGGER
    public static testmethod void TestTrigger()
    {
        ClearAccountReLinkSettings();
        
        // generate Accounts
        Map<String,Account> TestAccounts = GenerateTestAccounts();
        
        // generate ReLinks
        Account_ReLink__c TestAccountReLink = new Account_ReLink__c();
        TestAccountReLink.Cobalt_Account_Number__c = TestAccounts.get('Source').Account_Number__c;
        TestAccountReLink.Party_ID__c = TestAccounts.get('Destination').PartyID__c;
        
        // Test ReLink Insert Trigger
        system.debug(TestAccountRelink);
        insert TestAccountRelink;
        
        try { insert new Account_ReLink__c(Party_ID__c='INVALID'); } catch(Exception ex) {}
        try { insert new Account_ReLink__c(Cobalt_Account_Number__c='INVALID'); } catch(Exception ex) {}
        
        // Test ReLink Update Trigger
        TestAccountReLink.Cobalt_Account_Number__c = TestAccounts.get('Destination').Account_Number__c;
        TestAccountReLink.Party_ID__c = TestAccounts.get('Source').PartyID__c;
        update TestAccountRelink;
    }
    
    // -- TEST REMOTE ACTIONS
    public static testmethod void TestRemoteActions()
    {
        ClearAccountReLinkSettings();
        AccountReLinkObject__c rlContact = SetupContactTestSetting();
        
        Account_ReLink__c TestAccountRelink = GenerateTestReLink();
        Id BatchId = DSCB_AccountReLink.SubmitReLink(TestAccountReLink.Id);
        DSCB_AccountReLink.CheckReLinkStatus(BatchId);
    }
    
    // -- TEST QUERY GENERATORS
    public static testmethod void TestQueryGenerators()
    {
        ClearAccountReLinkSettings();
        
        Set<Id> AccountIds = new Set<Id>();
        Map<String,Account> TestAccounts = GenerateTestAccounts();
        for(Account a : TestAccounts.values()) { AccountIds.add(a.Id); }
        
        List<DSCB_AccountReLink.SourceAccount> SourceAccounts = DSCB_AccountReLink.QuerySourceAccounts(AccountIds);
        List<Account> DestinationAccounts = DSCB_AccountReLink.QueryDestinationAccounts(AccountIds);
    }
    
    // -- TEST PROCESS RELINKS
    public static testmethod void TestProcessReLinks()
    {
        ClearAccountReLinkSettings();
        AccountReLinkObject__c rlContact = SetupContactTestSetting();
        
        Id TestReLinkId = GenerateTestReLink().Id;
        
        Account_ReLink__c TestAccountReLink = [
            Select Id, Name, Party_ID__c, Cobalt_Account_Number__c, Cobalt_Account__c, Party_Account__c, CreatedDate 
            From Account_ReLink__c Where Id = :TestReLinkId Limit 1];
        
        system.debug(TestAccountReLink);
        
        DSCB_AccountReLink.ProcessRelinks(new List<Account_ReLink__c>{TestAccountReLink});
    }
    
    // -- TEST GET FIELD LIST
    public static testmethod void TestGetSobjectFieldList()
    {
        String ContactFields = DSCB_AccountReLink.GetSobjectFieldList('Contact');
    }
    
    // -- TEST QUERY AND UPDATE (CONTACT)
    public static testmethod void TestContactQueryAndUpdate()
    {
        ClearAccountReLinkSettings();
        AccountReLinkObject__c rlContact = SetupContactTestSetting();
        
        Id TestReLinkId = GenerateTestReLink().Id;
        
        Account_ReLink__c TestAccountReLink = [
            Select Id, Name, Party_ID__c, Cobalt_Account_Number__c, Cobalt_Account__c, Party_Account__c 
            From Account_ReLink__c Where Id = :TestReLinkId Limit 1];
        
        Set<Id> ContactIds = new Set<Id>();
        List<Contact> TestAccountContacts = [Select Id From Contact Where AccountId = :TestAccountReLink.Cobalt_Account__c];
        for(Contact c : TestAccountContacts) { ContactIds.add(c.Id); }
        
        DSCB_AccountReLink.QueryAndUpdate(ContactIds, new Map<Id,Id>(), rlContact.Object_API_Name__c, rlContact.Fields__c, 
            rlContact.Account_Field__c, TestAccountReLink.Party_Account__c);
    }
    
    // -- TEST QUERY AND CLONE (NOTE)
    public static testmethod void TestNoteQueryAndClone()
    {
        ClearAccountReLinkSettings();
        
        AccountReLinkObject__c rlNote = SetupNoteTestSetting();
        Id TestReLinkId = GenerateTestReLink().Id;
        
        Account_ReLink__c TestAccountReLink = [
            Select Id, Name, Party_ID__c, Cobalt_Account_Number__c, Cobalt_Account__c, Party_Account__c 
            From Account_ReLink__c Where Id = :TestReLinkId Limit 1];
        
        Set<Id> NoteIds = new Set<Id>();
        List<Note> TestAccountNotes = [Select Id From Note Where ParentId = :TestAccountReLink.Cobalt_Account__c];
        for(Note n : TestAccountNotes) { NoteIds.add(n.Id); }
        
        DSCB_AccountReLink.QueryAndClone(NoteIds, new Map<Id,Id>(), rlNote.Object_API_Name__c, rlNote.Fields__c, 
            rlNote.Account_Field__c, TestAccountReLink.Party_Account__c);
    }
    
    // -- TEST RELINK BATCH PROCESS
    public static testmethod void TestBatch()
    {
        ClearAccountReLinkSettings();
        List<AccountReLinkObject__c> rlObjects = SetupContactAndNoteTestSettings();
        
        Id TestReLinkId = GenerateTestReLink().Id;
        
        DSCB_AccountReLinkBatch batch = new DSCB_AccountReLinkBatch();
        batch.conditions += ' And Id = \'' + TestReLinkId + '\' ';
        
        Account_ReLink__c TestAccountReLink = Database.query(batch.st());
        batch.ex(new List<Account_ReLink__c>{TestAccountReLink});
        
        batch.fn(null);
    }
    
    // -- TEST RELINK SCHEDULER
    public static testmethod void TestScheduler()
    {
    	Test.startTest();
    	
    	// Cron Expression Syntax: Seconds, Minutes, Hours, Day of month, Month, Day of week, optional Year
    	// 0 0 0 * * ? means, run every day at 12am
    	String jobId = System.schedule('TestReLinkScheduler', '0 0 0 * * ?', new DSCB_AccountReLink_Scheduler());
    	
    	Test.stopTest();
    }
    
    // -- GENERATE RELINK
    public static testmethod Account_ReLink__c GenerateTestReLink()
    {
        Map<String,Account> TestAccounts = GenerateTestAccounts();
        
        Account_ReLink__c TestAccountReLink = new Account_ReLink__c();
        TestAccountReLink.Cobalt_Account_Number__c = TestAccounts.get('Source').Account_Number__c;
        TestAccountReLink.Party_ID__c = TestAccounts.get('Destination').PartyID__c;
        
        insert TestAccountReLink;
        return TestAccountReLink;
    }
    
    // -- GENERATE TEST ACCOUNTS (CONTACTS AND NOTES)
    public static testmethod Map<String,Account> GenerateTestAccounts()
    {
        Map<String,Account> TestAccounts = new Map<String,Account>();
        
        Account TestSourceAccount = DS_TestObjects.NewAccount();
        TestSourceAccount.Name = 'Source Account 1';
        TestSourceAccount.PartyID__c = '0001'; // unnecessary
        TestSourceAccount.Account_Number__c = '10000';
        TestAccounts.put('Source',TestSourceAccount);
        
        Account TestDestinationAccount = DS_TestObjects.NewAccount();
        TestDestinationAccount.Name = 'Destination Account 1';
        TestDestinationAccount.PartyID__c = '0002';
        TestDestinationAccount.Account_Number__c = '20000'; // unnecessary
        TestAccounts.put('Destination',TestDestinationAccount);
        
        insert TestAccounts.values();
        
        Contact TestSourceContact = DS_TestObjects.NewContact();
        TestSourceContact.AccountID = TestSourceAccount.Id;
        TestSourceContact.Role__c = 'Test Role'; // 9/29
        insert TestSourceContact;
        
        Note TestSourceNote = new Note(ParentId = TestSourceAccount.Id);
        TestSourceNote.Title = 'Test Note 1';
        insert TestSourceNote;
        
        system.debug(TestAccounts);
        return TestAccounts;
    }
    
    // -- SETUP CUSTOM SETTINGS (CONTACT)
    public static testmethod AccountReLinkObject__c SetupContactTestSetting()
    {
        AccountReLinkObject__c rlContact = GenerateContactTestSetting();
        insert rlContact;
        return rlContact;
    }
    
    // -- GENERATE CUSTOM SETTINGS (CONTACT)
    public static testmethod AccountReLinkObject__c GenerateContactTestSetting()
    {
        AccountReLinkObject__c rlContact = new AccountReLinkObject__c();
        rlContact.Account_Field__c = 'AccountId';
        rlContact.Account_Relationship_Name__c = 'Contacts';
        rlContact.Action__c = 'Update';
        rlContact.Fields__c = 'Id, Name, AccountId, External_ID__c, CreatedDate, OwnerId, Owner.IsActive, Owner.Name';
        rlContact.Object_API_Name__c = 'Contact';
        rlContact.Name = 'Contact';
        rlContact.Order__c = 1;
        return rlContact;
    }
    
    // -- SETUP CUSTOM SETTINGS (NOTE)
    public static testmethod AccountReLinkObject__c SetupNoteTestSetting()
    {
        AccountReLinkObject__c rlNote = GenerateNoteTestSetting();
        insert rlNote;
        return rlNote;
    }
    
    // -- GENERATE CUSTOM SETTINGS (NOTE)
    public static testmethod AccountReLinkObject__c GenerateNoteTestSetting()
    {
        AccountReLinkObject__c rlNote = new AccountReLinkObject__c();
        rlNote.Account_Field__c = 'ParentId';
        rlNote.Account_Relationship_Name__c = 'Notes';
        rlNote.Action__c = 'Clone';
        rlNote.Fields__c = 'Id, Title, ParentId, Owner.Profile.Name, OwnerId, Owner.Id, Owner.IsActive, Owner.Name';
        rlNote.Object_API_Name__c = 'Note';
        rlNote.Name = 'Note';
        rlNote.Order__c = 2;
        return rlNote;
    }
    
    // -- SETUP CUSTOM SETTINGS (CONTACT AND NOTE)
    public static testmethod List<AccountReLinkObject__c> SetupContactAndNoteTestSettings()
    {
        List<AccountReLinkObject__c> rlObjects = new List<AccountReLinkObject__c>();
        
        AccountReLinkObject__c rlContact = GenerateContactTestSetting();
        AccountReLinkObject__c rlNote = GenerateNoteTestSetting();
        
        rlObjects.add(rlContact);
        rlObjects.add(rlNote);
        
        system.debug(rlObjects);
        
        insert rlObjects;
        
        List<AccountReLinkObject__c> rlObjects1 = AccountReLinkObject__c.getall().values();
        system.debug(rlObjects1);
        
        return rlObjects;
    }
    
    // -- CLEAR ALL EXISTING CUSTOM SETTINGS
    public static testmethod void ClearAccountReLinkSettings()
    {
        List<AccountReLinkObject__c> rlo = AccountReLinkObject__c.getall().values();
        delete rlo;
    }
}