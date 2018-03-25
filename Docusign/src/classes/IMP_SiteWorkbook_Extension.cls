/*------------------------------------------------------------
Author: Kimiko Roberto
Company: Cloud Sherpas       
Description: Discovery Workbook Dashboard extension
Test Class: IMP_SiteWorkbookExtension_Test
History
08/26/14    Kimiko Roberto      Created
09/02/14    Michael Lasala      Completed createWkbook method based on new design flow
09/03/14    Michael Lasala      Added getSources method
09/08/14    Jerick Laurio       Updated createWkbook logic
09/15/14    Alexander Daria     Add last modified
11/20/14    Samuel Oberes       Applied usage of IMP_Project_Utility.buildSelectOption
11/25/14    Kimiko Roberto      Applied usage of IMP_Project_Utility.getSites and .getSources, rather than recreate the methods.
5/13/15     Venkata Shrivol     
------------------------------------------------------------*/
public with sharing class IMP_SiteWorkbook_Extension {
    
    private final SubProject__c mysObject;
    public Project__c project{get;set;}
    public SubProject__c subProject {get;set;}
    public Site_Workbook__c site{get;set;}
    public Site_Workbook__c tempSite{get;set;}
    public Discovery_Workbook_Category__c siteClone{get;set;}
    public List<Site_Workbook__c> siteDetails{get;set;}
    public List<Discovery_Workbook_Category__c> siteWorkbookCategories {get;set;}
    public Map<String,List<Discovery_Workbook_Category__c>> siteWkbkCatMap {get;set;}
    //public List<Project_Checklist__c> projectChkLists{get;set;} 
    //public datetime lastModifiedDate {get;set;}
    //public string lastModifiedBy {get;set;}
    //public DateTime wrkbookLastModifiedDate {get;set;}
    //public string wrkbookLastModifiedBy {get;set;}    
    //public list<Question_Category__c> AllQuestionCategories {get;set;}
    public string SelectedId { get; set; }
    public string lastPage{ get; set; }
    Public Integer noOfRecords{get; set;}
    Public Integer size{get;set;}
    public string subProjectId {get;set;}
    
    //private list<Answer__c> ans {get;set;}
    
    public ApexPages.StandardSetController setCon {
        //this is used to retrieve the category and used as the source of the paging function
        get{
            if(setCon == null){
                size = 5;
                //setCon =new ApexPages.StandardSetController(IMP_Project_Utility.retrieveSiteWorkbooks(project.Id));
                //setCon =new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id, Name,createddate, Site__c, Site__r.Name FROM Site_Workbook__c WHERE Project__c = :project.Id order by Createddate Desc]));
                setCon =new ApexPages.StandardSetController(Database.getQueryLocator([
                			SELECT Id, Name,createddate, Site__c, Site__r.Name 
                			FROM Site_Workbook__c 
                			WHERE SubProject__c = :subProject.Id order by Createddate Desc]));
                if(setCon.getResultSize()>0){
                    setCon.setPageSize(5);
                    noOfRecords = setCon.getResultSize();
                }
            }
            return setCon;
        }set;
    }
    
    public List<Site_Workbook__c> getsiteDetailNew(){
        //Get the value from the standardsetcontroller and return as a List that will be used to populate the dashboard
        List<Site_Workbook__c> accList = new List<Site_Workbook__c>();
        if(setCon.getResultSize()>0){
            for(Site_Workbook__c a : (List<Site_Workbook__c>)setCon.getRecords()){
                accList.add(a);
            }
        }
        return accList;
    }
    
    public pageReference refresh() {
        setCon = null;
        getsiteDetailNew();
        setCon.setPageNumber(1);
        return null;
    }
    // Function for pagination
    public Boolean hasNext {
        get {
            return setCon.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
    
    public Integer pageNumber {
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    public void first() {
        setCon.first();
    }
    
    public void last() {
        setCon.last();
    }
    
    public void previous() {
        setCon.previous();
    }
    
    public void next() {
        setCon.next();
    }
    
    public String backLinkUrl()
    {
        lastPage=  ApexPages.currentPage().getParameters().get('retURL');
        return lastPage;
    }
    
    
    /*------------------------------------------------------------
    Author: Kimiko Roberto
    Company: Cloud Sherpas
    Description: Constructor of the class
    Inputs: None
    Returns: Void
    History
    08/22/14      Kimiko Roberto      Created
    ------------------------------------------------------------*/
    public IMP_SiteWorkbook_Extension (ApexPages.StandardController stdController){
        //this is used to determine where the previous page come from (project or subproject)
        lastPage=ApexPages.currentPage().getParameters().get('id');
        subProjectId=ApexPages.currentPage().getParameters().get('subProject');
        
        if(lastPage == '' || lastPage == null)
        {
            lastPage=ApexPages.currentPage().getParameters().get('id');
        }
        
        if(subProjectId!=null)
        {
        		list<SubProject__c> subProjectList = [select Id, Market__c, Project_Type__c from SubProject__c where Id=:subProjectId limit 1];
        		
        }
        
        //get the details of the project
        this.mysObject = (SubProject__c)stdController.getRecord();
        
        if(mysObject.Id != null)
        {
            //String subQuery = '(SELECT Id, Name, Site__c FROM Site_Workbooks__r)';
            //project = IMP_Project_Utility.retrieveProjectWithSubquery(mysObject.Id, subQuery).get(0);
            //project = [SELECT Id, Name,(Select Id,Name,Site__c From Site_Workbooks__r) FROM Project__c WHERE Id = :mysObject.Id];
            
            subProject = [
            	select Id, Name,Market__c, Project_Type__c, Project__c,SubProject_Name__c,
                (select Id,Name,Site__c from Discovery_Site_Workbooks__r) 
                from SubProject__c where Id =:mysObject.Id
            ];
            
            if(IMP_Project_Utility.checkUserPermission('Site_Workbook__c','PermissionsCreate')){
                site = new Site_Workbook__c();  
                tempSite = new Site_Workbook__c();
            }
            
            if(IMP_Project_Utility.checkUserPermission('Discovery_Workbook_Category__c','PermissionsCreate')){
                siteClone = new Discovery_Workbook_Category__c();
            }
            
            //getChecklistCategoryDetails(mysObject.Id); //  load project's checklist to be displayed to the dashboard page
            //Retrieves Site_Workbook__c record and it's related Discovery_Workbook_Category__c records
            refreshSiteDetails();
            
            //getLastModifiedDateAndName(mysObject.Id);// get checklist Modified BY and Date to be displayed together with the checklist dashboard 
        }
    }
    
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Retrieves Site_Workbook__c record and it's related Discovery_Workbook_Category__c records
    Inputs: None
    Returns: Void
    History
    09/02/14      Michael Lasala      Created
    ------------------------------------------------------------*/
    public void refreshSiteDetails(){        
        //Retrieve Site_Workbook__c
        //siteDetails = IMP_Project_Utility.retrieveSiteWorkbooks(project.Id);
        //siteDetails = [SELECT Id, Name,CreatedDate, Site__c, Site__r.Name FROM Site_Workbook__c WHERE Project__c = :project.Id order by Createddate Desc];
        //Retrieve related Discovery_Workbook_Category__c
        siteDetails = [SELECT Id, Name,CreatedDate, Site__c, Site__r.Name FROM Site_Workbook__c WHERE SubProject__c = :subProject.Id order by Createddate Desc];
        
        if(!siteDetails.isEmpty())
        {
            String subQuery = '(Select LastModifiedDate, LastModifiedById FROM Discovery_Answer_Workbook_Categories__r ORDER BY LastModifiedDate desc limit 1)';
            siteWorkbookCategories = IMP_Project_Utility.retrieveWorkborkCategoryWithSubquery(siteDetails, subQuery);
            /*siteWorkbookCategories = [SELECT Id,
            Name,
            Percent_Complete__c,
            Number_of_Answers__c,
            Question_Category__c,
            Question_Category__r.Name,
            Site_Workbook_category__c,
            Site_Workbook_del__r.Name,
            Count_of_Questions__c,
            (Select LastModifiedDate, LastModifiedById FROM Discovery_Answer_Workbook_Categories__r ORDER BY LastModifiedDate desc LIMIT 1)
            FROM Discovery_Workbook_Category__c
            WHERE Site_Workbook_category__c IN :siteDetails ORDER BY Question_Category__r.Name];*/
            siteWkbkCatMap = new Map<String,List<Discovery_Workbook_Category__c>>();
            system.debug('--------siteWorkbookCategories-----'+siteWorkbookCategories);
            if(!siteWorkbookCategories.isEmpty())
            {
                for(Discovery_Workbook_Category__c disoveryWkbookCategory : siteWorkbookCategories)
                {
                    //Only iterate over categories with questions
                    if(disoveryWkbookCategory.Count_of_Questions__c > 0)
                    {
                        if(siteWkbkCatMap.containsKey(disoveryWkbookCategory.Site_Workbook__c))
                        {
                            List<Discovery_Workbook_Category__c> discoveryWkbookCatTempList = siteWkbkCatMap.get(disoveryWkbookCategory.Site_Workbook__c);
                            discoveryWkbookCatTempList.add(disoveryWkbookCategory);
                            siteWkbkCatMap.put(disoveryWkbookCategory.Site_Workbook__c, discoveryWkbookCatTempList);
                        } else 
                        {
                            List<Discovery_Workbook_Category__c > discoveryWkbookCatTempList = new List<Discovery_Workbook_Category__c >();
                            discoveryWkbookCatTempList.add(disoveryWkbookCategory);
                            siteWkbkCatMap.put(disoveryWkbookCategory.Site_Workbook__c, discoveryWkbookCatTempList);
                        }
                    }
                }
            }
        }
        refresh();
    }
    
    /*------------------------------------------------------------
    Author: Kimiko Roberto
    Company: Cloud Sherpas
    Description: Create Workbook function
    Inputs: None
    Returns: Void
    History
    09/02/14      Michael Lasala      Added logic based on latest design flow
    09/08/14      Jerick Laurio       Updated create site workbook logic
    ------------------------------------------------------------*/
    public void createWkbook(){
       
        
        List<Discovery_Workbook_Category__c> discoveryWkbkCategoryForInsertList = new List<Discovery_Workbook_Category__c>();
        List<Discovery_Answer_Workbook_Category__c> discoveryAnswerWkbkCategoryForInsertList = new list<Discovery_Answer_Workbook_Category__c>();
        map<Id, set<Id>> categorytToQuestionMap = new map<Id, set<Id>>();
        List<Answer__c> discoveryAnswersForInsertList = new List<Answer__c>();
        set<Id> discoveryProductIds = new set<Id>();
        set<Id> finalQuestionSet = new set<Id>();
        set<Id> discoveryquestionIds = new set<Id>();
        Map<Id, Discovery_Workbook_Category__c> wkbookCategoryViaQuestionCategoryMap = new Map<Id, Discovery_Workbook_Category__c>();
        map<Id, Id> answerToQuestionMap = new map<Id,Id>();
        
        List<Question__c> questionsList = new List<Question__c>();
        system.debug('tempSite---------'+tempSite);
        if(subProject!=null){
            
            if(tempSite!=null && tempSite.Site__c!=null)
            {
                IMP_CloneWorkbook_Helper cloneWorkbook = new IMP_CloneWorkbook_Helper();
                
                if(!cloneWorkbook.checkIfSiteContainsWorkbook(subProject.Id, tempSite.Site__c))
                {
                    //1. create Site_Workbook__c(Discovery Site Workbook) record using:
                    //       Site__c = site lookup field id
                    //       Project__c = project.Id;
                    Site_Workbook__c siteWorkBook = new Site_Workbook__c();
                    siteWorkBook.Project__c = subProject.Project__c;
                    siteWorkBook.SubProject__c = subProject.Id;
                    siteWorkBook.Site__c = tempSite.Site__c;
                    
                    SubProjectSite__c selectedSite = new SubProjectSite__c();
                    SubProject__c selectedSubProject;
                    list<SubProject__c> selectedSubProjects = [select Id, Market__c, Project_Type__c, (select Id, Account__c from SubProjectSites__r) from SubProject__c where Id =:subProject.Id limit 1];
                    if(!selectedSubProjects.isEmpty()){
                    	selectedSubProject = selectedSubProjects[0];
                    }
                    for(SubProjectSite__c sbs:selectedSubProject.SubProjectSites__r){
                    	if(sbs.Account__c==tempSite.Site__c){
                    		selectedSite=sbs;
                    	}
                    }
                    
                    //system.debug('----SubProjectSite---'+selectedSite.Id);
                    
                    list<Site_Product__c> siteProductList = [select Id, Product__c from Site_Product__c where SubProjectSite__c =:selectedSite.Id];
                    for(Site_Product__c spd: siteProductList) {
                    	discoveryProductIds.add(spd.Product__c);
                    }
                    
                    system.debug('----discoveryProductIds---'+discoveryProductIds);
                    list<Discovery_Question_Product__c> questionsWithProducts = [
																	SELECT ID, Question__c, Product__r.Solution__r.Question_Category__c
																	FROM Discovery_Question_Product__c 
																	WHERE Question__r.Active__c =  true
																	and (
																	    (Question__r.Market__c includes(:selectedSubProject.Market__c) and Question__r.Project_Type__c includes (:selectedSubProject.Project_Type__c)) 
																	    and 
																	    (Product__c IN :discoveryProductIds)
																	    )
																  ];
		            system.debug('-------questionsWithProducts---------'+questionsWithProducts.size());
		            
		            list<Discovery_Question_Category__c> questionsWithNoProducts;
		            
		            system.debug('-------subProject.Id----------'+selectedSubProject.Id);
	            	system.debug('-------subProject.Market__c----------'+selectedSubProject.Market__c);
	            	system.debug('--------subProject.Project_Type__c----------'+selectedSubProject.Project_Type__c);
	            			  
	            	questionsWithNoProducts = [select Discovery_Question__c, Question_Category__c from Discovery_Question_Category__c where Discovery_Question__r.Active__c =  true and 
	            			  (Discovery_Question__r.Market__c includes(:selectedSubProject.Market__c) and Discovery_Question__r.Project_Type__c includes (:selectedSubProject.Project_Type__c))];
	            											   
	            	system.debug('-------questionsWithNoProducts---------'+questionsWithNoProducts.size());
					
					if(questionsWithProducts!=null && !questionsWithProducts.isEmpty())
					{
						for(Discovery_Question_Product__c dqp: questionsWithProducts)
	                    {
	                    	set<Id> tempSet = categorytToQuestionMap.containsKey(dqp.Product__r.Solution__r.Question_Category__c) ? categorytToQuestionMap.get(dqp.Product__r.Solution__r.Question_Category__c) : new set<Id>();
	                    	tempSet.add(dqp.Question__c);
	                    	categorytToQuestionMap.put(dqp.Product__r.Solution__r.Question_Category__c, tempSet);	
	                    }
					}
                    if(questionsWithNoProducts!=null && !questionsWithNoProducts.isEmpty())
                    {
                    	for(Discovery_Question_Category__c dqc: questionsWithNoProducts)
	                    {
	                    	set<Id> tempSet = categorytToQuestionMap.containsKey(dqc.Question_Category__c) ? categorytToQuestionMap.get(dqc.Question_Category__c) : new set<Id>();
	                    	tempSet.add(dqc.Discovery_Question__c);
	                    	categorytToQuestionMap.put(dqc.Question_Category__c, tempSet);	
	                    }
                    }
                    
                    system.debug('----categorytToQuestionMap----'+categorytToQuestionMap);
                    if(!categorytToQuestionMap.keySet().isEmpty())
                    { 
                        try
                        {
                            insert siteWorkBook;
                        } catch (DmlException e){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                        }
                        for(Id qId: categorytToQuestionMap.keySet())
                        {
                            Discovery_Workbook_Category__c createdSiteWkbookCategory = new Discovery_Workbook_Category__c();
                            createdSiteWkbookCategory.Site_Workbook__c = siteWorkBook.Id;
                            createdSiteWkbookCategory.Question_Category__c = qId; //questionCategory.Id;
                            createdSiteWkbookCategory.Count_of_Questions__c = categorytToQuestionMap.get(qId).size();
                            //createdSiteWkbookCategory.Project__c = siteWorkBook.Project__c;
                            discoveryWkbkCategoryForInsertList.add(createdSiteWkbookCategory);
                        }
                    }
                    else
                    {
                       ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, 'No Questions retrieved on selected Project Type, Market and SiteProducts'));
                    }
                    
                    if(discoveryWkbkCategoryForInsertList.size()>0)
                    {
                        try
                        {
                            insert discoveryWkbkCategoryForInsertList;
                        } catch (DmlException e){
                            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                        }
                        for(Discovery_Workbook_Category__c wkbookCategory : discoveryWkbkCategoryForInsertList)
                        {
                            if(!wkbookCategoryViaQuestionCategoryMap.containsKey(wkbookCategory.Question_Category__c)){
                                wkbookCategoryViaQuestionCategoryMap.put(wkbookCategory.Question_Category__c, wkbookCategory);
                            }
                        }
                        for(Id qcId:categorytToQuestionMap.keySet())
                        {
                        	for(Id qId:categorytToQuestionMap.get(qcId))
                        	{
                        		if(!finalQuestionSet.contains(qId))
                        		{
                                    Answer__c createdAnswer = new Answer__c();
                                    //createdAnswer.Discovery_Workbook_Category__c = wkbookCategoryViaQuestionCategoryMap.get(qcId).Id;
                                    createdAnswer.Discovery_Site_Workbook__c = wkbookCategoryViaQuestionCategoryMap.get(qcId).Site_Workbook__c;
                                    createdAnswer.Question__c = qId;
                                    finalQuestionSet.add(qId);
                                    discoveryAnswersForInsertList.add(createdAnswer);
                            	}
                        	}
                         }
                        
                        if(discoveryAnswersForInsertList.size()>0)
                        {
                            try
                            {
                                insert discoveryAnswersForInsertList;
                            
                                Account acct = IMP_Project_Utility.retrieveAccount(tempSite.site__c);
                                //Account acct = [SELECT id, Name from Account where ( id =:tempSite.site__c) ];
                                if(acct.Name != null)
                                {
                                    Apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Info,'Workbook for Site ' + acct.Name + ' has been created' );
                                    Apexpages.addmessage(msg);  
                                }
                            } 
                            catch (DmlException e)
                            {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                            }
                            for(Answer__c ans:discoveryAnswersForInsertList)
                            {
                            	answerToQuestionMap.put(ans.Question__c, ans.Id);
                            }
                            
                             system.debug('---------answerToQuestionMap-------'+answerToQuestionMap);
                            for(Id qcId: categorytToQuestionMap.keySet())
                            {
                            	for(Id qId:categorytToQuestionMap.get(qcId))
                            	{
                            		system.debug('------Question Id'+qId);
                            		Discovery_Answer_Workbook_Category__c createdAnswerWBCategory = new Discovery_Answer_Workbook_Category__c();
                            		createdAnswerWBCategory.Answer__c = answerToQuestionMap.get(qId);
                            		createdAnswerWBCategory.Discovery_Workbook_Category__c = wkbookCategoryViaQuestionCategoryMap.get(qcId).Id;
                            		discoveryAnswerWkbkCategoryForInsertList.add(createdAnswerWBCategory);
                               	}
                            }
                            if(discoveryAnswerWkbkCategoryForInsertList.size()> 0)
                            {
                            	try
                            	{
                            		insert discoveryAnswerWkbkCategoryForInsertList;
                            	}
                            	catch(DmlException e)
                            	{
                            		ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                            	}
                            } 
                        }
                    }//discoveryWkbkCategoryForInsertList size check
                } 
                else {
                    Account acct = IMP_Project_Utility.retrieveAccount(tempSite.site__c);
                    //Account acct = [SELECT id, Name from Account where ( id =:tempSite.site__c) ];
                    if(acct.Name != null){
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Workbook for Site ' + acct.Name +' already exists');
                        ApexPages.addMessage(errMsg);
                    }
                }
                ApexPages.getMessages().clear();
            }
            else{
                
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'No Site record found. Please select a Site.');
                ApexPages.addMessage(errMsg);
            }
        }
        else{
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'No SubProject record found.');
            ApexPages.addMessage(errMsg);
        }
        
        //Refresh project details
        refreshSiteDetails();
    }
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Method of calling the clone class
    Inputs: None
    Returns: void
    History
    08/28/14      Rey Austral        Created
    09/15/14      Alexander Daria  Added validation message
    ------------------------------------------------------------*/
    /*public void cloneWkbook() {
        if (siteClone.Site_Workbook__c!= null) 
        {
            if (site.Site__c != null) 
            {                
                IMP_CloneWorkbook_Helper cloneWorkbook = new IMP_CloneWorkbook_Helper();
                //execute the clone function , the clone function will return an error message if the site already contain a workbook
                string ErrMessage= cloneWorkbook.cloneWorkBook(mysObject.Id,site.Site__c,siteClone.Site_Workbook__c);
                
                if(ErrMessage!='')
                {
                    //Get the name of the site to be able to use in the error message
                    Account acct = IMP_Project_Utility.retrieveAccount(site.site__c);
                    //Account acct = [SELECT id, Name from Account where ( id =:site.Site__c) ];
                    if(acct.Name != null){
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Workbook for Site ' + acct.Name +' already exists');
                        ApexPages.addMessage(errMsg);
                    }
                }
                else
                {
                    //Get the name of the site to be able to use in the error message
                    Account acct = IMP_Project_Utility.retrieveAccount(site.site__c);
                    //Account acct = [SELECT id, Name from Account where ( id =:site.Site__c) ];
                    //ApexPages.getMessages().clear();
                    if(acct.Name != null){
                        ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Info, 'Workbook for Site ' + acct.Name +' has been created');
                        ApexPages.addMessage(errMsg);
                    }
                    
                }
                //Refresh project details, to reflect the changes 
                refreshSiteDetails();
            }else
            {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'No Target Site record found. Please select a Target Site');
                ApexPages.addMessage(errMsg);
                
            }
        }
        else 
        {                   
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'No Source Site record found. Please select a Source Site');
            ApexPages.addMessage(errMsg);
            
        }
    }
    */
    /*------------------------------------------------------------
    Author: Michael Lasala
    Company: Cloud Sherpas
    Description: Retrieve sources based on assigned project to populate the Source Site Dropdown
    Inputs: None
    Returns: List<SelectOption>
    History
    09/02/14      Michael Lasala      Added logic based on latest design flow
    ------------------------------------------------------------*/
   /* public List<SelectOption> getSources() {
        
        return IMP_Project_Utility.getSources(project.Id);
    }*/
    
    /*------------------------------------------------------------
    Author: Kimiko Roberto
    Company: Cloud Sherpas
    Description: Gets all the existing workbooks in a Project.
    Inputs: None
    Returns: List<SelectOption>
    History
    11/11/14      Kimiko Roberto      Created
    ------------------------------------------------------------*/
    
    public List<SelectOption> getSites() {
        //return IMP_Project_Utility.getSites(project.Id);
        Map<String, String> optionsMap = new Map<String, String>();
        optionsMap.put('', '--None--');
        
        List<SubProjectSite__c> allSites = [SELECT Id, Account__c, Account__r.Name, SubProject__c, Project__c FROM SubProjectSite__c WHERE SubProject__c = :subProject.Id];
        //List<Site_Workbook__c> relatedSites = [SELECT Id, Site__r.Name FROM Site_Workbook__c WHERE Project__c = :project.Id];
        system.Debug('**allSites : '+allSites + '**selectedProject.SubProject__c' + subProject.Id);
        Set<Account> allSitesSet = new Set<Account>();
        for(SubProjectSite__c sps: allSites){
            allSitesSet.add(sps.Account__r);
        }

        if(allSitesSet != null && !allSitesSet.isEmpty()){
            for(Account a : allSitesSet){
                if (a != null ) {                                       
                    optionsMap.put(a.Id, a.Name);
                }
            }
        }
        return IMP_Project_Utility.buildSelectOption(optionsMap, false);
    }
    
    
    /*------------------------------------------------------------
    Author: Alexander Daria
    Company: Cloud Sherpas
    Description: Retrieve checklist answer based on assigned project to populate the checklist dashboard
    Inputs: None
    Returns: void
    History
    09/15/14      Alexander Daria        Created
    ------------------------------------------------------------*/ 
    /*public void getChecklistCategoryDetails (Id currProjId)
    {
        projectChkLists = IMP_Project_Utility.retrieveProjectCheckList(currProjId);
        //projectChkLists = [SELECT  Item_Category__r.Name,Number_of_Items_Collected__c,Number_of_Items_Remaining__c  FROM Project_Checklist__c  where project__c=: currProjId];
    }*/
    
    /*------------------------------------------------------------
    Author: Alexander Daria
    Company: Cloud Sherpas
    Description: Retrieve the last modified date and name for the checklist
    Inputs: None
    Returns: void
    History
    09/15/14      Alexander Daria        Created
    ------------------------------------------------------------*/ 
    /*public void getLastModifiedDateAndName(Id currprojId)
    {
        List<Project_Checklist__c> checklists = IMP_Project_Utility.retrieveProjectCheckList(currprojId);
        //List<Project_Checklist__c> checklists = [SELECT Name FROM Project_Checklist__c WHERE Project__c = :currprojId LIMIT 1];
        if(!checklists.isEmpty()){
            List<Checklist_Answer__c> ans = IMP_Project_Utility.retrieveChecklistAnswerBySet(checklists[0].Id, null, 'LastModifiedDate', false, 1);
            //List<Checklist_Answer__c> ans =  [SELECT LastModifiedDate,LastModifiedById FROM Checklist_Answer__c where Project_Checklist__c = :checklists[0].Id order by LastModifiedDate desc  Limit 1];
            List<String> userIds = new List<String>();
            
            if(!ans.isEmpty()){
                for(Checklist_Answer__c answers : ans)
                {
                    lastModifiedDate =  answers.LastModifiedDate;
                    userIds.add(answers.LastModifiedById);
                }
            }
            
            List<User> users = IMP_Project_Utility.retrieveUserBySet(null, userIds);
            
            if(!users.isEmpty()){
            //List<User> users = [Select Name From User where Id in : userIds];
                for(User lastUser : users)
                {
                    lastModifiedBy = lastUser.Name;
                }
            }
        }
    }    
    */
    /*------------------------------------------------------------
    Author: Alexander Daria
    Company: Cloud Sherpas
    Description: Delete selected site in the workbook
    Inputs: None
    Returns:  None
    History
    09/15/14      Alexander Daria        Created
    ------------------------------------------------------------*/ 
    public void deleteSiteWorkbook()
    {
        // if for any reason we are missing the reference 
        if (SelectedId == null) {
            
            return;
        }
        
        // find the account record within the collection
        List<Site_Workbook__c> ListTobeDeleted = new List<Site_Workbook__c>();
        List<Discovery_Workbook_Category__c> siteWbCategories = new List<Discovery_Workbook_Category__c>();
        list<Discovery_Answer_Workbook_Category__c> ansWkbkCategories = new list<Discovery_Answer_Workbook_Category__c>();
        list<Answer__c> answersTobeDeleted = new list<Answer__c>();
        set<Id> siteWorkbookSet = new set<Id>();
        set<Id> siteWbCategorySet = new set<Id>();
        set<Id> answerIds = new set<Id>();
        if(!siteDetails.isEmpty())
        {   
            for(Site_Workbook__c s : siteDetails )
                if (s.Id == SelectedId) {
                    ListTobeDeleted.add(s);
                    siteWorkbookSet.add(s.Id);
                    
                }
            String subQuery = '(Select Id,Answer__c,LastModifiedDate, LastModifiedById FROM Discovery_Answer_Workbook_Categories__r ORDER BY LastModifiedDate)';
            siteWbCategories = IMP_Project_Utility.retrieveWorkborkCategoryWithSubquery(ListTobeDeleted, subQuery);
            answersTobeDeleted = [select Id from Answer__c where Discovery_Site_Workbook__c IN:siteWorkbookSet];
            //siteWbCategories = [select Id from Discovery_Workbook_Category__c where Site_Workbook__c IN:siteWorkbookSet];
            
        }
        //if record found delete it
        if (!siteWbCategories.isEmpty()) 
        {
        	for(Discovery_Workbook_Category__c dwc:siteWbCategories)
        	{
        		siteWbCategorySet.add(dwc.Id);
        		ansWkbkCategories.addAll(dwc.Discovery_Answer_Workbook_Categories__r);	
        	}
        	//ansWkbkCategories = [select Id from Discovery_Answer_Workbook_Category__c where Discovery_Workbook_Category__c
        						//IN:siteWbCategorySet];
        	if(!ansWkbkCategories.isEmpty())
        	{
        		try { delete ansWkbkCategories; }
        		catch (DmlException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
            	}
        	}
        	
            try{
                Delete siteWbCategories;
            } catch (DmlException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
            }
            
        }
        if(!answersTobeDeleted.isEmpty())
        {
        	try{ delete answersTobeDeleted;}
        	catch(Exception e)
        	{
        		ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
        	}
        }
        if (!ListTobeDeleted.isEmpty()) {
            try{
               
                Delete ListTobeDeleted;
            } catch (DmlException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
            }
            
        }
        
        //refresh the data
        refreshSiteDetails();
    }
    
    /*Public PageReference ViewChecklist()
    {
        PageReference reference= new PageReference('/apex/IMP_checklistpage_2?id=' + project.Id + '&view=true');
        reference.setRedirect(true);
        
        system.Debug('**reference'+reference);
        system.Debug('**reference'+project.Id);
        return reference;
    }
    
    Public PageReference EditChecklist()
    {
        PageReference reference= new PageReference('/apex/IMP_checklistpage_2?id=' + project.Id);
        reference.setRedirect(true);
        return reference;
    }*/
}