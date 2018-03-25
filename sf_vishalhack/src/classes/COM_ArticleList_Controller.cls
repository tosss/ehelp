/**************************************************************
* 12/6/2016 vijay.manimaran@cdk.com created
* RQ-09217 5/4/2017 vijay.manimaran@cdk.com modified the code and cleaned to resolve soql limit.
* *************************************************************/

public with sharing class COM_ArticleList_Controller {
    public static String Online = 'Online';
    public static String language = 'en_US';

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
        String articleQuery =	'SELECT KnowledgeArticleId, Title,UrlName,LastPublishedDate, Summary '+
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
																	            	SELECT Id, KnowledgeArticleId,Summary,Image__Name__s,Attachment__ContentType__s,content__c 
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
                topicAssignWrapperObj.titleId = p.topicId; 
            }
            topicAssignWrapper.add(topicAssignWrapperObj);
        }
        
        kvw.tpws = topicAssignWrapper;
        kvw.title = knowledgeArticleObj.Title;
        kvw.Summary=knowledgeArticleObj.Summary;
        kvw.UrlName =knowledgeArticleObj.UrlName;
        kvw.LastPublishedDate = knowledgeArticleObj.LastPublishedDate;
        kvw.Content = CAK.content__c;
        kvw.KnowledgeArtcle_Id = knowledgeArticleObj.Id;
        kvw.KnowledgeArtcle_RecordId = knowledgeArticleObj.KnowledgeArticleId;
        kvw.ImageName = CAK.Image__Name__s;
        kvw.ContentType =CAK.Attachment__ContentType__s;
        return kvw;
    }
    
    
    @AuraEnabled
    public static knowledgeArticleWrapper articleDetails(String Ids)
    {
        KnowledgeArticleVersion mapkarticle = [
									            SELECT KnowledgeArticleId,Id, Title,UrlName,LastPublishedDate, Summary
									            FROM KnowledgeArticleVersion 
									            WHERE publishStatus ='Online'
									            AND language = 'en_US'
									            AND Id =: Ids
									          ];
        
        Employee_Community_Article__kav CommunityAritcle =
									          [
									         	Select Id, KnowledgeArticleId, content__c,Title,Summary,Attachment__Name__s,CreatedDate,Image__Name__s,Attachment__ContentType__s
									            From Employee_Community_Article__kav
									            Where publishStatus = 'Online'
									            And language ='en_US'
									            And KnowledgeArticleId =: mapkarticle.KnowledgeArticleId
									          ]; 
        
        map<Id,TopicAssignment> maptp = new map<Id,TopicAssignment>(
									            [
									              SELECT Id, EntityId,Topic.Name 
									              FROM TopicAssignment 
									              WHERE EntityId =: mapkarticle.Id
									            ]);
        
        knowledgeArticleWrapper kavlist = new knowledgeArticleWrapper();
        list<knowledgeArticleWrapper> kavlists = new list<knowledgeArticleWrapper>();
        kavlist = COM_ArticleList_Controller.utilityKnowledgeArticle(mapkarticle,CommunityAritcle,maptp); 
        kavlists.add(kavlist);
        return kavlist;
        
    }
    
    @AuraEnabled
    public static String articleEditAccess(){
        List<PermissionSetAssignment> lstcurrentUserPerSet =    [   
            SELECT Id, PermissionSet.Name,AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :Userinfo.getUserId() 
        ];
        
        String user_has_permission;
        for ( PermissionSetAssignment psa : lstcurrentUserPerSet){
            if ( psa.PermissionSet.Name.equals('COM_ArticleEditAccess')){
                return 'articleEditAccess';
            } 
        }
        return null;
    }
    
    
    public class knowledgeArticleWrapper
    {
        @AuraEnabled
        public list<KnowledgeArticleVersion> KnowledgeArticleVersionlst{get;set;}
        
        @AuraEnabled 
        public list<TopicAssignmentWrapper> tpws{get;set;}
        
        @AuraEnabled
        public string Title{get;set;} 
        
        @AuraEnabled
        public string UrlName{get;set;} 
        
        @AuraEnabled
        public string Summary{get;set;}  
        
        @AuraEnabled
        public string Content{get;set;}  
        
        @AuraEnabled
        public datetime LastPublishedDate{get;set;}  
        
        @AuraEnabled
        public String PhotoUrl{get;set;}    
        
        @AuraEnabled
        public String KnowledgeArtcle_Id{get;set;} 
        
        @AuraEnabled
        public String KnowledgeArtcle_RecordId{get;set;} 
        
        @AuraEnabled 
        public String ImageName{get;set;}
        
        @AuraEnabled 
        public String ContentType{get;set;}
    }
    
    public class TopicAssignmentWrapper
    {
        @AuraEnabled 
        public list<TopicAssignment> tpw{get;set;}
        
        @AuraEnabled
        public string topicName{get;set;}
        
        @AuraEnabled
        public string titleId{get;set;} 
    }
    
}