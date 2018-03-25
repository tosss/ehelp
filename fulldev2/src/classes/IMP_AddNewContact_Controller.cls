/*-------------------

08/27/15  -Venkata Shrivol  -Created
*--------------HISTORY---------------------*
2015-10-20   - venkata.shrivol@cdk.com  - Updated the record type of contact (RQ-05289)
---------------------*/

global with sharing class IMP_AddNewContact_Controller 
{
    public SubProject__c subProject  {get; set;}
    public Contact testContact {get; set;}
    public list<SubProjectSite__c> siteList {get;set;}
    public Id accountId {get; set;}
    public string subProjectId {get;set;}
    public decimal countOfChildSites{get; set;}
    
    public IMP_AddNewContact_Controller()
    {
        subProjectId = '';
        subProject = new SubProject__c();
        testContact = new Contact();
        countOfChildSites = 0;
        Id sId = ApexPages.currentPage().getParameters().get('id'); 
        siteList = new list<SubProjectSite__c>();
        if(sId!=null)
        {
           //subProject = IMP_Project_Utility.retrieveSubProject(sId);
           subProject = [
               select Id, Count_of_SubProject_Sites__c, 
               (select Account__c, Account__r.Name from SubProjectSites__r)
               from SubProject__c where ID =:sId limit 1
           ];
            
            if(subProject!=null)
            {
                subProjectId = subProject.Id;
                countOfChildSites = subProject.Count_of_SubProject_Sites__c;
                if(subProject.SubProjectSites__r.size()>0)
                {
                    siteList = subProject.SubProjectSites__r;
                }
            }
        } 
    }
    
    public list<String> getContactRoles()
    {
        return getPicklistValues('Contact','Role__c');
    }
    public list<String> getProjectRoles()
    {
        return getPicklistValues('SubProject_Client_Contact__c','Role__c');
    }
    public static list<String> getPicklistValues(string objectApiName, string fieldName)
    {
        list<String> optionList = new list<String>();
        
        //get the SObject identified
        Schema.SObjectType identifyObjFromGlobal = Schema.getGlobalDescribe().get(objectApiName);
        
        //describe the sObject to retrieve the fields
        Schema.DescribeSObjectResult sObjDescribe = identifyObjFromGlobal.getDescribe();
        
        //get the fields 
        map<String,Schema.SObjectField> fieldMapOfsObject = sObjDescribe.fields.getMap();
        
        //get the picklist Values
        list<Schema.PicklistEntry> finalPicklistValues = fieldMapOfsObject.get(fieldName).getDescribe().getPickListValues();
        
        for(Schema.PicklistEntry eachVal:finalPicklistValues)
        {
            optionList.add(eachVal.getValue());
        }
            
        return optionList;
    }
    public list<SelectOption> getSiteAccounts()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-- None --'));
        if(siteList!=null && siteList.size()>0)
        {
        	for(SubProjectSite__c site:siteList)
        	{
        		if(site.Account__c!=null)
        		{
        			if(site.Account__r.Name!=null)
        			{
        				options.add(new SelectOption(site.Account__c, site.Account__r.Name));
        			}
        		}
        	 }    
        }       
        //system.debug('allSites- in getter-' + allSites);
        return options;
    }
    
    
    webService static string AddContactAndClientContact(String FirstName, String LastName, String accountId, String contactRole, string projectRole, String Email, String Phone, string SubProjectId)
    {
        Response resp = new Response();
        string jsonResponse = '';
        string customerContactRecordTypeId = '';
        try
        {
            customerContactRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
           
            Contact newContact = new Contact();
            newContact.FirstName = FirstName;
            newContact.LastName = LastName;
            newContact.AccountId = accountId;
            newContact.Role__c = contactRole;
            newContact.Email = Email;
            newContact.Phone = Phone;
            if(customerContactRecordTypeId!='' && customerContactRecordTypeId!=null)
            {
            	newContact.RecordTypeId = customerContactRecordTypeId;    
            }
            
            insert newContact;
            
            
            SubProject_Client_Contact__c newSPCC = new SubProject_Client_Contact__c();
            newSPCC.Client_Contact__c = newContact.Id;
            newSPCC.SubProject__c = SubProjectId;
            newSPCC.Role__c = projectRole;
            insert newSPCC;
            
            resp.Message = 'Success';
            resp.Success = true;   
        }
        catch(Exception ex)
        {
         	system.debug('-----Exception-----'+ex); 
            resp.Message = ex.getMessage();
            resp.Success = false;
        }
        
        jsonResponse = JSON.serialize(resp);
        return jsonResponse;
    }
    global class Response
    {
        global Boolean Success {get;set;}
        global String Message {get;set;}
    }

}