@isTest
public class COM_ArticlesCarousel_Test
{
    @TestSetup
    private static void setupData()
    {
        User adminUser=DS_TestObjects.NewAdminUser_Inserted();
        adminUser.UserPermissionsKnowledgeUser=true;
        update adminUser;
        
        System.runAs(adminUser)
        {
            Topic topicRec=new Topic();
            topicRec.Name='TestTopic';
            topicRec.NetworkId ='0DB3300000001rtGAA';
            insert topicRec;
            
            topicRec=[SELECT Id, Name, NetworkId FROM Topic WHERE Name='TestTopic'];
            
            Employee_Community_Article__kav empComArticle=new Employee_Community_Article__kav();
            empComArticle.Title='Test Emp Article 1';
            empComArticle.UrlName='TestEmpArticle1';
            empComArticle.Language='en_US';
            empComArticle.Image__Name__s='Test Image';
            empComArticle.Image__ContentType__s='image/jpeg';
            empComArticle.Image__Body__s=EncodingUtil.base64Decode('VGVzdCBJbWFnZQ==');
            insert empComArticle;
            
            empComArticle=[
                SELECT Id, KnowledgeArticleId, Title, UrlName, Image__Name__s, Image_Link__c 
                FROM Employee_Community_Article__kav
                WHERE Id=:empComArticle.Id
            ];
            
            KbManagement.PublishingService.publishArticle(empComArticle.KnowledgeArticleId, true);
            
            Customer_Community_Article__kav custComArticle=new Customer_Community_Article__kav();
            custComArticle.Title='Test Cust Article 1';
            custComArticle.UrlName='TestCustArticle1';
            custComArticle.Language='en_US';
            insert custComArticle;
            
            custComArticle=[
                SELECT Id, KnowledgeArticleId, Title, UrlName, Image__Name__s, Image_Link__c 
                FROM Customer_Community_Article__kav
                WHERE Id=:custComArticle.Id
            ];
            
            KbManagement.PublishingService.publishArticle(custComArticle.KnowledgeArticleId, true);
            
            TopicAssignment topicAssignRec=new TopicAssignment();
            topicAssignRec.TopicId=topicRec.Id;
            topicAssignRec.EntityId=empComArticle.Id;
            insert topicAssignRec;
        }
    }
    
    private static testMethod void fetchArticles_LTNGTestOne()
    {
        Test.startTest();
        COM_ArticlesCarousel_Controller.fetchArticles_LTNG('TestTopic', 'Employee Community');
        Test.stopTest();
    }
    
    private static testMethod void fetchArticles_LTNGTestTwo()
    {
        Test.startTest();
        COM_ArticlesCarousel_Controller.fetchArticles_LTNG('TestTopic', 'Customer Community');
        Test.stopTest();
    }
    
    private static testMethod void fetchArticles_LTNGTestThree()
    {
        Test.startTest();
        COM_ArticlesCarousel_Controller.fetchArticles_LTNG('TestTopic', Null);
        Test.stopTest();
    }
    
    private static testMethod void fetchArticles_LTNGTestFour()
    {
        Test.startTest();
        COM_ArticlesCarousel_Controller.fetchArticles_LTNG('', Null);
        Test.stopTest();
    }
    
    private static testMethod void fetchArticles_LTNGTestFive()
    {
        Test.startTest();
        COM_ArticlesCarousel_Controller.fetchArticles_LTNG('', 'Employee Community');
        Test.stopTest();
    }
}