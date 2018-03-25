@isTest
public class ISVC_JiraProject_Builder {
    private Jira_Project__c record;
    private String name;
    private String key;

    public ISVC_JiraProject_Builder() {
        name = 'Test Project';
        key = 'TP';
    }

    public ISVC_JiraProject_Builder name(String name){
        this.name = name;
        return this;
    }

    public ISVC_JiraProject_Builder key(String key){
        this.key = key;
        return this;
    }

    public ISVC_JiraProject_Builder build(){
        record = new Jira_Project__c();
        record.Name = name;
        record.Key__c = key;
        return this;
    }

    public ISVC_JiraProject_Builder save(){
        build();
        insert record;
        return this;
    }

    public Jira_Project__c getRecord(){
        return record;
    }
}