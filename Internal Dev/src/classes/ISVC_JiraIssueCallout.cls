// GLOBIT-4804 Create JIRA Issue from Salesforce

// 2017-10-30 Marta.Malinowska@cdk.com
public class ISVC_JiraIssueCallout {

    public static ISVC_JiraIssueResponse createJiraIssue(ISVC_JiraIssueRequest jiraIssueReq){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:JIRA/rest/api/2/issue/');
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');
        system.debug('**** JSON.serialize(jiraIssueReq) **'+JSON.serialize(jiraIssueReq));
        req.setBody(JSON.serialize(jiraIssueReq));

        ISVC_JiraIssueResponse jiraIssueRes = new ISVC_JiraIssueResponse();
        HttpResponse res;
        try{
            res = http.send(req);
            system.debug('**** res'+res);
        } catch(CalloutException ex){
            jiraIssueRes.success = false;
            jiraIssueRes.error = ex.getMessage();
            return jiraIssueRes;
        }

        if(res.getStatusCode() != 201){
            jiraIssueRes.success = false;
            jiraIssueRes.error = res.toString();
            return jiraIssueRes;
        }

        jiraIssueRes = (ISVC_JiraIssueResponse) System.JSON.deserialize(res.getBody(), ISVC_JiraIssueResponse.class);
        jiraIssueRes.success = true;
        return jiraIssueRes;
    }
}