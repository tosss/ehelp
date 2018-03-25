/*------------------------------------------------------------
Author:Rey Austral
Company: Cloud Sherpas       
Description: Clone Method for Discovery worbook. This is used to create copy of all the workbook of the selected site  including the answer
Test Class: IMP_CloneWorkbook_Test
History
08/28/14    Rey Austral          Created
09/08/14    Michael Lasala       Make checkIfSiteContainsWorkbook method as public
------------------------------------------------------------*/
public class IMP_CloneWorkbook_Helper {
    public String cloneWorkBook(Id projectId, Id accountId, Id sourceSiteWorkbookId)
    {
        String result = '';
        //check target site if the selected workbook is already exist 
        //if the workbook is already exist return an error message that will tell the user that the system is unable to clone a workbook because of this reason
       /* if (!checkIfSiteContainsWorkbook(projectId,accountId))
        {
            processCloningWorkbook(projectId,accountId,sourceSiteWorkbookId);
        }else
        {
            result = 'The Site you have chosen already has a workbook for this project.  Please utilize it to continue your discovery, or if you intended to select a different site, please try selecting again.';
        }*/
        
        return result; 
        
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Used to check if the target site already contains a workbook
    Inputs: projectId, accountId
    Returns: Boolean
    History
    08/28/14      Rey Austral        Created
    09/08/14      Michael Lasala     Make method as public
    ------------------------------------------------------------*/
    public Boolean checkIfSiteContainsWorkbook(Id subProjectId, Id accountId)
    {
        //this method will search in the site_workbook object because this contains the workbook record per site and project                
        Boolean result = false;
        List<Site_Workbook__c> siteWorkbook = [ SELECT Id From Site_Workbook__c where Site__c =:accountId and SubProject__c =: subProjectId  ];
        if (!siteWorkbook.isEmpty())
        {
            result = true;
        }
        
        return result;
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Perform the clonning function
    Inputs: projectId, accountId, sourceSiteWorkbookId
    Returns: None
    History
    08/28/14      Rey Austral        Created
    ------------------------------------------------------------*/
    /*private void processCloningWorkbook(Id projectId, Id accountId, Id sourceSiteWorkbookId)
    {
         //retrieve the source workbook category values, the value will be copy to the target site
        Map<Id, Discovery_Workbook_Category__c> sourceWorkbookCategory = getProjectWorkbookstoClone(sourceSiteWorkbookId);
        if (!sourceWorkbookCategory.isEmpty()) 
        {
            //create a new site for the project
            Site_Workbook__c siteWorkBook = createSiteWorkBookc(projectId, accountId);      
            if (siteWorkBook.id != null)
            {
                //create a new workbook category based on the data of the source but different site
                List<Discovery_Workbook_Category__c> targetWorkbookCategory = cloneWorkbookCategory(sourceWorkbookCategory,siteWorkBook.id);        
                //get all question from the source site, to be used in mapping the old workbook category from the new category
                Map<Id,Question__c> allSourceQuestion = retreiveAllQuestions(sourceSiteWorkbookId);
                //get all cloneable question from the source site, to determine what answer will be copy
                Map<Id,Question__c> sourceCloneableQuestion = retreiveCloneableQuestions(sourceSiteWorkbookId);
                //get all answer from the source 
                List<Answer__c> sourceAnswer = getWorkbookAnswerstoClone(sourceWorkbookCategory);
                
                List<Answer__c> insertCloneableAnswer = new List<Answer__c>();
                List<Answer__c> insertNonCloneableAnswer = new List<Answer__c>();
                List<Answer__c> insertNullAnswer = new List<Answer__c>();
                //iterate all the answer of the source workbook
                for(Answer__c ans : sourceAnswer)
                {
                    //iterate the workbookcategory to map the answer to the category
                    for (Discovery_Workbook_Category__c workbookCategory : targetWorkbookCategory)
                    {
                        //the clone will copy the data of the source answer but need to replace the existing workbook category to the new category
                        //because we are looping the newly created workbook category we need to determine, is the answer belong to that category
                        //by comparing the old category to the new category , see the method for more details
                        if (isAnswerBelongToCategory(ans.Question__c,workbookCategory.Question_Category__c,allSourceQuestion))
                        {
                            //assign the category for each answer   
                            Answer__c newAnswer = new Answer__c();
                            newAnswer.Discovery_Workbook_Category__c = workbookCategory.id;
                            //Seperate the null answer, cloneable, non-cloneable w/ answer
                            if (isAnswerNull(ans) == true)
                            {
                                newAnswer.Question__c = ans.Question__c;                    
                                
                                if (sourceCloneableQuestion.containsKey(ans.Question__c))
                                { 
                                    newAnswer.Any_Answer__c = ans.Any_Answer__c;
                                }
                                insertNullAnswer.add(newAnswer);
                            }
                            else
                            {
                                //check if the source question is cloneable, sourceCloneableQuestion contains all cloneable question
                                //only cloneable answer can be copy to the target site
                                if (sourceCloneableQuestion.containsKey(ans.Question__c))
                                {                           
                                    newAnswer.Date_Answer__c = ans.Date_Answer__c;
                                    newAnswer.YesNo_Answer__c = ans.YesNo_Answer__c;
                                    newAnswer.Text_Answer__c = ans.Text_Answer__c;
                                    newAnswer.Number_Answer__c = ans.Number_Answer__c;                          
                                    newAnswer.Currency_Answer__c = ans.Currency_Answer__c;
                                    newAnswer.Checkbox_Answer__c = ans.Checkbox_Answer__c;
                                    newAnswer.Date_Answer__c = ans.Date_Answer__c;
                                    newAnswer.URL_Answer__c = ans.URL_Answer__c;
                                    newAnswer.MultiSelect_Picklist_Answer__c = ans.MultiSelect_Picklist_Answer__c;
                                    newAnswer.Picklist_Answer__c = ans.Picklist_Answer__c;
                                    newAnswer.Any_Answer__c = ans.Any_Answer__c;
                                    newAnswer.Question__c = ans.Question__c;
                                    insertCloneableAnswer.add(newAnswer);
                                }
                                else
                                {
                                    //do not save the answer of the question is non-cloneable                           
                                    newAnswer.Question__c = ans.Question__c;
                                    insertNonCloneableAnswer.add(newAnswer);
                                }
                            }
                        }
                    }
                }
                
                if (!insertCloneableAnswer.isEmpty())
                {
                    try
                    {
                        insert insertCloneableAnswer;
                    }        
                    catch (DmlException e){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                        System.debug('$$$ insertCloneableAnswer DmlException: '+e);
                    }
                }
                
                if (!insertNonCloneableAnswer.isEmpty())
                {
                    try
                    {
                        insert insertNonCloneableAnswer;
                    }         
                    catch (DmlException e){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                        System.debug('$$$ insertNonCloneableAnswer DmlException: '+e);
                    }
                }
                
                if (!insertNullAnswer.isEmpty())
                {
                    try
                    {
                        insert insertNullAnswer;
                    }
                    catch (DmlException e){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                        System.debug('$$$ insertNullAnswer DmlException: '+e);
                    }
                }
            }else
            {
                ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'No Site has been created');
                ApexPages.addMessage(errMsg);
            }
        }else
        {
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.Error, 'No Workbook Category Found');
            ApexPages.addMessage(errMsg);
        }
    }*/
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Create an entry for the target site
    Inputs: projectId, accountId
    Returns: Site_Workbook__c
    History
    08/28/14      Rey Austral        Created
    ------------------------------------------------------------*/
    private Site_Workbook__c createSiteWorkBookc(Id projectId, Id accountId)
    {       
        Site_Workbook__c siteWorkbook = new Site_Workbook__c();
        siteWorkbook.Site__c = accountId;
        siteWorkbook.Project__c = projectId;
        try
        {
            Insert siteWorkbook;
        }        
        catch (DmlException e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
            System.debug('$$$ siteWorkbook DmlException: '+e);
        }
        
        return siteWorkbook;
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Create a new workbook category entry for the target but copy the content from the source
    Inputs: sourceWorkbookCategory, siteId
    Returns: List<Discovery_Workbook_Category__c>
    History
    08/28/14      Rey Austral        Created
    ------------------------------------------------------------*/
    private List<Discovery_Workbook_Category__c> cloneWorkbookCategory(Map<Id, Discovery_Workbook_Category__c> sourceWorkbookCategory,Id siteId)
    {       
        List<Discovery_Workbook_Category__c> newWorkbookCetegory = new List<Discovery_Workbook_Category__c>();
        for (Discovery_Workbook_Category__c sourceCategory : sourceWorkbookCategory.values())
        {
            Discovery_Workbook_Category__c newCategory = new Discovery_Workbook_Category__c();
            newCategory.Site_Workbook__c = siteId;
            newCategory.Question_Category__c = sourceCategory.Question_Category__c;
            newCategory.Count_of_Questions__c = sourceCategory.Count_of_Questions__c;
            newWorkbookCetegory.add(newCategory);
        }
        if (!newWorkbookCetegory.isEmpty())
        {
            try
            {
                insert newWorkbookCetegory;
            }
            catch (DmlException e){
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                System.debug('$$$ newWorkbookCetegory DmlException: '+e);
            }
        }
        
        return newWorkbookCetegory;
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Retrieve all the question category from the source but filter it isdeleted = false
    Inputs: sourceSiteWorkbookId
    Returns:  Map<Id, Discovery_Workbook_Category__c>
    History
    08/28/14      Rey Austral        Created
    ------------------------------------------------------------*/
    private Map<Id, Discovery_Workbook_Category__c> getProjectWorkbookstoClone(Id sourceSiteWorkbookId)
    {       
        List<Discovery_Workbook_Category__c> lstCategory =  [ SELECT IsDeleted, Deleted__c, Name, LastModifiedById,  
                                                             Question_Category__c, Count_of_Questions__c, Id, Site_Workbook__c
                                                             FROM Discovery_Workbook_Category__c where  Site_Workbook__c = : sourceSiteWorkbookId and IsDeleted = false];
        //add to map for easy manipulation or comparing of data         
        Map<Id, Discovery_Workbook_Category__c> mapCategory = new Map<Id, Discovery_Workbook_Category__c>();
        if (!lstCategory.isEmpty())
        {
            for (Discovery_Workbook_Category__c category: lstCategory )
            {
                mapCategory.put(category.id,category);
            }
        }
        
        return mapCategory;
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Get all the answer from the source
    Inputs: sourceWorkbookCategory
    Returns: List<Answer__c>
    History
    08/28/14      Rey Austral        Created
    ------------------------------------------------------------*/
   /* private List<Answer__c> getWorkbookAnswerstoClone(Map<id,Discovery_Workbook_Category__c> sourceWorkbookCategory)
    {
        return [Select YesNo_Answer__c, Text_Answer__c,  Question__c, Number_Answer__c, Discovery_Workbook_Category__c , Date_Answer__c,
                Currency_Answer__c, Checkbox_Answer__c , Any_Answer__c, Picklist_Answer__c, MultiSelect_Picklist_Answer__c, URL_Answer__c
                From Answer__c where Discovery_Workbook_Category__c in : sourceWorkbookCategory.keySet() ];
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Retrieve all the cloneable question from the source
    Inputs: sourceSiteWorkbookId
    Returns: Map<Id,Question__c>
    History
    08/28/14      Rey Austral        Created
    ------------------------------------------------------------*/
    /*private Map<Id,Question__c> retreiveCloneableQuestions(Id sourceSiteWorkbookId)
    {       
        List<Question__c> lstQuestion=  [SELECT Id,Question_Category__c FROM Question__c 
                                         where Cloneable__c = true
                                         and Question_Category__c in 
                                         (Select Question_Category__c from Discovery_Workbook_Category__c  where Site_Workbook__c = : sourceSiteWorkbookId)];
        Map<Id, Question__c> mapQuestion = new Map<Id, Question__c>();
        if (!lstQuestion.isEmpty())
        {
            for (Question__c quest : lstQuestion)
            {
                mapQuestion.put(quest.id,quest);
            }
        }
        
        return mapQuestion;
    }*/
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Retreive all the question
    Inputs: sourceSiteWorkbookId
    Returns: Map<Id,Question__c>
    History
    08/28/14      Rey Austral        Created
    ------------------------------------------------------------*/
    /*private Map<Id,Question__c> retreiveAllQuestions(Id sourceSiteWorkbookId)
    {       
        List<Question__c> lstQuestion=  [SELECT Id,Question_Category__c FROM Question__c 
                                         where Question_Category__c in 
                                         (Select Question_Category__c from Discovery_Workbook_Category__c  where Site_Workbook__c = : sourceSiteWorkbookId)];
        Map<Id, Question__c> mapQuestion = new Map<Id, Question__c>();
        if (!lstQuestion.isEmpty())
        {
            for (Question__c quest : lstQuestion)
            {
                mapQuestion.put(quest.id,quest);
            }
        }
        
        return mapQuestion;
    }*/
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Validate if the answer is null
    Inputs: ans
    Returns: Boolean
    History
    08/28/14      Rey Austral        Created
    ------------------------------------------------------------*/
    private Boolean isAnswerNull(Answer__c ans)
    {       
        Boolean result = false;
        if (ans.YesNo_Answer__c == null && ans.Text_Answer__c == null && ans.Number_Answer__c == null && ans.Date_Answer__c == null && ans.Checkbox_Answer__c == false
            && ans.Currency_Answer__c == null && ans.URL_Answer__c == null && ans.MultiSelect_Picklist_Answer__c == null && ans.Picklist_Answer__c == null)
        {
            result = true;
        }
        return result;
    }
    /*------------------------------------------------------------
    Author: Rey Austral
    Company: Cloud Sherpas
    Description: Check if the answer belongs to the question category
    Inputs: answersQuestionId, targetWorkbookCategory_Question_CategoryId, questions
    Returns: Boolean
    History
    08/28/14      Rey Austral        Created
    ------------------------------------------------------------*/
    /*private Boolean isAnswerBelongToCategory(Id answersQuestionId, Id targetWorkbookCategory_Question_CategoryId, Map<Id,Question__c> questions)
    {
        Boolean result = false;
        //validate if the answer question id is still exist, to avoid error when the admin accidentally delete the question
        if (questions.containsKey(answersQuestionId))
        {
            //get the details of the question
            Question__c quest = questions.get(answersQuestionId);
            //check if the current item in the loop have the same question category of the workbook
            //we can only link the new category to the old answer by looking in the question category id of the question object
            if (quest.Question_Category__c == targetWorkbookCategory_Question_CategoryId)
            {
                result = true;
            }
        }
        
        return result;
    }*/
}