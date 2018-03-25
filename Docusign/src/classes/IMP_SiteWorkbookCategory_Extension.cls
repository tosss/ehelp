/*------------------------------------------------------------
Author:Kimiko  Roberto
Company: Cloud Sherpas       
Description: This class is used as an extension of IMP_SiteWorkBookCategory page
which displays the set of questions of the Workbook Category allowing them to, filter the questions,
edit the answers and save it.
This page also allows to add Interviewees and saves Interviewers and Interviewees included.
Test Class: IMP_SiteWorkbookCategoryEx_Test
History
08/28/14    Kimiko  Roberto         Created
09/01/14    Rey Austral             Added filter function
10/16/14    Kimiko  Roberto         Removed functionality on removing Interviewers
11/20/14    Samuel Oberes           Applied usage of IMP_Project_Utility.buildSelectOption
11/27/14    Samuel Oberes           Added semicolon in the list of valid question picklist values delimiter
05/29/15    Hemanth Kesapragada     Modified saveAnswers method to Save only modified fields
05/29/15    Hemanth Kesapragada     Created SubprojectId variable to hold the subproject parameter passed
05/29/15    Hemanth Kesapragada     Modified CompileAnswersForEachQuestion method to save results from SOQL into temporary
                                    variable instead of class variable. The method can be reused.
06/1/15     Hemanth Kesapragada     Removed methods,variables related to Interviewee,Interviewer. Moved it to component.
06/04/15    Hemanth Kesapragada     Commented ViewClose() method as command Link in VF page handles the functionality.
06/11/15    Hemanth Kesapragada     Removed remoteSaveAnswer() method
06/12/15    Hemanth Kesapragada     get autoSaveTimer settings based on the visualforce page in custom setting
07/1/15     Venkata Shrivol         Fixed the code accordingly for the new data model
------------------------------------------------------------*/
public class IMP_SiteWorkbookCategory_Extension {
    
    public Discovery_Workbook_Category__c DiscoveryWorkbookCategory {get;set;}
    public map<Id, Answer__c> AnswersForEachQuestion {get;set;}
    public String siteWkbookCatId = '';
    public String marketSelectedValue { get; set; } 
    public String projectTypeSelectedValue { get; set; }
    public List<String> solutionSelectedValue { get; set; }
    public List<String> productSelectedValue { get; set; }    
    public List<SelectOption> solutionItems { get; set; }    
    public String lastModifiedBy { get; set; }
    public DateTime lastModifiedDate { get; set; }    
    public Boolean isEditMode { get; set; }
    public List<QuestionWrapper> qWrapper { get; set; }    
    public String tempSelectedProduct { get; set; }
    private JSONGenerator generator;
    public String autosaveTimer { get; set; }
    public Boolean isRecordFiltered { get; set; }
    public map<Id,List<String>> selectedMultiPicklist { get; set; }
    public Boolean userHasEditPermission {get; set; }
    public String selectedAnswerField { get; set; }
    public String selectedQuestionId { get; set; }
    public String selectedErrorMsg { get; set; }
    public String selectedAnswerValue { get; set; }
    public String selectedAnswerType { get; set; }
    public String subProjectId {get; set;}
    public SubProject__c thisSubProject {get; set;}
    public static final String VF_PAGE = 'IMP_SiteWorkBookCategory';
    
    public IMP_SiteWorkbookCategory_Extension (ApexPages.StandardController DiscoveryWorkbookController)
    {
        string siteWkbookCatIdtmp = ApexPages.currentPage().getParameters().get('id');
        subProjectId=ApexPages.currentPage().getParameters().get('subProject');
        thisSubProject = [select Market__c, Project_Type__c from SubProject__c where Id= :subProjectId];
        //this will determine if the page is in edit mode or view mode
        if(ApexPages.currentPage().getParameters().get('view') != null && ApexPages.currentPage().getParameters().get('view') != '')
        {
            isEditMode = false;
        }
        else if(!IMP_Project_Utility.checkUserPermission('Discovery_Workbook_Category__c', 'PermissionsEdit')){
            isEditMode = false;
        }else
        {
            isEditMode = true;
        }
        //this will set the milliseconds on how long the auto save will fire
        for(IMP_AutoSaveTimers__c setting : IMP_AutoSaveTimers__c.getAll().values()){
            if(VF_PAGE.equals(setting.VF_Page__c))
            {
                autosaveTimer = String.valueOf(setting.Value__c);
            }
        } 
        
        selectedAnswerField = '';
        selectedQuestionId = '';
        tempSelectedProduct = '';
        isRecordFiltered = false;       
        selectedAnswerValue = '';
        selectedAnswerType= '';
        productSelectedValue = new  List<String>();
        selectedMultiPicklist = new Map<Id,List<String>>();
        
        //get question category based on the site selected
        siteWkbookCatId = siteWkbookCatIdtmp.substring(0, 15);
        //Retrieve the category to be able to get the question category
        system.debug('------siteWkbookCatId-----'+siteWkbookCatId);
        
        try
        {
            DiscoveryWorkbookCategory = [SELECT Id,
                                         Contact_Being_Interviewed__c,
                                         Interviewer__c,
                                         Question_Category__c,
                                         Question_Category__r.Name,
                                         Site_Workbook__c,
                                         Site_Workbook__r.Project__c,
                                         Site_Workbook__r.SubProject__c,
                                         Site_Workbook__r.SubProject__r.SubProject_Name__c,
                                         Site_Workbook__r.Project__r.Name,
                                         Site_Workbook__r.Name,
                                         Site_Workbook__r.Site__c,
                                         Site_Workbook__r.Site__r.Name
                                         FROM Discovery_Workbook_Category__c
                                         WHERE Id = :siteWkbookCatId];
            
            //get all the answer and retreive question for each answer
            AnswersForEachQuestion = CompileAnswersForEachQuestion(DiscoveryWorkbookCategory.Id);
            //map the solution and product, to speed up the filtering
            mapSolutionAndProduct();
            getLastModifiedDateAndName(siteWkbookCatId);
            //check if the user have permission to edit the workbook
            userHasEditPermission = IMP_Project_Utility.checkUserPermission('Answer__c','PermissionsEdit');
        }
        catch(Exception e)
        {
            system.debug(e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Retrieve when and who was the last person updated the record
    Inputs: siteWkbookCatId
    Returns: None
    History
    09/01/14      Rey Austral        Created
    ------------------------------------------------------------*/
    public void getLastModifiedDateAndName(Id siteWkbookCatId) {
        
        //check the latest modified date and user id in the answer only get 1
        List<Discovery_Answer_Workbook_Category__c> ans =  [SELECT LastModifiedDate,LastModifiedById 
                                FROM Discovery_Answer_Workbook_Category__c 
                                where Discovery_Workbook_Category__c = :siteWkbookCatId 
                                order by LastModifiedDate desc  
                                Limit 1];
        
        List<Id> userIds = new List<Id>();
        //store the value in the variable to be fetch by the page
        if (!ans.isEmpty()) {
            for(Discovery_Answer_Workbook_Category__c answers : ans)
            {
                lastModifiedDate = answers.LastModifiedDate;
                userIds.add(answers.LastModifiedById);
            }
        }
        //used to retrieve the name of the person
        List<User> users = IMP_Project_Utility.retrieveUserBySet(null, userIds);
        //List<User> users = [Select Name From User where Id in : userIds];
        if (!users.isEmpty()) {
            for(User lastUser : users)
            {
                lastModifiedBy = lastUser.Name;
            }
        }
    }

    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: This is used to what control will be render in the visualforce page
    Inputs: none
    Returns: None
    History
    10/31/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public QuestionTypeWrapper getQuestionType (String qType)
    {
        QuestionTypeWrapper typeWrapper = new QuestionTypeWrapper();
        typeWrapper.isSelectField = false;
        typeWrapper.isOutputField = false;
        typeWrapper.isMultiSelectField = false;
        typeWrapper.isTextAreaField = false;
        typeWrapper.isInputField = false;
        if ('Picklist'.equals(qType)) 
        {             
            typeWrapper.isSelectField = true;                 
        }
        else if (isEditMode == false && 'URL'.equals(qType))
        {           
            typeWrapper.isOutputField = true;
        }
        else if ('MultiSelect Picklist'.equals(qType)) 
        {
            typeWrapper.isMultiSelectField = true;
        }
        else if ('Text'.equals(qType))
        {
            typeWrapper.isTextAreaField = true;
        }
        else
        {
            typeWrapper.isInputField = true;
        }
        return typeWrapper;
    }
  
    /*------------------------------------------------------------
    Author: Kimiko  Roberto
    Company: Cloud Sherpas
    Description: Retrieve all the answer for each question
    Inputs: List<Question__c>,Id
    Returns: map<Id, Answer__c>
    History
    08/24/14      Kimiko  Roberto      Created
    11/04/14      Rey Austral          New Question must not be retrieve in the existing workbook
    12/05/14      Samuel Oberes        Introduced the regex approach in handling mixed comma and semicolon delimiters
    07/01/15      Venkata Shrivol      Modified to store the multiselect picklist answers
    ------------------------------------------------------------*/
    public map<Id, Answer__c> CompileAnswersForEachQuestion(Id dwCategoryId)
    {   

        //answersMap is used to populate the answer in the page and also to retrieve back the updated answer 
        map<Id, Answer__c> answersMap = new map<Id, Answer__c>();
        list<Answer__c> Answers;
        set<Id> answerIds = new set<Id>();
        
        //selectedMultiPicklist = new Map<Id,List<String>>();
        answerIds = getAnswerIds(DiscoveryWorkbookCategory.Id);
        
        if(!answerIds.isEmpty())
        {
            Answers = [
            select Id, Name, (select Answer_Completed__c from Discovery_Answer_Workbook_Categories__r),
            Checkbox_Answer__c, Currency_Answer__c, Date_Answer__c, Number_Answer__c, Text_Answer__c, YesNo_Answer__c, Picklist_Answer__c,URL_Answer__c,
            MultiSelect_Picklist_Answer__c, Any_Answer__c,
            Question__c,N_A__c, Phone_Answer__c,
            Question__r.Order__c, Question__r.Answer_Type__c, Question__r.Dependent_Question__c, 
            Question__r.Question_Text__c,Question__r.Toggle_Dependent__c,
            Question__r.Help_Text__c,Question__r.Picklist_Values__c, Question__r.Name from Answer__c
            where Id IN :answerIds and Question__c != null order by Question__r.Order__c 
            ];
        }   
        
        
        //store all the answer in the map
        if(Answers != null && !Answers.isEmpty()) {
            Integer ctr =1;
            qWrapper = new List<QuestionWrapper>();
            
            String  regex = IMP_RegularExpressions__c.getInstance('DiscoveryQuestionPicklistDelimiter').Pattern__c;
            String  replacementString = IMP_RegularExpressions__c.getInstance('DiscoveryQuestionPicklistDelimiter').ReplacementString__c;
            Pattern compiledPattern = Pattern.compile(regex);
            Matcher matcher;
            String  picklistValuesUsingUniformCommaDelimiter = '';
            String  delimiter = ',';

            for(Answer__c a : Answers) {                 
                if(a.Question__c != null && a.Question__r.Answer_Type__c != null && !''.equals(a.Question__r.Answer_Type__c )) { 
                    if (a.Question__r.Answer_Type__c == 'MultiSelect Picklist')
                    {
                        List<String> mPickAns = new List<String>();
                        if (selectedMultiPicklist.get(a.Question__c)!=null)
                        {
                             a.MultiSelect_Picklist_Answer__c = String.Join(selectedMultiPicklist.get(a.Question__r.Id),';');
                        }
                        if (a.MultiSelect_Picklist_Answer__c != null)
                        {
                            mPickAns  =  a.MultiSelect_Picklist_Answer__c.split(';');
                        }
                        selectedMultiPicklist.put(a.Question__c,mPickAns);
                    } 
                    answersMap.put(a.Question__c, a); 
                    //generate all the question related to the answer
                    
                    QuestionWrapper questions = new QuestionWrapper();
                    
                    questions.rowNumber = String.valueof(ctr);                    
                    questions.questions = a.Question__r;
                    if ('Picklist'.equals(a.Question__r.Answer_Type__c) || 'MultiSelect Picklist'.equals(a.Question__r.Answer_Type__c)) 
                    {
                        matcher = compiledPattern.matcher(a.Question__r.Picklist_Values__c);
                        picklistValuesUsingUniformCommaDelimiter = matcher.replaceAll(replacementString);

                        questions.picklistValues =  parseStringtoList(picklistValuesUsingUniformCommaDelimiter, delimiter); 

                    }
                    questions.questionType = getQuestionType(a.Question__r.Answer_Type__c);
                    qWrapper.add(questions);
                    ctr++;
                    
                } 
            }
        }
        return answersMap;
    }   
 
    public void tabSaveAnswer() {

        selectedErrorMsg = '';
        Answer__c a = AnswersForEachQuestion.get(selectedQuestionId);

        try
        {
            if (selectedAnswerType == 'Number')
            {
                Integer tryConvert  = Integer.valueOf(selectedAnswerValue);
            } else if (selectedAnswerType == 'Date')
            {
                Date tryConvert = Date.parse(selectedAnswerValue);
            } else if (selectedAnswerType == 'Currency')
            {
                Decimal tryConvert = Decimal.valueOf(selectedAnswerValue);
            }
        }
        catch(exception e)
        {
            selectedErrorMsg = e.getMessage();
        }
        
        if (a != null)
        {
            if(a.Question__r.Answer_Type__c == 'MultiSelect Picklist')
            {
                a.MultiSelect_Picklist_Answer__c = String.Join(selectedMultiPicklist.get(a.Question__r.Id),';');
            }
            if (checkAnswerIfLock(a.Question__r.Dependent_Question__c,a))
            {
                a.Any_Answer__c = true;                        
            }else
            {
                a.Any_Answer__c = false;
            }
            if(a.Question__r.Answer_Type__c == 'MultiSelect Picklist')
            {
                a.MultiSelect_Picklist_Answer__c = String.Join(selectedMultiPicklist.get(a.Question__r.Id),';');
            }          
        }
        
        try {
            //upsert a;
        }
        catch(Exception e) {          
            selectedErrorMsg = e.getMessage();
        }
        
    }
    
    
    /*------------------------------------------------------------
    Author: Kimiko  Roberto
    Company: Cloud Sherpas
    Description: Saving all answers from the answer fields, deletes the removed
    Iterviewees and also saves the added Interviewers and Interviewees.
    Inputs: None
    Returns:None
    History
    08/24/14      Kimiko  Roberto      Created
    09/04/14      Rey Austral          Change loading of data
    05/29/15      Hemanth Kesapragada  Modified to save only updated values
    ------------------------------------------------------------*/
     public void SaveAnswers()
    {   
        //get all the updated/non-updated answer
        list<Answer__c> AnswersList = new list<Answer__c>();
        list<Discovery_Answer_Workbook_Category__c> answerWkbkCatList= new list<Discovery_Answer_Workbook_Category__c>();
        set<Id> answerIds = new set<Id>();
        //convert map to list for saving the answer
        map<Id,Answer__c> existingAnswerMap = CompileAnswersForEachQuestion(siteWkbookCatId); 
        
        if(AnswersForEachQuestion != null && !AnswersForEachQuestion.isEmpty())
        {
            for(Answer__c a : AnswersForEachQuestion.values())
            {
                // For all the answers existingAnswerMap will be old values and AnswersForEachQuestion will be new answers on save
                // but for multi-select answers it is vice-versa
                Answer__c existingAnswerObj = existingAnswerMap.get(a.Question__r.Id);
                if(a.Checkbox_Answer__c!=existingAnswerObj.Checkbox_Answer__c || 
                   a.Currency_Answer__c!=existingAnswerObj.Currency_Answer__c ||
                   a.Date_Answer__c!=existingAnswerObj.Date_Answer__c ||
                   a.MultiSelect_Picklist_Answer__c!=existingAnswerObj.MultiSelect_Picklist_Answer__c ||
                   a.Number_Answer__c!=existingAnswerObj.Number_Answer__c ||
                   a.Picklist_Answer__c!=existingAnswerObj.Picklist_Answer__c ||
                   a.Text_Answer__c!=existingAnswerObj.Text_Answer__c ||
                   a.N_A__c!=existingAnswerObj.N_A__c ||
                   a.Phone_Answer__c!=existingAnswerObj.Phone_Answer__c ||
                   a.URL_Answer__c!=existingAnswerObj.URL_Answer__c ||
                   a.YesNo_Answer__c!=existingAnswerObj.YesNo_Answer__c)
                {
                    if(a.Question__r != null && a.Question__r.Answer_Type__c != null)
                    {
                        if(a.Question__r.Answer_Type__c == 'MultiSelect Picklist')
                        {
                            a.MultiSelect_Picklist_Answer__c = String.Join(selectedMultiPicklist.get(a.Question__r.Id),';');
                        }
                        if (checkAnswerIfLock(a.Question__r.Dependent_Question__c,a))
                        {
                            a.Any_Answer__c = true;
                            for(Discovery_Answer_Workbook_Category__c dawc:a.Discovery_Answer_Workbook_Categories__r)
                            {
                                dawc.Answer_Completed__c = true;
                            }
                        }else
                        {
                            a.Any_Answer__c = false;
                            for(Discovery_Answer_Workbook_Category__c dawc:a.Discovery_Answer_Workbook_Categories__r)
                            {
                                dawc.Answer_Completed__c = false;
                            }
                        }
                        if(a.N_A__c)
                        {
                            a.Any_Answer__c = true;
                            for(Discovery_Answer_Workbook_Category__c dawc:a.Discovery_Answer_Workbook_Categories__r)
                            {
                                dawc.Answer_Completed__c = true;
                            }
                        }
                        AnswersList.add(a);
                        answerWkbkCatList.addAll(a.Discovery_Answer_Workbook_Categories__r);
                    }
                }
            }
        }
        
        try {
            //insert or update the category
            upsert DiscoveryWorkbookCategory;

            if(!AnswersList.isEmpty()) 
            {
                upsert AnswersList;
                 
            } //insert or update all the answer
            
            if(!answerWkbkCatList.isEmpty())
            {
                upsert answerWkbkCatList;
            }
            //remap the question and answer to repopulate in the page, because the data is lost when the save button render the page again
            
            queryFilterQuestions( DiscoveryWorkbookCategory.Id);
        }
        catch(Exception e) {
            system.debug(e);
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    private Boolean checkAnswerIfLock(Id dendentId, Answer__c childRecord) 
    {
        Boolean result = true;
        if (AnswersForEachQuestion.containsKey(dendentId)) 
        {
            Answer__c parentRecord = AnswersForEachQuestion.get(dendentId);
            Question__c parentQuestion = parentRecord.Question__r;
            if (parentQuestion.Toggle_Dependent__c != '') 
            {               
                if (String.valueOf(parentRecord.Checkbox_Answer__c)  == parentQuestion.Toggle_Dependent__c 
                    || parentRecord.Text_Answer__c  == parentQuestion.Toggle_Dependent__c
                    || String.valueOf(parentRecord.Currency_Answer__c)  == parentQuestion.Toggle_Dependent__c
                    || String.valueOf(parentRecord.Date_Answer__c)  == parentQuestion.Toggle_Dependent__c
                    || parentRecord.MultiSelect_Picklist_Answer__c  == parentQuestion.Toggle_Dependent__c
                    || parentRecord.Picklist_Answer__c  == parentQuestion.Toggle_Dependent__c
                    || parentRecord.URL_Answer__c  == parentQuestion.Toggle_Dependent__c
                    || parentRecord.Phone_Answer__c  == parentQuestion.Toggle_Dependent__c
                    || String.valueOf(parentRecord.Number_Answer__c)  == parentQuestion.Toggle_Dependent__c
                    || parentRecord.YesNo_Answer__c  == parentQuestion.Toggle_Dependent__c) {
                        result = false;
                }else if (checkHasAnswer(parentRecord) == false)
                {
                    result = false;
                }
                else if(checkHasAnswer(childRecord)==false)
                {
                    result = false;
                }
             
            }else
            {
                if (checkHasAnswer(childRecord)==false) {
                        result = false;
                }
            }
        }else
        {
            result = false;
        }
        return result;
    }
    
    private Boolean checkHasAnswer(Answer__c ans)
    {
        Boolean hasAnswer = true;
        if (ans.Checkbox_Answer__c == false
            && (ans.Text_Answer__c  == ''  || ans.Text_Answer__c == null)
            && (ans.Currency_Answer__c == null)
            && (ans.Date_Answer__c == null)
            && (ans.MultiSelect_Picklist_Answer__c  == '' || ans.MultiSelect_Picklist_Answer__c == null)
            && (ans.Picklist_Answer__c  == '' || ans.Picklist_Answer__c == null)
            && (ans.Number_Answer__c == null)
            && (ans.URL_Answer__c  == '' || ans.URL_Answer__c == null)
            && (ans.YesNo_Answer__c  == '' || ans.YesNo_Answer__c == null)) {
                hasAnswer = false;
                }
        return hasAnswer;
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Redirecting to the dahboard
    Inputs: None
    Returns:None
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    /*public String ViewClose()
    {

        //closing the page without saving 
        String DiscoveryWorkbookPage = '/apex/imp_siteworkbook?id='+DiscoveryWorkbookCategory.Site_Workbook__r.Project__c+'&subProject='+subProjectId;  
        return DiscoveryWorkbookPage;     
    }*/
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Changing the view mode to edit mode
    Inputs: None
    Returns:None
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public void ViewEdit()
    {
        

        //make the view mode page into an edit page
        //this will show again the add interviewee and enable the controls
        if(IMP_Project_Utility.checkUserPermission('Discovery_Workbook_Category__c', 'PermissionsEdit')){
            isEditMode = true;
        }
        
        //isRecordFiltered is used to determine if the user have already filter the records before pressing the edit
        //need to perform a query because the data has been reset and the filter is lost when the controls was rerendered
        if (isRecordFiltered == true)
        {
            performFilterQuestion();
        }else 
        {
            //get all the answer and retreive question for each answer
            AnswersForEachQuestion = CompileAnswersForEachQuestion(DiscoveryWorkbookCategory.Id);
        }
    }
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Populating the market dropdown in the filter
    Inputs: None
    Returns:None
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public List<SelectOption> getMarketItems() {

        //get the value of market dropdown list in the custom settings
        Map<String, String> optionsMap = new Map<String, String>();
        optionsMap.put('','');
        if (IMP_MarketList__c.getAll().values().size() > 0){
            for(IMP_MarketList__c setting : IMP_MarketList__c.getAll().values()){
                optionsMap.put(setting.name, setting.name);
            }  
        }
        return IMP_Project_Utility.buildSelectOption(optionsMap, true);
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Populating the project type dropdown in the filter
    Inputs: None
    Returns:None
    History
    09/2/14      Rey Austral      Created
------------------------------------------------------------*/
    public List<SelectOption> getProjectTypeItems() {

        //get the value of the project tyoe dropdown list in the custom settings
        Map<String, String> optionsMap = new Map<String, String>();
        optionsMap.put('','');
        if (IMP_ProjectTypeList__c.getAll().values().size() > 0) {
            for(IMP_ProjectTypeList__c setting : IMP_ProjectTypeList__c.getAll().values()){
                optionsMap.put(setting.name, setting.name);
            }  
        }
        return IMP_Project_Utility.buildSelectOption(optionsMap, true);
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Filtering the question based on the selected dropdown
    Inputs: None
    Returns:None
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public void filterQuestions()
    {      

        //filter the question based on the selected value
        //System.debug('The value of DiscoveryWorkbookCategory.id is ' + DiscoveryWorkbookCategory.id);
        queryFilterQuestions(DiscoveryWorkbookCategory.id);
        //System.debug('Call to queryFilterQuestions method complete.  filterQuestions method now fully complete.');
        
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Converting List to Map
    Inputs: List<String>
    Returns:Map<String,String>
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public Map<String,String> GenerateStringMap(List<String> items)
    {

        //convert list to map for easy manipulation and searching
        Map<String,String> mapResult = new Map<String,String>();
        if (items != null)
        {
            for(String val : items)
            {
                if (!''.equals(val) && val != null)
                {
                    mapResult.put(val, val);
                }
            }
        }
        return mapResult;
    }
    
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Converting List to Map
    Inputs: List<String>
    Returns:Map<String,String>
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public set<Id> getAnswerIds(Id DiscoveryWkbkCategoryId)
    {
        set<Id> answerIds = new set<Id>();
        list<Discovery_Answer_Workbook_Category__c> discoveryAnswerCategoryList = [
            select Answer__c 
            from Discovery_Answer_Workbook_Category__c where Discovery_Workbook_Category__c =:DiscoveryWkbkCategoryId]; 
        if(discoveryAnswerCategoryList!=null && !discoveryAnswerCategoryList.isEmpty())
        {
            for(Discovery_Answer_Workbook_Category__c dawc:discoveryAnswerCategoryList)
            {
                answerIds.add(dawc.Answer__c);
            }  
        }
        return answerIds;
    }    

    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Used to generate the where of the sosql in retrieving the questions
    Inputs: Id
    Returns:List<Question__c>
    History
    09/2/14      Rey Austral      Created
    12/05/14     Samuel Oberes    Introduced the regex approach in handling mixed comma and semicolon delimiters
    ------------------------------------------------------------*/
    public void queryFilterQuestions(Id dwCategoryId){

        //this method is used to generate the where filter , check if the control has value
        //if yes, create a filter command for that
        List<String> queryFilter = new List<String>();
        set<Id> questionIds = new set<Id>();
        //use includes because the market and product type are multi select list
        /*if (!''.equals(marketSelectedValue) && marketSelectedValue != null)
        {           
            queryFilter.add('Question__r.Market__c INCLUDES (\'' + marketSelectedValue + '\')');  
        }
        
        if (!''.equals(projectTypeSelectedValue) && projectTypeSelectedValue != null)
        {           
            queryFilter.add('Question__r.Project_Type__c INCLUDES (\'' + projectTypeSelectedValue + '\')');  
        }*/
        //for solution and product get only the question id , the source will be different
        //String DQPsId = ListofDQPs();
        questionIds = ListofDQPs();
        
        /*if (!''.equals(DQPsId) && DQPsId != null)
        {
            if (!'None'.equals(DQPsId))
            {
                queryFilter.add('Question__r.Id IN (' + DQPsId + ')'); 
            }else
            {
                queryFilter.add('Question__r.Id IN (\'\')'); 
            }
        }
        //add and for each filter
        String generatedFilter = '';
        for (String values : queryFilter)
        {            
            generatedFilter += ' And ' + values;           
        }*/
        
        list<Answer__c> Answers = new list<Answer__c>(); 
        set<Id> answerIds = new set<Id>(); 
        //execute the query statement with the generated filter
        
        answerIds = getAnswerIds(dwCategoryId);
        
        /*String query =  'select Id, Name, ' +
            'Checkbox_Answer__c, Currency_Answer__c, Date_Answer__c, Number_Answer__c, Text_Answer__c, YesNo_Answer__c, Picklist_Answer__c,URL_Answer__c,' +
            'MultiSelect_Picklist_Answer__c,Discovery_Workbook_Category__c, N_A__c, Question_Category__c, Any_Answer__c, ' +
            'Question__c, ' +
            'Question__r.Order__c, Question__r.Answer_Type__c, Question__r.Dependent_Question__c, ' +
            'Question__r.Question_Text__c,Question__r.Toggle_Dependent__c,' +
            'Question__r.Help_Text__c,Question__r.Picklist_Values__c, Question__r.Name from Answer__c ' +
            'where Discovery_Workbook_Category__c = \'' + dwCategoryId + '\' and Question__c != null ' + generatedFilter + ' order by Question__r.Order__c ';
       
        Answers = Database.query(query) ;*/
        
        Answers =  [select Id, Name, 
            Checkbox_Answer__c, Currency_Answer__c, Date_Answer__c, Number_Answer__c, Text_Answer__c, YesNo_Answer__c, Picklist_Answer__c,URL_Answer__c,
            MultiSelect_Picklist_Answer__c,Phone_Answer__c, N_A__c, Any_Answer__c, 
            Question__c, 
            Question__r.Order__c, Question__r.Answer_Type__c, Question__r.Dependent_Question__c, 
            Question__r.Question_Text__c,Question__r.Toggle_Dependent__c,
            Question__r.Help_Text__c,Question__r.Picklist_Values__c, Question__r.Name from Answer__c 
            where Id IN:answerIds and Question__c IN :questionIds order by Question__r.Order__c] ;
        
        
        
        
        //remap the answer and question that will be used to populate the page
        if(Answers != null && !Answers.isEmpty()) {
            Integer ctr =1;
            qWrapper = new List<QuestionWrapper>();
            
            String  regex = IMP_RegularExpressions__c.getInstance('DiscoveryQuestionPicklistDelimiter').Pattern__c;
            String  replacementString = IMP_RegularExpressions__c.getInstance('DiscoveryQuestionPicklistDelimiter').ReplacementString__c;
            Pattern compiledPattern = Pattern.compile(regex);
            Matcher matcher;
            String  picklistValuesUsingUniformCommaDelimiter = '';
            String  delimiter = ',';

            for(Answer__c a : Answers) {                 
                if(a.Question__c != null && a.Question__r.Answer_Type__c != null && !''.equals(a.Question__r.Answer_Type__c )) { 
                    if (a.Question__r.Answer_Type__c == 'MultiSelect Picklist')
                    {
                        List<String> mPickAns = new List<String>();
                        if (a.MultiSelect_Picklist_Answer__c != null)
                        {
                            mPickAns  =  a.MultiSelect_Picklist_Answer__c.split(';');
                        }
                        selectedMultiPicklist.put(a.Question__c,mPickAns);
                    } 
                    
                    AnswersForEachQuestion.put(a.Question__c, a); 
                    //generate all the question relation to the answer
                    QuestionWrapper questions = new QuestionWrapper();
                    
                    questions.rowNumber = String.valueof(ctr);
                    questions.questions = a.Question__r;
                    if ('Picklist'.equals(a.Question__r.Answer_Type__c) || 'MultiSelect Picklist'.equals(a.Question__r.Answer_Type__c)) 
                    {
                        matcher = compiledPattern.matcher(a.Question__r.Picklist_Values__c);
                        picklistValuesUsingUniformCommaDelimiter = matcher.replaceAll(replacementString);

                        questions.picklistValues =  parseStringtoList(picklistValuesUsingUniformCommaDelimiter, delimiter);
                    }
                    questions.questionType = getQuestionType(a.Question__r.Answer_Type__c);
                    qWrapper.add(questions);
                    ctr++;
                } 
            }
        }
    }
   
    /*------------------------------------------------------------
    Author:      ?
    Company:     Cloud Sherpas
    Description: Creates a select option list out of a delimited string
    Inputs:      stringPickListValues - delimited string that will later on be split
                 delimeter
    Returns:     List<SelectOption>
    History
    12/05/14     Samuel Oberes    Used removeNullElements to remove unwanted elements (null elements that were created because they were in between 2 delimiters)
    ------------------------------------------------------------*/
    public List<SelectOption> parseStringtoList(String stringPickListValues, String delimeter)
    {

        List<String> stringValues = stringPickListValues.split(delimeter);
        stringValues = IMP_Project_Utility.removeNullElements(stringValues);

        Map<String, String> resultsMap = new Map<String, String>();
        resultsMap.put('','-- None --');
        for (String s : stringValues ) {
            resultsMap.put(s,s);
        }
        
        return IMP_Project_Utility.buildSelectOption(resultsMap, true);
    }

    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Used to generate the filter for product and solution
    Inputs: None
    Returns:String
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public Set<Id> ListofDQPs ()
    {

        //If product filter has selected value do not add the solution filter
        //only use the solution filter if there is no product selected
        set<Id> questionIds = new set<Id>();
        Map<String,String> mapProductSelectedValue =  GenerateStringMap(productSelectedValue);
        Map<String,String> mapSolutionSelectedValue = new Map<String,String>();
        String resultId = '';
        List<Discovery_Question_Product__c> dQuestionProduct = new List<Discovery_Question_Product__c>();
        //product filter is first check, if empty use the solution
        //because product have a lookup for the solution we do not need to include the solution in the filter to speed up the searching
        if (!mapProductSelectedValue.isEmpty())
        {
            List<String> queryFilter = new List<String>();
            dQuestionProduct = IMP_Project_Utility.retrieveQuestionProductBySet(mapProductSelectedValue.keySet(), null);
            //dQuestionProduct = [Select Question__c from Discovery_Question_Product__c WHERE Product__c in : mapProductSelectedValue.keySet()];
            if (dQuestionProduct.isEmpty())
            {
                resultId = 'None';
            }
        }
        else
        {
            mapSolutionSelectedValue =  GenerateStringMap(solutionSelectedValue);
            
            if (!mapSolutionSelectedValue.isEmpty())
            {
                //to be able to retrieve the data that have filter solution, we need first to get the product then used that as the filter in the question product object
                //there is no solution field in the Discovery_Question_Product__c object
                String subQuery = '(SELECT Id FROM Product__c WHERE Solution__c IN: parentRecordIdSet)';
                dQuestionProduct = IMP_Project_Utility.retrieveQuestionProductBySet(mapSolutionSelectedValue.keySet(), subQuery);
                //dQuestionProduct = [Select Question__c from Discovery_Question_Product__c where Product__c in (Select Id from Product__c WHERE Solution__c  in : mapSolutionSelectedValue.keySet())];
                if (dQuestionProduct.isEmpty())
                {
                    resultId = 'None';
                }
            }
        }
        //the question must be format that is valid in the "in" statement, ex. 'question','question1'
        Integer ctr = 0;
        if (!dQuestionProduct.isEmpty()) {
            for (Discovery_Question_Product__c dqp : dQuestionProduct)
            {
                /*
                if (ctr == 0)
                {
                    resultId += '\'' + dqp.Question__c + '\'';
                }else
                {
                    resultId += ',\'' + dqp.Question__c + '\'';
                }
                ctr++;*/
                questionIds.add(dqp.Question__c);
            }
        }
        system.debug('-----questionIds-----'+questionIds);
        //return resultId;
        return questionIds;
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Used to clear all the value related to the filter
    Inputs: None
    Returns:None
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public PageReference clearFilter()
    {

        //clear all the selected items from all the filter control
        isRecordFiltered = false;
        marketSelectedValue = '';
        projectTypeSelectedValue = '';
        solutionSelectedValue.clear();
        productSelectedValue.clear();
        //System.debug('About to call the CompileAnswersForEachQuestion method.  The value of DiscoveryWorkbookCategory.Id is ' + DiscoveryWorkbookCategory.Id);
        AnswersForEachQuestion = CompileAnswersForEachQuestion(DiscoveryWorkbookCategory.Id);
        //System.debug('The method call CompileAnswersForEachQuestion is now complete from within the clearFilter method.  About to return null to complete the clearFiler method.');
        return null;
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Used to populate the Solution list and map the product per solution
    Inputs: None
    Returns: None
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public void mapSolutionAndProduct()
    {
        set<Id> solutionIds = new set<Id>();
        set<Id> productIds = new set<Id>();
        set<Id> answerIds = new set<Id>();
        list<Discovery_Question_Product__c> dwclist;
        //this method is used to map each product to a solution
        //this also populate the solution list
        //need to use json to speed up the selecting of filter
        //to avoid postback of the page
        String subQuery = '(SELECT Id, Name FROM Products__r WHERE Active__c = true AND Number_of_Questions__c > 0)';
        String additionalFilter = 'Active__c = true AND Number_of_Questions__c > 0';
        //List<Solution__c> lstSolution = IMP_Project_Utility.retrieveSolutionsWithSubquery(DiscoveryWorkbookCategory.Question_Category__c, subQuery, additionalFilter);
        //List<Solution__c> lstSolution = [ Select Id, Name,(Select Id,Name From Products__r) From Solution__c where Question_Category__c = : DiscoveryWorkbookCategory.Question_Category__c order by name];
        try
        {
            //Discovery_Workbook_Category__c thisWorkbookCategory = [select Site_Workbook__r.Site__c from Discovery_Workbook_Category__c where Id =:siteWkbookCatId limit 1];
            if(DiscoveryWorkbookCategory!=null)
            {
                answerIds = getAnswerIds(DiscoveryWorkbookCategory.Id);
            
                dwclist = [select Product__r.Solution__c, Product__c from Discovery_Question_Product__c where Question__c IN 
                          (select Question__c from Answer__c where Id IN:answerIds)
                          and Product__c IN 
                          (select Product__c from Site_Product__c 
                           where SubProject__c = :subProjectId and 
                           SubProjectSite__r.Account__c =:DiscoveryWorkbookCategory.Site_Workbook__r.Site__c)];
            }
            for(Discovery_Question_Product__c dwc:dwclist)
            {
                solutionIds.add(dwc.Product__r.Solution__c);
                productIds.add(dwc.Product__c);
            }
        }
        catch(Exception e)
        {
            system.debug('-------EXCEPTION-------'+e);
        }
        List<Solution__c> lstSolution = [ Select Id, Name,(Select Id,Name From Products__r where Id IN:productIds) From Solution__c where Id IN:solutionIds];
        Map<String, String> optionsMap = new Map<String, String>();
        solutionItems = new List<SelectOption>();
        optionsMap.put('','-- None --');
        
        generator = new JSONGenerator();        
        if (!lstSolution.isEmpty()) {
            for (Solution__c sol : lstSolution )
            {             
                if(!sol.Products__r.isEmpty()){                           
                    optionsMap.put(sol.Id,sol.Name);
                    generator.productsList.put(sol.id, sol.Products__r); 
                }
                
            } 
        }

        solutionItems = IMP_Project_Utility.buildSelectOption(optionsMap, false);
    }
    
    public class QuestionWrapper
    {
        public String rowNumber { get; set; }
        public Question__c questions { get; set; }
        public List<SelectOption> picklistValues { get; set; }
        public QuestionTypeWrapper questionType { get; set; }
    }    
   
    public class QuestionTypeWrapper 
    {
        public Boolean isInputField { get; set;}
        public Boolean isOutputField { get; set;}
        public Boolean isSelectField { get; set;}
        public Boolean isMultiSelectField { get; set;}
        public Boolean isTextAreaField { get; set;}
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Convert the map of solution into json format
    Inputs: None
    Returns: None
    History
    09/2/14      Rey Austral      Created
    ------------------------------------------------------------*/
    public String generatedJSON {
        get {
            return JSON.serialize(generator);
        }
    }
    
    public class JSONGenerator 
    {
        Map<Id,List<Product__c>> productsList = new Map<Id,List<Product__c>>();
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: This is trigger when the filter button is click, 
    Inputs: None
    Returns: None
    History
    09/2/14      Rey Austral      Created
------------------------------------------------------------*/
    public PageReference performFilterQuestion()
    {  

        //System.debug('Entering the performFilterQuestion method.');
        //this execute the filter when the filter button in the page is click
        isRecordFiltered = true; //neeed to know if the filter is click for checking from view to edit
        //product type have different approach of getting the value because the product is populate via javascript
        // and the selected value also passed to the controller using the javascript
        productSelectedValue = tempSelectedProduct.split(',');
        //System.debug('Value of productSelectedValue is ' + productSelectedValue);
        filterQuestions();
        //System.debug('Method call filterQuestions now complete.  performFilterQuestion method now complete.');
        
        //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Function called!'));  
        return null;
    }
   
}