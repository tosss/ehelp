trigger ALL_FeedComment on FeedComment(before insert)
{
    //An instance of ALL_BlacklistFilterDelegate class is created.
    ALL_BlacklistFilterDelegate blacklistFilterDelegate=new ALL_BlacklistFilterDelegate();
    
    //filterFeedComments method of ALL_BlacklistFilterDelegate class is invoked and the list of FeedItem records are passed.
    blacklistFilterDelegate.filterFeedComments(Trigger.New);
}