@isTest
private class ISVC_CreateJiraIssue_Test {

    //Succesfull flow
    @IsTest(SeeAllData=true)
    static void testCreateJiraIssue() {
        ISVC_JiraProject_Builder jiraProjectBuilder = new ISVC_JiraProject_Builder();
        jiraProjectBuilder.name('Internal Service').key('ISVC').save();
        Jira_Project__c jiraProject = jiraProjectBuilder.getRecord();

        //Given: problem case
        Id problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        ISVC_Case_Builder problemCaseBuilder = new ISVC_Case_Builder();
        problemCaseBuilder.recordTypeId(problemRecordTypeId).subject('Problem Test Case').save();
        Case problemCase = problemCaseBuilder.getRecord();

        PageReference pageRef = Page.ISVC_CreateJiraIssue;
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new ISVC_JiraIssueResponse_Mock());

        //When: select project and create JIRA Issue
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(problemCase);
        ISVC_CreateJiraIssue_Extension controller = new ISVC_CreateJiraIssue_Extension(stdController);
        controller.getJiraProjects();
        controller.jiraProjectKey = jiraProject.Key__c;
        controller.createJiraIssue();
        Test.stopTest();

        //Then: JIRA Issue and Case JIRA Relation are created
        List<CaseJiraRelation__c> caseJiraRelations = [SELECT Issue__c FROM CaseJiraRelation__c WHERE Case__c = :problemCase.Id];
        System.assertEquals(1, caseJiraRelations.size());
        List<Jira_Issue__c> jiraIssues = [SELECT Summary__c FROM Jira_Issue__c WHERE Id = :caseJiraRelations[0].Issue__c];
        System.assertEquals(1, jiraIssues.size());
        System.assertEquals(problemCase.Subject, jiraIssues[0].Summary__c);
    }

    //Error flow
    static testMethod void testCreateJiraIssueError() {
        //Given: problem case
        Id problemRecordTypeId = ALL_RecordTypes_Utility.getProblemRecordTypeId();
        ISVC_Case_Builder problemCaseBuilder = new ISVC_Case_Builder();
        problemCaseBuilder.recordTypeId(problemRecordTypeId).subject('Problem Test Case').save();
        Case problemCase = problemCaseBuilder.getRecord();

        PageReference pageRef = Page.ISVC_CreateJiraIssue;
        Test.setCurrentPage(pageRef);
        Test.setMock(HttpCalloutMock.class, new ISVC_JiraIssueResponse_Mock());

        //When: try to create JIRA Issue without project
        Test.startTest();
        ApexPages.StandardController stdController = new ApexPages.StandardController(problemCase);
        ISVC_CreateJiraIssue_Extension controller = new ISVC_CreateJiraIssue_Extension(stdController);
        controller.jiraProjectKey = '';
        controller.createJiraIssue();
        Test.stopTest();

        //Then: Error message is displayed
        for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
            System.assertEquals(System.Label.ISVC_JiraProjectIsRequiredField, msg.getSummary());
        }
    }
}