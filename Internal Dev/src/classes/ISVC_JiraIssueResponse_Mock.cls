@isTest
global class ISVC_JiraIssueResponse_Mock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        ISVC_JiraIssueResponse jiraIssueResponse = new ISVC_JiraIssueResponse();
        jiraIssueResponse.id = '248610';
        jiraIssueResponse.key = 'GLOBIT-7805';
        jiraIssueResponse.self = 'https://projects-training.cdk.com/rest/api/2/issue/248610';

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(JSON.serialize(jiraIssueResponse));
        res.setStatusCode(201);
        return res;
    }
}