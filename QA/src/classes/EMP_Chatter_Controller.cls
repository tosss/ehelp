public class EMP_Chatter_Controller { 
    
    public String GroupID {get;set;}
    public List<ALL_ChatterUtility.FeedItemWrapper> retrieveAllFeeds {get;set;}
    
    public EMP_Chatter_Controller() { }
    
    public String ChatterGroupIdValue {
        get{
            return GroupID;
        }
        set {
            GroupID = value;
            retrieveAllFeeds = new List<ALL_ChatterUtility.FeedItemWrapper>();
            retrieveAllFeeds = ALL_ChatterUtility.retrieveAllPosts(GroupID);
        }
    }
}