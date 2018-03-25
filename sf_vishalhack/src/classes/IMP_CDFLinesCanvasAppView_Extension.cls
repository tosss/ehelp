// RQ-05791    - SubProject Home Page changes.
// Description - This class sends the required json parameters for cdf lines canvas app 
// 2015-12-09  - Venkata.shrivol@cdk.com  - Created

public with sharing class IMP_CDFLinesCanvasAppView_Extension 
{
    public SubProject__c subProject {get;set;}
    
    public List<String> subprojectIds{get;set;}
    
    public IMP_CDFLinesCanvasAppView_Extension(ApexPages.StandardController stdController)
    {
        //if(!Test.isRunningTest())
        try
        {
            stdController.addFields(new list<string>{'SubProject_Name__c','SubProject_Status__c'});
            String Ids = ApexPages.currentPage().getParameters().get('subprojectIds');
            if(Ids != null)
            {
                subprojectIds = Ids.split('\\|');
            }
        }
        catch(Exception e){
            system.debug('--Exception Caught---'+e);
        }
        subProject = (SubProject__c)stdController.getRecord();
    }
    
    public String getParameterString() 
    {
    	Project prj = new Project();
        prj.name = '';
        
        SubProject subPrj = new SubProject();
        subPrj.subProjectNumber = subProject.Name;
        subPrj.subProjectName = subProject.SubProject_Name__c;
        subPrj.subProjectId = subProject.Id;
        subPrj.subProjectStatus = subProject.SubProject_Status__c;
        
        // Query for the Subprojects associated with the current Project and gather information about each to include in the sibling parameter
        list<SubProject> siblingSubPrjs = new list<SubProject>();
        list<SubProject__c> siblings = (list<SubProject__c>)Database.query('SELECT Id, Name, SubProject_Name__c,  SubProject_Status__c from SubProject__c WHERE '+(subprojectIds!=null? 'Id IN :subprojectIds Or':'')+' Id = \''+ subProject.Id+'\'');
       
        if(siblings.size() > 0) 
        {
            for(SubProject__c sp:siblings) 
            {
               	SubProject subProj = new SubProject();
               	subProj.subProjectNumber = sp.Name; 
               	subProj.subProjectName = sp.SubProject_Name__c;
               	subProj.subProjectStatus = sp.SubProject_Status__c;
               	subProj.subProjectId = sp.Id;
                siblingSubPrjs.add(subProj);
            } 
        }

        // Query for the ClientContacts associated with the current Subproject and gather information about each to include in the contactList parameter 
        list<ClientContact> clientConList = new list<ClientContact>();       
        list<SubProject_Client_Contact__c> clientContacts = [SELECT Client_Contact__r.Lastname, Client_Contact__r.Firstname, Title__c, Email__c, Phone__c, SubProject__c from SubProject_Client_Contact__c WHERE SubProject__c = :subProject.Id];
        if(clientContacts.size() > 0) 
        {
            for(SubProject_Client_Contact__c clientCon:clientContacts) 
            {
            	ClientContact spcc = new ClientContact();
				spcc.lastName=clientCon.Client_Contact__r.Lastname;
            	spcc.firstName=clientCon.Client_Contact__r.Firstname;
            	spcc.email=clientCon.Email__c;
            	spcc.phoneNumber= clientCon.Phone__c;
            	spcc.title=clientCon.Title__c;
            	clientConList.add(spcc);
            } 
        }
        
        // Query for the CDKContacts associated with the current Subproject and then query the Contacts for each to gather information to include in the resourceList parameter  
        list<CDKContact> cdkConList = new list<CDKContact>();      
        List<Contact> resources = [
        	SELECT Id, Vendor_ID__c, User__c, Lastname, Firstname, Email 
        	from Contact 
        	WHERE User__c IN 
        	(
        		select CDK_Contact__c 
        		from SubProject_CDK_Contact__c
        		where SubProject__c = :subProject.Id
        	)
        ];        
        if(resources.size() > 0) 
        {
            for(Contact con:resources) 
            {
            	CDKContact cdkcon = new CDKContact();
            	cdkcon.vendorId=con.Vendor_ID__c;
            	cdkcon.lastName=con.Lastname;
            	cdkcon.firstName=con.Firstname;
            	cdkcon.email=con.Email;
            	cdkConList.add(cdkcon);
            } 
        }
        
        JsonParameters jsonObject = new JsonParameters();
        jsonObject.project = prj;
        jsonObject.subprojectSelected = subPrj;
        jsonObject.siblingsList = siblingSubPrjs;
        //jsonObject.contactList = clientConList;
        //jsonObject.resourceList = cdkConList;
        
        string jsonParams = '';
        jsonParams = convertStringToJSON(jsonObject);
        //system.debug('-------------'+jsonParams);
        return jsonParams;
    }
    
    public string convertStringToJSON(JsonParameters jp){
    	return JSON.serializePretty(jp);
    }
    
    public class Project
    {
    	public string name;
    }
    public class SubProject
    {
    	public string subProjectNumber;
    	public string subProjectName;
    	public string subProjectId;
    	public string subProjectStatus;
    }
    public class ClientContact
    {
    	public string firstName;
    	public string lastName;
    	public string email;
    	public string title;
    	public string phoneNumber;
    }
    public class CDKContact
    {
    	public string firstName;
    	public string lastName;
    	public string email;
    	public string vendorId;
    }
    public class JsonParameters
    {
    	public Project project;
    	public SubProject subprojectSelected;
    	public list<SubProject> siblingsList;
    	public list<ClientContact> contactList;
    	public list<CDKContact> resourceList;
    }

}