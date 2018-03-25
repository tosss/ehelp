/*------------------------------------------------------------
Author: Hemanth Kesapragada
Description: This class is the controller for Interview Visualforce Component.
This displays Interviewers and Interviewees in a pageblock table.
This page also allows to add Interviewees and saves Interviewers and Interviewees included.
*---------------------------History---------------------------------*
2015-07-10 	 - venkata.shrivol@cdk.com  - Modified fetchInterviewers Method
2015-10-20   - venkata.shrivol@cdk.com  - Updated the record type of contact (RQ-05289)
2016-12-05   - venkata.shrivol@cdk.com  - commented this class as this is no longer required.
------------------------------------------------------------*/
public class IMP_Interview_Controller 
{
    /*-----------------------------------------------------------
     Class Variables
    *-----------------------------------------------------------*/
   /* private Boolean initialized=false;
    public String siteWorkbookCategoryId{get;set;}
    public String questionCategoryId {get;set;}
    public String subProjectId{get;set;}
    public Discovery_Workbook_Interviewee__c captureInterviewee  {get;set;}  
    public SubProject_Client_Contact__c subProjectClientContact {get;set;}
    public Map<String, Discovery_Workbook_Interviewee__c> fetchIntervieweeMap;
    public List<User> fetchInterviewerList;
    private String addChosenInterviewee = '';
    private String chosenInterviewee='';
    public Boolean isEditMode { get; set; }
    public String selectedTypeOfContact {get;set;}
    public List<selectOption> clientContactsOptions{get;set;}
    public List<String> selectedClientContacts {get;set;}
    public static FINAL String CONTACT_TYPE = 'contacts';
    public static FINAL String CLIENT_CONTACT_TYPE = 'clientContacts';
    public boolean newContactFlag {get;set;}
    
    /*-----------------------------------------------------------
     Getters and Setters
    *-----------------------------------------------------------
    public void setChosenInterviewee(String n) { chosenInterviewee = n; }
    public String getChosenInterviewee() { return chosenInterviewee; } 
    public void setAddChosenInterviewee(String n) { addChosenInterviewee = n; }
    public String getAddChosenInterviewee() { return addChosenInterviewee; }    
    
    public Contact contactObj {
        get
        {
            if(contactObj==null)
            {
                contactObj = new Contact();
            }
            return contactObj;
        }
        set;
    }
    
    public Map<String, Discovery_Workbook_Interviewee__c> intervieweeMap
    {
        get
        {
            if(initialized==false)
            {
                fetchInterviewees();
            }
            return fetchIntervieweeMap;
        }
        set
        {
            fetchIntervieweeMap=value;
        }
    }
    
    public List<User> interviewerList
    {
        get
        {
            if(initialized==false)
            {
                fetchInterviewers();
                initialized=true;
            }
            return fetchInterviewerList;
        }    
        set
        {
            fetchInterviewerList=value;
        }
    }
    
    public Discovery_Workbook_Category__c discWrkSiteCategory 
    {
        get
        {
            discWrkSiteCategory = [
                SELECT Id,
                Contact_Being_Interviewed__c,
                Interviewer__c,
                Question_Category__c,
                Question_Category__r.Name,
                Site_Workbook__c,
                Site_Workbook__r.Project__c,
                Site_Workbook__r.Project__r.Name,
                Site_Workbook__r.Name,
                Site_Workbook__r.Site__c,
                Site_Workbook__r.Site__r.Name
                FROM Discovery_Workbook_Category__c
                WHERE Id = :siteWorkbookCategoryId
            ];
            
            return discWrkSiteCategory;
        }
        set;
    }
    
    //-- Constructor --
    public IMP_Interview_Controller()
    {
        captureInterviewee = new Discovery_Workbook_Interviewee__c();
        subProjectClientContact = new SubProject_Client_Contact__c();
        newContactFlag = false;
    }
    
    /*---------------------------------------------------------------
      This method fetches Interviewees from Discover_Workbook_Interview Object
      and creates a map with ID as key and Object as value.
      ---------------------------------------------------------------
    public void fetchInterviewees()
    {
        try
        {
            System.debug('$$ siteWorkbookCategoryId in fetch '+siteWorkbookCategoryId);
            fetchIntervieweeMap=new Map<String,Discovery_Workbook_Interviewee__c>();
            
            List<Discovery_Workbook_Interviewee__c> intervieweeList = [
                SELECT Id,Discovery_Workbook_Category__c, Interviewee__c,Interviewee__r.Name 
                FROM Discovery_Workbook_Interviewee__c 
                WHERE Discovery_Workbook_Category__c = : siteWorkbookCategoryId
            ];
            
            if(!intervieweeList.isEmpty())
            {
                for(Discovery_Workbook_Interviewee__c discIntervieweeObj: intervieweeList )
                {                
                    fetchIntervieweeMap.put(discIntervieweeObj.Id, discIntervieweeObj);            
                }
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    /*---------------------------------------------------------------
    	This method fetches list of Interviewers  - Unique list of users
    	based on the LastModifiedField on Discovery_Answer_Workbook_Category__c object
    ----------------------------------------------------------------
    public void fetchInterviewers()
    {
        try
        {
            fetchInterviewerList=new List<User>();
            Set<Id> userIds = new Set<Id>();
            
            //check the latest modified date
            List<Discovery_Answer_Workbook_Category__c> ansWkbkCategories;
            if(Test.isRunningTest())
            {
                ansWkbkCategories=[
                    SELECT LastModifiedDate,LastModifiedById FROM Discovery_Answer_Workbook_Category__c 
                    where Discovery_Workbook_Category__c = :siteWorkbookCategoryId 
                    and Answer_Completed__c=true
                    order by LastModifiedDate desc
                ];  
            }
            else
            {
                ansWkbkCategories=[
                    SELECT LastModifiedDate,LastModifiedById FROM Discovery_Answer_Workbook_Category__c 
                    where Discovery_Workbook_Category__c = :siteWorkbookCategoryId 
                    and Answer_Completed__c=true
                    order by LastModifiedDate desc
                ];
            }
            
            if(!ansWkbkCategories.isEmpty()) 
            {
                for(Discovery_Answer_Workbook_Category__c ansWkbkCat : ansWkbkCategories)
                {
                    userIds.add(ansWkbkCat.LastModifiedById);
                }
            }
            
            fetchInterviewerList= [Select Name From User where Id in : userIds];
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    /*---------------------------------------------------------------
    	This method allows to add Interviewee from Contacts
    	or SubProject client contacts object
    ---------------------------------------------------------------
    public void addInterviewee()
    {   
        try
        {
            ApexPages.currentPage().getParameters().put('message','');
            List<Discovery_Workbook_Interviewee__c> addIntervieweeList = new List<Discovery_Workbook_Interviewee__c>();
            if(selectedTypeOfContact.equals(CONTACT_TYPE))
            {
                //newContactFlag set to true when new contact is created
                if(newContactFlag==false)
                {
                    addChosenInterviewee = captureInterviewee.Interviewee__c;
                }
                
                if(addChosenInterviewee != '' && addChosenInterviewee != null)
                {
                    List<Discovery_Workbook_Interviewee__c> testInterviewee = [
                        SELECT Id,Interviewee__c 
                        FROM Discovery_Workbook_Interviewee__c 
                        WHERE Interviewee__c = : addChosenInterviewee 
                        And Discovery_Workbook_Category__c = :siteWorkbookCategoryId
                    ];
                    
                    //validate if the interviewee is already exist , if exist do not allow to insert that record
                    if(testInterviewee.isEmpty())
                    {
                        Discovery_Workbook_Interviewee__c newInterviewee = new Discovery_Workbook_Interviewee__c(
                            Discovery_Workbook_Category__c = siteWorkbookCategoryId,
                            Interviewee__c = addChosenInterviewee
                        );
                        
                        addIntervieweeList.add(newInterviewee);                                                                                         
                    } 
                    captureInterviewee = new Discovery_Workbook_Interviewee__c();
                }  
            }
            else if(selectedTypeOfContact.equals(CLIENT_CONTACT_TYPE))
            {
                if(selectedClientContacts!= null)
                {
                    List<Discovery_Workbook_Interviewee__c> testInterviewee = [
                        SELECT Id,Interviewee__c 
                        FROM Discovery_Workbook_Interviewee__c 
                        WHERE Interviewee__c in :selectedClientContacts
                        And Discovery_Workbook_Category__c = :siteWorkbookCategoryId
                    ];
                    
                    boolean flag = false;
                    if(testInterviewee.isEmpty())
                    {
                        flag=true;
                    }
                    else if(testInterviewee.size()!=selectedClientContacts.size())
                    {
                        flag = true;
                        for(Discovery_Workbook_Interviewee__c intervieweObj : testInterviewee) 
                        {
                            for(Integer i=0;i<selectedClientContacts.size();i++)
                            {
                                if(intervieweObj.Interviewee__c==selectedClientContacts.get(i))
                                {
                                    selectedClientContacts.remove(i);
                                }
                            }
                        }
                    }
                    
                    if(flag)
                    {
                        Discovery_Workbook_Interviewee__c newInterviewee;
                        for(String contactId : selectedClientContacts)
                        {
                            newInterviewee = new Discovery_Workbook_Interviewee__c(
                                Discovery_Workbook_Category__c = siteWorkbookCategoryId,
                                Interviewee__c = contactId
                            );
                            
                            addIntervieweeList.add(newInterviewee);
                        }
                    }
                    selectedClientContacts.clear();
                }  
            }
            
            if(!addIntervieweeList.isEmpty())
            {
                insert addIntervieweeList;
                fetchInterviewees();
            } 
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    /*---------------------------------------------------------------
    	This method allows to remove specific Interviewee
    ---------------------------------------------------------------
    public void removeInterviewee()
    {
        try
        {
            ApexPages.currentPage().getParameters().put('message','');
            fetchIntervieweeMap.remove(chosenInterviewee);
            
            Discovery_Workbook_Interviewee__c intervieweeToBeRemoved = [
                SELECT Id 
                FROM Discovery_Workbook_Interviewee__c 
                WHERE Id =: chosenInterviewee
            ];
            
            delete intervieweeToBeRemoved;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    /*---------------------------------------------------------------
    	This method populates multiple Select list 
    	when 'Add From SubProject Client Contacts' is selected
    ---------------------------------------------------------------
    public void renderAction()
    {
        ApexPages.currentPage().getParameters().put('message','');
        if(selectedTypeOfContact.equals('clientContacts'))
        {
            fetchClientContacts();
        }
    }
    
    /*---------------------------------------------------------------
    	This method populates select list with subproject client contact values 
    	based on the subproject Id passed.
    ----------------------------------------------------------------
    public List<SelectOption> fetchClientContacts()
    {
        try
        {
            clientContactsOptions = new List<SelectOption>();
            
            List<SubProject_Client_Contact__c> clientContactsList  = [
                SELECT Client_Contact__c,Client_Contact__r.Name ,Client_Contact__r.FirstName
                FROM SubProject_Client_Contact__c 
                WHERE SubProject__c =:subProjectId
            ];
            
            if(!clientContactsList.isEmpty())
            {
                for(SubProject_Client_Contact__c clientContactObj : clientContactsList)
                {
                    clientContactsOptions.add(
                        new SelectOption(clientContactObj.Client_Contact__c, clientContactObj.Client_Contact__r.Name)
                    );
                }
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
        
        return clientContactsOptions;
    }
   
    /*---------------------------------------------------------------
    	This method creates new contact and redirects to the main page
    ----------------------------------------------------------------
    public PageReference saveNewContact()
    {
        PageReference pageRef = new PageReference('/apex/imp_siteworkbookcategory?id='+siteWorkbookCategoryId+'&subProject='+subProjectId);
        pageRef.setRedirect(true);
        string customerContactRecordTypeId = '';
        
        try
        {
        	customerContactRecordTypeId = ALL_UtilitiesDescribe.getRecordTypeIdOfAnySObject('Contact','Customer Contact');
            if(contactObj!=null)
            {
                contactObj.AccountId = discWrkSiteCategory.Site_Workbook__r.Site__c;
                if(customerContactRecordTypeId!='' && customerContactRecordTypeId!=null)
                {
                	contactObj.RecordTypeId = customerContactRecordTypeId;    
                }
                insert contactObj;
                
                Discovery_Workbook_Category__c wrkCategory = [
                    select id,Contact_Being_Interviewed__c 
                    from Discovery_Workbook_Category__c 
                    where id=:siteWorkbookCategoryId
                ];
                
                if(wrkCategory != null)
                {
                    wrkCategory.Contact_Being_Interviewed__c = contactObj.Id;
                    update wrkCategory;
                }
                
                newContactFlag = true;
                addChosenInterviewee = contactObj.Id;
                selectedTypeOfContact = CONTACT_TYPE;
                
                addInterviewee();
                
                pageRef.getParameters().put('message','New contact created successfully');
            }  
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
            pageRef = new PageReference('/apex/imp_siteworkbookcategory?id='+siteWorkbookCategoryId+'&subProject='+subProjectId);
            return pageRef;
        }
        return pageRef;
    }*/
}