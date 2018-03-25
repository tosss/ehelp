/**************************************************************
* 1/19/2017 vijay.manimaran@cdk.com created   
* *************************************************************/

@isTest
public class EMP_ArticleList_LTNG_Test {
    static testMethod void MakeArticle() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) 
        {
            User u = DS_TestObjects.CurrentUser();
            u.UserPermissionsKnowledgeUser= True;
            update u;
            
            Customer_Community_Article__kav testArticle = new Customer_Community_Article__kav
                (
                    Summary= 'Test',
                    Language = 'en_US', 
                    Title = 'TestingName',
                    UrlName = 'TestingURL',
                    User__c = Userinfo.getUserId()
                );
            insert testArticle;
            
            Customer_Community_Article__kav k = [
                                                    SELECT
                                                    KnowledgeArticleId, User__c,
                                                    PublishStatus,User__r.SmallPhotoURL, User__r.Name 
                									FROM Customer_Community_Article__kav
                									WHERE Id = :testArticle.Id
            									];
                                                
            String articleID = k.KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(articleID, true);
            
            //execute this below query to retrieve the PublishStatus
            k = [
                SELECT 
                KnowledgeArticleId,User__r.SmallPhotoURL, User__r.Name, 
                PublishStatus,User__c 
                FROM Customer_Community_Article__kav 
                WHERE Id = :testArticle.Id
            ];
            
            //create topic
            Topic newTopic = new Topic
                (Name='topicName',
                 NetworkId ='0DB3300000001rtGAA'
                );
            insert newTopic;
            Topic tp = [select id, Name, NetworkId from topic where name ='topicName'];
            system.debug('** newTopic : '+tp);
            
            TopicAssignment topicassignment = new TopicAssignment(
            	TopicId = tp.Id,
                EntityId = k.Id
            );
            
			insert topicassignment;
            
            TopicAssignment tps =[select EntityID,TopicId from TopicAssignment where Topic.Name =: tp.Name];
            system.debug('*** tps : '+tps);
            KnowledgeArticleVersion kav = new KnowledgeArticleVersion();
            map<ID,TopicAssignment> mptp = new map<ID,TopicAssignment>([select EntityID,TopicId from TopicAssignment]);
            test.startTest();
            String TopicName = 'topicName';
            Integer articleCounter =1000 ;
            EMP_ArticleList_LTNG articleClass = new EMP_ArticleList_LTNG();
            EMP_ArticleList_LTNG.KnowledgeArticleVersion(TopicName, 1, 'False', 1,'Yes','Name');
            EMP_ArticleList_LTNG.KnowledgeArticleVersion(TopicName, 1, 'False', 1,'Yes','test');
            EMP_ArticleList_LTNG.nextArticle(TopicName, 1, 'False', 1,'Name');
            EMP_ArticleList_LTNG.language='en_US';
            EMP_ArticleList_LTNG.KAVcount = 10;
            EMP_ArticleList_LTNG.Online = 'Online';
            EMP_ArticleList_LTNG.knowledgeArticleVersionCount(TopicName, 10);
            EMP_ArticleList_LTNG.KnowledgeArticleVersion(TopicName, 1, 'True', 1,'Yes','Name');

            EMP_ArticleList_LTNG.knowledgeArticleWrapper KAW = new EMP_ArticleList_LTNG.knowledgeArticleWrapper();
            KAW.LastPublishedDate = system.today();
            KAW.PhotoUrl ='test';
            KAW.Summary = 'test';
            KAW.Title='Test';
            KAW.UrlName ='test';
            KAW.KnowledgeArticleVersionlst = new list<KnowledgeArticleVersion> ();
            test.stopTest();
            
        }
    }
}