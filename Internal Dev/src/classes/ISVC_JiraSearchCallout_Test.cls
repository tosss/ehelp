@isTest
private class ISVC_JiraSearchCallout_Test {

    static testMethod void testCreateJiraIssue() {
        Test.setMock(HttpCalloutMock.class, new ISVC_SearchJiraIssuesResponse_Mock());

        //Given: Search JIRA Issues Request details
        ISVC_SearchJiraIssuesRequest searchJiraIssuesReq = new ISVC_SearchJiraIssuesRequest('TP', 0, 10);

        //When: send request to search for JIRA Issues
        ISVC_SearchJiraIssuesResponse searchJiraIssuesRes = ISVC_JiraSearchCallout.searchForJiraIssues(searchJiraIssuesReq);

        //Then: response is successfull
        System.assertEquals(true, searchJiraIssuesRes.success);
    }
}