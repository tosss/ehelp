// GLOBIT-4804: Create Publisher Action to create JIRA issue
//
// 2017-10-24 marta.malinowska@cdk.com Created
public with sharing class ISVC_CreateJiraIssue_Extension {

    private static final String ISSUE_TYPE_BUG = 'Bug';
    private static final String ISSUE_STATUS_OPEN = 'Open';

    private Case parentCase;
    public String jiraProjectKey {get; set;}
    private String caseSubject;
    private String caseDescription;
    private Jira_Issue__c jiraIssue;
    private CaseJiraRelation__c caseJiraRelation;

    public ISVC_CreateJiraIssue_Extension(ApexPages.StandardController controller) {
        parentCase = (Case) controller.getRecord();
        caseSubject = parentCase.Subject;
        caseDescription = parentCase.Description;
    }

    public List<SelectOption> getJiraProjects() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        for(Jira_Project__c jiraProject : [SELECT Key__c, Name FROM Jira_Project__c]){
            options.add(new SelectOption(jiraProject.Key__c, jiraProject.Name));
        }
        return options;
    }

    public PageReference createJiraIssue() {
        if(String.isBlank(jiraProjectKey)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ISVC_JiraProjectIsRequiredField));
            return null;
        }
        if(String.isBlank(parentCase.Subject)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.ISVC_SummaryIsRequiredField));
            return null;
        }

        ISVC_JiraIssueRequest jiraIssueReq = new ISVC_JiraIssueRequest(jiraProjectKey, parentCase.Subject, parentCase.Description, ISSUE_TYPE_BUG);
        ISVC_JiraIssueResponse jiraIssueRes = ISVC_JiraIssueCallout.createJiraIssue(jiraIssueReq);
        if(jiraIssueRes.success){
            try {
                createJiraIssue(jiraIssueReq, jiraIssueRes);
                createCaseJiraRelation();
                postToChatter();
            } catch(DmlException ex){
                ApexPages.addMessages(ex);
            }
            refreshFields();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, jiraIssueRes.error));
        }

        return null;
    }

    private void createJiraIssue(ISVC_JiraIssueRequest jiraIssueReq, ISVC_JiraIssueResponse jiraIssueRes){
        jiraIssue = new Jira_Issue__c();
        jiraIssue.Id__c = Integer.valueOf(jiraIssueRes.id);
        jiraIssue.Key__c = jiraIssueRes.key;
        jiraIssue.Link__c = jiraIssueRes.self;
        jiraIssue.Type__c = jiraIssueReq.fields.issuetype.name;
        jiraIssue.Summary__c = jiraIssueReq.fields.summary;
        jiraIssue.Status__c = ISSUE_STATUS_OPEN;
        insert jiraIssue;
    }

    private void createCaseJiraRelation(){
        CaseJiraRelation__c caseJiraRelation = new CaseJiraRelation__c();
        caseJiraRelation.Case__c = parentCase.Id;
        caseJiraRelation.Issue__c = jiraIssue.Id;
        insert caseJiraRelation;
    }

    private void postToChatter(){
        ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
        textInput.text = System.Label.ISVC_NewJiraIssueHasBeenCreated;

        ConnectApi.LinkCapabilityInput linkInput = new ConnectApi.LinkCapabilityInput();
        linkInput.urlName = jiraIssue.Name;
        linkInput.url = URL.getSalesforceBaseUrl().toExternalForm()+'/'+jiraIssue.Id;

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = parentCase.Id;
        feedItemInput.body = new ConnectApi.MessageBodyInput();
        feedItemInput.body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.body.messageSegments.add(textInput);
        feedItemInput.capabilities = new ConnectApi.FeedElementCapabilitiesInput();
        feedItemInput.capabilities.link = linkInput;

        ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }

    private void refreshFields(){
        jiraProjectKey = '';
        parentCase.Subject = caseSubject;
        parentCase.Description = caseDescription;
    }
}