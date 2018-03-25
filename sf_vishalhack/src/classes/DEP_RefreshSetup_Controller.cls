public class DEP_RefreshSetup_Controller 
{
    private List<Change_Set__c> changeSetList;
    
    public List<Change_Set_Component__c> changeSetComponents{get;set;}
    
    public String selectedSandboxName{get;set;}
    
    public List<String> sandboxList{get;set;}
    
    public List<ChangeSetWrapper> changeSetWrapperList{get;set;}
    
    public Change_Set__c newChangeset{get;set;}
    
    public Integer pageSize{get;set;}
    
    public Integer pageNumber{get;set;}
    
    public Message pageMessage{get;set;}
    
    public DEP_RefreshSetup_Controller()
    {
        pageNumber = 1;
        pageSize = 10;
        selectedSandboxName = 'ap1 Production';
        sandboxList = new List<String>();
        sandboxList.add('Unified');
        sandboxList.add('ap1 Production');
        sandboxList.add('Training');
        sandboxList.add('Metadata API Production');
        sandboxList.add('QA');
        sandboxList.add('QAlong');
        getChangeSetComponent();
    }
    
    public void getChangeSetComponent()
    {
        changeSetComponents = [SELECT Id, Component_Name__c, Change_Set__r.Name,Change_Set__r.Status__c, Estimated_Release_Date__c FROM Change_Set_Component__c WHERE Sandbox__c =: selectedSandboxName AND Change_Set__r.Status__c!='Done'];
    }
    public void getChangeSetList()
    {
        Integer offset = (pageNumber - 1)*pageSize;
        changeSetList =  [
            SELECT Id, Name, Description__c,Summary__c, Priority__c 
            FROM Change_Set__c 
            ORDER BY Name 
            LIMIT :pageSize
            OFFSET :offset
        ];
        changeSetWrapperList = setWrapperList();
    }
    
    public void insertChangeSet()
    {
        Http h = new Http();
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://projects.cdk.com/rest/api/2/issue/'+newChangeset.Name);
        req.setMethod('GET');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(BLob.valueOf('bandariv:Rekha$1704')) );
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        if(res.getStatusCode() == 200)
        {
            Map<String,Object> allfields = (Map<String,Object>)JSon.deserializeUntyped(res.getBody());
            allfields=(Map<String,Object>)allfields.get('fields');
            newChangeSet.Description__c = String.valueOf(allfields.get('description'));
            newChangeSet.Summary__c = String.valueOf(allfields.get('summary'));
            newChangeSet.Priority__c = String.valueOf(((Map<String,Object>)allfields.get('priority')).get('name'));
            newChangeSet.Status__c = String.valueOf(((Map<String,Object>)allfields.get('status')).get('name'));
            try
            {
                insert newChangeset;
            }
            catch(Exception e)
            {
                pageMessage = new Message();
                pageMessage.messageBody = e.getMessage().contains('bad value for restricted picklist field') ? 'Changset for '+newChangeset.Name+' cannot be created with current status' : 'Error in saving'; 
                pageMessage.messageSeverity = 'error';
                newChangeset = new Change_Set__c(Version__c=38.0);
                getChangeSetList();
                return ;
            }
            newChangeset = new Change_Set__c(Version__c=38.0);
            getChangeSetList();
            pageMessage = new Message();
            pageMessage.messageBody = 'Saved Successfully !!!!'; 
            pageMessage.messageSeverity = 'success';
            return;
        }
    }
    
    public void deleteChangeSet()
    {
        List<Change_Set__C> deleteList = getSelectedChangeSetFromWrapper();
        if(deleteList!=null && deleteList.size() >0)
        {
            try
            {
                delete deleteList;
            }
            catch(Exception e)
            {
                pageMessage = new Message();
                pageMessage.messageBody = 'Error in deleting'; 
                pageMessage.messageSeverity = 'error';
                newChangeset = new Change_Set__c(Version__c=38.0);
                getChangeSetList();
                return ;
            }
            newChangeset = new Change_Set__c(Version__c=38.0);
            getChangeSetList();
            pageMessage = new Message();
            pageMessage.messageBody = 'Deleted Successfully !!!!'; 
            pageMessage.messageSeverity = 'success';
        }
        return;
    }
    
    private List<ChangeSetWrapper> setWrapperList()
    {
        List<ChangeSetWrapper> changeSetWrapperList = new List<ChangeSetWrapper>();
        for(Change_Set__c changeSetObj : changeSetList)
        {
            changeSetWrapperList.add(new ChangeSetWrapper(changeSetObj));
        }
        return changeSetWrapperList;
    }
    
    private List<Change_Set__c> getAllChangeSetFromWrapper()
    {
        List<Change_Set__c> changsetList = new List<Change_Set__c>();
        for(ChangeSetWrapper changeSetWrapperObj : changeSetWrapperList)
        {
            changsetList.add(changeSetWrapperObj.changeSetObj);
        }
        return changsetList;
    }
    
    private List<Change_Set__c> getSelectedChangeSetFromWrapper()
    {
        List<Change_Set__c> changsetList = new List<Change_Set__c>();
        for(ChangeSetWrapper changeSetWrapperObj : changeSetWrapperList)
        {
            if(changeSetWrapperObj.selected)
            {
                changsetList.add(changeSetWrapperObj.changeSetObj);
            }
        }
        return changsetList;
    }
    
    public class ChangeSetWrapper
    {
        public Boolean selected{get;set;}
        public Change_Set__C changeSetObj{get;set;}
        
        public ChangeSetWrapper(Change_Set__C changeSetObj)
        {
            selected =false;
            this.changeSetObj = changeSetObj;
        }
        
    }
    
    public Class Message
    {
        public String messageBody{get;set;}
        public String messageSeverity{get;set;}
        public Message()
        {
            messageBody = messageSeverity = '';
        }
        
    }
}