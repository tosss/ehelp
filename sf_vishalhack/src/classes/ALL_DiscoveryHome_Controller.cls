//2016-08-25- anirudh.singh@cdk.com- Created this class for ALL_DiscoveryHome Visualforce Page.
public class ALL_DiscoveryHome_Controller
{
    public String selectedTab{get; set;}
    public Opportunity_Location__c oppLocationRecord{get; set;}
    public List<HomePageWrapper> homePageWrapperList{get; set;}
    public String selectedQuesType{get; set;}
    
    public ALL_DiscoveryHome_Controller()
    {
        Id oppLocationSiteId=ApexPages.currentPage().getParameters().get('oppLocId');
        String tabNameVal=ApexPages.currentPage().getParameters().get('tabName');
        
        selectedTab=(tabNameVal==Null) ? 'Home' : tabNameVal;
        
        if(oppLocationSiteId!=Null)
        {
            oppLocationRecord=fetchLocationRecord(oppLocationSiteId);
            
            homePageWrapperList=(selectedTab!='Print Version') ? fetchWrapperList(oppLocationRecord, selectedTab, selectedQuesType) : new List<HomePageWrapper>();
        }
    }
    
    private static Opportunity_Location__c fetchLocationRecord(Id oppLocationSiteId)
    {
        Opportunity_Location__c locationRecord=[
            SELECT Id, Opportunity__r.Id, Opportunity__r.Name, Site__r.Id, Site__r.Name, 
            (
                SELECT Id FROM Discovery_Site_Workbooks__r
            ) 
            FROM Opportunity_Location__c
            WHERE Id=:oppLocationSiteId
        ];
        
        return locationRecord;
    }
    
    private static List<HomePageWrapper> fetchWrapperList(Opportunity_Location__c oppLocationRecord, String selectedTab, String selectedQuesType)
    {
        //Fetching all the Tab records.
        List<ALL_DiscoveryTab__mdt> discoveryTabRecordsList=new List<ALL_DiscoveryTab__mdt>([
            SELECT Id, MasterLabel, Related_to_Question_Answer__c, Order__c, Tab_Color__c 
            FROM ALL_DiscoveryTab__mdt 
            ORDER BY Order__c ASC
        ]);
        
        List<HomePageWrapper> homePageWrapperList=new List<HomePageWrapper>();
        homePageWrapperList=(selectedTab=='Home') ? fetchWrapperListForHomeTab(oppLocationRecord, discoveryTabRecordsList, selectedQuesType) : fetchWrapperListForNonHomeTab(discoveryTabRecordsList);
        
        return homePageWrapperList;
    }
    
    private static List<HomePageWrapper> fetchWrapperListForHomeTab(Opportunity_Location__c oppLocationRecord, List<ALL_DiscoveryTab__mdt> discoveryTabRecordsList, 
                                                                    String selectedQuesType)
    {
        List<HomePageWrapper> homePageWrapperList=new List<HomePageWrapper>();
        
        //Fetching all the Tab Contents.
        List<ALL_DiscoveryTabContent__mdt> tabContentRecordsList=new List<ALL_DiscoveryTabContent__mdt>([
            SELECT Id, Component_Name__c, Component_Order__c, Display_Header__c, Discovery_Tab_Name__r.MasterLabel 
            FROM ALL_DiscoveryTabContent__mdt 
            ORDER BY Component_Order__c
        ]);
        
        //Fetching all the Category and Sub-Category Records.
        List<ALL_DiscoveryCategory__mdt> categoriesList=new List<ALL_DiscoveryCategory__mdt>([
            SELECT Id, MasterLabel, Discovery_Tab_Content__c, Order_Field_API_Name__c, 
            (
                SELECT MasterLabel, Discovery_Category__c, Order__c, Order_Field_API_Name__c 
                FROM ALL_DiscoverySubCategories__r
                ORDER BY Order__c
            )
            FROM ALL_DiscoveryCategory__mdt
        ]);
        
        //Fetching all the SObject Detail Records.
        List<ALL_SObject__mdt> sObjectList=new List<ALL_SObject__mdt>([
            SELECT Id, MasterLabel, Discovery_Tab_Content__c, SObject_Name__c, SObject_Record_Type__c, 
            Field_Set_API_Name__c, Where_Clause_Field_API_Name__c, Building_Dependent__c 
            FROM ALL_SObject__mdt
        ]);
        
        Map<HomePageWrapper, String> homeWrapperQueryStrMap=createWrapperAndQueryStringMap(oppLocationRecord, discoveryTabRecordsList, tabContentRecordsList, 
                                                                                           categoriesList, sObjectList, homePageWrapperList, selectedQuesType);
        
        return processQueries(oppLocationRecord, homePageWrapperList, homeWrapperQueryStrMap);
    }
    
    private static Map<HomePageWrapper, String> createWrapperAndQueryStringMap(Opportunity_Location__c oppLocationRecord, List<ALL_DiscoveryTab__mdt> discoveryTabRecordsList, 
                                                                               List<ALL_DiscoveryTabContent__mdt> tabContentRecordsList, List<ALL_DiscoveryCategory__mdt> categoriesList, 
                                                                               List<ALL_SObject__mdt> sObjectList, List<HomePageWrapper> homePageWrapperList, 
                                                                               String selectedQuesType)
    {
        Map<HomePageWrapper, String> homeWrapperQueryStrMap=new Map<HomePageWrapper, String>();
        
        //Iterate the Tab records.
        for(ALL_DiscoveryTab__mdt tabRecord: discoveryTabRecordsList)
        {
            HomePageWrapper newWrapperRecord=new HomePageWrapper();
            newWrapperRecord.tabName=tabRecord.MasterLabel;
            newWrapperRecord.tabColor=processTabColor(tabRecord.Tab_Color__c);
            newWrapperRecord.relatedToQuestionsAnswer=tabRecord.Related_to_Question_Answer__c;
            
            //If the Tab record is related to Question Answers.
            if(tabRecord.Related_to_Question_Answer__c)
            {
                processHomeWrapperQueryStrMapForQA(tabContentRecordsList, tabRecord, 
                                                   oppLocationRecord, categoriesList, 
                                                   newWrapperRecord, homeWrapperQueryStrMap, 
                                                   selectedQuesType);
            }
            else if(tabRecord.MasterLabel=='Building Map')
            {
                newWrapperRecord.relatedToBuildingMap=true;
                homeWrapperQueryStrMap.put(newWrapperRecord, '');
            }
            else
            {
                processHomeWrapperQueryStrMapForOD(tabContentRecordsList, tabRecord, 
                                                   sObjectList, oppLocationRecord, 
                                                   newWrapperRecord, homeWrapperQueryStrMap);
            }
            homePageWrapperList.add(newWrapperRecord);
        }
        
        return homeWrapperQueryStrMap;
    }
    
    private static void processHomeWrapperQueryStrMapForQA(List<ALL_DiscoveryTabContent__mdt> tabContentRecordsList, ALL_DiscoveryTab__mdt tabRecord, 
                                                           Opportunity_Location__c oppLocationRecord, List<ALL_DiscoveryCategory__mdt> categoriesList, 
                                                           HomePageWrapper newWrapperRecord, Map<HomePageWrapper, String> homeWrapperQueryStrMap, 
                                                           String selectedQuesType)
    {
        //Iterate the Tab Content records.
        for(ALL_DiscoveryTabContent__mdt tabContentRecord: tabContentRecordsList)
        {
            //If the Tab Content record is for the current Tab Content Record.
            if(tabRecord.Id==tabContentRecord.Discovery_Tab_Name__c && (tabContentRecord.Component_Name__c=='ALL_QuestionAnswer' 
                                                                        || tabContentRecord.Component_Name__c=='ALL_ProductQuestions'))
            {
                String queryString=fetchQueryStringForQAComp(oppLocationRecord, tabContentRecord, categoriesList, selectedQuesType);
                homeWrapperQueryStrMap.put(newWrapperRecord, queryString);
            }
        }
    }
    
    private static String fetchQueryStringForQAComp(Opportunity_Location__c oppLocationRecord, ALL_DiscoveryTabContent__mdt tabContentRecord, 
                                                    List<ALL_DiscoveryCategory__mdt> categoriesList, String selectedQuesType)
    {
        String queryString='SELECT Id, General_Category__c, Parent_Question__c, Answer_DataType__c, Parent_Answer_For_Child_Rendering__c, Discovery_Question_Text__c, '
            +'('
            +    'SELECT Id, Checkbox_Answer__c, Currency_Answer__c, Date_Answer__c, Date_Time_Answer__c, Discovery_Question__c, '
            +    'Email_Answer__c, Number_Answer__c, Phone_Answer__c, Picklist_Answer__c, Text_Answer__c, Long_Text_Area_Answer__c, '
            +    'Multiselect_Picklist_Answer__c, URL_Answer__c, Discovery_Site_Workbook__c, N_A__c, LastModifiedBy.Name, LastModifiedDate '
            +    'FROM Discovery_Answers__r '
            +    'WHERE Discovery_Site_Workbook__c=\''+oppLocationRecord.Discovery_Site_Workbooks__r[0].Id+'\' '
            +    'ORDER BY LastModifiedDate DESC'
            +') '
            +'FROM Discovery_Question__c '
            +'WHERE Active__c=true ';
        
        if(selectedQuesType!=Null && selectedQuesType!='')
        {
            queryString+='AND Question_Type__c=\''+selectedQuesType+'\' ';
        }
        
        if(tabContentRecord.Component_Name__c=='ALL_QuestionAnswer')
        {
            //Iterate the Tab Category records.
            for(ALL_DiscoveryCategory__mdt categoryRecord: categoriesList)
            {
                //If the Category Record is for the current tab Content Record.
                if(tabContentRecord.Id==categoryRecord.Discovery_Tab_Content__c)
                {
                    queryString+='AND General_Category__c INCLUDES ';
                    
                    //If there are Sub-Category records present for the Category Record.
                    if(categoryRecord.ALL_DiscoverySubCategories__r!=Null && categoryRecord.ALL_DiscoverySubCategories__r.size()>0)
                    {
                        List<String> subCategoriesList=new List<String>();
                        for(ALL_DiscoverySubCategory__mdt subCategoryRecord: categoryRecord.ALL_DiscoverySubCategories__r)
                        {
                            subCategoriesList.add(subCategoryRecord.MasterLabel);
                        }
                        String subCategoriesString='(\''+String.join(subCategoriesList, '\',\'')+'\')';
                        queryString+=subCategoriesString;
                    }
                    else
                    {
                        List<String> tempCategoriesList=new List<String>();
                        tempCategoriesList.add(categoryRecord.MasterLabel);
                        String categoriesString='(\''+String.join(tempCategoriesList, '\',\'')+'\')';
                        queryString+=categoriesString;
                    }
                }
            }
        }
        else
        {
            queryString+='AND Id IN ';
        }
        
        return queryString;
    }
    
    private static void processHomeWrapperQueryStrMapForOD(List<ALL_DiscoveryTabContent__mdt> tabContentRecordsList, ALL_DiscoveryTab__mdt tabRecord, 
                                                           List<ALL_SObject__mdt> sObjectList, Opportunity_Location__c oppLocationRecord, 
                                                           HomePageWrapper newWrapperRecord, Map<HomePageWrapper, String> homeWrapperQueryStrMap)
    {
        //Iterate the Tab Content records.
        for(ALL_DiscoveryTabContent__mdt tabContentRecord: tabContentRecordsList)
        {
            //If the Tab Content record is for the current Tab Content Record.
            if(tabRecord.Id==tabContentRecord.Discovery_Tab_Name__c && tabContentRecord.Component_Name__c!='ALL_QuestionAnswer'
               && tabContentRecord.Component_Name__c!='ALL_DiscoveryBuildingImages')
            {
                //Iterate the ALL_SObject records.
                for(ALL_SObject__mdt sObjectRecord: sObjectList)
                {
                    //If the Category Record is for the current tab Content Record.
                    if(tabContentRecord.Id==sObjectRecord.Discovery_Tab_Content__c)
                    {
                        String queryString=fetchQueryStringForObjDetComp(oppLocationRecord, sObjectRecord);
                        homeWrapperQueryStrMap.put(newWrapperRecord, queryString);
                    }
                }
            }
        }
    }
    
    private static String fetchQueryStringForObjDetComp(Opportunity_Location__c oppLocationRecord, ALL_SObject__mdt sObjectRecord)
    {
        String queryString='SELECT Id, LastModifiedBy.Name, LastModifiedDate FROM '+sObjectRecord.SObject_Name__c+' ';
        if(!sObjectRecord.Building_Dependent__c)
        {
            queryString+='WHERE '+sObjectRecord.Where_Clause_Field_API_Name__c+'=\''+oppLocationRecord.Id+'\' ';
        }
        else
        {
            queryString+='WHERE '+sObjectRecord.Where_Clause_Field_API_Name__c+' IN :buildingRecordIds ';
        }
        queryString+='ORDER BY LastModifiedDate DESC';
        
        return queryString;
    }
    
    private static List<HomePageWrapper> processQueries(Opportunity_Location__c oppLocationRecord, List<HomePageWrapper> homePageWrapperList, 
                                                        Map<HomePageWrapper, String> homeWrapperQueryStrMap)
    {
        Set<Id> questionIds=fetchQuesIdsForQuesTab(oppLocationRecord);
        Set<Id> buildingRecordIds=fetchBuildingRecordIds(oppLocationRecord.Id);
        
        for(HomePageWrapper key: homeWrapperQueryStrMap.keySet())
        {
            String queryString=homeWrapperQueryStrMap.get(key);
            
            //If the Tab record is related to Question Answers.
            if(key.relatedToQuestionsAnswer)
            {
                processHPWrapperForQA(queryString, key, questionIds);
            }
            else if(key.relatedToBuildingMap)
            {
                key.percentComplete='100';
                key.homePageProgressSpanText='Completed';
            }
            else
            {
                processHPWrapperForObjDet(queryString, key, buildingRecordIds);
            }
        }
        
        return homePageWrapperList;
    }
    
    private static Set<Id> fetchQuesIdsForQuesTab(Opportunity_Location__c oppLocationRecord)
    {
        Set<Id> questionIds=new Set<Id>();
        
        Set<Id> allProdDefIds=new Set<Id>();
        for(Product_at_Site__c prodRec: new List<Product_at_Site__c>([
            SELECT Id, Discovery_Product_Definition__c, Discovery_Product_Definition__r.Active__c, 
            Discovery_Product_Definition__r.Department__c, Discovery_Product_Definition__r.Workflow__c
            FROM Product_at_Site__c 
            WHERE Opportunity_Location__c=:oppLocationRecord.Id 
            AND Discovery_Product_Definition__r.Active__c=true
            AND Include_Questions__c=true
        ]))
        {
            if(prodRec.Discovery_Product_Definition__r.Department__c!=Null 
               && prodRec.Discovery_Product_Definition__r.Workflow__c!=Null)
            {
                allProdDefIds.add(prodRec.Discovery_Product_Definition__c);
            }
        }
        
        List<Discovery_Product_Question__c> prodQuestsList=new List<Discovery_Product_Question__c>([
            SELECT Id, Discovery_Question__c, Discovery_Product_Definition__c
            FROM Discovery_Product_Question__c
            WHERE Discovery_Product_Definition__c IN :allProdDefIds
        ]);
        
        for(Discovery_Product_Question__c prodQuestRec: prodQuestsList)
        {
            questionIds.add(prodQuestRec.Discovery_Question__c);
        }
        
        return questionIds;
    }
    
    private static Set<Id> fetchBuildingRecordIds(Id oppLocationSiteIdForRecs)
    {
        Set<Id> buildingRecordIds=new Set<Id>();
        for(Opportunity_Location__c rec: new List<Opportunity_Location__c>([SELECT Id, Building_Site__c FROM Opportunity_Location__c WHERE Building_Site__c=:oppLocationSiteIdForRecs]))
        {
            buildingRecordIds.add(rec.Id);
        }
        
        return buildingRecordIds;
    }
    
    private static void processHPWrapperForQA(String queryString, HomePageWrapper key, Set<Id> questionIds)
    {
        if(key.tabName=='Questions')
        {
            queryString+=':questionIds';
        }
        
        Integer noOfQuesForCategory=0;
        Integer noOfAnswdQues=0;
        
        List<Discovery_Question__c> quesAnsList=database.query(queryString);
        if(quesAnsList!=Null && quesAnsList.size()>0)
        {
            for(Discovery_Question__c questionRecord: quesAnsList)
            {
                if(questionRecord.Parent_Question__c==Null)
                {
                    noOfQuesForCategory++;
                    noOfAnswdQues=fetchNoOfAnswdQues(questionRecord, noOfAnswdQues, quesAnsList);
                }
                
                if(questionRecord.Discovery_Answers__r!=Null && questionRecord.Discovery_Answers__r.size()>0)
                {
                    DateTime currentAnsModifiedDate=questionRecord.Discovery_Answers__r[0].LastModifiedDate;
                    if(key.lastModifiedDate==Null || (key.lastModifiedDate<currentAnsModifiedDate))
                    {
                        key.lastModifiedBy=questionRecord.Discovery_Answers__r[0].LastModifiedBy.Name;
                        key.lastModifiedDate=currentAnsModifiedDate;
                    }
                }
            }
        }
        
        if(noOfQuesForCategory>0)
        {
            key.percentComplete=String.valueOf(((Decimal)noOfAnswdQues/(Decimal)noOfQuesForCategory)*100);
            key.homePageProgressSpanText=noOfAnswdQues+'/'+noOfQuesForCategory+' Complete';
        }
        else
        {
            key.homePageProgressSpanText='0/0 Complete';
        }
    }
    
    private static Integer fetchNoOfAnswdQues(Discovery_Question__c questionRecord, Integer noOfAnswdQues, 
                                              List<Discovery_Question__c> quesAnsList)
    {
        if(questionRecord.Discovery_Answers__r!=Null && questionRecord.Discovery_Answers__r.size()>0)
        {
            Boolean naAns=Boolean.valueOf(questionRecord.Discovery_Answers__r[0].get('N_A__c'));
            
            if(naAns)
            {
                noOfAnswdQues++;
            }
            else
            {
                String ansDatatype=questionRecord.Answer_DataType__c;
                String ans=String.valueOf(questionRecord.Discovery_Answers__r[0].get(fetchAnswerFieldAPIName(ansDatatype)));
                String scenarioName='';
                
                if(ansDatatype=='Checkbox' && ans=='true')
                {
                    scenarioName='checkbox';
                }
                else if(ansDatatype!='Checkbox' && ans!=Null && ans!='')
                {
                    scenarioName=(ansDatatype=='Picklist' || ansDatatype=='MultiSelect Picklist') ? 'picklist' : 'other';
                }
                
                List<QuesAnsWrapper> qaWrapperList=new List<QuesAnsWrapper>();
                QuesAnsWrapper qaWrapper=new QuesAnsWrapper();
                qaWrapper.quesId=questionRecord.Id;
                qaWrapper.ans=ans;
                qaWrapper.scenarioName=scenarioName;
                qaWrapperList.add(qaWrapper);
                
                if(qaWrapper.scenarioName!='' && checkIfChildrenAnswered(quesAnsList, qaWrapperList))
                {
                    noOfAnswdQues++;
                }
            }
        }
        
        return noOfAnswdQues;
    }
    
    private static Boolean checkIfChildrenAnswered(List<Discovery_Question__c> quesAnsList, List<QuesAnsWrapper> qaWrapperList)
    {
        Boolean answered=true;
        List<QuesAnsWrapper> newQaWrapperList=new List<QuesAnsWrapper>();
        
        for(QuesAnsWrapper wrapperRef: qaWrapperList)
        {
            for(Discovery_Question__c questionRecord: quesAnsList)
            {
                //If any Child Exists.
                if(wrapperRef.quesId==questionRecord.Parent_Question__c)
                {
                    //If Answer Record Exists.
                    //Check if the Child is rendered depending on Parent Scenario.
                    //If Parent Scenario is Picklist, Check Child rendered or not.
                    //For other Scenarios, child will always be rendered.
                    if(questionRecord.Discovery_Answers__r!=Null && questionRecord.Discovery_Answers__r.size()>0)
                    {
                        Boolean naAns=Boolean.valueOf(questionRecord.Discovery_Answers__r[0].get('N_A__c'));
                        
                        if(!naAns)
                        {
                            if(wrapperRef.scenarioName=='picklist')
                            {
                                //If Parent_Answer_For_Child_Rendering__c is Null or Blank, Child Question is always rendered.
                                if(questionRecord.Parent_Answer_For_Child_Rendering__c!=Null && questionRecord.Parent_Answer_For_Child_Rendering__c!='')
                                {
                                    if(compareParentAnsAndChildRendAns(wrapperRef.ans, questionRecord.Parent_Answer_For_Child_Rendering__c))
                                    {
                                        QuesAnsWrapper qaWrapper=processChildQues(questionRecord);
                                        if(qaWrapper==Null)
                                        {
                                            answered=false;
                                            break;
                                        }
                                        else
                                        {
                                            newQaWrapperList.add(qaWrapper);
                                        }
                                    }
                                }
                                else
                                {
                                    QuesAnsWrapper qaWrapper=processChildQues(questionRecord);
                                    if(qaWrapper==Null)
                                    {
                                        answered=false;
                                        break;
                                    }
                                    else
                                    {
                                        newQaWrapperList.add(qaWrapper);
                                    }
                                }
                            }
                            else
                            {
                                QuesAnsWrapper qaWrapper=processChildQues(questionRecord);
                                if(qaWrapper==Null)
                                {
                                    answered=false;
                                    break;
                                }
                                else
                                {
                                    newQaWrapperList.add(qaWrapper);
                                }
                            }
                        }
                    }
                    //If Answer Record does not Exist.
                    //Check if the Child is rendered depending on Parent Scenario.
                    //If Parent Scenario is Picklist, Check Child rendered or not.
                    //For other Scenarios, child will always be rendered.
                    else
                    {
                        if(wrapperRef.scenarioName=='picklist')
                        {
                            //If Parent_Answer_For_Child_Rendering__c is Null or Blank, Child Question is always rendered.
                            if(questionRecord.Parent_Answer_For_Child_Rendering__c!=Null && questionRecord.Parent_Answer_For_Child_Rendering__c!='')
                            {
                                if(compareParentAnsAndChildRendAns(wrapperRef.ans, questionRecord.Parent_Answer_For_Child_Rendering__c))
                                {
                                    answered=false;
                                    break;
                                }
                            }
                            else
                            {
                                answered=false;
                                break;
                            }
                        }
                        else
                        {
                            answered=false;
                            break;
                        }
                    }
                }
            }
        }
        
        if(answered && newQaWrapperList.size()>0)
        {
            return checkIfChildrenAnswered(quesAnsList, newQaWrapperList);
        }
        
        return answered;
    }
    
    private static Boolean compareParentAnsAndChildRendAns(String currentParentAnsValue, String parentAnsForRendering)
    {
        Boolean renderChild=false;
        
        Set<String> parentAnsValList=new Set<String>();
        if(currentParentAnsValue.indexOf(',')>-1)
        {
            parentAnsValList=new Set<String>(currentParentAnsValue.split(','));
        }
        else if(currentParentAnsValue.indexOf(';')>-1)
        {
            parentAnsValList=new Set<String>(currentParentAnsValue.split(';'));
        }
        
        Set<String> parentAnsForRendList=new Set<String>();
        if(parentAnsForRendering.indexOf(',')>-1)
        {
            parentAnsForRendList=new Set<String>(parentAnsForRendering.split(','));
        }
        else if(parentAnsForRendering.indexOf(';')>-1)
        {
            parentAnsForRendList=new Set<String>(parentAnsForRendering.split(';'));
        }
        
        if(parentAnsValList.size()==0 && parentAnsForRendList.size()>0)
        {
            for(String str: parentAnsForRendList)
            {
                if(str.trim()==currentParentAnsValue)
                {
                    renderChild=true;
                    break;
                }
            }
        }
        else if(parentAnsForRendList.size()==0 && parentAnsValList.size()>0)
        {
            for(String str: parentAnsValList)
            {
                if(str.trim()==parentAnsForRendering)
                {
                    renderChild=true;
                    break;
                }
            }
        }
        else if(parentAnsForRendList.size()>0 && parentAnsValList.size()>0)
        {
            for(String str1: parentAnsValList)
            {
                for(String str2: parentAnsValList)
                {
                    if(str1.trim()==str2.trim())
                    {
                        renderChild=true;
                        break;
                    }
                }
            }
        }
        else if(currentParentAnsValue==parentAnsForRendering)
        {
            renderChild=true;
        }
        
        return renderChild;
    }
    
    private static QuesAnsWrapper processChildQues(Discovery_Question__c questionRecord)
    {
        QuesAnsWrapper qaWrapper;
        String ansDatatype=questionRecord.Answer_DataType__c;
        String ans=String.valueOf(questionRecord.Discovery_Answers__r[0].get(fetchAnswerFieldAPIName(ansDatatype)));
        String scenarioName='';
        
        if(ansDatatype=='Checkbox' && ans=='true')
        {
            scenarioName='checkbox';
        }
        else if(ansDatatype!='Checkbox' && ans!=Null && ans!='')
        {
            scenarioName=(ansDatatype=='Picklist' || ansDatatype=='MultiSelect Picklist') ? 'picklist' : 'other';
        }
        
        if(scenarioName!='')
        {
            qaWrapper=new QuesAnsWrapper();
            qaWrapper.quesId=questionRecord.Id;
            qaWrapper.ans=ans;
            qaWrapper.scenarioName=scenarioName;
        }
        
        return qaWrapper;
    }
    
    private static void processHPWrapperForObjDet(String queryString, HomePageWrapper key, Set<Id> buildingRecordIds)
    {
        List<sObject> sObjectRecordsList=database.query(queryString);
        
        if(sObjectRecordsList.size()>0 && sObjectRecordsList[0].getSObject('LastModifiedBy')!=Null)
        {
            if(key.lastModifiedDate==Null)
            {
                key.lastModifiedBy=(String)sObjectRecordsList[0].getSObject('LastModifiedBy').get('Name');
                key.lastModifiedDate=(Datetime)sObjectRecordsList[0].get('LastModifiedDate');
            }
            
            key.percentComplete='100';
            key.homePageProgressSpanText=sObjectRecordsList.size()+' record(s) present';
        }
        else
        {
            key.homePageProgressSpanText='No record(s) present';
        }
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
    
    private static List<HomePageWrapper> fetchWrapperListForNonHomeTab(List<ALL_DiscoveryTab__mdt> discoveryTabRecordsList)
    {
        List<HomePageWrapper> homePageWrapperList=new List<HomePageWrapper>();
        for(ALL_DiscoveryTab__mdt tabRecord: discoveryTabRecordsList)
        {
            HomePageWrapper newWrapperRecord=new HomePageWrapper();
            newWrapperRecord.tabName=tabRecord.MasterLabel;
            newWrapperRecord.tabColor=processTabColor(tabRecord.Tab_Color__c);
            homePageWrapperList.add(newWrapperRecord);
        }
        
        return homePageWrapperList;
    }
    
    private static String processTabColor(String recordTabColorVal)
    {
        String tabColor='';
        if(recordTabColorVal!='' && recordTabColorVal!=Null)
        {
            tabColor=recordTabColorVal.deleteWhitespace();
            tabColor=tabColor.substring(0, 1).toLowerCase()+tabColor.substring(1)+'TabColor';
        }
        return tabColor;
    }
    
    public void filterQuestions()
    {
        selectedQuesType=(selectedQuesType=='All') ? Null : selectedQuesType;
        homePageWrapperList=fetchWrapperList(oppLocationRecord, selectedTab, selectedQuesType);
    }
    
    public class QuesAnsWrapper
    {
        public Id quesId{get; set;}
        public String ans{get; set;}
        public String scenarioName{get; set;}
        
        public QuesAnsWrapper()
        {
            quesId=Null;
            ans=Null;
            scenarioName=Null;
        }
    }
    
    public class HomePageWrapper
    {
        public String tabName{get; set;}
        public String tabColor{get; set;}
        public String lastModifiedBy{get; set;}
        public DateTime lastModifiedDate{get; set;}
        public String percentComplete{get; set;}
        public Boolean relatedToQuestionsAnswer{get; set;}
        public Boolean relatedToBuildingMap{get; set;}
        public String homePageProgressSpanText{get; set;}
        
        public HomePageWrapper()
        {
            lastModifiedBy=Null;
            lastModifiedDate=Null;
            percentComplete='0';
            relatedToQuestionsAnswer=false;
            relatedToBuildingMap=false;
            homePageProgressSpanText='';
        }
    }
}