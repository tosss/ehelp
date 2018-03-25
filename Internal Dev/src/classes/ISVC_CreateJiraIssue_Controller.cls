/*****************************************************
**11/10/2017 created vijay.manimaran@cdk.com 
******************************************************** */

public with sharing class ISVC_CreateJiraIssue_Controller {
    
    @AuraEnabled
    public static List<Lightning_SelectOption> JiraProjects(){
        List<Lightning_SelectOption> options = new List<Lightning_SelectOption>();
        options.add(new Lightning_SelectOption('', '--None--'));
        for(Jira_Project__c jiraProject : [SELECT Key__c, Name FROM Jira_Project__c]){
            options.add(new Lightning_SelectOption(jiraProject.Key__c, jiraProject.Name));
        }
        return options;
    }
    @AuraEnabled
    public Static List<String> FieldPikclistValues(String ObjectApi_name, String picklistField)
    {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry>  controllingFieldValues = field_map.get(picklistField).getDescribe().getPickListValues();
        list<String> values =  new  list<String>();
        values.add('--None--');  
        
        for (Schema.PicklistEntry pklVal : controllingFieldValues){
            values.add(pklVal.getValue());  
        }
        system.debug('******* values'+values);
        return values;
    }
    
    @AuraEnabled
    public static void createJiraIssue(string jiraProjectKey , string Subject,String Description, String ISSUE_TYPE_BUG, String caseId, string customfield_11500) {
        ISVC_JiraIssueRequest jiraIssueReq = new ISVC_JiraIssueRequest(jiraProjectKey, Subject, Description, ISSUE_TYPE_BUG,customfield_11500);
        ISVC_JiraIssueResponse jiraIssueRes = ISVC_JiraIssueCallout.createJiraIssue(jiraIssueReq);
        if(jiraIssueRes.success){
            try {
                ISVC_CreateJiraIssue_Controller createJira = new ISVC_CreateJiraIssue_Controller();
                Jira_Issue__c JiraIssue = createJira.createJiraIssue(jiraIssueReq, jiraIssueRes);
                case cs = new case();
                createJira.createCaseJiraRelation(JiraIssue,caseId);
                createJira.postToChatter(JiraIssue,caseId);
            } catch(Exception ex){
            }
        } 
    }
    
    private Jira_Issue__c createJiraIssue(ISVC_JiraIssueRequest jiraIssueReq, ISVC_JiraIssueResponse jiraIssueRes){
        Jira_Issue__c  jiraIssue = new Jira_Issue__c();
        jiraIssue.Id__c = Integer.valueOf(jiraIssueRes.id);
        jiraIssue.Key__c = jiraIssueRes.key;
        jiraIssue.Link__c = jiraIssueRes.self;
        jiraIssue.Issue_Type__c = jiraIssueReq.fields.issuetype.name;
        jiraIssue.Summary__c = jiraIssueReq.fields.summary;
        jiraIssue.Status__c = 'Open';
       // jiraIssue.IT_Team__c = jiraIssueReq.fields.ITTeam.customfield_11500;

        insert jiraIssue;
        return jiraIssue;
    }
    
    private void createCaseJiraRelation(Jira_Issue__c jiraIssue, String caseId){
        CaseJiraRelation__c caseJiraRelation = new CaseJiraRelation__c();
        caseJiraRelation.Case__c = caseId;
        caseJiraRelation.Issue__c = jiraIssue.Id;
        system.debug('************ caseJiraRelation**********'+caseJiraRelation); 
        insert caseJiraRelation;
    }
    
    private void postToChatter(Jira_Issue__c jiraIssue, string caseId){
        ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
        textInput.text = System.Label.ISVC_NewJiraIssueHasBeenCreated;
        ConnectApi.LinkCapabilityInput linkInput = new ConnectApi.LinkCapabilityInput();
        linkInput.urlName = jiraIssue.Name;
        linkInput.url = URL.getSalesforceBaseUrl().toExternalForm()+'/'+jiraIssue.Id;
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = caseId;
        feedItemInput.body = new ConnectApi.MessageBodyInput();
        feedItemInput.body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.body.messageSegments.add(textInput);
        feedItemInput.capabilities = new ConnectApi.FeedElementCapabilitiesInput();
        feedItemInput.capabilities.link = linkInput;
        ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }
    
    
}