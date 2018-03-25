// GLOBIT-6029 Link JIRA Issues to Salesforce

// 2017-10-30 Marta.Malinowska@cdk.com
public class ISVC_SearchJiraIssuesRequest {
    public String jql;
    public Integer startAt;
    public Integer maxResults;
   // public String summary;
  /* public List<String> fields = new List<String>{
            'id',
            'self',
            'key',
            'assignee',
            'status',
            'issuetype',
            'summary'
    };*/

    public ISVC_SearchJiraIssuesRequest(String project, Integer startAt, Integer maxResults){
        jql = 'project = ' + project+' AND status != Done AND text ~ test';
        this.startAt = startAt;
        this.maxResults = maxResults;
    }
}