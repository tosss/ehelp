/**************************************************************
* 12/6/2016 vijay.manimaran@cdk.com created
* RQ-09217 5/4/2017 vijay.manimaran@cdk.com modified the code and cleaned to resolve soql limit.
* *************************************************************/

public class EMP_ArticleList_LTNG 
{ 
    public static String Online = 'Online';
    public static String language = 'en_US';
    public list<KnowledgeArticleVersion> KnowledgeArticleVersion = new list<KnowledgeArticleVersion>();
    public static Integer KAVcount{get;set;}
    
    @AuraEnabled
    public static Integer knowledgeArticleVersionCount(String TopicName,Integer articleCounter)
    { 
       map<ID,TopicAssignment> topicassignments = new map<ID,TopicAssignment>([
            select entityID from TopicAssignment where topic.Name =: TopicName limit 1000
        ]);
        set<ID> Ids = new Set<ID>();
        system.debug('Ids' +Ids);
        for(TopicAssignment tp :topicassignments.values()){
            Ids.add(tp.EntityId);
        }
        map<Id,KnowledgeArticleVersion> mapkarticle = new map<Id,KnowledgeArticleVersion>([
            SELECT KnowledgeArticleId, Title,UrlName,LastPublishedDate, Summary
            FROM KnowledgeArticleVersion 
            WHERE publishStatus ='Online'
            AND language = 'en_US'
            AND Id IN : Ids
            Order By Title Asc
        ]);
        Decimal articlecounts = mapkarticle.size();
        articlecounts = articlecounts/articleCounter;
        Integer articleCount = Integer.valueOf(articlecounts.round(system.roundingMode.CEILING));
        return articleCount;
    }
    
    @AuraEnabled
    public static list<knowledgeArticleWrapper> KnowledgeArticleVersion(
        String TopicName, Integer articleCounter,
        String dsg_isValid, Integer counter,
        String showPagination, String sortBy)
    {
        map<ID,TopicAssignment> topicassignments = new map<ID,TopicAssignment>([
            select entityID from TopicAssignment where topic.Name =: TopicName limit 1000
        ]);
        set<ID> Ids = new Set<ID>();
        system.debug('Ids' +Ids);
        for(TopicAssignment tp :topicassignments.values()){
            Ids.add(tp.EntityId);
        }
        
        if(showPagination=='No'){
            articleCounter = 1000;
        }
        String sortOrder;
        if(sortBy == 'Name'){
            sortBy= 'Title';
            sortOrder ='Asc';
        }else {
            sortBy = 'LastPublishedDate';
            sortOrder ='Desc'; 
        }
         String limitValue = '900';
        String articleQuery ='SELECT KnowledgeArticleId, Title,UrlName,LastPublishedDate, Summary '+
            ' FROM KnowledgeArticleVersion'+ 
            ' WHERE publishStatus =: Online'+
            ' AND language =: language'+
            ' AND Id IN : Ids'+
            ' Order By '+ sortby +' '+ sortOrder +
            ' limit : articleCounter offset :counter';
        map<Id,KnowledgeArticleVersion> mapkarticle = new map<Id,KnowledgeArticleVersion>((list<KnowledgeArticleVersion>) Database.query(articleQuery));
        list<knowledgeArticleWrapper> kavlist = new list<knowledgeArticleWrapper>();
        String sTopicName;
        String sTopicId;
        for(KnowledgeArticleVersion knowledgeArticleObj : mapkarticle.values())  
        {                    
            knowledgeArticleWrapper kvw = new knowledgeArticleWrapper();
            kvw.title = knowledgeArticleObj.Title;
            kvw.Summary=knowledgeArticleObj.Summary;
            kvw.UrlName =knowledgeArticleObj.UrlName;
            kvw.LastPublishedDate = knowledgeArticleObj.LastPublishedDate;
            kavlist.add(kvw);                    
        }
        return kavlist;
    }
    
    
    @AuraEnabled
    public static list<knowledgeArticleWrapper> nextArticle(String TopicName,Integer articleCounter,String dsg_isValid,Integer counter,String sortBy)
    {
        list<knowledgeArticleWrapper> KnowledgeArticleVersions = KnowledgeArticleVersion(TopicName,articleCounter,dsg_isValid,counter,'Yes',sortBy);
        return KnowledgeArticleVersions;
    }
    
    public class knowledgeArticleWrapper
    {
        @AuraEnabled
        public list<KnowledgeArticleVersion> KnowledgeArticleVersionlst{get;set;}
        
        @AuraEnabled
        public string Title{get;set;} 
        
        @AuraEnabled
        public string UrlName{get;set;} 
        
        @AuraEnabled
        public string Summary{get;set;}  
        
        @AuraEnabled
        public datetime LastPublishedDate{get;set;}  
        
        @AuraEnabled
        public String PhotoUrl{get;set;}    
    }
}