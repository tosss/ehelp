/**************************************************************
* 12/6/2016 vijay.manimaran@cdk.com created
* RQ-09217 5/4/2017 vijay.manimaran@cdk.com modified the code and cleaned to resolve soql limit.
* *************************************************************/

public with sharing class COM_ArticleList_Controller {
    public static String Online = 'Online';
    public static String language = 'en_US';
  /*  
    @AuraEnabled
    public static Integer knowledgeArticleVersionCount(String TopicName,Integer articleCounter)
    { 
        map<ID,TopicAssignment> topicassignments = new map<ID,TopicAssignment>([
            SELECT entityID,topic.Name
            FROM TopicAssignment 
            WHERE topic.Id =: TopicName 
            LIMIT 1000
        ]);
        set<ID> Ids = new Set<ID>();
        for(TopicAssignment tp :topicassignments.values()){Ids.add(tp.EntityId);}
        map<Id,KnowledgeArticleVersion> mapkarticle = new map<Id,KnowledgeArticleVersion>
            ([
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
    public static list<knowledgeArticleWrapper> KnowledgeArticleVersionImage(String TopicName, Integer articleCounter,String dsg_isValid, Integer counter,String showPagination, String sortBy)
    {
        map<ID,TopicAssignment> topicassignments = new map<ID,TopicAssignment>([
            SELECT entityID,topic.Name 
            FROM TopicAssignment 
            WHERE topic.Id =: TopicName 
            LIMIT 1000
        ]);
        set<ID> Ids = new Set<ID>();
        for(TopicAssignment tp :topicassignments.values()){Ids.add(tp.EntityId);}
        if(showPagination=='No'){
            articleCounter = 1000;
        }
        
        String sortOrder;
        if(sortBy == 'Name'){
            sortBy= 'Title';
            sortOrder ='Asc';
        }else{
            sortBy = 'LastPublishedDate';
            sortOrder ='Desc'; 
        }
        
        String limitValue = '900';
        String articleQuery =   'SELECT KnowledgeArticleId, Title,UrlName,LastPublishedDate, Summary '+
            ' FROM KnowledgeArticleVersion'+ 
            ' WHERE publishStatus =: Online'+
            ' AND language =: language'+
            ' AND Id IN : Ids'+
            ' Order By '+ sortby +' '+ sortOrder +
            ' limit : articleCounter ';
        
        map<Id,KnowledgeArticleVersion> mapkarticle = new map<Id,KnowledgeArticleVersion>((list<KnowledgeArticleVersion>) Database.query(articleQuery));
        list<knowledgeArticleWrapper> kavlist = new list<knowledgeArticleWrapper>();
        String sTopicName;
        String sTopicId;
        set<Id> setKnowledgeArticleId = new set<Id>();
        
        for(KnowledgeArticleVersion knowledgeArticleIds : mapkarticle.values()){
            setKnowledgeArticleId.add(knowledgeArticleIds.KnowledgeArticleId);
        }
        
        map<Id,Employee_Community_Article__kav> mapCommunityAritcle = new map<Id,Employee_Community_Article__kav>(
            [
                SELECT Id, KnowledgeArticleId,Summary,Image__Name__s,Attachment__ContentType__s,content__c,Hide_Votes__c,Hide_Summary__c,Image_Link__c,
                Show_Chatter__c,Hide_Views__c,Hide_Topic__c 
                FROM Employee_Community_Article__kav
                WHERE publishStatus = 'Online'
                AND language ='en_US'
                AND KnowledgeArticleId IN :setKnowledgeArticleId
            ]);  
        
        for(KnowledgeArticleVersion knowledgeArticleObj : mapkarticle.values())  
        { 
            for(Employee_Community_Article__kav CAK : mapCommunityAritcle.values())
            {
                knowledgeArticleWrapper kavlists = new knowledgeArticleWrapper();
                if(CAK.KnowledgeArticleId == knowledgeArticleObj.KnowledgeArticleId)
                {
                    knowledgeArticleWrapper kvw = new knowledgeArticleWrapper();
                    kvw = COM_ArticleList_Controller.utilityKnowledgeArticle(knowledgeArticleObj,CAK,topicassignments); 
                    kavlist.add(kvw);  
                }
            }        
        }
        return kavlist;
    }
    
    @AuraEnabled
    public static knowledgeArticleWrapper utilityKnowledgeArticle(KnowledgeArticleVersion knowledgeArticleObj,Employee_Community_Article__kav CAK,map<Id,TopicAssignment> maptp){
        list<knowledgeArticleWrapper> kavlist = new list<knowledgeArticleWrapper>();
        knowledgeArticleWrapper kvw = new knowledgeArticleWrapper();
        list<TopicAssignmentWrapper> topicAssignWrapper = new list<TopicAssignmentWrapper>();
        Integer totalTopics = maptp.size();
        
        for(Integer i=0; i<totalTopics; i++)
        {
            TopicAssignment p = maptp.values().get(i);
            TopicAssignmentWrapper topicAssignWrapperObj = new TopicAssignmentWrapper();
            if(p.EntityId == knowledgeArticleObj.Id)
            {
                topicAssignWrapperObj.topicName = p.topic.Name;
                topicAssignWrapperObj.topicUrlName =knowledgeArticleObj.UrlName;
                topicAssignWrapperObj.titleId = p.topicId; 
            }
            topicAssignWrapper.add(topicAssignWrapperObj);
        }
        Schema.DescribeSObjectResult KnowledgeArticleVersionDescribe = Employee_Community_Article__kav.sObjectType.getDescribe();
        kvw.KnowledgeArticleVersionlst = knowledgeArticleObj;
        kvw.tpws = topicAssignWrapper;
        kvw.title = knowledgeArticleObj.Title;
        kvw.documentAccess = KnowledgeArticleVersionDescribe.updateable;
        if(knowledgeArticleObj.LastPublishedDate >= Date.today().addDays(-7) &&  knowledgeArticleObj.LastPublishedDate <= Date.today())
        {
            kvw.newDocument = true;
        }
        else
        {
            kvw.newDocument =false;
        }
        kvw.EMPCommunityArticle = CAK;
        kvw.KnowledgeArtcle_Id = knowledgeArticleObj.Id;
        kvw.KnowledgeArtcle_RecordId = knowledgeArticleObj.KnowledgeArticleId;
        return kvw;
    }
    
    
    @AuraEnabled
    public static knowledgeArticleWrapper articleDetails(String topicName)
    {
        KnowledgeArticleVersion mapkarticle = [
            SELECT KnowledgeArticleId,Id, Title,UrlName,LastPublishedDate, Summary
            FROM KnowledgeArticleVersion 
            WHERE publishStatus ='Online'
            AND language = 'en_US'
            AND UrlName =: topicName
        ];
        Employee_Community_Article__kav CommunityAritcle= COM_ArticleList_Controller.EMPCommunityArticleObj(mapkarticle.KnowledgeArticleId);
        
        
        map<Id,TopicAssignment> maptp = new map<Id,TopicAssignment>(
            [
                SELECT Id, EntityId,Topic.Name 
                FROM TopicAssignment 
                WHERE EntityId =: mapkarticle.Id
            ]);
        
        knowledgeArticleWrapper kavlist = new knowledgeArticleWrapper();
        kavlist = COM_ArticleList_Controller.utilityKnowledgeArticle(mapkarticle,CommunityAritcle,maptp); 
        return kavlist;
    }
    
    @AuraEnabled
    public static knowledgeArticleWrapper KnowledgeArticleViewStat(String knowledgeArticleId){
        KnowledgeArticleViewStat KnowledgeArticleViewStats = new  KnowledgeArticleViewStat();
        knowledgeArticleWrapper knowledgeArticleWrapperRecord = new knowledgeArticleWrapper();      
        
        try{
            KnowledgeArticleViewStats = [
                SELECT ParentId,viewcount FROM KnowledgeArticleViewStat 
                WHERE ParentId IN( SELECT KnowledgeArticleId
                                  FROM KnowledgeArticleVersion 
                                  WHERE publishStatus ='Online'
                                  AND language = 'en_US'
                                  AND UrlName =: knowledgeArticleId )and channel = 'All Channels'
            ];
            Employee_Community_Article__kav CommunityAritcle= COM_ArticleList_Controller.EMPCommunityArticleObj(KnowledgeArticleViewStats.ParentId);
            
            
            
            knowledgeArticleWrapperRecord.TotalViews = KnowledgeArticleViewStats.viewcount;
            knowledgeArticleWrapperRecord.EMPCommunityArticle = CommunityAritcle;
            return knowledgeArticleWrapperRecord;
            
        }catch(exception ex){
            return knowledgeArticleWrapperRecord;
            
        }
        
    }
    
    @AuraEnabled
    public static knowledgeArticleWrapper createVote(String knowledgeArticleID, String voteType)
    {
        KnowledgeArticleVersion mapkarticle = [
            SELECT KnowledgeArticleId,Id, Title,UrlName,LastPublishedDate, Summary
            FROM KnowledgeArticleVersion 
            WHERE publishStatus ='Online'
            AND language = 'en_US'
            AND UrlName =: knowledgeArticleID
        ];
        
        knowledgeArticleWrapper knowledgeArticleWrapperRecord=new knowledgeArticleWrapper();
        list<vote> totalVotes = new list<vote> ();
        totalVotes = [Select ParentId,Type FROM vote where ParentId =: mapkarticle.knowledgeArticleID and createdbyID =: userinfo.getUserId()]; 
        
        if(totalVotes.size() > 0){
            knowledgeArticleWrapperRecord.errorMessage ='You have already Voted';
            knowledgeArticleWrapper KAW=new knowledgeArticleWrapper();
            
            KAW = COM_ArticleList_Controller.getvotes(knowledgeArticleID);
            knowledgeArticleWrapperRecord.voteup = kaw.voteup;
            knowledgeArticleWrapperRecord.votedown = kaw.votedown;
            
        } else{
            Vote userVote=new Vote();
            userVote.ParentId= mapkarticle.knowledgeArticleID;
            userVote.Type= voteType; 
            Database.SaveResult userVoteInsertResult=Database.insert(userVote, false);
        }
        return knowledgeArticleWrapperRecord;
    }
    
    @AuraEnabled
    public static knowledgeArticleWrapper getvotes(String knowledgearticleID)
    {
        KnowledgeArticleVersion mapkarticle = [
            SELECT KnowledgeArticleId,Id,UrlName
            FROM KnowledgeArticleVersion 
            WHERE publishStatus ='Online'
            AND language = 'en_US'
            AND UrlName =: knowledgeArticleID
        ];
        
        Employee_Community_Article__kav CommunityAritcle= COM_ArticleList_Controller.EMPCommunityArticleObj(mapkarticle.KnowledgeArticleId);
        
        
        list<Vote> votelist = new list<Vote>();
        votelist =[Select ParentId,Type FROM vote where ParentId =: mapkarticle.KnowledgeArticleId];
        knowledgeArticleWrapper KAW = new knowledgeArticleWrapper();
        
        for(vote v: votelist){
            Integer i=0,j=0;
            
            if(v.Type == '5'){
                i = i+ 1;
            }else if(v.Type == '1'){
                j = j+1;
            } else{
                i=0;j=0;
            }
            KAW.voteup = i;
            KAW.votedown = j;
        }
        
        KAW.EMPCommunityArticle = CommunityAritcle;
        return KAW;
    }
    
    @AuraEnabled
    public static Boolean articleEditAccess()
    {    
        Schema.DescribeSObjectResult KnowledgeArticleVersionDescribe = Employee_Community_Article__kav.sObjectType.getDescribe();
        Boolean editaccess= KnowledgeArticleVersionDescribe.updateable;
        return editaccess;
    }
    
    
    @AuraEnabled 
    public static Employee_Community_Article__kav EMPCommunityArticleObj(String knowledgearticleID){
        
        Employee_Community_Article__kav CommunityAritcle =
            [
                Select Id, KnowledgeArticleId, content__c,Title,Summary,Attachment__Name__s,CreatedDate,Hide_Votes__c,Hide_Summary__c,Hide_Views__c,Hide_Topic__c,
                Image__Name__s,Attachment__ContentType__s,Show_Chatter__c,Image_Link__c
                From Employee_Community_Article__kav
                Where publishStatus = 'Online'
                And language ='en_US'
                And KnowledgeArticleId =: knowledgearticleID
            ]; 
        
        return CommunityAritcle;
    }
    
    public class knowledgeArticleWrapper
    {
        @AuraEnabled
        public KnowledgeArticleVersion KnowledgeArticleVersionlst{get;set;}
        
        @AuraEnabled
        public Employee_Community_Article__kav EMPCommunityArticle{get;set;}
        
        @AuraEnabled
        public list<vote> votelst{get;set;}
        
        @AuraEnabled
        public Integer voteup{get;set;}
        
        @AuraEnabled
        public Integer votedown{get;set;}
        
        @AuraEnabled 
        public list<TopicAssignmentWrapper> tpws{get;set;}
        
        @AuraEnabled
        public String errorMessage{get; set;}
        
        @AuraEnabled
        public String Title{get; set;}
        
        @AuraEnabled
        public Boolean documentAccess{get; set;}
        
        @AuraEnabled 
        public Integer TotalViews{get;set;}  
        
        @AuraEnabled
        public Boolean newDocument{get;set;}    
        
        @AuraEnabled
        public String KnowledgeArtcle_Id{get;set;} 
        
        @AuraEnabled
        public String KnowledgeArtcle_RecordId{get;set;} 
        
        
    }
    
    public class TopicAssignmentWrapper
    {
        @AuraEnabled 
        public list<TopicAssignment> tpw{get;set;}
        
        @AuraEnabled
        public string topicName{get;set;}
        
        @AuraEnabled
        public string topicURLName{get;set;}
        
        @AuraEnabled
        public string titleId{get;set;} 
    }*/
    
}