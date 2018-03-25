@RestResource(urlMapping='/issueupdate')
global class IssueListener {

    
    @HttpGet
    global static void doGET() {
        handleRequest();
    }
    
    @HttpPost
    global static void doPOST() {
        handleRequest();
        
    }
    
    private static void handleRequest(){
        String issueKey = RestContext.request.params.get('issueKey');
         
        RestResponse res = RestContext.response;
        
               
        if (issueKey == null){
            res.statusCode = 418;
            return;
        }

		// Integer issueCheckStatusCode = getJiraIssue(issueKey);
		res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');

        RestContext.response.responseBody = Blob.valueOf('{"ok":true,"message":"hello, world!"}');
    }

}