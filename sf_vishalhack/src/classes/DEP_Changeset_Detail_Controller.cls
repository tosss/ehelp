public class DEP_Changeset_Detail_Controller 
{
    public Change_Set__c changeSetObj{get;set;}
    
    public Change_Set_Component__c newChangeSetComponentObj{get;set;}
     
    public Change_Set_Deployment__c newChangeSetDeploymentObj{get;set;}
    public String ccAddress{get;set;}
    
    public String componentDeletionReason{get;set;}
    
    private static final Integer METADATA_API_VERSION = Integer.valueOf(new MetadataService.MetadataPort().endpoint_x.substringAfterLast('/'));

	public String MetadataFileName {get; set;}
	public String MetadataFileData {get; set;}
	public MetadataService.AsyncResult RetrieveAsyncResult {get; private set;}
	public String MetaDataRetrieveZip { get; private set; }	
	public List<MetadataFile> MetadataFiles { get; set; }		
    private List<Attachment> allAttachments;
    public String recordIdInAction{get;set;}
    public List<Component> deployingComponents{get;set;}
    
    private Map<String,String> statusCodes;
    
    public String ZipData { get; set; }	
    
    public String packageXML{get;set;}
	
	public MetadataService.AsyncResult AsyncResult {get; private set;}
    
    private MetadataService.MetadataPort service;
    
    public Message pageMessage{get;set;}
	
	public PageReference retrieveMetadataItem()
	{
        pageMessage = null;
		// Reset state from any previous requests
		MetaDataRetrieveZip = null;
		MetadataFiles = null;
		 
		// Construct unmanaged package with list of desired components to retrieve in zip				
		MetadataService.RetrieveRequest retrieveRequest = new MetadataService.RetrieveRequest();
		retrieveRequest.apiVersion = METADATA_API_VERSION;
		retrieveRequest.packageNames = null;
		retrieveRequest.singlePackage = true;
		retrieveRequest.specificFiles = null;
		retrieveRequest.unpackaged = new MetadataService.Package_x();
		retrieveRequest.unpackaged.types = new List<MetadataService.PackageTypeMembers>();
		MetadataService.PackageTypeMembers packageType = new MetadataService.PackageTypeMembers();
		packageType.name = newChangeSetComponentObj.Component_Type__c; 
		packageType.members = new String[] { newChangeSetComponentObj.Folder_Name__c, newChangeSetComponentObj.Component_Name__c };
		retrieveRequest.unpackaged.types.add(packageType);
		RetrieveAsyncResult = service.retrieve(retrieveRequest);
						
		return null;	
	}
	
	public PageReference checkRetrieveAsyncRequest()
	{
        pageMessage = null;
		// Check the status of the retrieve request
		MetadataService.RetrieveResult retrieveResult = service.checkRetrieveStatus(RetrieveAsyncResult.Id, true);
		if(retrieveResult.zipFile != null)
		{
				// Place Base64 encoded zip data onto the page for the JSZip library to handle
				MetaDataRetrieveZip = retrieveResult.zipFile;
				MetadataFiles = new List<MetadataFile>();
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Expanding...'));
				RetrieveAsyncResult = null;		}
		else
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Retrieving metadata...'));
		}	

		return null;
	}
	
	public PageReference receiveMetadataZipFile()
	{
		// In this example the retrieved metadata is stored in viewstate in production cases you would probably use a custom object / attachment
		pageMessage = null;
		MetadataFile metaDataFile = new MetadataFile();
		metaDataFile.fullName = MetaDataFileName;
		metaDataFile.content = MetaDataFileData;
		MetadataFiles.add(metaDataFile);
        Attachment attachmentObj = new Attachment();
        attachmentObj.Name = MetaDataFileName;
        attachmentObj.Body = Blob.valueOf(MetaDataFileData);
        attachmentObj.ContentType = '.txt';
        allAttachments.add(attachmentObj);
		return null;
	}
	
	public PageReference receiveComplete()
	{
		// Completed, cleared Base64 encoded zip data from viewstate
		pageMessage = null;
        try
        {
            insert newChangeSetComponentObj;
            
            for(Attachment attachObj  : allAttachments)
            {
                attachObj.ParentId = newChangeSetComponentObj.Id;
            }
            insert allAttachments;
        }
        catch(Exception e)
        {
            MetaDataRetrieveZip = null;	
            pageMessage = new Message();
            System.debug(e.getCause());
            pageMessage.messageBody = e.getMessage().remove('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,').remove(': []');
            pageMessage.messageSeverity = 'error';
            return null;
        }
        getChangeSetObj();
		MetaDataRetrieveZip = null;		
        newChangeSetComponentObj = new Change_Set_Component__c();
        pageMessage = new Message();
        pageMessage.messageBody = 'Saved Succesfully !!!';
        pageMessage.messageSeverity = 'success';
		return null;
	}	
	
	/**
	 * Simple container class for retrieve metadata file, may as well leverage the Metadata API class for this
	 **/
	public class MetadataFile extends MetadataService.MetadataWithContent
	{
		public String getFullname()
		{
			return fullName;
		}
		
		public String getContent()
		{
			return content;
		}
	}
    
    public DEP_Changeset_Detail_Controller()
    {
        pageMessage = null;
        newChangeSetComponentObj = new Change_Set_Component__c();
        newChangeSetDeploymentObj = new Change_Set_Deployment__c();
        statusCodes = new Map<String,String>();
        statusCodes.put('To Do','11');
        statusCodes.put('In Progress','21');
        statusCodes.put('Done','31');
        statusCodes.put('Blocked','41');
        statusCodes.put('Abandoned','51');
        statusCodes.put('Review','61');
        statusCodes.put('Test','71');
        getChangeSetObj();
    }
    public void updateChangeSetStatus()
    {
        Http h = new Http();
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://projects.cdk.com/rest/api/2/issue/'+changeSetObj.Name+'/transitions?expand=transitions.fields');
        req.setMethod('POST');
        req.setHeader('Authorization','Basic '+EncodingUtil.base64Encode(BLob.valueOf('bandariv:Rekha$1212')) );
        req.setHeader('Content-Type','application/json');
        req.setBody('{"transition":{"id":"'+statusCodes.get(changeSetObj.Status__c)+'"}}');
        // Send the request, and return a response
        HttpResponse res = h.send(req); 
        if(res.getStatusCode() == 200 || res.getStatusCode() == 204)
        {
            try
            {
                update changeSetObj;
                if(changeSetObj.Status__c == 'Done')
                {
                    delete changeSetObj.Change_Set_Components__r;
                }
            }
            catch(Exception e)
            {
                pageMessage = new Message();
                pageMessage.messageBody = e.getMessage().remove('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,').remove(': []');
                pageMessage.messageSeverity = 'error';
                return;
            }
            getChangeSetObj();
            pageMessage = new Message();
            pageMessage.messageBody = 'Updated Succesfully !!!';
            pageMessage.messageSeverity = 'success';
        }
    }
    public void insertNewComponent()
    {
        pageMessage = null;
        Id changeSetId = ApexPages.currentPage().getParameters().get('id');
        newChangeSetComponentObj.Change_Set__c = changeSetId;
        allAttachments = new List<Attachment>();
        Sandbox_Credentials__c credentials = Sandbox_Credentials__c.getAll().get(newChangeSetComponentObj.Sandbox__c); 
		service = MetadataServiceExamples.createService(credentials.User_Name__c,credentials.Password__c+credentials.Security_Token__c, credentials.isSandbox__c);
        retrieveMetadataItem();
    }
    
    public void updateChangeSetComponents()
    {
        pageMessage = null;
        try
        {
            update changeSetObj.Change_Set_Components__r;
        }
        catch(Exception e)
        {
            pageMessage = new Message();
            pageMessage.messageBody = e.getMessage().remove('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,').remove(': []');
            pageMessage.messageSeverity = 'error';
            return;
        }
        getChangeSetObj();
        pageMessage = new Message();
        pageMessage.messageBody = 'Saved Succesfully !!!';
        pageMessage.messageSeverity = 'success';
    }
    
    public void updateChangeSetDeployments()
    {
        pageMessage = null;
        try
        {
            update changeSetObj.Change_Set_Deployments__r;
        }
        catch(Exception e)
        {
            pageMessage = new Message();
            pageMessage.messageBody = e.getMessage().remove('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,').remove(': []');
            pageMessage.messageSeverity = 'error';
            return;
        }
        getChangeSetObj();
        pageMessage = new Message();
        pageMessage.messageBody = 'Saved Succesfully !!!';
        pageMessage.messageSeverity = 'success';
    }
    
    public void getChangeSetObj()
    {
        Id changeSetId = ApexPages.currentPage().getParameters().get('id');
        changeSetObj = [SELECT Id, Name,Priority__c, Summary__c,Description__c,Status__c , Major_Release__c, Estimated_Release_Date__c, CreatedBy.Name, CreatedDate, LastModifiedBy.Name, LastModifiedDate,
                        (SELECT Id, Name, Component_Name__c, Component_Type__c,isAvailable__c, Deployment_Order__c,CreatedBy.Name,Folder_Name__c, Sandbox__c FROM Change_Set_Components__r ORDER BY Deployment_Order__c ),
                        (SELECT Id, Name,CreatedBy.Name, Sandbox__c, Sandbox_Type__c, Status__c, Deployment_Order__c, Deployment_Strategy__c FROM Change_Set_Deployments__r ORDER BY Deployment_Order__c)
                        FROM Change_Set__c 
                        WHERE Id = :changeSetId];
    }
    
    public void insertNewDeployment()
    {
        pageMessage = null;
        Id changeSetId = ApexPages.currentPage().getParameters().get('id');
        try
        {
            if(recordIdInAction == null || recordIdInAction == '')
            {
                newChangeSetDeploymentObj.Change_Set__c = changeSetId;
                insert newChangeSetDeploymentObj;
            }
            else
            {
                newChangeSetDeploymentObj.Id = recordIdInAction;
                update newChangeSetDeploymentObj;
            }
            recordIdInAction = null;
        
        }
        catch(Exception e)
        {
            newChangeSetDeploymentObj = new Change_Set_Deployment__c();
            pageMessage = new Message();
            pageMessage.messageBody = e.getMessage().remove('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,').remove(': []');
            pageMessage.messageSeverity = 'error';
            return;
        }
        getChangeSetObj();
        pageMessage = new Message();
        pageMessage.messageBody = 'Saved Succesfully !!!';
        pageMessage.messageSeverity = 'success';
        newChangeSetDeploymentObj = new Change_Set_Deployment__c();
    }
    
    public void deleteDeployment()
    {
        try
        {
            newChangeSetDeploymentObj.Id = recordIdInAction;
        	delete newChangeSetDeploymentObj;
        }
        catch(Exception e)
        {
            pageMessage = new Message();
            pageMessage.messageBody = e.getMessage().remove('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,').remove(': []');
            pageMessage.messageSeverity = 'error';
            newChangeSetDeploymentObj = new Change_Set_Deployment__c();
            return;
        }
        getChangeSetObj();
        pageMessage = new Message();
        pageMessage.messageBody = 'Deleted Succesfully !!!';
        pageMessage.messageSeverity = 'success';
        newChangeSetDeploymentObj = new Change_Set_Deployment__c();
    }
    
    public void deploy()
    {
        pageMessage = null;
        newChangesetDeploymentObj = [SELECT Id, Sandbox__c, Sandbox_type__c, Status__c, Deployment_Order__c, Deployment_Strategy__c  FROM Change_set_Deployment__c WHERE Id =: recordIdInAction];
        
        Sandbox_Credentials__c credentials = Sandbox_Credentials__c.getAll().get(newChangesetDeploymentObj.Sandbox__c); 
		service = MetadataServiceExamples.createService(credentials.User_Name__c,credentials.Password__c+credentials.Security_Token__c,credentials.isSandbox__c);
        Id changeSetId = ApexPages.currentPage().getParameters().get('id');
        List<Change_Set_Deployment__c> deployments = [SELECT Id FROM Change_Set_Deployment__c WHERE Change_Set__c = :changeSetId];
        List<Attachment> attachments = [SELECT Body FROM Attachment WHERE ParentId IN: deployments AND Name = 'package.xml'];
        delete attachments;
        List<Change_Set_Component__c> components = [SELECT Id, Change_Set__r.Version__c FROM Change_Set_Component__c WHERE Change_Set__c = :changeSetId Order By Deployment_Order__c];
        Decimal version = components[0].Change_Set__r.Version__c;
        attachments = [SELECT Body FROM Attachment WHERE ParentId IN: components AND Name = 'package.xml'];
        String xml = '<?xml version="1.0" encoding="UTF-8"?>\n<Package xmlns="http://soap.sforce.com/2006/04/metadata">';
        for(Attachment attach : attachments)
        {
            xml += attach.Body.toString().remove('<?xml version="1.0" encoding="UTF-8"?>\n<Package xmlns="http://soap.sforce.com/2006/04/metadata">').remove(attach.Body.toString().substringBetween('</types>', '\n</Package>')).remove('\n</Package>');
        }
        xml+='<version>'+version+'</version>\n</Package>';
        deployments = [SELECT Id FROM Change_Set_Deployment__c WHERE Id = :recordIdInAction];
        List<Attachment> attachmentDeployments = new List<Attachment>();
        for(Change_Set_Deployment__c deployment : deployments)
        {
            Attachment attach = new Attachment(Body = Blob.valueOf(xml),Name='package.xml',ParentId = deployment.Id);
            attachmentDeployments.add(attach);
        }
        insert attachmentDeployments;
        deployComponents();
    }
	
	
	public PageReference deployZip()
	{
		pageMessage = null;
 
		// Deploy zip file posted back from the page action function				
		Sandbox_Credentials__c credentials = Sandbox_Credentials__c.getAll().get(newChangesetDeploymentObj.Sandbox__c); 
		service = MetadataServiceExamples.createService(credentials.User_Name__c,credentials.Password__c+credentials.Security_Token__c,credentials.isSandbox__c);
		MetadataService.DeployOptions deployOptions = new MetadataService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.testLevel = newChangesetDeploymentObj.Deployment_Strategy__c;
        deployOptions.singlePackage = true;		
		AsyncResult = service.deploy(ZipData, DeployOptions);
        getChangeSetObj();
		return null;
	}	
	
	public PageReference checkAsyncRequest()
	{	
        pageMessage = null;
		// Check the status of the retrieve request
		Sandbox_Credentials__c credentials = Sandbox_Credentials__c.getAll().get(newChangesetDeploymentObj.Sandbox__c); 
		service = MetadataServiceExamples.createService(credentials.User_Name__c,credentials.Password__c+credentials.Security_Token__c,credentials.isSandbox__c);
		MetadataService.DeployResult deployResult = service.checkDeployStatus(AsyncResult.Id, true);
		if(deployResult.done)
		{

			// Deployment errors?
            if(deployResult.details!=null && deployResult.details.componentFailures!=null)
            {
                for(MetadataService.DeployMessage deployMessage : deployResult.details.componentFailures)
                {
                    if(deployMessage.problem!=null)
                    {
                        pageMessage = new Message();
                        pageMessage.messageBody = deployMessage.fileName + 
                            ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + 
                            deployMessage.problem;
                        pageMessage.messageSeverity = 'error';
                        AsyncResult = null;
                        packageXML = null;
                        pageMessage = new Message();
                        pageMessage.messageBody = 'Deployment Error !!!  '+deployMessage.problem;
                        pageMessage.messageSeverity = 'error';
                        newChangesetDeploymentObj.Deployment_Error__c = deployMessage.fileName + 
                            ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + 
                            deployMessage.problem;
                        newChangesetDeploymentObj.Status__c = 'Deployment Failed';
                        update newChangesetDeploymentObj;
                        getChangeSetObj();
                        newChangesetDeploymentObj = new Change_Set_Deployment__c();
                        return null;
                    }
                }
            }
            
            pageMessage = new Message();
            pageMessage.messageBody = 'Deployed Successfully !!!!'; 
            pageMessage.messageSeverity = 'success';
            newChangesetDeploymentObj.Deployment_Error__c = 'N/A';
            newChangesetDeploymentObj.Status__c = 'Deployed';
            update newChangesetDeploymentObj;
            newChangesetDeploymentObj = new Change_Set_Deployment__c();
            getChangeSetObj();
            packageXML = null;
            AsyncResult = null;
		}
		else
		{
            pageMessage = null;
            getChangeSetObj();
            AsyncResult = null;
		}	
		return null;
	}
    
    public void deployComponents()
    {
        pageMessage = null;
        deployingComponents = new List<Component>();
        
        Id changeSetId = ApexPages.currentPage().getParameters().get('id');
        List<Change_Set_Component__c> components = [SELECT Id, Change_Set__r.Version__c FROM Change_Set_Component__c WHERE Change_Set__c = :changeSetId Order By Deployment_Order__c];
        Decimal version = components[0].Change_Set__r.Version__c;
        List<Attachment> attachments = [SELECT Name,Body FROM Attachment WHERE ParentId IN: components AND Name != 'package.xml'];
        
        for(Attachment attach : attachments)
        {
            deployingComponents.add(new Component(attach.Name, attach.Body, version));
        }
        
        List<Change_Set_Deployment__c> deployments = [SELECT Id FROM Change_Set_Deployment__c WHERE Id = :newChangesetDeploymentObj.Id];
        attachments = [SELECT Body FROM Attachment WHERE ParentId IN: deployments AND Name = 'package.xml'];
        packageXML = attachments[0].Body.toString().replace('\n','');
    }
    
    public PageReference deleteComponent()
    {
        try
        {
            Change_Set_Component__c componentObj = [SELECT Id, Component_Name__c, Change_set__r.Name FROM Change_Set_Component__c WHERE Id = :recordIdInAction];
            if(componentDeletionReason=='To be used by other High Priority Request')
            {
                DEP_SendEmail.sendEmailWithAttachment('', UserInfo.getUserEmail()+';'+ccAddress, componentObj);
            }
        	delete componentObj;
        }
        catch(Exception e)
        {
            pageMessage = new Message();
            pageMessage.messageBody = e.getMessage().remove('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION,').remove(': []');
            pageMessage.messageSeverity = 'error';
            return null;
        }
        getChangeSetObj();
        pageMessage = new Message();
        pageMessage.messageBody = 'Deleted Succesfully !!!';
        pageMessage.messageSeverity = 'success';
        newChangeSetComponentObj = new Change_Set_Component__c();
        return null;
    }
    
    public class Component
    {
        public String path{get;set;}
        public String body{get;set;}
        
        public Component(String path,Blob body,Decimal Version)
        {
            this.path = path;
            this.body = body.toString();
            if(body.toString().contains('<apiVersion>'))
            {
            this.body = body.toString().remove(body.toString().substringBetween('<apiVersion>', '</apiVersion>')).replace('<apiVersion></apiVersion>','<apiVersion>'+Version+'</apiVersion>');
        	}
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