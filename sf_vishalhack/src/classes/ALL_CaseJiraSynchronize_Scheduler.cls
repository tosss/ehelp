global class ALL_CaseJiraSynchronize_Scheduler implements Schedulable 
{
    global void execute(SchedulableContext SC) 
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://projects.cdk.com/rest/api/2/search');
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');
        String fields = '"updated",';
        List<Case_to_Jira__c> ctj = Case_to_Jira__c.getAll().values();
        Map<String,String> fieldsMap = new Map<String,String>();
        Map<String,String> ExpandedField = new Map<String,String>();
        String changedBy = '( ';
        for(Case_to_Jira__c ctjObj : ctj)
        {
            if(ctjObj.IsJIRAAccessible__c)
            {
                fields+='"'+ctjObj.JiraName__c+'",';
                changedBy+=(ctjObj.JiraName__c!='summary' || ctjObj.JiraName__c!='description')?' '+ctjObj.JiraName__c+' changed BY "bandariv" or ':'';
                fieldsMap.put(ctjObj.JiraName__c.toLowerCase(),ctjObj.CaseName__c.toLowerCase());
                ExpandedField.put(ctjObj.JiraName__c.toLowerCase(),
                                  (ctjObj.ExpandedField__c!=null?ctjObj.ExpandedField__c.toLowerCase():null));
            }
        }
        changedBy = changedBy.removeEnd(' or ');
        changedBy += ' ) ';
        fields = fields.removeEnd(',');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf('bandariv:Tonu$1212')) );
        req.setBody('{"jql": "updated>=\'-90m\' AND project=\'SFI\'" , "startAt": 0,"fields": ['+fields+']}');
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200)
        {
            List<Object> issues=(List<Object>)(((Map<String,Object>)JSon.deserializeUntyped(res.getBody())).get('issues'));
            Map<String,Object> allIssues = new Map<String,Object>();
            for(Object issue : issues)
            {
                allIssues.put(String.valueOf(((Map<String,Object>)issue).get('key')),((Map<String,Object>)issue).get('fields'));
            }
            Map<String,String> statusMap = new Map<String,String>();
            statusMap.put('In Progress','Open');
            statusMap.put('To Do','Waiting');
            statusMap.put('Done','Resolved');
            statusMap.put('Review','Returned');
            statusMap.put('Test','QA');
            
            List<Case> caseList= [Select Id,JiraIssue__c,LastModifiedDate
                                FROM Case WHere JiraIssue__c In: allIssues.keySet()];
            List<Case> casetoUpdate = new List<Case>();
            Map<String,Case> jiraToCase = new Map<String,Case>();
            
            for(Case caseObj : caseList )
            {
                jiraToCase.put(caseObj.JiraIssue__c,caseObj);
            }
            
            for(String issueKey : allIssues.keySet())
            {
                Object issue = allIssues.get(issueKey);
                
                Case caseObj = jiraToCase.get(issueKey);
                
                Map<String,Object> fieldsList =  (Map<String,Object>)allIssues.get(issueKey);
                Boolean isUpatedAtJIRA = false;
                for(String fieldName : fieldsList.keySet())
                {
                    Object currentJiraFieldValue = fieldsList.get(fieldName);
                    if(fieldsMap.get(fieldName)!= null)
                    {
                        if(ExpandedField.get(fieldsMap.get(fieldName).toLowerCase()) != null)
                        {
                            currentJiraFieldValue = ((Map<String,Object>)currentJiraFieldValue).get(ExpandedField.get(fieldName).toLowerCase());
                        }
                        
                        if(fieldsMap.get(fieldName).toLowerCase() == 'status' )
                        {
                            currentJiraFieldValue = statusMap.get(String.valueOf(currentJiraFieldValue));
                        }
                        if(String.valueOf(caseObj.get(fieldsMap.get(fieldName).toLowerCase())).equalsIgnoreCase(String.valueOf(currentJiraFieldValue)))
                        {
                            isUpatedAtJIRA = true;
                            caseObj.put(fieldsMap.get(fieldName).toLowerCase(), String.valueOf(currentJiraFieldValue));
                        }
                    }
                }
                if(isUpatedAtJIRA)
                {
                    caseToUpdate.add(caseObj);
                }
            }
            if(caseToUpdate.size() > 0)
            {
                ALL_Case_Handler.runFutureOnce = 'Jira Create';
                update caseToUpdate;
            }
        }
    }
}