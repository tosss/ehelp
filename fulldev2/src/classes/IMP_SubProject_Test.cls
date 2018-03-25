//2016-02-25- anirudh.singh@cdk.com- Created this test class for the Handler class IMP_SubProject_Handler as per Request RQ-06018.
@isTest
public class IMP_SubProject_Test
{
    @TestSetup
    private static void setupData()
    {
        Account accountRecord=IMP_TestFactory_Helper.buildAccount();   
        insert accountRecord;
        
        Opportunity opportunityRecord=IMP_TestFactory_Helper.buildOpportunity();
        opportunityRecord.AccountId=accountRecord.Id;
        insert opportunityRecord; 
        
        List<Opportunity_Quotes__c> oppQuotesList=new List<Opportunity_Quotes__c>();
        Opportunity_Quotes__c opportunityQuoteRecordOne=IMP_TestFactory_Helper.buildOpportunityQuotes(accountRecord.Id, opportunityRecord.Id);
        opportunityQuoteRecordOne.Deal_Id__c='12345';
        oppQuotesList.add(opportunityQuoteRecordOne);
        
        Opportunity_Quotes__c opportunityQuoteRecordTwo=IMP_TestFactory_Helper.buildOpportunityQuotes(accountRecord.Id, opportunityRecord.Id);
        opportunityQuoteRecordTwo.Deal_Id__c='35462';
        oppQuotesList.add(opportunityQuoteRecordTwo);
        insert oppQuotesList;
        
        List<Deal_State__c> dealStateList=new List<Deal_State__c>();
        Deal_State__c dealStateRecordOne=new Deal_State__c();
        dealStateRecordOne.SQT_Deal_Id__c='35462';
        dealStateRecordOne.Opportunity__c=opportunityRecord.Id;
        dealStateRecordOne.CA_Approved_Date__c=datetime.now();
        dealStateList.add(dealStateRecordOne);
        
        Deal_State__c dealStateRecordTwo=new Deal_State__c();
        dealStateRecordTwo.SQT_Deal_Id__c='12345';
        dealStateRecordTwo.Opportunity__c=opportunityRecord.Id;
        dealStateRecordTwo.CA_Approved_Date__c=datetime.now()+2;
        dealStateList.add(dealStateRecordTwo);
        insert dealStateList;
        
        Project__c projectRecord=IMP_TestFactory_Helper.buildProject(0);
        insert projectRecord;
        
        SubProject__c subProjectRecord=IMP_TestFactory_Helper.buildSubProject(projectRecord.Id);
        subProjectRecord.Confidential__c=true;
        subProjectRecord.Deal_Id__c='12345;35462';
        subProjectRecord.Contract_Roll_Called__c=date.newinstance(2016, 03, 14);
        insert subProjectRecord;
        
        Project_Milestone__c milestoneRecord=IMP_TestFactory_Helper.buildMilestoneNonStandard(subProjectRecord.Id, 'Test Description');
        insert milestoneRecord;
        
        List<Project_Log__c> projectLogsList=new List<Project_Log__c>();
        Project_Log__c issue=IMP_TestFactory_Helper.buildIssueLog(projectRecord.Id, subProjectRecord.Id);
        issue.SubProject_Confidential__c=true;
        projectLogsList.add(issue);
        
        Project_Log__c risk=IMP_TestFactory_Helper.buildRiskLog(projectRecord.Id, subProjectRecord.Id);
        risk.SubProject_Confidential__c=true;
        projectLogsList.add(risk);
        
        Project_Log__c action=IMP_TestFactory_Helper.buildActionItemLog(projectRecord.Id, subProjectRecord.Id);
        action.SubProject_Confidential__c=true;
        projectLogsList.add(action);
        
        Project_Log__c change=IMP_TestFactory_Helper.buildChangeRequestLog(projectRecord.Id, subProjectRecord.Id);
        change.SubProject_Confidential__c=true;
        projectLogsList.add(change);
        
        Project_Log__c lesson=IMP_TestFactory_Helper.buildLessonLearnedLog(projectRecord.Id, subProjectRecord.Id);
        lesson.SubProject_Confidential__c=true;
        projectLogsList.add(lesson);
        insert projectLogsList;
    }
    
    private static testMethod void processSubProjectsBeforeUpdateTest()
    {
        SubProject__c subProjectRecord=[
            SELECT Id, Project_Manager__c, SubProject_Status__c, Confidential__c, 
            Training_Implementation_Client_Mgr__c, Project__c
            FROM SubProject__c
        ];
        
        List<Project_Log__c> projectLogsList=[
            SELECT SubProject_Confidential__c 
            FROM Project_Log__c 
            ORDER BY Lookup_Field_API_Name_to_Subproject__c
        ];
        
        test.startTest();
        Map<Id, SubProject__c> oldSubProjectsMap=new Map<Id, SubProject__c>();
        oldSubProjectsMap.put(subProjectRecord.Id, subProjectRecord);
        
        //Creating a new Project.
        Project__c projectRecordNew=IMP_TestFactory_Helper.buildProject(0);
        projectRecordNew.Project_Status__c='Closed';
        insert projectRecordNew;
        
        SubProject__c newSubProjectRecord=new SubProject__c();
        newSubProjectRecord=subProjectRecord.clone(true);
        newSubProjectRecord.Project_Manager__c=UserInfo.getUserId();
        newSubProjectRecord.SubProject_Status__c='Closed';
        newSubProjectRecord.Confidential__c=false;
        newSubProjectRecord.Project__c=projectRecordNew.Id;
        
        Map<Id, SubProject__c> newSubProjectsMap=new Map<Id, SubProject__c>();
        newSubProjectsMap.put(newSubProjectRecord.Id, newSubProjectRecord);
        
        IMP_SubProject_Handler.processSubProjectsBeforeUpdate(newSubProjectsMap, oldSubProjectsMap);
        
        List<Project_Log__c> updatedProjectLogsList=[
            SELECT SubProject_Confidential__c 
            FROM Project_Log__c 
            ORDER BY Lookup_Field_API_Name_to_Subproject__c
        ];
        
        system.assertEquals(false, updatedProjectLogsList[0].SubProject_Confidential__c, 'SubProject_Confidential__c field value updated on Action Item');
        system.assertNotEquals(projectLogsList[0].SubProject_Confidential__c, updatedProjectLogsList[0].SubProject_Confidential__c, 'Action Item Updated');
        
        system.assertEquals(false, updatedProjectLogsList[1].SubProject_Confidential__c, 'SubProject_Confidential__c field value updated on Change Request');
        system.assertNotEquals(projectLogsList[1].SubProject_Confidential__c, updatedProjectLogsList[1].SubProject_Confidential__c, 'Change Request Updated');
        
        system.assertEquals(false, updatedProjectLogsList[2].SubProject_Confidential__c, 'SubProject_Confidential__c field value updated on Issue');
        system.assertNotEquals(projectLogsList[2].SubProject_Confidential__c, updatedProjectLogsList[2].SubProject_Confidential__c, 'Issue Updated');
        
        system.assertEquals(false, updatedProjectLogsList[3].SubProject_Confidential__c, 'SubProject_Confidential__c field value updated on Lessons Learned');
        system.assertNotEquals(projectLogsList[3].SubProject_Confidential__c, updatedProjectLogsList[3].SubProject_Confidential__c, 'Lessons Learned Updated');
        
        system.assertEquals(false, updatedProjectLogsList[4].SubProject_Confidential__c, 'SubProject_Confidential__c field value updated on Risk');
        system.assertNotEquals(projectLogsList[4].SubProject_Confidential__c, updatedProjectLogsList[4].SubProject_Confidential__c, 'Risk Updated');
        test.stopTest();
    }
    
    private static testMethod void processSubProjectsAfterInsertTestOne()
    {
        SubProject__c subProjectRecord=[
            SELECT Id, Project_Manager__c, SubProject_Status__c, Confidential__c, 
            Training_Implementation_Client_Mgr__c, Project__c, Deal_Id__c, Contract_Roll_Called__c
            FROM SubProject__c
        ];
		
        List<Deal_State__c> dealStateList=[SELECT Id, Roll_Call_Date__c FROM Deal_State__c];
        
        List<SubProject__c> newSubProjectsList=new List<SubProject__c>();
        newSubProjectsList.add(subProjectRecord);
        
        test.startTest();
        IMP_SubProject_Handler.processSubProjectsAfterInsert(newSubProjectsList, Null);
        
        List<Deal_State__c> updatedDealStateList=[SELECT Id, Roll_Call_Date__c FROM Deal_State__c];
        system.assertEquals(dealStateList[0].Roll_Call_Date__c, updatedDealStateList[0].Roll_Call_Date__c, 'Roll Call Date Not Updated.');
        test.stopTest();
    }
    
    private static testMethod void processSubProjectsAfterInsertTestTwo()
    {
        SubProject__c subProjectRecord=[
            SELECT Id, Project_Manager__c, SubProject_Status__c, Confidential__c, 
            Training_Implementation_Client_Mgr__c, Project__c, Deal_Id__c, Contract_Roll_Called__c
            FROM SubProject__c
        ];
        
        List<Deal_State__c> dealStateList=[SELECT Id, Roll_Call_Date__c, SQT_Deal_Id__c FROM Deal_State__c];
        
        List<SubProject__c> subProjectsList=new List<SubProject__c>();
        subProjectsList.add(subProjectRecord);
        
        test.startTest();
        IMP_SubProject_Handler.processSubProjectsAfterInsert(subProjectsList, Null);
        
        SubProject__c newSubProjectRecord=new SubProject__c();
        newSubProjectRecord=subProjectRecord.clone(true);
        newSubProjectRecord.Deal_Id__c='12345';
        newSubProjectRecord.Contract_Roll_Called__c=date.newinstance(2016, 03, 16);
        
        List<SubProject__c> newSubProjectsList=new List<SubProject__c>();
        newSubProjectsList.add(newSubProjectRecord);
        
        IMP_SubProject_Handler.processSubProjectsAfterInsert(newSubProjectsList, Null);
        
        List<Deal_State__c> updatedDealStateList=[SELECT Id, Roll_Call_Date__c, SQT_Deal_Id__c FROM Deal_State__c];
        system.assertEquals(dealStateList[0].SQT_Deal_Id__c, updatedDealStateList[0].SQT_Deal_Id__c);
        system.assertNotEquals(dealStateList[0].Roll_Call_Date__c, updatedDealStateList[0].Roll_Call_Date__c, 'Roll Call Date Updated.');
        system.assertEquals(date.newinstance(2016, 03, 16), updatedDealStateList[0].Roll_Call_Date__c, 'Roll Call Date Updated.');
        test.stopTest();
    }
    
    private static testMethod void processSubProjectsAfterUpdateTest()
    {
        SubProject__c subProjectRecord=[
            SELECT Id, Project_Manager__c, SubProject_Status__c, Confidential__c, 
            Training_Implementation_Client_Mgr__c, Project__c, Deal_Id__c, Contract_Roll_Called__c
            FROM SubProject__c
        ];
        
        List<Deal_State__c> dealStateList=[SELECT Id, Roll_Call_Date__c, SQT_Deal_Id__c FROM Deal_State__c];
        
        test.startTest();
        Map<Id, SubProject__c> oldSubProjectsMap=new Map<Id, SubProject__c>();
        oldSubProjectsMap.put(subProjectRecord.Id, subProjectRecord);
        
        SubProject__c newSubProjectRecord=new SubProject__c();
        newSubProjectRecord=subProjectRecord.clone(true);
        newSubProjectRecord.Project_Manager__c=UserInfo.getUserId();
        newSubProjectRecord.Contract_Roll_Called__c=date.newinstance(2016, 03, 16);
        
        Map<Id, SubProject__c> newSubProjectsMap=new Map<Id, SubProject__c>();
        newSubProjectsMap.put(newSubProjectRecord.Id, newSubProjectRecord);
        
        IMP_SubProject_Handler.processSubProjectsAfterUpdate(newSubProjectsMap, oldSubProjectsMap);
        
        List<Deal_State__c> updatedDealStateList=[SELECT Id, Roll_Call_Date__c, SQT_Deal_Id__c FROM Deal_State__c];
        system.assertEquals(dealStateList[0].SQT_Deal_Id__c, updatedDealStateList[0].SQT_Deal_Id__c);
        system.assertNotEquals(dealStateList[0].Roll_Call_Date__c, updatedDealStateList[0].Roll_Call_Date__c, 'Roll Call Date Updated.');
        system.assertEquals(date.newinstance(2016, 03, 16), updatedDealStateList[0].Roll_Call_Date__c, 'Roll Call Date Updated.');
        
        system.assertEquals(dealStateList[1].SQT_Deal_Id__c, updatedDealStateList[1].SQT_Deal_Id__c);
        system.assertNotEquals(dealStateList[1].Roll_Call_Date__c, updatedDealStateList[1].Roll_Call_Date__c, 'Roll Call Date Updated.');
        system.assertEquals(date.newinstance(2016, 03, 16), updatedDealStateList[1].Roll_Call_Date__c, 'Roll Call Date Updated.');
        
        Project__c projectRecordNew=IMP_TestFactory_Helper.buildProject(0);
        insert projectRecordNew;
        
        SubProject__c updatedSubProjectRecord=new SubProject__c();
        updatedSubProjectRecord=subProjectRecord.clone(true);
        updatedSubProjectRecord.Deal_Id__c='12345';
        updatedSubProjectRecord.Contract_Roll_Called__c=date.newinstance(2016, 03, 18);
        updatedSubProjectRecord.Project__c=projectRecordNew.Id;
        
        Map<Id, SubProject__c> updatedSubProjectsMap=new Map<Id, SubProject__c>();
        updatedSubProjectsMap.put(updatedSubProjectRecord.Id, updatedSubProjectRecord);
        
        IMP_SubProject_Handler.processSubProjectsAfterUpdate(updatedSubProjectsMap, oldSubProjectsMap);
        
        List<Deal_State__c> updatedDealStateListTwo=[SELECT Id, Roll_Call_Date__c, SQT_Deal_Id__c FROM Deal_State__c];
        system.assertEquals(dealStateList[0].SQT_Deal_Id__c, updatedDealStateListTwo[0].SQT_Deal_Id__c);
        system.assertNotEquals(dealStateList[0].Roll_Call_Date__c, updatedDealStateListTwo[0].Roll_Call_Date__c, 'Roll Call Date Updated.');
        system.assertEquals(date.newinstance(2016, 03, 18), updatedDealStateListTwo[0].Roll_Call_Date__c, 'Roll Call Date Updated.');
        test.stopTest();
    }
}