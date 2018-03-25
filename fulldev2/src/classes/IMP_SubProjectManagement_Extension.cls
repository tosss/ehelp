/*------------------------------------------------------------
Author: Michael Lasala
Company: Cloud Sherpas
Description: SubProject Management extension, supporting the display of the custom Subproject page with Detail and Milestone tabs
Test Class: IMP_SubProjectManagementExtension_Test
History
09/03/14    Michael Lasala      Created
09/11/14    Michael Lasala      Changed to extension
09/16/14    Michael Lasala      Added defaulting of tabs, Added isGenerated variable for rendering of Milestones tab
05/29/15    Fay Salwen          Added getParameterString() to pass to Canvas app for CDF Line Management
09/16/14    Michael Lasala      Added defaulting of tabs, Added isGenerated variable for rendering of Milestones tab
07/28/15    Vishal Bandari      RQ-04849: Added showDiscoveryTab variable, Added logic to render the Discovery Tab
10/27/15    Venkata Shrivol		Added escapeSingleQuotes string method in getParameterString Method (RQ-05621)
11/15/15    Venkata Shrivol     removed the esacpeSingleQuotes and added a JSON wrapper class to send the data
12/22/15    Venkata Shrivol		temporarily modified getParameter String method. This class will be deprecated soon. 
------------------------------------------------------------*/
public with sharing class IMP_SubProjectManagement_Extension {
    
    private final SubProject__c mysObject;
    
    public SubProject__c subProject {get;set;}
    public String defaultTab {get;set;}
    public Boolean isGenerated {get;set;}
    
    //Added by Vishal Bandari, to show Discovery Tab
    public Boolean showDiscoveryTab {get; set;}
    
    public IMP_SubProjectManagement_Extension (){
        //this.mysObject = (SubProject__c)stdController.getRecord();
        subProject = new SubProject__c();
        try {
            Id sId = ApexPages.currentPage().getParameters().get('id'); 
            if(sId != null){
                
                subProject = IMP_Project_Utility.retrieveSubProject(sId);
                showDiscoveryTab =false;
               
                if (subProject.id != null) {
                     //Rendering of Milestone tab     
                    if (subProject.Count_of_Milestones_on_SubProject__c > 0 || subProject.Milestones_Auto_Generated_Flag__c == true)
                    {
                        isGenerated = true;
                    }
                    else
                    {
                        isGenerated = false;
                    }
                    
                    //Rendering of Discovery tab
                    List<Site_Workbook__c>  siteWorkbookList = [
                            SELECT Id, Name,createddate, Site__c, Site__r.Name 
                            FROM Site_Workbook__c 
                            WHERE SubProject__c = :subProject.Id order by Createddate Desc];
                    if(siteWorkbookList.size() > 0)
                    {
                        //Show Discovery Tab if Site_Workbook__c is created for the SubProject__c
                        showDiscoveryTab =true;
                    }
                }else {
                    
                    ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'SubProject Id is not associated with any records!')); 
                }
            }
        } catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'SubProject Id is not associated with any records!')); 
        }
        
        defaultTab = ApexPages.currentPage().getParameters().get('tab');
        
        //Show Discovery Tab if the defaultTab is discoveryTab in page url
        if(defaultTab == 'discoveryTab')
        {
            showDiscoveryTab =true;
        }
        
        if(defaultTab == null){
            defaultTab = IMP_Project_Utility.TAB_SUBPROJECT;
        }
    }
    
     
    public String getParameterString() 
    {
    	Project prj = new Project();
        prj.name = subProject.Project__r.Name;
        
        SubProject subPrj = new SubProject();
        subPrj.subProjectNumber = subProject.Name;
        subPrj.subProjectName = subProject.SubProject_Name__c;
        subPrj.subProjectId = subProject.Id;
        subPrj.subProjectStatus = subProject.SubProject_Status__c;
        
        // Query for the Subprojects associated with the current Project and gather information about each to include in the sibling parameter
        list<SubProject> siblingSubPrjs = new list<SubProject>();
        list<SubProject__c> siblings = [SELECT Id, Name, SubProject_Name__c, Project__c, SubProject_Status__c from SubProject__c WHERE Project__c = :subProject.Project__c];
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
            	spcc.phoneNumber=clientCon.Phone__c;
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
        jsonObject.contactList = clientConList;
        jsonObject.resourceList = cdkConList;
        
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