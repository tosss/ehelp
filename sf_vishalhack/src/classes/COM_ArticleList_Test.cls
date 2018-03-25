/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
@isTest
private class COM_ArticleList_Test {
    
    static testMethod void MakeArticle() {
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) 
        {
            User u = DS_TestObjects.CurrentUser(); 
            u.UserPermissionsKnowledgeUser= True;
            update u;
            
            Employee_Community_Article__kav testArticle = new Employee_Community_Article__kav
                (
                    Summary= 'Test',
                    Language = 'en_US', 
                    Title = 'TestingName',
                    UrlName = 'TestingURL' );
            insert testArticle;
            system.debug('insert article'+testArticle);
            Employee_Community_Article__kav k = [
                Select Id, KnowledgeArticleId, content__c,Title,Summary,Attachment__Name__s,CreatedDate
                From Employee_Community_Article__kav
                Where Id = :testArticle.Id
            ];
            
            String articleID = k.KnowledgeArticleId;
            KbManagement.PublishingService.publishArticle(articleID, true);
            
            //execute this below query to retrieve the PublishStatus
            k = [
                SELECT 
                Id, KnowledgeArticleId, content__c,Title,Summary,Attachment__Name__s,CreatedDate
                From Employee_Community_Article__kav
                Where publishStatus = 'Online'
                And language ='en_US' 
                And Id = :testArticle.Id
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
            String TopicName = tp.Id;
            Integer articleCounter =1000 ;
            COM_ArticleList_Controller articleClass = new COM_ArticleList_Controller();
            COM_ArticleList_Controller.KnowledgeArticleVersionImage(TopicName, 1, 'False', 1,'Yes','Name'); 
            COM_ArticleList_Controller.KnowledgeArticleVersionImage(TopicName, 1, 'False', 1,'Yes','test');
            COM_ArticleList_Controller.articleDetails(k.Id);
            //COM_ArticleList_Controller.nextArticle(TopicName, 1, 'False', 1,'Name');
            COM_ArticleList_Controller.language='en_US';
            COM_ArticleList_Controller.Online = 'Online';
            COM_ArticleList_Controller.knowledgeArticleVersionCount(TopicName, 10);
            COM_ArticleList_Controller.KnowledgeArticleVersionImage(TopicName, 1, 'True', 1,'Yes','Name');
            COM_ArticleList_Controller.knowledgeArticleWrapper KAW = new COM_ArticleList_Controller.knowledgeArticleWrapper();
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