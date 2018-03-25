// GLOBIT-6029 Link JIRA Issues to Salesforce

// 2017-10-30 Marta.Malinowska@cdk.com
public class ISVC_JiraSearchCallout {
    
    public static ISVC_SearchJiraIssuesResponse searchForJiraIssues(ISVC_SearchJiraIssuesRequest searchJiraIssuesReq){
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:JIRA/rest/api/2/search');
        req.setHeader('Content-Type','application/json');
        req.setMethod('POST');
        system.debug('searchJiraIssuesReq*'+searchJiraIssuesReq+' -----------------' +JSON.serialize(searchJiraIssuesReq));
        req.setBody(JSON.serialize(searchJiraIssuesReq));
        
        ISVC_SearchJiraIssuesResponse searchJiraIssuesRes = new ISVC_SearchJiraIssuesResponse();
        HttpResponse res;
        try{
            res = http.send(req);
        } catch(CalloutException ex){
            searchJiraIssuesRes.success = false;
            searchJiraIssuesRes.error = ex.getMessage();
            return searchJiraIssuesRes;
        }
        
        if(res.getStatusCode() != 200){
            searchJiraIssuesRes.success = false;
            searchJiraIssuesRes.error = res.toString();
            return searchJiraIssuesRes;
        }
        
        searchJiraIssuesRes = (ISVC_SearchJiraIssuesResponse) System.JSON.deserialize(res.getBody(), ISVC_SearchJiraIssuesResponse.class);
        searchJiraIssuesRes.success = true;
        return searchJiraIssuesRes;
    }
}