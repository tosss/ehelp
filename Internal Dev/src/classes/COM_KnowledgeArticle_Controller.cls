public class COM_KnowledgeArticle_Controller {
    public static String Online = 'Online';
    public static String language = 'en_US';
    
    @AuraEnabled
    public static Integer knowledgeArticleVersionCount(String TopicName, Integer articleCounter)
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
    public static list<knowledgeArticleWrapper> KnowledgeArticleVersionImage(String articleType, String TopicName, Integer articleCounter,String dsg_isValid, Integer counter,String showPagination, String sortBy)
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
        
        map<Id,Sobject> mapCommunityAritcle = new map<Id,Sobject>(
            Database.query(
                'SELECT Id, KnowledgeArticleId,Summary,Image__Name__s,Attachment__ContentType__s,content__c,Hide_Votes__c,Hide_Summary__c,'
                +' Show_Chatter__c,Hide_Views__c,Hide_Topic__c '
                +' FROM '+articleType+'__kav'
                +' WHERE publishStatus = \'Online\''
                +' AND language =\'en_US\' '
                +' AND KnowledgeArticleId IN :setKnowledgeArticleId'
            ));  
        
        for(KnowledgeArticleVersion knowledgeArticleObj : mapkarticle.values())  
        { 
            for(Sobject CAK : mapCommunityAritcle.values())
            {
                knowledgeArticleWrapper kavlists = new knowledgeArticleWrapper();
                if(CAK.get('KnowledgeArticleId') == knowledgeArticleObj.KnowledgeArticleId)
                {
                    knowledgeArticleWrapper kvw = new knowledgeArticleWrapper();
                    kvw = COM_KnowledgeArticle_Controller.utilityKnowledgeArticle(articleType,knowledgeArticleObj,CAK,topicassignments); 
                    kavlist.add(kvw);  
                }
            }        
        }
        return kavlist;
    }
    
    @AuraEnabled
    public static knowledgeArticleWrapper utilityKnowledgeArticle(String articleType, KnowledgeArticleVersion knowledgeArticleObj,Sobject CAK,map<Id,TopicAssignment> maptp){
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
        Schema.DescribeSObjectResult KnowledgeArticleVersionDescribe = Schema.getGlobalDescribe().get(articleType+'__kav').getDescribe();
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
        kvw.communityArticle = CAK;
        kvw.KnowledgeArtcle_Id = knowledgeArticleObj.Id;
        kvw.KnowledgeArtcle_RecordId = knowledgeArticleObj.KnowledgeArticleId;
        return kvw;
    }
    
    
    @AuraEnabled
    public static knowledgeArticleWrapper articleDetails(String articleType, String topicName)
    {
        KnowledgeArticleVersion mapkarticle = [
            SELECT KnowledgeArticleId,Id, Title,UrlName,LastPublishedDate, Summary
            FROM KnowledgeArticleVersion 
            WHERE publishStatus ='Online'
            AND language = 'en_US'
            AND UrlName =: topicName
        ];
        Sobject communityAritcle= COM_KnowledgeArticle_Controller.communityArticleObj(articleType,mapkarticle.KnowledgeArticleId);
        
        
        map<Id,TopicAssignment> maptp = new map<Id,TopicAssignment>(
            [
                SELECT Id, EntityId,Topic.Name 
                FROM TopicAssignment 
                WHERE EntityId =: mapkarticle.Id
            ]);
        
        knowledgeArticleWrapper kavlist = new knowledgeArticleWrapper();
        kavlist = COM_KnowledgeArticle_Controller.utilityKnowledgeArticle(articleType,mapkarticle,CommunityAritcle,maptp); 
        return kavlist;
    }
    
    @AuraEnabled
    public static knowledgeArticleWrapper KnowledgeArticleViewStat(String articleType, String knowledgeArticleId){
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
            Sobject communityAritcle= COM_KnowledgeArticle_Controller.communityArticleObj(articleType,KnowledgeArticleViewStats.ParentId);
            
            
            
            knowledgeArticleWrapperRecord.TotalViews = KnowledgeArticleViewStats.viewcount;
            knowledgeArticleWrapperRecord.communityArticle = communityAritcle;
            return knowledgeArticleWrapperRecord;
            
        }catch(exception ex){
            return knowledgeArticleWrapperRecord;
            
        }
        
    }
    
    /* code for vote */
    @AuraEnabled
    public static knowledgeArticleWrapper createVote(String articleType, String knowledgeArticleID, String voteType)
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
            
            KAW = COM_KnowledgeArticle_Controller.getvotes(articleType,knowledgeArticleID);
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
    public static knowledgeArticleWrapper getvotes(String articleType,String knowledgearticleID)
    {
        KnowledgeArticleVersion mapkarticle = [
            SELECT KnowledgeArticleId,Id,UrlName
            FROM KnowledgeArticleVersion 
            WHERE publishStatus ='Online'
            AND language = 'en_US'
            AND UrlName =: knowledgeArticleID
        ];
        
        Sobject communityAritcle= COM_KnowledgeArticle_Controller.communityArticleObj(articleType,mapkarticle.KnowledgeArticleId);
        
        
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
        
        KAW.communityArticle = communityAritcle;
        return KAW;
    }
    
    @AuraEnabled
    public static Boolean articleEditAccess(String articleType)
    {    
        Schema.DescribeSObjectResult KnowledgeArticleVersionDescribe = Schema.getGlobalDescribe().get(articleType+'__kav').getDescribe();
        Boolean editaccess= KnowledgeArticleVersionDescribe.updateable;
        return editaccess;
    }
    
    
    @AuraEnabled 
    public static Sobject communityArticleObj(String articleType, String knowledgearticleID){
        
        Sobject CommunityAritcle =
            Database.query(
                'Select Id, KnowledgeArticleId, content__c,Title,Summary,Attachment__Name__s,CreatedDate,Hide_Votes__c,Hide_Summary__c,Hide_Views__c,Hide_Topic__c,'
                +' Image__Name__s,Attachment__ContentType__s,Show_Chatter__c'
                +' From '+articleType+'__kav'
                +' Where publishStatus = \'Online\''
                +' And language =\'en_US\''
                +' And KnowledgeArticleId =: knowledgearticleID'
            ); 
        
        return CommunityAritcle;
    }
    
    public class knowledgeArticleWrapper
    {
        @AuraEnabled
        public KnowledgeArticleVersion KnowledgeArticleVersionlst{get;set;}
        
        @AuraEnabled
        public Sobject communityArticle{get;set;}
        
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
    }
}