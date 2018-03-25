/*******************************************************
 * Author: Hemanth.Kesapragada@cdk.com
 * Description: Test class for ALL_ChatterUtlity class
 * 
 * History:
 * 2015-07-07 	Hemanth Kesapragada		Created
 * 2015-07-21	Hemanth Kesapragada		Added test control variables
 * *************************************************** */
@isTest
public class ALL_ChatterUtility_Test {
    //Toggle enable/disable debug logs
    private static final boolean GENERATE_DEBUG_LOGS = true;
    //TestMethod control variables
    private static final boolean RUN_ALL = true;
    private static final boolean RUN_FETCH_FOLLOWERS = true;
    private static final boolean RUN_FETCH_SUBSCRIPTIONS = true;
    private static final boolean RUN_FOLLOW_RECORD = true;
    private static final boolean RUN_UNFOLLOW_RECORD = true;
    private static final boolean RUN_POST_TO_CHATTER = true;
    private static final boolean RUN_POST_FILE_TO_CHATTER = true;
    private static final boolean RUN_CREATE_FILE_TO_CHATTER = true;
    private static final boolean RUN_ADD_COMMENT = true;
    private static final boolean RUN_DELETE_COMMENT = true;
    private static final boolean RUN_DELETE_POST = true;
    private static final boolean RUN_RETRIEVE_ALL_POST = true;
    private static final boolean RUN_LIKE_POST = true;
    private static final boolean RUN_LIKE_COMMENT = true;
    private static final boolean RUN_UNLIKE_POST = true;
    private static final boolean RUN_DELETE_ALL_POSTS = true;
    private static final boolean RUN_GET_ALL_COMMENTS = true;
    private static final boolean RUN_PHOTO_URL = true;
    
    //Setup test data
    @TestSetup public static void loadData()
    {
        List<sObject> genericList = new List<sObject>();
        Account account = DS_TestObjects.NewAccount_Inserted();
        Opportunity opportunity = DS_TestObjects.NewOpportunity_Inserted();
        User userObj = DS_TestObjects.NewUser_Inserted();
        
        EntitySubscription follow = new EntitySubscription (
            parentId = account.id,
            subscriberid = UserInfo.getUserId());
        genericList.add(follow);
        
        EntitySubscription follow2 = new EntitySubscription (
            parentId = account.id,
            subscriberid = userObj.id);
        genericList.add(follow2);
        
        EntitySubscription follow3 = new EntitySubscription (
            parentId = opportunity.id,
            subscriberid = UserInfo.getUserId());
        genericList.add(follow3);
        insert genericList;
        
        FeedItem feedItemObj = new FeedItem();
        feedItemObj.Body = 'This is test feedItem';
        feedItemObj.ParentId = account.id;
        insert feedItemObj;
        
        FeedComment feedCommentObj = new FeedComment();
        feedCommentObj.CommentBody = 'Test Comment';
        feedCommentObj.FeedItemId = feedItemObj.Id;
        insert feedCommentObj;
        
        FeedItem feedItemObj2 = new FeedItem();
        feedItemObj2.Body = 'Test FeedItem';
        feedItemObj2.ParentId = opportunity.id;
        insert feedItemObj2;
        
        FeedLike feedLikeObj = new FeedLike();
        feedLikeObj.FeedItemId = feedItemObj2.id;
        insert feedLikeObj;    
    }
    
    public static testMethod void  testFetchFollowersByRecordID()
    {
        if(RUN_FETCH_FOLLOWERS || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing fetchFollowersByRecordID method');
            User userObj = [
                select id 
                from User 
                order by createdDate 
                desc limit 1
            ];
            Account accountObj = [
                select id 
                from Account 
                limit 1
            ];
            String accountID = accountObj.Id;
            List<user> userList = ALL_ChatterUtility.fetchFollowersByRecordID(accountID);
            
            List<String> expectedIds = new List<String>();
            expectedIds.add(UserInfo.getUserId());
            expectedIds.add(userObj.Id);
            expectedIds.sort();
            
            List<String> actualIds = new List<String>();
            for(User newUserObj : userList)
            {
                actualIds.add(newUserObj.Id);
            }
            actualIds.sort();
            
            String expectedId = ALL_UtilitiesString.ListToDelimitedString(expectedIds, ',');
            String actualId = ALL_UtilitiesString.ListToDelimitedString(actualIds, ',');
            System.assertEquals(expectedId, actualId);
            
            System.assertEquals(2, userList.size());
            
            List<user> newUserList = ALL_ChatterUtility.fetchFollowersByRecordID('abc');
            System.assertEquals(null, newUserList);
            Test.stopTest();
        }
    }
    
    public static testMethod void testFetchSubscriptionsByUserID()
    {
        if(RUN_FETCH_SUBSCRIPTIONS || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing fetchSubscriptionsByUserID method');
            Opportunity opportunityObj = [
                select id 
                from Opportunity 
                limit 1
            ];
            Account accountObj = [
                select id 
                from Account 
                limit 1];
            
            List<EntitySubscription> subscriptionList = ALL_ChatterUtility.fetchSubscriptionsByUserID(UserInfo.getUserId());
            
            List<String> expectedIds = new List<String>();
            expectedIds.add(opportunityObj.Id);
            expectedIds.add(accountObj.Id);
            expectedIds.sort();
            
            List<String> actualIds = new List<String>();
            for(EntitySubscription entitySubObj : subscriptionList)
            {
                actualIds.add(entitySubObj.parentid);
            }
            actualIds.sort();
            
            String expectedId = ALL_UtilitiesString.ListToDelimitedString(expectedIds, ',');
            String actualId = ALL_UtilitiesString.ListToDelimitedString(actualIds, ',');
            System.assertEquals(expectedId, actualId);
            
            System.assertEquals(2, subscriptionList.size());
            
            User NewUserObj = new User(
                UserName='testUser1234@cdk.com', 
                Email='testUser@cdk.com', 
                Alias='TestU',
                EmailEncodingKey='UTF-8', 
                FirstName='TestFName',
                LastName='TestLName', 
                LanguageLocaleKey='en_US', 
                LocaleSIDKey='en_US', 
                profileid=UserInfo.getProfileId(), 
                TimeZoneSIDKey='America/Chicago',
                ADID__c='A',
                isActive=false,
                FederationIdentifier = 'F'
            );
            insert NewUserObj;
            List<EntitySubscription> subList = ALL_ChatterUtility.fetchSubscriptionsByUserID(NewUserObj.id);
            System.assertEquals(null, subList);
            Test.stopTest();
        }
    }
    
    public static testMethod void testFollowRecord()
    {
        if(RUN_FOLLOW_RECORD || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing followRecord method');
            Account accountObj = DS_TestObjects.NewAccount_Inserted();
            EntitySubscription actualSubscObj = ALL_ChatterUtility.followRecord(UserInfo.getUserId(), accountObj.id);
            EntitySubscription expectedSubsObj = [
                select id 
                from EntitySubscription 
                where parentId =:accountObj.Id 
                and subscriberid=:UserInfo.getUserId()
            ];
            
            System.assertEquals(expectedSubsObj.id,actualSubscObj.Id);
            
            EntitySubscription newSubObj = ALL_ChatterUtility.followRecord(UserInfo.getUserId(),'');
            System.assertEquals(null,newSubObj);
            Test.stopTest();
        }
    }
    
    public static testMethod void testUnFollowRecord()
    {
        if(RUN_UNFOLLOW_RECORD || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing unfollowRecord method');
            Opportunity OpportunityObj = [
                select id 
                from Opportunity 
                limit 1
            ];
            ALL_ChatterUtility.unfollowRecord(UserInfo.getUserId(), OpportunityObj.id);
            List<EntitySubscription> expectedSubsList = [
                select id 
                from EntitySubscription 
                where parentId =:OpportunityObj.Id 
                and subscriberid=:UserInfo.getUserId()
            ];
            
            System.assertEquals(0, expectedSubsList.size());
            
            ALL_ChatterUtility.unfollowRecord(UserInfo.getUserId(), '');
            Test.stopTest();
        }
    }
    
    public static testMethod void testPostToChatter()
    {
        if(RUN_POST_TO_CHATTER || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing postToChatter method');
            String opportunityId  = [
                select id 
                from opportunity 
                limit 1
            ].Id;
            
            String body = 'Test string in body';
            String url  = 'www.google.com';
            FeedItem feedItemObj = ALL_ChatterUtility.postToChatter(opportunityId, body, url);
            FeedItem newFeedItemObj = [
                select id,body,parentId,LinkUrl 
                from FeedItem 
                where parentId=:opportunityId 
                and id=:feedItemObj.id
            ];
            
            System.assertEquals(body, newFeedItemObj.Body);
            //System.assertEquals('http://'+url, newFeedItemObj.LinkUrl);
          //  System.assertEquals(feedItemObj.id, newFeedItemObj.id);
            
           // FeedItem tempFeedItemObj = ALL_ChatterUtility.postToChatter(opportunityId,'', '');
          //  System.assertEquals(null, tempFeedItemObj);
            
           // FeedItem tempFeedItemObj2 = ALL_ChatterUtility.postToChatter('',body, url);
          //  System.assertEquals(null, tempFeedItemObj2);
            
            Test.stopTest();
        }
    }
    
  /*  public static testMethod void testPostFileToChatter()
    {
        if(RUN_POST_FILE_TO_CHATTER || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing postFileToChatter method');
            String testString = 'Test';
            Blob bodyBlob =  Blob.valueOf(testString);
            ALL_ChatterUtility.attachedFile = bodyBlob;
            ALL_ChatterUtility.attachmentName = 'Test.txt';
            String oppId = [select id from opportunity limit 1].id;
            String body = 'Sample Text';
            String url  = 'www.google.com';
            FeedItem feedItemObj  = ALL_ChatterUtility.postFileToChatter(oppId, body, url);
            
            FeedItem newFeedItemObj = [
                select id,body,LinkUrl,ContentData,ContentFileName 
                from FeedItem 
                where parentId=:oppId 
                and id=:feedItemObj.id
            ];
            System.assertEquals('Test.txt', newFeedItemObj.ContentFileName);
            System.assertEquals(bodyBlob.toString(), (newFeedItemObj.ContentData).toString());
            System.assertEquals(body, newFeedItemObj.Body);
            System.assertEquals('http://'+url, newFeedItemObj.LinkUrl);
            
            ALL_ChatterUtility.attachedFile = null;
            FeedItem tempFeedItemObj  = ALL_ChatterUtility.postFileToChatter(oppId, '', '');
            System.assertEquals(null, tempFeedItemObj);
            
            ALL_ChatterUtility.attachedFile = bodyBlob;
            ALL_ChatterUtility.attachmentName = 'test';
            FeedItem tempFeedItemObj2  = ALL_ChatterUtility.postFileToChatter(oppId, '', '');
            System.assertEquals(null, tempFeedItemObj2);
            
            Test.stopTest();
        }
    }
    */
    public static testMethod void testCreateTxTFileToChatter()
    {
        if(RUN_CREATE_FILE_TO_CHATTER || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing createFileToChatter method - Text file');
            String oppId = [select id from opportunity limit 1].Id;
            String body= 'This is test post';
            String attachmentBody = 'This is text in the attachment';
            String url = 'www.google.com';
            String filename='document1';
            String extension = 'txt';
            
            FeedItem feedItemObj = ALL_ChatterUtility.createFileToChatter(oppId, body, url, attachmentBody, filename, extension);
            
            FeedItem newFeedItemObj = [
                select id,body,LinkUrl,ContentData,ContentFileName 
                from FeedItem 
                where parentId=:oppId 
                and id=:feedItemObj.id
            ];
            
            System.assertEquals(body, newFeedItemObj.body);
            //http gets added if it is URL type field
            System.assertEquals('http://'+url, newFeedItemObj.LinkUrl);
            System.assertEquals(filename+'.'+extension, newFeedItemObj.ContentFileName);
            System.assertEquals(attachmentBody, (newFeedItemObj.ContentData).toString());
            
            Test.stopTest();
        }
    }
    
    public static testMethod void testCreateDocFileToChatter()
    {
        Test.startTest();
        setHeaderLogs('Testing createFileToChatter method - Doc File');
        String oppId = [select id from opportunity limit 1].Id;
        String attachmentBody = 'This is text in the attachment';
        String filename='document1';
        String extension = 'docx';
        String body = '';
        String url = '';
        
        FeedItem feedItemObj = ALL_ChatterUtility.createFileToChatter(oppId, body, url, attachmentBody, filename, extension);
        
        FeedItem newFeedItemObj = [
            select id,body,LinkUrl,ContentData,ContentFileName 
            from FeedItem 
            where parentId=:oppId 
            and id=:feedItemObj.id
        ];

        System.assertEquals(filename+'.doc', newFeedItemObj.ContentFileName);
        System.assertEquals(attachmentBody, (newFeedItemObj.ContentData).toString());
        
        Test.stopTest();
    }
    
     public static testMethod void testCreatePdfFileToChatter()
    {
        if(RUN_CREATE_FILE_TO_CHATTER || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing createFileToChatter method - PDF file');
            String oppId = [select id from opportunity limit 1].Id;
            String attachmentBody = 'This is text in the attachment';
            String filename='document1';
            String extension = 'pdf';
            String body = '';
            String url = '';
            
            FeedItem feedItemObj = ALL_ChatterUtility.createFileToChatter(oppId, body, url, attachmentBody, filename, extension);
            
            FeedItem newFeedItemObj = [
                select id,body,LinkUrl,ContentData,ContentFileName 
                from FeedItem 
                where parentId=:oppId 
                and id=:feedItemObj.id
            ];
            System.assertEquals(filename+'.'+extension, newFeedItemObj.ContentFileName);
            
            Test.stopTest();
        }
    }
    
    public static testMethod void testCreateFileToChatterCatch()
    {
        if(RUN_CREATE_FILE_TO_CHATTER || RUN_ALL)
        {
            //Test Exceptions
            Test.startTest();
            setHeaderLogs('Testing createFileToChatter method - Exceptions');
            String oppId = [select id from opportunity limit 1].Id;
            String attachmentBody = '';
            String filename='';
            String extension = '';
            String body = '';
            String url = '';
            
            FeedItem feedItemObj = ALL_ChatterUtility.createFileToChatter(oppId, body, url, attachmentBody, filename, extension);
            System.assertEquals(null, feedItemObj);
            
            attachmentBody = 'This is test';
            filename='Document';
            extension = null;
            feedItemObj = ALL_ChatterUtility.createFileToChatter(oppId, body, url, attachmentBody, filename, extension);
            System.assertEquals(null, feedItemObj);
            
            filename=null;
            extension = 'pdf';
            feedItemObj = ALL_ChatterUtility.createFileToChatter(oppId, body, url, attachmentBody, filename, extension);
            System.assertEquals(null, feedItemObj);
        }
     }
    
    public static testMethod void testAddComment()
    {
        if(RUN_ADD_COMMENT || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing addComment method');
            String accountId = [select id from Account limit 1].Id;
            String feedItemID = [select id from FeedItem where parentId=:accountId limit 1].Id;
            String commentBody = 'This is test comment';
            ALL_ChatterUtility.FeedCommentWrapper feedCommentWrapperObj = ALL_ChatterUtility.addComment(feedItemID, CommentBody);
            FeedComment feedCommentObj = feedCommentWrapperObj.FeedCommentItem;
            
            FeedComment newFeedCommentObj = [
                select id,commentbody 
                from FeedComment 
                where feedItemId=:feedItemID 
                and id=:feedCommentObj.id
            ];
            System.assertEquals(commentBody, newFeedCommentObj.CommentBody);
            
            ALL_ChatterUtility.FeedCommentWrapper  tempFeedCommentObj = ALL_ChatterUtility.addComment(feedItemID, '');
            //System.assertEquals(null, tempFeedCommentObj.FeedCommentItem);
            
            ALL_ChatterUtility.FeedCommentWrapper tempFeedCommentObj2 = ALL_ChatterUtility.addComment('', '');
            //System.assertEquals(null, tempFeedCommentObj2.FeedCommentItem);
            Test.stopTest();
        }
    }
    
    public static testMethod void testDeleteComment()
    {
        if(RUN_DELETE_COMMENT || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing deleteComment method');
            String acountId = [select id from Account limit 1].Id;
            String feedItemId = [select id from FeedItem where parentId=:acountId limit 1].Id;
            String feedCommentId = [select id from FeedComment where feedItemId = :feedItemId limit 1].Id;
            ALL_ChatterUtility.deleteComment(feedCommentId);
            List<FeedComment> feedCommentsList = [
                select id 
                from FeedComment 
                where feedItemId=:feedItemId 
                and id=:feedCommentId
            ];
            System.assertEquals(0, feedCommentsList.size());
            ALL_ChatterUtility.deleteComment('');
            Test.stopTest();
        }
    }
    
    public static testMethod void testDeletePost()
    {
        if(RUN_DELETE_POST || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing deletePost method');
            String accountId = [select id from Account limit 1].Id;
            String feedItemID = [select id from FeedItem where parentId=:accountId limit 1].Id;
            ALL_ChatterUtility.deletePost(feedItemID);
            
            List<FeedItem> feedItemList = [select id from FeedItem where parentId=:accountID and id=:feedItemID];
            System.assertEquals(0, feedItemList.size());
            
            ALL_ChatterUtility.deletePost('');
            Test.stopTest();
        }
    }
    
    public static testMethod void testRetreiveAllPosts()
    {
        if(RUN_RETRIEVE_ALL_POST || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing retrieveAllPosts method');
            String accountId = [select id from Account limit 1].Id;
            List<ALL_ChatterUtility.FeedItemWrapper> feedItemWrapperList = ALL_ChatterUtility.retrieveAllPosts(accountId);
            FeedItem expectedFeedItemObj = [select parentId,Id from FeedItem where parentId=:accountId limit 1];
            FeedComment expectedFeedCommentObj = [select parentId,Id,feedItemId from FeedComment where feedItemId = :expectedFeedItemObj.Id limit 1 ];
            String expectedFeedItemId  = expectedFeedItemObj.Id;
            String expectedFeedCommentId = expectedFeedCommentObj.Id;
            
            ALL_ChatterUtility.FeedItemWrapper wrapperObj =  feedItemWrapperList.get(0);
            String actualFeedItemId = wrapperObj.feedItemObj.id;
            
            List<ALL_ChatterUtility.FeedCommentWrapper> commentsList = wrapperObj.FeedComments;
            ALL_ChatterUtility.FeedCommentWrapper commentWrapperObj = commentsList.get(0);
            String actualFeedCommentId = commentWrapperObj.FeedCommentItem.Id;

            System.assertEquals(expectedFeedItemId, actualFeedItemId);
            System.assertEquals(expectedFeedCommentId, actualFeedCommentId);

            Test.stopTest();
        }
    }
    
    public static testMethod void testLikeAPost()
    {
        if(RUN_LIKE_POST || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing likeAPost method');
            String accountId = [select id from Account limit 1].Id;
            FeedItem feedItemObj = [select id,likeCount from FeedItem where parentId=:accountId limit 1];
            Integer expectedLikeCount = feedItemObj.likeCount;
            ALL_ChatterUtility.likeAPost(feedItemObj.Id);
            FeedItem newFeedItemObj = [
                select id,likeCount 
                from FeedItem 
                where parentId=:accountId 
                and id=:feedItemObj.Id 
                limit 1
            ];
            
            Integer actualLikedCount = newFeedItemObj.LikeCount;
            //The post is liked - there will be difference in the like count
            System.assertNotEquals(expectedLikeCount, actualLikedCount);
            
            //Already liked post - Exception
            ALL_ChatterUtility.likeAPost(feedItemObj.Id);
            Test.stopTest();
        }
    }
    
    public static testMethod void testLikeAComment()
    {
        if(RUN_LIKE_COMMENT || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing likeAComment method');
            String accountId = [select id from Account limit 1].Id;
            String feedItemId = [select id,likeCount from FeedItem where parentId=:accountId limit 1].id;
            FeedComment feedCommentObj = [select id from FeedComment where feedItemId=:feedItemId];
            ALL_ChatterUtility.likeAComment(feedCommentObj.id);
            //No assert statements as cannot query likes on comments
            //Only way to test is to like the comment again and this will throw exception
            ALL_ChatterUtility.likeAComment(feedCommentObj.id);
            Test.stopTest();
        }
    }
    
    public static testMethod void testUnlikeAPost()
    {
        if(RUN_UNLIKE_POST || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing unlikeAPost method');
            String opportunityId = [select id from Opportunity limit 1].Id;
            FeedItem feedItemObj = [select id,likeCount from FeedItem where parentId=:opportunityId limit 1];
            Integer expectedLikeCount = feedItemObj.likeCount;
            ALL_ChatterUtility.unlikeAPost(feedItemObj.Id);
            FeedItem newFeedItemObj = [
                select id,likeCount 
                from FeedItem 
                where parentId=:opportunityId 
                and id=:feedItemObj.Id 
                limit 1
            ];
            Integer actualLikeCount = newFeedItemObj.likeCount;
            System.assertNotEquals(expectedLikeCount, actualLikeCount);
            
            ALL_ChatterUtility.unlikeAPost(feedItemObj.Id);
            Test.stopTest();
        }
    }
    
    public static testMethod void testDeleteAllPosts()
    {
        if(RUN_DELETE_ALL_POSTS || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing deleteAllposts method');
            String accountId = [select id from Opportunity limit 1].Id;
            List<FeedItem> expectedFeedItemList = [select id from FeedItem where parentId=:accountId];
            ALL_ChatterUtility.deleteAllposts(accountId);
            List<FeedItem> actualFeedItemList = [select id from FeedItem where parentId=:accountId];
            System.assertNotEquals(expectedFeedItemList.size(), actualFeedItemList.size());
            
            ALL_ChatterUtility.deleteAllposts('');
            Test.stopTest();
        }
    }
    
    public static testMethod void testGetAllComments()
    {
        if(RUN_GET_ALL_COMMENTS || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing get all comments method');
            String accountId = [select id from Account limit 1].Id;
            
            List<FeedItem> expectedFeedItemList = [select id,CommentCount from FeedItem where parentId=:accountId];
            List<string> feedItemIds = new List<String>();
            for(FeedItem feedItemObj : expectedFeedItemList)
            {
                feedItemIds.add(feedItemObj.id);
            }

            Map<id,List<FeedComment>> FeedCommentsMap =  ALL_ChatterUtility.getAllComments(feedItemIds);
            String sampleFeedItemId = expectedFeedItemList.get(0).Id;
            List<FeedComment> expectedFeedCommentsList = FeedCommentsMap.get(sampleFeedItemId);
            
            //Take [0] as sample for testing 
            FeedItem actualFeedItem = [select id,commentCount from FeedItem where parentId=:accountId and id=:sampleFeedItemId];
            System.assertEquals(expectedFeedCommentsList.size(), actualFeedItem.CommentCount);
            
            
            Map<id,List<FeedComment>> newFeedCommentsMap =  ALL_ChatterUtility.getAllComments(null);
            System.assertEquals(null,newFeedCommentsMap);
            Test.stopTest();
        }
    }
    
    public static testMethod void testPhotoURL()
    {
        if(RUN_PHOTO_URL || RUN_ALL)
        {
            Test.startTest();
            setHeaderLogs('Testing photo URL method');
            String url =  ALL_ChatterUtility.photoURL();
            System.assertNotEquals(null, url);
            Test.stopTest();
            
        }
    }
    
    private static void setHeaderLogs(String txt)
    {
        if(GENERATE_DEBUG_LOGS)
        {
            //Genereate debug logs
            System.debug('**********************************');
            System.debug('***** '+txt);
            System.debug('**********************************');  
        }
        
    }
    
}