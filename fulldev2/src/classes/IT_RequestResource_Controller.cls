public class IT_RequestResource_Controller {
    
    //Properties 
    public request_resource__c reqRes {get;set;}
    public request__c req {get;set;}
    public Id id{get;set;}
    public List<Request_Resource__c> resourcesPresent{get;set;}
    
    // Constructor
    public IT_RequestResource_Controller() 
    {      
        reqRes = new Request_Resource__c();
        resourcesPresent = new List<Request_Resource__c>();
        string teststring = system.currentPageReference().getparameters().get('id');
        try
        {
            id = testString; 
            if(id!=null)
            {
                reqRes.Request__c = id;
                list<Request__c> requests = [
                    select Status__c,createdByid, Name 
                    from Request__c 
                    where id =: reqRes.Request__c
                ];
                if(requests != null && !requests.isEmpty()) { req = requests.get(0); }
                displayRequestResources();                
            }
        }
        catch(Exception E)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please pass a valid Id.');
            ApexPages.addmessage(myMsg);           
        }        
    } 
    
    // Action Methods
    
    // ( This method is called only when we use manually select a request without passing Id in URL)
    public void requestPopulated()
    {
        req = [select Status__c,createdByid, Name from Request__c where id =: reqRes.Request__c][0];
        displayRequestResources();        
    }
    
    // This method checks for duplicates and inserts a resource if it passes the test
    // Takes requestId, ResourceType ( ApexPage or ApexClass or ApexComponent or StaticResource ) 
    // and the corresponding ResourceName as parameters
    @RemoteAction
    public  static String saveRecord(Id reqId, String resourceType, String resourceName)
    {
        Request_Resource__c reqRes = new Request_Resource__c(Request__c = reqId, Resource_Type__c = resourceType , Name = resourceName);                   
        List<Request_Resource__c> reqResList = new List<Request_Resource__c>();
        reqResList = [
            select Name, Resource_Type__c 
            from Request_Resource__c 
            where Request__c = :reqId
        ];
        
        // check for duplicates, so that no resource can be added twice
        for(Request_Resource__c rs : reqResList)
        {
            if(rs.Name == reqRes.Name && rs.Resource_Type__c == reqRes.Resource_Type__c)
            {
                return 'Duplicate Found';
            }
        }
        // try inserting if it passes the duplicacy test
        try
        {
            insert reqRes;
            return String.valueof(reqRes.id);
        }
        catch(Exception E)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Insert Failed');
            ApexPages.addMessage(myMsg);
            return null;
        }        
    }
    
    // searches for a resource ( except Standard and custom objects ) and takes what we type in the ResourceName text box as an argument
    @RemoteAction
    public static List<Object> searchResource(String resType, String queryTerm)
    {
        List<SObject> resourceList = new List<SObject>();
        resourceList = Database.query('select id, name from '+resType+' where name like \'%' +String.escapeSingleQuotes(queryTerm)+'%\'' );        
        return resourceList;
    }   
    
    // Searches for Standard and Custom objects and takes what we type in the ResourceName text box as an argument 
    @RemoteAction
    public static List<String> searchObjects(String resType, String queryTerm)
    {
        List<String> standardSObjectList = new List<String>();
        List<String> customSObjectList = new List<String>();
        List<String> finalList = new List<String>();
        
        // gets all SObjects into a list
        List<Schema.SObjectType> objTyp = Schema.getGlobalDescribe().Values();
        
        // bifurcate the above list into Custom and Standard object lists
        for(Schema.SObjectType o : objTyp)
        {
            if(o.getDescribe().isCustom())
            {
                customSObjectList.add(o.getDescribe().getLabel());
                customSObjectList.sort();
            }
            else
            {
                standardSObjectList.add(o.getDescribe().getLabel());
                standardSObjectList.sort();
            }
        }
        
        // as we want the list based on the query we type in the textbox, we get  finallist based on the queryTerm
        if(resType == 'StandardSObject')
        {
            for(String a : standardSObjectList)
            {
                if(a.startsWithIgnoreCase(queryTerm))
                {
                    finalList.add(a);
                }
            }
        }
        else
        {
            for(String a : customSObjectList)
            {
                if(a.startsWithIgnoreCase(queryTerm))
                {
                    finalList.add(a);
                }
            }
        }
        return finalList;
    } 
    
    public void displayRequestResources()
    {         
        resourcesPresent = database.query('select id,name,resource_type__c from Request_Resource__c where Request__c = \''+reqRes.Request__c+'\'');
    }
}