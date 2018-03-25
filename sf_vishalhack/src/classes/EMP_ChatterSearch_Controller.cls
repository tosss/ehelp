/*************************************************************************
 * 12/23/2016 created vijay.manimaran@cdk.com chattersearch for communities
************************************************************************ */
public class EMP_ChatterSearch_Controller
{
    public List<FeedItemWrapper> retrieveAllFeeds {get;set;}
    public Map<String, List<FeedItemWrapper>> allFeedItemWrappers {get; set;}
    public String searchTerm{get;set;}
    
    @AuraEnabled
    public static List<FeedItemWrapper> retrieveAllPosts(String searchTerm)
    { 
        List<Id> UserIds = new List<Id>();
        List<FeedItemWrapper> FeedItemswrapperList = new List<FeedItemWrapper>();
        List<Id> feedItemIds = new List<string>();
        list<FeedItem> allFeedsList = new List<FeedItem>();
        list<Id> feedParentIds = new list<Id>();
        
        allFeedsList = searchChatterFeeds(searchTerm);
        if(allFeedsList != null && !allFeedsList.isEmpty())
        {
            for(FeedItem item : allFeedsList)
            {
                feedItemIds.add(item.id);
                UserIds.add(item.CreatedByID);
                feedParentIds.add(item.ParentId);
            }
        }
        
        if(allFeedsList != null && !allFeedsList.isEmpty())
        {
            //Fetch comments for all the feedItem ids
            Map<id,List<FeedComment>> feedCommentsMap = getAllComments(feedItemIds);
            
            for(ID objFeedItemID : feedItemIds){
                if(feedCommentsMap.get(objFeedItemID)==null) continue;
                for(FeedComment objfc : feedCommentsMap.get(objFeedItemID)){
                    UserIds.add(objfc.CreatedByID);
                }
            }
            
            Map<id,User> mapUser = new Map<id,User>(
                [
                    Select id, name, SmallPhotoURL 
                    from 
                    User 
                    where id IN:UserIds
                ]);
            Map<id, CollaborationGroup> mapGroup = new Map<id, CollaborationGroup>([
                SELECT Id,Name,SmallPhotoUrl,BannerPhotoUrl, FullPhotoUrl
                FROM CollaborationGroup 
                where id IN: feedParentIds
            ]);
            
            FeedItemWrapper chatterFeedItem;
            
            //Iterate and create wrapper object
            for(FeedItem feedItemObj : allFeedsList)
            {
                chatterFeedItem= new FeedItemWrapper();
                
                List<FeedComment> feedCommentsList = feedCommentsMap.get(feedItemObj.Id);
                List<FeedCommentWrapper> FeedComments = new List<FeedCommentWrapper>();
                if(feedCommentsList!=null){
                    for(FeedComment comment : feedCommentsList){
                        FeedCommentWrapper fc = new FeedCommentWrapper();
                        fc.FeedCommentItem = comment;
                        fc.UserPhoto = mapUser.get(comment.CreatedById).SmallPhotoURL; 
                        FeedComments.add(fc);
                    }
                }
                
                chatterFeedItem.FeedComments = FeedComments;
                chatterFeedItem.feedItemObj = feedItemObj;
                chatterFeedItem.UserPhoto = mapUser.get(feedItemObj.CreatedById).SmallPhotoURL;
                chatterFeedItem.groupName = feedItemObj.Parent.Name;
                chatterFeedItem.groupPhoto = mapGroup.get(feedItemObj.parentId).SmallPhotoURL;
                
                FeedItemswrapperList.add(chatterFeedItem);
            }
            
            return FeedItemswrapperList;
        }
        return null;
    }
    
    
    @AuraEnabled
    public static Map<Id,List<FeedComment>> getAllComments(List<String> feedItemIdsList)
    {
        Map<Id,List<FeedComment>> feedCommentsMap = new Map<Id,List<FeedComment>>();
        if(feedItemIdsList!=null || !feedItemIdsList.isEmpty())
        {
            for(FeedComment feedCommentObj : [
                select id,CommentBody,CommentType,CreatedById,
                feedItemId,CreatedBy.FirstName,CreatedBy.Lastname,CreatedDate
                from FeedComment 
                where feedItemId in :feedItemIdsList
                Limit 50
            ])
            {
                List<FeedComment> feedCommentsList = feedCommentsMap.get(feedCommentObj.feedItemId);
                if(feedCommentsList==null)
                {
                    feedCommentsList = new List<FeedComment>();
                }
                feedCommentsList.add(feedCommentObj);
                feedCommentsMap.put(feedCommentObj.feedItemId, feedCommentsList);
            }
        }
        return feedCommentsMap;
    }       
    
    @AuraEnabled
    public static list<FeedItem> searchChatterFeeds(String searchTerm) {
        
        if(searchTerm != null && searchTerm.trim() != '')
        {
            List<CollaborationGroup> Groups;
            set<Id> setFeedItemId = new set<Id>();
            List<List<SObject>> searchList;
            
            if(Test.isRunningTest()) {
                Groups = [
                    SELECT Id,Name
                    FROM CollaborationGroup
                ];
            }
            else
            {
                Groups = [
                    SELECT Id,Name,SmallPhotoUrl,BannerPhotoUrl, FullPhotoUrl
                    FROM CollaborationGroup
                    WHERE NetworkId = '0DB3300000001rtGAA'
                ];
            }
            
            searchList = [
                FIND :searchTerm IN ALL FIELDS 
                RETURNING FeedItem(Id
                                   WHERE ParentId IN :Groups
                                   Order By CreatedDate desc
                                   Limit 50
                                  ),
                FeedComment(Id,FeedItemId WHERE ParentId IN :Groups
                            Order By CreatedDate desc
                            Limit 50 )
            ];
            
            for(FeedItem fi : (list<FeedItem>)searchList[0]){
                setFeedItemId.add(fi.Id);
            }
            
            for(FeedComment fc : (list<FeedComment>)searchList[1]){
                setFeedItemId.add(fc.FeedItemId);
            }
            list<FeedItem> FeedItemList = [
                Select Id, Title, Body, LinkUrl, 
                ParentId,
                CommentCount, LikeCount, CreatedById, CreatedBy.Name, 
                CreatedBy.FirstName, CreatedBy.LastName, CreatedDate, Parent.Name
                From FeedItem
                Where Id In :setFeedItemId
                And ParentId IN :Groups
                Order By CreatedDate desc 
                Limit 50
            ];
            return FeedItemList;
        }
        
        return null;
    }
    public class FeedItemWrapper
    {
        @AuraEnabled
        public FeedItem feedItemObj {get;set;}
        @AuraEnabled
        public List<FeedCommentWrapper> FeedComments {get;set;}
        @AuraEnabled
        public Boolean isLiked {get;set;}
        @AuraEnabled
        public Id feedItemId {get;set;}
        @AuraEnabled
        public String UserPhoto {get;set;}
        @AuraEnabled
        public String groupName {get;set;}
        @AuraEnabled
        public String groupPhoto {get;set;}
    }
    
    public class FeedCommentWrapper
    {
        @AuraEnabled
        public FeedComment FeedCommentItem {get;set;}
        @AuraEnabled
        public Boolean isLiked;
        @AuraEnabled
        public List<FeedComment> feedCommentsList {get;set;} 
        @AuraEnabled
        public Id feedItemId;
        @AuraEnabled
        public String UserPhoto {get;set;}
        @AuraEnabled
        public String Message;
    }
    
}