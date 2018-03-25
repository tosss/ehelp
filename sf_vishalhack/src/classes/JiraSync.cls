//2017-Sep-30  vishal.bandari@cdk.com - Created Class for Public Invoking Web Service fro JIRA Webhook
@RestResource(urlMapping='/JiraSync/*')
global without sharing class JiraSync {
   
    @HttpPost
    global static String doPost()
    {        
        try
        {
            RestRequest restReq = RestContext.request;
            
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://JIRA_Instance_URL/rest/api/2/search');
            req.setMethod('GET');
            req.setHeader('Content-Type','application/json');
            
            //fields to be retirved using JQL
            String fields = '"updated",';
            
            List<Case_to_Jira__c> ctj = Case_to_Jira__c.getAll().values();
            
            //JIRA field name to Salesforce Field Name Map (All entered in lower case)
            Map<String,String> fieldsMap = new Map<String,String>();
            
            //JIRA field can be JSON rather than value, to hold traversing info to value if the field is JSON Ex.
            Map<String,String> ExpandedField = new Map<String,String>();
            for(Case_to_Jira__c ctjObj : ctj)
            {
                if(ctjObj.IsJIRAAccessible__c)
                {
                    fields+='"'+ctjObj.JiraName__c+'",';
                    
                    fieldsMap.put(ctjObj.JiraName__c.toLowerCase(),ctjObj.CaseName__c.toLowerCase());
                    
                    ExpandedField.put(ctjObj.JiraName__c.toLowerCase(),
                                      (ctjObj.ExpandedField__c!=null?ctjObj.ExpandedField__c.toLowerCase():null));
                }
            }
            
            fields = fields.removeEnd(',');
            
            //JIRA Authentication 
            req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(Blob.valueOf('username:password')) );
            
            //JQL to retrieve current values
            req.setBody('{"jql": "key=\''+restReq.params.get('key')+'\' AND project=\'SFI\'" , "startAt": 0,"fields": ['+fields+']}');
            HttpResponse res = h.send(req);
            
            if(res.getStatusCode() == 200)
            {
                //Response contains List of issues.
                Object issue = ((List<Object>)(((Map<String,Object>)JSon.deserializeUntyped(res.getBody())).get('issues')))[0];
                
                //Issue key
                String key = String.valueOf(((Map<String,Object>)issue).get('key'));
                
                //field and Value Pairs
                Map<String,Object> fieldsList =  (Map<String,Object>)((Map<String,Object>)issue).get('fields');
                
                //Status Mapping from JIRA to Salesforce(Can be made dynamic)
                Map<String,String> statusMap = new Map<String,String>();
                statusMap.put('In Progress','Open');
                statusMap.put('To Do','Waiting');
                statusMap.put('Done','Resolved');
                statusMap.put('Review','Returned');
                statusMap.put('Test','QA');
                
                //Related Case Obj for the JIRA Issue
                Case caseObj= [Select Id,JiraIssue__c,Subject,LastModifiedDate,Description,Status
                               FROM Case WHere JiraIssue__c =: key LIMIT 1];
                
                Boolean isUpatedAtJIRA = false;
                
                for(String fieldName : fieldsList.keySet())
                {
                    Object currentJiraFieldValue = fieldsList.get(fieldName);
                    if(fieldsMap.get(fieldName)!= null)
                    {
                        //Check if the value has Exapanded field
                        if(ExpandedField.get(fieldsMap.get(fieldName).toLowerCase()) != null)
                        {
                            currentJiraFieldValue = ((Map<String,Object>)currentJiraFieldValue).get(ExpandedField.get(fieldName).toLowerCase());
                        }
                        
                        //Check with Status Value of JIRA and corresponding Salesforce Field if current current name is Status.
                        if(fieldsMap.get(fieldName).toLowerCase() == 'status' )
                        {
                            currentJiraFieldValue = statusMap.get(String.valueOf(currentJiraFieldValue));
                        }
                        
                        //Check if field value has changed
                        if(!String.valueOf(caseObj.get(fieldsMap.get(fieldName).toLowerCase())).equalsIgnoreCase(String.valueOf(currentJiraFieldValue)))
                        {
                            isUpatedAtJIRA = true;
                            caseObj.put(fieldsMap.get(fieldName).toLowerCase(), String.valueOf(currentJiraFieldValue));
                        }
                    }
                }
                //Update only if field value has changes to avoid infinite looping
                if(isUpatedAtJIRA)
                {
                    //Avoid reccurrence
                    ALL_Case_Handler.runFutureOnce = 'Jira Create';
                    update caseObj;
                    return 'success';
                }
                return 'Already in Sync';
            }
            return 'JIRA Callout failed';
        }
        catch(Exception e)
        {
            return e.getMessage()+' '+e.getLineNumber();
        }
    }
    
}