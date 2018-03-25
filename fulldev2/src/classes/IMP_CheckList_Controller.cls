/*------------------------------------------------------------
Author: Alexander Daria
Company: Cloud Sherpas       
Description: This class is used as an extension of IMP_ChecklistPage page.
             It supports both view and edit modes to examine and update the pre-discovery checklist, respectively.
Test Class: IMP_CheckList_Controller_Test
History
08/26/14   Alexander Daria         Created

------------------------------------------------------------*/
public class IMP_CheckList_Controller{  
    public list<Checklist_Category__c> ChkList{get;set;}
    public list<CategoryDetails> categoryDetails{get;set;}
    public List<CategoryLinks> catLinks { get; set; }
    public Project__c currProject {get;set;}
    public DateTime lastModifiedDate {get;set;}
    public string lastModifiedBy {get;set;}
    public Boolean isEditMode { get; set; }
    
    public IMP_CheckList_Controller (ApexPages.StandardController controller) {
        if(ApexPages.currentPage().getParameters().get('view') != null && ApexPages.currentPage().getParameters().get('view') != '')
        {
            isEditMode = false;
        }else
        {
            isEditMode = true;
        }
        
        //init all variables
        categoryDetails = new list<CategoryDetails>();
        ChkList = new list<Checklist_Category__c>();
        
        //get the details of the project
        currProject = (Project__c) controller.getRecord();
        if(currProject!=null){
            currProject = IMP_Project_Utility.retrieveProject(currProject.Id, null);
            //currProject = [SELECT Id, Name FROM Project__c WHERE Id =: currProject.Id];
        }
        else{          
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'No Project Id Found');
            ApexPages.addMessage(errMsg);
            return;
        }
        //get the last person who modified the checklist answer and when did the person modified it
        getLastModifiedDateAndName(currProject.Id);
        
        //get checklist of the project 
        List<Project_Checklist__c> projectChkLists = IMP_Project_Utility.retrieveProjectCheckList(currProject.Id);
        //List<Project_Checklist__c> projectChkLists = [Select Id, Project__c, Item_Category__c FROM Project_Checklist__c WHERE Project__c=: currProject.Id];
        Set<Id> projectChecklistIds = new Set<Id>();
        Set<Id> categoryIds = new Set<Id>();
        
        //get the id to be used in the sosql for getting the checklist items and answer
        for(Project_Checklist__c item : projectChkLists){
            projectChecklistIds.add(item.Id);
            categoryIds.add(item.Item_Category__c);
        }
        
        //get category details and category items
        ChkList = IMP_Project_Utility.retrieveCheckListCategoryBySet(categoryIds);
        //ChkList= [SELECT Id, Name, Number_of_Checklist_Items__c FROM Checklist_Category__c WHERE Id IN: categoryIds];
        
        Map<string, list< Checklist_Answer__c>> chkListMap = new Map<String, list< Checklist_Answer__c>>();
        
        //get all the answer in the checklist
        //this loop will map the category and answer that will be used in the next loop
        for(Checklist_Answer__c chklistAns: IMP_Project_Utility.retrieveChecklistAnswerBySet(null, projectChecklistIds, 'Item__r.Order__c', true, 0)){
            //for(Checklist_Answer__c chklistAns : [select id,Project_Checklist__c,Project_Checklist__r.item_category__c,item__c, item__r.Item__c,Response__c,URL_Location__C from Checklist_Answer__c 
            //                                      where Project_Checklist__c=:projectChecklistIds order by item__r.Order__c] )
            //{
            //check if the category already exist in the chkListMap if not create a new record for that category
            if(chkListMap.containskey(chklistAns.Project_Checklist__r.item_category__c))
            {
                //get all the answer for that category
                list<Checklist_Answer__c> tempListAns =  chkListMap.get(chklistAns.Project_Checklist__r.item_category__c);
                //add a new answer in the list
                tempListAns.add(chklistAns);
                //update the map
                chkListMap.put(chklistAns.Project_Checklist__r.item_category__c,tempListAns);
                
            }
            else
            {
                //add new category and ansewr in the list
                list<Checklist_Answer__c> tempList = new list<Checklist_Answer__c>();
                tempList.add(chklistAns);
                chkListMap.put(chklistAns.Project_Checklist__r.item_category__c,tempList);
            }
        }
        
        //this iteration will group the answer by category
        //add a counter number in the list for each answer by category
        //this will populate categorydetails which is the source value of IMP_CheckListPageView
        Integer cnt = 0;
        CategoryLinks cLinks = new CategoryLinks();
        catLinks = new List<CategoryLinks>();
        List<Checklist_Category__c> cat  = new List<Checklist_Category__c>();
        for(Checklist_Category__c  cc : ChkList)
        {
            integer count=1;
          
            CategoryDetails catDetail = new CategoryDetails();
            catDetail.categoryObj=cc;
            List<QuestionAnswer> qaList = new list<QuestionAnswer>();
            if(chkListMap.containskey(cc.id))
            {
                //get the all answer of the current category in the loop
                for(Checklist_Answer__c ca :chkListMap.get(cc.id))
                {
                    QuestionAnswer qaItem= new QuestionAnswer();
                    qaItem.counter=count; // assign counter number to be used to  Column Order
                    count++; //increment Counter number per item
                    
                    qaItem.answer=ca;
                    qaList.add(qaItem);
                }
                //add a new category with its answer in the wrapper class
                catDetail.qa=qaList;
                categorydetails.add(catDetail);
            }            
            //this function will populate the category links
            //the table consist of 4 links per row
            cat.add(cc);
            cnt++;
            if (cnt == 4)
            {
                cLinks.categories = cat;
                catLinks.add(cLinks); //add to the wrapper class, the source variable of the repeater
                //reset for the next row
                cLinks = new CategoryLinks();
                cat  = new List<Checklist_Category__c>();
                cnt = 0;
            }
        }
        //add the remaining value with less that 4 in the list
        if (!cat.isEmpty()) {
            cLinks.categories = cat;
            catLinks.add(cLinks);
        }
        
        for(categorydetails catDetails:  categorydetails)
        {
            for(QuestionAnswer QAnswer : catDetails.qa)
            {
                
                if(QAnswer.answer.Response__c == 'N/A')
                {
                    QAnswer.isNotApplicable = true;
                }
                else{
                    QAnswer.isNotApplicable = false;
                }
            }
        }
    }
    /*------------------------------------------------------------
    Author: Alexander Daria
    Company: Cloud Sherpas
    Description: Retrieve when and who was the last person updated the record
    Inputs: Id
    Returns: None
    History
    08/26/14      Alexander Daria      Created
    ------------------------------------------------------------*/
    public void getLastModifiedDateAndName(Id currprojId) {
        //check the latest modified date and user id in the answer only get 1
        List<Project_Checklist__c> checklists = IMP_Project_Utility.retrieveProjectCheckList(currprojId);
        //List<Project_Checklist__c> checklists = [SELECT Name FROM Project_Checklist__c WHERE Project__c = :currprojId LIMIT 1];
        List<Checklist_Answer__c> ans = IMP_Project_Utility.retrieveChecklistAnswerBySet(checklists[0].Id, null, 'LastModifiedDate', false, 1);
        //List<Checklist_Answer__c> ans =  [SELECT LastModifiedDate,LastModifiedById FROM Checklist_Answer__c where Project_Checklist__c = :checklists[0].Id order by LastModifiedDate desc  Limit 1];
        List<Id> userIds = new List<Id>();
        //store the value in the variable to be fetch by the page
        for(Checklist_Answer__c answers : ans)
        {
            lastModifiedDate = answers.LastModifiedDate;
            userIds.add(answers.LastModifiedById);
        }
        //used to retrieve the name of the person
        List<User> users = IMP_Project_Utility.retrieveUserBySet(null, userIds);
        //List<User> users = [Select Name From User where Id in : userIds];
        for(User lastUser : users)
        {
            lastModifiedBy = lastUser.Name;
        }
    }
    /*------------------------------------------------------------
    Author: Alexander Daria
    Company: Cloud Sherpas
    Description: Saving the record
    Inputs: none
    Returns: PageReference
    History
    08/26/14      Alexander Daria      Created
    12/12/14      Kimiko Roberto       Applied if blocks for Boolean isNotApplicable
    ------------------------------------------------------------*/
    Public PageReference saveRecords()
    {
        //iterate  categorydetails and get the answer in the wrapper class
        list <Checklist_Answer__c > answr= new list<Checklist_Answer__c >();
        for(categorydetails catDetails:  categorydetails)
        {
            for(QuestionAnswer QAnswer : catDetails.qa)
            {
                
                if(QAnswer.answer!=null )
                {
                    if(QAnswer.isNotApplicable){
                        QAnswer.answer.Response__c = 'N/A';
                    }
                    else if(!QAnswer.isNotApplicable && QAnswer.answer.URL_Location__c != null && QAnswer.answer.URL_Location__c != ''){
                        QAnswer.answer.Response__c = 'Yes';
                    }
                    else if(QAnswer.isNotApplicable && (QAnswer.answer.URL_Location__c == null || QAnswer.answer.URL_Location__c == '')){
                        QAnswer.answer.Response__c = '';  
                    }
                    answr.add(QAnswer.answer);
                }
            }
        }
        try
        {
            upsert answr;
        }
        catch (DmlException e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
            System.debug('$$$ upsert Checklist DmlException: '+e);
        }
        return null;
    }
    /*------------------------------------------------------------
    Author: Alexander Daria
    Company: Cloud Sherpas
    Description: Save and redirect to the dashboard page
    Inputs: None
    Returns: PageReference
    History
    08/26/14      Alexander Daria      Created
    ------------------------------------------------------------*/
    Public PageReference Close()
    {
        saveRecords();
        PageReference reference= new PageReference('/'+'apex/IMP_siteworkbook?id=' + currProject.Id);
        reference.setRedirect(true);
        return reference;
    }
    /*------------------------------------------------------------
    Author: Alexander Daria
    Company: Cloud Sherpas
    Description: Redirect to the dashboard page
    Inputs: None
    Returns: PageReference
    History
    08/26/14      Alexander Daria      Created
    ------------------------------------------------------------*/
    Public PageReference Cancel()
    {
        PageReference reference= new PageReference('/'+'apex/IMP_siteworkbook?id=' + currProject.Id);
        reference.setRedirect(true);
        return reference;
    }
    /*------------------------------------------------------------
    Author: Alexander Daria
    Company: Cloud Sherpas
    Description: Wrapper, this is used to populate the question by category in the page
    Inputs: none
    Returns: None
    History
    08/26/14      Alexander Daria      Created
    ------------------------------------------------------------*/
    public class CategoryDetails
    {
        public Checklist_Category__c categoryObj {get;set;}
        public List<QuestionAnswer> qa {get;set;}
        
        
    }
    /*------------------------------------------------------------
    Author: Alexander Daria
    Company: Cloud Sherpas
    Description: Wrapper , this is used to be able to add item # field
    Inputs: none
    Returns: None
    History
    08/26/14      Alexander Daria      Created
    ------------------------------------------------------------*/
    public class QuestionAnswer
    {
        public Checklist_Item__c item {get;set;}
        public Checklist_Answer__c answer {get;set;}
        public integer Counter {get;set;}
        public Boolean isNotApplicable {get;set;}
        public QuestionAnswer(){
            isNotApplicable = false;
        }
        
            
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Wrapper , this is used to populate the links in the page
    Inputs: none
    Returns: None
    History
    08/26/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public class CategoryLinks
    {        
        public List<Checklist_Category__c> categories {get;set;}
    }
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Changing the view mode to edit mode
    Inputs: None
    Returns:None
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public PageReference editRecords()
    {  
        isEditMode = true;
        return null;
       
    }
    
}