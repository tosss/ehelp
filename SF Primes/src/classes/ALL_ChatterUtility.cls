// ***************************************************
// Author: Hemanth.Kesapragada@cdk.com
// Description: Utitlity class to add posts to sObjects, Groups, Posts
// Test Class: ALL_ChatterUtility_Test
// 
// History:
// 2015-07-07 	Hemanth Kesapragada		Created
// 2015-07-08 	Hemanth Kesapragada		Added fetchFollowersForARecord method
// 2015-07-10 	Hemanth Kesapragada		Added followRecord,unfollowRecord, postToChatter,postFileToChatter,createFileToChatter method
// 2015-07-14	Hemanth Kesapragada		Added retrieveAllPosts,likeAComment,likeAPost method
// 2015-07-21	Hemanth Kesapragada		Added unlikeApost and deleteAllPosts method
// 2015-07-23	Hemanth Kesapragada		Added getAllComments method to fix 'Invalid Query locator' error while fetchin FeedComments from feedItems
// 2015-07-24	Hemanth Kesapragada		Renamed removePost to deletePost, removeCOmment to deleteComment
// 2015-07-28	Vijay					Changed retrieveAllPosts method
// 2015-08-17   matt.keefe@cdk.com      Removed all try-catch blocks (error handling should happen in JS), updated formatting
// ***************************************************
public class ALL_ChatterUtility {
    
    //File to be posted in chatter
    public static Blob attachedFile {get;set;}
    public static String attachmentName {get;set;}
    
    // constructors
    public ALL_ChatterUtility(){}
    public ALL_ChatterUtility(ApexPages.StandardController StandardController){}
    public ALL_ChatterUtility(EMP_Chatter_Controller CustomController){}
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Get followers (Users) by passing sObjectId
    // Parameters: record Id
    // Return type: users list
    // ****************************************
    @RemoteAction
    public static List<User> fetchFollowersByRecordID(String recordID)
    {
        try 
        {
            //Id check - throws error if ID is not valid
            Id parentId = recordID;
            Set<Id> userIds = new Set<Id>();
            List<User> followers;
            if(parentId!=null)
            {
                for(EntitySubscription subscriptionObj : [
                    select id, parentid, subscriberid ,
                    subscriber.name,parent.name 
                    from EntitySubscription 
                    where parentId=:parentId])
                {
                    userIds.add(subscriptionObj.subscriberid);
                }
                followers = [
                    select id,firstName ,lastName
                    from User 
                    where id in :userIds
                ];
            }
            return followers;
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return null;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Get subscriptions of a user
    // Parameters: user Id
    // Return type: List of EntitySubscriptions
    // ****************************************
    @RemoteAction
    public static List<EntitySubscription> fetchSubscriptionsByUserID(String userID)
    {
        try
        {
            Map<Id,String> subscriptionMap = new Map<Id,String>();
            Id userRecordID = userID;
            //Check User id
            User userObj = [
                select id,firstName,lastName,IsActive 
                from user 
                where id=:userRecordID
            ];
            if(!userObj.IsActive)
            {
                throw new ChatterException('User is not active');
            }
            else
            {
                List<EntitySubscription> followingES = [
                    select id, parentid, subscriberid, parent.name 
                    from EntitySubscription
                    where subscriberid =:userRecordID
                ];   
                return followingES;
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return null;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Follow user or a record
    // Parameters: subscriber(UserID) and record or user Id
    // Return type: void
    // ****************************************
    @RemoteAction
    public static EntitySubscription followRecord(String subscriberUserID, String recordID)
    {
        try
        {
            Id parentID = recordID;
            Id subscriberID = subscriberUserID;
            
            EntitySubscription follow = new EntitySubscription (
                parentId = parentID,
                subscriberid = subscriberID);
            
            insert follow;
            return follow;
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return null;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Unfollow user or a record
    // Parameters: subscriber(UserID) and record or user Id
    // Return type: void
    // ****************************************
    @RemoteAction
    public static void unfollowRecord(String subscriberUserID, String recordID)
    {
        try
        {
            Id parentID = recordID;
            Id subscriberID = subscriberUserID;
            EntitySubscription unfollow = [
                select id from EntitySubscription 
                where parentId=:parentID 
                and subscriberID=:subscriberID
            ];
            if(unfollow!=null)
            {
                delete unfollow;
            }            
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: This method is used to post text,url as feed to a record id / user id
    // Parameters: recordID(Required attribute), Either body or URL must be passed
    // Return type: FeedItem
    // ****************************************
    @RemoteAction
    public static FeedItem postToChatter(String recordID, String body, String url)
    {
        try
        {
            ID parentID = recordID;
            System.debug('*** recordID,' +recordID +'******* body'+body);
            
            FeedItem post = new FeedItem();
            post.ParentId = parentID;
            
            if((body==null || String.isBlank(body)) && (url==null || String.isBlank(url)))
            {
                throw new ChatterException('Either body or URL should be specified');
            }
            
            if(body!=null|| !String.isBlank(body))
            {
                post.Body = body;
                post.Type = 'textpost';
                post.NetworkScope = Network.getNetworkId();
                post.CreatedById = UserInfo.getUserId(); 
                post.CreatedDate = System.now();
            }
            
            //if(url!=null || !String.isBlank(url))
            //{
            //    post.LinkUrl = url; 
            //    post.NetworkScope = Network.getNetworkId();   
            //    post.CreatedById = UserId;
            //    post.CreatedDate = System.now();
            //}
            
            insert post;
            return post;
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            
            throw new ChatterException(e.getMessage());
            
            return null;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: This method posts files to chatter.
    // Class variables - attachedFile and attachmentName must be set to use this method 
    // Parameters: record or user Id 
    // Return type: FeedItem
    // ****************************************
   /* @RemoteAction
    public static FeedItem postFileToChatter(String recordID,String body,String url)
    {
        try
        {
            if(attachedFile!=null)
            {
                if(attachmentName!=null || !String.isBlank(attachmentName))
                {
                    ID parentID = recordID;
                    
                    FeedItem post = new FeedItem();
                    post.ParentId = parentID;
                    if(body!=null|| !String.isBlank(body))
                    {
                        post.Body = body;  
                    }
                    if(url!=null || !String.isBlank(url))
                    {
                        post.LinkUrl = url;  
                    }
                    post.ContentData= attachedFile;
                    post.ContentFileName = attachmentName;
                    insert post;
                    
                    return post;
                }
                else
                {
                    throw new ChatterException('File name must be specified');  
                }
            }
            else
            {
                throw new ChatterException('No file attached');
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            
            throw new ChatterException(e.getMessage());
            
            return null;
        }
    }
    */
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: This method creates files dynamically and posts to the feed.
    // Parameters: record or user Id (required) , body, URL, attachment body, attachment name and extension
    // Return type: FeedItem
    // ****************************************
    @RemoteAction
    public static FeedItem createFileToChatter(String recordID,String body,String url,String attachmentBody, String fileName, String extension)
    {
        try
        {
            ID parentID = recordID;
            
            FeedItem post = new FeedItem();
            post.ParentId = parentID;
            boolean isBodyNull=false;
            boolean isURLNull=false;
            boolean isAttachmentBodyNull=false;
            
            if(body==null|| String.isBlank(body))
            {
                isBodyNull=true;
            }
            
            if(url==null || String.isBlank(url))
            {
                isURLNull=true;
            }
            
            if(attachmentBody==null || String.isBlank(attachmentBody))
            {
                isAttachmentBodyNull=true;
            }
            
            if(isBodyNull==true && isURLNull==true && isAttachmentBodyNull==true)
            {
                throw new ChatterException('Either body, url or attachmentbody must be specified');
            }
            else
            {
                if(isBodyNull==false)
                {
                    post.Body = body;  
                }
                
                if(isURLNull==false)
                {
                    post.LinkUrl = url;  
                }
                
                if(isAttachmentBodyNull==false)
                {
                    if(extension!=null || !String.isBlank(extension))
                    {
                        if(fileName!=null || !String.isBlank(fileName))
                        {
                            if(extension.equalsIgnoreCase('pdf'))
                            {
                                post.ContentData= Blob.toPdf(attachmentBody);
                                post.ContentFileName = fileName+'.'+extension;
                            }
                            else if(extension.equalsIgnoreCase('docx')||extension.equalsIgnoreCase('docx'))
                            {
                                post.ContentData= Blob.valueOf(attachmentBody);
                                post.ContentFileName = fileName+'.doc';
                            }
                            else if(extension.equalsIgnoreCase('txt'))
                            {
                                post.ContentData= Blob.valueOf(attachmentBody);
                                post.ContentFileName = fileName+'.'+extension;
                            }
                        }
                        else
                        {
                            throw new ChatterException('please specify file name');
                        }
                    }
                    else
                    {
                        throw new ChatterException('please specify extension');
                    }
                }
                
                insert post;
                return post;
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return null;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: This method deletes feed item post.
    // Parameters: feedItemID(required)
    // Return type: void
    // ****************************************
    @RemoteAction
    public static void deletePost(String feedItemID)
    {
        try
        {
            Id feedItem = feedItemID;
            FeedItem item = [
                select id from FeedItem 
                where id=:feedItem
            ];
            
            if(item!=null)
            {
                delete item;
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Retrieve all the items posted to a group/record/user.
    // Parameters: 
    // Return type: List<FeedItemWrapper>
    // ****************************************
    @RemoteAction
    public static List<FeedItemWrapper> retrieveAllPosts(String recordID)
    {
        try
        {
            Id parentID = recordId;
            List<Id> UserIds = new List<Id>();
            List<FeedItemWrapper> FeedItemswrapperList = new List<FeedItemWrapper>();
            List<Id> feedItemIds = new List<string>();
            
            Map<id,FeedItem> allFeedsList = new Map<id,FeedItem>([
                select id, Body, LinkUrl, ContentDescription, /* ContentData, // removed because View State error */
                RelatedRecordId, ContentFileName, ContentSize, ContentType, ParentId,
                CommentCount, BestCommentId, LikeCount, CreatedById, CreatedBy.Name, 
                CreatedBy.FirstName, CreatedBy.LastName, CreatedDate,
                (select id, FeedEntityId, CreatedById from FeedLikes)
                from FeedItem 
                where parentID = :parentID 
                order by LastModifiedDate desc
                limit 50
            ]);
            
            // getting current user likes requires a separate query because of the way FeedLikes is limited
            Map<id,FeedItem> FeedListWithUserLikes = new Map<id,FeedItem>([
                select id, (select id, FeedEntityId, CreatedById from FeedLikes Where CreatedById = :UserInfo.getUserId())
                from FeedItem 
                where id in :allFeedsList.keySet()
            ]);
            
            for(FeedItem objfi : allFeedsList.values()){
                UserIds.add(objfi.CreatedByID);
            }
            
            list<User> CreatedByUsers = new list<User>();
            
            if(allFeedsList != null && !allFeedsList.isEmpty())
            {
                for(FeedItem item : allFeedsList.values())
                {
                    feedItemIds.add(item.id);
                }
                
                //Fetch comments for all the feedItem ids
                Map<id,List<FeedComment>> feedCommentsMap = getAllComments(feedItemIds);
                
                for(ID objFeedItemID : feedItemIds){
                    if(feedCommentsMap.get(objFeedItemID)==null) continue;
                    for(FeedComment objfc : feedCommentsMap.get(objFeedItemID)){
                        UserIds.add(objfc.CreatedByID);
                    }
                }
                
                Map<id,User> mapUser = new Map<id,User>([select id, name, SmallPhotoURL from User where id IN:UserIds]);
                
                FeedItemWrapper chatterFeedItem;
                
                //Iterate and create wrapper object
                for(FeedItem feedItemObj : allFeedsList.values())
                {
                    chatterFeedItem= new FeedItemWrapper();
                    
                    if(FeedListWithUserLikes.get(feedItemObj.id).FeedLikes.size()>0) { chatterFeedItem.isLiked=true; }
                    
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
                    
                    FeedItemswrapperList.add(chatterFeedItem);
                }
                return FeedItemswrapperList;
            }
            return null;
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return null;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Delete all posts.
    // Parameters: USer / Group / SObjectID(required)
    // Return type: void
    // **************************************** 
    @RemoteAction
    public static void deleteAllPosts(String recordID)
    {
        try
        {
            Id parentID = recordID;
            List<FeedItem> feedItemsList = [
                select id 
                from FeedItem 
                where parentID =:parentID
            ]; 
            if(feedItemsList!=null)
            {
                delete feedItemsList;
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: This method adds comment to a feed.
    // Parameters: feedItem ID(required), commentBody (required)
    // Return type: FeedCommentWrapper
    // ****************************************
    @RemoteAction
    public static FeedCommentWrapper addComment(String feedItemID, String CommentBody)
    {
        try 
        {
            FeedCommentWrapper WrappedComment = new FeedCommentWrapper();
            
            Id feedItem = feedItemID;	
            if(CommentBody==null || String.isBlank(CommentBody))
            {
                throw new ChatterException('Comment must be specified');
            }
            
            FeedItem feedItemObj = [
                select id from FeedItem
                where id=:feedItem
            ];
            
            FeedComment feedCommentObj;
            if(feedItemObj!=null)
            {
                feedCommentObj = new FeedComment();
                feedCommentObj.FeedItemId = feedItemObj.id;
                feedCommentObj.CommentBody = CommentBody;
                feedCommentObj.CreatedById = UserInfo.getUserId();
                feedCommentObj.CreatedDate = System.now();
                insert feedCommentobj;
            }
            
            
            WrappedComment.FeedCommentItem = feedCommentobj;
            WrappedComment.Message = 'success';
            return WrappedComment;
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return null;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: This method deletes comment from a feed.
    // Parameters: feedCommentID(required)
    // Return type: void
    // ****************************************
    @RemoteAction
    public static void deleteComment(String feedCommentID)
    {
        try
        {
            Id feedComment = feedCommentID;
            FeedComment feedCommentObj = [
                select id from FeedComment 
                where id=:feedComment
            ];
            
            if(feedCommentObj!=null)
            {
                delete feedCommentObj;
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Retrieve all the comments related to feedItemIds
    // Parameters: List<FeedItemIds>
    // Return type: Map<feedItemId,List<FeedComments>
    // ****************************************
    @RemoteAction
    public static Map<Id,List<FeedComment>> getAllComments(List<String> feedItemIdsList)
    {
        try
        {
            Map<Id,List<FeedComment>> feedCommentsMap = new Map<Id,List<FeedComment>>();
            if(feedItemIdsList!=null || !feedItemIdsList.isEmpty())
            {
                for(FeedComment feedCommentObj : [
                    select id,RelatedRecordId,CommentBody,CommentType,CreatedById,
                    feedItemId,CreatedBy.FirstName,CreatedBy.Lastname,CreatedDate
                    //,(select id,FeedEntityId,CreatedById from FeedLikes) // FeedLikes on comments cannot be queried by the API
                    from FeedComment 
                    where feedItemId in :feedItemIdsList])
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
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return null;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Like a post.
    // Parameters: feedItemID(required)
    // Return type: void
    // ****************************************
    @RemoteAction
    public static FeedLike likeAPost(String postId)
    {
        try
        {
            Id feedItemId = postId;
            system.debug('************' +feedItemId);
            FeedItem feedItemObj = [
                select id,(select id from FeedLikes) 
                from FeedItem 
                where id=:feedItemId
            ];
            
            Map<id,FeedItem> mapFeedsList = new Map<id,FeedItem>([
                select id,Body,LinkUrl,ContentData,ContentDescription,
                ContentFileName,ContentSize,ContentType,parentId,
                CommentCount,BestCommentId,
                LikeCount,CreatedById,CreatedBy.Name,CreatedBy.FirstName,CreatedBy.LastName,createddate,
                (select id,FeedEntityId,CreatedById from FeedLikes where createdByid=:Userinfo.getUserId())
                from FeedItem where id =:feedItemId 
            ]);
            
            if(mapFeedsList.get(feedItemObj.id).FeedLikes.size()>0) {
                throw new ChatterException('Post is already liked');
            }
            else
            {
                FeedLike feedLikeObj = new FeedLike();
                feedLikeObj.FeedItemId = feedItemId;
                insert feedLikeObj;
                return feedLikeObj;
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return null;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Like a Comment.
    // Parameters: Feed Comment Id(required)
    // Return type: void
    // ****************************************
    @RemoteAction
    public static void likeAComment(String commentId)
    {
        try
        {
            Id feedCommentID = commentId;
            FeedComment feedCommentObj = [
                select id,feedItemId 
                from FeedComment 
                where id=:feedCommentID
            ];
            //Likes on comments can't be queried. SO no check if like already exists on comment.
            if(feedCommentObj!=null)
            {
                FeedLike feedLikeObj = new FeedLike();
                feedLikeObj.FeedItemId = feedCommentObj.feedItemId;
                feedLikeObj.FeedEntityId = commentId;
                insert feedLikeObj;
            }
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: unlike a post.
    // Parameters: Feed Comment Id(required)
    // Return type: void
    // **************************************** 
    @RemoteAction
    public static String unlikeAPost(String postID)
    {
        try
        {
            Id feedItemId = postId;
            FeedItem feedItemObj = [
                select id,(select id from FeedLikes where createdByid=:Userinfo.getUserId()) 
                from FeedItem 
                where id=:feedItemId
            ]; 
            FeedLike likes  = feedItemObj.FeedLikes;
            Delete likes;
            return 'success';
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return null;
        }
    }
    
    @RemoteAction
    public static String photoURL()
    {
        try
        {
            String photoURL = [select SmallPhotoURL from User where id=:UserInfo.getUserId()].SmallPhotoURL;
            return photoURL;
        }
        catch(Exception e)
        {
            ALL_UtilitiesMiscellaneous.showDebug = true;
            ALL_UtilitiesMiscellaneous.debug(e.getMessage());
            return null;
        }
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Wrapper to bind FeedComments and FeedItem objects
    // ****************************************
    public class FeedItemWrapper
    {
        public FeedItem feedItemObj {get;set;}
        public List<FeedCommentWrapper> FeedComments {get;set;}
        
        public Boolean isLiked {get;set;}
        public Id feedItemId {get;set;}
        public String UserPhoto {get;set;}
        
        public String postMessage {get;set;}
    }
    
    public class FeedCommentWrapper
    {
        public FeedComment FeedCommentItem {get;set;}
        public Boolean isLiked;
        public List<FeedComment> feedCommentsList {get;set;} 
        public Id feedItemId;
        public String UserPhoto {get;set;}
        public String Message;
    }
    
    // ****************************************
    // Author: Hemanth Kesapragada
    // Description: Custom Exception class to set custom messages. 
    // Extends Exception class
    // ****************************************
    public class ChatterException Extends Exception
    {}
}