public class EMP_Search_Controller
{
    public Set<String> groupKeys {get;set;}
    public List<FeedItemWrapper> retrieveAllFeeds {get;set;}
    public Map<String, List<FeedItemWrapper>> allFeedItemWrappers {get; set;}
    public String grp{get; set;}  // This will hold the selected value, the id in here
	public String searchTerm{get;set;}
    
    public EMP_Search_Controller() 
    {
        String urlSearchTerm = ApexPages.currentPage().getParameters().get('str');        
        if(String.isNotEmpty(urlSearchTerm)) {
            searchTerm = urlSearchTerm;
        }
        system.debug('@searchTerm is having ' + searchTerm);
        ApexPages.currentPage().getParameters().put('str', searchTerm);
        
        String urlGrp = ApexPages.currentPage().getParameters().get('grp');
        if(String.isNotBlank(urlGrp)) {
            grp = urlGrp;
        }
        system.debug('@grp is having ' + grp);
        ApexPages.currentPage().getParameters().put('grp', grp);
        
        retrieveAllFeeds = new List<FeedItemWrapper>();
        retrieveAllFeeds = retrieveAllPosts(searchTerm, grp);
        
        system.debug('@developer --> retrieveAllFeeds :'+retrieveAllFeeds);
        allFeedItemWrappers = transformRetrieveAllPosts(retrieveAllFeeds);
        system.debug('@developer --> allFeedItemWrappers :'+allFeedItemWrappers);
        groupKeys = allFeedItemWrappers.keySet();
    }
    
    
    public PageReference searchChatter() 
    {
        //PageReference pg = Page.EMP_Search;
        PageReference pg = ApexPages.currentPage();
        
        //  PageReference pg = new pageReference('/Employees/apex/EMP_AssociatePortalPage?page=EMP_Search');
        retrieveAllFeeds = new List<FeedItemWrapper>();
        retrieveAllFeeds = retrieveAllPosts(searchTerm, grp);
        
        system.debug('@developer --> retrieveAllFeeds :'+retrieveAllFeeds);
        allFeedItemWrappers = transformRetrieveAllPosts(retrieveAllFeeds);
        system.debug('@developer --> allFeedItemWrappers :'+allFeedItemWrappers);
        groupKeys = allFeedItemWrappers.keySet();
        
        return pg;
    }
   
    public List<SelectOption> getChatterGroupOptions() {
        List<SelectOption> optns = new List<Selectoption>();
        List<CollaborationGroup> groups;
        groups = retrieveChatterGroups();
        for(CollaborationGroup obj : groups){
           optns.add(new selectOption(String.valueOf(obj.Id).substring(0, 15), obj.Name));
        }            

        return optns;
	}
    
    public static List<CollaborationGroup> retrieveChatterGroups() {
    	List<CollaborationGroup> Groups;   
        list<CollaborationGroupMember> Membership = [
            Select CollaborationGroupId 
            From CollaborationGroupMember 
            Where MemberId = :UserInfo.getUserId()
        ];
        
        list<Id> MembershipIds = new list<Id>();
        for(CollaborationGroupMember groupMember : Membership) { 
            MembershipIds.add(groupMember.CollaborationGroupId); 
        }
        
        Groups = [
            SELECT Id, Name
            FROM CollaborationGroup
            WHERE Id IN :MembershipIds
            AND NetworkId != null
        ];
        
        return Groups;
    }
    
    public static Map<String, List<FeedItemWrapper>> transformRetrieveAllPosts(List<FeedItemWrapper> retrieveAllFeeds)
    {
        Map<String, List<FeedItemWrapper>> transformedPosts = new Map<String, List<FeedItemWrapper>>();
        
        If(retrieveAllFeeds != null && !retrieveAllFeeds.isEmpty()) {
            for(FeedItemWrapper itemWrapper : retrieveAllFeeds)
            {
                if(transformedPosts.get(itemWrapper.groupName) == null) {
                    list<FeedItemWrapper> groupNameItems = new List<FeedItemWrapper>();
                    groupNameItems.add(itemWrapper);
                    transformedPosts.put(itemWrapper.groupName, groupNameItems);
                }
                else {
                    transformedPosts.get(itemWrapper.groupName).add(itemWrapper);
                }
            }
        }
        
        return transformedPosts;
    }
    
    public static List<FeedItemWrapper> retrieveAllPosts(String searchTerm, String grp)
    {
        List<Id> UserIds = new List<Id>();
        List<FeedItemWrapper> FeedItemswrapperList = new List<FeedItemWrapper>();
        List<Id> feedItemIds = new List<string>();
        list<FeedItem> allFeedsList = new List<FeedItem>();
        
        allFeedsList = searchChatterFeeds(searchTerm, grp);
        
        if(allFeedsList != null && !allFeedsList.isEmpty())
        {
            for(FeedItem item : allFeedsList)
            {
                feedItemIds.add(item.id);
                UserIds.add(item.CreatedByID);
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
            
            Map<id,User> mapUser = new Map<id,User>([select id, name, SmallPhotoURL from User where id IN:UserIds]);
            
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
                
                system.debug('group name is ' + feedItemObj.Parent.Name);
                chatterFeedItem.groupName = feedItemObj.Parent.Name;
                
                FeedItemswrapperList.add(chatterFeedItem);
            }
            
            return FeedItemswrapperList;
        }
        return null;
    }
    
    public class FeedItemWrapper
    {
        public FeedItem feedItemObj {get;set;}
        public List<FeedCommentWrapper> FeedComments {get;set;}
        public Boolean isLiked {get;set;}
        public Id feedItemId {get;set;}
        public String UserPhoto {get;set;}
        public String groupName {get;set;}
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
        
    public static list<FeedItem> searchChatterFeeds(String searchTerm, String grp) {
        if(searchTerm != null && searchTerm.trim() != '')
        {
            List<CollaborationGroup> groups;
            if(Test.isRunningTest()) {
                groups = [
                    SELECT Id
                    FROM CollaborationGroup
                ];
            }
            else 
            {
                if(String.isNotBlank(grp)) {
                    groups = [
                        SELECT Id
                        FROM CollaborationGroup
                        WHERE Id = :grp
                    ];
                }
                else {
                    groups = retrieveChatterGroups();
                }
            }
            
            if(Test.isRunningTest()) {
                Id[] fixedSearchResults= new Id[1];
                List<FeedItem> allFeeds = [Select Id, Title From FeedItem Limit 1];
                fixedSearchResults[0] = allFeeds[0].Id;
                Test.setFixedSearchResults(fixedSearchResults);
            }
            
            List<List<SObject>> searchList = [
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
            
            set<Id> setFeedItemId = new set<Id>();
            for(FeedItem fi : (list<FeedItem>)searchList[0]){
                setFeedItemId.add(fi.Id);
            }
            
            for(FeedComment fc : (list<FeedComment>)searchList[1]){
                setFeedItemId.add(fc.FeedItemId);
            }
            
            list<FeedItem> FeedItemList = [Select Id, Title, Body, LinkUrl, ContentDescription,
                ContentFileName, ContentSize, ContentType, ParentId,
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
    
}