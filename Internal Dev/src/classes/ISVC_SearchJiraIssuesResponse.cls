// GLOBIT-6029 Link JIRA Issues to Salesforce

// 2017-10-30 Marta.Malinowska@cdk.com
public class ISVC_SearchJiraIssuesResponse {
    public Integer startAt;
    public Integer maxResults;
    public Integer total;
    public List<Issue> issues;
    public Boolean success;
    public String error;

    public class Issue {
        public String id;
        public String key;
        public String self;
        public IssueFields fields;
    }

    public class IssueFields {
        public String summary;
        public Assignee assignee;
        public Status status;
        public IssueType issuetype;
    }

    public class Assignee {
        public String key;
    }

    public class Status {
        public String name;
    }

    public class IssueType {
        public String name;
    }
}