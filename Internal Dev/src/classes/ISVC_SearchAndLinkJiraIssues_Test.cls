@isTest
private class ISVC_SearchAndLinkJiraIssues_Test {

    //Succesfull flow
    static testMethod void testSearchJiraIssues() {
        ISVC_JiraProject_Builder jiraProjectBuilder = new ISVC_JiraProject_Builder();
        jiraProjectBuilder.name('Test Project').key('TP').save();
        Jira_Project__c jiraProject = jiraProjectBuilder.getRecord();

        //Given: problem case
        Id problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        ISVC_Case_Builder problemCaseBuilder = new ISVC_Case_Builder();
        problemCaseBuilder.recordTypeId(problemRecordTypeId).subject('Problem Test Case').save();
        Case problemCase = problemCaseBuilder.getRecord();

        PageReference pageRef = Page.ISVC_SearchAndLinkJiraIssues;
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new ISVC_SearchJiraIssuesResponse_Mock());

        //When: select project
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(problemCase);
        ISVC_SearchAndLinkJiraIssues_Extension controller = new ISVC_SearchAndLinkJiraIssues_Extension(stdController);
        controller.getJiraProjects();
        controller.jiraProjectKey = jiraProject.Key__c;
        controller.searchJiraIssues();
        if(controller.getHasNextPage()){
            controller.nextPage();
        }
        if(controller.getHasPreviousPage()){
            controller.previousPage();
        }
        Test.stopTest();

        //Then: JIRA Issues are displayed in table
        System.assertEquals(3, controller.jiraIssues.size());
    }

    //Succesfull flow
    static testMethod void testSearchAndLinkJiraIssues() {
        ISVC_JiraProject_Builder jiraProjectBuilder = new ISVC_JiraProject_Builder();
        jiraProjectBuilder.name('Test Project').key('TP').save();
        Jira_Project__c jiraProject = jiraProjectBuilder.getRecord();

        //Given: problem case
        Id problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        ISVC_Case_Builder problemCaseBuilder = new ISVC_Case_Builder();
        problemCaseBuilder.recordTypeId(problemRecordTypeId).subject('Problem Test Case').save();
        Case problemCase = problemCaseBuilder.getRecord();

        PageReference pageRef = Page.ISVC_SearchAndLinkJiraIssues;
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new ISVC_SearchJiraIssuesResponse_Mock());

        //When: select project
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(problemCase);
        ISVC_SearchAndLinkJiraIssues_Extension controller = new ISVC_SearchAndLinkJiraIssues_Extension(stdController);
        controller.getJiraProjects();
        controller.jiraProjectKey = jiraProject.Key__c;
        controller.searchJiraIssues();
        for(ISVC_SearchAndLinkJiraIssues_Extension.JiraIssue jiraIssue : controller.jiraIssues){
            jiraIssue.selected = true;
        }
        controller.linkJiraIssues();
        Test.stopTest();

        //Then: JIRA Issues are created and related to case
        List<CaseJiraRelation__c> caseJiraRelations = [SELECT Issue__c FROM CaseJiraRelation__c WHERE Case__c = :problemCase.Id];
        System.assertEquals(3, caseJiraRelations.size());
        Set<Id> jiraIssueIds = new Set<Id>();
        for(CaseJiraRelation__c caseJiraRelation : caseJiraRelations){
            jiraIssueIds.add(caseJiraRelation.Issue__c);
        }
        List<Jira_Issue__c> jiraIssues = [SELECT Id, Key__c FROM Jira_Issue__c WHERE Id IN :jiraIssueIds];
        System.assertEquals(3, jiraIssues.size());
    }

    //Succesfull flow
    static testMethod void testSearchAndUnLinkJiraIssues() {
        ISVC_JiraProject_Builder jiraProjectBuilder = new ISVC_JiraProject_Builder();
        jiraProjectBuilder.name('Test Project').key('TP').save();
        Jira_Project__c jiraProject = jiraProjectBuilder.getRecord();

        //Given: problem case
        Id problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        ISVC_Case_Builder problemCaseBuilder = new ISVC_Case_Builder();
        problemCaseBuilder.recordTypeId(problemRecordTypeId).subject('Problem Test Case').save();
        Case problemCase = problemCaseBuilder.getRecord();

        List<Jira_Issue__c> jiraIssues = new List<Jira_Issue__c>();
        ISVC_JiraIssue_Builder jiraIssueBuilder1 = new ISVC_JiraIssue_Builder();
        ISVC_JiraIssue_Builder jiraIssueBuilder2 = new ISVC_JiraIssue_Builder();
        ISVC_JiraIssue_Builder jiraIssueBuilder3 = new ISVC_JiraIssue_Builder();
        jiraIssueBuilder1.key('TP-22').build();
        jiraIssueBuilder2.key('TP-23').build();
        jiraIssueBuilder3.key('TP-24').build();
        jiraIssues.add(jiraIssueBuilder1.getRecord());
        jiraIssues.add(jiraIssueBuilder2.getRecord());
        jiraIssues.add(jiraIssueBuilder3.getRecord());
        insert jiraIssues;

        List<CaseJiraRelation__c> caseJiraRelations = new List<CaseJiraRelation__c>();
        for(Jira_Issue__c jiraIssue : jiraIssues){
            CaseJiraRelation__c caseJiraRelation = new CaseJiraRelation__c();
            caseJiraRelation.Case__c = problemCase.Id;
            caseJiraRelation.Issue__c = jiraIssue.Id;
        }
        insert caseJiraRelations;

        PageReference pageRef = Page.ISVC_SearchAndLinkJiraIssues;
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new ISVC_SearchJiraIssuesResponse_Mock());

        //When: select project
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(problemCase);
        ISVC_SearchAndLinkJiraIssues_Extension controller = new ISVC_SearchAndLinkJiraIssues_Extension(stdController);
        controller.getJiraProjects();
        controller.jiraProjectKey = jiraProject.Key__c;
        controller.searchJiraIssues();
        for(ISVC_SearchAndLinkJiraIssues_Extension.JiraIssue jiraIssue : controller.jiraIssues){
            jiraIssue.selected = false;
        }
        controller.linkJiraIssues();
        Test.stopTest();

        //Then: JIRA Issues are created and related to case
        caseJiraRelations = [SELECT Issue__c FROM CaseJiraRelation__c WHERE Case__c = :problemCase.Id];
        System.assertEquals(0, caseJiraRelations.size());
    }
}