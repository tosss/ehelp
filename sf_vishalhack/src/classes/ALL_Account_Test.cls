//2016-10-10 - ragashalini.koka@cdk.com - RQ-07962 - added code to improve code coverage
//2016-12-14 - lalitha.adduru@cdk.com - RQ-08111 
//2017-02-28 - ragashalini.koka@cdk.com - RQ-08685 - added the testmethod validateInactiveCROfDuplicateAccounts
@isTest
public class ALL_Account_Test 
{
   @testSetUp
    private static void setUp()
    {
        List<Trigger_Toggle__c> ToggleList = new List<Trigger_Toggle__c>();
        
        ToggleList.add(new Trigger_Toggle__c(
            Name='ALL_Account', 
            sObject__c='Account', 
            Code_Reference__c='CDK_Default_Team',
            RecordType_Name__c = 'CDK OEM/Brand',
            On__c=true));
        
        ToggleList.add(new Trigger_Toggle__c(
            Name='ALL Account', 
            sObject__c='Account', 
            Code_Reference__c='CDK_Default_Team',
            RecordType_Name__c=null,
            On__c=false));
        
        ToggleList.add(new Trigger_Toggle__c(
            Name='ALL ADPDefaultTeamMembers', 
            sObject__c='ADP_Default_Team_Members__c', 
            Code_Reference__c='New OEM Sales Team Member',
            RecordType_Name__c = 'OEM Sales',
            On__c=true));
        
        ToggleList.add(new Trigger_Toggle__c(
            Name='ALL_ADPDefaultTeamMembers', 
            sObject__c='ADP_Default_Team_Members__c', 
            Code_Reference__c='New OEM Sales Team Member',
            On__c=false));
        
        insert toggleList;
        
        List<ADP_Default_Team__c> teamsToBeInserted = new List<ADP_Default_Team__c>();
        ADP_Default_Team__c defaultTeam = new ADP_Default_Team__c();
        Id teamRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('ADP_Default_Team__c', 'OEM Sales');
        defaultTeam.RecordTypeId = teamRecordTypeId;
        defaultTeam.Name = 'Test Team';
        teamsToBeInserted.add(defaultTeam);
        
        ADP_Default_Team__c defaultTeamOne = new ADP_Default_Team__c();
        defaultTeamOne.RecordTypeId = teamRecordTypeId;
        defaultTeamOne.Name = 'Test Team One';
        teamsToBeInserted.add(defaultTeamOne);
        
        insert teamsToBeInserted;
        
        User newUser = DS_TestObjects.NewUser_Inserted();
        
        List<ADP_Default_Team_Members__c> members = new List<ADP_Default_Team_Members__c>();
        ADP_Default_Team_Members__c teamMember = new ADP_Default_Team_Members__c();
        teamMember.Team_Role__c = 'OEM Sales';
        teamMember.ADP_Default_Team__c = defaultTeam.Id;
        teamMember.Team_Member__c = UserInfo.getUserId();
        teamMember.Account_Access__c = 'Read Only';
        teamMember.Opportunity_Access__c = 'Read Only';
        members.add(teamMember);
        
        ADP_Default_Team_Members__c teamMemberOne = new ADP_Default_Team_Members__c();
        teamMemberOne.Team_Role__c = 'OEM Sales';
        teamMemberOne.ADP_Default_Team__c = defaultTeam.Id;
        teamMemberOne.Team_Member__c = newUser.Id;
        teamMemberOne.Account_Access__c = 'Read Only';
        teamMemberOne.Opportunity_Access__c = 'Read Only';
        members.add(teamMemberOne);
        
        ADP_Default_Team_Members__c teamMemberTwo = new ADP_Default_Team_Members__c();
        teamMemberTwo.Team_Role__c = 'OEM Sales';
        teamMemberTwo.ADP_Default_Team__c = defaultTeamOne.Id;
        teamMemberTwo.Team_Member__c = UserInfo.getUserId();
        teamMemberTwo.Account_Access__c = 'Full Access';
        teamMemberTwo.Opportunity_Access__c = 'Private';
        members.add(teamMemberTwo);
        
        insert members;
        Account testAccount = DS_TestObjects.NewAccount();
        testAccount.RecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Account', 'CDK OEM/Brand');
        testAccount.CDK_Default_Team__c = defaultTeamOne.Id;
        insert testAccount;
        testAccount.CDK_Default_Team__c = defaultTeam.Id;
        update testAccount;
        
        ADP_Default_Team_Members__c teamMemberThree = new ADP_Default_Team_Members__c();
        teamMemberThree.Team_Role__c = 'OEM Sales';
        teamMemberThree.ADP_Default_Team__c = defaultTeamOne.Id;
        teamMemberThree.Team_Member__c = DS_TestObjects.NewUser_Inserted().Id;
        teamMemberThree.Account_Access__c = 'Full Access';
        teamMemberThree.Opportunity_Access__c = 'Private';
        insert teamMemberThree;
        
        List<Account> accountsToBeInserted = new List<Account>();
        Account parentAccountOne = new Account(Name='ParentAccountOne', DS_LGL_Data_Rights_Opt_Out__c='Test');
        accountsToBeInserted.add(parentAccountOne);
        Account parentAccountTwo = new Account(Name='ParentAccountTwo', parentID = null, DS_LGL_Data_Rights_Opt_Out__c='Test');
        accountsToBeInserted.add(parentAccountTwo);
        insert accountsToBeInserted;
        accountsToBeInserted.clear();
        Account childAccountOne = new Account(Name = 'ChildAccountOne', parentID = parentAccountOne.ID, CBLTBillState__c = 'NC',DS_LGL_Data_Rights_Opt_Out__c = '9D;APAD for Menu');
        accountsToBeInserted.add(childAccountOne);
        Account childAccountTwo = new Account(Name = 'ChildAccountTwo', parentID = parentAccountOne.ID, CBLTBillState__c = 'CA', BillingState = 'CA');
        accountsToBeInserted.add(childAccountTwo);
        
        Account childAccountThree = new Account(Name='childAccountThree', parentID = childAccountTwo.ID, BillingState = 'CA', DS_LGL_Data_Rights_Opt_Out__c='CA;SF');
        accountsToBeInserted.add(childAccountThree);
        Account childAccountFour = new Account(Name = 'childAccountFour', parentID = childAccountTwo.ID );
        accountsToBeInserted.add(childAccountFour);        
        insert accountsToBeInserted;
        
        Contact newContact1 = DS_TestObjects.NewContact();
        newContact1.AccountId = parentAccounttwo.Id;
        ALL_SharedContact_Helper.insertContact(newContact1, null, null, null);
        Contact newContact2 = DS_TestObjects.NewContact();
        ALL_SharedContact_Helper.insertContact(newContact2, null, null, null);
        List<Contact_Relationship__c> crList = new List<Contact_Relationship__c>();
        Contact_Relationship__c newCR1 = new Contact_Relationship__c(Account__c = childAccountThree.Id, Contact__c = newContact1.Id);
        crList.add(newCR1);
        Contact_Relationship__c newCR2 = new Contact_Relationship__c(Account__c = childAccountFour.Id, Contact__c = newContact1.Id);
        crList.add(newCR2);
        Contact_Relationship__c newCR3 = new Contact_Relationship__c(Account__c = childAccountFour.Id, Contact__c = newContact2.Id);
        crList.add(newCR3);
        insert crList; 
        
        List<Account__c> dataRightsCustomSettingList = new List<Account__c>();
        Account__c dataRightsCustomSettingOne = new Account__c(Name = '00', Data_Rights_Name__c = '9D', Data_Rights_State_to_Skip__c = 'NC');
        dataRightsCustomSettingList.add(dataRightsCustomSettingOne);
        Account__c dataRightsCustomSettingTwo = new Account__c(Name = '01', Data_Rights_Name__c = '9D', Data_Rights_State_to_Skip__c = 'CA');
        dataRightsCustomSettingList.add(dataRightsCustomSettingTwo);
        insert dataRightsCustomSettingList;
    }

    private static testmethod void testPropagateDataRights()
    {
        Map<ID, Account> accountMap = new Map<ID,Account>([ SELECT ID, DS_LGL_Data_Rights_Opt_Out__c, Name, ParentID FROM Account]);
        
        Map<ID, Account> clonedAccountMap = new Map<ID,Account>();

        for(Account acc : accountMap.values())
        {
            Account tempAccount = acc.clone();
            tempAccount.ID = null;    		
            clonedAccountMap.put(acc.ID, tempAccount);
        }
        
        accountMap.values()[0].DS_LGL_Data_Rights_Opt_Out__c = '9D;APAD for Menu';
        accountMap.values()[1].DS_LGL_Data_Rights_Opt_Out__c = '9D';
        ALL_Account_Handler.propagateDataRights(accountMap.values(), null);
        ALL_Account_Handler.propagateDataRights(accountMap.values(), clonedAccountMap);        
    }
    
    private static testmethod void testHandleContactRelationshipsOfDuplicateAccounts() {
        Account originalAcc = [SELECT Id FROM Account WHERE Name LIKE '%childAccountThree%'];
        Account duplicateAcc = [SELECT Id FROM Account WHERE Name LIKE '%childAccountFour%'];
       
        test.startTest();
        Database.merge(originalAcc, duplicateAcc.Id);
        Integer countOfCRsAfterMerge = Database.countQuery('SELECT Count() FROM Contact_Relationship__c WHERE Account__c=\'' + originalAcc.Id + '\'');
        System.assertEquals(2, countOfCRsAfterMerge);
        test.stopTest();
    }
    
    private static testmethod void testUpdateContactDealerGroup() {
        Account acc1 = [SELECT Id, Name, ParentId FROM Account WHERE Name LIKE '%ChildAccountOne%'];
        Account acc2 = [SELECT Id, Name FROM Account WHERE Name LIKE '%childAccountThree%'];
        Contact ctct1 = DS_TestObjects.NewContact();
        ctct1.AccountId = acc2.Id;
        ALL_SharedContact_Helper.insertContact(ctct1, null, null, null);
        acc2.ParentId = acc1.ParentId;
        update acc2;
    }
    
      //2017-02-28  ragashalini.koka@cdk.com - Added the method to validate CRs of duplicate Accounts for RQ-08685
    private static testmethod void testInactivateCROfDuplicateAccounts() {
        Test.startTest();
        Account acc = [SELECT Id FROM Account WHERE Id IN (SELECT Account__c FROM Contact_Relationship__c WHERE Status__c = 'Active') LIMIT 1];
        acc.Duplicate__c = true;
        update acc;
        Test.stopTest();
        List<Contact_Relationship__c> crList = [SELECT Id, Status__c FROM Contact_Relationship__c WHERE Account__c = : acc.Id AND Status__c = 'Active'];
        System.assertEquals(0, crList.size());
    }
}