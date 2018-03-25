@isTest
public class ISVC_JiraIssue_Builder {
    private Jira_Issue__c record;
    private Integer id;
    private String key;
    private String link;
    private String status;
    private String type;
    private String summary;

    public ISVC_JiraIssue_Builder() {
        id = 10022;
        key = 'TP-22';
        link = 'https://cdksfdcpoc.atlassian.net/rest/api/2/issue/10022';
        status = 'To Do';
        type = 'Bug';
        summary = 'Test JIRA issue';
    }

    public ISVC_JiraIssue_Builder id(Integer id){
        this.id = id;
        return this;
    }

    public ISVC_JiraIssue_Builder key(String key){
        this.key = key;
        return this;
    }

    public ISVC_JiraIssue_Builder link(String link){
        this.link = link;
        return this;
    }

    public ISVC_JiraIssue_Builder status(String status){
        this.status = status;
        return this;
    }

    public ISVC_JiraIssue_Builder type(String type){
        this.type = type;
        return this;
    }

    public ISVC_JiraIssue_Builder summary(String summary){
        this.summary = summary;
        return this;
    }

    public ISVC_JiraIssue_Builder build(){
        record = new Jira_Issue__c();
        record.Id__c = id;
        record.Key__c = key;
        record.Link__c = link;
        record.Status__c = status;
        record.Type__c = type;
        record.Summary__c = summary;
        return this;
    }

    public ISVC_JiraIssue_Builder save(){
        build();
        insert record;
        return this;
    }

    public Jira_Issue__c getRecord(){
        return record;
    }
}