@isTest
private class ISVC_JiraIssueCallout_Test {

    static testMethod void testCreateJiraIssue() {
        Test.setMock(HttpCalloutMock.class, new ISVC_JiraIssueResponse_Mock());

        //Given: JIRA Issue Request details
        ISVC_JiraIssueRequest jiraIssueReq = new ISVC_JiraIssueRequest('GLOBIT', 'Test JIRA Issue', '', 'Bug');

        //When: send request to create JIRA Issue
        ISVC_JiraIssueResponse jiraIssueRes = ISVC_JiraIssueCallout.createJiraIssue(jiraIssueReq);

        //Then: response is successfull
        System.assertEquals(true, jiraIssueRes.success);
    }
}