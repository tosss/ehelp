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
                    isGenerated = subProject.Milestones_Auto_Generated_Flag__c;
                    
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
    
    public String getParameterString() {
    
        String currentName = subProject.Name + ' - ' + subProject.SubProject_Name__c;
        System.debug('In getParameterString() =====> subProject = ' + subProject + ' and currentName = ' + currentName);

        // Query for the Subprojects associated with the current Project and gather information about each to include in the sibling parameter
        List<SubProject__c> siblings = [SELECT Id, Name, SubProject_Name__c, Project__c, SubProject_Status__c from SubProject__c WHERE Project__c = :subProject.Project__c];
        String siblingNames = '';
        if(siblings.size() > 0) {
            for(Integer i=0; i<siblings.size(); i++) {
                siblingNames += i > 0 ? ';' : '';
                siblingNames += siblings[i].Name + ' - ' + siblings[i].SubProject_Name__c + '+' + siblings[i].SubProject_Status__c; 
            } 
        }
        System.debug('In getParameterString() =====> siblingNames = ' + siblingNames);

        // Query for the ClientContacts associated with the current Subproject and gather information about each to include in the contactList parameter        
        List<SubProject_Client_Contact__c> clientContacts = [SELECT Client_Contact__r.Lastname, Client_Contact__r.Firstname, Client_Contact__r.Title, Email__c, Phone__c, SubProject__c from SubProject_Client_Contact__c WHERE SubProject__c = :subProject.Id];
        String contactNames = '';
        if(clientContacts.size() > 0) {
            for(Integer i=0; i<clientContacts.size(); i++) {
                contactNames += i > 0 ? ';' : '';
                contactNames += clientContacts[i].Client_Contact__r.Lastname + '+' + clientContacts[i].Client_Contact__r.Firstname  + '+' + clientContacts[i].Email__c + '+' + clientContacts[i].Phone__c + '+' + clientContacts[i].Client_Contact__r.Title;
            } 
        }
        System.debug('In getParameterString() =====> contactNames = ' + contactNames);

        // Query for the CDKContacts associated with the current Subproject and then query the Contacts for each to gather information to include in the resourceList parameter        
        List<SubProject_CDK_Contact__c> cdkContacts = [SELECT CDK_Contact__c, SubProject__c from SubProject_CDK_Contact__c WHERE SubProject__c = :subProject.Id];        
        Set<Id> userIds = new Set<Id>();
        userIds.add(UserInfo.getUserId());
        for (SubProject_CDK_Contact__c cdkContact : cdkContacts) {
            if (cdkContact.CDK_Contact__c != null) {
               userIds.add(cdkContact.CDK_Contact__c);
            }
        }
        List<Contact> resources = [SELECT Id, Vendor_ID__c, User__c, Lastname, Firstname, Email from Contact WHERE User__c in :userIds];        
        Map<Id, Contact> resourcesByUserId = new Map<Id, Contact>();
        for (Contact resource : resources) {
            resourcesByUserId.put(resource.User__c, resource);
        }        

        String resourceNames = '';
        Contact resource;
        if(cdkContacts.size() > 0) {
            for(Integer i=0; i<cdkContacts.size(); i++) {
                resource = resourcesByUserId.get(cdkContacts[i].CDK_Contact__c);
                if (resource != null) {
                    resourceNames += i > 0 ? ';' : '';
                    resourceNames += resource.Vendor_ID__c + '+' + resource.Lastname + '+' + resource.Firstname  + '+' + resource.Email;
                }
            } 
        }
               
        String jsonParams = '{project:\'' + subProject.Project__r.Name + '\',subprojectSelected:\'' + currentName + '\',subprojectList:\'' + siblingNames + '\',contactList:\'' + contactNames + '\',resourceList:\'' + resourceNames + '\'}';
        System.debug('In getParameterString() =====> jsonParams = ' + jsonParams);
        return jsonParams;
    }
}