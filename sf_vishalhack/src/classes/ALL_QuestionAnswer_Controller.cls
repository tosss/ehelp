//2016-08-22- anirudh.singh@cdk.com- Created this class for ALL_QuestionAnswer Visualforce Component.
//2017-05-05- anirudh.singh@cdk.com- Modified this JS for RQ-09205 Discovery - Add a Comments question for each tab.
public class ALL_QuestionAnswer_Controller
{
    public String categoryNameForRecs{get; set;}
    public String subCategoryNameForRecs{get; set;}
    public Id discoverySiteWorkbookIdForRecs{get; set;}
    public String orderByFieldName{get; set;}
    public String questionIdsForRecs{get; set;}
    public String questionsScenario{get; set;}
    public String productNameForRecs{get; set;}
    public String saveActionFunctionName{get; set;}
    
    //This Boolean variable is used to prevent the initialization of the setters twice on the load of the component.
    private Boolean initialized=false;
    private transient List<QuestionAnswerWrapper> pdfWrapperList{get; set;}
    
    public List<QuestionAnswerWrapper> questionAnswerWrapperList
    {
        get
        {
            if(!initialized && (categoryNameForRecs!=Null || questionIdsForRecs!=Null) 
               && discoverySiteWorkbookIdForRecs!=Null)
            {
                initialized=true;
                
                saveActionFunctionName=(questionsScenario!='pdf') ? fetchActionFunctionName(categoryNameForRecs, subCategoryNameForRecs, productNameForRecs) : Null;
                
                List<QuestionAnswerWrapper> tempWrapperList=fetchQuestionAnswerRecords(categoryNameForRecs, subCategoryNameForRecs, 
                                                                                       discoverySiteWorkbookIdForRecs, orderByFieldName, 
                                                                                       questionIdsForRecs, questionsScenario);
                questionAnswerWrapperList=(questionsScenario!='pdf') ? tempWrapperList : Null;
                pdfWrapperList=(questionsScenario=='pdf') ? tempWrapperList : Null;
            }
            return (questionAnswerWrapperList==Null ? pdfWrapperList : questionAnswerWrapperList);
        }
        set;
    }
    
    private static String fetchActionFunctionName(String categoryNameForRecs, String subCategoryNameForRecs, String productNameForRecs)
    {
        String actionFunctionName='';
        if(subCategoryNameForRecs!=Null && subCategoryNameForRecs!='')
        {
            actionFunctionName=subCategoryNameForRecs;
        }
        else if(productNameForRecs!=Null && productNameForRecs!='')
        {
            actionFunctionName=productNameForRecs;
        }
        else
        {
            actionFunctionName=categoryNameForRecs;
        }
        
        return actionFunctionName.replaceAll('[^A-Za-z]+', '').toLowerCase();
    }
    
    private static List<QuestionAnswerWrapper> fetchQuestionAnswerRecords(String categoryNameForRecs, String subCategoryNameForRecs, 
                                                                          Id discoverySiteWorkbookIdForRecs, String orderByFieldName, 
                                                                          String questionIdsForRecs, String questionsScenario)
    {
        List<QuestionAnswerWrapper> questionAnswerWrapperList=new List<QuestionAnswerWrapper>();
        
        String queryString='SELECT Id, Name, Discovery_Question_Text__c, Active__c, Answer_DataType__c, General_Category__c, '
            +'Help_Text__c, Note__c, Order__c, Parent_Question__c, Picklist_Values__c, Question_Type__c, Parent_Question__r.Name'
            +', Parent_Answer_For_Child_Rendering__c, Parent_Question__r.Answer_DataType__c, '
            +'('
            +   'SELECT Id, Checkbox_Answer__c, Currency_Answer__c, Date_Answer__c, Date_Time_Answer__c, Discovery_Question__c, '
            +   'Email_Answer__c, Number_Answer__c, Phone_Answer__c, Picklist_Answer__c, Text_Answer__c, Long_Text_Area_Answer__c, '
            +   'Multiselect_Picklist_Answer__c, URL_Answer__c, Discovery_Site_Workbook__c, N_A__c '
            +   'FROM Discovery_Answers__r '
            +   'WHERE Discovery_Site_Workbook__c=:discoverySiteWorkbookIdForRecs '
            +')'
            +' FROM Discovery_Question__c '
            +'WHERE Active__c=true ';
        
        List<String> questionIdsList=new List<String>();
        if(subCategoryNameForRecs!=Null && subCategoryNameForRecs!='')
        {
            queryString+='AND General_Category__c INCLUDES (:subCategoryNameForRecs) ';
        }
        else if(categoryNameForRecs!=Null && categoryNameForRecs!='')
        {
            queryString+='AND General_Category__c INCLUDES (:categoryNameForRecs) ';
        }
        else if(questionIdsForRecs!=Null && questionIdsForRecs!='')
        {
            for(String questionId: questionIdsForRecs.replace('[', '').replace(']', '').split(','))
            {
                questionIdsList.add(questionId.normalizeSpace());
            }
            queryString+='AND Id IN :questionIdsList ';
        }
        
        if(orderByFieldName!=Null && orderByFieldName!='')
        {
            queryString+='ORDER BY '+orderByFieldName;
        }
        
        List<Discovery_Question__c> questionsList=new List<Discovery_Question__c>();
        try
        {
            if(questionIdsForRecs!=Null && questionIdsForRecs!='' && questionIdsList.size()>0)
            {
                List<Discovery_Question__c> tempQuestionsList=new List<Discovery_Question__c>();
                tempQuestionsList=Database.query(queryString);
                
                for(String prodQuesId: questionIdsList)
                {
                    for(Discovery_Question__c quesRef: tempQuestionsList)
                    {
                        if(prodQuesId==quesRef.Id)
                        {
                            questionsList.add(quesRef);
                            break;
                        }
                    }
                }
            }
            else
            {
                questionsList=Database.query(queryString);
            }
        }
        catch(Exception ex)
        {
            system.debug('ex---->'+ex.getMessage());
        }
        
        List<QuestionAnswerWrapper> qaWrapperList=new List<QuestionAnswerWrapper>();
        
        //Process Parent Records.
        processQA(questionsList, new Set<Id>(), qaWrapperList, questionsScenario, discoverySiteWorkbookIdForRecs);
        
        questionAnswerWrapperList.addAll(qaWrapperList);
        
        for(QuestionAnswerWrapper qaRef: qaWrapperList)
        {
            system.debug('qaRef---->'+qaRef);
        }
        
        return questionAnswerWrapperList;
    }
    
    private static void processQA(List<Discovery_Question__c> questionsList, Set<Id> parentIds, 
                                  List<QuestionAnswerWrapper> qaWrapperList, String questionsScenario, 
                                  Id discoverySiteWorkbookIdForRecs)
    {
        List<Id> parentIdsList=new List<Id>();
        parentIdsList.addAll(parentIds);
        
        Map<Id, Integer> parentIdPositionChildNoMap=new Map<Id, Integer>();
        
        Set<Id> newParentIds=new Set<Id>();
        
        if(questionsList.size()>0)
        {
            //For Topmost Parent Questions.
            if(parentIdsList.size()==0)
            {
                QuestionAnswerWrapper otherCommentsRec;
                Integer counter=0;
                
                for(Integer i=0; i<questionsList.size(); i++)
                {
                    Discovery_Question__c quesRec=questionsList[i];
                    
                    if(quesRec.Parent_Question__c==Null)
                    {
                        QuestionAnswerWrapper newRec=new QuestionAnswerWrapper();
                        processWrapperRec(quesRec, newRec, questionsScenario, discoverySiteWorkbookIdForRecs);
                        
                        if(quesRec.Question_Type__c!='Other')
                        {
                            counter=counter+1;
                            newRec.parentQuestionNumber=counter;
                            qaWrapperList.add(newRec);
                            
                            newParentIds.add(quesRec.Id);
                        }
                        else
                        {
                            otherCommentsRec=newRec;
                        }
                    }
                }
                
                //2017-05-05- anirudh.singh@cdk.com- Added the IF condition qaWrapperList.size()>0.
                if(otherCommentsRec!=Null && qaWrapperList.size()>0)
                {
                    qaWrapperList.add(0, new QuestionAnswerWrapper());
                    //2017-05-05- anirudh.singh@cdk.com- Commented the below line and added line to add the otherCommentsRec at zeroth position.
                    //qaWrapperList.set(qaWrapperList.size()-1, otherCommentsRec);
                    qaWrapperList.set(0, otherCommentsRec);
                }
            }
            //For Child Questions.
            else if(parentIdsList.size()>0)
            {
                for(Integer j=0; j<parentIdsList.size(); j++)
                {
                    for(Integer i=0; i<questionsList.size(); i++)
                    {
                        Discovery_Question__c quesRec=questionsList[i];
                        Id parentId=parentIdsList[j];
                        
                        if(quesRec.Parent_Question__c==parentId)
                        {
                            QuestionAnswerWrapper newRec=new QuestionAnswerWrapper();
                            processWrapperRec(quesRec, newRec, questionsScenario, discoverySiteWorkbookIdForRecs);
                            
                            Integer parentPosition=fetchParentPosition(qaWrapperList, parentId);
                            if(parentIdPositionChildNoMap.containsKey(parentId))
                            {
                                parentIdPositionChildNoMap.put(parentId, parentIdPositionChildNoMap.get(parentId)+1);
                            }
                            else
                            {
                                parentIdPositionChildNoMap.put(parentId, 1);
                            }
                            
                            Integer childPosition=parentPosition+parentIdPositionChildNoMap.get(parentId);
                            
                            if(qaWrapperList.size()<childPosition+1)
                            {
                                qaWrapperList.add(new QuestionAnswerWrapper());
                            }
                            
                            if(qaWrapperList.get(childPosition).questionRecord==Null)
                            {
                                qaWrapperList.set(childPosition, newRec);
                            }
                            else
                            {
                                qaWrapperList.add(childPosition, newRec);
                            }
                            
                            newParentIds.add(quesRec.Id);
                        }
                    }
                }
            }
        }
        
        if(newParentIds.size()>0)
        {
            processQA(questionsList, newParentIds, qaWrapperList, questionsScenario, discoverySiteWorkbookIdForRecs);
        }
    }
    
    private static void processWrapperRec(Discovery_Question__c quesRec, QuestionAnswerWrapper newRec, 
                                          String questionsScenario, 
                                          Id discoverySiteWorkbookIdForRecs)
    {
        newRec.questionRecord=quesRec;
        newRec.picklistValues=(quesRec.Answer_DataType__c=='Picklist' 
                               || quesRec.Answer_DataType__c=='MultiSelect Picklist') ? fetchPicklistValues(quesRec.Answer_DataType__c, 
                                                                                                            quesRec.Picklist_Values__c, 
                                                                                                            questionsScenario) : Null;
        newRec.answerFieldAPIName=fetchAnswerFieldAPIName(quesRec.Answer_DataType__c);
        
        if(quesRec.Discovery_Answers__r!=Null && quesRec.Discovery_Answers__r.size()>0)
        {
            newRec.answerRecord=quesRec.Discovery_Answers__r[0];
            newRec.existingAnswerValue=quesRec.Discovery_Answers__r[0].get(newRec.answerFieldAPIName);
        }
        else
        {
            newRec.answerRecord=new Discovery_Answer__c();
            newRec.answerRecord.Discovery_Site_Workbook__c=discoverySiteWorkbookIdForRecs;
            newRec.answerRecord.Discovery_Question__c=quesRec.Id;
        }
    }
    
    private static Integer fetchParentPosition(List<QuestionAnswerWrapper> qaWrapperList, Id parentId)
    {
        Integer position=0;
        
        for(Integer i=0; i<qaWrapperList.size(); i++)
        {
            if(qaWrapperList[i].questionRecord.Id==parentId)
            {
                position=i;
                break;
            }
        }
        
        return position;
    }
    
    private static List<SelectOption> fetchPicklistValues(String answerDataType, String picklistValuesField, 
                                                          String questionsScenario)
    {
        List<SelectOption> picklistValues=new List<SelectOption>();
        
        if(questionsScenario!='pdf')
        {
            if(answerDataType=='MultiSelect Picklist')
            {
                picklistValues.add(new SelectOption('', '--None--', true));
            }
            else
            {
                picklistValues.add(new SelectOption('', '--None--'));
            }
        }
        
        if(picklistValuesField!=Null)
        {
            if(picklistValuesField.indexOf(',')!=-1)
            {
                for(String picklistValue: picklistValuesField.split(','))
                {
                    String value=picklistValue.normalizeSpace();
                    picklistValues.add(new SelectOption(value, value));
                }
            }
            else if(picklistValuesField.indexOf(';')!=-1)
            {
                for(String picklistValue: picklistValuesField.split(';'))
                {
                    String value=picklistValue.normalizeSpace();
                    picklistValues.add(new SelectOption(value, value));
                }
            }
        }
        
        return picklistValues;
    }
    
    private static String fetchAnswerFieldAPIName(String answerDataType)
    {
        String answerFieldAPIName;
        
        if(answerDataType=='Checkbox')
        {
            answerFieldAPIName='Checkbox_Answer__c';
        }
        else if(answerDataType=='Currency')
        {
            answerFieldAPIName='Currency_Answer__c';
        }
        else if(answerDataType=='Date')
        {
            answerFieldAPIName='Date_Answer__c';
        }
        else if(answerDataType=='DateTime')
        {
            answerFieldAPIName='Date_Time_Answer__c';
        }
        else if(answerDataType=='Email')
        {
            answerFieldAPIName='Email_Answer__c';
        }
        else if(answerDataType=='Long Text Area')
        {
            answerFieldAPIName='Long_Text_Area_Answer__c';
        }
        else if(answerDataType=='Picklist')
        {
            answerFieldAPIName='Picklist_Answer__c';
        }
        else if(answerDataType=='MultiSelect Picklist')
        {
            answerFieldAPIName='Multiselect_Picklist_Answer__c';
        }
        else if(answerDataType=='Number')
        {
            answerFieldAPIName='Number_Answer__c';
        }
        else if(answerDataType=='Phone')
        {
            answerFieldAPIName='Phone_Answer__c';
        }
        else if(answerDataType=='Text')
        {
            answerFieldAPIName='Text_Answer__c';
        }
        else if(answerDataType=='URL')
        {
            answerFieldAPIName='URL_Answer__c';
        }
        
        return answerFieldAPIName;
    }
    
    @RemoteAction
    public static String networkTest()
    {
        return 'Network Connected';
    }
    
    public void saveAnswerRecords()
    {
        system.debug('Start saveAnswerRecords---->'+questionAnswerWrapperList.size());
        upsertAndDeleteRecords(questionAnswerWrapperList);
        
        system.debug('End saveAnswerRecords---->');
    }
    
    private static void upsertAndDeleteRecords(List<QuestionAnswerWrapper> questionAnswerWrapperList)
    {
        List<Discovery_Answer__c> answerRecordsToUpsertList=new List<Discovery_Answer__c>();
        List<Discovery_Answer__c> answerRecordsToDeleteList=new List<Discovery_Answer__c>();
        
        for(Integer i=0; i<questionAnswerWrapperList.size(); i++)
        {
            QuestionAnswerWrapper quesRecord=questionAnswerWrapperList[i];
            processAnswerRecords(quesRecord, answerRecordsToUpsertList, answerRecordsToDeleteList);
        }
        
        List<Database.UpsertResult> upsertResult=Database.upsert(answerRecordsToUpsertList, false);
        List<Database.DeleteResult> deleteResult=Database.delete(answerRecordsToDeleteList, false);
    }
    
    private static void processAnswerRecords(QuestionAnswerWrapper questionRecordWrapper, List<Discovery_Answer__c> answerRecordsToUpsertList, 
                                             List<Discovery_Answer__c> answerRecordsToDeleteList)
    {
        //If not Checkbox.
        if(questionRecordWrapper.questionRecord.Answer_DataType__c!='Checkbox')
        {
            //Additional Processing of Answer For Multiselect Picklist.
            if(questionRecordWrapper.questionRecord.Answer_DataType__c=='MultiSelect Picklist' 
               && questionRecordWrapper.answerRecord.Multiselect_Picklist_Answer__c!=Null)
            {
                questionRecordWrapper.answerRecord.Multiselect_Picklist_Answer__c=
                    questionRecordWrapper.answerRecord.Multiselect_Picklist_Answer__c.replace('[', '').replace(']', '').replace(',', ';');
            }
            
            //Upsert Records.
            if(questionRecordWrapper.answerRecord.get(questionRecordWrapper.answerFieldAPIName)!=Null 
               && questionRecordWrapper.answerRecord.get(questionRecordWrapper.answerFieldAPIName)!=''
               && (questionRecordWrapper.answerRecord.get('N_A__c')==false || questionRecordWrapper.questionRecord.Question_Type__c=='Other') 
               && questionRecordWrapper.answerRecord.get(questionRecordWrapper.answerFieldAPIName)!=questionRecordWrapper.existingAnswerValue)
            {
                answerRecordsToUpsertList.add(questionRecordWrapper.answerRecord);
            }
            //Insert blank records if Not Applicable is checked for that answer record.
            else if(questionRecordWrapper.answerRecord.get('N_A__c')==true)
            {
                questionRecordWrapper.answerRecord.put(questionRecordWrapper.answerFieldAPIName, Null);
                answerRecordsToUpsertList.add(questionRecordWrapper.answerRecord);
            }
            //Delete Records.
            else if(questionRecordWrapper.answerRecord.Id!=Null && questionRecordWrapper.answerRecord.get('N_A__c')==false 
                    && (questionRecordWrapper.answerRecord.get(questionRecordWrapper.answerFieldAPIName)==Null 
                        || questionRecordWrapper.answerRecord.get(questionRecordWrapper.answerFieldAPIName)==''))
            {
                answerRecordsToDeleteList.add(questionRecordWrapper.answerRecord);
            }
        }
        else
        {
            //Upsert Records.
            if(questionRecordWrapper.answerRecord.get(questionRecordWrapper.answerFieldAPIName)==true
               && questionRecordWrapper.answerRecord.get('N_A__c')==false)
            {
                answerRecordsToUpsertList.add(questionRecordWrapper.answerRecord);
            }
            //Insert blank records if Not Applicable is checked for that answer record.
            else if(questionRecordWrapper.answerRecord.get('N_A__c')==true)
            {
                questionRecordWrapper.answerRecord.put(questionRecordWrapper.answerFieldAPIName, false);
                answerRecordsToUpsertList.add(questionRecordWrapper.answerRecord);
            }
            //Delete Records.
            else if(questionRecordWrapper.answerRecord.Id!=Null && questionRecordWrapper.answerRecord.get('N_A__c')==false 
                    && questionRecordWrapper.answerRecord.get(questionRecordWrapper.answerFieldAPIName)==false)
            {
                answerRecordsToDeleteList.add(questionRecordWrapper.answerRecord);
            }
        }
    }
    
    @RemoteAction
    public static String quickSaveAnswers(String ansObject, List<String> ansCleared)
    {
        system.debug('ansObject---->'+ansObject);
        String errorMessage='';
        try
        {
            if(ansObject!=Null)
            {
                AnswerResponseWrapper ansWrapper=(AnswerResponseWrapper)JSON.deserialize(ansObject, AnswerResponseWrapper.class);
                if(ansWrapper.answerId==Null || ansWrapper.answerId=='')
                {
                    fetchAnsIdIfExisting(ansWrapper);
                }
                
                Discovery_Answer__c answerRecord=processAnsRec(ansWrapper, '');
                upsert answerRecord;
            }
            
            List<Discovery_Answer__c> ansListToDelete=new List<Discovery_Answer__c>([SELECT Id FROM Discovery_Answer__c WHERE Id IN :ansCleared]);
            if(ansListToDelete.size()>0)
            {
                delete ansListToDelete;
            }
        }
        catch(Exception ex)
        {
            errorMessage=ex.getMessage();
            system.debug('errorMessage---->'+errorMessage);
        }
        return 'Network Connected';
    }
    
    @RemoteAction
    public static String quickSaveNAAnswers(List<String> naAnsObjectList)
    {
        system.debug('naAnsObjectList---->'+naAnsObjectList);
        List<Discovery_Answer__c> ansRecords=new List<Discovery_Answer__c>();
        
        for(String jsonString: naAnsObjectList)
        {
            AnswerResponseWrapper ansWrapper=(AnswerResponseWrapper)JSON.deserialize(jsonString, AnswerResponseWrapper.class);
            if(ansWrapper.answerId==Null || ansWrapper.answerId=='')
            {
                fetchAnsIdIfExisting(ansWrapper);
            }
            
            Discovery_Answer__c answerRecord=processAnsRec(ansWrapper, 'na');
            ansRecords.add(answerRecord);
        }
        
        String errorMessage='';
        try
        {
            if(ansRecords.size()>0)
            {
                upsert ansRecords;
            }
        }
        catch(Exception ex)
        {
            errorMessage=ex.getMessage();
            system.debug('errorMessage---->'+errorMessage);
        }
        return 'Network Connected';
    }
    
    private static void fetchAnsIdIfExisting(AnswerResponseWrapper ansWrapper)
    {
        List<Discovery_Answer__c> existingAnswerList=new List<Discovery_Answer__c>([
            SELECT Id 
            FROM Discovery_Answer__c 
            WHERE Discovery_Site_Workbook__c=:ansWrapper.siteWorkBookId 
            AND Discovery_Question__c=:ansWrapper.quesId
        ]);
        
        if(existingAnswerList.size()>0)
        {
            ansWrapper.answerId=existingAnswerList[0].Id;
        }
    }
    
    private static Discovery_Answer__c processAnsRec(AnswerResponseWrapper ansWrapper, String quickSaveScenario)
    {
        String ansId=ansWrapper.answerId;
        String fieldAPIName=fetchAnswerFieldAPIName(ansWrapper.dataType);
        String fieldValue=ansWrapper.fieldValue;
        
        Discovery_Answer__c answerRecord=new Discovery_Answer__c();
        if(ansId!=Null && ansId!='')
        {
            answerRecord.Id=ansId;
        }
        else
        {
            answerRecord.Discovery_Site_Workbook__c=ansWrapper.siteWorkBookId;
            answerRecord.Discovery_Question__c=ansWrapper.quesId;
        }
        
        if(quickSaveScenario!='na')
        {
            if(fieldAPIName=='Checkbox_Answer__c')
            {
                answerRecord.put(fieldAPIName, Boolean.valueOf(fieldValue));
            }
            else if(fieldAPIName=='Number_Answer__c')
            {
                answerRecord.put(fieldAPIName, Integer.valueOf(fieldValue));
            }
            else if(fieldAPIName=='Date_Time_Answer__c')
            {
                answerRecord.put(fieldAPIName, DateTime.parse(fieldValue));
            }
            else if(fieldAPIName=='Date_Answer__c')
            {
                answerRecord.put(fieldAPIName, Date.parse(fieldValue));
            }
            else
            {
                answerRecord.put(fieldAPIName, String.valueOf(fieldValue));
            }
        }
        else
        {
            answerRecord.N_A__c=Boolean.valueOf(fieldValue);
            if(answerRecord.N_A__c)
            {
                if(fieldAPIName=='Checkbox_Answer__c')
                {
                    answerRecord.put(fieldAPIName, false);
                }
                else
                {
                    answerRecord.put(fieldAPIName, Null);
                }
            }
        }
        
        return answerRecord;
    }
    
    public class QuestionAnswerWrapper
    {
        public Discovery_Question__c questionRecord{get; set;}
        public String answerFieldAPIName{get; set;}
        public Object existingAnswerValue{get; set;}
        public List<SelectOption> picklistValues{get; set;}
        public Discovery_Answer__c answerRecord{get; set;}
        public Integer parentQuestionNumber{get; set;}
    }
    
    public class AnswerResponseWrapper
    {
        public String answerId{get; set;}
        public String dataType{get; set;}
        public String fieldValue{get; set;}
        public String siteWorkBookId{get; set;}
        public String quesId{get; set;}
    }
}