// GLOBIT-4804: Create Publisher Action to search JIRA Issues and Link them to the case
//
// 2017-10-31 marta.malinowska@cdk.com Created
public with sharing class ISVC_SearchAndLinkJiraIssues_Extension implements ALL_Pagination_Interface {

    private Case parentCase;
    private Set<String> linkedJiraIssueKeys;
    private Map<String, Jira_Issue__c> existingJiraIssues;
    public String jiraProjectKey {get; set;}
    public List<JiraIssue> jiraIssues {get; set;}

    private Integer PAGE_SIZE = 50;
    private Integer total;
    private Integer startAt;

    public ISVC_SearchAndLinkJiraIssues_Extension(ApexPages.StandardController controller) {
        parentCase = (Case) controller.getRecord();
        linkedJiraIssueKeys = getAlreadyLinkedJiraIssueKeys();
        jiraIssues = new List<JiraIssue>();
        total = 0;
        startAt = 0;
    }

    public List<SelectOption> getJiraProjects(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        for(Jira_Project__c jiraProject : [SELECT Key__c, Name FROM Jira_Project__c]){
            options.add(new SelectOption(jiraProject.Key__c, jiraProject.Name));
        }
        return options;
    }

    public PageReference searchJiraIssues() {
        if(String.isBlank(jiraProjectKey)){
            jiraIssues = new List<JiraIssue>();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ISVC_JiraProjectIsRequiredField));
            return null;
        }

        ISVC_SearchJiraIssuesRequest searchJiraIssuesReq = new ISVC_SearchJiraIssuesRequest(jiraProjectKey, startAt, PAGE_SIZE);
        ISVC_SearchJiraIssuesResponse searchJiraIssuesRes = ISVC_JiraSearchCallout.searchForJiraIssues(searchJiraIssuesReq);
        if(searchJiraIssuesRes.success){
            total = searchJiraIssuesRes.total;
            jiraIssues = getJiraIssues(searchJiraIssuesRes.issues);
            existingJiraIssues = getExistingJiraIssues(jiraIssues);
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, searchJiraIssuesRes.error));
        }

        return null;
    }

    public PageReference linkJiraIssues() {
        List<Jira_Issue__c> jiraIssuesToLink = new List<Jira_Issue__c>();
        List<Jira_Issue__c> jiraIssuesToInsert = new List<Jira_Issue__c>();
        Set<String> jiraIssueKeysToUnLink = new Set<String>();
        for(JiraIssue jiraIssue : jiraIssues){
            if(jiraIssue.selected && !linkedJiraIssueKeys.contains(jiraIssue.key)){
                Jira_Issue__c jiraIssueToLink;
                if(existingJiraIssues.containsKey(jiraIssue.key)){
                    jiraIssueToLink = existingJiraIssues.get(jiraIssue.key);
                } else {
                    jiraIssueToLink = createNewJiraIssue(jiraIssue);
                    jiraIssuesToInsert.add(jiraIssueToLink);
                }
                jiraIssuesToLink.add(jiraIssueToLink);
            }
            if(!jiraIssue.selected && linkedJiraIssueKeys.contains(jiraIssue.key)){
                jiraIssueKeysToUnLink.add(jiraIssue.key);
            }
        }
        if(!jiraIssuesToLink.isEmpty()){
            try {
                insert jiraIssuesToInsert;
                List<CaseJiraRelation__c> caseJiraRelationsToInsert = createNewCaseJiraRelations(jiraIssuesToLink);
                insert caseJiraRelationsToInsert;
                for(Jira_Issue__c jiraIssue : jiraIssuesToInsert){
                    linkedJiraIssueKeys.add(jiraIssue.Key__c);
                    existingJiraIssues.put(jiraIssue.Key__c, jiraIssue);
                }
            } catch(DmlException ex){
                ApexPages.addMessages(ex);
            }
        }
        if(!jiraIssueKeysToUnLink.isEmpty()){
            List<CaseJiraRelation__c> caseJiraRelationsToDelete = [
                    SELECT Id, Issue__r.Key__c FROM CaseJiraRelation__c
                    WHERE Case__c = :parentCase.Id AND Issue__r.Key__c IN :jiraIssueKeysToUnLink];
            try {
                delete caseJiraRelationsToDelete;
                for(CaseJiraRelation__c caseJiraRelation : caseJiraRelationsToDelete){
                    linkedJiraIssueKeys.remove(caseJiraRelation.Issue__r.Key__c);
                }
            } catch(DmlException ex){
                ApexPages.addMessages(ex);
            }
        }
        return null;
    }

    public void firstPage(){
        startAt = 0;
        searchJiraIssues();
    }

    public void lastPage(){
        startAt = total - Math.mod(total, PAGE_SIZE);
        searchJiraIssues();
    }

    public void previousPage(){
        startAt = startAt - PAGE_SIZE;
        searchJiraIssues();
    }

    public void nextPage(){
        startAt = startAt + PAGE_SIZE;
        searchJiraIssues();
    }

    public Boolean getHasPreviousPage(){
        if(startAt > 0){
            return true;
        } else {
            return false;
        }
    }

    public Boolean getHasNextPage(){
        if((startAt + PAGE_SIZE) < total){
            return true;
        } else {
            return false;
        }
    }

    public Integer getCurrentPageNumber(){
        return startAt / PAGE_SIZE + 1;
    }

    public Integer getTotalPageNumber(){
        Decimal nrOfPages = (Decimal) total / PAGE_SIZE;
        return (Integer) nrOfPages.round(System.RoundingMode.CEILING);
    }

    private Set<String> getAlreadyLinkedJiraIssueKeys(){
        Set<String> linkedJiraIssueKeys = new Set<String>();
        for(CaseJiraRelation__c caseJiraRelation : [SELECT Issue__r.Key__c FROM CaseJiraRelation__c WHERE Case__c = :parentCase.Id]){
            linkedJiraIssueKeys.add(caseJiraRelation.Issue__r.Key__c);
        }
        return linkedJiraIssueKeys;
    }

    private List<JiraIssue> getJiraIssues(List<ISVC_SearchJiraIssuesResponse.Issue> issues){
        List<JiraIssue> jiraIssues = new List<JiraIssue>();
        for(ISVC_SearchJiraIssuesResponse.Issue issue : issues){
            JiraIssue jiraIssue = new JiraIssue();
            jiraIssue.selected = linkedJiraIssueKeys.contains(issue.key);
            jiraIssue.id = issue.id;
            jiraIssue.key = issue.key;
            jiraIssue.self = issue.self;
            if(issue.fields != null){
                jiraIssue.assignee = issue.fields.assignee != null ? issue.fields.assignee.key : '';
                jiraIssue.status = issue.fields.status != null ? issue.fields.status.name : '';
                jiraIssue.type = issue.fields.issuetype != null ? issue.fields.issuetype.name : '';
                jiraIssue.summary = issue.fields.summary;
            }
            jiraIssues.add(jiraIssue);
        }
        return jiraIssues;
    }

    private Map<String, Jira_Issue__c> getExistingJiraIssues(List<JiraIssue> jiraIssues){
        Set<String> jiraIssueKeys = new Set<String>();
        for(JiraIssue jiraIssue : jiraIssues){
            jiraIssueKeys.add(jiraIssue.key);
        }
        Map<String, Jira_Issue__c> existingJiraIssues = new Map<String, Jira_Issue__c>();
        for(Jira_Issue__c jiraIssue : [SELECT Id, Key__c FROM Jira_Issue__c WHERE Key__c IN :jiraIssueKeys]){
            existingJiraIssues.put(jiraIssue.Key__c, jiraIssue);
        }
        return existingJiraIssues;
    }

    private Jira_Issue__c createNewJiraIssue(JiraIssue issue){
        Jira_Issue__c jiraIssue = new Jira_Issue__c();
        jiraIssue.Id__c = Integer.valueOf(issue.id);
        jiraIssue.Key__c = issue.key;
        jiraIssue.Link__c = issue.self;
        jiraIssue.Status__c = issue.status;
        jiraIssue.Type__c = issue.type;
        jiraIssue.Summary__c = issue.summary;
        return jiraIssue;
    }

    private List<CaseJiraRelation__c> createNewCaseJiraRelations(List<Jira_Issue__c> jiraIssues){
        List<CaseJiraRelation__c> caseJiraRelations = new List<CaseJiraRelation__c>();
        for(Jira_Issue__c jiraIssue : jiraIssues){
            CaseJiraRelation__c caseJiraRelation = new CaseJiraRelation__c();
            caseJiraRelation.Case__c = parentCase.Id;
            caseJiraRelation.Issue__c = jiraIssue.Id;
            caseJiraRelations.add(caseJiraRelation);
        }
        return caseJiraRelations;
    }

    public class JiraIssue {
        public Boolean selected {get; set;}
        public String id {get; set;}
        public String key {get; set;}
        public String self {get; set;}
        public String assignee {get; set;}
        public String status {get; set;}
        public String type {get; set;}
        public String summary {get; set;}
    }
}