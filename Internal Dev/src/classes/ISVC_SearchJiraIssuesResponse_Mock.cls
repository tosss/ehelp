@isTest
global class ISVC_SearchJiraIssuesResponse_Mock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        ISVC_SearchJiraIssuesResponse searchJiraIssuesRes = new ISVC_SearchJiraIssuesResponse();
        searchJiraIssuesRes.startAt = 0;
        searchJiraIssuesRes.maxResults = 10;
        searchJiraIssuesRes.total = 100;

        ISVC_SearchJiraIssuesResponse.Issue issue1 = new ISVC_SearchJiraIssuesResponse.Issue();
        issue1.id = '10022';
        issue1.key = 'TP-22';
        issue1.self = 'https://cdksfdcpoc.atlassian.net/rest/api/2/issue/10022';
        issue1.fields = new ISVC_SearchJiraIssuesResponse.IssueFields();
        issue1.fields.summary = 'Test issue 1';
        issue1.fields.status = new ISVC_SearchJiraIssuesResponse.Status();
        issue1.fields.status.name = 'To Do';
        issue1.fields.issuetype = new ISVC_SearchJiraIssuesResponse.IssueType();
        issue1.fields.issuetype.name = 'Bug';

        ISVC_SearchJiraIssuesResponse.Issue issue2 = new ISVC_SearchJiraIssuesResponse.Issue();
        issue2.id = '10023';
        issue2.key = 'TP-23';
        issue2.self = 'https://cdksfdcpoc.atlassian.net/rest/api/2/issue/10023';
        issue2.fields = new ISVC_SearchJiraIssuesResponse.IssueFields();
        issue2.fields.summary = 'Test issue 2';
        issue2.fields.status = new ISVC_SearchJiraIssuesResponse.Status();
        issue2.fields.status.name = 'To Do';
        issue2.fields.issuetype = new ISVC_SearchJiraIssuesResponse.IssueType();
        issue2.fields.issuetype.name = 'Bug';

        ISVC_SearchJiraIssuesResponse.Issue issue3 = new ISVC_SearchJiraIssuesResponse.Issue();
        issue3.id = '10024';
        issue3.key = 'TP-24';
        issue3.self = 'https://cdksfdcpoc.atlassian.net/rest/api/2/issue/10024';
        issue3.fields = new ISVC_SearchJiraIssuesResponse.IssueFields();
        issue3.fields.summary = 'Test issue 3';
        issue3.fields.status = new ISVC_SearchJiraIssuesResponse.Status();
        issue3.fields.status.name = 'To Do';
        issue3.fields.issuetype = new ISVC_SearchJiraIssuesResponse.IssueType();
        issue3.fields.issuetype.name = 'Bug';

        searchJiraIssuesRes.issues = new List<ISVC_SearchJiraIssuesResponse.Issue>{issue1, issue2, issue3};

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(searchJiraIssuesRes));
        res.setStatusCode(200);
        return res;
    }
}