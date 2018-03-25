/*
*06/15/2015 - Venkata Shrivol - Created
*Description: used to copy workbooks from one Site to another Site withIn same SubProject
*-----HISTORY----- 
*2016-12-06 -venkata.shrivol@cdk.com -commented the code as this class is no longer required. 
*/
 public with sharing class IMP_CopyWorkbooksToAnotherSite_Extension 
{
   /* public SubProject__c thisSubProject{get;set;}
    public string subProjectId {get;set;}
    public string sourceSiteId {get;set;}
    public string targetSiteId{get;set;}
    public string srcAccount {get; set;}
    public string  trgAccount{get; set;}
    public list<SubProjectSite__c> sourceSiteList{get;set;}
    public list<SubProjectSite__c> targetSiteList{get;set;}
    public list<sourceSiteProductWrapper> srcSiteProducts {get;set;}
    public list<Site_Product__c> trgtSiteProducts {get;set;}
    public map<Id,set<Id>> siteToProductMap {get; set;}
    public map<Id,Id> srcSiteToAccountMap {get; set;}
    public map<Id,Id> trgSiteToAccountMap {get; set;}
    
    public IMP_CopyWorkbooksToAnotherSite_Extension()
    {
        
        sourceSiteList = new list<SubProjectSite__c>();
        targetSiteList = new list<SubProjectSite__c>();
        srcSiteProducts = new list<sourceSiteProductWrapper>();
        trgtSiteProducts = new list<Site_Product__c>();
        siteToProductMap = new map<Id, set<Id>>();
        srcSiteToAccountMap = new map<Id,Id>();
        trgSiteToAccountMap = new map<Id,Id>();
        srcAccount='';
        trgAccount='';
        
        subProjectId = ApexPages.currentPage().getParameters().get('id');
        if(subProjectId!=null)
        {
            list<SubProject__c> tempSubProList = [select Market__c, Project_Type__c, Project__c from SubProject__c where Id=:subProjectId];
            thisSubProject = tempSubProList.size()>0 ? tempSubProList.get(0) : new SubProject__c();
            
            
            sourceSiteList = [
                select Id, Account__r.Name,Account__c from SubProjectSite__c where SubProject__c =:subProjectId
                and Account__c IN (select Site__c from Site_Workbook__c where SubProject__c=:subProjectId)
            ];
            system.debug('-----SourceSites----'+sourceSiteList);
            
            if(!sourceSiteList.isEmpty())
            {
                for(SubProjectSite__c sp:sourceSiteList)
                {
                    srcSiteToAccountMap.put(sp.Id, sp.Account__c);
                }
                targetSiteList = [
                    select Account__r.Name,Account__c from SubProjectSite__c where SubProject__c =:subProjectId
                    and Account__c NOT IN 
                    (select Site__c from Site_Workbook__c where SubProject__c=:subProjectId)
                ];
                system.debug('-----destinationSites----'+targetSiteList);
                if(!targetSiteList.isEmpty())
                {
                    for(SubProjectSite__c sp:targetSiteList)
                    {
                        trgSiteToAccountMap.put(sp.Id, sp.Account__c);
                    }
                }
                    
            }
            
        }
        
    }
        
    public list<SelectOption> getSourceSites()
    {
        return buildOptions(sourceSiteList);
    }
    public list<SelectOption> getTargetSites()
    {
        return buildOptions(targetSiteList);
    }
    
    public list<SelectOption> buildOptions(list<SubProjectSite__c> siteList)
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','---None---'));
        if(!siteList.isEmpty())
        {
            for(SubProjectSite__c site:siteList)
            {
                options.add(new SelectOption(site.Id, site.Account__r.Name));
            }
        }
        //system.debug('------options------'+options);
        return options;
    }
    
    
    
    public void getSiteProducts()
    {
        String sourceSiteId = ApexPages.currentPage().getParameters().get('sourceSiteId');
        String targetSiteId = ApexPages.currentPage().getParameters().get('targetSiteId');
        set<Id> siteIds = new set<Id>();        
        map<String, List<Site_Product__c>> siteProdMap = new map<String, List<Site_Product__c>>();
        
        list<Site_Product__c> siteProductList = [
            select Id, Product__c, Product__r.Name, SubProjectSite__r.Account__r.Name, SubProjectSite__c, SubProjectSite__r.Account__c 
            from Site_Product__c 
            where SubProjectSite__c =: sourceSiteId or SubProjectSite__c =:targetSiteId];
        
        
        //List<Site_Product__c> tempSPLst = null;
        for(Site_Product__c sp:siteProductList)
        {
            List<Site_Product__c> tempSPLst = siteProdMap.containsKey(sp.SubProjectSite__c) ? siteProdMap.get(sp.SubProjectSite__c) : new list<Site_Product__c>();
            /*String keyVal = sp.SubProjectSite__c;
            if(siteProdMap.get(keyVal) == null){
                tempSPLst = new List<Site_Product__c>();
            }*/
           /* tempSPLst.add(sp);
            siteProdMap.put(sp.SubProjectSite__c, tempSPLst);
        }
        
        srcSiteProducts = new List<sourceSiteProductWrapper>();
        trgtSiteProducts = new List<Site_Product__c>();
        trgAccount = '';
        srcAccount='';
         
        if(sourceSiteId != ''  && sourceSiteId != null)
        {
            if(siteProdMap.get(sourceSiteId)!=null)
            {
                for(Site_Product__c sp:siteProdMap.get(sourceSiteId))
                {
                    sourceSiteProductWrapper sourceWrap = new sourceSiteProductWrapper();
                    sourceWrap.sourceProductName = sp.Product__r.Name;
                    sourceWrap.sourceProdId = sp.Product__c;
                    sourceWrap.toCopyThisProduct = false;
                    sourceWrap.checkDisable = false; //checkThisProductInTargetSite(sp.Product__c);
                    srcSiteProducts.add(sourceWrap);
                }
            }
            if(srcSiteToAccountMap.get(sourceSiteId)!=null){
                srcAccount = srcSiteToAccountMap.get(sourceSiteId);
            }
        }
        system.debug('----srcSiteProducts---'+srcSiteProducts);
        
        if(targetSiteId != ''  && targetSiteId != null)
        {
            if(siteProdMap.get(targetSiteId)!=null)
            {
                trgtSiteProducts.addAll(siteProdMap.get(targetSiteId));
                disableCheckboxOfCommonProducts(srcSiteProducts, trgtSiteProducts);
            }
            if(trgSiteToAccountMap.get(targetSiteId)!=null){
                trgAccount = trgSiteToAccountMap.get(targetSiteId);
            }   
        }
        system.debug('-----srcAccount----'+srcAccount);
        system.debug('----trgAccount------'+trgAccount);    
        
    }
    
    public void copyWorkbook()
    {
        set<Id> srcProductIds = new set<Id>();
        set<Id> srcProdIdsToCopy = new set<Id>();
        set<Id> targetProductIds = new set<Id>();
        set<Id> sourceQuestionIds = new set<Id>();
        set<Id> targetQuestionIds = new set<Id>();
        set<Id> commonQuestionIds = new set<Id>();
        map<Id,set<Id>> categoryToQuestionMap = new map<Id,set<Id>>();
        map<Id,Answer__c> questionToAnswerMap = new map<Id,Answer__c>();
        map<Id,Id> createdAnswerToQuestionMap = new map<Id,Id>();
        map<Id,Discovery_Workbook_Category__c> wkbookCategoryViaQuestionCategoryMap = new map<Id,Discovery_Workbook_Category__c>();
        
        system.debug('---srcSiteProducts in Copy Workbook----'+srcSiteProducts);
        system.debug('---targetSiteId----'+targetSiteId);
        
        if(srcAccount!='' && trgAccount!='')
        {
            if(!CheckIfSiteContainsWorkbook(subProjectId, trgAccount))
            {
                for(sourceSiteProductWrapper spw:srcSiteProducts)
                {
                    if(spw.toCopyThisProduct)
                    {
                        srcProdIdsToCopy.add(spw.sourceProdId);
                    }
                }
                if(targetSiteId!=null && !srcProdIdsToCopy.isEmpty())
                {
                    createSiteProductsforTargetSite(targetSiteId, srcProdIdsToCopy, subProjectId);
                }
                for(Site_Product__c sp:trgtSiteProducts)
                {
                    targetProductIds.add(sp.Product__c);
                }
                targetProductIds.addAll(srcProdIdsToCopy);
                list<Answer__c> sourceSiteAnswers = [
                    select Question__c, Any_Answer__c,Checkbox_Answer__c,Currency_Answer__c, Date_Answer__c, MultiSelect_Picklist_Answer__c,
                    N_A__c, Number_Answer__c, Phone_Answer__c, Picklist_Answer__c,Text_Answer__c, URL_Answer__c, YesNo_Answer__c from Answer__c 
                    where Question__r.Cloneable__c = true and 
                    Discovery_Site_Workbook__c IN
                    (select Id from Site_Workbook__c where SubProject__c =:subProjectId and Site__c=:srcAccount)];
                
                for(Answer__c ans:sourceSiteAnswers)
                {
                    sourceQuestionIds.add(ans.Question__c);
                    questionToAnswerMap.put(ans.Question__c, ans);  
                }
                
                list<Discovery_Question_Product__c> qsWithProducts = [
                    select Question__c, Product__r.Solution__r.Question_Category__c from Discovery_Question_Product__c 
                    WHERE Question__r.Active__c =  true
                    and (
                    (Question__r.Market__c includes(:thisSubProject.Market__c) and Question__r.Project_Type__c includes (:thisSubProject.Project_Type__c)) 
                    and 
                    (Product__c IN :targetProductIds)
                        )
                     ]; 
                for(Discovery_Question_Product__c dqp:qsWithProducts)
                {
                    targetQuestionIds.add(dqp.Question__c); 
                    set<Id> tempSet = categoryToQuestionMap.containsKey(dqp.Product__r.Solution__r.Question_Category__c) ? categoryToQuestionMap.get(dqp.Product__r.Solution__r.Question_Category__c) : new set<Id>();
                    tempSet.add(dqp.Question__c);
                    categoryToQuestionMap.put(dqp.Product__r.Solution__r.Question_Category__c, tempSet);
                    
                }
                list<Discovery_Question_Category__c> qsWithNoProducts = [
                    select Discovery_Question__c, Question_Category__c from Discovery_Question_Category__c 
                    where Discovery_Question__r.Active__c =  true and 
                    (Discovery_Question__r.Market__c includes(:thisSubProject.Market__c) 
                        and Discovery_Question__r.Project_Type__c includes (:thisSubProject.Project_Type__c))
                ];
                for(Discovery_Question_Category__c dqp:qsWithNoProducts)
                {
                    targetQuestionIds.add(dqp.Discovery_Question__c);
                    set<Id> tempSet = categoryToQuestionMap.containsKey(dqp.Question_Category__c) ? categoryToQuestionMap.get(dqp.Question_Category__c) : new set<Id>();
                    tempSet.add(dqp.Discovery_Question__c);
                    categoryToQuestionMap.put(dqp.Question_Category__c, tempSet);   
                }
                system.debug('-------targetQuestionIds-------'+targetQuestionIds);  
                for(Id qId:sourceQuestionIds)
                {
                    if(targetQuestionIds.contains(qId))
                    {
                        commonQuestionIds.add(qId);
                    }
                }
                if(!commonQuestionIds.isEmpty())
                {
                    Site_Workbook__c targetSiteWorkbook = CreateSiteWorkbook(subProjectId,trgAccount);
                    if(targetSiteWorkbook.Id!=null)
                    {
                        list<Discovery_Workbook_Category__c> targetSiteWkbkCategories = createSiteWorkbookCategories(targetSiteWorkbook.Id, categoryToQuestionMap);
                        for(Discovery_Workbook_Category__c wkbookCategory : targetSiteWkbkCategories)
                        {
                            if(!wkbookCategoryViaQuestionCategoryMap.containsKey(wkbookCategory.Question_Category__c)){
                                wkbookCategoryViaQuestionCategoryMap.put(wkbookCategory.Question_Category__c, wkbookCategory);
                            }
                        }
                        list<Answer__c> answerListToInsert = new list<Answer__c>();
                        set<Id> finalQuestionSet = new set<Id>();
                        for(Id qcId:categoryToQuestionMap.keySet())
                        {
                            for(Id qId:categoryToQuestionMap.get(qcId))
                            {
                                if(!finalQuestionSet.contains(qId))
                                {
                                    Answer__c createdAnswer = new Answer__c();
                                    //createdAnswer.Discovery_Workbook_Category__c = wkbookCategoryViaQuestionCategoryMap.get(qcId).Id;
                                    createdAnswer.Discovery_Site_Workbook__c = wkbookCategoryViaQuestionCategoryMap.get(qcId).Site_Workbook__c;
                                    if(questionToAnswerMap.keySet().contains(qId))
                                    {
                                        if(isAnswerNull(questionToAnswerMap.get(qId)))
                                        {
                                            createdAnswer.Question__c = qId;
                                        }
                                        else
                                        {
                                            createdAnswer.Date_Answer__c = questionToAnswerMap.get(qId).Date_Answer__c;
                                            createdAnswer.YesNo_Answer__c = questionToAnswerMap.get(qId).YesNo_Answer__c;
                                            createdAnswer.Text_Answer__c = questionToAnswerMap.get(qId).Text_Answer__c;
                                            createdAnswer.Number_Answer__c = questionToAnswerMap.get(qId).Number_Answer__c;                          
                                            createdAnswer.Currency_Answer__c = questionToAnswerMap.get(qId).Currency_Answer__c;
                                            createdAnswer.Checkbox_Answer__c = questionToAnswerMap.get(qId).Checkbox_Answer__c;
                                            createdAnswer.Date_Answer__c = questionToAnswerMap.get(qId).Date_Answer__c;
                                            createdAnswer.URL_Answer__c = questionToAnswerMap.get(qId).URL_Answer__c;
                                            createdAnswer.MultiSelect_Picklist_Answer__c = questionToAnswerMap.get(qId).MultiSelect_Picklist_Answer__c;
                                            createdAnswer.Picklist_Answer__c = questionToAnswerMap.get(qId).Picklist_Answer__c;
                                            createdAnswer.Phone_Answer__c = questionToAnswerMap.get(qId).Phone_Answer__c;
                                            createdAnswer.N_A__c = questionToAnswerMap.get(qId).N_A__c;
                                            createdAnswer.Any_Answer__c = questionToAnswerMap.get(qId).Any_Answer__c;
                                            createdAnswer.Question__c = qId;
                                        }
                                    }
                                    else
                                    {
                                        createdAnswer.Question__c = qId;
                                    }
                                    finalQuestionSet.add(qId);
                                    answerListToInsert.add(createdAnswer);
                                }
                            }
                        }
                        if(!answerListToInsert.isEmpty())
                        {
                            try{insert answerListToInsert;}
                            catch(Exception e){system.debug(e);}
                        }
                        for(Answer__c ans:answerListToInsert)
                        {
                            createdAnswerToQuestionMap.put(ans.Question__c, ans.Id);
                        }
                        //system.debug('---------answerToQuestionMap-------'+answerToQuestionMap);
                        list<Discovery_Answer_Workbook_Category__c> ansWkbkCatListToInsert = 
                        new list<Discovery_Answer_Workbook_Category__c>();
                        for(Id qcId: categoryToQuestionMap.keySet())
                        {
                            for(Id qId:categoryToQuestionMap.get(qcId))
                            {
                                Discovery_Answer_Workbook_Category__c createdAnswerWBCategory = new Discovery_Answer_Workbook_Category__c();
                                createdAnswerWBCategory.Answer__c = createdAnswerToQuestionMap.get(qId);
                                createdAnswerWBCategory.Discovery_Workbook_Category__c = wkbookCategoryViaQuestionCategoryMap.get(qcId).Id;
                                ansWkbkCatListToInsert.add(createdAnswerWBCategory);
                            }
                        }
                        if(ansWkbkCatListToInsert.size()> 0)
                        {
                            try{ insert ansWkbkCatListToInsert; }
                            catch(DmlException e)
                            {
                                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, e.getMessage()));
                            }
                        } 
                    }
                }
                else
                {
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'The Source and Target Site does not have any common Questions related to their Products');
                    ApexPages.addMessage(errorMsg);
                }
            }
            else
            {
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'The workbook for this Site already exists');
                ApexPages.addMessage(errorMsg);
            }
        }
        else
        {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please select at least one Source Site and One TargetSite');
            ApexPages.addMessage(errorMsg);
        }
    }
    
    public Site_Workbook__c CreateSiteWorkbook(string subProjectId, string trgAccount)
    {
        Site_Workbook__c createdSiteWorkbook = new Site_Workbook__c();
        createdSiteWorkbook.SubProject__c = subProjectId;
        createdSiteWorkbook.Project__c= thisSubProject.Project__c;
        createdSiteWorkbook.Site__c=trgAccount;
        try { insert createdSiteWorkbook;}
        catch(Exception e)
        {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, e.getMessage());
            ApexPages.addMessage(errorMsg);
        }
        
        return createdSiteWorkbook;
    }
    
    public list<Discovery_Workbook_Category__c> createSiteWorkbookCategories(Id siteWkbkId, map<Id,set<Id>> QuestionCategoryMap)
    {
        list<Discovery_Workbook_Category__c> wkbkCategoriesToInsert = new list<Discovery_Workbook_Category__c>();
        if(!QuestionCategoryMap.keySet().isEmpty())
        {
            for(Id qcId:QuestionCategoryMap.keySet())
            {
                Discovery_Workbook_Category__c dwc = new Discovery_Workbook_Category__c();
                dwc.Site_Workbook__c=siteWkbkId;
                dwc.Question_Category__c=qcId;
                dwc.Count_of_Questions__c=QuestionCategoryMap.get(qcId).size();
                wkbkCategoriesToInsert.add(dwc);
            }
            try {insert wkbkCategoriesToInsert;}
            catch(Exception e){system.debug(e);}
        }
        return wkbkCategoriesToInsert;
    }
    
    public boolean isAnswerNull(Answer__c ans)
    {
        boolean result = false;
        if (ans.YesNo_Answer__c == null && ans.Text_Answer__c == null && ans.Number_Answer__c == null && ans.Date_Answer__c == null && ans.Checkbox_Answer__c == false
            && ans.Currency_Answer__c == null && ans.URL_Answer__c == null && ans.MultiSelect_Picklist_Answer__c == null && ans.Picklist_Answer__c == null 
            && ans.Phone_Answer__c==null && ans.N_A__c== false)
        {
            result = true;
        }
        return result;
    }
    public boolean checkIfSiteContainsWorkbook(Id subProjectId, string accountId)
    {
        Boolean result = false;
        List<Site_Workbook__c> siteWorkbook = [ SELECT Id From Site_Workbook__c where Site__c =:accountId and SubProject__c =: subProjectId  ];
        if (!siteWorkbook.isEmpty())
        {
            result = true;
        }
        
        return result;
    }
    public void disableCheckboxOfCommonProducts(list<sourceSiteProductWrapper> sourceSiteProds, list<Site_Product__c> trgtSiteProducts)
    {
        set<Id> targetProdIds = new set<Id>();
        if(!sourceSiteProds.isEmpty())
        {
            for(Site_Product__c sp:trgtSiteProducts)
            {
                targetProdIds.add(sp.Product__c);
            }
            for(sourceSiteProductWrapper sp:sourceSiteProds)
            {
                if(targetProdIds.contains(sp.sourceProdId)){
                    sp.checkDisable=true;
                }
            }
        }
    }
    
    public void createSiteProductsforTargetSite(string targetSiteId, set<Id> ProductIds, string subProjectId)
    {
        list<Site_Product__c> listToInsert = new list<Site_Product__c>();
        for(Id prdId:ProductIds)
        {
            Site_Product__c sp = new Site_Product__c();
            sp.Product__c = prdId;
            sp.SubProjectSite__c = targetSiteId;
            sp.SubProject__c = subProjectId;
            sp.SiteProduct_Ext_Id__c = targetSiteId + prdId;
            listToInsert.add(sp);
        }
        try { insert listToInsert; }
        catch(Exception e){ system.debug('----Exception-----'+e); }
    }
    public class sourceSiteProductWrapper
    {
        public string sourceProductName {get; set;}
        public string sourceProdId {get; set;}
        public boolean toCopyThisProduct {get; set;}
        public boolean checkDisable{get; set;}
    }*/
}