//2016-08-05- anirudh.singh@cdk.com- Modified this class and rewritten it as it was not covering any of the caseTriggers class.
@isTest
private class caseTriggersTest 
{
    @TestSetup
    private static void setupData()
    {
        List<User> testUsersList=new List<User>();
        for(Integer i=0; i<2; i++)
        {
            User testUser=DS_TestObjects.NewUser();
            testUser.FirstName='caseTriggersTestUser'+i;
            testUsersList.add(testUser);
        }
        insert testUsersList;
         
        Account accountRecord=DS_TestObjects.NewAccount_Inserted();
        
        Contact contactRecord=DS_TestObjects.NewContact();
        contactRecord.AccountId=accountRecord.Id;
        insert contactRecord;
        
        //2016-07-27 matt.keefe@cdk.com - added contact relationship for shared contacts (Case Lookup requires)
        Contact_Relationship__c contactRelationshipRecord=new Contact_Relationship__c(Contact__c=contactRecord.Id, Account__c=accountRecord.Id);
        contactRelationshipRecord.Role__c='Accountant';
        insert contactRelationshipRecord;
        
        //Insert 10 test parents.
        List<Case> parentCaseList=new List<Case>();
        for(Integer i=0; i<10; i++)
        {
            Case parentCase=new Case();
            parentCase.AccountId=accountRecord.Id;
            parentCase.ContactId=contactRecord.Id;
            parentCase.OwnerId=testUsersList[0].Id;
            parentCase.Subject='Test'+i;
            parentCase.Dealer_Group_Contact__c=contactRecord.Id;
            parentCaseList.add(parentCase);
        } 
        insert parentCaseList;
        
        //Insert 2 children for each parent.
        List<Case> childCasesList=new List<Case>();
        for(Case parentCase: parentCaseList)
        {
            for(Integer i=0; i<2; i++)
            {
                Case childCase=new Case();
                childCase.AccountId=accountRecord.Id;
                childCase.ContactId=contactRecord.Id;
                childCase.OwnerId=testUsersList[0].Id;
                childCase.Subject='Test'+i;
                childCase.Dealer_Group_Contact__c=contactRecord.Id;
                childCase.ParentId=parentCase.Id;
                childCasesList.add(childCase);
            }
        }
        insert childCasesList;
        
        //Default Case Team Member.
        CaseTeamRole caseTeamRoleRecord=new CaseTeamRole(Name='TEST Case Team Member', AccessLevel='Edit');
        system.runAs(DS_TestObjects.CurrentUser())
        {
            insert caseTeamRoleRecord;
        }
        
        GlobalSettings__c globalSettingRecord=new GlobalSettings__c();
        globalSettingRecord.DefaultCaseTeamMemberId__c=caseTeamRoleRecord.Id;
        insert globalSettingRecord;
    }
    
    private static testMethod void caseTriggerCasesTestOne()
    {
        List<Case> caselist=[SELECT Id, AccountId, ContactId, OwnerId, ParentId, Status FROM Case];
        
        Test.startTest();
        caseTriggers.CaseTriggerCases(caselist, Null, Null);
        Test.stopTest();
    }
    
    /*private static testMethod void caseTriggerCasesTestTwo()
    {
        List<Case> caselist=[SELECT Id, AccountId, ContactId, OwnerId, ParentId, Status FROM Case];
        Map<Id, Case> newMap=new Map<Id, Case>();
        newMap.putAll(caselist);
            
        Test.startTest();
        caseTriggers.CaseTriggerCases(caselist, newMap, Null);
        Test.stopTest();
    }
    
    private static testMethod void caseTriggerCasesTestThree()
    {
        List<Case> caselist=[SELECT Id, AccountId, ContactId, OwnerId, ParentId, Status FROM Case];
        Map<Id, Case> oldMap=new Map<Id, Case>();
        oldMap.putAll(caselist);
            
        Test.startTest();
        caseTriggers.CaseTriggerCases(caselist, Null, oldMap);
        Test.stopTest();
    }
    
    private static testMethod void caseTriggerCasesTestFour()
    {
        Case caseRecord=[SELECT Id, AccountId, ContactId, OwnerId, ParentId, Status FROM Case Limit 1];
        User testUser=[SELECT Id FROM User WHERE FirstName='caseTriggersTestUser1'];
        
        Map<Id, Case> oldMap=new Map<Id, Case>();
        oldMap.put(caseRecord.Id, caseRecord);
        
        Map<Id, Case> newMap=new Map<Id, Case>();
        Case modifiedCaseRecord=caseRecord.clone(true);
        newMap.put(modifiedCaseRecord.Id, modifiedCaseRecord);
        newMap.values()[0].OwnerId=testUser.Id;
        
        Test.startTest();
        caseTriggers.CaseTriggerCases(new List<Case>{caseRecord}, newMap, oldMap);
        Test.stopTest();
    }
    
    private static testMethod void caseUpdatesTestOne()
    {
        Test.startTest();
        caseTriggers.caseUpdates(new Map<Id, Case>(), Null);
        Test.stopTest();
    }
    
    private static testMethod void caseUpdatesTestTwo()
    {
        Test.startTest();
        caseTriggers.caseUpdates(new Map<Id, Case>(), new Map<Id, Case>());
        Test.stopTest();
    }
    
    private static testMethod void caseUpdatesTestThree()
    {
        List<Case> caselist=[SELECT Id, AccountId, ContactId, OwnerId, ParentId, Status FROM Case];
        Map<Id, Case> newMap=new Map<Id, Case>();
        newMap.putAll(caselist);
        
        Test.startTest();
        caseTriggers.caseUpdates(newMap, new Map<Id, Case>());
        Test.stopTest();
    }
    
    private static testMethod void caseUpdatesTestFour()
    {
        Case caseRecord=[SELECT Id, AccountId, ContactId, OwnerId, ParentId, Status FROM Case Limit 1];
        User testUser=[SELECT Id FROM User WHERE FirstName='caseTriggersTestUser1'];
        
        Map<Id, Case> oldMap=new Map<Id, Case>();
        oldMap.put(caseRecord.Id, caseRecord);
        
        Map<Id, Case> newMap=new Map<Id, Case>();
        Case modifiedCaseRecord=caseRecord.clone(true);
        newMap.put(modifiedCaseRecord.Id, modifiedCaseRecord);
        newMap.values()[0].OwnerId=testUser.Id;
        
        Test.startTest();
        caseTriggers.caseUpdates(newMap, oldMap);
        Test.stopTest();
    }*/
}