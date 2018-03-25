//2017-06-07- anirudh.singh@cdk.com- Created this component for RQ-09402.
public with sharing class COM_ArticlesCarousel_Controller
{
    @AuraEnabled
    public static List<ArticleWrapper> fetchArticles_LTNG(String topicName, String communityName)
    {
        List<ArticleWrapper> artWrapList;
        if(String.isNotBlank(communityName))
        {
            List<TopicAssignment> topicAssgnList=new List<TopicAssignment>([
                SELECT EntityId, EntityType 
                FROM TopicAssignment 
                WHERE Topic.Name=:topicName
            ]);
            
            String articleType=(communityName=='Employee Community') ? 'Employee_Community_Article' : 
            (communityName=='Customer Community') ? 'Customer_Community_Article' : Null;
            
            Set<Id> articleIds=new Set<Id>();
            for(TopicAssignment assignRec: topicAssgnList)
            {
                if(articleType==assignRec.EntityType)
                {
                    articleIds.add(assignRec.EntityId);
                }
            }
            
            if(articleIds.size()>0)
            {
                String queryStr='SELECT Id, Title, UrlName, Image__Name__s, Image_Link__c'
                    +' FROM '+articleType+'__kav'
                    +' WHERE PublishStatus=\'Online\' AND Language=\'en_US\' AND Id IN :articleIds Order By Title ASC';
                
                List<sObject> articlesList=new List<sObject>();
                articlesList=database.query(queryStr);
                
                artWrapList=popWrapperList(articleType, articlesList);
            }
        }
        
        return artWrapList;
    }
    
    private static List<ArticleWrapper> popWrapperList(String articleType, List<sObject> articlesList)
    {
        List<ArticleWrapper> artWrapList=new List<ArticleWrapper>();
        if(articlesList.size()>0)
        {
            String networkUrl=(Network.communitiesLanding()!=Null) ? Network.communitiesLanding().getUrl() : Null;
            String communityUrl=(String.isNotBlank(networkUrl)) ? networkUrl : URL.getSalesforceBaseUrl().toExternalForm()+'/';
            
            for(sObject rec: articlesList)
            {
                if(rec.get('Image__Name__s')!=Null)
                {
                    ArticleWrapper wrapRec=new ArticleWrapper();
                    wrapRec.articleTitle=(String)rec.get('Title');
                    
                    String tempComUrl=communityUrl;
                    if(networkUrl!=Null)
                    {
                        Integer comUrlLen=communityUrl.length()-2;
                        tempComUrl=communityUrl.substring(0, comUrlLen);
                    }
                    wrapRec.imgSrc=tempComUrl+'servlet/fileField?entityId='+rec.get('Id')+'&field=Image__Body__s';
                    
                    String imageLink=(String)rec.get('Image_Link__c');
                    if(String.isBlank(imageLink))
                    {
                        imageLink=communityUrl+'articles/'+articleType+'/'+rec.get('UrlName');
                        if(networkUrl!=Null)
                        {
                            imageLink=communityUrl+'article/'+rec.get('Id')+'/'+rec.get('UrlName');
                        }
                    }
                    wrapRec.imgLink=imageLink;
                    
                    artWrapList.add(wrapRec);
                }
            }
        }
        
        return artWrapList;
    }
    
    public class ArticleWrapper
    {
        @AuraEnabled
        public String articleTitle{get; set;}
        
        @AuraEnabled
        public String imgLink{get; set;}
        
        @AuraEnabled
        public String imgSrc{get; set;}
    }
}